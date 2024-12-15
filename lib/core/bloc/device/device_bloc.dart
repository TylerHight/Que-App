// lib/core/bloc/device/device_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:que_app/core/services/database_service.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import 'package:que_app/core/models/device/device.dart';
import 'device_event.dart';
import 'device_state.dart';

class DeviceBloc extends Bloc<DeviceEvent, DeviceState> {
  static const int maxRetries = 3;
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration autoReconnectDelay = Duration(seconds: 30);

  final DatabaseService _databaseService;
  final BleService _bleService;

  StreamSubscription? _bleConnectionSubscription;
  StreamSubscription? _deviceStateSubscription;
  Timer? _reconnectTimer;
  Timer? _connectionTimeoutTimer;
  int _connectionRetries = 0;
  Device? _lastConnectedDevice;

  DeviceBloc({
    required DatabaseService databaseService,
    required BleService bleService,
  }) : _databaseService = databaseService,
        _bleService = bleService,
        super(DeviceInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<AddDevice>(_onAddDevice);
    on<RemoveDevice>(_onRemoveDevice);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectDevice>(_onDisconnectDevice);
    on<UpdateDevice>(_onUpdateDevice);
    on<RetryConnection>(_onRetryConnection);

    _setupConnectionListener();
  }

  void _setupConnectionListener() {
    _bleConnectionSubscription?.cancel();
    _bleConnectionSubscription = _bleService.connectionStatusStream.listen(
          (isConnected) async {
        if (_lastConnectedDevice != null) {
          if (isConnected) {
            _connectionRetries = 0;
            _reconnectTimer?.cancel();
            add(UpdateDevice(_lastConnectedDevice!.copyWith(isBleConnected: true)));
          } else {
            add(UpdateDevice(_lastConnectedDevice!.copyWith(isBleConnected: false)));
            _handleDisconnection();
          }
        }
      },
      onError: (error) {
        add(UpdateDevice(_lastConnectedDevice!.copyWith(isBleConnected: false)));
        _handleConnectionError(error);
      },
    );

    _deviceStateSubscription?.cancel();
    _deviceStateSubscription = _bleService.deviceStateStream.listen(
          (message) {
        // Handle device state updates
        if (message.contains('error')) {
          emit(DeviceError(message: message));
        }
      },
    );
  }

  Future<void> _onLoadDevices(LoadDevices event, Emitter<DeviceState> emit) async {
    emit(DeviceLoading());
    try {
      final devices = await _databaseService.getAllDevices();

      if (devices.isNotEmpty) {
        final connectedDevice = devices.firstWhere(
              (device) => device.isConnected,
          orElse: () => devices.first,
        );

        if (connectedDevice.isConnected) {
          add(ConnectToDevice(connectedDevice));
        }
      }

      emit(DevicesLoaded(devices: devices));
    } catch (e) {
      emit(DeviceError(message: 'Failed to load devices: $e'));
    }
  }

  Future<void> _onAddDevice(AddDevice event, Emitter<DeviceState> emit) async {
    try {
      if (state is DevicesLoaded) {
        final currentState = state as DevicesLoaded;

        final newDevice = Device(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          deviceName: event.name,
          connectedQueName: event.bluetoothDevice?.platformName ?? 'Unnamed Device',
          bluetoothDevice: event.bluetoothDevice,
          emission1Duration: Device.defaultEmissionDuration,
          emission2Duration: Device.defaultEmissionDuration,
          releaseInterval1: Device.defaultReleaseInterval,
          releaseInterval2: Device.defaultReleaseInterval,
          isPeriodicEmissionEnabled: false,
          isPeriodicEmissionEnabled2: false,
          isBleConnected: false,
          heartrateThreshold: Device.defaultHeartRateThreshold,
        );

        await _databaseService.createDevice(newDevice);
        final updatedDevices = [...currentState.devices, newDevice];
        emit(DevicesLoaded(devices: updatedDevices));

        if (event.bluetoothDevice != null) {
          add(ConnectToDevice(newDevice));
        }
      }
    } catch (e) {
      emit(DeviceError(message: 'Failed to add device: $e'));
    }
  }

  Future<void> _onRemoveDevice(RemoveDevice event, Emitter<DeviceState> emit) async {
    try {
      if (state is DevicesLoaded) {
        final currentState = state as DevicesLoaded;

        if (event.device.isConnected) {
          await _bleService.disconnectFromDevice();
        }

        await _databaseService.deleteDevice(event.device.id);

        final updatedDevices = currentState.devices
            .where((device) => device.id != event.device.id)
            .toList();

        emit(DevicesLoaded(devices: updatedDevices));
      }
    } catch (e) {
      emit(DeviceError(message: 'Failed to remove device: $e'));
    }
  }

  Future<void> _onConnectToDevice(ConnectToDevice event, Emitter<DeviceState> emit) async {
    if (event.device.bluetoothDevice == null) return;

    _lastConnectedDevice = event.device;
    _connectionRetries = 0;
    await _attemptConnection(event.device, emit);
  }

  Future<void> _attemptConnection(Device device, Emitter<DeviceState> emit) async {
    _connectionTimeoutTimer?.cancel();

    if (_connectionRetries >= maxRetries) {
      emit(DeviceError(message: 'Failed to connect after $maxRetries attempts'));
      return;
    }

    try {
      emit(DeviceConnectionInProgress());

      _connectionTimeoutTimer = Timer(connectionTimeout, () {
        if (state is DeviceConnectionInProgress) {
          _bleService.disconnectFromDevice();
          add(RetryConnection(device));
        }
      });

      await _bleService.connectToDevice(device.bluetoothDevice!);
      _connectionTimeoutTimer?.cancel();
      emit(DeviceConnected(device: device));

    } catch (e) {
      _connectionTimeoutTimer?.cancel();
      await _handleConnectionFailure(device, emit, e);
    }
  }

  Future<void> _handleConnectionFailure(Device device, Emitter<DeviceState> emit, dynamic error) async {
    _connectionRetries++;

    if (_connectionRetries < maxRetries) {
      emit(DeviceError(message: 'Connection attempt $_connectionRetries failed: $error'));
      await Future.delayed(retryDelay);
      add(RetryConnection(device));
    } else {
      emit(DeviceError(message: 'Failed to connect after $maxRetries attempts'));
      _startAutoReconnectTimer(device);
    }
  }

  void _handleDisconnection() {
    if (_lastConnectedDevice != null && state is! DeviceConnectionInProgress) {
      _startAutoReconnectTimer(_lastConnectedDevice!);
    }
  }

  void _handleConnectionError(dynamic error) {
    emit(DeviceError(message: 'Connection error: $error'));

    if (_lastConnectedDevice != null) {
      _connectionRetries++;
      if (_connectionRetries < maxRetries) {
        add(RetryConnection(_lastConnectedDevice!));
      } else {
        _startAutoReconnectTimer(_lastConnectedDevice!);
      }
    }
  }

  void _startAutoReconnectTimer(Device device) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(autoReconnectDelay, (timer) {
      if (!device.isConnected) {
        _connectionRetries = 0;
        add(ConnectToDevice(device));
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _onRetryConnection(RetryConnection event, Emitter<DeviceState> emit) async {
    await _attemptConnection(event.device, emit);
  }

  Future<void> _onDisconnectDevice(DisconnectDevice event, Emitter<DeviceState> emit) async {
    try {
      _reconnectTimer?.cancel();
      await _bleService.disconnectFromDevice();
      _lastConnectedDevice = null;
      emit(DeviceDisconnected(device: event.device));
    } catch (e) {
      emit(DeviceError(message: 'Failed to disconnect: $e'));
    }
  }

  Future<void> _onUpdateDevice(UpdateDevice event, Emitter<DeviceState> emit) async {
    try {
      if (state is DevicesLoaded) {
        final currentState = state as DevicesLoaded;
        await _databaseService.updateDevice(event.device);

        final updatedDevices = currentState.devices.map((device) {
          return device.id == event.device.id ? event.device : device;
        }).toList();

        emit(DevicesLoaded(devices: updatedDevices));
      }
    } catch (e) {
      emit(DeviceError(message: 'Failed to update device: $e'));
    }
  }

  @override
  Future<void> close() async {
    await _bleConnectionSubscription?.cancel();
    await _deviceStateSubscription?.cancel();
    _connectionTimeoutTimer?.cancel();
    _reconnectTimer?.cancel();
    _lastConnectedDevice = null;
    await super.close();
  }
}
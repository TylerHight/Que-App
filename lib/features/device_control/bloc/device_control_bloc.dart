// lib/features/device_control/bloc/device_control_bloc.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:que_app/core/models/device/device.dart';
import 'package:que_app/core/services/database_service.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import 'device_control_event.dart';
import 'device_control_state.dart';

class DeviceControlBloc extends Bloc<DeviceControlEvent, DeviceControlState> {
  final DatabaseService _databaseService;
  final BleService _bleService;
  StreamSubscription? _connectionSubscription;

  DeviceControlBloc({
    required DatabaseService databaseService,
    required BleService bleService,
  })  : _databaseService = databaseService,
        _bleService = bleService,
        super(DeviceControlInitial()) {
    on<LoadDevices>(_onLoadDevices);
    on<StartDeviceScan>(_onStartDeviceScan);
    on<StopDeviceScan>(_onStopDeviceScan);
    on<AddDevice>(_onAddDevice);
    on<RemoveDevice>(_onRemoveDevice);
    on<ConnectToDevice>(_onConnectToDevice);
    on<DisconnectDevice>(_onDisconnectDevice);
    on<UpdateDeviceConnection>(_onUpdateDeviceConnection);
    on<SendDeviceCommand>(_onSendDeviceCommand);

    _setupConnectionListener();
  }

  void _setupConnectionListener() {
    _connectionSubscription?.cancel();
    _connectionSubscription = _bleService.connectionStatusStream.listen(
          (isConnected) {
        if (state is DeviceControlLoaded) {
          final connectedDevice = _findConnectedDevice();

          if (connectedDevice != null) {
            add(UpdateDeviceConnection(
              device: connectedDevice,
              isConnected: isConnected,
            ));
          }
        }
      },
      onError: (error) {
        if (state is DeviceControlLoaded) {
          final currentState = state as DeviceControlLoaded;
          emit(currentState.copyWith(
            scanError: 'Connection error: $error',
          ));
        }
      },
    );
  }

  Device? _findConnectedDevice() {
    if (state is DeviceControlLoaded) {
      final currentState = state as DeviceControlLoaded;
      try {
        return currentState.devices.firstWhere(
              (device) => device.bluetoothDevice?.remoteId.toString() ==
              _bleService.connectedDevice?.remoteId.toString(),
        );
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Future<void> _onLoadDevices(
      LoadDevices event,
      Emitter<DeviceControlState> emit,
      ) async {
    emit(DeviceControlLoading());
    try {
      final devices = await _databaseService.getAllDevices();
      emit(DeviceControlLoaded(devices: devices));
    } catch (e) {
      emit(DeviceControlError('Failed to load devices: $e'));
    }
  }

  Future<void> _onStartDeviceScan(
      StartDeviceScan event,
      Emitter<DeviceControlState> emit,
      ) async {
    if (state is DeviceControlLoaded) {
      final currentState = state as DeviceControlLoaded;
      emit(currentState.copyWith(isScanning: true));

      try {
        await _bleService.startScan();
      } catch (e) {
        emit(currentState.copyWith(
          isScanning: false,
          scanError: 'Failed to start scan: $e',
        ));
      }
    }
  }

  Future<void> _onStopDeviceScan(
      StopDeviceScan event,
      Emitter<DeviceControlState> emit,
      ) async {
    if (state is DeviceControlLoaded) {
      final currentState = state as DeviceControlLoaded;
      try {
        await _bleService.stopScan();
        emit(currentState.copyWith(isScanning: false));
      } catch (e) {
        emit(currentState.copyWith(
          scanError: 'Failed to stop scan: $e',
        ));
      }
    }
  }

  Future<void> _onAddDevice(
      AddDevice event,
      Emitter<DeviceControlState> emit,
      ) async {
    if (state is DeviceControlLoaded) {
      final currentState = state as DeviceControlLoaded;
      try {
        final device = Device.create(
          name: event.name,
          bluetoothDevice: event.bluetoothDevice,
        );

        await _databaseService.createDevice(device);
        final List<Device> updatedDevices = List.from(currentState.devices)..add(device);
        emit(currentState.copyWith(devices: updatedDevices));

        if (event.bluetoothDevice != null) {
          add(ConnectToDevice(device));
        }
      } catch (e) {
        emit(DeviceControlError('Failed to add device: $e'));
      }
    }
  }

  Future<void> _onRemoveDevice(
      RemoveDevice event,
      Emitter<DeviceControlState> emit,
      ) async {
    if (state is DeviceControlLoaded) {
      final currentState = state as DeviceControlLoaded;
      try {
        await _databaseService.deleteDevice(event.device.id);

        if (event.device.isConnected) {
          await _bleService.disconnectFromDevice();
        }

        final List<Device> updatedDevices = currentState.devices
            .where((device) => device.id != event.device.id)
            .toList();

        emit(currentState.copyWith(devices: updatedDevices));
      } catch (e) {
        emit(DeviceControlError('Failed to remove device: $e'));
      }
    }
  }

  Future<void> _onConnectToDevice(
      ConnectToDevice event,
      Emitter<DeviceControlState> emit,
      ) async {
    if (event.device.bluetoothDevice == null) return;

    try {
      await _bleService.connectToDevice(event.device.bluetoothDevice!);

      if (state is DeviceControlLoaded) {
        add(UpdateDeviceConnection(device: event.device, isConnected: true));
      }
    } catch (e) {
      if (state is DeviceControlLoaded) {
        final currentState = state as DeviceControlLoaded;
        emit(currentState.copyWith(
          scanError: 'Failed to connect: $e',
        ));
      }
    }
  }

  Future<void> _onDisconnectDevice(
      DisconnectDevice event,
      Emitter<DeviceControlState> emit,
      ) async {
    try {
      await _bleService.disconnectFromDevice();

      if (state is DeviceControlLoaded) {
        add(UpdateDeviceConnection(device: event.device, isConnected: false));
      }
    } catch (e) {
      if (state is DeviceControlLoaded) {
        final currentState = state as DeviceControlLoaded;
        emit(currentState.copyWith(
          scanError: 'Failed to disconnect: $e',
        ));
      }
    }
  }

  Future<void> _onUpdateDeviceConnection(
      UpdateDeviceConnection event,
      Emitter<DeviceControlState> emit,
      ) async {
    if (state is DeviceControlLoaded) {
      final currentState = state as DeviceControlLoaded;
      try {
        final List<Device> updatedDevices = currentState.devices.map((device) {
          if (device.id == event.device.id) {
            final updatedDevice = device.updateConnectionStatus(event.isConnected);
            return updatedDevice;
          }
          return device;
        }).toList();

        emit(currentState.copyWith(devices: updatedDevices));

        // Update database
        await _databaseService.updateDevice(
          event.device.updateConnectionStatus(event.isConnected),
        );
      } catch (e) {
        emit(currentState.copyWith(
          scanError: 'Failed to update connection status: $e',
        ));
      }
    }
  }

  Future<void> _onSendDeviceCommand(
      SendDeviceCommand event,
      Emitter<DeviceControlState> emit,
      ) async {
    try {
      await _bleService.setLedColor(event.command);
    } catch (e) {
      if (state is DeviceControlLoaded) {
        final currentState = state as DeviceControlLoaded;
        emit(currentState.copyWith(
          scanError: 'Failed to send command: $e',
        ));
      }
    }
  }

  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    return super.close();
  }
}
// lib/core/models/device/device.dart
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../services/ble/ble_service.dart';
import 'device_state.dart';
import 'device_ble.dart';
import 'device_utils.dart';

class Device extends ChangeNotifier with EquatableMixin {
  final String id;
  final String deviceName;
  String connectedQueName;
  BluetoothDevice? bluetoothDevice;
  final BleService bleService;
  final DeviceState _state;
  late final DeviceBle _ble;

  static const Duration defaultEmissionDuration = Duration(seconds: 10);

  // Forward state getters
  Duration get emission1Duration => _state.emission1Duration;
  Duration get emission2Duration => _state.emission2Duration;
  Duration get releaseInterval1 => _state.releaseInterval1;
  Duration get releaseInterval2 => _state.releaseInterval2;
  bool get isPeriodicEmissionEnabled => _state.isPeriodicEmissionEnabled;
  bool get isPeriodicEmissionEnabled2 => _state.isPeriodicEmissionEnabled2;
  bool get isBleConnected => _state.isBleConnected;
  int get heartrateThreshold => _state.heartrateThreshold;
  Map<String, List<String>> get bluetoothServiceCharacteristics => _ble.serviceCharacteristics;
  bool get isConnected => isBleConnected;

  set isBleConnected(bool value) {
    _state.isBleConnected = value;
    notifyListeners();
  }

  Device._({
    required this.id,
    required this.deviceName,
    required this.connectedQueName,
    required this.bleService,
    required DeviceState state,
    required Map<String, List<String>> serviceCharacteristics,
    this.bluetoothDevice,
  }) : _state = state {
    _ble = DeviceBle(
      device: this,
      bleService: bleService,
      serviceCharacteristics: serviceCharacteristics,
    );
  }

  factory Device({
    String? id,
    required String deviceName,
    required String connectedQueName,
    BluetoothDevice? bluetoothDevice,
    Duration? emission1Duration,
    Duration? emission2Duration,
    Duration? releaseInterval1,
    Duration? releaseInterval2,
    bool? isBleConnected,
    bool? isPeriodicEmissionEnabled = false,
    bool? isPeriodicEmissionEnabled2 = false,
    Map<String, List<String>>? bluetoothServiceCharacteristics,
    int heartrateThreshold = 90,
    BleService? bleService,
  }) {
    final generatedId = id ?? DeviceUtils.generateRandomId();
    final service = bleService ?? BleService();

    final state = DeviceState(
      emission1Duration: emission1Duration ?? defaultEmissionDuration,
      emission2Duration: emission2Duration ?? defaultEmissionDuration,
      releaseInterval1: releaseInterval1 ?? const Duration(seconds: 5),
      releaseInterval2: releaseInterval2 ?? const Duration(seconds: 5),
      isBleConnected: isBleConnected ?? false,
      isPeriodicEmissionEnabled: isPeriodicEmissionEnabled ?? false,
      isPeriodicEmissionEnabled2: isPeriodicEmissionEnabled2 ?? false,
      heartrateThreshold: heartrateThreshold,
    );

    return Device._(
      id: generatedId,
      deviceName: deviceName,
      connectedQueName: connectedQueName,
      bluetoothDevice: bluetoothDevice,
      bleService: service,
      state: state,
      serviceCharacteristics: bluetoothServiceCharacteristics ?? {},
    );
  }

  // Forward state updates
  void updateEmission1Duration(Duration duration) {
    _state.updateEmission1Duration(duration);
    notifyListeners();
  }

  void updateEmission2Duration(Duration duration) {
    _state.updateEmission2Duration(duration);
    notifyListeners();
  }

  void updateReleaseInterval1(Duration interval) {
    _state.updateReleaseInterval1(interval);
    notifyListeners();
  }

  void updateReleaseInterval2(Duration interval) {
    _state.updateReleaseInterval2(interval);
    notifyListeners();
  }

  void updatePeriodicEmission1(bool enabled) {
    _state.updatePeriodicEmission1(enabled);
    notifyListeners();
  }

  void updatePeriodicEmission2(bool enabled) {
    _state.updatePeriodicEmission2(enabled);
    notifyListeners();
  }

  void updateHeartRateThreshold(int threshold) {
    _state.updateHeartRateThreshold(threshold);
    notifyListeners();
  }

  // Forward BLE operations
  String? getCharacteristicUUID(String serviceUUID) => _ble.getCharacteristicUUID(serviceUUID);
  Future<void> connectToDevice() => _ble.connect();
  Stream<bool> get bleConnectionStatusStream => _ble.connectionStatusStream;

  Device copyWith({
    String? id,
    String? deviceName,
    String? connectedQueName,
    BluetoothDevice? bluetoothDevice,
    Duration? emission1Duration,
    Duration? emission2Duration,
    Duration? releaseInterval1,
    Duration? releaseInterval2,
    bool? isBleConnected,
    bool? isPeriodicEmissionEnabled,
    bool? isPeriodicEmissionEnabled2,
    Map<String, List<String>>? bluetoothServiceCharacteristics,
    int? heartrateThreshold,
    BleService? bleService,
  }) {
    return Device(
      id: id ?? this.id,
      deviceName: deviceName ?? this.deviceName,
      connectedQueName: connectedQueName ?? this.connectedQueName,
      bluetoothDevice: bluetoothDevice ?? this.bluetoothDevice,
      emission1Duration: emission1Duration ?? this.emission1Duration,
      emission2Duration: emission2Duration ?? this.emission2Duration,
      releaseInterval1: releaseInterval1 ?? this.releaseInterval1,
      releaseInterval2: releaseInterval2 ?? this.releaseInterval2,
      isBleConnected: isBleConnected ?? this.isBleConnected,
      isPeriodicEmissionEnabled: isPeriodicEmissionEnabled ?? this.isPeriodicEmissionEnabled,
      isPeriodicEmissionEnabled2: isPeriodicEmissionEnabled2 ?? this.isPeriodicEmissionEnabled2,
      bluetoothServiceCharacteristics: bluetoothServiceCharacteristics ?? this.bluetoothServiceCharacteristics,
      heartrateThreshold: heartrateThreshold ?? this.heartrateThreshold,
      bleService: bleService ?? this.bleService,
    );
  }

  Future<void> delete() => _ble.deleteDevice();

  @override
  List<Object?> get props => [
    id,
    deviceName,
    connectedQueName,
    bluetoothDevice,
    _state,
    _ble,
  ];

  @override
  void dispose() {
    _ble.dispose();
    super.dispose();
  }
}
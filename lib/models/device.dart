import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:que_app/services/ble_service.dart';

class Device extends ChangeNotifier {
  final String id;
  final String deviceName;
  String connectedQueName;
  static const Duration defaultEmissionDuration = Duration(seconds: 10);
  Duration _emission1Duration;
  Duration _emission2Duration;
  Duration _releaseInterval1;
  Duration _releaseInterval2;
  bool _isPeriodicEmissionEnabled;
  bool _isPeriodicEmissionEnabled2;
  bool _isBleConnected;
  int _heartrateThreshold;
  final BleService bleService;

  final Map<String, List<String>> bluetoothServiceCharacteristics;

  // Getters and setters for private fields
  Duration get emission1Duration => _emission1Duration;
  set emission1Duration(Duration value) {
    _emission1Duration = value;
    notifyListeners();
  }

  Duration get emission2Duration => _emission2Duration;
  set emission2Duration(Duration value) {
    _emission2Duration = value;
    notifyListeners();
  }

  Duration get releaseInterval1 => _releaseInterval1;
  set releaseInterval1(Duration value) {
    _releaseInterval1 = value;
    notifyListeners();
  }

  Duration get releaseInterval2 => _releaseInterval2;
  set releaseInterval2(Duration value) {
    _releaseInterval2 = value;
    notifyListeners();
  }

  bool get isPeriodicEmissionEnabled => _isPeriodicEmissionEnabled;
  set isPeriodicEmissionEnabled(bool value) {
    _isPeriodicEmissionEnabled = value;
    notifyListeners();
  }

  bool get isPeriodicEmissionEnabled2 => _isPeriodicEmissionEnabled2;
  set isPeriodicEmissionEnabled2(bool value) {
    _isPeriodicEmissionEnabled2 = value;
    notifyListeners();
  }

  int get heartrateThreshold => _heartrateThreshold;
  set heartrateThreshold(int value) {
    _heartrateThreshold = value;
    notifyListeners();
  }

  bool get isBleConnected => _isBleConnected;
  set isBleConnected(bool value) {
    _isBleConnected = value;
    notifyListeners();
  }

  Device._({
    required this.id,
    required this.deviceName,
    required this.connectedQueName,
    required Duration emission1Duration,
    required Duration emission2Duration,
    required Duration releaseInterval1,
    required Duration releaseInterval2,
    required bool isPeriodicEmissionEnabled,
    required bool isPeriodicEmissionEnabled2,
    required bool isBleConnected,
    required Map<String, List<String>> bluetoothServiceCharacteristics,
    required int heartrateThreshold,
    required this.bleService,
  })  : _emission1Duration = emission1Duration,
        _emission2Duration = emission2Duration,
        _releaseInterval1 = releaseInterval1,
        _releaseInterval2 = releaseInterval2,
        _isPeriodicEmissionEnabled = isPeriodicEmissionEnabled,
        _isPeriodicEmissionEnabled2 = isPeriodicEmissionEnabled2,
        _isBleConnected = isBleConnected,
        _heartrateThreshold = heartrateThreshold,
        bluetoothServiceCharacteristics = bluetoothServiceCharacteristics,
        super();

  factory Device({
    String? id,
    required String deviceName,
    required String connectedQueName,
    Duration? emission1Duration,
    Duration? emission2Duration,
    Duration? releaseInterval1,
    Duration? releaseInterval2,
    bool? isBleConnected,
    bool? isPeriodicEmissionEnabled = false,
    bool? isPeriodicEmissionEnabled2 = false,
    Map<String, List<String>>? bluetoothServiceCharacteristics,
    int heartrateThreshold = 90,
  }) {
    final generatedId = id ?? _generateRandomId();
    final bleService = BleService();
    return Device._(
      id: generatedId,
      deviceName: deviceName,
      connectedQueName: connectedQueName,
      emission1Duration: emission1Duration ?? defaultEmissionDuration,
      emission2Duration: emission2Duration ?? defaultEmissionDuration,
      releaseInterval1: releaseInterval1 ?? Duration(seconds: 5),
      releaseInterval2: releaseInterval2 ?? Duration(seconds: 5),
      isBleConnected: isBleConnected ?? false,
      isPeriodicEmissionEnabled: isPeriodicEmissionEnabled ?? false,
      isPeriodicEmissionEnabled2: isPeriodicEmissionEnabled2 ?? false,
      bluetoothServiceCharacteristics: bluetoothServiceCharacteristics ?? {},
      heartrateThreshold: heartrateThreshold,
      bleService: bleService,
    );
  }

  static String _generateRandomId() {
    const chars = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    const idLength = 10;
    return String.fromCharCodes(
      Iterable.generate(
        idLength,
            (_) => chars.codeUnitAt(random.nextInt(chars.length)),
      ),
    );
  }

  String? getCharacteristicUUID(String serviceUUID) {
    final characteristics = bluetoothServiceCharacteristics[serviceUUID];
    if (characteristics != null && characteristics.isNotEmpty) {
      return characteristics.first;
    } else {
      print("No characteristic UUIDs found for service UUID: $serviceUUID");
      return null;
    }
  }

  Device copy({
    String? id,
    String? deviceName,
    String? connectedQueName,
    Duration? emission1Duration,
    Duration? emission2Duration,
    Duration? releaseInterval1,
    Duration? releaseInterval2,
    bool? isBleConnected,
    bool? isPeriodicEmissionEnabled,
    bool? isPeriodicEmissionEnabled2,
    Map<String, List<String>>? bluetoothServiceCharacteristics,
    int? heartrateThreshold,
  }) =>
      Device(
        id: id ?? this.id,
        deviceName: deviceName ?? this.deviceName,
        connectedQueName: connectedQueName ?? this.connectedQueName,
        emission1Duration: emission1Duration ?? this.emission1Duration,
        emission2Duration: emission2Duration ?? this.emission2Duration,
        releaseInterval1: releaseInterval1 ?? this.releaseInterval1,
        releaseInterval2: releaseInterval2 ?? this.releaseInterval2,
        isBleConnected: isBleConnected ?? this.isBleConnected,
        isPeriodicEmissionEnabled: isPeriodicEmissionEnabled ?? this.isPeriodicEmissionEnabled,
        isPeriodicEmissionEnabled2: isPeriodicEmissionEnabled2 ?? this.isPeriodicEmissionEnabled2,
        bluetoothServiceCharacteristics: bluetoothServiceCharacteristics ?? this.bluetoothServiceCharacteristics,
        heartrateThreshold: heartrateThreshold ?? this.heartrateThreshold,
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'deviceName': deviceName,
    'connectedQueueName': connectedQueName,
    'emission1Duration': emission1Duration.inSeconds,
    'emission2Duration': emission2Duration.inSeconds,
    'releaseInterval1': releaseInterval1.inSeconds,
    'releaseInterval2': releaseInterval2.inSeconds,
    'isBleConnected': isBleConnected,
    'isPeriodicEmissionEnabled': isPeriodicEmissionEnabled,
    'isPeriodicEmissionEnabled2': isPeriodicEmissionEnabled2,
    'heartrateThreshold': heartrateThreshold,
    'bluetoothServiceCharacteristics': bluetoothServiceCharacteristics,
  };

  Future<void> updateBleConnectionStatus(bool isConnected) async {
    isBleConnected = isConnected;
    notifyListeners();
  }

  Future<void> delete() async {
    try {
      // Add any specific cleanup logic for the device here if necessary
      if (bleService.connectedDevice != null) {
        await bleService.disconnectFromDevice(bleService.connectedDevice!);  // Pass the BluetoothDevice instance
      }
      print('Device deleted: $deviceName');
    } catch (e) {
      print('Error deleting device: $e');
      throw Exception('Failed to delete device');
    }
  }

  Stream<bool> get bleConnectionStatusStream => bleService.connectionStatusStream;

  @override
  void dispose() {
    bleService.dispose();
    super.dispose();
  }
}

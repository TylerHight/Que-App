// lib/core/models/device/device_ble.dart
import '../../services/ble_service.dart';
import 'device.dart';

class DeviceBle {
  final Device device;
  final BleService bleService;
  final Map<String, List<String>> serviceCharacteristics;

  DeviceBle({
    required this.device,
    required this.bleService,
    required this.serviceCharacteristics,
  });

  String? getCharacteristicUUID(String serviceUUID) {
    final characteristics = serviceCharacteristics[serviceUUID];
    return characteristics?.firstOrNull;
  }

  Future<void> connect() async {
    if (device.bluetoothDevice != null) {
      try {
        await bleService.connectToDevice(device.bluetoothDevice!);
        device.isBleConnected = true;
      } catch (e) {
        device.isBleConnected = false;
        rethrow;
      }
    }
  }

  Future<void> deleteDevice() async {
    try {
      if (device.bluetoothDevice != null) {
        await bleService.disconnectFromDevice();
      }
      device.notifyListeners();
    } catch (e) {
      print('Error deleting device: $e');
      rethrow;
    }
  }

  Stream<bool> get connectionStatusStream => bleService.connectionStatusStream;

  void dispose() {
    bleService.dispose();
  }
}

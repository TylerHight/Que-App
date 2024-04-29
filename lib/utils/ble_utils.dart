import 'package:flutter_blue/flutter_blue.dart';

class BleUtils {
  FlutterBlue flutterBlue = FlutterBlue.instance;

  Future<List<BluetoothDevice>> startScan() async {
    List<BluetoothDevice> devices = [];

    try {
      await flutterBlue.startScan(timeout: const Duration(seconds: 4));
      flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          if (!devices.contains(result.device)) {
            devices.add(result.device);
          }
        }
      });
    } catch (e) {
      throw Exception("Error starting BLE scan: $e");
    }

    return devices;
  }
}

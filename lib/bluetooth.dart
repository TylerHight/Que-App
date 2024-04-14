import 'package:flutter_blue/flutter_blue.dart';

class BLEController {
  static late BluetoothDevice _device;
  static late BluetoothCharacteristic _fan1Characteristic;
  static bool _isConnected = false;

  static Future<void> connectToDevice() async {
    final FlutterBlue flutterBlue = FlutterBlue.instance;

    // Start scanning for devices
    flutterBlue.scan(timeout: Duration(seconds: 4)).listen((scanResult) {
      // Connect to the device when found
      _device = scanResult.device;
      _device.connect().then((value) {
        // Discover services and characteristics
        _device.discoverServices().then((services) {
          for (BluetoothService service in services) {
            service.characteristics.forEach((characteristic) {
              // Check for characteristics you're interested in
              if (characteristic.uuid.toString() == '19B10001-E8F2-537E-4F6C-D104768A1214') {
                _fan1Characteristic = characteristic;
                _isConnected = true;
              }
              // Add more if needed for other characteristics
            });
          }
        });
      });
    });
  }

  static Future<void> disconnect() async {
    if (_isConnected) {
      await _device.disconnect();
      _isConnected = false;
    }
  }

  static Future<void> turnOnFan1() async {
    if (_isConnected) {
      // Send command to turn on fan1
      await _fan1Characteristic.write([1]); // Assuming 1 means turn on
    }
  }

// Add more functions for other commands as needed

}

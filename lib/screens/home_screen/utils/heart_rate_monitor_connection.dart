// heart_rate_monitor_connection.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:provider/provider.dart';
import '../../../device_data.dart';

class HeartRateMonitorConnection {
  static Future<void> selectBluetoothDevice(BuildContext context) async {
    FlutterBlue flutterBlue = FlutterBlue.instance;

    // Check if Bluetooth is available on the device
    bool isAvailable = await flutterBlue.isAvailable;

    if (!isAvailable) {
      // Handle the case where Bluetooth is not available
      // You might want to show a message to the user
      return;
    }

    // Scan for Bluetooth devices
    List<ScanResult> scanResults = [];
    var scanSubscription = flutterBlue.scan().listen((scanResult) {
      scanResults.add(scanResult);
    });

    // Display a dialog with a list of available Bluetooth devices
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Bluetooth Device'),
          content: Column(
            children: [
              for (var result in scanResults)
                ListTile(
                  title: Text(result.device.name ?? 'Unknown Device'),
                  onTap: () {
                    // Handle the selected Bluetooth device
                    print('Selected Bluetooth Device: ${result.device.name}');
                    // Update the UI with the connected device name
                    _updateConnectedDeviceName(context, result.device.name);
                    Navigator.of(context).pop();
                  },
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Stop scanning when the user closes the dialog
                scanSubscription.cancel();
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    // Stop scanning when the dialog is closed
    scanSubscription.cancel();
  }

  // New method to update the connected device name
  static void _updateConnectedDeviceName(BuildContext context, String deviceName) {
    Provider.of<DeviceData>(context, listen: false).setConnectedHRDeviceName(deviceName);
  }
}

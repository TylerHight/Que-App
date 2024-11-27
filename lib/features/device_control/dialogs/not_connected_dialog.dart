// lib/features/device_control/dialogs/not_connected_dialog.dart
import 'package:flutter/material.dart';
import 'package:que_app/core/models/device/device.dart';
import 'package:que_app/core/services/ble/ble_service.dart';

Future<void> showNotConnectedDialog({
  required BuildContext context,
  required Device device,
  required BleService bleService,
  VoidCallback? onConnected,
}) async {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Not connected'),
        content: const Text('Would you like to try connecting?'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text('Connect'),
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                if (device.bluetoothDevice != null) {
                  await bleService.connectToDevice(device.bluetoothDevice!);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Connected successfully'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                  onConnected?.call();
                } else {
                  throw Exception('No Bluetooth device associated');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Connection failed: $e'),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
          ),
        ],
      );
    },
  );
}
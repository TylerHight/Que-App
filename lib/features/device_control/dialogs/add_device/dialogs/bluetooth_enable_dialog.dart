// lib/features/device_control/dialogs/add_device/dialogs/bluetooth_enable_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

enum BluetoothEnableResult {
  enabled,
  cancelled,
}

Future<BluetoothEnableResult> showBluetoothEnableDialog(BuildContext context) async {
  final result = await showDialog<BluetoothEnableResult>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Bluetooth Required'),
        content: const Text('Please enable Bluetooth to scan for devices.'),
        actions: <Widget>[
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop(BluetoothEnableResult.cancelled);
            },
          ),
          TextButton(
            child: const Text('Enable'),
            onPressed: () async {
              try {
                await FlutterBluePlus.turnOn();
                if (context.mounted) {
                  Navigator.of(context).pop(BluetoothEnableResult.enabled);
                }
              } catch (e) {
                if (context.mounted) {
                  Navigator.of(context).pop(BluetoothEnableResult.cancelled);
                }
              }
            },
          ),
        ],
      );
    },
  );

  return result ?? BluetoothEnableResult.cancelled;
}
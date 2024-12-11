// lib/features/device_settings/dialogs/delete_device_dialog.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/core/models/device_list.dart';

class DeleteDeviceDialog extends StatelessWidget {
  final Device device;

  const DeleteDeviceDialog({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete Device'),
      content: Text('Are you sure you want to delete the device "${device.deviceName}"?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.blue),
          ),
        ),
        TextButton(
          onPressed: () async {
            try {
              // Get deviceList provider
              final deviceList = Provider.of<DeviceList>(context, listen: false);

              // Remove device using DeviceList's removeDevice method
              await deviceList.removeDevice(device);

              if (context.mounted) {
                // Pop dialog first
                Navigator.of(context).pop();

                // Navigate back to device list screen using Navigator.of with rootNavigator
                Navigator.of(context, rootNavigator: true).pop();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${device.deviceName} deleted successfully'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                // Show error if deletion fails
                Navigator.of(context).pop(); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Failed to delete device: $e'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
          child: const Text(
            'Delete',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
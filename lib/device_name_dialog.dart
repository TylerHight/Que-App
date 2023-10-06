// device_name_dialog.dart

import 'package:flutter/material.dart';

class DeviceNameDialog extends StatefulWidget {
  final Function(String) onDeviceNameEntered;

  DeviceNameDialog({required this.onDeviceNameEntered});

  @override
  _DeviceNameDialogState createState() => _DeviceNameDialogState();
}

class _DeviceNameDialogState extends State<DeviceNameDialog> {
  final TextEditingController _deviceNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Device Name'),
      content: TextField(
        controller: _deviceNameController,
        decoration: InputDecoration(labelText: 'Device Name'),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            String deviceName = _deviceNameController.text.trim();
            if (deviceName.isNotEmpty) {
              widget.onDeviceNameEntered(deviceName);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }
}

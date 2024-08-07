import 'package:flutter/material.dart';
import 'package:que_app/models/device.dart';

class DeleteDeviceDialog extends StatelessWidget {
  final Device device;

  const DeleteDeviceDialog({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Delete Device'),
      content: Text('Are you sure you want to delete the device "${device.deviceName}"?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            print('Cancel button pressed');
            Navigator.of(context).pop(false);
          },
          child: Text(
            'Cancel',
            style: TextStyle(color: Colors.blue), // Customize cancel button color
          ),
        ),
        TextButton(
          onPressed: () async {
            print('delete_device_dialog.dart: Delete button pressed');
            await device.delete();
            print('delete_device_dialog.dart: Device deleted');
            Navigator.of(context).pop(true);
          },
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.red), // Make delete button text red
          ),
        ),
      ],
    );
  }
}

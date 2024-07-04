import 'package:flutter/material.dart';

class DeleteDeviceDialog extends StatelessWidget {
  final String deviceName;
  final VoidCallback onDelete; // Callback function for deletion confirmation

  const DeleteDeviceDialog({
    Key? key,
    required this.deviceName,
    required this.onDelete, // Accept the onDelete callback
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Delete Device',
        style: TextStyle(color: Colors.red), // Set the text color to red
      ),
      content: Text('Are you sure you want to delete $deviceName?'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the dialog
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: onDelete, // Call the onDelete callback
          child: Text(
            'Delete',
            style: TextStyle(color: Colors.red), // Set the text color to red
          ),
        ),
      ],
    );
  }
}

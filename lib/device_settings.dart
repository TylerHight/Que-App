import 'package:flutter/material.dart';

class DeviceSettingsScreen extends StatelessWidget {
  final String deviceName;
  final VoidCallback onDelete; // Add onDelete callback

  DeviceSettingsScreen({
    required this.deviceName,
    required this.onDelete, // Add onDelete callback
  });

  void _deleteDevice(BuildContext context) {
    // Display a confirmation dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete Device'),
          content: Text('Delete device $deviceName?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                onDelete(); // Call the onDelete callback
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context).pop(); // Close the settings screen
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Settings'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red), // Red delete icon
            onPressed: () {
              _deleteDevice(context); // Call the _deleteDevice function
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Settings content goes here'),
      ),
    );
  }
}

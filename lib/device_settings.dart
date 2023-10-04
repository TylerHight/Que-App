import 'package:flutter/material.dart';

class DeviceSettingsScreen extends StatelessWidget {
  final VoidCallback onDelete;

  DeviceSettingsScreen({required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Settings content goes here'),
            ElevatedButton(
              onPressed: onDelete,
              child: Text('Delete Device'),
            ),
          ],
        ),
      ),
    );
  }
}

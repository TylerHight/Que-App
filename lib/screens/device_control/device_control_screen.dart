import 'package:flutter/material.dart';
import 'add_device_dialog.dart'; // Import the dialog file
import 'device_remote.dart'; // Import the DeviceRemote widget

class DeviceControlScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Device Control',
          style: TextStyle(color: Colors.white), // Set the text color to white
        ),
        backgroundColor: Colors.blue, // Set the background color to blue
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Show the dialog when the add button is tapped
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  // Return the dialog widget
                  return AddDeviceDialog();
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        children: <Widget>[
          // Display three instances of DeviceRemote
          DeviceRemote(
            title: 'Device 1',
            onButton1Pressed: () {
              // Handle button 1 pressed
            },
            onButton2Pressed: () {
              // Handle button 2 pressed
            },
            onButton3Pressed: () {
              // Handle button 3 pressed
            },
            onButton4Pressed: () {
              // Handle button 4 pressed
            },
            onMainButton1Pressed: () {
              // Handle main button 1 pressed
            },
            onMainButton2Pressed: () {
              // Handle main button 2 pressed
            },
          ),
          DeviceRemote(
            title: 'Device 2',
            // Add onPressed handlers as needed
          ),
          DeviceRemote(
            title: 'Device 3',
            // Add onPressed handlers as needed
          ),
          // Add more DeviceRemote widgets as needed
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'add_device_dialog.dart'; // Import the dialog file

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
      body: Center(
        child: Text(
          'Device Control Screen',
        ),
      ),
    );
  }
}

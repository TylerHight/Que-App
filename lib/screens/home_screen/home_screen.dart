// home_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Add this import statement
import 'device_data.dart'; // Import the DeviceData class
import 'device_remote.dart';
import 'device_settings_screen.dart';
import 'device_name_dialog.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final deviceData = Provider.of<DeviceData>(context);
    final deviceTitles = deviceData.deviceTitles;

    void addDevice(BuildContext context) {
      showDialog(
        context: context,
        builder: (context) => DeviceNameDialog(
          onDeviceNameEntered: (deviceName) {
            deviceData.addDeviceTitle(deviceName);
          },
        ),
      );
    }

    void deleteDevice(int index) {
      deviceData.deleteDeviceTitle(index);
    }

    void navigateToDeviceSettings(BuildContext context, int index) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DeviceSettingsScreen(
            onDelete: () {
              deleteDevice(index);
              Navigator.pop(context); // Close the settings screen
            },
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Devices',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 4.0,
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.add,
              color: Colors.white,
            ),
            onPressed: () {
              addDevice(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: deviceTitles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.all(2.0),
            child: DeviceRemote(
              title: deviceTitles[index],
              onTap: () {
                navigateToDeviceSettings(context, index);
              },
            ),
          );
        },
      ),
    );
  }
}

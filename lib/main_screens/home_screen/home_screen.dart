// home_screen.dart

import 'package:flutter/material.dart';
import 'device_remote.dart';
import 'device_settings.dart';
import 'device_name_dialog.dart'; // Import the new dialog file

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> deviceTitles = List.generate(3, (index) => 'Device $index');

  void addDevice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => DeviceNameDialog(
        onDeviceNameEntered: (deviceName) {
          setState(() {
            deviceTitles.add(deviceName);
          });
        },
      ),
    );
  }

  void deleteDevice(int index) {
    setState(() {
      deviceTitles.removeAt(index);
    });
  }

  void navigateToDeviceSettings(int index) {
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

  @override
  Widget build(BuildContext context) {
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
                navigateToDeviceSettings(index);
              },
            ),
          );
        },
      ),
    );
  }
}
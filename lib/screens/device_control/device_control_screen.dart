/// device_control_screen.dart

import 'package:flutter/material.dart';
import 'add_device_dialog.dart';
import 'device_remote.dart';
import 'package:que_app/app_data.dart';
import 'package:que_app/models/device.dart';

class DeviceControlScreen extends StatefulWidget {
  @override
  _DeviceControlScreenState createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Que Control',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () async {
              final result = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AddDeviceDialog(
                    onDeviceAdded: (Device newDevice) {
                      // Update the device list if a new device was added
                      setState(() {
                        devicesList.add(newDevice);
                      });
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: devicesList.length,
        itemBuilder: (context, index) {
          final device = devicesList[index];
          return Container(
            margin: const EdgeInsets.only(top: 5.0), // Adjust the value as needed
            child: DeviceRemote(
              deviceName: device.deviceName,
              connectedQueName: device.connectedQueName,
              emission1Duration: device.emission1Duration,
              emission2Duration: device.emission2Duration,
              // Add handlers as needed
            ),
          );
        },
      ),
    );
  }
}

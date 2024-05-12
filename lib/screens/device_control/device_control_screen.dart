import 'package:flutter/material.dart';
import '../../models/device_list.dart';
import 'add_device_dialog.dart';
import 'device_remote.dart';
import 'package:que_app/models/device.dart';
import 'package:que_app/services/ble_service.dart'; // Import the BleService class
import 'package:provider/provider.dart'; // Import the Provider package

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
                      Provider.of<DeviceList>(context, listen: false).add(newDevice);
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: Provider.of<DeviceList>(context).devices.length,
        itemBuilder: (context, index) {
          final device = Provider.of<DeviceList>(context).devices[index];
          return Container(
            margin: const EdgeInsets.only(top: 5.0), // Adjust the value as needed
            child: DeviceRemote(
              device: device,
              bleService: BleService(), // Instantiate your BleService here if needed
              // Add handlers as needed
            ),
          );
        },
      ),
    );
  }
}
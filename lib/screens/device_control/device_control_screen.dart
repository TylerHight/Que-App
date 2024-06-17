import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/models/device_list.dart';
import 'device_remote.dart';
import 'package:que_app/models/device.dart';
import 'package:que_app/services/ble_service.dart';
import 'package:que_app/screens/device_control/add_device_dialog.dart';

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
          'Control',
          style: TextStyle(
            color: Colors.black, // Set title text color to black
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Colors.white, // Set the AppBar background color to white
        iconTheme: IconThemeData(color: Colors.black), // Set the color of icons in AppBar
        elevation: 0.0, // Remove the shadow/depth of the AppBar
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 14.0), // Add padding to the right
            child: Container(
              width: 35.0, // Slightly reduce the size of the circle
              height: 35.0,
              decoration: BoxDecoration(
                color: Colors.blue, // Blue background
                shape: BoxShape.circle, // Circle shape
              ),
              child: Center( // Center the child within the container
                child: IconButton(
                  padding: EdgeInsets.zero, // Remove default padding from IconButton
                  icon: Icon(Icons.add, color: Colors.white), // White "add" icon
                  onPressed: () async {
                    final result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddDeviceDialog(
                          onDeviceAdded: (Device newDevice) {
                            Provider.of<DeviceList>(context, listen: false).add(newDevice);
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<DeviceList>(
        builder: (context, deviceList, _) {
          if (deviceList.devices.isEmpty) {
            return Center(
              child: Text(
                'No devices yet. Tap the "+" button to add a device.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
              ),
            );
          } else {
            return Container(
              color: Colors.white, // Ensure ListView background color is white
              child: ListView.builder(
                itemCount: deviceList.devices.length,
                itemBuilder: (context, index) {
                  final device = deviceList.devices[index];
                  return Container(
                    margin: const EdgeInsets.only(top: 5.0),
                    child: ChangeNotifierProvider.value(
                      value: device,
                      child: DeviceRemote(
                        device: device,
                        bleService: BleService(),
                      ),
                    ),
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}

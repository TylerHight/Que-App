import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/models/device_list.dart';
import '../../models/device.dart';
import 'add_device_dialog.dart';
import 'device_remote.dart';
import 'package:que_app/services/ble_service.dart';

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
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0.0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Container(
              width: 35.0,
              height: 35.0,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: Icon(Icons.add, color: Colors.white),
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
              color: Colors.white,
              child: ListView.builder(
                itemCount: deviceList.devices.length,
                itemBuilder: (context, index) {
                  final device = deviceList.devices[index];
                  final bleService = BleService(); // Create a new BleService instance for each device

                  return FutureBuilder<bool>(
                    future: bleService.isConnected(),
                    builder: (context, snapshot) {
                      final isConnected = snapshot.data ?? false;
                      print("Device: ${device.deviceName}, isConnected: $isConnected");

                      return GestureDetector(
                        onTap: () {
                          if (!isConnected) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Not connected'),
                                  content: Text('The device is not connected.'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('OK'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            // Handle the onTap when the device is connected, if needed
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 5.0),
                          child: ChangeNotifierProvider.value(
                            value: device,
                            child: DeviceRemote(
                              device: device,
                              bleService: bleService,
                            ),
                          ),
                        ),
                      );
                    },
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

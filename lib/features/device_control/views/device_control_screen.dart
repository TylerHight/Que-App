// lib/screens/device_control/device_control_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/core/models/device_list.dart';
import '../../../core/models/device/index.dart';
import '../dialogs/add_device_dialog.dart';
import '../dialogs/not_connected_dialog.dart';
import '../widgets/device_remote_card.dart';
import 'package:que_app/core/services/ble/ble_service.dart';

class DeviceControlScreen extends StatefulWidget {
  const DeviceControlScreen({super.key});

  @override
  _DeviceControlScreenState createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> {
  // Single instance of BleService
  final BleService _bleService = BleService();

  @override
  void dispose() {
    _bleService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Control',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w400,
          ),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0.0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 14.0),
            child: Container(
              width: 35.0,
              height: 35.0,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.add, color: Colors.white),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AddDeviceDialog(
                          onDeviceAdded: (Device newDevice) {
                            Provider.of<DeviceList>(context, listen: false).add(newDevice);
                          },
                          bleService: _bleService, // Pass the BleService instance
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
            return const Center(
              child: Text(
                'No devices yet. Tap the "+" button to add a device.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Container(
            color: Colors.white,
            child: ListView.builder(
              itemCount: deviceList.devices.length,
              itemBuilder: (context, index) {
                final device = deviceList.devices[index];

                return StreamBuilder<bool>(
                  stream: _bleService.connectionStatusStream,
                  initialData: false,
                  builder: (context, snapshot) {
                    final isConnected = snapshot.data ?? false;

                    return GestureDetector(
                      onTap: () async {
                        if (!isConnected) {
                          await showNotConnectedDialog(
                            context: context,
                            device: device,
                            bleService: _bleService,
                          );
                        }
                      },
                      child: Container(
                        margin: const EdgeInsets.only(top: 5.0),
                        child: ChangeNotifierProvider.value(
                          value: device,
                          child: DeviceRemote(
                            device: device,
                            bleService: _bleService,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
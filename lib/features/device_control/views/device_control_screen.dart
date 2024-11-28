// lib/features/device_control/views/device_control_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:que_app/core/models/device_list.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/features/device_control/dialogs/add_device/add_device_dialog.dart';
import 'package:que_app/features/device_control/dialogs/not_connected_dialog.dart';
import 'package:que_app/features/device_control/widgets/device_remote_card.dart';
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

  Future<void> _showAddDeviceDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddDeviceDialog(
          onDeviceAdded: (Device newDevice) {
            // No need to add device here as it's handled in the dialog
            // through the Provider
          },
          bleService: _bleService,
        );
      },
    );
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
                  onPressed: _showAddDeviceDialog,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<DeviceList>(
        builder: (context, deviceList, _) {
          if (deviceList.devices.isEmpty) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.device_unknown,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No devices yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the + button to add a device.',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                        color: Colors.black54,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }

          return Container(
            color: Colors.white,
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8.0, bottom: 16.0),
              itemCount: deviceList.devices.length,
              itemBuilder: (context, index) {
                final device = deviceList.devices[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: StreamBuilder<bool>(
                    stream: device.bleService.connectionStatusStream,
                    initialData: false,
                    builder: (context, snapshot) {
                      final isConnected = snapshot.data ?? false;

                      return GestureDetector(
                        onTap: () async {
                          if (!isConnected && device.bluetoothDevice != null) {
                            await showNotConnectedDialog(
                              context: context,
                              device: device,
                              bleService: _bleService,
                            );
                          }
                        },
                        child: ChangeNotifierProvider.value(
                          value: device,
                          child: DeviceRemote(
                            device: device,
                            bleService: _bleService,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
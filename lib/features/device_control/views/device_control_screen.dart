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
          onDeviceAdded: (Device newDevice) {},
          bleService: _bleService,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Devices',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Material(
              color: Colors.blue[600],
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: _showAddDeviceDialog,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const Row(
                    children: [
                      Icon(Icons.add, color: Colors.white, size: 20),
                      SizedBox(width: 4),
                      Text(
                        'Add Device',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.devices_other,
                      size: 48,
                      color: Colors.blue[400],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'No devices added yet',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap the "Add Device" button above to connect your first device.',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: deviceList.devices.length,
            itemBuilder: (context, index) {
              final device = deviceList.devices[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
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
          );
        },
      ),
    );
  }
}
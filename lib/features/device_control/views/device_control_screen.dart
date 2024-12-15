// lib/features/device_control/views/device_control_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:que_app/core/models/device/device.dart';
import 'package:que_app/features/device_control/bloc/device_control_bloc.dart';
import 'package:que_app/features/device_control/bloc/device_control_event.dart';
import 'package:que_app/features/device_control/bloc/device_control_state.dart';
import 'package:que_app/features/device_control/dialogs/add_device/add_device_dialog.dart';
import 'package:que_app/features/device_control/dialogs/not_connected_dialog.dart';
import 'package:que_app/features/device_control/widgets/device_remote.dart';
import 'package:que_app/core/services/ble/ble_service.dart';

class DeviceControlScreen extends StatefulWidget {
  const DeviceControlScreen({super.key});

  @override
  _DeviceControlScreenState createState() => _DeviceControlScreenState();
}

class _DeviceControlScreenState extends State<DeviceControlScreen> with WidgetsBindingObserver {
  late final BleService _bleService;

  @override
  void initState() {
    super.initState();
    _bleService = context.read<BleService>();
    WidgetsBinding.instance.addObserver(this);
    _initializeConnections();
  }

  Future<void> _initializeConnections() async {
    if (!mounted) return;
    context.read<DeviceControlBloc>().add(LoadDevices());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;

    switch (state) {
      case AppLifecycleState.resumed:
        context.read<DeviceControlBloc>().add(LoadDevices());
        break;
      case AppLifecycleState.paused:
        _bleService.disconnectFromDevice();
        break;
      default:
        break;
    }
  }

  Future<void> _showAddDeviceDialog() async {
    if (!mounted) return;

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Colors.transparent,
          ),
          child: AddDeviceDialog(
            onDeviceAdded: (String name, BluetoothDevice? selectedDevice) {
              context.read<DeviceControlBloc>().add(
                AddDevice(
                  name: name,
                  bluetoothDevice: selectedDevice,
                ),
              );
            },
            bleService: _bleService,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: BlocBuilder<DeviceControlBloc, DeviceControlState>(
              builder: (context, state) {
                final isLoading = state is DeviceControlLoading;
                return Material(
                  color: Colors.blue[600],
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: isLoading ? null : _showAddDeviceDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
                );
              },
            ),
          ),
        ],
      ),
      body: BlocBuilder<DeviceControlBloc, DeviceControlState>(
        builder: (context, state) {
          if (state is DeviceControlLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is DeviceControlLoaded) {
            if (state.devices.isEmpty) {
              return _buildEmptyState();
            }
            return _buildDeviceList(state.devices);
          }

          if (state is DeviceControlError) {
            return Center(child: Text(state.message));
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildDeviceList(List<Device> devices) {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: devices.length,
      itemBuilder: (context, index) {
        final device = devices[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: StreamBuilder<bool>(
            stream: _bleService.connectionStatusStream,
            initialData: device.isBleConnected,
            builder: (context, snapshot) {
              final isConnected = snapshot.data ?? false;

              return GestureDetector(
                onTap: () async {
                  if (!isConnected && device.bluetoothDevice != null && mounted) {
                    await showNotConnectedDialog(
                      context: context,
                      device: device,
                      bleService: _bleService,
                      onConnected: () {
                        context.read<DeviceControlBloc>().add(
                          UpdateDeviceConnection(
                            device: device,
                            isConnected: true,
                          ),
                        );
                      },
                    );
                  }
                },
                child: DeviceRemote(
                  device: device,
                  bleService: _bleService,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
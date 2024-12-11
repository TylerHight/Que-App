// lib/features/device_control/dialogs/add_device/add_device_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import './managers/ble_connection_manager.dart';
import './models/add_device_state.dart';
import './components/device_name_field.dart';
import './components/device_selector.dart';
import './components/bluetooth_status.dart';

class AddDeviceDialog extends StatefulWidget {
  final Function(String name, BluetoothDevice? device) onDeviceAdded;
  final bool includeNameField;
  final BleService bleService;

  const AddDeviceDialog({
    super.key,
    required this.onDeviceAdded,
    required this.bleService,
    this.includeNameField = true,
  });

  @override
  _AddDeviceDialogState createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  late final BleConnectionManager _bleManager;
  late final AddDeviceState _state;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _stateUpdateEnabled = true;

  @override
  void initState() {
    super.initState();
    _state = AddDeviceState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bleManager = BleConnectionManager(
      bleService: widget.bleService,
      onStateChanged: _handleStateChange,
      context: context,
    );
    _bleManager.initialize();
  }

  void _handleStateChange(AddDeviceState newState) {
    if (!mounted || !_stateUpdateEnabled) return;
    setState(() {
      final currentDevice = _state.selectedDevice;
      _state.update(newState);
      if (currentDevice != null) {
        final matchingDevice = newState.nearbyDevices.firstWhere(
              (device) => device.remoteId.str == currentDevice.remoteId.str,
          orElse: () => currentDevice,
        );
        _state.setSelectedDevice(matchingDevice);
      }
    });
  }

  Future<void> _handleDeviceSelection(BluetoothDevice? device) async {
    if (!mounted) return;
    _stateUpdateEnabled = false;
    setState(() {
      _state.setSelectedDevice(device);
    });
    await Future.delayed(const Duration(milliseconds: 100));
    _stateUpdateEnabled = true;
  }

  Future<void> _handleAddDevice() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a device name')),
      );
      return;
    }

    widget.onDeviceAdded(name, _state.selectedDevice);
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bleManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Add Device',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 24),
                  if (widget.includeNameField)
                    DeviceNameField(
                      controller: _nameController,
                      enabled: !_state.isConnecting,
                    ),
                  DeviceSelector(
                    devices: _state.nearbyDevices,
                    selectedDevice: _state.selectedDevice,
                    isConnecting: _state.isConnecting,
                    onDeviceSelected: _handleDeviceSelection,
                  ),
                  BluetoothStatus(
                    isScanning: _state.isScanning,
                    isConnecting: _state.isConnecting,
                    statusMessage: _state.statusMessage,
                    onScanPressed: () => _bleManager.startScan(),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: _state.isConnecting
                            ? null
                            : () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _state.isConnecting ? null : _handleAddDevice,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
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
      // Preserve selected device when updating state
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
    _stateUpdateEnabled = false;  // Temporarily disable state updates
    setState(() {
      _state.setSelectedDevice(device);
    });
    await Future.delayed(const Duration(milliseconds: 100));
    _stateUpdateEnabled = true;  // Re-enable state updates
  }

  Future<void> _handleAddDevice() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final selectedDevice = _state.selectedDevice;

    // Return name and selected device to parent
    widget.onDeviceAdded(name, selectedDevice);
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bleManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Add Que',
        style: TextStyle(color: Colors.black),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
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
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _state.isConnecting ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _state.isConnecting ? null : () {
            if (_formKey.currentState?.validate() ?? false) {
              _handleAddDevice();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
// lib/features/device_control/dialogs/add_device/add_device_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/core/models/device_list.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import 'package:que_app/features/device_control/dialogs/add_device/managers/ble_connection_manager.dart';
import 'package:que_app/features/device_control/dialogs/add_device/models/add_device_state.dart';
import 'package:que_app/features/device_control/dialogs/add_device/components/device_name_field.dart';
import 'package:que_app/features/device_control/dialogs/add_device/components/device_selector.dart';
import 'package:que_app/features/device_control/dialogs/add_device/components/bluetooth_status.dart';

class AddDeviceDialog extends StatefulWidget {
  final Function(Device) onDeviceAdded;
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

  @override
  void initState() {
    super.initState();
    _state = AddDeviceState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize BLE manager here since we need context
    _bleManager = BleConnectionManager(
      bleService: widget.bleService,
      onStateChanged: _handleStateChange,
      context: context,
    );
    _bleManager.initialize();
  }

  void _handleStateChange(AddDeviceState newState) {
    if (!mounted) return;
    setState(() {
      _state.update(newState);
    });
  }

  Future<void> _handleAddDevice() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text;
    final selectedDevice = _state.selectedDevice;

    if (selectedDevice != null) {
      setState(() => _state.setConnecting(true));

      try {
        final connected = await _bleManager.connectToDevice(selectedDevice);
        if (!connected) {
          throw Exception("Failed to establish connection");
        }
        _createAndAddDevice(name, selectedDevice);
      } catch (e) {
        setState(() {
          _state.setConnecting(false);
          _state.setStatusMessage("Connection failed: ${e.toString()}");
        });

        if (!mounted) return;

        // Show dialog asking if user wants to continue without connection
        final continueWithoutConnection = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Connection Failed'),
            content: const Text('Would you like to add the device without connecting?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.of(context).pop(false),
              ),
              TextButton(
                child: const Text('Add Without Connection'),
                onPressed: () => Navigator.of(context).pop(true),
              ),
            ],
          ),
        );

        if (continueWithoutConnection == true) {
          _createAndAddDevice(name, null);
        }
      }
    } else {
      _createAndAddDevice(name, null);
    }
  }

  void _createAndAddDevice(String name, BluetoothDevice? bluetoothDevice) {
    final deviceList = Provider.of<DeviceList>(context, listen: false);

    final newDevice = Device(
      id: UniqueKey().toString(),
      deviceName: name,
      connectedQueName: bluetoothDevice?.platformName ?? '',
      bluetoothDevice: bluetoothDevice,
      bleService: widget.bleService,
    );

    _state.setCompleted(true);
    deviceList.add(newDevice);
    widget.onDeviceAdded(newDevice);

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
                  onDeviceSelected: (device) => setState(() => _state.setSelectedDevice(device)),
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
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              _handleAddDevice();
            }
          },
          child: Text(_state.isConnecting ? 'Connecting...' : 'Add'),
        ),
      ],
    );
  }
}
// lib/features/device_control/dialogs/add_device/add_device_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import '../../handlers/device_creation_handler.dart';
import 'package:que_app/core/utils/ble/ble_utils.dart';

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
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  bool _isScanning = false;
  bool _isConnecting = false;
  String _status = '';
  List<BluetoothDevice> _nearbyDevices = [];
  BluetoothDevice? _selectedDevice;

  @override
  void initState() {
    super.initState();
    _initializeBluetooth();
  }

  Future<void> _initializeBluetooth() async {
    try {
      if (!await FlutterBluePlus.isSupported) {
        setState(() => _status = 'Bluetooth not supported on this device');
        return;
      }

      if (!await FlutterBluePlus.isOn) {
        await FlutterBluePlus.turnOn();
      }

      _startScan();
    } catch (e) {
      setState(() => _status = 'Initialization error: $e');
    }
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
      _status = 'Scanning for devices...';
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidScanMode: AndroidScanMode.lowLatency,
      );

      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          _nearbyDevices = results
              .where((result) => result.device.platformName.isNotEmpty)
              .map((result) => result.device)
              .toList();
          _status = 'Found ${_nearbyDevices.length} devices';
        });
      });

      await Future.delayed(const Duration(seconds: 4));

      setState(() {
        _isScanning = false;
        if (_nearbyDevices.isEmpty) {
          _status = 'No devices found';
        }
      });
    } catch (e) {
      setState(() {
        _isScanning = false;
        _status = 'Scan error: $e';
      });
    }
  }

  Future<void> _handleDeviceSelection(BluetoothDevice? device) async {
    setState(() {
      _selectedDevice = device;
      _status = device != null ? 'Selected ${device.platformName}' : '';
    });
  }

  Future<void> _handleAddDevice() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();

    await DeviceCreationHandler.validateAndCreateDevice(
      name: name,
      bluetoothDevice: _selectedDevice,
      onDeviceCreated: (device) {
        widget.onDeviceAdded(name, _selectedDevice);
        Navigator.of(context).pop();
      },
      onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error)),
        );
      },
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.add_circle_outline, color: Colors.blue),
                  const SizedBox(width: 8),
                  const Text(
                    'Add Device',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              if (widget.includeNameField)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Device Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.devices),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a device name';
                    }
                    return null;
                  },
                  enabled: !_isConnecting,
                ),
              const SizedBox(height: 16),
              _buildDeviceDropdown(),
              const SizedBox(height: 16),
              _buildScanButton(),
              if (_status.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  _status,
                  style: TextStyle(
                    fontSize: 14,
                    color: _getStatusColor(_status),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isConnecting
                        ? null
                        : () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isConnecting ? null : _handleAddDevice,
                    child: const Text('Add Device'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceDropdown() {
    return InputDecorator(
      decoration: const InputDecoration(
        labelText: 'Select Device',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.bluetooth),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<BluetoothDevice>(
          isExpanded: true,
          value: _selectedDevice,
          hint: const Text('No device selected'),
          onChanged: _isConnecting ? null : _handleDeviceSelection,
          items: [
            ..._nearbyDevices.map((device) => DropdownMenuItem(
              value: device,
              child: Text(device.platformName),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildScanButton() {
    return ElevatedButton.icon(
      onPressed: _isScanning || _isConnecting ? null : _startScan,
      icon: _isScanning
          ? const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : const Icon(Icons.refresh),
      label: Text(_isScanning ? 'Scanning...' : 'Scan for Devices'),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
    );
  }

  Color _getStatusColor(String status) {
    if (status.contains('error') || status.contains('failed')) {
      return Colors.red;
    }
    if (status.contains('Scanning')) {
      return Colors.blue;
    }
    if (status.contains('Found') || status.contains('Selected')) {
      return Colors.green;
    }
    return Colors.grey;
  }
}
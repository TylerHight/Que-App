// lib/screens/device_control/dialogs/add_device_dialog.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import 'package:que_app/core/utils/ble/ble_utils.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:provider/provider.dart';
import 'package:que_app/core/models/device_list.dart';

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
  late BleUtils bleUtils;
  List<BluetoothDevice> nearbyDevices = [];
  BluetoothDevice? selectedDevice;
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  StreamSubscription? _deviceStateSubscription;
  StreamSubscription? _connectionStatusSubscription;

  bool _isScanning = false;
  bool _isConnecting = false;
  String _statusMessage = "";
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    bleUtils = BleUtils();
    _setupSubscriptions();
    _startScan();
  }

  void _setupSubscriptions() {
    _deviceStateSubscription = widget.bleService.deviceStateStream.listen(
            (message) {
          if (mounted) {
            setState(() => _statusMessage = message);
          }
        },
        onError: (error) {
          if (mounted) {
            setState(() {
              _statusMessage = "Error: $error";
              _isConnecting = false;
            });
          }
        }
    );

    _connectionStatusSubscription = widget.bleService.connectionStatusStream.listen(
            (isConnected) {
          if (!mounted) return;
          if (!isConnected && _isConnecting) {
            setState(() {
              _statusMessage = "Device disconnected";
              _isConnecting = false;
            });
          }
        }
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deviceStateSubscription?.cancel();
    _connectionStatusSubscription?.cancel();
    if (!_isCompleted && _isConnecting) {
      widget.bleService.disconnectFromDevice();
    }
    super.dispose();
  }

  Future<void> _startScan() async {
    if (!mounted) return;

    setState(() {
      _isScanning = true;
      _statusMessage = "Scanning for devices...";
      nearbyDevices.clear();
      selectedDevice = null;
    });

    try {
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 4),
        androidScanMode: AndroidScanMode.lowLatency,
      );

      FlutterBluePlus.scanResults.listen((results) {
        if (mounted) {
          setState(() {
            nearbyDevices = results
                .where((result) =>
            result.device.platformName == "Nano 33 BLE" &&
                result.advertisementData.connectable)
                .map((result) => result.device)
                .toList();
            _statusMessage = nearbyDevices.isEmpty ? "No devices found" : "";
          });
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _statusMessage = "Scan failed: ${e.toString()}";
      });
    } finally {
      if (!mounted) {
        await FlutterBluePlus.stopScan();
        return;
      }
      setState(() {
        _isScanning = false;
      });
    }
  }

  List<BluetoothDevice> getDevicesWithNames() {
    return nearbyDevices.where((device) => device.platformName.isNotEmpty).toList();
  }

  Future<void> _addDevice() async {
    if (!_formKey.currentState!.validate()) return;

    // If a device is selected, connect to it
    if (selectedDevice != null) {
      if (!mounted) return;
      setState(() {
        _isConnecting = true;
        _statusMessage = "Connecting to ${selectedDevice!.platformName}...";
      });

      try {
        await widget.bleService.connectToDevice(selectedDevice!);
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        if (mounted) {
          setState(() {
            _isConnecting = false;
            _statusMessage = "Connection failed: ${e.toString()}";
          });
          return;
        }
      }
    }

    // Create the device
    final name = _nameController.text;
    final deviceList = Provider.of<DeviceList>(context, listen: false);

    final newDevice = Device(
      id: UniqueKey().toString(),
      deviceName: name,
      connectedQueName: selectedDevice?.platformName ?? '',
      bluetoothDevice: selectedDevice,
      bleService: widget.bleService,
    );

    // Set completion flag before closing dialog
    _isCompleted = true;

    // Only add the device once through the deviceList
    deviceList.add(newDevice);

    // Just notify the parent that a device was added without passing the device
    widget.onDeviceAdded(newDevice);

    if (mounted) {
      Navigator.of(context).pop();
    }
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Name',
                        border: OutlineInputBorder(),
                      ),
                      enabled: !_isConnecting,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a name';
                        }
                        return null;
                      },
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: DropdownButtonFormField<BluetoothDevice>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Select Que (Optional)',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedDevice,
                    onChanged: _isConnecting ? null : (BluetoothDevice? device) {
                      setState(() => selectedDevice = device);
                    },
                    items: [
                      const DropdownMenuItem<BluetoothDevice>(
                        value: null,
                        child: Text('No Que selected'),
                      ),
                      ...getDevicesWithNames()
                          .map((device) => DropdownMenuItem(
                        value: device,
                        child: Text(
                          device.platformName,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ))
                          .toList(),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _isConnecting ? null : () => _startScan(),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 40),
                  ),
                  child: Text(_isScanning ? 'Scanning...' : 'Rescan'),
                ),
                if (_statusMessage.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      _statusMessage,
                      style: TextStyle(
                        color: _statusMessage.contains('Error') ||
                            _statusMessage.contains('failed') ||
                            _statusMessage.contains('timeout')
                            ? Colors.red
                            : Colors.blue,
                      ),
                    ),
                  ),
                if (_isConnecting || _isScanning)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Center(child: CircularProgressIndicator()),
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: _isConnecting ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isConnecting || _isScanning ? null : _addDevice,
          child: Text(_isConnecting ? 'Connecting...' : 'Add'),
        ),
      ],
    );
  }
}
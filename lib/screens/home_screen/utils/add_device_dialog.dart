import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class DeviceNameDialog extends StatefulWidget {
  final Function(String) onDeviceNameEntered;

  const DeviceNameDialog({Key? key, required this.onDeviceNameEntered})
      : super(key: key);

  @override
  _DeviceNameDialogState createState() => _DeviceNameDialogState();
}

class _DeviceNameDialogState extends State<DeviceNameDialog> {
  final TextEditingController _deviceNameController = TextEditingController();
  String _selectedDevice = ''; // Default selected device
  List<ScanResult> _availableDevices = [];
  bool _isScanning = false;

  @override
  Widget build(BuildContext context) {
    // Filter devices to remove unknown devices or devices without names
    List<ScanResult> filteredDevices = _availableDevices
        .where((device) => device.device.name.isNotEmpty)
        .toList();

    return AlertDialog(
      title: const Text('Add New Device'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _deviceNameController,
            decoration: const InputDecoration(labelText: 'Name Device'),
          ),
          const SizedBox(height: 16.0),
          // Display a dropdown menu of available Bluetooth devices or "No devices found"
          DropdownButtonFormField<ScanResult>(
            value: _selectedDevice.isNotEmpty
                ? _availableDevices
                .firstWhere(
                    (device) => device.device.id.toString() == _selectedDevice,
                orElse: () => _availableDevices.first)
                : null,
            items: filteredDevices.map((device) {
              return DropdownMenuItem<ScanResult>(
                value: device,
                child: Text(device.device.name),
              );
            }).toList(),
            onChanged: _availableDevices.isEmpty
                ? null
                : (device) {
              setState(() {
                _selectedDevice = device!.device.id.toString();
              });
            },
            hint: _availableDevices.isEmpty
                ? const Text('No devices found')
                : const Text('Select Device (Optional)'),
            disabledHint: const Text('No devices found'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            String deviceName = _deviceNameController.text.trim();
            if (deviceName.isEmpty && _selectedDevice.isNotEmpty) {
              deviceName = _availableDevices
                  .firstWhere((device) => device.device.id.toString() == _selectedDevice,
                  orElse: () => _availableDevices.first)
                  .device
                  .name;
            }
            if (deviceName.isNotEmpty) {
              widget.onDeviceNameEntered(deviceName);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _requestLocationPermissionAndStartScanning();
  }

  @override
  void dispose() {
    _stopScanning();
    super.dispose();
  }

  Future<void> _requestLocationPermissionAndStartScanning() async {
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }

    bool isAvailable = await FlutterBlue.instance.isAvailable;
    bool isOn = await FlutterBlue.instance.isOn;

    if (isAvailable && isOn) {
      _startScanning();
    } else {
      _showBluetoothAlert(isAvailable, isOn);
    }
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });

    FlutterBlue.instance.scanResults.listen((results) {
      setState(() {
        _availableDevices = results;
      });
    });

    FlutterBlue.instance.startScan(timeout: const Duration(seconds: 10));
  }

  void _stopScanning() {
    FlutterBlue.instance.stopScan();
    setState(() {
      _isScanning = false;
    });
  }

  void _showBluetoothAlert(bool isAvailable, bool isOn) {
    String title = 'Bluetooth Error';
    String message = '';

    if (!isAvailable) {
      message = 'Bluetooth is not available on this device.';
    } else if (!isOn) {
      message = 'Bluetooth is turned off. Please turn it on and try again.';
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

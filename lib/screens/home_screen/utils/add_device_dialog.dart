import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:que_app/bluetooth.dart'; // Import the Bluetooth file

class DeviceNameDialog extends StatefulWidget {
  final Function({required String deviceName, required String bluetoothDeviceID}) onDeviceNameEntered;

  const DeviceNameDialog({Key? key, required this.onDeviceNameEntered}) : super(key: key);

  @override
  _DeviceNameDialogState createState() => _DeviceNameDialogState();
}

class _DeviceNameDialogState extends State<DeviceNameDialog> {
  final TextEditingController _deviceNameController = TextEditingController();
  String _selectedDevice = ''; // Default selected device
  List<ScanResult> _availableDevices = [];
  bool _isScanning = false;

  late BLEController _bleController; // Declare BLEController instance

  @override
  void initState() {
    super.initState();
    _bleController = BLEController(); // Initialize BLEController instance
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

    Bluetooth().scanForDevices().listen((results) {
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
            String bluetoothDeviceID = _selectedDevice.isNotEmpty
                ? _selectedDevice
                : '';

            if (deviceName.isNotEmpty) {
              // Call addDeviceTitle with the provided device name and Bluetooth device ID
              widget.onDeviceNameEntered(deviceName: deviceName, bluetoothDeviceID: bluetoothDeviceID);
              _connectToDevice();
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  void _connectToDevice() async {
    try {
      await _bleController.connectToDevice(_availableDevices.first.device);
    } catch (e) {
      print('Failed to connect to device: $e');
    }
  }
}

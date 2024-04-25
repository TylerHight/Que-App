import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:que_app/ble_control.dart'; // Import the BleControl file
import 'package:provider/provider.dart';
import 'package:que_app/device_data.dart';

class DeviceNameDialog extends StatefulWidget {
  final Function({required String deviceName, required String bluetoothDeviceID})
  onDeviceNameEntered;

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

  late BleControl _bleControl; // Declare BleControl instance

  @override
  void initState() {
    super.initState();
    _bleControl = BleControl(); // Initialize BleControl instance
    _requestLocationPermissionAndStartScanning();
  }

  @override
  void dispose() {
    _stopScanning();
    super.dispose();
  }

  Future<void> _requestLocationPermissionAndStartScanning() async {
    print('Requesting location permission...');
    if (await Permission.location.isDenied) {
      await Permission.location.request();
    }

    print('Checking Bluetooth availability...');
    bool isAvailable = await FlutterBlue.instance.isAvailable;
    bool isOn = await FlutterBlue.instance.isOn;

    if (isAvailable && isOn) {
      print('Bluetooth is available and turned on. Starting scanning...');
      _startScanning();
    } else {
      print('Bluetooth is not available or turned off.');
      _showBluetoothAlert(isAvailable, isOn);
    }
  }

  void _startScanning() {
    print('Starting BLE scan...');
    setState(() {
      _isScanning = true;
    });

    _bleControl.startScan().listen(
          (results) {
        print('Scan results received: $results');
        setState(() {
          _availableDevices = results;
        });
      },
      onError: (e) {
        print('Error while scanning: $e');
        // Handle the error accordingly, such as displaying an error message.
      },
      cancelOnError: true, // Cancel the stream on error
    );
  }

  void _stopScanning() {
    print('Stopping BLE scan...');
    _bleControl.stopScan();
    setState(() {
      _isScanning = false; // Set _isScanning to false when scanning is stopped
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
    List<ScanResult> filteredDevices = _availableDevices.where((device) => device.device.name.isNotEmpty).toList();

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
                ? _availableDevices.firstWhere(
                  (device) => device.device.id.toString() == _selectedDevice,
              orElse: () => _availableDevices.first,
            )
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
              _connectToDevice(device!.device); // Call connectToDevice when device is selected
            },
            hint: _availableDevices.isEmpty ? const Text('No devices found') : const Text('Select Device (Optional)'),
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
            String bluetoothDeviceID = _selectedDevice.isNotEmpty ? _selectedDevice : '';

            if (deviceName.isNotEmpty) {
              // Call addDeviceTitle with the provided device name and Bluetooth device ID
              widget.onDeviceNameEntered(deviceName: deviceName, bluetoothDeviceID: bluetoothDeviceID);
              // Save the device to device_data.dart
              Provider.of<DeviceData>(context, listen: false).addDeviceTitle(deviceName, bluetoothDeviceID: bluetoothDeviceID);

              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      print('Connecting to device: ${device.name}');
      await _bleControl.connectToDevice(device);
    } catch (e) {
      print('Failed to connect to device: $e');
    }
  }
}

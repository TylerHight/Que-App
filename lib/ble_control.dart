import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class BleControl {
  final String serviceUUID = "0000180a-0000-1000-8000-00805f9b34fb";
  final String controlCharacteristicUUID = "00002a57-0000-1000-8000-00805f9b34fb";
  final String settingCharacteristicUUID = "19b10001-e8f2-537e-4f6c-d104768a1214";
  BluetoothCharacteristic? controlCharacteristic;
  BluetoothCharacteristic? settingCharacteristic;
  bool connected = false;

  FlutterBlue flutterBlue = FlutterBlue.instance;
  List<BluetoothDevice> devices = [];
  StreamSubscription<List<ScanResult>>? _scanSubscription;
  BluetoothDevice? connectedDevice;

  Stream<List<ScanResult>> startScan() {
    // Check if scan is already active
    if (_scanSubscription == null) {
      print("Starting BLE scan...");
      _scanSubscription = flutterBlue.scanResults.listen((List<ScanResult> results) {
        for (ScanResult result in results) {
          print('${result.device.name} found! rssi: ${result.rssi}');
          if (!devices.contains(result.device)) {
            devices.add(result.device);
          }
        }
      });

      return flutterBlue.scanResults;
    }
    return Stream.empty();
  }

  void stopScan() {
    print('Stopping BLE scan...');
    flutterBlue.stopScan();
    _scanSubscription?.cancel();
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      print("Stopping BLE scan");
      stopScan();
      print('Connecting to device: ${device.name}');
      await device.connect();

      print("Waiting to discover services...");
      await Future.delayed(const Duration(seconds: 1));

      print("Discovering services...");
      List<BluetoothService> services = await device.discoverServices();
      print("Available services on ${device.name}:");
      for (var service in services) {
        print("- Service UUID: ${service.uuid}");
        if (service.uuid.toString() == serviceUUID) {
          print("Target service found.");
          print("Searching for matching characteristic(s) in service...");
          for (var characteristic in service.characteristics) {
            print("Found characteristic UUIDs: $characteristic.uuid");
            if (characteristic.uuid.toString() == controlCharacteristicUUID) {
              print("Control characteristic found: ${characteristic.uuid}");
              controlCharacteristic = characteristic;
            } else if (characteristic.uuid.toString() == settingCharacteristicUUID) {
              print("Setting characteristic found: ${characteristic.uuid}");
              settingCharacteristic = characteristic;
            } else {
              print("UUIDs did not match");
            }
          }
          print("Exiting _connectToDevice method");
          break;
        }
      }

      connected = true;
    } catch (e) {
      print("Error connecting to device: $e");
    }
  }

  void disconnectFromDevice(BluetoothDevice device) async {
    try {
      await device.disconnect();
      connected = false;
    } catch (e) {
      print("Error disconnecting from device: $e");
    }
  }

  void sendCommand(int value) async {
    final characteristic = controlCharacteristic;
    if (characteristic != null) {
      List<int> data = [value];
      print("Sending control command to Arduino: $data");
      await characteristic.write(data);
      print("Command sent successfully!");
    } else {
      print("Characteristic is null. Cannot send command to Arduino.");
    }
  }
}

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

    _bleControl.startScan().listen(
          (results) {
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
    _bleControl.stopScan();
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
            String bluetoothDeviceID = _selectedDevice.isNotEmpty ? _selectedDevice : '';

            if (deviceName.isNotEmpty) {
              // Call addDeviceTitle with the provided device name and Bluetooth device ID
              widget.onDeviceNameEntered(deviceName: deviceName, bluetoothDeviceID: bluetoothDeviceID);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );
  }

  void _connectToDevice(BluetoothDevice device) async {
    try {
      print('Connecting to device');
      await _bleControl.connectToDevice(device);
    } catch (e) {
      print('Failed to connect to device: $e');
    }
  }
}

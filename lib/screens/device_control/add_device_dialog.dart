import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:que_app/services/ble_service.dart';
import 'package:que_app/utils/ble_utils.dart';
import 'package:que_app/models/device.dart';
import 'package:que_app/app_data.dart'; // Import app_data.dart to access devicesList

class AddDeviceDialog extends StatefulWidget {
  final Function(Device) onDeviceAdded;

  AddDeviceDialog({required this.onDeviceAdded});

  @override
  _AddDeviceDialogState createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  late BleService bleService;
  late BleUtils bleUtils;
  List<BluetoothDevice> nearbyDevices = [];
  BluetoothDevice? selectedDevice;
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    bleService = BleService();
    bleUtils = BleUtils();
    _startScan();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    try {
      nearbyDevices = await bleUtils.startScan();
      setState(() {});
    } catch (e) {
      print("Error scanning for nearby devices: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Device'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            DropdownButtonFormField<BluetoothDevice>(
              decoration: InputDecoration(labelText: 'Select Que'),
              value: selectedDevice,
              onChanged: (BluetoothDevice? device) {
                setState(() {
                  selectedDevice = device;
                });
              },
              items: nearbyDevices
                  .map((device) => DropdownMenuItem(
                value: device,
                child: Text(device.name),
              ))
                  .toList(),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 5, // Adjust the width as needed
              child: ElevatedButton(
                onPressed: _startScan,
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                      Size(0, 40)), // Adjust the height as needed
                ),
                child: Text('Rescan'),
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Add'),
          onPressed: () {
            _addDevice();
          },
        ),
      ],
    );
  }

  void _addDevice() {
    final name = _nameController.text;
    final connectedQueName =
    selectedDevice != null ? selectedDevice!.name : 'none';

    // Create a new Device instance with the provided information
    final newDevice = Device(
      id: UniqueKey().toString(), // Generate a unique id for the new device
      deviceName: name,
      connectedQueName: connectedQueName,
    );

    // Set isBleConnected to true for the selected device and false for all other devices
    if (newDevice.connectedQueName != "none") {
      for (final device in devicesList) {
        device.isBleConnected = false;
      }
      newDevice.isBleConnected = true;
    }

    // Pass the new device back to the callback function
    widget.onDeviceAdded(newDevice);

    // Close the dialog
    Navigator.of(context).pop();
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:que_app/services/ble_service.dart';
import 'package:que_app/utils/ble_utils.dart';

class AddDeviceDialog extends StatefulWidget {
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
                  minimumSize: MaterialStateProperty.all(Size(0, 40)), // Adjust the height as needed
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
    final connectedQueueName =
    selectedDevice != null ? selectedDevice!.name : 'none';

    // Implement logic to add the device here
    // You can access form values using form fields controllers or state
    // Once done, you can close the dialog
    Navigator.of(context).pop();
  }
}

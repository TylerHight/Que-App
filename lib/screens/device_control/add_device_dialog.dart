import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:que_app/services/ble_service.dart';
import 'package:que_app/utils/ble_utils.dart'; // Change "your_app_name" to the actual package name


class AddDeviceDialog extends StatefulWidget {
  @override
  _AddDeviceDialogState createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  BleService bleService = BleService();
  BleUtils bleUtils = BleUtils();

  List<BluetoothDevice> nearbyDevices = [];
  BluetoothDevice? selectedDevice;

  @override
  void initState() {
    super.initState();
    _startScan();
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
              decoration: InputDecoration(labelText: 'Que Name'),
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
            // Implement logic to add the device here
            // You can access form values using form fields controllers or state
            // Once done, you can close the dialog
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

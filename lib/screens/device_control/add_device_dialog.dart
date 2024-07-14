import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:que_app/services/ble_service.dart';
import 'package:que_app/utils/ble_utils.dart';
import 'package:que_app/models/device.dart';
import 'package:provider/provider.dart';
import 'package:que_app/models/device_list.dart';

class AddDeviceDialog extends StatefulWidget {
  final Function(Device) onDeviceAdded;
  final bool includeNameField;

  AddDeviceDialog({required this.onDeviceAdded, this.includeNameField = true});

  @override
  _AddDeviceDialogState createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  late BleService bleService;
  late BleUtils bleUtils;
  List<BluetoothDevice> nearbyDevices = [];
  BluetoothDevice? selectedDevice;
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

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

  List<BluetoothDevice> getDevicesWithNames() {
    return nearbyDevices.where((device) => device.name.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Add Que',
        style: TextStyle(color: Colors.black),
      ),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: ListBody(
            children: <Widget>[
              if (widget.includeNameField)
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
              DropdownButtonFormField<BluetoothDevice>(
                decoration: InputDecoration(labelText: 'Select Que'),
                value: selectedDevice,
                onChanged: (BluetoothDevice? device) {
                  setState(() {
                    selectedDevice = device;
                  });
                },
                items: getDevicesWithNames()
                    .map((device) => DropdownMenuItem(
                  value: device,
                  child: Text(device.name),
                ))
                    .toList(),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 5,
                child: ElevatedButton(
                  onPressed: () {
                    _startScan();
                  },
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(0, 40)),
                  ),
                  child: Text('Rescan'),
                ),
              ),
            ],
          ),
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
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              print('add_device_dialog.dart: awaiting _addDevice()');
              await _addDevice();
            }
          },
        ),
      ],
    );
  }

  Future<void> _addDevice() async {
    final name = _nameController.text;
    final connectedQueName = selectedDevice != null ? selectedDevice!.name : 'none';

    final deviceList = Provider.of<DeviceList>(context, listen: false);

    final newDevice = Device(
      id: UniqueKey().toString(),
      deviceName: name,
      connectedQueName: connectedQueName,
    );

    if (newDevice.connectedQueName != "none") {
      // Connect to the selected Bluetooth device
      print("add_device_dialog.dart");
      await bleService.connectToDevice(selectedDevice!);
    }

    deviceList.add(newDevice);
    Navigator.of(context).pop();
  }
}

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
    print('AddDeviceDialog: initState called');
    bleService = BleService();
    bleUtils = BleUtils();
    _startScan();
  }

  @override
  void dispose() {
    print('AddDeviceDialog: dispose called');
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    print('AddDeviceDialog: _startScan called');
    try {
      nearbyDevices = await bleUtils.startScan();
      print('AddDeviceDialog: Scanning complete, devices found: ${nearbyDevices.length}');
      setState(() {});
    } catch (e) {
      print("Error scanning for nearby devices: $e");
    }
  }

  List<BluetoothDevice> getDevicesWithNames() {
    print('AddDeviceDialog: getDevicesWithNames called');
    return nearbyDevices.where((device) => device.name.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    print('AddDeviceDialog: build called');
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
                  print('AddDeviceDialog: Device selected: ${device?.name}');
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
                    print('AddDeviceDialog: Rescan button pressed');
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
            print('AddDeviceDialog: Cancel button pressed');
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Add'),
          onPressed: () {
            print('AddDeviceDialog: Add button pressed');
            if (_formKey.currentState!.validate()) {
              _addDevice();
            }
          },
        ),
      ],
    );
  }

  void _addDevice() async {
    print('AddDeviceDialog: _addDevice called');
    final name = _nameController.text;
    final connectedQueName = selectedDevice != null ? selectedDevice!.name : 'none';

    print('AddDeviceDialog: Device name: $name, Connected Que Name: $connectedQueName');

    final deviceList = Provider.of<DeviceList>(context, listen: false);

    final newDevice = Device(
      id: UniqueKey().toString(),
      deviceName: name,
      connectedQueName: connectedQueName,
    );

    if (newDevice.connectedQueName != "none") {
      for (final device in deviceList.devices) {
        device.isBleConnected = false;
      }
      newDevice.isBleConnected = true;

      // Connect to the selected Bluetooth device
      try {
        await bleService.connectToDevice(selectedDevice!);
        print('AddDeviceDialog: Connected to device: ${selectedDevice!.name}');
      } catch (e) {
        print('Error connecting to device: $e');
      }
    }

    print('AddDeviceDialog: Adding new device: ${newDevice.deviceName} with connected Que: ${newDevice.connectedQueName}');
    deviceList.add(newDevice);

    Navigator.of(context).pop();
  }
}

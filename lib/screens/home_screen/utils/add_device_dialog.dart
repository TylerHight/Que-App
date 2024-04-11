import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceNameDialog extends StatefulWidget {
  final Function(String) onDeviceNameEntered;

  const DeviceNameDialog({super.key, required this.onDeviceNameEntered});

  @override
  _DeviceNameDialogState createState() => _DeviceNameDialogState();
}

class _DeviceNameDialogState extends State<DeviceNameDialog> {
  final TextEditingController _deviceNameController = TextEditingController();
  BluetoothDevice? _selectedDevice;
  List<BluetoothDevice> _availableDevices = []; // Store available devices

  @override
  void initState() {
    super.initState();
    FlutterBlue.instance.scanResults.listen((results) {
      _availableDevices = results.map((result) => result.device!).toList();
      setState(() {}); // Trigger UI rebuild
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Device'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display a dropdown menu of available Bluetooth devices (optional)
          _selectedDevice != null
              ? Text('Selected Device: ${_selectedDevice?.name ?? 'Unknown Device'}')
              : DropdownButtonFormField<BluetoothDevice>(
            value: _selectedDevice,
            items: _availableDevices.map((device) {
              return DropdownMenuItem<BluetoothDevice>(
                value: device,
                child: Text(device.name ?? 'Unknown Device'),
              );
            }).toList(),
            onChanged: (device) => setState(() => _selectedDevice = device),
            hint: const Text('Select Device (Optional)'),
          ),
          const SizedBox(height: 16.0),
          TextField(
            controller: _deviceNameController,
            decoration: const InputDecoration(labelText: 'Device Name'),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            String deviceName;
            if (_selectedDevice != null) {
              deviceName = _selectedDevice!.name ?? '';
            } else {
              deviceName = _deviceNameController.text.trim();
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
}

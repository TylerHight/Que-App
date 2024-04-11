import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class DeviceNameDialog extends StatefulWidget {
  final Function(String) onDeviceNameEntered;

  const DeviceNameDialog({Key? key, required this.onDeviceNameEntered}) : super(key: key);

  @override
  _DeviceNameDialogState createState() => _DeviceNameDialogState();
}

class _DeviceNameDialogState extends State<DeviceNameDialog> {
  final TextEditingController _deviceNameController = TextEditingController();
  BluetoothDevice? _selectedDevice;
  List<ScanResult> _scanResults = []; // Store scan results

  @override
  void initState() {
    super.initState();
    FlutterBlue.instance.scanResults.listen((results) {
      setState(() {
        _scanResults = results;
      });
    });
    FlutterBlue.instance.startScan();
  }

  @override
  void dispose() {
    FlutterBlue.instance.stopScan();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Device'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display a dropdown menu of available Bluetooth devices
          DropdownButtonFormField<ScanResult>(
            value: _selectedDevice != null
                ? _scanResults.firstWhere(
                  (result) => result.device.id == _selectedDevice!.id,
              orElse: () => _scanResults.isNotEmpty ? _scanResults[0] : _scanResults.first,
            )
                : _scanResults.isNotEmpty ? _scanResults[0] : null,
            items: _scanResults.isNotEmpty
                ? _scanResults.map((result) {
              return DropdownMenuItem<ScanResult>(
                value: result,
                child: Text(result.device.name ?? 'Unknown Device'),
              );
            }).toList()
                : [
              DropdownMenuItem<ScanResult>(
                value: null,
                child: Text('No devices found'),
              ),
            ],
            onChanged: _scanResults.isNotEmpty
                ? (result) => setState(() => _selectedDevice = result!.device)
                : null,
            hint: _scanResults.isEmpty ? const Text('No devices found') : const Text('Select Device (Optional)'),
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
            String deviceName = _deviceNameController.text.trim();
            if (deviceName.isEmpty && _selectedDevice != null) {
              deviceName = _selectedDevice!.name ?? '';
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

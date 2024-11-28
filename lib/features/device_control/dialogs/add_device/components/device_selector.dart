// lib/features/device_control/dialogs/add_device/components/device_selector.dart

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class DeviceSelector extends StatelessWidget {
  final List<BluetoothDevice> devices;
  final BluetoothDevice? selectedDevice;
  final bool isConnecting;
  final ValueChanged<BluetoothDevice?> onDeviceSelected;

  const DeviceSelector({
    super.key,
    required this.devices,
    required this.selectedDevice,
    required this.isConnecting,
    required this.onDeviceSelected,
  });

  List<BluetoothDevice> _getDevicesWithNames() {
    return devices.where((device) => device.platformName.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final devicesWithNames = _getDevicesWithNames();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: DropdownButtonFormField<BluetoothDevice>(
            isExpanded: true,
            decoration: const InputDecoration(
              labelText: 'Connect to Device',
              helperStyle: TextStyle(fontStyle: FontStyle.italic),
              helperMaxLines: 2,
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            ),
            hint: const Text('Select a device or leave empty'),
            value: selectedDevice,
            onChanged: isConnecting
                ? null
                : (BluetoothDevice? device) => onDeviceSelected(device),
            items: [
              const DropdownMenuItem<BluetoothDevice>(
                value: null,
                child: Row(
                  children: [
                    Icon(Icons.do_not_disturb, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('No device selected'),
                  ],
                ),
              ),
              if (devicesWithNames.isNotEmpty)
                const DropdownMenuItem<BluetoothDevice>(
                  enabled: false,
                  child: Divider(),
                ),
              ...devicesWithNames.map((device) => DropdownMenuItem(
                value: device,
                child: Row(
                  children: [
                    const Icon(
                      Icons.bluetooth,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        device.platformName,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )).toList(),
            ],
          ),
        ),
      ],
    );
  }
}
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

  @override
  Widget build(BuildContext context) {
    // Deduplicate devices by remoteId
    final uniqueDevices = <String, BluetoothDevice>{};
    for (var device in devices) {
      if (device.platformName.isNotEmpty) {
        uniqueDevices[device.remoteId.str] = device;
      }
    }

    // Get currently selected device from unique devices if it exists
    final currentDevice = selectedDevice != null
        ? uniqueDevices[selectedDevice!.remoteId.str] ?? selectedDevice
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Connect to Device',
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<BluetoothDevice>(
              isExpanded: true,
              isDense: true,
              value: currentDevice,
              onChanged: isConnecting ? null : onDeviceSelected,
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
                ...uniqueDevices.values.map((device) => DropdownMenuItem(
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
        ),
      ),
    );
  }
}
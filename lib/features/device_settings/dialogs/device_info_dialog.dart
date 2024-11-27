// lib/features/device_settings/dialogs/device_info_dialog.dart
import 'package:flutter/material.dart';
import '../../../core/models/device/index.dart';

class DeviceInfoDialog extends StatelessWidget {
  final Device device;

  const DeviceInfoDialog({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Device Information'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('Device Name', device.deviceName),
          const SizedBox(height: 8),
          _buildInfoRow('Queue Name', device.connectedQueName),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Connection Status',
            device.isBleConnected ? 'Connected' : 'Disconnected',
            color: device.isBleConnected ? Colors.green : Colors.orange,
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Heart Rate Threshold',
            '${device.heartrateThreshold} BPM',
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('CLOSE'),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: color,
          ),
        ),
      ],
    );
  }
}
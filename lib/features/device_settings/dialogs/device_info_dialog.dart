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
          _buildInfoRow('Device Name', device.name),
          const SizedBox(height: 8),
          _buildInfoRow('Firmware Version', device.firmwareVersion),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Battery Level',
            '${device.batteryLevel}%',
            color: _getBatteryColor(device.batteryLevel),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Last Synced',
            _formatLastSync(device.lastSyncTime),
          ),
          const SizedBox(height: 8),
          _buildInfoRow(
            'Heart Rate Monitor',
            device.isHeartRateMonitorConnected ? 'Connected' : 'Not Connected',
            color: device.isHeartRateMonitorConnected ? Colors.green : Colors.grey,
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

  Color _getBatteryColor(int level) {
    if (level <= 20) return Colors.red;
    if (level <= 40) return Colors.orange;
    return Colors.green;
  }

  String _formatLastSync(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    }
  }
}
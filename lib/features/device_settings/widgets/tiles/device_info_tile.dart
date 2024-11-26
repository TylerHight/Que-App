// lib/features/device_settings/widgets/tiles/device_info_tile.dart

import 'package:flutter/material.dart';
import 'package:que_app/features/device_settings/widgets/base/settings_list_tile.dart';

class DeviceInfoTile extends StatelessWidget {
  final String deviceName;
  final String firmwareVersion;
  final int batteryLevel;
  final DateTime lastSync;
  final VoidCallback onTap;

  const DeviceInfoTile({
    Key? key,
    required this.deviceName,
    required this.firmwareVersion,
    required this.batteryLevel,
    required this.lastSync,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsListTile(
      title: 'Device Information',
      subtitle: _buildSubtitle(),
      icon: Icons.info_outline,
      iconColor: Colors.blue,
      onTap: onTap,
      trailing: _buildBatteryIndicator(),
    );
  }

  String _buildSubtitle() {
    final now = DateTime.now();
    final difference = now.difference(lastSync);
    String syncText;

    if (difference.inMinutes < 1) {
      syncText = 'Just now';
    } else if (difference.inHours < 1) {
      syncText = '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      syncText = '${difference.inHours}h ago';
    } else {
      syncText = '${difference.inDays}d ago';
    }

    return 'Last synced: $syncText';
  }

  Widget _buildBatteryIndicator() {
    Color batteryColor;
    IconData batteryIcon;

    if (batteryLevel >= 80) {
      batteryColor = Colors.green;
      batteryIcon = Icons.battery_full;
    } else if (batteryLevel >= 50) {
      batteryColor = Colors.orange;
      batteryIcon = Icons.battery_5_bar;
    } else if (batteryLevel >= 20) {
      batteryColor = Colors.orange;
      batteryIcon = Icons.battery_3_bar;
    } else {
      batteryColor = Colors.red;
      batteryIcon = Icons.battery_1_bar;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$batteryLevel%',
          style: TextStyle(
            color: batteryColor,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          batteryIcon,
          color: batteryColor,
          size: 20,
        ),
      ],
    );
  }
}
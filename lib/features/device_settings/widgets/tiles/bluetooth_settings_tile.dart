// lib/features/device_settings/widgets/tiles/bluetooth_settings_tile.dart

import 'package:flutter/material.dart';
import 'package:que_app/features/device_settings/widgets/base/settings_list_tile.dart';

class BluetoothSettingsTile extends StatelessWidget {
  final bool connected;
  final String deviceName;
  final bool enabled;
  final VoidCallback onConnect;
  final VoidCallback? onDisconnect;

  const BluetoothSettingsTile({
    Key? key,
    required this.connected,
    required this.deviceName,
    this.enabled = true,
    required this.onConnect,
    this.onDisconnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsListTile(
      title: connected ? 'Connected to $deviceName' : 'Connect to Device',
      subtitle: connected
          ? 'Tap to disconnect'
          : 'Tap to scan for devices',
      icon: connected
          ? Icons.bluetooth_connected
          : Icons.bluetooth_searching,
      iconColor: connected ? Colors.blue : Colors.grey,
      enabled: enabled,
      onTap: connected ? onDisconnect : onConnect,
      trailing: _buildTrailing(context),
    );
  }

  Widget _buildTrailing(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (connected) ...[
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Connected',
              style: TextStyle(
                color: Colors.green,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
        Icon(
          Icons.chevron_right,
          color: enabled ? Colors.grey : Colors.grey.shade300,
        ),
      ],
    );
  }
}
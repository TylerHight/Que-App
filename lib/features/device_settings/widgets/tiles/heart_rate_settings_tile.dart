// lib/features/device_settings/widgets/tiles/heart_rate_settings_tile.dart

import 'package:flutter/material.dart';
import 'package:que_app/features/device_settings/widgets/base/settings_value_tile.dart';
import 'package:que_app/features/device_settings/dialogs/heart_rate_threshold_dialog.dart';
import 'package:que_app/features/device_settings/utils/settings_helpers.dart';

class HeartRateSettingsTile extends StatelessWidget {
  final int threshold;
  final bool connected;
  final bool enabled;
  final Function(int) onThresholdChanged;

  const HeartRateSettingsTile({
    Key? key,
    required this.threshold,
    required this.connected,
    this.enabled = true,
    required this.onThresholdChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsValueTile(
      title: 'Heart Rate Threshold',
      subtitle: connected ? 'Monitor connected' : 'Monitor not connected',
      value: '$threshold BPM',
      icon: Icons.favorite,
      iconColor: _getHeartColor(threshold),
      enabled: enabled && connected,
      customValue: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            connected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            size: 16,
            color: connected ? Colors.blue : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            '$threshold BPM',
            style: TextStyle(
              color: enabled && connected ? Colors.grey.shade600 : Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
      onTap: () => _showThresholdPicker(context),
    );
  }

  Color _getHeartColor(int value) {
    if (value >= 160) return Colors.red;
    if (value >= 120) return Colors.orange;
    return Colors.green;
  }

  void _showThresholdPicker(BuildContext context) async {
    try {
      final selectedThreshold = await showDialog<int>(
        context: context,
        builder: (context) => HeartRateThresholdDialog(
          title: "Set Heart Rate Threshold",
          currentThreshold: threshold,
          minThreshold: SettingsHelpers.minHeartRate,
          maxThreshold: SettingsHelpers.maxHeartRate,
        ),
      );

      if (selectedThreshold != null) {
        onThresholdChanged(selectedThreshold);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set threshold: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
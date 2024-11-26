// lib/features/device_settings/widgets/tiles/duration_settings_tile.dart

import 'package:flutter/material.dart';
import 'package:que_app/features/device_settings/widgets/base/settings_value_tile.dart';
import 'package:que_app/features/device_settings/utils/settings_helpers.dart';

import '../../dialogs/duration_selection_dialog.dart';

class DurationSettingsTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Duration duration;
  final IconData icon;
  final Color iconColor;
  final bool enabled;
  final Function(Duration) onDurationChanged;

  const DurationSettingsTile({
    Key? key,
    required this.title,
    this.subtitle,
    required this.duration,
    required this.icon,
    required this.iconColor,
    this.enabled = true,
    required this.onDurationChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SettingsValueTile(
      title: title,
      subtitle: subtitle,
      value: SettingsHelpers.formatDuration(duration),
      icon: icon,
      iconColor: iconColor,
      enabled: enabled,
      onTap: () => _showDurationPicker(context),
    );
  }

  void _showDurationPicker(BuildContext context) async {
    try {
      final selectedDuration = await showDialog<Duration>(
        context: context,
        builder: (context) => DurationSelectionDialog(
          title: title,
          initialDuration: duration,
          minDuration: SettingsHelpers.minEmissionDuration,
          maxDuration: SettingsHelpers.maxEmissionDuration,
          icon: icon,
          iconColor: iconColor,
        ),
      );

      if (selectedDuration != null) {
        onDurationChanged(selectedDuration);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set duration: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
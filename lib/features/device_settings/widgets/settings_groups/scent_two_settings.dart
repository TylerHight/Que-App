// lib/features/device_settings/widgets/settings_groups/scent_two_settings.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_bloc.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_event.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_state.dart';
import 'package:que_app/features/device_settings/widgets/base/settings_group.dart';
import 'package:que_app/features/device_settings/widgets/base/settings_switch_tile.dart';
import 'package:que_app/features/device_settings/widgets/base/settings_value_tile.dart';
import 'package:que_app/features/device_settings/dialogs/duration_selection_dialog.dart';
import 'package:que_app/features/device_settings/utils/settings_helpers.dart';

class ScentTwoSettings extends StatelessWidget {
  final bool enabled;

  const ScentTwoSettings({
    Key? key,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceSettingsBloc, DeviceSettingsState>(
      builder: (context, state) {
        final hasPendingDurationChange = state.pendingChanges.containsKey('emission2Duration');
        final hasPendingIntervalChange = state.pendingChanges.containsKey('releaseInterval2');
        final hasPendingPeriodicChange = state.pendingChanges.containsKey('isPeriodicEmission2');

        return SettingsGroup(
          title: 'Scent Two Settings',
          enabled: enabled,
          accentColor: Colors.green.shade500,
          subtitle: !state.isConnected && state.hasPendingChanges ? 'Changes will sync when connected' : null,
          children: [
            SettingsValueTile(
              title: 'Release Duration',
              value: SettingsHelpers.formatDuration(state.emission2Duration),
              icon: Icons.air,
              iconColor: Colors.green.shade500,
              enabled: enabled,
              trailing: !state.isConnected && hasPendingDurationChange
                  ? Icon(
                Icons.sync_disabled,
                size: 16,
                color: Colors.orange[700],
              )
                  : null,
              onTap: () => _showDurationPicker(
                context,
                state.emission2Duration,
              ),
            ),
            SettingsSwitchTile(
              title: 'Periodic Emissions',
              subtitle: state.isPeriodicEmission2Enabled
                  ? 'Releases scent automatically'
                  : 'Manual release only',
              icon: Icons.timer,
              value: state.isPeriodicEmission2Enabled,
              iconColor: Colors.green.shade500,
              enabled: enabled,
              trailing: !state.isConnected && hasPendingPeriodicChange
                  ? Icon(
                Icons.sync_disabled,
                size: 16,
                color: Colors.orange[700],
              )
                  : null,
              onChanged: (value) => context.read<DeviceSettingsBloc>().add(
                UpdatePeriodicEmission2(value),
              ),
            ),
            if (state.isPeriodicEmission2Enabled)
              SettingsValueTile(
                title: 'Release Interval',
                value: SettingsHelpers.formatDuration(state.releaseInterval2),
                icon: Icons.timer_outlined,
                iconColor: Colors.green.shade500,
                enabled: enabled,
                trailing: !state.isConnected && hasPendingIntervalChange
                    ? Icon(
                  Icons.sync_disabled,
                  size: 16,
                  color: Colors.orange[700],
                )
                    : null,
                onTap: () => _showIntervalPicker(
                  context,
                  state.releaseInterval2,
                ),
              ),
          ],
        );
      },
    );
  }
}

  void _showDurationPicker(BuildContext context, Duration current) async {
    try {
      final duration = await showDialog<Duration>(
        context: context,
        builder: (context) => DurationSelectionDialog(
          title: 'Set Release Duration',
          initialDuration: current,
          minDuration: SettingsHelpers.minEmissionDuration,
          maxDuration: SettingsHelpers.maxEmissionDuration,
          icon: Icons.air,
          iconColor: Colors.green.shade500,
        ),
      );

      if (duration != null && context.mounted) {
        context.read<DeviceSettingsBloc>().add(
          UpdateEmission2Duration(duration),
        );
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

  void _showIntervalPicker(BuildContext context, Duration current) async {
    try {
      final duration = await showDialog<Duration>(
        context: context,
        builder: (context) => DurationSelectionDialog(
          title: 'Set Release Interval',
          initialDuration: current,
          minDuration: SettingsHelpers.minInterval,
          maxDuration: SettingsHelpers.maxInterval,
          icon: Icons.timer_outlined,
          iconColor: Colors.green.shade500,
        ),
      );

      if (duration != null && context.mounted) {
        context.read<DeviceSettingsBloc>().add(
          UpdateReleaseInterval2(duration),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set interval: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
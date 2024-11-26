// lib/features/device_settings/widgets/settings_groups/scent_one_settings.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_bloc.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_event.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_state.dart';
import 'package:que_app/features/device_settings/widgets/base/settings_group.dart';
import 'package:que_app/features/device_settings/widgets/base/settings_switch_tile.dart';
import 'package:que_app/features/device_settings/widgets/base/settings_value_tile.dart';
import 'package:que_app/features/device_settings/utils/settings_helpers.dart';

class ScentOneSettings extends StatelessWidget {
  final bool enabled;

  const ScentOneSettings({
    Key? key,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceSettingsBloc, DeviceSettingsState>(
      builder: (context, state) {
        return SettingsGroup(
          title: 'Scent One Settings',
          enabled: enabled,
          accentColor: Colors.lightBlue.shade400,
          children: [
            SettingsValueTile(
              title: 'Release Duration',
              value: SettingsHelpers.formatDuration(state.emission1Duration),
              icon: Icons.air,
              iconColor: Colors.lightBlue.shade400,
              enabled: enabled,
              onTap: () => _showDurationPicker(
                context,
                state.emission1Duration,
              ),
            ),
            SettingsSwitchTile(
              title: 'Periodic Emissions',
              subtitle: state.isPeriodicEmission1Enabled
                  ? 'Releases scent automatically'
                  : 'Manual release only',
              icon: Icons.timer,
              value: state.isPeriodicEmission1Enabled,
              iconColor: Colors.blue,
              enabled: enabled,
              onChanged: (value) => context.read<DeviceSettingsBloc>().add(
                UpdatePeriodicEmission1(value),
              ),
            ),
            if (state.isPeriodicEmission1Enabled)
              SettingsValueTile(
                title: 'Release Interval',
                value: SettingsHelpers.formatDuration(state.releaseInterval1),
                icon: Icons.timer_outlined,
                iconColor: Colors.blue,
                enabled: enabled,
                onTap: () => _showIntervalPicker(
                  context,
                  state.releaseInterval1,
                ),
              ),
          ],
        );
      },
    );
  }

  void _showDurationPicker(BuildContext context, Duration current) async {
    final duration = await showDialog<Duration>(
      context: context,
      builder: (context) => DurationSelectionDialog(
        title: 'Set Release Duration',
        initialDuration: current,
        minDuration: SettingsHelpers.minEmissionDuration,
        maxDuration: SettingsHelpers.maxEmissionDuration,
      ),
    );

    if (duration != null && context.mounted) {
      context.read<DeviceSettingsBloc>().add(
        UpdateEmission1Duration(duration),
      );
    }
  }

  void _showIntervalPicker(BuildContext context, Duration current) async {
    final duration = await showDialog<Duration>(
      context: context,
      builder: (context) => DurationSelectionDialog(
        title: 'Set Release Interval',
        initialDuration: current,
        minDuration: SettingsHelpers.minInterval,
        maxDuration: SettingsHelpers.maxInterval,
      ),
    );

    if (duration != null && context.mounted) {
      context.read<DeviceSettingsBloc>().add(
        UpdateReleaseInterval1(duration),
      );
    }
  }
}
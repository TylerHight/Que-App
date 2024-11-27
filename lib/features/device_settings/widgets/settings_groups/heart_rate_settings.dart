// lib/features/device_settings/widgets/settings_groups/heart_rate_settings.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/device_settings_bloc.dart';
import '../../bloc/device_settings_event.dart';
import '../../bloc/device_settings_state.dart';
import '../../utils/settings_helpers.dart';
import '../base/settings_group.dart';
import '../base/settings_list_tile.dart';
import '../base/settings_value_tile.dart';
import '../../dialogs/heart_rate_threshold_dialog.dart';

class HeartRateSettings extends StatelessWidget {
  final bool enabled;

  const HeartRateSettings({
    Key? key,
    this.enabled = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceSettingsBloc, DeviceSettingsState>(
      builder: (context, state) {
        return SettingsGroup(
          title: 'Heart Rate Settings',
          enabled: enabled,
          children: [
            SettingsListTile(
              title: 'Connect Heart Rate Monitor',
              subtitle: state.isHeartRateMonitorConnected
                  ? 'Connected'
                  : 'Not connected',
              icon: Icons.bluetooth,
              iconColor: state.isHeartRateMonitorConnected
                  ? Colors.blue
                  : Colors.grey,
              enabled: enabled,
              onTap: () => context.read<DeviceSettingsBloc>().add(
                const ConnectToHeartRateMonitor(),
              ),
            ),
            SettingsValueTile(
              title: 'Heart Rate Threshold',
              value: '${state.heartrateThreshold} BPM',
              icon: Icons.favorite,
              iconColor: Colors.red,
              enabled: enabled,
              onTap: () => _showThresholdPicker(
                context,
                state.heartrateThreshold,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showThresholdPicker(BuildContext context, int current) async {
    final threshold = await showDialog<int>(
      context: context,
      builder: (context) => HeartRateThresholdDialog(
        title: 'Set Heart Rate Threshold',
        currentThreshold: current,
        minThreshold: SettingsHelpers.minHeartRate,
        maxThreshold: SettingsHelpers.maxHeartRate,
      ),
    );

    if (threshold != null && context.mounted) {
      context.read<DeviceSettingsBloc>().add(
        UpdateHeartRateThreshold(threshold),
      );
    }
  }
}
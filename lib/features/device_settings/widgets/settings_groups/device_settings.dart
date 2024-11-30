// lib/features/device_settings/widgets/settings_groups/device_settings.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/device_settings_bloc.dart';
import '../../bloc/device_settings_event.dart';
import '../../bloc/device_settings_state.dart';
import '../base/settings_group.dart';
import '../base/settings_list_tile.dart';
import '../../dialogs/device_info_dialog.dart';

class DeviceSettings extends StatelessWidget {
  final VoidCallback? onDeleteRequested;

  const DeviceSettings({
    Key? key,
    this.onDeleteRequested,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceSettingsBloc, DeviceSettingsState>(
      builder: (context, state) {
        return SettingsGroup(
          children: [
            SettingsListTile(
              title: 'Device Information',
              subtitle: 'View device details and status',
              icon: Icons.info_outline,
              iconColor: Colors.blue,
              onTap: () => _showDeviceInfo(context, state),
            ),
            SettingsListTile(
              title: 'Firmware Update',
              subtitle: state.firmwareUpdateAvailable
                  ? 'Update available'
                  : 'Up to date',
              icon: Icons.system_update,
              iconColor: state.firmwareUpdateAvailable
                  ? Colors.orange
                  : Colors.grey,
              onTap: state.firmwareUpdateAvailable
                  ? () => _startFirmwareUpdate(context)
                  : null,
            ),
            SettingsListTile(
              title: 'Factory Reset',
              subtitle: 'Reset device to default settings',
              icon: Icons.restore,
              iconColor: Colors.orange,
              onTap: () => _showFactoryResetConfirmation(context),
            ),
            SettingsListTile(
              title: 'Delete Device',
              icon: Icons.delete_outline,
              iconColor: Colors.red,
              textColor: Colors.red,
              onTap: onDeleteRequested,
            ),
          ],
        );
      },
    );
  }

  void _showDeviceInfo(BuildContext context, DeviceSettingsState state) {
    showDialog(
      context: context,
      builder: (context) => DeviceInfoDialog(
        device: state.device,
      ),
    );
  }

  void _startFirmwareUpdate(BuildContext context) {
    context.read<DeviceSettingsBloc>().add(
      const StartFirmwareUpdate(),
    );
  }

  void _showFactoryResetConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Factory Reset'),
        content: const Text(
          'This will reset all settings to their default values. '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop();
              context.read<DeviceSettingsBloc>().add(
                const FactoryResetDevice(),
              );
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}
// lib/features/device_settings/widgets/settings_groups/device_settings.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import '../../bloc/device_settings_bloc.dart';
import '../../bloc/device_settings_event.dart';
import '../../bloc/device_settings_state.dart';
import '../base/settings_group.dart';
import '../base/settings_list_tile.dart';
import '../../dialogs/device_info_dialog.dart';
import '../../dialogs/delete_device_dialog.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/core/models/device_list.dart';

class DeviceSettings extends StatelessWidget {
  final VoidCallback? onDeleteRequested;

  const DeviceSettings({
    Key? key,
    this.onDeleteRequested,
  }) : super(key: key);

  Future<void> _showDeleteConfirmation(BuildContext context, Device device) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => DeleteDeviceDialog(device: device),
    );

    if (confirmed == true && context.mounted) {
      try {
        final deviceList = Provider.of<DeviceList>(context, listen: false);
        await deviceList.removeDevice(device);

        if (context.mounted) {
          Navigator.of(context).pop(); // Pop settings screen
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to delete device: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

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
              onTap: () => showDialog(
                context: context,
                builder: (context) => DeviceInfoDialog(
                  device: state.device,
                ),
              ),
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
                  ? () => context.read<DeviceSettingsBloc>().add(
                const StartFirmwareUpdate(),
              )
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
              onTap: () => _showDeleteConfirmation(context, state.device),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showFactoryResetConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Factory Reset'),
        content: const Text(
          'This will reset all settings to their default values. '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () {
              Navigator.of(context).pop(true);
              context.read<DeviceSettingsBloc>().add(
                const FactoryResetDevice(),
              );
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      if (context.mounted) {
        context.read<DeviceSettingsBloc>().add(
          const FactoryResetDevice(),
        );
      }
    }
  }
}
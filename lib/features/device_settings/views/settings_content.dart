// lib/features/device_settings/views/settings_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_bloc.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_event.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_state.dart';
import 'package:que_app/features/device_settings/widgets/settings_groups/scent_one_settings.dart';
import 'package:que_app/features/device_settings/widgets/settings_groups/scent_two_settings.dart';
import 'package:que_app/features/device_settings/widgets/settings_groups/heart_rate_settings.dart';
import 'package:que_app/features/device_settings/widgets/settings_groups/device_settings.dart';

class SettingsContent extends StatelessWidget {
  final Device device;

  const SettingsContent({
    Key? key,
    required this.device,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DeviceSettingsBloc, DeviceSettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: _buildAppBar(context, state),
          body: _buildBody(context, state),
          bottomNavigationBar: _buildSyncBar(context, state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, DeviceSettingsState state) {
    final hasUnsyncedChanges = !state.isConnected && state.hasPendingChanges;

    return AppBar(
      title: Column(
        children: [
          Text(
            '${device.deviceName} Settings',
            style: const TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w500,
              fontSize: 20,
            ),
          ),
          if (hasUnsyncedChanges)
            Text(
              'Unsynced Changes',
              style: TextStyle(
                color: Colors.orange[700],
                fontWeight: FontWeight.w400,
                fontSize: 12,
              ),
            ),
        ],
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black87),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          if (hasUnsyncedChanges) {
            _showUnsavedChangesDialog(context);
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      actions: [
        if (state.isLoading)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(BuildContext context, DeviceSettingsState state) {
    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            context.read<DeviceSettingsBloc>().add(InitializeSettings(device));
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildConnectionStatus(state),
                    if (!state.isConnected) _buildOfflineMessage(),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSettingsGroups(context, state),
                    ),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (state.isLoading)
          Positioned.fill(
            child: Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConnectionStatus(DeviceSettingsState state) {
    return Container(
      margin: const EdgeInsets.all(16.0),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        color: state.isConnected ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: state.isConnected ? Colors.green.shade200 : Colors.orange.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            state.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: state.isConnected ? Colors.green.shade700 : Colors.orange.shade700,
            size: 24,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.isConnected ? 'Connected' : 'Disconnected',
                  style: TextStyle(
                    color: state.isConnected ? Colors.green.shade700 : Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                if (!state.isConnected)
                  Text(
                    'Settings can be changed but won\'t sync until connected',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12.0),
          Expanded(
            child: Text(
              'Settings will be saved locally and sync automatically when the device reconnects',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroups(BuildContext context, DeviceSettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Scent Settings'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              ScentOneSettings(
                enabled: true,
                hasPendingChanges: !state.isConnected && state.hasPendingChanges,
              ),
              const Divider(height: 1),
              ScentTwoSettings(
                enabled: true,
                hasPendingChanges: !state.isConnected && state.hasPendingChanges,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24.0),
        _buildSectionHeader('Heart Rate Settings'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: HeartRateSettings(
            enabled: true,
            hasPendingChanges: !state.isConnected && state.hasPendingChanges,
          ),
        ),
        const SizedBox(height: 24.0),
        _buildSectionHeader('Device Settings'),
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey.shade200),
          ),
          child: DeviceSettings(
            onDeleteRequested: () => _showDeleteConfirmation(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildSyncBar(BuildContext context, DeviceSettingsState state) {
    if (!state.hasPendingChanges || state.isConnected) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.sync_disabled,
              color: Colors.orange.shade700,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pending Changes',
                  style: TextStyle(
                    color: Colors.orange.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Text(
                  'Changes will sync when device connects',
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Device?'),
        content: Text(
          'Are you sure you want to delete ${device.deviceName}? '
              'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<DeviceSettingsBloc>().add(DeleteDevice(device));
      Navigator.of(context).pop();
    }
  }

  Future<void> _showUnsavedChangesDialog(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Unsaved Changes'),
        content: const Text(
          'You have pending changes that haven\'t been synced to the device. '
              'These changes will be saved locally and sync when the device connects.\n\n'
              'Do you want to leave anyway?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Stay'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Leave'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      Navigator.of(context).pop();
    }
  }
}
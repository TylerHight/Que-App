// lib/features/device_settings/views/settings_content.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_bloc.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_state.dart';
import 'package:que_app/features/device_settings/widgets/settings_groups/scent_one_settings.dart';
import 'package:que_app/features/device_settings/widgets/settings_groups/scent_two_settings.dart';
import 'package:que_app/features/device_settings/widgets/settings_groups/heart_rate_settings.dart';
import 'package:que_app/features/device_settings/widgets/settings_groups/device_settings.dart';

/// Presentation component that handles the UI layout
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
          appBar: _buildAppBar(context, state),
          body: _buildBody(context, state),
        );
      },
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, DeviceSettingsState state) {
    return AppBar(
      title: Text(
        '${device.deviceName} Settings',
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w400,
        ),
      ),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.black),
      centerTitle: true,
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
            context.read<DeviceSettingsBloc>().add(
              InitializeSettings(device),
            );
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: [
                      _buildConnectionStatus(state),
                      const SizedBox(height: 16.0),
                      _buildSettingsGroups(context, state),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        if (state.isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildConnectionStatus(DeviceSettingsState state) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      decoration: BoxDecoration(
        color: state.isConnected ? Colors.green.shade50 : Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(
          color: state.isConnected ? Colors.green : Colors.orange,
        ),
      ),
      child: Row(
        children: [
          Icon(
            state.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
            color: state.isConnected ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8.0),
          Text(
            state.isConnected ? 'Connected' : 'Disconnected',
            style: TextStyle(
              color: state.isConnected ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroups(BuildContext context, DeviceSettingsState state) {
    return Column(
      children: [
        ScentOneSettings(
          enabled: state.isConnected && !state.isLoading,
        ),
        const SizedBox(height: 8.0),
        ScentTwoSettings(
          enabled: state.isConnected && !state.isLoading,
        ),
        const SizedBox(height: 8.0),
        HeartRateSettings(
          enabled: state.isConnected && !state.isLoading,
        ),
        const SizedBox(height: 8.0),
        DeviceSettings(
          onDeleteRequested: () => _showDeleteConfirmation(context),
        ),
      ],
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
            child: const Text('CANCEL'),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      context.read<DeviceSettingsBloc>().add(DeleteDevice(device));
      Navigator.of(context).pop(); // Close settings screen
    }
  }
}
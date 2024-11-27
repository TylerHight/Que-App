// lib/features/device_settings/views/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:que_app/core/models/device/index.dart';
import 'package:que_app/core/services/ble/ble_service.dart';
import 'package:que_app/core/services/database_service.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_bloc.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_event.dart';
import 'package:que_app/features/device_settings/bloc/device_settings_state.dart';
import 'package:que_app/features/device_settings/repositories/device_settings_repository.dart';
import 'settings_content.dart';

/// Container component that handles dependency injection and state management
class SettingsScreen extends StatelessWidget {
  final Device device;
  final BleService bleService;

  const SettingsScreen({
    Key? key,
    required this.device,
    required this.bleService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final repository = DeviceSettingsRepository(
          databaseService: context.read<DatabaseService>(),
          bleService: bleService,
        );

        return DeviceSettingsBloc(
          bleService: bleService,
          device: device,
          repository: repository,
        )..add(InitializeSettings(device));
      },
      child: BlocListener<DeviceSettingsBloc, DeviceSettingsState>(
        listener: (context, state) {
          if (state.error != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error!),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SettingsContent(device: device),
      ),
    );
  }
}
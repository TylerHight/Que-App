// lib/features/device_settings/bloc/mixins/device_connection_mixin.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/settings_service.dart';
import '../device_settings_event.dart';
import '../device_settings_state.dart';

mixin DeviceConnectionMixin on Bloc<DeviceSettingsEvent, DeviceSettingsState> {
  SettingsService get _settingsService;

  void registerConnectionHandlers() {
    on<ConnectToDevice>(_onConnectToDevice);
    on<DeleteDevice>(_onDeleteDevice);
  }

  Future<void> _onConnectToDevice(
      ConnectToDevice event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));

      final updatedDevice = state.device.copyWith(
        isBleConnected: true,
        bluetoothDevice: event.device,
      );

      emit(DeviceSettingsState.success(state.copyWith(device: updatedDevice)));

      // If we have pending changes, try to sync them
      if (state.hasPendingChanges) {
        add(const SaveSettings());
      }
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to connect to device: $e'));
    }
  }

  Future<void> _onDeleteDevice(
      DeleteDevice event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));

      // First try to disconnect if connected
      if (state.isConnected) {
        await _settingsService.bleService.disconnectFromDevice();
      }

      // Then delete the device
      await _settingsService.deleteDevice(event.device);

      // Clear any pending changes since the device is being deleted
      emit(DeviceSettingsState.success(state.copyWith(
        pendingChanges: {},
      )));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to delete device: $e'));
    }
  }

  // Helper method to handle disconnection
  Future<void> disconnectDevice(Emitter<DeviceSettingsState> emit) async {
    try {
      if (state.isConnected) {
        await _settingsService.bleService.disconnectFromDevice();

        final updatedDevice = state.device.copyWith(
          isBleConnected: false,
          bluetoothDevice: null,
        );

        emit(DeviceSettingsState.success(state.copyWith(device: updatedDevice)));
      }
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to disconnect device: $e'));
    }
  }
}
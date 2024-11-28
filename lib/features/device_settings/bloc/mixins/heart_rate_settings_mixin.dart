// lib/features/device_settings/bloc/mixins/heart_rate_settings_mixin.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/settings_service.dart';
import '../device_settings_bloc.dart';
import '../device_settings_event.dart';
import '../device_settings_state.dart';

mixin HeartRateSettingsMixin on Bloc<DeviceSettingsEvent, DeviceSettingsState> {
  SettingsService get _settingsService;

  void registerHeartRateHandlers() {
    on<UpdateHeartRateThreshold>(_onUpdateHeartRateThreshold);
    on<ConnectToHeartRateMonitor>(_onConnectToHeartRateMonitor);
  }

  Future<void> _onUpdateHeartRateThreshold(
      UpdateHeartRateThreshold event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      final updatedDevice = state.device.copyWith(
        heartrateThreshold: event.threshold,
      );

      Map<String, dynamic> pendingChanges = Map.from(state.pendingChanges);
      pendingChanges['heartRateThreshold'] = event.threshold;

      if (state.isConnected) {
        emit(DeviceSettingsState.loading(state));
        await _settingsService.updateHeartRateThreshold(state.device, event.threshold);
        pendingChanges.remove('heartRateThreshold');
      }

      emit(DeviceSettingsState.success(state.copyWith(
        device: updatedDevice,
        pendingChanges: pendingChanges,
      )));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update heart rate threshold: $e'));
    }
  }

  Future<void> _onConnectToHeartRateMonitor(
      ConnectToHeartRateMonitor event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await _settingsService.connectToHeartRateMonitor(state.device);

      // Note: You might want to update the device state here with heart rate monitor connection status
      // depending on your implementation

      emit(DeviceSettingsState.success(state));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to connect to heart rate monitor: $e'));
    }
  }
}
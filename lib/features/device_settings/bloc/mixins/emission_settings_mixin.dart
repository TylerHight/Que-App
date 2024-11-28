// lib/features/device_settings/bloc/mixins/emission_settings_mixin.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/settings_service.dart';
import '../device_settings_bloc.dart';
import '../device_settings_event.dart';
import '../device_settings_state.dart';

mixin EmissionSettingsMixin on Bloc<DeviceSettingsEvent, DeviceSettingsState> {
  SettingsService get _settingsService;

  void registerEmissionHandlers() {
    on<UpdateEmission1Duration>(_onUpdateEmission1Duration);
    on<UpdateEmission2Duration>(_onUpdateEmission2Duration);
  }

  Future<void> _onUpdateEmission1Duration(
      UpdateEmission1Duration event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      final updatedDevice = state.device.copyWith(
        emission1Duration: event.duration,
      );

      Map<String, dynamic> pendingChanges = Map.from(state.pendingChanges);
      pendingChanges['emission1Duration'] = event.duration;

      if (state.isConnected) {
        emit(DeviceSettingsState.loading(state));
        await _settingsService.updateEmission1Duration(state.device, event.duration);
        pendingChanges.remove('emission1Duration');
      }

      emit(DeviceSettingsState.success(state.copyWith(
        device: updatedDevice,
        pendingChanges: pendingChanges,
      )));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update emission 1 duration: $e'));
    }
  }

  Future<void> _onUpdateEmission2Duration(
      UpdateEmission2Duration event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      final updatedDevice = state.device.copyWith(
        emission2Duration: event.duration,
      );

      Map<String, dynamic> pendingChanges = Map.from(state.pendingChanges);
      pendingChanges['emission2Duration'] = event.duration;

      if (state.isConnected) {
        emit(DeviceSettingsState.loading(state));
        await _settingsService.updateEmission2Duration(state.device, event.duration);
        pendingChanges.remove('emission2Duration');
      }

      emit(DeviceSettingsState.success(state.copyWith(
        device: updatedDevice,
        pendingChanges: pendingChanges,
      )));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update emission 2 duration: $e'));
    }
  }
}
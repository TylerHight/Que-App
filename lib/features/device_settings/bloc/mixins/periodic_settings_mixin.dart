// lib/features/device_settings/bloc/mixins/periodic_settings_mixin.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/settings_service.dart';
import '../device_settings_bloc.dart';
import '../device_settings_event.dart';
import '../device_settings_state.dart';

mixin PeriodicSettingsMixin on Bloc<DeviceSettingsEvent, DeviceSettingsState> {
  SettingsService get _settingsService;

  void registerPeriodicHandlers() {
    on<UpdatePeriodicEmission1>(_onUpdatePeriodicEmission1);
    on<UpdatePeriodicEmission2>(_onUpdatePeriodicEmission2);
    on<UpdateReleaseInterval1>(_onUpdateReleaseInterval1);
    on<UpdateReleaseInterval2>(_onUpdateReleaseInterval2);
  }

  Future<void> _onUpdatePeriodicEmission1(
      UpdatePeriodicEmission1 event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      final updatedDevice = state.device.copyWith(
        isPeriodicEmissionEnabled: event.enabled,
      );

      Map<String, dynamic> pendingChanges = Map.from(state.pendingChanges);
      pendingChanges['isPeriodicEmission1'] = event.enabled;

      if (state.isConnected) {
        emit(DeviceSettingsState.loading(state));
        await _settingsService.updatePeriodicEmission1(state.device, event.enabled);
        pendingChanges.remove('isPeriodicEmission1');
      }

      emit(DeviceSettingsState.success(state.copyWith(
        device: updatedDevice,
        pendingChanges: pendingChanges,
      )));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update periodic emission 1: $e'));
    }
  }

  Future<void> _onUpdatePeriodicEmission2(
      UpdatePeriodicEmission2 event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      final updatedDevice = state.device.copyWith(
        isPeriodicEmissionEnabled2: event.enabled,
      );

      Map<String, dynamic> pendingChanges = Map.from(state.pendingChanges);
      pendingChanges['isPeriodicEmission2'] = event.enabled;

      if (state.isConnected) {
        emit(DeviceSettingsState.loading(state));
        await _settingsService.updatePeriodicEmission2(state.device, event.enabled);
        pendingChanges.remove('isPeriodicEmission2');
      }

      emit(DeviceSettingsState.success(state.copyWith(
        device: updatedDevice,
        pendingChanges: pendingChanges,
      )));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update periodic emission 2: $e'));
    }
  }

  Future<void> _onUpdateReleaseInterval1(
      UpdateReleaseInterval1 event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      final updatedDevice = state.device.copyWith(
        releaseInterval1: event.interval,
      );

      Map<String, dynamic> pendingChanges = Map.from(state.pendingChanges);
      pendingChanges['releaseInterval1'] = event.interval;

      if (state.isConnected) {
        emit(DeviceSettingsState.loading(state));
        await _settingsService.updateReleaseInterval1(state.device, event.interval);
        pendingChanges.remove('releaseInterval1');
      }

      emit(DeviceSettingsState.success(state.copyWith(
        device: updatedDevice,
        pendingChanges: pendingChanges,
      )));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update release interval 1: $e'));
    }
  }

  Future<void> _onUpdateReleaseInterval2(
      UpdateReleaseInterval2 event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      final updatedDevice = state.device.copyWith(
        releaseInterval2: event.interval,
      );

      Map<String, dynamic> pendingChanges = Map.from(state.pendingChanges);
      pendingChanges['releaseInterval2'] = event.interval;

      if (state.isConnected) {
        emit(DeviceSettingsState.loading(state));
        await _settingsService.updateReleaseInterval2(state.device, event.interval);
        pendingChanges.remove('releaseInterval2');
      }

      emit(DeviceSettingsState.success(state.copyWith(
        device: updatedDevice,
        pendingChanges: pendingChanges,
      )));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update release interval 2: $e'));
    }
  }
}
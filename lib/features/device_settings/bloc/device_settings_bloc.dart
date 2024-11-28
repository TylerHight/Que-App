// lib/features/device_settings/bloc/device_settings_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/models/device/index.dart';
import '../../../core/services/ble/ble_service.dart';
import '../services/settings_service.dart';
import '../repositories/device_settings_repository.dart';
import 'device_settings_event.dart';
import 'device_settings_state.dart';
import 'mixins/emission_settings_mixin.dart';
import 'mixins/periodic_settings_mixin.dart';
import 'mixins/heart_rate_settings_mixin.dart';
import 'mixins/device_connection_mixin.dart';

class DeviceSettingsBloc extends Bloc<DeviceSettingsEvent, DeviceSettingsState>
    with
        EmissionSettingsMixin,
        PeriodicSettingsMixin,
        HeartRateSettingsMixin,
        DeviceConnectionMixin {

  final BleService bleService;
  final SettingsService _settingsService;
  final DeviceSettingsRepository _repository;

  DeviceSettingsBloc({
    required this.bleService,
    required Device device,
    required DeviceSettingsRepository repository,
  }) : _settingsService = SettingsService(
    bleService: bleService,
    repository: repository,
  ),
        _repository = repository,
        super(DeviceSettingsState.initial(device)) {
    _registerEventHandlers();
    _setupConnectionListener();
    _loadInitialState();
  }

  // New method to load saved state including pending changes
  Future<void> _loadInitialState() async {
    add(InitializeSettings(state.device));
  }

  void _registerEventHandlers() {
    on<InitializeSettings>(_onInitializeSettings);
    on<SaveSettings>(_onSaveSettings);
    on<StartFirmwareUpdate>(_onStartFirmwareUpdate);
    on<FactoryResetDevice>(_onFactoryReset);
    on<HandleError>(_onHandleError);

    registerEmissionHandlers();
    registerPeriodicHandlers();
    registerHeartRateHandlers();
    registerConnectionHandlers();
  }

  void _setupConnectionListener() {
    bleService.connectionStatusStream.listen((isConnected) {
      if (isConnected && state.hasPendingChanges) {
        add(const SaveSettings());
      }
    });
  }

  Future<void> _onInitializeSettings(
      InitializeSettings event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));

      // Load settings and pending changes from repository
      final settings = await _repository.getDeviceSettings(event.device.id);

      final updatedDevice = event.device.copyWith(
        emission1Duration: settings.scentOne.emissionDuration,
        emission2Duration: settings.scentTwo.emissionDuration,
        releaseInterval1: settings.scentOne.releaseInterval,
        releaseInterval2: settings.scentTwo.releaseInterval,
        isPeriodicEmissionEnabled: settings.scentOne.isPeriodicEnabled,
        isPeriodicEmissionEnabled2: settings.scentTwo.isPeriodicEnabled,
        heartrateThreshold: settings.heartRate.threshold,
      );

      // Load stored pending changes
      Map<String, dynamic> pendingChanges = settings.pendingChanges;

      emit(DeviceSettingsState.success(state.copyWith(
        device: updatedDevice,
        pendingChanges: pendingChanges,
      )));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to initialize settings: $e'));
    }
  }

  Future<void> _onSaveSettings(
      SaveSettings event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    if (!state.isConnected || state.pendingChanges.isEmpty) return;

    try {
      emit(DeviceSettingsState.loading(state));
      await _syncPendingChanges();

      // Clear pending changes in repository after successful sync
      await _repository.updatePendingChanges(state.device.id, {});

      emit(DeviceSettingsState.success(state.copyWith(pendingChanges: {})));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to sync settings: $e'));
    }
  }

  Future<void> _syncPendingChanges() async {
    for (final entry in state.pendingChanges.entries) {
      switch (entry.key) {
        case 'emission1Duration':
          await _settingsService.updateEmission1Duration(state.device, entry.value as Duration);
          break;
        case 'emission2Duration':
          await _settingsService.updateEmission2Duration(state.device, entry.value as Duration);
          break;
        case 'releaseInterval1':
          await _settingsService.updateReleaseInterval1(state.device, entry.value as Duration);
          break;
        case 'releaseInterval2':
          await _settingsService.updateReleaseInterval2(state.device, entry.value as Duration);
          break;
        case 'isPeriodicEmission1':
          await _settingsService.updatePeriodicEmission1(state.device, entry.value as bool);
          break;
        case 'isPeriodicEmission2':
          await _settingsService.updatePeriodicEmission2(state.device, entry.value as bool);
          break;
        case 'heartRateThreshold':
          await _settingsService.updateHeartRateThreshold(state.device, entry.value as int);
          break;
      }
    }
  }

  // Helper method to persist pending changes
  Future<void> _savePendingChanges(Map<String, dynamic> changes) async {
    try {
      await _repository.updatePendingChanges(state.device.id, changes);
    } catch (e) {
      add(HandleError('Failed to save pending changes: $e'));
    }
  }

  Future<void> _onStartFirmwareUpdate(
      StartFirmwareUpdate event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    emit(DeviceSettingsState.failure(state, 'Firmware update not implemented'));
  }

  Future<void> _onFactoryReset(
      FactoryResetDevice event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    emit(DeviceSettingsState.failure(state, 'Factory reset not implemented'));
  }

  void _onHandleError(
      HandleError event,
      Emitter<DeviceSettingsState> emit,
      ) {
    emit(DeviceSettingsState.failure(state, event.error));
  }

  @override
  Future<void> close() async {
    try {
      if (state.isConnected) {
        await bleService.disconnectFromDevice();
      }
      // Save any pending changes before closing
      if (state.hasPendingChanges) {
        await _savePendingChanges(state.pendingChanges);
      }
    } catch (e) {
      print('Error during BLoC closure: $e');
    }
    return super.close();
  }
}
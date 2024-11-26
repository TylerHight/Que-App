// lib/features/device_settings/bloc/device_settings_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../core/models/device/index.dart';
import '../../../core/services/ble_service.dart';
import '../services/settings_service.dart';
import '../repositories/device_settings_repository.dart';
import 'device_settings_event.dart';
import 'device_settings_state.dart';

class DeviceSettingsBloc extends Bloc<DeviceSettingsEvent, DeviceSettingsState> {
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
    on<InitializeSettings>(_onInitializeSettings);
    on<UpdateEmission1Duration>(_onUpdateEmission1Duration);
    on<UpdateEmission2Duration>(_onUpdateEmission2Duration);
    on<UpdateReleaseInterval1>(_onUpdateReleaseInterval1);
    on<UpdateReleaseInterval2>(_onUpdateReleaseInterval2);
    on<UpdatePeriodicEmission1>(_onUpdatePeriodicEmission1);
    on<UpdatePeriodicEmission2>(_onUpdatePeriodicEmission2);
    on<UpdateHeartRateThreshold>(_onUpdateHeartRateThreshold);
    on<ConnectToDevice>(_onConnectToDevice);
    on<ConnectToHeartRateMonitor>(_onConnectToHeartRateMonitor);
    on<DeleteDevice>(_onDeleteDevice);
    on<SaveSettings>(_onSaveSettings);
    on<StartFirmwareUpdate>(_onStartFirmwareUpdate);
    on<FactoryResetDevice>(_onFactoryReset);
    on<HandleError>(_onHandleError);
  }

  Future<void> _onInitializeSettings(
      InitializeSettings event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));

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

      emit(DeviceSettingsState.success(state.copyWith(device: updatedDevice)));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to initialize settings: $e'));
    }
  }

  Future<void> _onUpdateEmission1Duration(
      UpdateEmission1Duration event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await _settingsService.updateEmission1Duration(state.device, event.duration);

      final updatedDevice = state.device.copyWith(
        emission1Duration: event.duration,
      );

      emit(DeviceSettingsState.success(state.copyWith(device: updatedDevice)));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update emission 1 duration: $e'));
    }
  }

  Future<void> _onUpdateEmission2Duration(
      UpdateEmission2Duration event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await _settingsService.updateEmission2Duration(state.device, event.duration);

      final updatedDevice = state.device.copyWith(
        emission2Duration: event.duration,
      );

      emit(DeviceSettingsState.success(state.copyWith(device: updatedDevice)));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update emission 2 duration: $e'));
    }
  }

  Future<void> _onUpdateReleaseInterval1(
      UpdateReleaseInterval1 event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await _settingsService.updateReleaseInterval1(state.device, event.interval);

      final updatedDevice = state.device.copyWith(
        releaseInterval1: event.interval,
      );

      emit(DeviceSettingsState.success(state.copyWith(device: updatedDevice)));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update release interval 1: $e'));
    }
  }

  Future<void> _onUpdateReleaseInterval2(
      UpdateReleaseInterval2 event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await _settingsService.updateReleaseInterval2(state.device, event.interval);

      final updatedDevice = state.device.copyWith(
        releaseInterval2: event.interval,
      );

      emit(DeviceSettingsState.success(state.copyWith(device: updatedDevice)));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update release interval 2: $e'));
    }
  }

  Future<void> _onUpdatePeriodicEmission1(
      UpdatePeriodicEmission1 event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await _settingsService.updatePeriodicEmission1(state.device, event.enabled);

      final updatedDevice = state.device.copyWith(
        isPeriodicEmissionEnabled: event.enabled,
      );

      emit(DeviceSettingsState.success(state.copyWith(device: updatedDevice)));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update periodic emission 1: $e'));
    }
  }

  Future<void> _onUpdatePeriodicEmission2(
      UpdatePeriodicEmission2 event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await _settingsService.updatePeriodicEmission2(state.device, event.enabled);

      final updatedDevice = state.device.copyWith(
        isPeriodicEmissionEnabled2: event.enabled,
      );

      emit(DeviceSettingsState.success(state.copyWith(device: updatedDevice)));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update periodic emission 2: $e'));
    }
  }

  Future<void> _onUpdateHeartRateThreshold(
      UpdateHeartRateThreshold event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await _settingsService.updateHeartRateThreshold(state.device, event.threshold);

      final updatedDevice = state.device.copyWith(
        heartrateThreshold: event.threshold,
      );

      emit(DeviceSettingsState.success(state.copyWith(device: updatedDevice)));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to update heart rate threshold: $e'));
    }
  }

  Future<void> _onConnectToDevice(
      ConnectToDevice event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await bleService.connectToDevice(event.device);

      final updatedDevice = state.device.copyWith(
        isBleConnected: true,
        bluetoothDevice: event.device,
      );

      emit(DeviceSettingsState.success(state.copyWith(device: updatedDevice)));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to connect to device: $e'));
    }
  }

  Future<void> _onConnectToHeartRateMonitor(
      ConnectToHeartRateMonitor event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await _settingsService.connectToHeartRateMonitor(state.device);
      emit(DeviceSettingsState.success(state));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to connect to heart rate monitor: $e'));
    }
  }

  Future<void> _onDeleteDevice(
      DeleteDevice event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await _settingsService.deleteDevice(event.device);
      emit(DeviceSettingsState.success(state));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to delete device: $e'));
    }
  }

  Future<void> _onSaveSettings(
      SaveSettings event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    try {
      emit(DeviceSettingsState.loading(state));
      await _settingsService.saveSettings(state.device);
      emit(DeviceSettingsState.success(state));
    } catch (e) {
      emit(DeviceSettingsState.failure(state, 'Failed to save settings: $e'));
    }
  }

  Future<void> _onStartFirmwareUpdate(
      StartFirmwareUpdate event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    // TODO: Implement firmware update logic
    emit(DeviceSettingsState.failure(state, 'Firmware update not implemented'));
  }

  Future<void> _onFactoryReset(
      FactoryResetDevice event,
      Emitter<DeviceSettingsState> emit,
      ) async {
    // TODO: Implement factory reset logic
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
    } catch (e) {
      // Log error but don't prevent closure
      print('Error during BLoC closure: $e');
    }
    return super.close();
  }
}
// lib/features/device_settings/bloc/device_settings_state.dart
import 'package:equatable/equatable.dart';
import '../../../core/models/device/index.dart';

enum DeviceSettingsStatus {
  initial,
  loading,
  success,
  failure
}

class DeviceSettingsState extends Equatable {
  final Device device;
  final DeviceSettingsStatus status;
  final String? errorMessage;

  const DeviceSettingsState({
    required this.device,
    this.status = DeviceSettingsStatus.initial,
    this.errorMessage,
  });

  // Device state getters
  Duration get emission1Duration => device.emission1Duration;
  Duration get emission2Duration => device.emission2Duration;
  Duration get releaseInterval1 => device.releaseInterval1;
  Duration get releaseInterval2 => device.releaseInterval2;
  bool get isPeriodicEmission1Enabled => device.isPeriodicEmissionEnabled;
  bool get isPeriodicEmission2Enabled => device.isPeriodicEmissionEnabled2;
  int get heartrateThreshold => device.heartrateThreshold;
  bool get isConnected => device.isBleConnected;
  bool get isHeartRateMonitorConnected => false; // Added for UI compatibility
  bool get firmwareUpdateAvailable => false; // Added for UI compatibility

  // Helper getters for UI
  bool get isLoading => status == DeviceSettingsStatus.loading;
  bool get hasError => status == DeviceSettingsStatus.failure;
  bool get isSuccess => status == DeviceSettingsStatus.success;
  String? get error => errorMessage; // Added for backward compatibility

  DeviceSettingsState copyWith({
    Device? device,
    DeviceSettingsStatus? status,
    String? errorMessage,
    bool? clearError, // Added to explicitly clear error
  }) {
    return DeviceSettingsState(
      device: device ?? this.device,
      status: status ?? this.status,
      errorMessage: clearError == true ? null : (errorMessage ?? this.errorMessage),
    );
  }

  // Factory constructors for common state transitions
  factory DeviceSettingsState.initial(Device device) {
    return DeviceSettingsState(device: device);
  }

  factory DeviceSettingsState.loading(DeviceSettingsState current) {
    return current.copyWith(
      status: DeviceSettingsStatus.loading,
      clearError: true,
    );
  }

  factory DeviceSettingsState.success(DeviceSettingsState current) {
    return current.copyWith(
      status: DeviceSettingsStatus.success,
      clearError: true,
    );
  }

  factory DeviceSettingsState.failure(DeviceSettingsState current, String error) {
    return current.copyWith(
      status: DeviceSettingsStatus.failure,
      errorMessage: error,
    );
  }

  @override
  List<Object?> get props => [
    device,
    status,
    errorMessage,
  ];

  @override
  String toString() {
    return '''DeviceSettingsState { 
      status: $status, 
      emission1Duration: $emission1Duration,
      emission2Duration: $emission2Duration,
      releaseInterval1: $releaseInterval1,
      releaseInterval2: $releaseInterval2,
      isPeriodicEmission1Enabled: $isPeriodicEmission1Enabled,
      isPeriodicEmission2Enabled: $isPeriodicEmission2Enabled,
      heartrateThreshold: $heartrateThreshold,
      isConnected: $isConnected,
      hasError: $hasError,
      errorMessage: $errorMessage
    }''';
  }
}
// lib/features/device_settings/bloc/device_settings_event.dart
import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../core/models/device/index.dart';

abstract class DeviceSettingsEvent extends Equatable {
  const DeviceSettingsEvent();

  @override
  List<Object?> get props => [];
}

class InitializeSettings extends DeviceSettingsEvent {
  final Device device;
  const InitializeSettings(this.device);

  @override
  List<Object> get props => [device];
}

class UpdateEmission1Duration extends DeviceSettingsEvent {
  final Duration duration;
  const UpdateEmission1Duration(this.duration);

  @override
  List<Object> get props => [duration];
}

class UpdateEmission2Duration extends DeviceSettingsEvent {
  final Duration duration;
  const UpdateEmission2Duration(this.duration);

  @override
  List<Object> get props => [duration];
}

class UpdateReleaseInterval1 extends DeviceSettingsEvent {
  final Duration interval;
  const UpdateReleaseInterval1(this.interval);

  @override
  List<Object> get props => [interval];
}

class UpdateReleaseInterval2 extends DeviceSettingsEvent {
  final Duration interval;
  const UpdateReleaseInterval2(this.interval);

  @override
  List<Object> get props => [interval];
}

class UpdatePeriodicEmission1 extends DeviceSettingsEvent {
  final bool enabled;
  const UpdatePeriodicEmission1(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class UpdatePeriodicEmission2 extends DeviceSettingsEvent {
  final bool enabled;
  const UpdatePeriodicEmission2(this.enabled);

  @override
  List<Object> get props => [enabled];
}

class UpdateHeartRateThreshold extends DeviceSettingsEvent {
  final int threshold;
  const UpdateHeartRateThreshold(this.threshold);

  @override
  List<Object> get props => [threshold];
}

class ConnectToDevice extends DeviceSettingsEvent {
  final BluetoothDevice device;
  const ConnectToDevice(this.device);

  @override
  List<Object> get props => [device];
}

class ConnectToHeartRateMonitor extends DeviceSettingsEvent {
  const ConnectToHeartRateMonitor();
}

class DeleteDevice extends DeviceSettingsEvent {
  final Device device;
  const DeleteDevice(this.device);

  @override
  List<Object> get props => [device];
}

class SaveSettings extends DeviceSettingsEvent {
  const SaveSettings();
}

// Additional events to handle firmware updates and factory reset
class StartFirmwareUpdate extends DeviceSettingsEvent {
  const StartFirmwareUpdate();
}

class FactoryResetDevice extends DeviceSettingsEvent {
  const FactoryResetDevice();
}

// Event to handle any errors that occur
class HandleError extends DeviceSettingsEvent {
  final String error;
  const HandleError(this.error);

  @override
  List<Object> get props => [error];
}
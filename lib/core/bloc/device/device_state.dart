// lib/core/bloc/device/device_state.dart

import 'package:equatable/equatable.dart';
import '../../../core/models/device/device.dart';

abstract class DeviceState extends Equatable {
  const DeviceState();

  @override
  List<Object> get props => [];
}

class DeviceInitial extends DeviceState {}

class DeviceLoading extends DeviceState {}

class DevicesLoaded extends DeviceState {
  final List<Device> devices;

  const DevicesLoaded({required this.devices});

  @override
  List<Object> get props => [devices];

  DevicesLoaded copyWith({
    List<Device>? devices,
  }) {
    return DevicesLoaded(
      devices: devices ?? this.devices,
    );
  }
}

class DeviceError extends DeviceState {
  final String message;

  const DeviceError({required this.message});

  @override
  List<Object> get props => [message];
}

class DeviceConnectionInProgress extends DeviceState {}

class DeviceConnected extends DeviceState {
  final Device device;

  const DeviceConnected({required this.device});

  @override
  List<Object> get props => [device];
}

class DeviceDisconnected extends DeviceState {
  final Device device;

  const DeviceDisconnected({required this.device});

  @override
  List<Object> get props => [device];
}
// lib/features/device_control/bloc/device_control_state.dart

import 'package:equatable/equatable.dart';
import 'package:que_app/core/models/device/device.dart';

abstract class DeviceControlState extends Equatable {
  const DeviceControlState();

  @override
  List<Object> get props => [];
}

class DeviceControlInitial extends DeviceControlState {}

class DeviceControlLoading extends DeviceControlState {}

class DeviceControlLoaded extends DeviceControlState {
  final List<Device> devices;
  final bool isScanning;
  final String? scanError;

  const DeviceControlLoaded({
    required this.devices,
    this.isScanning = false,
    this.scanError,
  });

  @override
  List<Object> get props => [devices, isScanning];

  DeviceControlLoaded copyWith({
    List<Device>? devices,
    bool? isScanning,
    String? scanError,
  }) {
    return DeviceControlLoaded(
      devices: devices ?? this.devices,
      isScanning: isScanning ?? this.isScanning,
      scanError: scanError ?? this.scanError,
    );
  }
}

class DeviceControlError extends DeviceControlState {
  final String message;

  const DeviceControlError(this.message);

  @override
  List<Object> get props => [message];
}
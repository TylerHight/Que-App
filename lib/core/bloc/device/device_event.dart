// lib/core/bloc/device/device_event.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../../core/models/device/device.dart';

abstract class DeviceEvent extends Equatable {
  const DeviceEvent();

  @override
  List<Object?> get props => [];
}

class LoadDevices extends DeviceEvent {}

class AddDevice extends DeviceEvent {
  final String name;
  final BluetoothDevice? bluetoothDevice;

  const AddDevice({
    required this.name,
    this.bluetoothDevice,
  });

  @override
  List<Object?> get props => [name, bluetoothDevice];
}

class RemoveDevice extends DeviceEvent {
  final Device device;

  const RemoveDevice(this.device);

  @override
  List<Object> get props => [device];
}

class ConnectToDevice extends DeviceEvent {
  final Device device;

  const ConnectToDevice(this.device);

  @override
  List<Object> get props => [device];
}

class DisconnectDevice extends DeviceEvent {
  final Device device;

  const DisconnectDevice(this.device);

  @override
  List<Object> get props => [device];
}

class UpdateDevice extends DeviceEvent {
  final Device device;

  const UpdateDevice(this.device);

  @override
  List<Object> get props => [device];
}

class RetryConnection extends DeviceEvent {
  final Device device;

  const RetryConnection(this.device);

  @override
  List<Object> get props => [device];
}
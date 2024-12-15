// lib/features/device_control/bloc/device_control_event.dart

import 'package:equatable/equatable.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:que_app/core/models/device/device.dart';

abstract class DeviceControlEvent extends Equatable {
  const DeviceControlEvent();

  @override
  List<Object?> get props => [];
}

class LoadDevices extends DeviceControlEvent {}

class StartDeviceScan extends DeviceControlEvent {}

class StopDeviceScan extends DeviceControlEvent {}

class AddDevice extends DeviceControlEvent {
  final String name;
  final BluetoothDevice? bluetoothDevice;

  const AddDevice({
    required this.name,
    this.bluetoothDevice,
  });

  @override
  List<Object?> get props => [name, bluetoothDevice];
}

class RemoveDevice extends DeviceControlEvent {
  final Device device;

  const RemoveDevice(this.device);

  @override
  List<Object> get props => [device];
}

class ConnectToDevice extends DeviceControlEvent {
  final Device device;

  const ConnectToDevice(this.device);

  @override
  List<Object> get props => [device];
}

class DisconnectDevice extends DeviceControlEvent {
  final Device device;

  const DisconnectDevice(this.device);

  @override
  List<Object> get props => [device];
}

class UpdateDeviceConnection extends DeviceControlEvent {
  final Device device;
  final bool isConnected;

  const UpdateDeviceConnection({
    required this.device,
    required this.isConnected,
  });

  @override
  List<Object> get props => [device, isConnected];
}

class SendDeviceCommand extends DeviceControlEvent {
  final Device device;
  final int command;

  const SendDeviceCommand({
    required this.device,
    required this.command,
  });

  @override
  List<Object> get props => [device, command];
}
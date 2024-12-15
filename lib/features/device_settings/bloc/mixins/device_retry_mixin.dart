// lib/features/device_settings/bloc/mixins/device_retry_mixin.dart

import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/models/device/device.dart';
import '../device_settings_event.dart';
import '../device_settings_state.dart';

mixin DeviceRetryMixin on Bloc<DeviceSettingsEvent, DeviceSettingsState> {
  static const int maxRetries = 3;
  static const Duration retryDelay = Duration(seconds: 2);
  static const Duration autoReconnectDelay = Duration(seconds: 30);

  int _connectionRetries = 0;
  Timer? _reconnectTimer;

  Future<void> handleConnectionFailure(
      Device device,
      Emitter<DeviceSettingsState> emit,
      ) async {
    _connectionRetries++;

    if (_connectionRetries < maxRetries) {
      emit(DeviceSettingsState.failure(
        state,
        'Connection attempt $_connectionRetries failed, retrying...',
      ));

      await Future.delayed(retryDelay);
      add(ConnectToDevice(device.bluetoothDevice!));
    } else {
      emit(DeviceSettingsState.failure(
        state,
        'Failed to connect after $maxRetries attempts',
      ));
      startAutoReconnectTimer(device);
    }
  }

  void startAutoReconnectTimer(Device device) {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(autoReconnectDelay, (timer) {
      if (!device.isConnected && device.bluetoothDevice != null) {
        _connectionRetries = 0;
        add(ConnectToDevice(device.bluetoothDevice!));
      } else {
        timer.cancel();
      }
    });
  }

  void resetRetries() {
    _connectionRetries = 0;
  }

  bool get canRetry => _connectionRetries < maxRetries;

  @override
  Future<void> close() {
    _reconnectTimer?.cancel();
    return super.close();
  }
}
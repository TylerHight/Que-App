// lib/core/services/ble/managers/keep_alive_manager.dart
import 'dart:async';
import '../ble_types.dart';

class BleKeepAliveManager {
  Timer? _keepAliveTimer;
  final Duration interval;
  final KeepAliveFailedCallback onKeepAliveFailed;

  BleKeepAliveManager({
    required this.interval,
    required this.onKeepAliveFailed,
  });

  void startKeepAlive(Future<void> Function() keepAliveAction) {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(interval, (_) async {
      try {
        await keepAliveAction();
      } catch (e) {
        onKeepAliveFailed();
      }
    });
  }

  void stopKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = null;
  }

  void dispose() {
    stopKeepAlive();
  }
}
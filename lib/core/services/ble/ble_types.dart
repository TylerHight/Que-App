// lib/core/services/ble/ble_types.dart
enum BleConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting
}

class BleException implements Exception {
  final String message;
  BleException(this.message);

  @override
  String toString() => message;
}

typedef ErrorCallback = void Function(String message);
typedef StateChangeCallback = void Function(BleConnectionState state);
typedef KeepAliveFailedCallback = void Function();
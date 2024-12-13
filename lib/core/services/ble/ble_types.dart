// lib/core/services/ble/ble_types.dart
enum BleConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting
}

typedef ErrorCallback = void Function(String message);
typedef StateChangeCallback = void Function(BleConnectionState state);
typedef KeepAliveFailedCallback = void Function();

class BleException implements Exception {
  final String message;
  BleException(this.message);

  @override
  String toString() => message;
}
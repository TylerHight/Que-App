// lib/core/constants/ble_constants.dart
class BleConstants {
  // Service and Characteristic UUIDs from the Arduino code
  static const String LED_SERVICE_UUID = "0000180a-0000-1000-8000-00805f9b34fb";
  static const String SWITCH_CHARACTERISTIC_UUID = "00002a57-0000-1000-8000-00805f9b34fb";

  // Device name as advertised by Arduino
  static const String DEVICE_NAME = "Nano 33 BLE";

  // Command values matching Arduino implementation
  static const int CMD_LED_OFF = 0;
  static const int CMD_LED_RED = 1;
  static const int CMD_LED_GREEN = 2;
  static const int CMD_LED_BLUE = 3;

  // Timeout value matching Arduino (in milliseconds)
  static const int DISCONNECT_TIMEOUT = 20000;
}
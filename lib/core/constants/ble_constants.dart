// lib/core/constants/ble_constants.dart
class BleConstants {
  // Device Information
  static const String DEVICE_NAME = "Nano 33 BLE";

  // Timeout values
  static const int DISCONNECT_TIMEOUT = 20000;
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 10);
  static const Duration KEEP_ALIVE_INTERVAL = Duration(seconds: 15);

  // Service UUIDs
  static const String LED_SERVICE_UUID = "0000180a-0000-1000-8000-00805f9b34fb";
  static const String SETTINGS_SERVICE_UUID = "0000180f-0000-1000-8000-00805f9b34fb";

  // LED Characteristic UUID
  static const String SWITCH_CHARACTERISTIC_UUID = "00002a57-0000-1000-8000-00805f9b34fb";

  // Settings Characteristic UUIDs
  static const String EMISSION1_CHARACTERISTIC_UUID = "00002a19-0000-1000-8000-00805f9b34fb";
  static const String EMISSION2_CHARACTERISTIC_UUID = "00002a1a-0000-1000-8000-00805f9b34fb";
  static const String INTERVAL1_CHARACTERISTIC_UUID = "00002a1b-0000-1000-8000-00805f9b34fb";
  static const String INTERVAL2_CHARACTERISTIC_UUID = "00002a1c-0000-1000-8000-00805f9b34fb";
  static const String PERIODIC1_CHARACTERISTIC_UUID = "00002a1d-0000-1000-8000-00805f9b34fb";
  static const String PERIODIC2_CHARACTERISTIC_UUID = "00002a1e-0000-1000-8000-00805f9b34fb";
  static const String HEARTRATE_CHARACTERISTIC_UUID = "00002a1f-0000-1000-8000-00805f9b34fb";

  // LED Commands
  static const int CMD_LED_OFF = 0;
  static const int CMD_LED_RED = 1;
  static const int CMD_LED_GREEN = 2;
  static const int CMD_LED_BLUE = 3;

  // Command validation
  static bool isValidLedCommand(int command) =>
      command >= CMD_LED_OFF && command <= CMD_LED_BLUE;

  // UUID helper
  static String getShortUUID(String fullUUID) {
    try {
      return fullUUID.replaceAll('-', '').replaceAll('0000', '').substring(0, 4).toLowerCase();
    } catch (e) {
      return fullUUID.toLowerCase();
    }
  }
}
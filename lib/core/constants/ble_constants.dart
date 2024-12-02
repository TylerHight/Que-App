// lib/core/constants/ble_constants.dart

class BleConstants {
  // Device Information
  static const String DEVICE_NAME = "Nano 33 BLE";

  // Timeout values
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 10);
  static const Duration KEEP_ALIVE_INTERVAL = Duration(seconds: 15);

  // Service UUIDs
  static const String LED_SERVICE_UUID = "0000180a-0000-1000-8000-00805f9b34fb";
  static const String SWITCH_CHARACTERISTIC_UUID = "00002a57-0000-1000-8000-00805f9b34fb";

  // LED Commands
  static const int CMD_LED_OFF = 0;
  static const int CMD_LED_RED = 1;
  static const int CMD_LED_GREEN = 2;
  static const int CMD_LED_BLUE = 3;

  // Command Types
  static const int CMD_EMISSION1_DURATION = 4;
  static const int CMD_EMISSION2_DURATION = 5;
  static const int CMD_INTERVAL1 = 6;
  static const int CMD_INTERVAL2 = 7;
  static const int CMD_PERIODIC1 = 8;
  static const int CMD_PERIODIC2 = 9;
  static const int CMD_HEARTRATE = 10;

  // Service UUIDs
  static const String HEARTRATE_SERVICE_UUID = "0000180d-0000-1000-8000-00805f9b34fb";

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
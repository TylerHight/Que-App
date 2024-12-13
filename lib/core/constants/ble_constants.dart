// lib/core/constants/ble_constants.dart

class BleConstants {
  // Device Information
  static const String DEVICE_NAME = "QUE Device";  // Updated to match Arduino name
  static const String DEVICE_NAME_PREFIX = "QUE";  // For partial matching

  // Connection settings
  static const Duration CONNECTION_TIMEOUT = Duration(seconds: 30);  // Increased timeout
  static const Duration KEEP_ALIVE_INTERVAL = Duration(seconds: 15);
  static const int MAX_CONNECTION_RETRIES = 3;
  static const Duration RETRY_DELAY = Duration(seconds: 2);
  static const int MIN_RSSI_THRESHOLD = -80;  // Minimum acceptable signal strength

  // Service UUIDs - Using standardized UUIDs
  static const String LED_SERVICE_UUID = "180A";
  static const String SETTINGS_SERVICE_UUID = "180F";
  static const String HEARTRATE_SERVICE_UUID = "180D";

  // Characteristic UUIDs
  static const String SWITCH_CHARACTERISTIC_UUID = "2A57";
  static const String EMISSION1_CHARACTERISTIC_UUID = "2A19";
  static const String EMISSION2_CHARACTERISTIC_UUID = "2A1A";
  static const String INTERVAL1_CHARACTERISTIC_UUID = "2A1B";
  static const String INTERVAL2_CHARACTERISTIC_UUID = "2A1C";
  static const String PERIODIC1_CHARACTERISTIC_UUID = "2A1D";
  static const String PERIODIC2_CHARACTERISTIC_UUID = "2A1E";
  static const String HEARTRATE_CHARACTERISTIC_UUID = "2A1F";

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

  // MTU Settings
  static const int DEFAULT_MTU = 23;
  static const int PREFERRED_MTU = 512;

  // Validation methods
  static bool isValidLedCommand(int command) =>
      command >= CMD_LED_OFF && command <= CMD_LED_BLUE;

  static bool isValidEmissionCommand(int command) =>
      command >= CMD_EMISSION1_DURATION && command <= CMD_HEARTRATE;

  // UUID helper methods
  static String normalizeUUID(String uuid) {
    uuid = uuid.toLowerCase().replaceAll('-', '');
    if (uuid.length == 4) {
      return "0000$uuid-0000-1000-8000-00805f9b34fb";
    }
    return uuid;
  }

  static String shortUUID(String uuid) {
    return uuid.substring(4, 8).toLowerCase();
  }

  // Error messages
  static const String ERR_DEVICE_NOT_FOUND = "QUE device not found";
  static const String ERR_CONNECTION_FAILED = "Failed to connect to device";
  static const String ERR_SERVICE_NOT_FOUND = "Required BLE service not found";
  static const String ERR_CHARACTERISTIC_NOT_FOUND = "Required characteristic not found";
  static const String ERR_DEVICE_DISCONNECTED = "Device disconnected unexpectedly";
  static const String ERR_BLUETOOTH_DISABLED = "Bluetooth is disabled";
  static const String ERR_TIMEOUT = "Connection timeout";
}
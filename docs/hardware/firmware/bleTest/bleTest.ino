#include <ArduinoBLE.h>

// Services
BLEService ledService("0000180a-0000-1000-8000-00805f9b34fb"); // BLE LED Service
BLEService settingsService("0000180f-0000-1000-8000-00805f9b34fb"); // Settings Service

// Characteristics
BLEByteCharacteristic switchCharacteristic("00002a57-0000-1000-8000-00805f9b34fb", BLERead | BLEWrite);
BLELongCharacteristic emission1Characteristic("00002a19-0000-1000-8000-00805f9b34fb", BLERead | BLEWrite);
BLELongCharacteristic emission2Characteristic("00002a1a-0000-1000-8000-00805f9b34fb", BLERead | BLEWrite);
BLELongCharacteristic interval1Characteristic("00002a1b-0000-1000-8000-00805f9b34fb", BLERead | BLEWrite);
BLELongCharacteristic interval2Characteristic("00002a1c-0000-1000-8000-00805f9b34fb", BLERead | BLEWrite);
BLEByteCharacteristic periodic1Characteristic("00002a1d-0000-1000-8000-00805f9b34fb", BLERead | BLEWrite);
BLEByteCharacteristic periodic2Characteristic("00002a1e-0000-1000-8000-00805f9b34fb", BLERead | BLEWrite);
BLEByteCharacteristic heartrateCharacteristic("00002a1f-0000-1000-8000-00805f9b34fb", BLERead | BLEWrite);

// Command definitions
#define CMD_LED_OFF 0
#define CMD_LED_RED 1
#define CMD_LED_GREEN 2
#define CMD_LED_BLUE 3
#define CMD_EMISSION1_DURATION 4
#define CMD_EMISSION2_DURATION 5
#define CMD_INTERVAL1 6
#define CMD_INTERVAL2 7
#define CMD_PERIODIC1 8
#define CMD_PERIODIC2 9
#define CMD_HEARTRATE 10

// Settings storage
unsigned long emission1Duration = 10000;  // 10 seconds in milliseconds
unsigned long emission2Duration = 10000;  // 10 seconds in milliseconds
unsigned long interval1 = 300000;         // 5 minutes in milliseconds
unsigned long interval2 = 300000;         // 5 minutes in milliseconds
bool periodic1Enabled = false;
bool periodic2Enabled = false;
byte heartrateThreshold = 90;            // Default 90 BPM

// Timing variables
unsigned long lastActivityTime = 0;
const unsigned long disconnectTimeout = 60000; // 60 seconds timeout
unsigned long lastEmission1Time = 0;
unsigned long lastEmission2Time = 0;

void setup() {
  Serial.begin(9600);
  while (!Serial);

  // Set LED pins to output mode
  pinMode(LEDR, OUTPUT);
  pinMode(LEDG, OUTPUT);
  pinMode(LEDB, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);

  // Initialize all LEDs to off
  digitalWrite(LED_BUILTIN, LOW);
  digitalWrite(LEDR, HIGH);
  digitalWrite(LEDG, HIGH);
  digitalWrite(LEDB, HIGH);

  // Initialize BLE
  if (!BLE.begin()) {
    Serial.println("Starting Bluetooth® Low Energy failed!");
    while (1);
  }

  // Set up LED service
  BLE.setLocalName("Nano 33 BLE");
  BLE.setAdvertisedService(ledService);
  ledService.addCharacteristic(switchCharacteristic);
  BLE.addService(ledService);
  switchCharacteristic.writeValue(0);

  // Set up settings service
  settingsService.addCharacteristic(emission1Characteristic);
  settingsService.addCharacteristic(emission2Characteristic);
  settingsService.addCharacteristic(interval1Characteristic);
  settingsService.addCharacteristic(interval2Characteristic);
  settingsService.addCharacteristic(periodic1Characteristic);
  settingsService.addCharacteristic(periodic2Characteristic);
  settingsService.addCharacteristic(heartrateCharacteristic);
  BLE.addService(settingsService);

  // Initialize characteristic values
  emission1Characteristic.writeValue(emission1Duration);
  emission2Characteristic.writeValue(emission2Duration);
  interval1Characteristic.writeValue(interval1);
  interval2Characteristic.writeValue(interval2);
  periodic1Characteristic.writeValue(periodic1Enabled);
  periodic2Characteristic.writeValue(periodic2Enabled);
  heartrateCharacteristic.writeValue(heartrateThreshold);

  // Start advertising
  BLE.advertise();
  Serial.println("Advertised as Nano 33 BLE");
}

void handleLEDs(byte command) {
  switch (command) {
    case CMD_LED_RED:
      Serial.println("Red LED on");
      digitalWrite(LEDR, LOW);
      digitalWrite(LEDG, HIGH);
      digitalWrite(LEDB, HIGH);
      break;
    case CMD_LED_GREEN:
      Serial.println("Green LED on");
      digitalWrite(LEDR, HIGH);
      digitalWrite(LEDG, LOW);
      digitalWrite(LEDB, HIGH);
      break;
    case CMD_LED_BLUE:
      Serial.println("Blue LED on");
      digitalWrite(LEDR, HIGH);
      digitalWrite(LEDG, HIGH);
      digitalWrite(LEDB, LOW);
      break;
    default:
      Serial.println("LEDs off");
      digitalWrite(LEDR, HIGH);
      digitalWrite(LEDG, HIGH);
      digitalWrite(LEDB, HIGH);
      break;
  }
}

void checkPeriodicEmissions() {
  unsigned long currentTime = millis();
  
  if (periodic1Enabled && (currentTime - lastEmission1Time >= interval1)) {
    handleLEDs(CMD_LED_RED);
    delay(emission1Duration);
    handleLEDs(CMD_LED_OFF);
    lastEmission1Time = currentTime;
  }
  
  if (periodic2Enabled && (currentTime - lastEmission2Time >= interval2)) {
    handleLEDs(CMD_LED_GREEN);
    delay(emission2Duration);
    handleLEDs(CMD_LED_OFF);
    lastEmission2Time = currentTime;
  }
}

void handleSettingsUpdate() {
  if (emission1Characteristic.written()) {
    emission1Duration = emission1Characteristic.value();
    Serial.print("Updated emission1Duration: ");
    Serial.println(emission1Duration);
  }
  
  if (emission2Characteristic.written()) {
    emission2Duration = emission2Characteristic.value();
    Serial.print("Updated emission2Duration: ");
    Serial.println(emission2Duration);
  }
  
  if (interval1Characteristic.written()) {
    interval1 = interval1Characteristic.value();
    Serial.print("Updated interval1: ");
    Serial.println(interval1);
  }
  
  if (interval2Characteristic.written()) {
    interval2 = interval2Characteristic.value();
    Serial.print("Updated interval2: ");
    Serial.println(interval2);
  }
  
  if (periodic1Characteristic.written()) {
    periodic1Enabled = periodic1Characteristic.value();
    Serial.print("Updated periodic1Enabled: ");
    Serial.println(periodic1Enabled);
  }
  
  if (periodic2Characteristic.written()) {
    periodic2Enabled = periodic2Characteristic.value();
    Serial.print("Updated periodic2Enabled: ");
    Serial.println(periodic2Enabled);
  }
  
  if (heartrateCharacteristic.written()) {
    heartrateThreshold = heartrateCharacteristic.value();
    Serial.print("Updated heartrateThreshold: ");
    Serial.println(heartrateThreshold);
  }
}

void loop() {
  BLEDevice central = BLE.central();

  if (central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());
    digitalWrite(LED_BUILTIN, HIGH);
    lastActivityTime = millis();

    while (central.connected()) {
      // Update activity time on any characteristic interaction
      if (switchCharacteristic.written() || 
          switchCharacteristic.subscribed() || 
          switchCharacteristic.read()) {
        lastActivityTime = millis();
      }

      // Handle LED commands
      if (switchCharacteristic.written()) {
        handleLEDs(switchCharacteristic.value());
      }

      // Handle settings updates
      handleSettingsUpdate();
      
      // Check periodic emissions
      checkPeriodicEmissions();

      // Check disconnection timeout
      if (millis() - lastActivityTime > disconnectTimeout) {
        Serial.println("Timeout: disconnecting central");
        central.disconnect();
        break;
      }
    }

    // Clean up on disconnect
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
    digitalWrite(LED_BUILTIN, LOW);
    handleLEDs(CMD_LED_OFF);

    // Restart advertising
    BLE.advertise();
    Serial.println("Advertised as Nano 33 BLE");
  }
}
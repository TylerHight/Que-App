#include <ArduinoBLE.h>

BLEService ledService("0000180a-0000-1000-8000-00805f9b34fb"); // BLE LED Service

// BLE LED Switch Characteristic - custom 128-bit UUID, read and writable by central
BLEByteCharacteristic switchCharacteristic("00002a57-0000-1000-8000-00805f9b34fb", BLERead | BLEWrite);

unsigned long lastActivityTime = 0;
const unsigned long disconnectTimeout = 20000; // 20 seconds in milliseconds

void setup() {
  Serial.begin(9600);
  while (!Serial);

  // set LED's pin to output mode
  pinMode(LEDR, OUTPUT);
  pinMode(LEDG, OUTPUT);
  pinMode(LEDB, OUTPUT);
  pinMode(LED_BUILTIN, OUTPUT);

  digitalWrite(LED_BUILTIN, LOW);         // when the central disconnects, turn off the LED
  digitalWrite(LEDR, HIGH);               // will turn the LED off
  digitalWrite(LEDG, HIGH);               // will turn the LED off
  digitalWrite(LEDB, HIGH);               // will turn the LED off

  // begin initialization
  if (!BLE.begin()) {
    Serial.println("Starting Bluetooth® Low Energy failed!");
    while (1);
  }

  // set advertised local name and service UUID:
  BLE.setLocalName("Nano 33 BLE");
  BLE.setAdvertisedService(ledService);

  // add the characteristic to the service
  ledService.addCharacteristic(switchCharacteristic);

  // add service
  BLE.addService(ledService);

  // set the initial value for the characteristic:
  switchCharacteristic.writeValue(0);

  // start advertising
  BLE.advertise();

  Serial.println("Advertised as Nano 33 BLE");
}

void loop() {
  // listen for BLE peripherals to connect:
  BLEDevice central = BLE.central();

  // if a central is connected to peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // print the central's MAC address:
    Serial.println(central.address());
    digitalWrite(LED_BUILTIN, HIGH);            // turn on the LED to indicate the connection

    // reset last activity time when connected
    lastActivityTime = millis();

    // while the central is still connected to peripheral:
    while (central.connected()) {
      // check if the remote device wrote to the characteristic,
      // use the value to control the LED:
      if (switchCharacteristic.written()) {
        switch (switchCharacteristic.value()) {   // any value other than 0
          case 1:
            Serial.println("Red LED on");
            digitalWrite(LEDR, LOW);            // will turn the LED on
            digitalWrite(LEDG, HIGH);           // will turn the LED off
            digitalWrite(LEDB, HIGH);           // will turn the LED off
            break;
          case 2:
            Serial.println("Green LED on");
            digitalWrite(LEDR, HIGH);           // will turn the LED off
            digitalWrite(LEDG, LOW);            // will turn the LED on
            digitalWrite(LEDB, HIGH);           // will turn the LED off
            break;
          case 3:
            Serial.println("Blue LED on");
            digitalWrite(LEDR, HIGH);           // will turn the LED off
            digitalWrite(LEDG, HIGH);           // will turn the LED off
            digitalWrite(LEDB, LOW);            // will turn the LED on
            break;
          default:
            Serial.println("LEDs off");
            digitalWrite(LEDR, HIGH);           // will turn the LED off
            digitalWrite(LEDG, HIGH);           // will turn the LED off
            digitalWrite(LEDB, HIGH);           // will turn the LED off
            break;
        }
      }

      // check disconnection timeout
      if (millis() - lastActivityTime > disconnectTimeout) {
        Serial.println("Timeout: disconnecting central");
        central.disconnect();
        break;
      }
    }

    // when the central disconnects, print it out:
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
    digitalWrite(LED_BUILTIN, LOW);              // when the central disconnects, turn off the LED
    digitalWrite(LEDR, HIGH);                    // will turn the LED off
    digitalWrite(LEDG, HIGH);                    // will turn the LED off
    digitalWrite(LEDB, HIGH);                    // will turn the LED off

    // Restart advertising to make the device available for connection again
    BLE.advertise();
    Serial.println("Advertised as Nano 33 BLE");
  }
}

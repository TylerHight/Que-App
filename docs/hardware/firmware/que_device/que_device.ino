#include <ArduinoBLE.h>
#include "ble_config.h"
#include "led_control.h"
#include "settings.h"
#include "timing.h"

void setup() {
    Serial.begin(9600);
    while (!Serial);

    Serial.println("\n=== QUE Device Startup ===");

    setupPins();
    setupBLE();

    Serial.println("\nDevice Ready!");
    Serial.println("=== Setup Complete ===\n");
}

void loop() {
    BLEDevice central = BLE.central();

    if (central) {
        onCentralConnected(central);

        while (central.connected()) {
            handlePeripheralLoop(central);
        }

        onCentralDisconnected(central);
    }
}
// ble_config.cpp
#include "ble_config.h"
#include "led_control.h"
#include "settings.h"
#include "timing.h"

BLEService ledService("180A"); // Use 16-bit UUID for standard service
BLEService settingsService("180F");

BLEByteCharacteristic switchCharacteristic("2A57", BLERead | BLEWrite | BLENotify);
BLELongCharacteristic emission1Characteristic("2A19", BLERead | BLEWrite | BLENotify);
BLELongCharacteristic emission2Characteristic("2A1A", BLERead | BLEWrite | BLENotify);
BLELongCharacteristic interval1Characteristic("2A1B", BLERead | BLEWrite | BLENotify);
BLELongCharacteristic interval2Characteristic("2A1C", BLERead | BLEWrite | BLENotify);
BLEByteCharacteristic periodic1Characteristic("2A1D", BLERead | BLEWrite | BLENotify);
BLEByteCharacteristic periodic2Characteristic("2A1E", BLERead | BLEWrite | BLENotify);
BLEByteCharacteristic heartrateCharacteristic("2A1F", BLERead | BLEWrite | BLENotify);

void setupBLE() {
    Serial.println("\nInitializing BLE...");

    if (!BLE.begin()) {
        Serial.println("ERROR: Starting BLE failed!");
        while (1);
    }

    // Configure services
    setupServices();

    // Set device properties
    BLE.setDeviceName("QUE Device");
    BLE.setLocalName("QUE Device");

    // Important: Only advertise the primary service
    BLE.setAdvertisedService(ledService);

    // Start advertising
    BLE.advertise();
    Serial.println("Advertising as 'QUE Device'");
}

void setupServices() {
    // Add characteristics to services
    ledService.addCharacteristic(switchCharacteristic);

    settingsService.addCharacteristic(emission1Characteristic);
    settingsService.addCharacteristic(emission2Characteristic);
    settingsService.addCharacteristic(interval1Characteristic);
    settingsService.addCharacteristic(interval2Characteristic);
    settingsService.addCharacteristic(periodic1Characteristic);
    settingsService.addCharacteristic(periodic2Characteristic);
    settingsService.addCharacteristic(heartrateCharacteristic);

    // Add services to device
    BLE.addService(ledService);
    BLE.addService(settingsService);

    // Initialize values
    initializeCharacteristics();
}

void initializeCharacteristics() {
    switchCharacteristic.writeValue(0);
    emission1Characteristic.writeValue(getEmission1Duration());
    emission2Characteristic.writeValue(getEmission2Duration());
    interval1Characteristic.writeValue(getInterval1());
    interval2Characteristic.writeValue(getInterval2());
    periodic1Characteristic.writeValue(getPeriodic1Enabled());
    periodic2Characteristic.writeValue(getPeriodic2Enabled());
    heartrateCharacteristic.writeValue(getHeartrateThreshold());
}

void onCentralConnected(BLEDevice central) {
    Serial.print("Connected to central: ");
    Serial.println(central.address());
    digitalWrite(LED_BUILTIN, HIGH);
    resetActivityTimer();
}

void onCentralDisconnected(BLEDevice central) {
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
    digitalWrite(LED_BUILTIN, LOW);
    handleLEDs(CMD_LED_OFF);
    BLE.advertise();
}

void handlePeripheralLoop(BLEDevice central) {
    if (switchCharacteristic.written()) {
        resetActivityTimer();
        handleLEDs(switchCharacteristic.value());
    }

    handleSettingsUpdate();
    checkPeriodicEmissions();

    if (isConnectionTimedOut()) {
        Serial.println("Connection timeout");
        central.disconnect();
    }
}
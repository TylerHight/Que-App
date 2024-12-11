// ble_config.h
#ifndef BLE_CONFIG_H
#define BLE_CONFIG_H

#include <ArduinoBLE.h>

// Services
extern BLEService ledService;
extern BLEService settingsService;

// Characteristics
extern BLEByteCharacteristic switchCharacteristic;
extern BLELongCharacteristic emission1Characteristic;
extern BLELongCharacteristic emission2Characteristic;
extern BLELongCharacteristic interval1Characteristic;
extern BLELongCharacteristic interval2Characteristic;
extern BLEByteCharacteristic periodic1Characteristic;
extern BLEByteCharacteristic periodic2Characteristic;
extern BLEByteCharacteristic heartrateCharacteristic;

void setupBLE();
void setupServices();
void initializeCharacteristics();
void onCentralConnected(BLEDevice central);
void onCentralDisconnected(BLEDevice central);
void handlePeripheralLoop(BLEDevice central);

#endif // BLE_CONFIG_H
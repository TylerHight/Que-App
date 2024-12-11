// settings.cpp
#include "settings.h"
#include "ble_config.h"
#include "led_control.h"

// Settings storage
static unsigned long emission1Duration = 10000;  // 10 seconds
static unsigned long emission2Duration = 10000;  // 10 seconds
static unsigned long interval1 = 300000;         // 5 minutes
static unsigned long interval2 = 300000;         // 5 minutes
static bool periodic1Enabled = false;
static bool periodic2Enabled = false;
static byte heartrateThreshold = 90;            // Default 90 BPM

// Timing variables for periodic emissions
static unsigned long lastEmission1Time = 0;
static unsigned long lastEmission2Time = 0;

// Getters
unsigned long getEmission1Duration() { return emission1Duration; }
unsigned long getEmission2Duration() { return emission2Duration; }
unsigned long getInterval1() { return interval1; }
unsigned long getInterval2() { return interval2; }
bool getPeriodic1Enabled() { return periodic1Enabled; }
bool getPeriodic2Enabled() { return periodic2Enabled; }
byte getHeartrateThreshold() { return heartrateThreshold; }

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
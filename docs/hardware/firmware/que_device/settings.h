// settings.h
#ifndef SETTINGS_H
#define SETTINGS_H

#include <Arduino.h>

// Settings getters
unsigned long getEmission1Duration();
unsigned long getEmission2Duration();
unsigned long getInterval1();
unsigned long getInterval2();
bool getPeriodic1Enabled();
bool getPeriodic2Enabled();
byte getHeartrateThreshold();

// Settings handlers
void handleSettingsUpdate();
void checkPeriodicEmissions();

#endif // SETTINGS_H
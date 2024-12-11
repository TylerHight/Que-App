// led_control.h
#ifndef LED_CONTROL_H
#define LED_CONTROL_H

#include <Arduino.h>

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

void setupPins();
void handleLEDs(byte command);

#endif // LED_CONTROL_H
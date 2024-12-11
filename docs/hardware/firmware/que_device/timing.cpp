// timing.cpp
#include "timing.h"

static unsigned long lastActivityTime = 0;
static const unsigned long DISCONNECT_TIMEOUT = 60000; // 60 seconds timeout

void resetActivityTimer() {
    lastActivityTime = millis();
}

bool isConnectionTimedOut() {
    return (millis() - lastActivityTime > DISCONNECT_TIMEOUT);
}
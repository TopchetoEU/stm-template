#include <stdio.h>
#include <stm32g0xx_hal.h>

#include "bosonLogger.h"

#include "sys.h"

void setup() {
	init_sys(NULL /* Replace with a uart handle */);
	logI("Hello, world!");
}

void loop() {
	logI("I'm looping!");
	HAL_Delay(1000);
}

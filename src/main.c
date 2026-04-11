#include <stdio.h>
#include <stm32g0xx_hal.h>

#include "bosonLogger.h"

#include "syscalls.h"

void setup() {
	init_printing(NULL /* Replace with a uart handle */);
	bsn_loggerInit(HAL_GetTick, true);
	logI("Hello, world!");
}

void loop() {
	logI("I'm looping!");
	HAL_Delay(1000);
}

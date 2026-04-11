#include <stdio.h>
#include <stm32g0xx_hal.h>

#include "syscalls.h"

void setup() {
	init_printing(NULL /* Replace with a uart handle */);
	printf("Hello, world!\n");
}

void loop() {
	printf("I'm looping!\n");
	HAL_Delay(1000);
}

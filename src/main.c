#include <stdio.h>
#include <stm32g0xx_hal.h>

void setup() {
	printf("Hello, world!\n");
}

void loop() {
	printf("I'm looping!\n");
	HAL_Delay(1000);
}

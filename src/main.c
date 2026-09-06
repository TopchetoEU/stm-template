#include <stdio.h>
#include <stm32g0xx_hal.h>

#include "bosonLogger.h"

#include "sys.h"

static size_t _crit_n = 0;

static uint32_t _get_tick() {
	return (uint32_t)HAL_GetTick();
}
static void _crit_begin() {
	if (!_crit_n) {
		__disable_irq();
	}
	_crit_n++;
}
static void _crit_end() {
	if (_crit_n > 0) {
		_crit_n--;
	}
	if (!_crit_n) {
		__enable_irq();
	}
}

void setup() {
	bsn_critInit(crit_begin, crit_end);

	#ifdef DEBUG
		bsn_loggerInit(_get_tick, true);
	#else
		bsn_loggerInit(_get_tick, false);
	#endif

	logI("Hello, world!");
}

void loop() {
	logI("I'm looping!");
	HAL_Delay(1000);
}

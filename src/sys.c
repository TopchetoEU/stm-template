#include <stdbool.h>
#include <stdio.h>
#include <errno.h>

#include <stm32g0xx_hal.h>
#include <sys/reent.h>

static UART_HandleTypeDef *_uart = NULL;

static size_t _crit_n = 0;

static void crit_begin() {
	if (!_crit_n) {
		__disable_irq();
	}
	_crit_n++;
}
static void crit_end() {
	if (_crit_n > 0) {
		_crit_n--;
	}
	if (!_crit_n) {
		__enable_irq();
	}
}

void init_sys(UART_HandleTypeDef *uart) {
	_uart = uart;

	bsn_critInit(crit_begin, crit_end);

	#ifdef DEBUG
		bsn_loggerInit((bsn_tickFunc)HAL_GetTick, true);
	#else
		bsn_loggerInit((bsn_tickFunc)HAL_GetTick, false);
	#endif
}



void _error() {
	printf("FATAL ERROR!!\n");
	while (true);
}

int _read(int file, char *ptr, int len) {
	(void)file;

	if (_uart == NULL) {
		errno = EBADF;
		return -1;
	}

	if (HAL_UART_Receive(_uart, (uint8_t*)ptr, len, HAL_MAX_DELAY) != HAL_OK) {
		errno = EBADF;
		return -1;
	}

	return len;
}
int _write(int file, char *ptr, int len) {
	(void)file;

	if (_uart == NULL) {
		errno = EBADF;
		return -1;
	}

	if (HAL_UART_Transmit(_uart, (uint8_t*)ptr, len, HAL_MAX_DELAY) != HAL_OK)
	{
		errno = EBADF;
		return -1;
	}

	return len;
}

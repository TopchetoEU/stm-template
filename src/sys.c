#include <stdbool.h>
#include <stdio.h>
#include <errno.h>

#include <stm32g0xx_hal.h>
#include <sys/reent.h>

static UART_HandleTypeDef *_uart = NULL;

void init_sys(UART_HandleTypeDef *uart) {
	_uart = uart;
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

	return 0;
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

	return 0;
}

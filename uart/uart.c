#include "uart.h"

static uint32_t tx_count;       /* visible only in uart.c */

void uart_init(uint32_t baud_div)
{
    UART0->BAUDDIV = baud_div;  /* one bit lasts baud_div clock cycles */
    UART0->CTRL    = 0;         /* polling, no interrupts              */
    tx_count = 0;
}

void uart_putc(char c)
{
    while (UART0->STATUS & UART_STATUS_TX_FULL) {
        /* wait while the transmit FIFO is full */
    }
    UART0->TXDATA = (uint8_t)c;
    tx_count++;
}

void uart_puts(const char *s)
{
    while (*s) {
        uart_putc(*s++);
    }
}

int uart_getc(void)
{
    if (!(UART0->STATUS & UART_STATUS_RX_READY)) {
        return -1;
    }
    return (int)(UART0->RXDATA & 0xFF);
}

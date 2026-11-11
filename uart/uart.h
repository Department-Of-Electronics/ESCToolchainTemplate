#ifndef UART_H
#define UART_H

#include <stdint.h>

/* UART0 of the SoC (serial port, connected to the PC) */
#define UART0_BASE              0x00800000u

typedef struct {
    volatile uint32_t TXDATA;   /* 0x00  W:  byte to transmit        */
    volatile uint32_t RXDATA;   /* 0x04  R:  received byte           */
    volatile uint32_t STATUS;   /* 0x08  R:  status flags            */
    volatile uint32_t CTRL;     /* 0x0C  RW: interrupt enables       */
    volatile uint32_t BAUDDIV;  /* 0x10  RW: clock cycles per bit    */
} uart_regs_t;

#define UART0                   ((uart_regs_t *)UART0_BASE)

/* STATUS register */
#define UART_STATUS_TX_BUSY     (1u << 0)
#define UART_STATUS_RX_READY    (1u << 1)
#define UART_STATUS_TX_FULL     (1u << 2)

void uart_init(uint32_t baud_div);
void uart_putc(char c);
void uart_puts(const char *s);
int  uart_getc(void);           /* received byte, or -1 if there is none */

#endif

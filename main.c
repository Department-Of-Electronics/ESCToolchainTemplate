#include "uart.h"

#define BAUD_DIV    16          /* UART: clock cycles per bit */

const char banner[] = "RNS template: UART ready\n";    /* constant      */
char       prompt   = '>';                             /* initialized   */
uint32_t   rx_count;                                   /* uninitialized */

int main(void)
{
    uart_init(BAUD_DIV);
    uart_puts(banner);
#ifdef DEBUG
    uart_puts("debug build\n");
#endif
    uart_putc(prompt);

    while (1) {
        int c = uart_getc();    /* -1: nothing received */
        if (c >= 0) {
            rx_count++;
            uart_putc((char)c); /* echo */
        }
    }
}

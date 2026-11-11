# Template_projekat: the build process step by step

The starting project of the lecture *The build process of embedded software* (course *Design and Development
of Embedded Software*, PRNS). It is built by hand, tool by tool, to show every step of the RISC-V GNU
toolchain: assembling, compiling, analysing the object files and linking. The `Makefile` is written later
in the lecture, once the manual build has shown why it is needed.

| File | What it is |
|---|---|
| `startup.s` | first code after reset: stack, `.data` copied from Flash to SRAM, `.bss` cleared, interrupts (`mtvec`, `mstatus.MIE`), call to `main` |
| `main.c` | `main`: UART init, a message, then an endless loop that echoes every received character |
| `uart/uart.h`, `uart/uart.c` | UART0 driver (registers, `uart_init`, `uart_putc`, `uart_puts`, `uart_getc`) |
| `linker.ld` | linker script: Flash 64 KB at `0x00000000`, SRAM 64 KB at `0x00010000` |

## Build by hand

```
riscv64-unknown-elf-as  -march=rv32im_zicsr -mabi=ilp32 startup.s -o startup.o
riscv64-unknown-elf-gcc -march=rv32im_zicsr -mabi=ilp32 -O0 -Wall -ffreestanding -Iuart -c main.c -o main.o
riscv64-unknown-elf-gcc -march=rv32im_zicsr -mabi=ilp32 -O0 -Wall -ffreestanding -c uart/uart.c -o uart.o
riscv64-unknown-elf-ld  -m elf32lriscv -T linker.ld --no-relax -Map=app.map startup.o main.o uart.o -o app.elf
```

## Run

[rvisio.com](https://rvisio.com) → **System on chip (SoC)** → panel Program → **ELF** → `app.elf` → **Run**.
The Console (UART) panel shows `RNS template: UART ready` and `>`; text sent from the console is echoed back.

## Interrupts

`startup.s` writes the address of `trap_entry` to `mtvec` and enables interrupts. `trap_entry` saves the
registers, calls the C function `irq_handler` and returns with `mret`. The default `irq_handler` does nothing
(weak symbol); define your own `void irq_handler(void)` in any C file to handle interrupts.

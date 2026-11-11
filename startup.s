# startup.s - the first code executed after reset (target SoC, RV32IM)
#
#   1. stack pointer
#   2. .data: copy the initial values from Flash to SRAM
#   3. .bss:  fill with zeros
#   4. interrupts: handler address (mtvec), global enable (mstatus.MIE)
#   5. jump to main()
#
# The symbols _stack_top, _data_load, _data_start, _data_end, _bss_start and
# _bss_end are not defined here: the linker script (linker.ld) defines them.

    .section .text.init
    .globl  _start
_start:
    la      sp, _stack_top          # 1. stack: end of SRAM

    la      t0, _data_load          # 2. .data: Flash (LMA) -> SRAM (VMA)
    la      t1, _data_start
    la      t2, _data_end
1:  bgeu    t1, t2, 2f
    lw      t3, 0(t0)
    sw      t3, 0(t1)
    addi    t0, t0, 4
    addi    t1, t1, 4
    j       1b

2:  la      t0, _bss_start          # 3. .bss = 0
    la      t1, _bss_end
3:  bgeu    t0, t1, 4f
    sw      zero, 0(t0)
    addi    t0, t0, 4
    j       3b

4:  la      t0, trap_entry          # 4. interrupts: the processor jumps to
    csrw    mtvec, t0               #    mtvec when an interrupt is taken
    csrsi   mstatus, 8              #    mstatus.MIE = 1: interrupts enabled

    call    main                    # 5. the C program
5:  j       5b                      #    main() should never return

# ---------------------------------------------------------------------------
# Interrupt entry. The processor has saved the return address in mepc.
# An interrupt can arrive between any two instructions, so every register a
# C function may change (ra, t0-t6, a0-a7) is saved on the stack and restored.

    .section .text
    .align  2
trap_entry:
    addi    sp, sp, -64
    sw      ra,  0(sp)
    sw      t0,  4(sp)
    sw      t1,  8(sp)
    sw      t2, 12(sp)
    sw      t3, 16(sp)
    sw      t4, 20(sp)
    sw      t5, 24(sp)
    sw      t6, 28(sp)
    sw      a0, 32(sp)
    sw      a1, 36(sp)
    sw      a2, 40(sp)
    sw      a3, 44(sp)
    sw      a4, 48(sp)
    sw      a5, 52(sp)
    sw      a6, 56(sp)
    sw      a7, 60(sp)

    call    irq_handler             # interrupt handler written in C

    lw      ra,  0(sp)
    lw      t0,  4(sp)
    lw      t1,  8(sp)
    lw      t2, 12(sp)
    lw      t3, 16(sp)
    lw      t4, 20(sp)
    lw      t5, 24(sp)
    lw      t6, 28(sp)
    lw      a0, 32(sp)
    lw      a1, 36(sp)
    lw      a2, 40(sp)
    lw      a3, 44(sp)
    lw      a4, 48(sp)
    lw      a5, 52(sp)
    lw      a6, 56(sp)
    lw      a7, 60(sp)
    addi    sp, sp, 64
    mret                            # return to the interrupted program (mepc)

# Default handler: does nothing. It is a weak symbol, so a function
# void irq_handler(void) defined in any C file replaces it.
    .weak   irq_handler
irq_handler:
    ret

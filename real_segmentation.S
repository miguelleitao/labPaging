/* https://github.com/cirosantilli/x86-bare-metal-examples#real-mode-segmentation */

#include "common.h"

/* Print a 16-bit number
 *
 * * in: r/m/imm16
 */
.macro PRINT_WORD_HEX2 in1=<%ax>  in2=<%bx>
    mov \in1, %ax
    mov \in2, %bx
    call print_word_hex
.endm

BEGIN
    CLEAR

    /* It is not possible to encode moving immediates
     * to segment registers: we must either:
     *
     * * pass through a general register ax
     * * pop from the stack
     */
    mov $2, %ax
    mov %ax, %ds
    PRINT_WORD_HEX2 <%ds>, <$msg>
    mov %ds:msg, %al
    PUTC <%al>

    /* %ds is the default segment for GAS memory operations
     * if we don't write it explicitly.
     */
    PRINT_NEWLINE
    mov msg, %al
    PUTC <%al>

    /*  Use %ds:(%bx) */
     
    mov $2, %ax
    mov %ax, %ds
    lea msg, %bx
    PRINT_WORD_HEX2 <%ds>, <%bx>
    movb (%bx), %al
    PUTC <%al>

    mov $0, %ax
    mov %ax, %ds
    lea msg, %bx
    add $0x20, %bx
    PRINT_WORD_HEX2 <%ds>, <%bx>
    movb (%bx), %al
    PUTC <%al>

    /*  Use %es:msg  */
    mov $2, %ax
    mov %ax, %es
    PRINT_WORD_HEX2 <%es>, <$msg>
    mov %es:msg, %al
    PUTC <%al>

    hlt

/* Print a 16-bit number in AX
 */
print_word_hex:
    push %bx
    PRINT_NEWLINE
    PRINT_HEX <%ah>
    PRINT_HEX <%al>
    PUTC $':
    pop %bx
    PRINT_HEX <%bh>
    PRINT_HEX <%bl>
    PRINT_NEWLINE
    ret

msg:
    /* Push the correct A forward 16 bytes in memory
     * to compensate for the segments.
     */
    .fill 0x20

    .byte 'A'

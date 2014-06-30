@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ uart.s
@
@ Code for reading (blocking) and writing to a serial port
@ on pins 14(txd) and 15(rxd) at 115200 baud
@@@@

.globl uart_init
.globl uart_readb
.globl uart_writeb
.globl uart_readb_echo
.globl uart_print
.globl uart_printn

@@@@@@
@@ Our memory mapped registers we'll be using
.equ    AUXENB,             0x20215004 
.equ    AUX_MU_IER_REG,     0x20215044
.equ    AUX_MU_IIR_REG,     0x20215048

.equ    AUX_MU_CNTL_REG,    0x20215060
.equ    AUX_MU_LCR_REG,     0x2021504C
.equ    AUX_MU_MCR_REG,     0x20215050
.equ    AUX_MU_BAUD,        0x20215068

.equ    AUX_MU_LSR_REG,     0x20215054
.equ    AUX_MU_IO_REG,      0x20215040

.equ    GPPUD_REG,          0x20200094      @ Page 91
.equ    GPPUDCLK0_REG,      0x20200098

@@@@@@
@@ Some magic numbers we're using
.equ    GPIO_ALT_5,         2
.equ    GPIO_TXD,           14
.equ    GPIO_RXD,           15

@@@@@@
@@ Baud rate = 250,000,000 / (115,200 * 8) - 1 = 270.267361111
.equ    BAUD_RATE,          270 


@@@@@@@@@@@@@@@@@@@@@@@@@@@@ TEXT SECTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.section .text


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ uart_init()
@  Initializes the UART
@@@@
uart_init:
    push    {lr}
    @ First enable the mini UART
    ldr     r0, =AUXENB
    ldr     r1, [r0]
    orr     r1, #1              @ Bit 0 controls the UART
    str     r1, [r0]
    

    @ Then disable UART interrupts
    ldr     r0, =AUX_MU_IER_REG
    mov     r1, #0              @ Clear all bits
    
    str     r1, [r0]    


    @ Disable Recieving/Transmitting
    ldr     r0, =AUX_MU_CNTL_REG
    ldr     r1, [r0]
    bic     r1, #3              @ Bit 0 is recieve, bit 1 is transmit
    str     r1, [r0]
    
    @ Set symbol width to 8-bit mode
    ldr     r0, =AUX_MU_LCR_REG
    ldr     r1, [r0]
    mov     r1, #3              @ Set bit 0 for 8 bit, set bit 1 (undoc)
    str     r1, [r0]
    
    @ Set the RTS line high
    ldr     r0, =AUX_MU_MCR_REG
    ldr     r1, [r0]
    bic     r1, #2              @ CLEAR bit 1 for RTS high
    str     r1, [r0]
    
    @ Clear I/O Buffers
    ldr     r0, =AUX_MU_IIR_REG
    ldr     r1, [r0]
    orr     r1, #0xC6           @ Set bits 1 and 2 to clear I/O FIFO's
                                @ Bits 6 and 7 aparantly enable FIFO as well
    str     r1, [r0]
    
    @ Set baud rate
    ldr     r0, =AUX_MU_BAUD
    ldr     r1, =BAUD_RATE      @ 115,200 baud = 270
    str     r1, [r0]
    
    @ Set RXD (pin 15) to Alt 5
    mov     r0, #GPIO_RXD
    mov     r1, #GPIO_ALT_5
    bl      gpio_mode
    
    @ Set TXD (pin 14) to Alt 5
    mov     r0, #GPIO_TXD
    mov     r1, #GPIO_ALT_5
    bl      gpio_mode

    @ Disable Pull-up/down for RXD and TXD
    
    @ Clear PUD bits from GPIO Pull-up/down register
    ldr     r0, =GPPUD_REG
    ldr     r1, [r0]
    bic     r1, #3              @ Clear bits 1 and 0
    
    str     r1, [r0]
    
    @ Wait for 150 cycles
    .rept 150
    nop
    .endr


    @ Assert clock lines 14 and 15 
    ldr     r0, =GPPUDCLK0_REG
    ldr     r1, [r0]
    ldr     r2, =0x0000C000     @ Set bits 14 and 15
    orr     r1, r2
    str     r1, [r0]
    
    @ Wait for 150 cycles 
    .rept 150
    nop
    .endr
    
    @ Clear clock lines 14 and 15
    ldr     r0, =GPPUDCLK0_REG
    ldr     r1, [r0]
    ldr     r2, =0x0000C000     @ Set bits 14 and 15
    bic     r1, r2
    str     r1, [r0]
    
    @ Enable Recieving and Transmitting
    ldr     r0, =AUX_MU_CNTL_REG
    ldr     r1, [r0]
    orr     r1, #3              @ Bit 0 is recieve, bit 1 is transmit
    
    str     r1, [r0]
    
    
    pop     {pc}                @ And we're done!
    
@@ END UART_INIT
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
    
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ uart_readb()
@  Waits until the UART has a byte, then returns it
@@@@
uart_readb:
    ldr     r0, =AUX_MU_LSR_REG
dready_wait:
    ldr     r1, [r0]
    tst     r1, #1
    beq     dready_wait         @ While bit 0 (data ready) is not set
        
    ldr     r1, =AUX_MU_IO_REG
    ldrb    r0, [r1]        

    
    bx      lr                  @ Byte returned in r0
    
@@ END UART_READB
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
    
    
    
    
    
    

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ uart_writeb(byte)
@  Waits until the UART has space, then sends the byte
@@@@
uart_writeb:
    ldr     r1, =AUX_MU_LSR_REG
tempty_wait:
    ldr     r2, [r1]
    tst     r2, #0x20           @ Bit 5 (transmitter empty)
    beq     tempty_wait         @ Wait until it is set
    
    ldr     r1, =AUX_MU_IO_REG
    strb    r0, [r1]
    
    bx      lr

@@ END UART_WRITEB
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@    
    
    
    
    
    
    
    

    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ uart_print(char *)
@ Prints a null terminated string to the uart
@@@@
uart_print:
    push    { r4, lr }
    mov     r4, r0              @ Save the pointer to our string
uart_print_loop:
    ldrb    r0, [r4], #1        
    cmp     r0, #0              @ Check for the null
    beq     uart_print_end      @ Return if null
    
    bl      uart_writeb         @ Otherwise write the byte
    b       uart_print_loop
uart_print_end:
    pop     { r4, pc }          @ Return if null
    
@@ END UART_PRINT
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    

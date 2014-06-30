@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ gpio.s
@
@ Interfacing methods for the Rasperry Pi's GPIO pins
@@@@

.globl gpio_read
.globl gpio_write
.globl gpio_mode
    
.section .text

.equ FUNC_SELECT_REG_BASE,      0x20200000
.equ SET_REG_BASE,              0x2020001C
.equ CLEAR_REG_BASE,            0x20200028
.equ LEVEL_REG_BASE,            0x20200034

.equ    GPIO_INPUT,     0
.equ    GPIO_OUTPUT,    1
.equ    GPIO_ALT_0,     4
.equ    GPIO_ALT_1,     5
.equ    GPIO_ALT_2,     6
.equ    GPIO_ALT_3,     7
.equ    GPIO_ALT_4,     3
.equ    GPIO_ALT_5,     2

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ gpio_mode(pin, mode)
@  Sets the specified pin to the specified mode 
@  0 input 1 output 4 alt0 5 alt1 6 alt2 7 alt3 3 alt4 2 alt5
@@@@
gpio_mode:
    push    { r4 }
    ldr     r2, =FUNC_SELECT_REG_BASE   @ Base address of the function select registers
    
countl:
    cmp     a1, #10                     @ While the pin is greater than 10
    subge   a1, #10         
    addge   r2, #4                      @ Increment the base address to the next select register 
    bgt     countl
    
    ldr     r4, [r2]
    
    add     a1, a1, lsl #1              @ Multiply the offset by 3 (bits)
                                        
    mov     r3, #7                      @ Bitmask of 111
    bic     r4, r3, lsl a1              @ Shift the bitmask to the right spot
    orr     r4, a2, lsl a1
    
    str     r4, [r2]
    
    pop     { r4 }
    bx      lr
@@ END GPIO_MODE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
 
 
 
 
 
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ gpio_write(pin, val)
@ Where var is 0 or 1
@@@@
gpio_write:
    cmp     a2, #1
    ldreq   r2, =SET_REG_BASE           @ Set if val is 1
    ldrne   r2, =CLEAR_REG_BASE         @ Clear if val is 0

    cmp     a1, #31
    subgt   a1, #32
    addgt   r2, #4
    
    mov     r3, #1
    lsl     r3, a1
    
    str     r3, [r2]
    
    bx      lr
@@ END GPIO_WRITE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ gpio_read(pin)
@ Where var is 0 or 1
@@@@
gpio_read:
    ldr     r2, =LEVEL_REG_BASE         @ level register 0 if pin <= 31
    cmp     a1, #31
    addgt   r2, #4                      @ level register 1 if pin > 31
    

    subgt   a1, #32                     @ Remove the offset of 31 if using reg 1
    
    mov     r3, #1
    
    ldr     r1, [r2]            
    and     r1, r3, lsl a1              @ Bitmask the bit we want
    lsr     r0, r1, a1                  @ move the bit to bit 0
    
    bx      lr                          @ And return
@@ END GPIO_READ
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    



@@@@@@@@@@@@@@@@@@@@@@@@@@@@ DATA SECTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.section .data


@ Page 92
@ Starts at 0x20000000 ( Bus address 0x7E000000)
@ Uart on GPIO TxD 14 RxD 15
@ Function select registers start at 0x20200000
@ 3 bits per GPIO line
@ last 2 bits not used
@ 31-30 not used
@ 0-2 line 0, 3-5 line 1, etc.

@ 000 input,  001 output 
@ 100 Alt 0,  101 Alt 1
@ 110 Alt 2,  111 Alt 3
@ 011 Alt 4,  010 Alt 5 

@ Setting a pin
@ Set 0 (2020001C)  Set 1 (0x20200020
@ set0 0-31    set 1 32-53

@ Clearing a pin 
@ Clear 0( 0x2020028 ) Clear 1( 0x202002C)
@ clear0 0-31 clear1 32-53

@ Getting input (must be in input mode)
@ Level register 0 0x2020034   Level register 1 0x2020038
@ level0 0-31 level1 32-53


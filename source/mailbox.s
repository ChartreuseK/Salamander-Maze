@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ mailbox.s
@@
@ Code for initializing the frame buffer through
@ the mailbox interface.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.globl framebuffer_init

.section .text

.equ    MAILBOX_BASE,   0x2000B880
.equ    MAILBOX_READ,   0x00
.equ    MAILBOX_PEEK,   0x10
.equ    MAILBOX_SENDER, 0x14
.equ    MAILBOX_STATUS, 0x18
.equ    MAILBOX_CONFIG, 0x1C
.equ    MAILBOX_WRITE,  0x20

.equ    MAILBOX_CHANNEL_POWERMANAGE, 0x0
.equ    MAILBOX_CHANNEL_FRAMEBUFFER, 0x1
.equ    MAILBOX_CHANNEL_VCHIQINTER,  0x3
.equ    MAILBOX_CHANNEL_LEDSINTER,   0x4
.equ    MAILBOX_CHANNEL_BUTTONINTER, 0x5
.equ    MAILBOX_CHANNEL_TOUCHSCREEN, 0x6
.equ    MAILBOX_CHANNEL_PROPTAGOUT,  0x8
.equ    MAILBOX_CHANNEL_PROPTAGIN,   0x9


.equ    FB_POINTER,     0x20

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ framebuffer_init
@ Initializes the framebuffer by asking the gpio
@ for the framebuffer described in framebuffer_struct.s
@ through the mailbox interface.
@@@@
framebuffer_init:
    push    { lr }  
    ldr     r1, =MAILBOX_BASE
    add     r1, #MAILBOX_STATUS
    
fbinit_waitmb:
    ldr     r0, [r1]
    tst     r0, #0x80000000                     @ Wait till bit 31 (Full) is clear
    bne     fbinit_waitmb
    
    @@
    @ Mailbox wants the framebuffer struct + 0x40000000 orred with 
    @ the frame buffer channel
    ldr     r3, =framebuffer_info
    add     r3, #0x40000000
    orr     r3, #MAILBOX_CHANNEL_FRAMEBUFFER
    
    ldr     r1, =MAILBOX_BASE
    add     r1, #MAILBOX_WRITE      
    str     r3, [r1]                            @ Write this to the write mailbox
    

    @@
    @ Wait for response
fbinit_waitresp:
    ldr     r1, =MAILBOX_BASE
    add     r1, #MAILBOX_STATUS
    ldr     r0, [r1]
    tst     r0, #0x40000000                     @ Wait till bit 30 (Empty) is clear
    bne     fbinit_waitresp
    
    @@ 
    @ Check response
    ldr     r1, =MAILBOX_BASE
    add     r1, #MAILBOX_READ
    
    ldr     r0, [r1]
    and     r0, #0xF
    cmp     r0, #MAILBOX_CHANNEL_FRAMEBUFFER
    bne     fbinit_waitresp
    
    @@
    @ Check if init succeded 
    ldr     r0, [r1]
    lsr     r0, #4                              @ Bitmask off the upper 28 bits
    lsls    r0, #4                              @ Check if we got a 0 value
    movne   r0, #0                              @ If we didn't return 0 to indicate
    popne   { pc }                              @ an error.
    
    
    ldr     r0, =framebuffer_info
    add     r0, #FB_POINTER
fbinit_waitptr:
    ldr     r1, [r0]
    cmp     r1, #0
    beq     fbinit_waitptr
    
    
    mov     r0, #1                              @ We got a non 0 pointer so we succeded
    pop     { pc }
@@ END FRAMEBUFFER_INIT
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    

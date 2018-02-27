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
@ Initializes the framebuffer
@@@@
framebuffer_init:
    push    { lr }  
    
    bl      frameBufferPointer              @ Get Pi linux framebuffer
    
    ldr     r1, =framebuffer_info
    str     r0, [r1, #FB_POINTER]
    
    mov     r0, #1                          @ We got a non 0 pointer so we succeded
    pop     { pc }
@@ END FRAMEBUFFER_INIT
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    

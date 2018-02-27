.globl framebuffer_info

.section .data

.equ    FB_WIDTH,       0x00
.equ    FB_HEIGHT,      0x04
.equ    FB_PITCH,       0x10
.equ    FB_POINTER,     0x20
.equ    FB_BPP,         0x14

.align 4

framebuffer_info:
    .int    1024                @ Width             0x00
    .int    768                 @ Height            0x04
    .int    1024                @ Virt. Width       0x08
    .int    768                 @ Virt. Height      0x0C
    .int    0                   @ Pitch (GPU set)   0x10
    .int    32                  @ BPP               0x14
    .int    0                   @ Offset X          0x18
    .int    0                   @ Offset Y          0x1C
    .int    0                   @ Pointer (GPU set) 0x20
    .int    0                   @ Size of FB (GPU)  0x24
    @ If in 8bpp mode the 256 16-bit palette entries would 
    @ be appended after here. Not sure if the GPU reads these
    @ live or if any changes would have to be sent over mailbox
    



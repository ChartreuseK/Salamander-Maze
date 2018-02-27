@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ graphics.s
@@
@ A simple graphics library for dealing with
@ bitmapped image tiles, and images. Drawing simple
@ primatives. And a basic disolve effect and clear screen.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.globl putPixel16                       @ x, y, colour
.globl clearScr                         @ 
.globl fillBox                          @ x, y, width, height, colour
.globl outlineBox                       @ x, y, width, height, colour
.globl horizLine                        @ x, y, width, colour
.globl vertLine                         @ x, y, height, colour
.globl putTile_bw_8x8                   @ x, y, tile
.globl putTile_bw_8x8_double            @ x, y, tile
.globl putTile_16x16                    @ x, y, tile
.globl putTile_16x16_alpha              @ x, y, tile
.globl putTile_16x16_double             @ x, y, tile
.globl putTile_16x16_double_alpha       @ x, y, tile
.globl putTile_32x32                    @ x, y, tile
.globl putImage                         @ x, y, image
.globl putImage_double                  @ x, y, image
.globl fadeToBlack                      @ 


.section .text

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our global .equ's
.include "defines.s"

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Offset of the FB_POINTER in the framebuffer_info struct
.equ    FB_POINTER,     0x20



.equ    SCREEN_BYTES, (WIDTH*HEIGHT*BPP)
.equ    SCREEN_WORDS, (WIDTH*HEIGHT)
.equ    WORDS_NEXTPOW,  0x200000        @ Next power of 2 > SCREEN_WORDS



@@@@@@@@@@@@@
@ Convert a 16 bit color to 32-bit
@ Not a true function, arg and return in r4 for speed
@ Just so we can retrofit
@ all regs preserved
conv16_32:
    push    { r5, r6 }
    @ We have RRRR RGGG GGGB BBBB
    @ We want RRRR RRRR GGGG GGGG BBBB BBBB
    @ Red
    and     r6, r4, #0xF800
    mov     r6, r6, LSR #8              @ Move down to 0..7
    orr     r6, r6, LSR #5             @ Move top 3 bits into low 3
    @ Green
    and     r5, r4, #0x07E0             @ Extract green
    mov     r5, r5, LSR #3              @ Move down to 0..7
    orr     r5, r5, LSR #6              @ Move top 2 bits into low 2
    @ Blue 
    and     r4, r4, #0x001F             @ Extract blue
    mov     r4, r4, LSL #3              @ Move up to 8 bits
    orr     r4, r4, LSR #5              @ Move top 3 bits into low 3
    
    orr     r4, r5, LSL #8              @ Add green to blue
    orr     r4, r6, LSL #16             @ Add red
    pop     { r5, r6 }
    bx      lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ fadeToBlack
@  "Randomly" draws black pixels to the fb to dissolve out
@@@@
fadeToBlack:
    push    { r4, r5, lr }
    ldr     r1, =framebuffer_info       @ Get our framebuffer address
    ldr     r1, [r1, #FB_POINTER]       @ Address of the frame buffer
    
    ldr     r3, =0xC218A6F9             @ Random seed for the effect
    mov     r2, #SCREEN_BYTES           @ Number of pixels to draw
    mov     r0, #BLACK                  @ Color black
ftb_loop:
    subs    r2, #1
    popeq   { r4, r5, pc }
    
    mov     r4, #WORDS_NEXTPOW          @ Slightly bigger than the screen size of C0000
    sub     r4, #1                      
    and     r4, r3, r4                  @ We only want the lower bits
    
    cmp     r4, #SCREEN_WORDS           @ Check against the size of the FB
    bge     ftb_afterPixel
    
    lsl     r4, #2                      @ Since we're using 4 bytes per pixel
    str     r0, [r1, r4]        
ftb_afterPixel:
    @ Use a Linear congruential generator to generate some
    @ Pseudo-random numbers for the fade. Constants used
    @ are the Borland C/C++ constants from the wikipedia article
    @ http://en.wikipedia.org/wiki/Linear_congruential_generator
    @@@@@@@@@@@@@
    
    ldr     r4, =22695477               @ Multiplier 
    mul     r3, r4              
    add     r3, #1                      @ Increment
    
    b       ftb_loop
@@ END FADETOBLACK
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@






@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ putPixel16(int, int, int)
@  Draws a pixel at (r0, r1) with colour r2
@  Assuming a 1024x768 screen
@  offset = x + y << 10
@
@@
putPixel16:
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    @add     r0, r1, lsl #10             @ r0 = x + y << 10 
    @                                    @ r0 = x + (y * 1024)
    push    {r2}
    mov     r2, #WIDTH
    mla     r0, r1, r2, r0              @ r0 = x + (y * WIDTH)
    pop     {r2}
    
    lsl     r0, #2                      @ words
    str     r2, [r3, r0]                @ Set the pixel to the colour
    bx      lr
@@ END PUTPIXEL16
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
    
    
    
    
    
    





@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Clear the screen
@@@@
clearScr:
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    mov     r0, #BLACK
    mov     r1, #BLACK
    add     r2, r3, #SCREEN_BYTES       @ 
clrloop:
    strd    r0, [r3], #8                @ Store 8 bytes at a time
    cmp     r2, r3
    bgt     clrloop
    bx      lr
@@ END CLEARSCR
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
    
    
    
    
    
        
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ fillBox(int x, int y, int width, int height, short colour)
@ Fills a box with the specified colour
@ Note colour is passed on stack
@@@@
fillBox:
    push    { r4, r5, lr }              @ We pushed 3x4 bytes onto the stack
    
    @add     r4, r0, r1, lsl #10         @ r4 = x + (y * 1024)
    mov     r4, #WIDTH
    mla     r4, r1, r4, r0              @ r4 = x + (y * WIDTH)
    
    ldr     r0, =framebuffer_info       
    ldr     r0, [r0, #FB_POINTER]       @ Get the Frame buffer address
    add     r0, r4, lsl #2              @ Move us to the start x,y
    
    ldr     r4, [sp, #12]               @ We want the 5th argument, but we have
                                        @ To add the offset that we pushed
                                        
    mov     r1, r2                      @ Save a copy of the width
fillBox_loop:
    str     r4, [r0], #4
    
    subs    r1, #1
    bne     fillBox_loop
    
    sub     r0, r2, lsl #2              @ Subtract the width we wrote * BPP
    add     r0, #WIDTH*BPP              @ One line

    
    mov     r1, r2
    
    subs    r3, #1                      @ Count down the height
    bne     fillBox_loop                @ Still got more rows to go
    
    pop     { r4, r5, lr }
    add     sp, #4                      @ Pop off the argument on the stack
    bx      lr
@@ END FILLBOX
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
     
    
    
    
    
    
    
    
    

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ outlineBox(int x, int y, int width, int height, short colour)
outlineBox:
    push    { r4, r5, r6, r7, r8, lr }  @ We pushed 6x4 bytes onto the stack
    
    ldr     r8, [sp, #(0 + 6*4)]        @ We want the 5th argument, but we have
                                        @ To add the offset that we pushed
    mov     r4, r0
    mov     r5, r1
    mov     r6, r2
    mov     r7, r3
                
    mov     r3, r8                                              
    bl      horizLine                   @ horizLine(x,y,w,colour)
    
    mov     r0, r4                      @ x
    add     r1, r5, r7                  @ y + height ( -1 ?)
    sub     r1, #1
    mov     r2, r6                      @ width
    mov     r3, r8                      @ colour
    bl      horizLine                   @ horizLine(x,y+height,w,colour)
    
    mov     r0, r4                      @ x
    mov     r1, r5                      @ y
    mov     r2, r7                      @ height
    mov     r3, r8                      @ colour
    bl      vertLine
    
    add     r0, r4, r6                  @ x + width ( -1 ?)
    sub     r0, #1                      @ -1
    mov     r1, r5                      @ y 
    mov     r2, r7                      @ height
    mov     r3, r8                      @ colour
    bl      vertLine

    
    pop     { r4, r5, r6, r7, r8, lr }
    add     sp, #4                      @ Pop off the argument on the stack
    bx      lr



















@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ horizLine(int x, int y, int width, int colour)
horizLine:
    @ Calculate the offset in the FB
    @add     r0, r0, r1, lsl #10         @ r4 = x + (y * 1024)
    push    {r2}
    mov     r2, #WIDTH
    mla     r0, r1, r2, r0              @ r0 = x + (y * WIDTH)
    pop     {r2}
    
    ldr     r1, =framebuffer_info       @ Get our framebuffer address
    ldr     r1, [r1, #FB_POINTER]       @ Address of the frame buffer
    add     r1, r0, lsl #2              @ words so we need to mul by 4
    
horizLine_loop:
    str     r3, [r1], #4                @ Draw each pixel
    
    subs    r2, #1
    bne     horizLine_loop              @ While we still have some width to go
    
    bx      lr
@@ END HORIZLINE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
















@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ vertLine(int x, int y, int height, int colour)
vertLine:
    @ Calculate the offset in the FB
    @add     r0, r0, r1, lsl #10         @ r4 = x + (y * 1024)
    push    {r2}
    mov     r2, #WIDTH
    mla     r0, r1, r2, r0              @ r0 = x + (y * WIDTH)
    pop     {r2}
    
    ldr     r1, =framebuffer_info       @ Get our framebuffer address
    ldr     r1, [r1, #FB_POINTER]       @ Address of the frame buffer
    add     r1, r0, lsl #2              @ words so we need to mul by 4
    
vertLine_loop:
    str     r3, [r1]                    @ Draw each pixel, and advance a line\
    add     r1, #WIDTH*BPP              @ One line
    
    
    subs    r2, #1
    bne     vertLine_loop               @ While we still have some height to go
    
    bx      lr
@@ END VERTLINE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@














@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ putTile_bw_8x8(int x,int y, void* tile) 
@ Draws a 8x8 black and white tile
@ Only draws the foreground, background is transparent!
@ Returns the address of the tile to the right, (x+8, y) 
@@@@
putTile_bw_8x8:
    push    { r4, r5, r6, lr }
    
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    @ Calculate the offset in the FB
    @add     r4, r0, r1, lsl #10         @ r4 = x + (y * 1024)
    mov     r4, #WIDTH
    mla     r4, r1, r4, r0              @ r4 = x + (y * WIDTH)

    add     r3, r4, lsl #2              @ Words so we need to mul by 4
    
    mov     r5, #WHITE                  @ White (All ones in the 16 bits)
    mov     r6, #8                      @ 8 rows to draw
    
ptbw88_loop:
    subs    r6, #1                      @ We want to draw 8 rows 
    beq     ptbw88_end                  @ If we're done then we'll return
    
    ldrb    r4, [r2], #1                @ Load the row byte from the tile
    
    tst     r4, #0x80                   @ Now we bitmask each bit from the tile
    strne   r5, [r3], #BPP              @ And either write the next word
    addeq   r3, #BPP                    @ Or skip if the bit isn't set.
    
    tst     r4, #0x40
    strne   r5, [r3], #BPP
    addeq   r3, #BPP
    
    tst     r4, #0x20
    strne   r5, [r3], #BPP
    addeq   r3, #BPP
    
    tst     r4, #0x10
    strne   r5, [r3], #BPP
    addeq   r3, #BPP
    
    tst     r4, #0x8
    strne   r5, [r3], #BPP
    addeq   r3, #BPP
    
    tst     r4, #0x4
    strne   r5, [r3], #BPP
    addeq   r3, #BPP
    
    tst     r4, #0x2
    strne   r5, [r3], #BPP
    addeq   r3, #BPP
    
    tst     r4, #0x1
    strne   r5, [r3], #BPP
    addeq   r3, #BPP
    
    @ Return to the start of the next line
    sub     r3, #8*BPP                  @ Subtract the 8*BPP pixels we wrote
    add     r3, #WIDTH*BPP              @ One line
    
    b       ptbw88_loop
ptbw88_end:
    add     r0, #8                      @ We want to return the x of the next 
                                        @ tile to the right. And the Y (which 
                                        @ is still stored in r1)
    pop     { r4, r5, r6, pc }
@@ END PUTTILE_BW_8x8
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@













@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ putTile_bw_8x8_double(int x,int y, void* tile) 
@ Draws a 8x8 black and white tile 2x scaled
@ Only draws the foreground, background is transparent!
@ Returns the address of the tile to the right, (x+16, y) 
@@@@
putTile_bw_8x8_double:
    push    { r4, r5, r6, lr }
    
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    @ Calculate the offset in the FB
    @add     r4, r0, r1, lsl #10         @ r4 = x + (y * 1024)

    mov     r4, #WIDTH
    mla     r4, r1, r4, r0              @ r4 = x + (y * WIDTH)

    add     r3, r4, lsl #2              @ Words so we need to mul by 4
    
    mov     r5, #WHITE                  @ White (All ones in the 32 bits)
    mov     r6, #8                      @ 8 rows to draw
    
ptbw88d_loop:
    subs    r6, #1                      @ We want to draw 8 rows 
    beq     ptbw88d_end                 @ If we're done then we'll return
    
    ldrb    r4, [r2], #1                @ Load the row byte from the tile
.rept 2                                 @ Draw 2 rows each time

    tst     r4, #0x80                   @ Now we bitmask each bit from the tile
    strne   r5, [r3], #4                @ And either write the next word
    strne   r5, [r3], #4                @ And either write the next word
    addeq   r3, #8                      @ Or skip if the bit isn't set.
    tst     r4, #0x40
    strne   r5, [r3], #4
    strne   r5, [r3], #4
    addeq   r3, #8
    tst     r4, #0x20
    strne   r5, [r3], #4
    strne   r5, [r3], #4           
    addeq   r3, #8
    tst     r4, #0x10
    strne   r5, [r3], #4
    strne   r5, [r3], #4    
    addeq   r3, #8
    tst     r4, #0x8
    strne   r5, [r3], #4
    strne   r5, [r3], #4               
    addeq   r3, #8
    tst     r4, #0x4
    strne   r5, [r3], #4
    strne   r5, [r3], #4              
    addeq   r3, #8
    tst     r4, #0x2
    strne   r5, [r3], #4
    strne   r5, [r3], #4                
    addeq   r3, #8
    tst     r4, #0x1
    strne   r5, [r3], #4
    strne   r5, [r3], #4              
    addeq   r3, #8
    
    @ Return to the start of the next line
    sub     r3, #16*BPP                 @ Subtract the 16*2 pixels we wrote
    add     r3, #WIDTH*BPP              @ One line

.endr


    b       ptbw88d_loop
ptbw88d_end:
    add     r0, #16                     @ We want to return the x of the next 
                                        @ tile to the right. And the Y (which 
                                        @ is still stored in r1)
    pop     { r4, r5, r6, pc }
@@ END PUTTILE_BW_8x8_DOUBLE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@






















@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ putTile_16x16(int x, int y, void *tile)
@  Blits a 16x16 16-bit colour tile to the frame buffer
@@@@
putTile_16x16:
    push    { r4, r5, r6, lr }
    
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    @ Calculate the offset in the FB
    @add     r4, r0, r1, lsl #10         @ r4 = x + (y * 1024)
    mov     r4, #WIDTH
    mla     r4, r1, r4, r0              @ r0 = x + (y * WIDTH)

    add     r3, r4, lsl #2              @ words so we need to mul by 4
    
    mov     r6, #16                     @ 16 rows to blit

pt1616_loop:

    @ Blit one row of tile data

.rept 16
    ldrh    r4, [r2], #2                @ Load 1 word of tile data
    bl      conv16_32   @ Convert r4 (not a compliant func)
    str     r4, [r3], #4
.endr 

    @ Return to the start of the next line
    sub     r3, #16*BPP                 @ Subtract the 16*2 pixels we wrote
    add     r3, #WIDTH*BPP              @ 1024*2 One line
    
    subs    r6, #1 
    bne     pt1616_loop
pt1616_end:
    add     r0, #16                     @ We want to return the x of the next 
                                        @ tile to the right. And the Y (which 
                                        @ is still stored in r1)
    pop     { r4, r5, r6, pc }
@@ END PUTTILE_16x16
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
    
    
    
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ putTile_16x16_double(int x, int y, void *tile)
@  Blits a 16x16 16-bit colour tile scaled 2x to the frame buffer
@@@@
putTile_16x16_double:
    push    { r4, r5, r6, lr }
    
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    @ Calculate the offset in the FB
    @add     r4, r0, r1, lsl #10         @ r4 = x + (y * 1024)
    
    mov     r4, #WIDTH
    mla     r4, r1, r4, r0              @ r0 = x + (y * WIDTH)

    add     r3, r4, lsl #2              @ Words so we need to mul by 4
    
    mov     r6, #16                     @ 16 rows to blit

pt1616d_loop:

    
    @ Blit two rows of tile data

    .rept 16
    ldrh    r4, [r2], #2                @ Load 1 word of tile data
    bl      conv16_32   @ Convert r4 (not a compliant func)
    str     r4, [r3], #4
    str     r4, [r3], #4
    .endr
    
    @ Return to the start of the next line
    sub     r3, #32*BPP                 @ Subtract the 32*2 pixels we wrote
    add     r3, #WIDTH*BPP              @ 1024*2 One line
    sub     r2, #32                     @ Go back in the image to read
                                        @ the same line again

    .rept 16
    ldrh    r4, [r2], #2                @ Load 1 word of tile data
    bl      conv16_32   @ Convert r4 (not a compliant func)
    str     r4, [r3], #4
    str     r4, [r3], #4
    .endr
    
    @ Return to the start of the next line
    sub     r3, #32*BPP                 @ Subtract the 16*2 pixels we wrote
    add     r3, #WIDTH*BPP              @ 1024*2 One line

    subs    r6, #1                      @ Count down the rows
    
    bne     pt1616d_loop
pt1616d_end:
    add     r0, #32                     @ We want to return the x of the next 
                                        @ tile to the right. And the Y (which 
                                        @ is still stored in r1)
    pop     { r4, r5, r6, pc }
@@ END PUTTILE_16x16_DOUBLE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
    
    
    
    
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ putTile_16x16_alpha(int x, int y, void *tile)
@  Blits a 16x16 16-bit colour tile to the frame buffer
@  where black is transparent
@@@@
putTile_16x16_alpha:
    push    { r4, r5, r6, lr }
    
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    @ Calculate the offset in the FB
    @add     r4, r0, r1, lsl #10         @ r4 = x + (y * 1024)
    mov     r4, #WIDTH
    mla     r4, r1, r4, r0              @ r0 = x + (y * WIDTH)
    
    add     r3, r4, lsl #2              @ Words so we need to mul by 4
    
    mov     r6, #16                     @ 16 rows to blit

pt1616a_loop:

    
    @ Blit one rows of tile data

    .rept 16
    ldrh    r4, [r2], #2                @ Load 1 word of tile data
    cmp     r4, #0
    blne    conv16_32   @ Convert r4 (not a compliant func)
    strne   r4, [r3], #4
    addeq   r3, #4
    .endr
        
    @ Return to the start of the next line
    sub     r3, #16*BPP                 @ Subtract the 16*2 pixels we wrote
    add     r3, #WIDTH*BPP              @ 1024*2 One line
    
    subs    r6, #1                      @ Count down the rows
    bne     pt1616a_loop
    
pt1616a_end:
    add     r0, #32                     @ We want to return the x of the next 
                                        @ tile to the right. And the Y (which 
                                        @ is still stored in r1)
    pop     { r4, r5, r6, pc }
@@ END PUTTILE_16x16_ALPHA
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ putTile_16x16_double_alpha(int x, int y, void *tile)
@  Blits a 16x16 16-bit colour tile scaled 2x to the frame buffer
@  where black is transparent
@@@@
putTile_16x16_double_alpha:
    push    { r4, r5, r6, lr }
    
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    @ Calculate the offset in the FB
    @add     r4, r0, r1, lsl #10         @ r4 = x + (y * 1024)
    
    mov     r4, #WIDTH
    mla     r4, r1, r4, r0              @ r4 = x + (y * WIDTH)

    add     r3, r4, lsl #2              @ words so we need to mul by 4
    
    mov     r6, #16                     @ 16 rows to blit

pt1616da_loop:

    
    @ Blit two rows of tile data

    .rept 16
    ldrh    r4, [r2], #2                @ Load 1 word of tile data
    cmp     r4, #0
    blne    conv16_32   @ Convert r4 (not a compliant func)
    strne   r4, [r3], #4
    strne   r4, [r3], #4
    addeq   r3, #8
    .endr
    
    @ Return to the start of the next line
    sub     r3, #32*BPP                 @ Subtract the 32*2 pixels we wrote
    add     r3, #WIDTH*BPP              @ 1024*2 One line
    sub     r2, #32                     @ Go back in the image to read
                                        @ the same line again

    .rept 16
    ldrh    r4, [r2], #2                @ Load 1 word of tile data
    cmp     r4, #0
    blne    conv16_32   @ Convert r4 (not a compliant func)
    strne   r4, [r3], #4
    strne   r4, [r3], #4
    addeq   r3, #8
    .endr
    
    @ Return to the start of the next line
    sub     r3, #32*BPP                 @ Subtract the 16*2 pixels we wrote
    add     r3, #WIDTH*BPP              @ 1024*2 One line
    
    subs    r6, #1                      @ Count down the rows
    bne     pt1616da_loop
    
pt1616da_end:
    add     r0, #32                     @ We want to return the x of the next 
                                        @ tile to the right. And the Y (which 
                                        @ is still stored in r1)
    pop     { r4, r5, r6, pc }
@@ END PUTTILE_16x16_DOUBLE_ALPHA
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ putTile_32x32(int x, int y, void *tile)
@  Blits a 32x32 16-bit colour tile to the frame buffer
@@@@
putTile_32x32:
    push    { r4, r5, r6, lr }
    
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    @ Calculate the offset in the FB
    @add     r4, r0, r1, lsl #10         @ r4 = x + (y * 1024)
    mov     r4, #WIDTH
    mla     r4, r1, r4, r0              @ r4 = x + (y * WIDTH)
    
    add     r3, r4, lsl #2              @ Words so we need to mul by 2
    
    mov     r6, #32                     @ 16 rows to blit

pt3232_loop:
    subs    r6, #1                      @ Count down the rows
    beq     pt3232_end
    
    @ Blit one row of tile data
    
.rept 32
    ldrh    r4, [r2], #2                @ Load 1 word of tile data
    bl      conv16_32   @ Convert r4 (not a compliant func)
    str     r4, [r3], #4
.endr
    
    @ Return to the start of the next line
    sub     r3, #32*BPP                 @ Subtract the 32 pixels * 4
    add     r3, #WIDTH*BPP              @ 1024*2 One line
    
    b       pt3232_loop
pt3232_end:
    add     r0, #32                     @ We want to return the x of the next 
                                        @ tile to the right. And the Y (which 
                                        @ is still stored in r1)
    pop     { r4, r5, r6, pc }
@@ END PUTTILE_32x32
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



















@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ putImage(int x, int y, void *image)
@  Blits an image to the screen, width must be a multiple of 4!
@  First two words at *image must be the width, then the height
@@@@
putImage:
    push    { r4, r5, r6, lr }
    
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    @ Calculate the offset in the FB
    @add     r4, r0, r1, lsl #10         @ r4 = x + (y * 1024)
    mov     r4, #WIDTH
    mla     r4, r1, r4, r0              @ r4 = x + (y * WIDTH)
    
    add     r3, r4, lsl #2              @ words so we need to mul by 4
    
    ldr     r0, [r2], #4                @ Grab the width of the image
    ldr     r1, [r2], #4                @ Grab the height of the image

    mov     r6, r0                      @ Counter for horizontal position in img
pi_loop:
    @ Blit one row of tile data
    .rept 4
    ldrh    r4, [r2], #2                @ Load 1 word of tile data
    bl      conv16_32   @ Convert r4 (not a compliant func)
    str     r4, [r3], #4
    .endr
    
    subs    r6, #4                      @ We wrote 4 pixels
    bgt     pi_loop                     @ Repeat till the row is done
    
    @ Then return to the start of the next line
    sub     r3, r0, lsl #2              @ Subtract the width of the image * BPP
    add     r3, #WIDTH*BPP              @ 1024*2 One line
    
    subs    r1, #1                      @ Count down the height
    movne   r6, r0                      @ Reset the horizontal counter
    
    bne     pi_loop                     @ Keep going till the height is zero

    pop     { r4, r5, r6, pc }          @ If it is, then we're done
@@ END PUTIMAGE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@























@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ putImage_double(int x, int y, void *image)
@  Blits an image to the screen 2x scaled, width must be a multiple of 4!
@  First two words at *image must be the width, then the height
@@@@
putImage_double:
    push    { r4, r5, r6, lr }
    
    ldr     r3, =framebuffer_info       @ Get our framebuffer address
    ldr     r3, [r3, #FB_POINTER]       @ Address of the frame buffer
    
    @ Calculate the offset in the FB
    @add     r4, r0, r1, lsl #10         @ r4 = x + (y * 1024)
    mov     r4, #WIDTH
    mla     r4, r1, r4, r0              @ r4 = x + (y * WIDTH)
    
    add     r3, r4, lsl #2              @ Half words so we need to mul by 2
    
    ldr     r0, [r2], #4                @ Grab the width of the image
    ldr     r1, [r2], #4                @ Grab the height of the image

    mov     r6, r0                      @ Counter for horizontal position in img
pi_double_loop:
    @ Blit one row of tile data
    
    ldrh    r4, [r2], #2                @ Load 1 word of tile data
    bl      conv16_32   @ Convert r4 (not a compliant func)
    str     r4, [r3], #4
    str     r4, [r3], #4
    
    subs    r6, #1                      @ We wrote 1 pixel
    bgt     pi_double_loop                      @ Repeat till the row is done
    
    @ Then return to the start of the next line
    sub     r3, r0, lsl #3              @ Subtract the width of the image * 8
    add     r3, #WIDTH*BPP              @ 1024*2 One line
    mov     r6, r0                      @ Reset the horizontal counter
    sub     r2, r0, lsl #1              @ Go back one line in the image
pi_double_loop2:
    @ Blit the same row again
    ldrh    r4, [r2], #2                @ Load 1 word of tile data
    bl      conv16_32   @ Convert r4 (not a compliant func)
    str     r4, [r3], #4
    str     r4, [r3], #4
    
    
    subs    r6, #1                      @ We wrote 1 pixel
    bgt     pi_double_loop2                     @ Repeat till the row is done
    
    sub     r3, r0, lsl #3              @ Subtract the width of the image * 8
    add     r3, #WIDTH*BPP              @ 1024*2 One line
    mov     r6, r0                      @ Reset the horizontal counter
    
    subs    r1, #1                      @ Count down the height
    movne   r6, r0                      @ Reset the horizontal counter
    
    bne     pi_double_loop                      @ Keep going till the height is zero

    pop     { r4, r5, r6, pc }          @ If it is, then we're done
@@ END PUTIMAGE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

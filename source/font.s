@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ font.s
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Contains my 8x8 bitmap font and functions
@ for writing strings and numbers to the screen
@@@@

.globl writeMsg                         @ string
.globl writeStr                         @ x, y, string
.globl writeStr_double                  @ x, y, string
.globl writeNumber_double               @ x, y, int

.globl char_ascii


.section .text

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our global .equ's
.include "defines.s"


@ Location of the Message area
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.equ    MESSAGE_X,              72
.equ    MESSAGE_Y,              752
.equ    MESSAGE_WIDTH,          1024
.equ    MESSAGE_HEIGHT,         16




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ writeMsg(char *string)
@  Writes a string to the message area
@@@@
writeMsg:
    push    { lr }
    
    push    { r0 }
    mov     r0, #0
    ldr     r1, =MESSAGE_Y
    mov     r2, #1024
    mov     r3, #0          
    push    { r3 }                     @ Fifth argument is colour
    mov     r3, #16
    bl      fillBox
    pop     { r0 }
    
    mov     r2, r0
    ldr     r0, =MESSAGE_X
    ldr     r1, =MESSAGE_Y
    bl      writeStr_double
    pop     { pc }
@@ END WRITEMSG
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@







@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ writeStr(int x, int y, char* string)
@  Draws a asciz string to the screen in normal size font
@@@@
writeStr:
    push    { r6, r7, lr }
    mov     r6, r2
    
    ldr     r7, =char_ascii
writeStr_loop:
    ldrb    r2, [r6], #1                @ Read the next character of the string
    
    cmp     r2, #0
    popeq   { r6, r7, pc }      		@ Return if we get to the end of string
    

    add     r2, r7, r2, lsl #3          @ ASCII * 8 gives the tile offset from
                                        @ char_ascii
    push	{ r1 } 						@ Save the y
    bl      putTile_bw_8x8			    @ Next x is return in r0, 
	pop		{ r1 }

    
    b       writeStr_loop
@@ END WRITESTR
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@








@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ writeNumber_double(int x, int y, int number)
@  Draws a number in double font
@@@@
writeNumber_double:
    push	{ r4, r5, lr }
    
    push	{ r0, r1 } 					@ We don't need these just yet.
    @@@ We need to first mod the number by 10 
    @@@ push the ascii of that onto our stack, 
    @@@ then divide by 10 and repeat until the
    @@@ divide results in 0. Then call Writestr 
    @@@ with the stack pointer.

    ldr		r4, =str_num				@ r4 will be our stack pointer here
    
    ldr		r1, =0x1999999A				@ Approximation of 2^32 / 10
										@ 0x19999999.9999999......
writeNumber_double_loop:
	mov		r5, r2						@ Save the original number
	umull	r0, r2, r1, r2				@ 2^32 / 10  * number
										@ Results in number / 10 in RdHi (r2)
										@ We don't care about what goes in r0
	cmp		r2, #0 						@ Check if we're empty
	beq		writeNumber_double_end
										
	mov		r3, #10
	mul		r0, r2, r3					@ Multiply by 10 again
	
	sub		r0, r5, r0					@ Gives us number % 10 
	
	add		r0, #'0'					@ Offset it to an ascii character 
										
    strb	r0, [r4, #-1]!				@ Push the character onto the stack
    
    b		writeNumber_double_loop
    
writeNumber_double_end:
	mov		r3, #10
	mul		r0, r2, r3					@ Multiply by 10 again
	
	sub		r0, r5, r0					@ Gives us number % 10 
	
	add		r0, #'0'					@ Offset it to an ascii character 
										
    strb	r0, [r4, #-1]!				@ Push the character onto the stack
    

	pop		{ r0, r1 }
	mov		r2, r4
	bl		writeStr_double

    pop		{ r4, r5, pc }
@@ END WRITENUBMER_DOUBLE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@















@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ writeStr_double(int x, int y, char* string)
@  Draws a asciz string to the screen in double size font
@@@@
writeStr_double:
    push    {  r6, r7, lr }
    mov     r6, r2
    
    ldr     r7, =char_ascii
writeStr_double_loop:
    ldrb    r2, [r6], #1                @ Read the next character of the string
    
    cmp     r2, #0
    popeq   {  r6, r7, pc }             @ Return if we get to the end of string
    
    add     r2, r7, r2, lsl #3          @ ASCII * 8 gives the tile offset from
                                        @ char_ascii
    push	{ r1 } 						@ Save the y
    bl      putTile_bw_8x8_double       @ Next x is return in r0, 
	pop		{ r1 }

    
    b       writeStr_double_loop
@@ END WRITESTR_DOUBLE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


















@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Beginning of the bitmapped ascii font              @
@ Offset is char_ascii + (ASCII val * 8)             @
@ Characters are stored as one bit per pixel, 1 = on @
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
char_ascii:
    @ Skip 33 characters so that we're at '!'
    @@@@@@@@@@
    .skip       33 * 8
    char_excl:  .byte 0x18, 0x18, 0x18, 0x18, 0x18, 0x00, 0x18, 0x00
    @ Skip 14 more characters so that we're now at char_0
    .skip       14 * 8

@ Numerical order, multiply number by 8 to get offset
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
char_0:     .byte   0x3C, 0x66, 0x66, 0x66, 0x66, 0x66, 0x3C, 0x00
char_1:     .byte   0x38, 0x78, 0x18, 0x18, 0x18, 0x18, 0xFE, 0x00
char_2:     .byte   0x3C, 0x66, 0x46, 0x0C, 0x18, 0x30, 0xFE, 0x00
char_3:     .byte   0x3C, 0x66, 0x06, 0x3C, 0x06, 0x66, 0x3C, 0x00
char_4:     .byte   0x1E, 0x36, 0x66, 0xFE, 0x06, 0x06, 0x06, 0x00
char_5:     .byte   0xFE, 0xC0, 0xF8, 0x0C, 0x06, 0x0C, 0xF8, 0x00
char_6:     .byte   0x3C, 0x60, 0xC0, 0x7C, 0xC6, 0x66, 0x3C, 0x00
char_7:     .byte   0xFE, 0x06, 0x0C, 0x7E, 0x30, 0x60, 0xC0, 0x00
char_8:     .byte   0x3C, 0xC6, 0xC6, 0x3C, 0xC6, 0xC6, 0x3C, 0x00
char_9:     .byte   0x7C, 0xC6, 0xC6, 0x7E, 0x0C, 0x38, 0xE0, 0x00
char_semicolon:
            .byte   0x00, 0x30, 0x30, 0x00, 0x00, 0x30, 0x30, 0x00
            
@ Skip 3 characters so we're in ASCII order
            .skip       3 * 8

@ Make ascii '>' be the arrow character
char_arrow: .byte   0x80, 0xE0, 0xF8, 0xFF, 0xF8, 0xE0, 0x80, 0x00

@ Skip 2 more characters to keep in ASCII order
            .skip       2 * 8

@ Alphabetical order, multiply position of letter in alphabet by 8 to get the
@ offset for that letter
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
char_A:		.byte	0x38, 0x44, 0xC6, 0xFE, 0xC6, 0xC6, 0xC6, 0x00
char_B:		.byte	0xFC, 0xC6, 0xC6, 0xFC, 0xC6, 0xC6, 0xFC, 0x00
char_C:		.byte	0x7E, 0xE0, 0xC0, 0xC0, 0xC0, 0xE0, 0x7E, 0x00
char_D:		.byte	0xFC, 0xCE, 0xC6, 0xC6, 0xC6, 0xCE, 0xFC, 0x00
char_E:		.byte	0xFE, 0xC2, 0xC0, 0xFC, 0xC0, 0xC2, 0xFE, 0x00
char_F:		.byte	0xFE, 0xC2, 0xC0, 0xFC, 0xC0, 0xC0, 0xE0, 0x00
char_G:		.byte	0x7C, 0xC6, 0xC0, 0xCE, 0xC6, 0xC6, 0x7C, 0x00
char_H:		.byte	0xC6, 0xC6, 0xC6, 0xFE, 0xC6, 0xC6, 0xC6, 0x00
char_I:		.byte	0xFE, 0x18, 0x18, 0x18, 0x18, 0x18, 0xFE, 0x00
char_J:		.byte	0xFE, 0x06, 0x06, 0x06, 0x06, 0xCC, 0x78, 0x00
char_K:		.byte	0xC6, 0xC6, 0xC8, 0xF8, 0xC8, 0xC6, 0xC6, 0x00
char_L:		.byte	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC2, 0xFE, 0x00
char_M:		.byte	0xEE, 0xD6, 0xD6, 0xC6, 0xC6, 0xC6, 0xC6, 0x00
char_N:		.byte	0xC6, 0xE6, 0xF6, 0xD6, 0xDE, 0xCE, 0xC6, 0x00
char_O:		.byte	0x38, 0xEE, 0xC6, 0xC6, 0xC6, 0xEE, 0x38, 0x00
char_P:		.byte	0xF8, 0xC6, 0xFC, 0xC0, 0xC0, 0xC0, 0xE0, 0x00
char_Q:		.byte	0x38, 0x6C, 0xC6, 0xD6, 0xD6, 0xCC, 0x3A, 0x00
char_R:		.byte	0xFC, 0xC6, 0xFC, 0xD8, 0xCC, 0xC6, 0xC6, 0x00
char_S:		.byte	0x7E, 0xC0, 0xC0, 0x7C, 0x06, 0x06, 0xFC, 0x00
char_T:		.byte	0xFE, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x00
char_U: 	.byte	0xC6, 0xC6, 0xC6, 0xC6, 0xC6, 0xC6, 0x7A, 0x00
char_V:		.byte	0xC6, 0xC6, 0xC6, 0xC6, 0x6C, 0x6C, 0x38, 0x00
char_W:		.byte	0xC6, 0xC6, 0xC6, 0xC6, 0xD6, 0xD6, 0x7C, 0x00
char_X:		.byte	0xC6, 0xC6, 0x6C, 0x38, 0x6C, 0xC6, 0xC6, 0x00
char_Y:		.byte	0xC6, 0xC6, 0x6C, 0x38, 0x18, 0x18, 0x18, 0x00
char_Z: 	.byte	0xFE, 0x06, 0x0C, 0x38, 0x60, 0xC0, 0xFE, 0x00

@ Skip 6 characters so we line up with ascii 'a'
            .skip   6 * 8
            
@ Use the same data as the uppercase characters. 
       		.byte	0x38, 0x44, 0xC6, 0xFE, 0xC6, 0xC6, 0xC6, 0x00
       		.byte	0xFC, 0xC6, 0xC6, 0xFC, 0xC6, 0xC6, 0xFC, 0x00
       		.byte	0x7E, 0xE0, 0xC0, 0xC0, 0xC0, 0xE0, 0x7E, 0x00
       		.byte	0xFC, 0xCE, 0xC6, 0xC6, 0xC6, 0xCE, 0xFC, 0x00
       		.byte	0xFE, 0xC2, 0xC0, 0xFC, 0xC0, 0xC2, 0xFE, 0x00
       		.byte	0xFE, 0xC2, 0xC0, 0xFC, 0xC0, 0xC0, 0xE0, 0x00
       		.byte	0x7C, 0xC6, 0xC0, 0xCE, 0xC6, 0xC6, 0x7C, 0x00
       		.byte	0xC6, 0xC6, 0xC6, 0xFE, 0xC6, 0xC6, 0xC6, 0x00
       		.byte	0xFE, 0x18, 0x18, 0x18, 0x18, 0x18, 0xFE, 0x00
       		.byte	0xFE, 0x06, 0x06, 0x06, 0x06, 0xCC, 0x78, 0x00
       		.byte	0xC6, 0xC6, 0xC8, 0xF8, 0xC8, 0xC6, 0xC6, 0x00
       		.byte	0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC2, 0xFE, 0x00
       		.byte	0xEE, 0xD6, 0xD6, 0xC6, 0xC6, 0xC6, 0xC6, 0x00
       		.byte	0xC6, 0xE6, 0xF6, 0xD6, 0xDE, 0xCE, 0xC6, 0x00
       		.byte	0x38, 0xEE, 0xC6, 0xC6, 0xC6, 0xEE, 0x38, 0x00
       		.byte	0xF8, 0xC6, 0xFC, 0xC0, 0xC0, 0xC0, 0xE0, 0x00
       		.byte	0x38, 0x6C, 0xC6, 0xD6, 0xD6, 0xCC, 0x3A, 0x00
       		.byte	0xFC, 0xC6, 0xFC, 0xD8, 0xCC, 0xC6, 0xC6, 0x00
       		.byte	0x7E, 0xC0, 0xC0, 0x7C, 0x06, 0x06, 0xFC, 0x00
       		.byte	0xFE, 0x18, 0x18, 0x18, 0x18, 0x18, 0x18, 0x00
        	.byte	0xC6, 0xC6, 0xC6, 0xC6, 0xC6, 0xC6, 0x7A, 0x00
       		.byte	0xC6, 0xC6, 0xC6, 0xC6, 0x6C, 0x6C, 0x38, 0x00
       		.byte	0xC6, 0xC6, 0xC6, 0xC6, 0xD6, 0xD6, 0x7C, 0x00
       		.byte	0xC6, 0xC6, 0x6C, 0x38, 0x6C, 0xC6, 0xC6, 0x00
       		.byte	0xC6, 0xC6, 0x6C, 0x38, 0x18, 0x18, 0x18, 0x00
        	.byte	0xFE, 0x06, 0x0C, 0x38, 0x60, 0xC0, 0xFE, 0x00

@ Skip the remaining 37 ascii characters just to be safe if we mess
@ up a string when writing.
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
            .skip       5 * 8




.section .data
.align 4



@ Small 0 terminated str_num stack for converting integers to ascii 
@ Full descending
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.skip 32
str_num: .byte	0






/* Font bit patterns

00000000 
00110000 
00110000 
00000000
00000000
00110000
00110000
00000000


00011000 
00011000 
00011000 
00011000
00011000
00000000
00011000
00000000

00111000 
01000100
11000110
11111110
11000110
11000110
11000110
00000000

11111100
11000110
11000110
11111100
11000110
11000110
11111100


01111110
11100000
11000000
11000000
11000000
11100000
01111110


11111100
11001110
11000110
11000110
11000110
11001110
11111100

11111110
11000010
11000000
11111100
11000000
11000010
11111110


11111110
11000010
11000000
11111100
11000000
11000000
11100000


01111100
11000110
11000000
11001110
11000110
11000110
01111100


11000110
11000110
11000110
11111110
11000110
11000110
11000110


11111110
00011000
00011000
00011000
00011000
00011000
11111110


11111110
00000110
00000110
00000110
00000110
11001100
01111000


11000110
11000110
11001100
11111000
11001100
11000110
11000110

11000000
11000000
11000000
11000000
11000000
11000010
11111110

11101110
11010110
11010110
11000110
11000110
11000110
11000110

11000110
11100110
11110110
11010110
11011110
11001110
11000110

00111100
11101110
11000110
11000110
11000110
11101110
00111100

11111100
11000110
11111100
11000000
11000000
11000000
11100000

00111000
01101100
11000110
11010110
11010110
11001100
00111010

11111100
11000110
11111100
11011000
11001100
11000110
11000110

01111110
11000000
11000000
01111100
00000110
00000110
11111100

11111110
00011000
00011000
00011000
00011000
00011000
00011000

11000110
11000110
11000110
11000110
11000110
11000110
01111010

11000110
11000110
11000110
11000110
01101100
01101100
00111000

11000110
11000110
11000110
11000110
11010110
11010110
01111100

11000110
11000110
01101100
00111000
01101100
11000110
11000110

11000110
11000110
01101100
00111000
00011000
00011000
00011000

11111110
00000110
00001100
00111000
01100000
11000000
11111110

@ Numbers

00111100
01100110
01100110
01100110
01100110
01100110
00111100

00111000
01111000
00011000
00011000
00011000
00011000
11111110

00111100
01100110
01000110
00001100
00011000
00110000
11111110

00111100
01100110
00000110
00111100
00000110
01100110
00111100

00011110
00110110
01100110
11111110
00000110
00000110
00000110

11111110
11000000
11111000
00001100
00000110
00001100
11111000

00111100
01100000
11000000
01111100
11000110
01100110
00111100

11111110
00000110
00001100
01111110
00110000
01100000
11000000

00111100
11000110
11000110
01111100
11000110
11000110
00111100

01111100
11000110
11000110
01111110
00001100
00111000
11100000


@ Arrow selector

10000000
11100000
11111000
11111111
11111000
11100000
10000000

*/

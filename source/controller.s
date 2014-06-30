@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ controller.s
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Contains functions for initializing and getting data from
@ the SNES controller 
@@@@


.globl		snes_init
.globl		snes_getstate
.globl      waitForRelease
.globl      waitForButton

.section .text


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our global .equ's
.include "defines.s"


@@@@@@@@@@@@@@
@@ GPIO pins for the SNES controller
.equ	SNES_DAT,		10
.equ	SNES_LAT,		9
.equ	SNES_CLK,		11


@@@@@@@@@@@@@@
@@ Timer delays
.equ	LATCH_DELAY,	12
.equ	CLOCK_DELAY,	6





@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ snes_init
@  Initializes the gpio for the SNES controller
@@@@
snes_init:
	push	{ lr }
	
	mov		r0, #SNES_DAT				@ Data line is input
	mov		r1, #GPIO_INPUT
	bl		gpio_mode
	
	mov		r0, #SNES_LAT				@ Latch line is output
	mov		r1, #GPIO_OUTPUT
	bl		gpio_mode
	
	mov		r0, #SNES_CLK				@ Clock line is output
	mov		r1, #GPIO_OUTPUT
	bl		gpio_mode
	
	mov		r0, #SNES_CLK				@ Leave the clock line high
	mov		r1, #1
	bl		gpio_write
	
	pop		{ pc }
@@ END SNES_INIT
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@





	
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ snes_getstate
@  Returns the current state of the buttons of the SNES controller.
@  0 is pressed, 1 is not pressed
@  Order is B Y Select Start Up Down Left Right A X L R - - - -
@@@@
snes_getstate:
	push	{ r4, r5, lr }
	
	mov		r0, #SNES_CLK				@ Make sure the clock is high
	mov		r1, #1		
	bl		gpio_write
	
	mov		r0, #SNES_LAT				@ Put the latch high
	mov		r1, #1
	bl		gpio_write
	
	mov		r0, #LATCH_DELAY			@ Wait for 12us
	bl		st_sleep
	
	mov		r0, #SNES_LAT
	mov		r1, #0
	bl		gpio_write
	
	mov		r4, #16						@ We're going to read 16 bits
	mov		r5, #0						@ Start with all 0's
	
snes_gs_loop:
	sub		r4, #1
	
	mov		r0, #CLOCK_DELAY			@ Wait 6us
	bl		st_sleep
	
	mov		r0, #SNES_CLK				@ Pull the clock down
	mov		r1, #0	
	bl		gpio_write
	
	mov		r0, #SNES_DAT				@ Get the current bit
	bl		gpio_read
afterread:
	orr		r5,	r0, lsl r4				@ Put the bit in the right position
	
	mov		r0, #CLOCK_DELAY			@ Wait 6us
	
	mov		r0, #SNES_CLK				@ Put the clock back up
	mov		r1, #1	
	bl		gpio_write
	
	cmp		r4, #0
	bne		snes_gs_loop
	
	mov		r0, r5
	pop		{ r4, r5, pc }
@@ END SNES_GETSTATE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@   
    
    
    
    
    
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ waitForRelease
@  Waits until no button is pressed on the controller
@@@@
waitForRelease:
	push	{ lr }
waitForRelease_loop:
	mov		r0, #65536					@ Sleep for ~65ms to debounce 
	bl		st_sleep					@ the button press
	
	bl		snes_getstate
	mov		r1, #-1
	cmp		r0, r1, lsr #16				@ Wait till all 16 buttons bits
	bne		waitForRelease_loop			@ are not pressed.

	pop		{ pc }
@@ END WAITFORRELEASE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@







@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ waitForButton
@  Waits until no button is pressed on the controller
@@@@
waitForButton:
	push	{ lr }
waitForButton_loop:
	mov		r0, #65536					@ Sleep for ~65ms to debounce 
	bl		st_sleep					@ the button press
	
	bl		snes_getstate
	mov		r1, #-1
	cmp		r0, r1, lsr #16				@ Wait till at least one button is pressed
	beq		waitForButton_loop			

	pop		{ pc }
@@ END WAITFORBUTTON
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	

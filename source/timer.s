@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ timer.s
@@
@ Functions dealing with the system timer
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.globl st_sleep
.globl timerFired
.globl initSecondTimer

.globl resetTimer
.globl showTimer
.globl hideTimer
.globl pauseTimer
.globl unpauseTimer


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our global .equ's
.include "defines.s"


.equ	SYSTIMER_BASE,		0x20003000
.equ	SYSTIMER_CS,		0x00
.equ	SYSTIMER_CLO,		0x04
.equ	SYSTIMER_CHI,		0X08
.equ	SYSTIMER_C0,		0X0C
.equ	SYSTIMER_C1,		0X10
.equ	SYSTIMER_C2,		0X14
.equ	SYSTIMER_C3,		0X18



.equ    TIMERTEXT_X,        0
.equ    TIMERTEXT_Y,        0
.equ    TIMERNUM_X,         TIMERTEXT_X + (6 * 16)      @ Right after the text
.equ    TIMERNUM_Y,         TIMERTEXT_Y 
.equ    CLEARBOX_X,         TIMERTEXT_X
.equ    CLEARBOX_Y,         TIMERTEXT_Y
.equ    CLEARBOX_WIDTH,     (10 * 16)                   @ 10 characters wide
.equ    CLEARBOX_HEIGHT,     (1  * 16)                   @ 1 line

.equ    CLEARBOX_SMALL_X,       TIMERNUM_X
.equ    CLEARBOX_SMALL_Y,       TIMERNUM_Y
.equ    CLEARBOX_SMALL_WIDTH,   (4 * 16)                    @ 4 characters wide
.equ    CLEARBOX_SMALL_HEIGHT,  (1  * 16)                   @ 1 line  

.section .text

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@@ st_sleep(int)
@@ Simple timer sleep in micro seconds
@@@@
st_sleep:
	ldr		r2, =SYSTIMER_BASE
	ldr		r1, [r2, #SYSTIMER_CLO]
	add		r0, r1						@ Get the timer offset to end
	
st_sleep_loop:
	ldr		r1, [r2, #SYSTIMER_CLO]
	cmp		r0, r1
	bgt		st_sleep_loop				@ While the wanted time is still
										@ Greater than the current time.
	
	bx		lr							@ Otherwise return
@@ END ST_SLEEP
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ initSecondTimer
@ Sets up a timer for one second from now in C1
@@@@
initSecondTimer:
    ldr		r2, =SYSTIMER_BASE
	mov     r0, #0x2                    @ We want the C1 bit in CS
    str     r0, [r2, #SYSTIMER_CS]      @ Clear the match on C1
    
	ldr		r1, [r2, #SYSTIMER_CLO]
    ldr     r0, =1000000                @ 1000000us = 1s
	add		r1, r0
    str     r1, [r2, #SYSTIMER_C1]

    bx      lr
    

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ timerFired
@  Called by the ISR when the timer in C1 is matched
@@@@
timerFired:
    push    { lr }
    
    bl      initSecondTimer             @ Reset the timer so it will fire again 

    ldr		r1, =SYSTIMER_BASE
	mov     r0, #0x2                    @ We want the C1 bit in CS
    str     r0, [r1, #SYSTIMER_CS]      @ Clear the match on C1

    ldr     r0, =paused
    ldr     r0, [r0]
    cmp     r0, #1                      @ Check if we are paused

    ldr     r1, =seconds
    ldr     r2, [r1]
    addne   r2, #1
    strne   r2, [r1]                    @ Increment the counter if we aren't
     
    ldr     r0, =showtimer
    ldr     r0, [r0]
    cmp     r0, #1                      @ Check if we are showing the timer
    beq     timerFired_drawTimer

    pop     { pc }

timerFired_drawTimer:
    push    { r2 }                      @ Save the number of seconds so we don't
                                        @ Have to load again

    mov     r0, #CLEARBOX_SMALL_X       @ If we are then we go to clear a box
    mov     r1, #CLEARBOX_SMALL_Y
    mov     r2, #CLEARBOX_SMALL_WIDTH
    mov     r3, #BLACK          
    push    { r3 }                      @ 5th argument, colour (black)
    mov     r3, #CLEARBOX_SMALL_HEIGHT
    bl      fillBox                     @ Clear a small area in the top left corner

    mov     r0, #TIMERTEXT_X
    mov     r1, #TIMERTEXT_Y
    ldr     r2, =timer_str
    bl      writeStr_double             @ Write the TIME ELAPSED message to the screen


    mov     r0, #TIMERNUM_X
    mov     r1, #TIMERNUM_Y
    pop     { r2 }                      @ Number of seconds we saved earlier
    bl      writeNumber_double          @ Write the seconds timer to the top left
    
    pop     { pc }

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ resetTimer
@ Resets the timer's counter to 0
@@@@
resetTimer:
    push    { lr }
    ldr     r1, =seconds
    mov     r0, #0
    str     r0, [r1]
    
    bl      initSecondTimer
    
    ldr     r0, =pause_timeleft         @ Reset the time left for the pause 
    ldr     r1, =1000000                @ So that it will go one second from now
    str     r1, [r0]

    pop     { pc }


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ hideTimer
@  Stops the timer from being displayed, does not stop it from counting
@  Also clears it from the screen
@@@@
hideTimer:
    push    { lr }
    ldr     r1, =showtimer
    mov     r0, #0
    str     r0, [r1]
    
    mov     r0, #CLEARBOX_X             @ Then we clear the area
    mov     r1, #CLEARBOX_Y
    mov     r2, #CLEARBOX_WIDTH
    mov     r3, #BLACK          
    push    { r3 }                      @ 5th argument, colour (black)
    mov     r3, #CLEARBOX_HEIGHT
    bl      fillBox                     @ Clear a small area in the top left corner

    pop     { pc }

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ showTimer
@  Enables the timer to be displayed to the screen
@@@@
showTimer:
    push    { lr }
    ldr     r1, =showtimer
    mov     r0, #1
    str     r0, [r1]
    
    
    mov     r0, #CLEARBOX_X             @ Now we're going to clear a box and
    mov     r1, #CLEARBOX_Y             @ Write the timer to the screen
    mov     r2, #CLEARBOX_WIDTH
    mov     r3, #BLACK          
    push    { r3 }                      @ 5th argument, colour (black)
    mov     r3, #CLEARBOX_HEIGHT
    bl      fillBox                     @ Clear a small area in the top left corner

    mov     r0, #TIMERTEXT_X
    mov     r1, #TIMERTEXT_Y
    ldr     r2, =timer_str
    bl      writeStr_double             @ Write the TIME ELAPSED message to the screen


    mov     r0, #TIMERNUM_X
    mov     r1, #TIMERNUM_Y
    ldr     r2, =seconds
    ldr     r2, [r2]
    bl      writeNumber_double          @ Write the seconds timer to the top left
    
    pop     { pc }


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ pauseTimer
@  Pauses the timer so that it is still shown but doesn't count up
@@@@
pauseTimer:
    ldr     r1, =paused
    mov     r0, #1
    str     r0, [r1]
    
    ldr		r2, =SYSTIMER_BASE
    ldr		r1, [r2, #SYSTIMER_CLO]
    ldr     r2, [r2, #SYSTIMER_C1]
    sub     r2, r1                      @ Get the number of microseconds we had
                                        @ Left to the next second
    ldr     r1, =pause_timeleft
    str     r2, [r1]
    
    bx      lr


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ unpauseTimer
@  Unpauses the timer so that it resumes counting
@@@@
unpauseTimer:
    ldr     r1, =paused
    mov     r0, #0
    str     r0, [r1]

    ldr     r0, =pause_timeleft
    ldr     r0, [r0]

    ldr		r2, =SYSTIMER_BASE
    ldr		r1, [r2, #SYSTIMER_CLO]     @ Get the current time
    add     r0, r1                      @ Add the time we had remaining to it
    str     r0, [r2, #SYSTIMER_C1]      @ And set it in the compare register 1
    
    bx      lr


.section .data

.align 4

seconds:    .int 0
showtimer:  .int 0                      @ Start with the timer hidden
paused:     .int 0
pause_timeleft: .int 1000000            @ Time left till the next second was supposed to occur
timer_str:  .ascii "TIME:"
                        

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ player.s
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Contains functions for moving, drawing, and dealing with player actions
@@@@

.globl writeActionsLeft
.globl writeKeysLeft
.globl findStart
.globl drawPlayer
.globl movePlayer
.globl openDoor



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our global .equ's
.include "defines.s"

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ findStart
@ Finds the 'S' character indicating the start square on the board
@ and updates the player X Y to that location. 
@@@@
findStart:
	push	{ r4, r5, r6, lr }
	ldr		r4, =game
	add		r4, #CURMAZE
	
	mov		r5, #0						@ Start at 0, 0
	mov		r6, #0	

findStart_loop:
	mov		r0, r5
	mov		r1, r6
	bl		getSquare
		
	cmp		r0, #'S'					@ If we've found the start square
	
	ldreq	r4, =game
	addeq	r4, #PLAYER	
	streq	r5, [r4, #PLAYER_X]			@ Store that square as the player
	streq	r6, [r4, #PLAYER_Y]			@ x and y location.
	popeq	{ r4, r5, r6, pc }			@ And return
	
	add		r5, #1
	ldr		r0, [r4, #CURMAZE_WIDTH]
	cmp		r5, r0
	bne		findStart_loop
	
	mov		r5, #0
	add		r6, #1
	b       findStart_loop
@@ END FINDSTART
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


	








@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ drawPlayer
@ Draws the player sprite to the maze
@@@@
drawPlayer:
	push	{ r4, lr }
	
	ldr		r2, =game
	
	add		r3, r2, #PLAYER
	ldr		r0, [r3, #PLAYER_X]
	
	add		r2, r2, #CURMAZE
	ldr		r1, [r2, #CURMAZE_X]
    ldr     r4, [r2, #CURMAZE_SIZE]
    
    cmp     r4, #1                      @ If we're doing a large tile set
	addeq   r0, r1, r0, lsl #5			@ Player X * tilewidth (32)
	addne   r0, r1, r0, lsl #4          @ tilewidth(16)

	ldr		r1, [r3, #PLAYER_Y]
	ldr		r2, [r2, #CURMAZE_Y]
    
	addeq	r1, r2, r1, lsl #5			@ Player Y * tilewidth (32)
    addne	r1, r2, r1, lsl #4			@ tilewidth (16)
	
	ldr		r3, [r3, #PLAYER_ORIENTATION]
	cmp		r3, #3
	ldreq	r2, =tile_player_left
	cmp		r3, #2
	ldreq	r2, =tile_player_down
	cmp		r3, #1
	ldreq	r2, =tile_player_right
	cmp		r3, #0
	ldreq	r2, =tile_player_up
	
    cmp     r4, #0                      @ If we're doing a small tile set
    beq     dp_small
	bl		putTile_16x16_double_alpha
	pop		{ r4, pc }
dp_small:
    bl		putTile_16x16_alpha
	pop		{ r4, pc }
@@ END DRAWPLAYER
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	
	
	
	
	
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ movePlayer_s(int direction)
@ 0 up, 1 right, 2 down, 3 left
@@@@
movePlayer_s:
	push	{ lr }
	
	push	{ r0 } 						@ Save the orientation
	ldr		r1, =game
	add		r1, #PLAYER
						
	str		r0, [r1, #PLAYER_ORIENTATION]
	ldr		r0, [r1, #PLAYER_X]			
	ldr		r1, [r1, #PLAYER_Y]			
	
	bl		drawSquare					@ Draw back the sqaure we were
										@ standing on.
	pop		{ r0 }
		
	ldr		r3, =game
	add		r3, #PLAYER			
	ldr		r1, [r3, #PLAYER_X]			
	ldr		r2, [r3, #PLAYER_Y]		
	
	cmp		r0, #0
	subeq	r2, #1
	
	cmp		r0, #1
	addeq	r1, #1
	
	cmp		r0, #2
	addeq	r2, #1
	
	cmp		r0, #3
	subeq	r1, #1
	
	str 	r1, [r3, #PLAYER_X]			
	str		r2, [r3, #PLAYER_Y]	
	
movePlayer_draw:
	bl		drawPlayer					@ Draw the player in the new location

	pop		{ pc }
@@ END MOVEPLAYER_S
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
    
    
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ movePlayer(int direction)
@  Moves the player in the given direction, and checks for walls
@@@@
movePlayer:
	push	{ r4, r5, r6, lr }
	
    push    { r0 }
    ldr     r0, =blank_str              @ Clear the message area
    bl      writeMsg
	pop     { r0 }
    
	ldr		r2, =game
	add		r2, #PLAYER					
	
	ldr		r5, [r2, #PLAYER_X]			
	ldr		r6, [r2, #PLAYER_Y]	
	
	cmp		r0, #0						@ Add/Sub 1 from X/Y depending 
	subeq	r6, #1						@ On the direction we are moving
	cmp		r0, #1						@ 0 up 1 right 2 down 3 left
	addeq	r5, #1
	cmp		r0, #2
	addeq	r6, #1
	cmp		r0, #3
	subeq	r5, #1
	
	mov		r4, r0						@ Save the orientation
	
	mov		r0, r5
	mov 	r1, r6
	bl		getSquare
	
	cmp		r0, #'#'					@ We're trying to move into a wall
	beq     movePlayer_rotate           @ Just rotate the player and exit
	cmp		r0, #'D'					@ We're trying to move into a door
	beq     movePlayer_rotate           @ Just rotate the player and exit
	
	cmp		r0, #'X'					@ We're trying to move into the exit door
	beq     movePlayer_rotate           @ Just rotate the player and exit
	
	cmp		r0, #'K'					@ We're moving into a key!
	beq		movePlayer_key		
	
movePlayer_end:
	mov		r0, r4						
	bl		movePlayer_s
	
    ldr		r6, =game
	add		r6, #PLAYER		
	ldr		r2, [r6, #PLAYER_ACTIONSLEFT] 	@ Decrement the players remaining
	sub		r2, #1							@ actions by 1
	str		r2, [r6, #PLAYER_ACTIONSLEFT]	
    
    bl      writeActionsLeft
	
	pop		{ r4, r5, r6, pc }
	
movePlayer_rotate:
    ldr     r2, =cheating
    ldr     r2, [r2]
    cmp     r2, #1                      @ If we are cheating, let us move through
    beq     movePlayer_end

    ldr		r2, =game
	add		r2, #PLAYER	
	ldr		r5, [r2, #PLAYER_X]			    @ Grab the current square the player
	ldr		r6, [r2, #PLAYER_Y]	            @ is standing on
    str     r4, [r2, #PLAYER_ORIENTATION]   @ Update the players new orientation
    mov		r0, r5
	mov		r1, r6						@ We need to redraw the floor
	bl		drawSquare					@ tile.
    
    bl      drawPlayer                  @ Then we redraw the player on top of it
    
    pop     { r4, r5, r6, pc }
    
movePlayer_key:
	@ r5,r6 contain the tile where the key is
	mov		r0, r5
	mov		r1, r6
	mov		r2, #' '					@ We're replacing the key with a
	bl		setSquare					@ floor tile
	
	mov		r0, r5
	mov		r1, r6						@ We need to redraw the new floor
	bl		drawSquare					@ tile.
	

	ldr		r0, =game
	add		r0, #PLAYER
	ldr		r1, [r0, #PLAYER_KEYS]		@ Increment the player's keys by
	add		r1, #1						@ by one
	str		r1, [r0, #PLAYER_KEYS]
	
    bl      writeKeysLeft
	
	
	b		movePlayer_end
@@ END MOVEPLAYER
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@







@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ openDoor()
@  Tries to open an adjacent door if the player has a key
@@@@
openDoor:
	push	{ r4, r5, r6, lr }
	
	@ First we try and see if we have an adjacent door
	ldr		r6, =game
	add		r6, #PLAYER
	ldr		r4, [r6, #PLAYER_X]
	ldr		r5, [r6, #PLAYER_Y]
	
	mov		r0, r4						@ Check up first
	sub		r1, r5, #1
	bl		getSquare
	cmp		r0, #'D'
	subeq	r5, #1
	beq		openDoor_found
	cmp		r0, #'X'                    @ Check for the exit door
	subeq	r5, #1
	beq		openDoor_exit
	
	add		r0, r4, #1					@ Check right
	mov		r1, r5
	bl		getSquare
	cmp		r0, #'D'
	addeq	r4, #1
	beq		openDoor_found
	cmp		r0, #'X'                    @ Check for the exit door
	addeq	r4, #1
	beq		openDoor_exit
    
	mov		r0, r4						@ Check down
	add		r1, r5, #1
	bl		getSquare
	cmp		r0, #'D'
	addeq	r5, #1
	beq		openDoor_found
	cmp		r0, #'X'                    @ Check for the exit door
	addeq	r5, #1
	beq		openDoor_exit
    
	sub		r0, r4, #1					@ Check left
	mov		r1, r5
	bl		getSquare
	cmp		r0, #'D'
	subeq	r4, #1
	beq		openDoor_found
	cmp		r0, #'X'                    @ Check for the exit door
	subeq	r4, #1
	beq		openDoor_exit
    
	pop		{ r4, r5, r6, pc } 			@ We didn't find a door
	
openDoor_exit:
    @ Now we need to check if the player has a key
	
	ldr		r1, [r6, #PLAYER_KEYS]
	
	cmp		r1, #0						@ Check if the player has any
    beq     openDoor_nokeys             @ keys on them.
    		
										
	sub		r1, #1						@ Take one away
	str		r1, [r6, #PLAYER_KEYS]
	
    bl      writeKeysLeft
    
    ldr		r6, =game
    mov     r0, #STATE_GAME_WON         @ Set the game state to game won
    str     r0, [r6, #STATE]
    
    pop		{ r4, r5, r6, pc }
openDoor_nokeys:
    ldr     r0, =needKey_str
    bl      writeMsg                    @ Write the need key message to the msg area
	pop	    { r4, r5, r6, pc }	        @ And return
    
openDoor_found:
	@ Now we need to check if the player has a key
	
	ldr		r1, [r6, #PLAYER_KEYS]
	
	cmp		r1, #0						@ Check if the player has any
	beq     openDoor_nokeys  			@ keys on them.
										
	sub		r1, #1						@ Take one away
	str		r1, [r6, #PLAYER_KEYS]
	
    bl      writeKeysLeft
	
	@ Finally we'll remove the door
	
	mov		r0, r4
	mov		r1, r5
	mov		r2, #' '					@ Floor tile
	bl		setSquare
	
	mov		r0, r4
	mov		r1, r5
	bl		drawSquare					@ Redraw the floor tile
	
					
								
	ldr		r2, [r6, #PLAYER_ACTIONSLEFT] 	@ Decrement the players remaining
	sub		r2, #1							@ actions by 1
	str		r2, [r6, #PLAYER_ACTIONSLEFT]	
    
    bl      writeActionsLeft
	
	pop		{ r4, r5, r6, pc }
@@ END OPENDOOR
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    

    
    
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ writeActionsLeft
@  Writes the number of actions left to the screen
@@@@
writeActionsLeft:
    push    { lr }
    
    mov		r0, #492                    @ X
	mov		r1, #16                     @ Y
	mov		r2, #48                     @ Width
    mov		r3, #0                      @ Argument 4 - color - on stack
	push	{ r3 }
    mov		r3, #16                     @ Arg 3 - height
	bl		fillBox
	
    ldr		r3, =game
	add		r3, #PLAYER
	ldr		r2, [r3, #PLAYER_ACTIONSLEFT]
	mov		r0, #492
	mov		r1, #16
	bl		writeNumber_double
	
    pop     { pc }
@@ END WRITEACTIONSLEFT
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@






@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ writeKeysLeft
@  Writes the number of keys left to the screen
@@@@
writeKeysLeft:
    push    { lr }
    
    mov		r0, #848                    @ X
	mov		r1, #16                     @ Y
	mov		r2, #48                     @ Width
    mov		r3, #0                      @ Argument 4 - color - on stack
	push	{ r3 }
    mov		r3, #16                     @ Arg 3 - height
	bl		fillBox
	
    ldr		r3, =game
	add		r3, #PLAYER
	ldr		r2, [r3, #PLAYER_KEYS]
	mov		r0, #848
	mov		r1, #16
	bl		writeNumber_double
	
    pop     { pc }
@@ END WRITEKEYSLEFT
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


.align 4
blank_str:      .asciz " "

.align 4
needKey_str:    .asciz "          YOU NEED A KEY TO OPEN THIS DOOR!"

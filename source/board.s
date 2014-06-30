@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ board.s
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Contains functions for dealing with the game board
@@@@


.globl getSquare
.globl setSquare
.globl drawSquare

.globl loadBoard
.globl drawBoard

.globl drawSpecialMaze                  @ Used for loading and drawing a special
                                        @ Maze used for displaying tile images


.section .text
.align 4

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our global .equ's
.include "defines.s"







@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ loadBoard(int width, char *board)
@@@@
loadBoard:
	ldr		r2, =game
	add		r2, #CURMAZE
	
	str		r0, [r2, #CURMAZE_WIDTH]
    
    ldr     r3, [r2, #CURMAZE_SIZE]
    cmp     r3, #1                      @ Check if we're a large maze
    mov     r3, #WIDTH                  @ Width of the screen
    
    subeq     r3, r0, lsl #5            @ Subtract from the width, the maze
                                        @ width multiplied by the tile width(32)
                                        
    subne     r3, r0, lsl #4            @ Subtract from the width, the maze
                                        @ width multiplied by the tile width(16)
                                        
    lsr     r3, #1                      @ Divide by two to get the left offset
    str     r3, [r2, #CURMAZE_X]        
    
    
	
	add		r2, #CURMAZE_BOARD			@ Point to the current board start

loadBoard_loop:
	ldrb	r0, [r1], #1				@ Load from the passed board
	strb	r0, [r2], #1				@ And store on the current board
	
	cmp		r0, #0
	bne 	loadBoard_loop
		

	bx		lr
@@ END LOADBOARD
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@










@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ getSquare(int x, int y)
@ Returns the character describing the square in (x,y)
@@@@
getSquare:
	ldr		r3, =game
	add		r3, #CURMAZE
	ldr		r2, [r3, #CURMAZE_WIDTH]
	
	mul		r1, r2						@ Y * width
	add		r0, r1						@ [x][y]
	add		r0, #CURMAZE_BOARD			@ board[x][y]
	ldrb	r0, [r3, r0]				
	
	bx		lr
@@ END GETSQUARE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@






@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ setSquare(int x, int y, char tile)
@ Sets the character describing the square in (x,y)
@@@@
setSquare:
	push	{ r4 }
	ldr		r3, =game
	add		r3, #CURMAZE
	ldr		r4, [r3, #CURMAZE_WIDTH]
	mul		r1, r4						@ Y * width
	add		r0, r1						@ [x][y]
	add		r0, #CURMAZE_BOARD			@ board[x][y]
	strb	r2, [r3, r0]				
	
	pop		{ r4 }
	bx		lr
@@ END SETSQUARE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@









	

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ drawSquare(int x, int y)
@@@@
drawSquare:
	push    { lr }
    ldr     r2, =game
    add     r2, #CURMAZE
    ldr     r2, [r2, #CURMAZE_SIZE]
    cmp     r2, #0 
    beq     ds_small
    bl      drawSquare_large
    pop     { pc }
ds_small:
    bl      drawSquare_small
    pop     { pc }
@@ END DRAWSQUARE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
















@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ drawBoard()
drawBoard:
	push    { lr }
    ldr     r0, =game
    add     r0, #CURMAZE
    ldr     r0, [r0, #CURMAZE_SIZE]
    cmp     r0, #0 
    beq     db_small
    bl      drawBoard_large
    pop     { pc }
db_small:
    bl      drawBoard_small
    pop     { pc }
@@ END DRAWBOARD
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


	
	



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ drawBoard_large()
drawBoard_large:
	push	{ r4, r5, r6, lr }
	
	mov		r4, #0
	mov		r5, #0
	
	ldr		r6, =game
	add		r6, #CURMAZE
	ldr		r6, [r6, #CURMAZE_WIDTH]
	
drawBoard_large_loop:
	mov		r0, r4
	mov		r1, r5
	bl		drawSquare
	cmp		r0, #1							@ If drawing the tile was not a 
	popeq	{ r4, r5, r6, pc }				@ success we're done.
	
	add		r4, #1
	cmp		r4, r6
	bne		drawBoard_large_loop
	
	mov		r4, #0
	add		r5, #1
	
	b		drawBoard_large_loop
@@ END DRAWBOARD_LARGE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@








	
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ drawBoard_small()
drawBoard_small:
	push	{ r4, r5, r6, lr }
	
	mov		r4, #0
	mov		r5, #0
	
	ldr		r6, =game
	add		r6, #CURMAZE
	ldr		r6, [r6, #CURMAZE_WIDTH]
	
drawBoard_small_loop:
	mov		r0, r4
	mov		r1, r5
	bl		drawSquare_small
	cmp		r0, #1							@ If drawing the tile was not a 
	popeq	{ r4, r5, r6, pc }				@ success we're done.
	
	add		r4, #1
	cmp		r4, r6
	bne		drawBoard_small_loop
	
	mov		r4, #0
	add		r5, #1
	
	b		drawBoard_small_loop
@@ END DRAWBOARD_SMALL
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


    
    
    
    

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ drawSquare_large(int x, int y)
@@@@
drawSquare_large:
	push	{ r4, lr }

	ldr		r4, =game
	add		r4, #CURMAZE
	
	ldr		r2, [r4, #CURMAZE_WIDTH]
	mul		r3, r1, r2					@ y * boardwidth 
	add		r3, r0						@ Get the position in the maze
	

	ldr		r2, [r4, #CURMAZE_X]
	add		r0, r2, r0, lsl #5

	ldr		r2, [r4, #CURMAZE_Y]
	add		r1, r2, r1, lsl #5


	add		r4, #CURMAZE_BOARD
	ldrb	r3, [r4, r3] 					@ Grab the current char
	
	cmp		r3, #0							@ If we hit the end of board square
	moveq	r0, #1
	popeq	{ r4, pc }						@ Return Unsuccessful
	
	mov		r2, #0
	
	cmp		r3, #'#'						@ Load the appropriate tile to draw
	ldreq	r2, =tile_wall
	cmp		r3, #' '
	ldreq	r2, =tile_floor
	cmp		r3, #'K'
	ldreq	r2, =tile_greenkey_ground
	cmp		r3, #'X'
	ldreq	r2, =tile_exit
	cmp		r3, #'S'
	ldreq	r2, =tile_start
	cmp		r3, #'D'
	ldreq	r2, =tile_greendoor
    cmp     r3, #'O'
    beq     drawSquare_large_blackTile
	
	cmp		r2, #0							@ If we didn't pick a tile
	moveq	r0, #0		
	popeq	{ r4, pc }						@ Return Unsuccessful

	bl		putTile_16x16_double			@ Redraw the specified tile.

	mov		r0, #0							@ Successful

	pop		{ r4, pc }

drawSquare_large_blackTile:
    mov     r2, #32                         @ We're drawing 32x32 tiles
    mov     r3, #32
    mov     r4, #0                          @ Black tile
    push    { r4 }                          @ As the fifth argument
    bl      fillBox
    
    mov     r0, #0
    pop     { r4, pc }
@@ END DRAWSQUARE_LARGE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@






    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ drawSquare_small(int x, int y)
@@@@
drawSquare_small:
	push	{ r4, lr }

	ldr		r4, =game
	add		r4, #CURMAZE
	
	ldr		r2, [r4, #CURMAZE_WIDTH]
	mul		r3, r1, r2					@ y * boardwidth 
	add		r3, r0						@ Get the position in the maze
	

	ldr		r2, [r4, #CURMAZE_X]
	add		r0, r2, r0, lsl #4

	ldr		r2, [r4, #CURMAZE_Y]
	add		r1, r2, r1, lsl #4


	add		r4, #CURMAZE_BOARD
	ldrb	r3, [r4, r3] 					@ Grab the current char
	
	cmp		r3, #0							@ If we hit the end of board square
	moveq	r0, #1
	popeq	{ r4, pc }						@ Return Unsuccessful
	
	mov		r2, #0
	
	cmp		r3, #'#'						@ Load the appropriate tile to draw
	ldreq	r2, =tile_wall
	cmp		r3, #' '
	ldreq	r2, =tile_floor
	cmp		r3, #'K'
	ldreq	r2, =tile_greenkey_ground
	cmp		r3, #'X'
	ldreq	r2, =tile_exit
	cmp		r3, #'S'
	ldreq	r2, =tile_start
	cmp		r3, #'D'
	ldreq	r2, =tile_greendoor
    cmp     r3, #'O'
    beq     drawSquare_small_blackTile
	
	cmp		r2, #0							@ If we didn't pick a tile
	moveq	r0, #0		
	popeq	{ r4, pc }						@ Return Unsuccessful

	bl		putTile_16x16       			@ Redraw the specified tile.

	mov		r0, #0							@ Successful

	pop		{ r4, pc }

drawSquare_small_blackTile:
    mov     r2, #16                         @ We're drawing 32x32 tiles
    mov     r3, #16
    mov     r4, #0                          @ Black tile
    push    { r4 }                          @ As the fifth argument
    bl      fillBox
    
    mov     r0, #0
    pop     { r4, pc }
@@ END DRAWSQUARE_SMALL
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@










@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ drawSpecialMaze(int width, char *maze, int tilesize)
@  Loads and draws a special maze to the screen to show large messages
@  Or to draw larger images using small tiles
@  Tilesize: 1 - 32x32  0 - 16x16
@@@@
drawSpecialMaze:
    push    { lr }
    ldr     r3, =game                   @ Grab the game object again
    add     r3, #CURMAZE                @ We need the curmaze sub-structure
    str     r2, [r3, #CURMAZE_SIZE]     @ Store the desired tile size 

    bl		loadBoard                   @ Load the special board
    bl      clearScr                    @ Clear the screen
    bl      drawBoard                   @ And draw the board

    pop     { pc }
@@ END DRAWSPECIALMAZE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

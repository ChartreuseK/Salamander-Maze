@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ gamestate.s
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Contains the structure holding the current state of the game
@@@@

.globl game


.section .text
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our global .equ's
.include "defines.s"



game:
    state:                      .int STATE_MAIN_MENU  

    level:                      .int 1  @ Starting level
    
    player:
        player_x: 			    .int 1	@ Default grid position of player
        player_y: 			    .int 1  @ Should be overridden 
        player_orientation:     .int 2	@ 0 up, 1 right, 2 down, 3 left
        
        player_keys:		    .int 0
        player_actionsleft:	    .int 0
    

    curmaze:
        curmaze_x:		        .int   0        @ Determined by the maze width
        curmaze_y:		        .int  46        @ Always 46px from the top
        curmaze_width:	        .int   0
        curmaze_size:           .int   1        @ 1 = large, 0 = small, for drawing size
        curmaze_board:			.skip MAX_BOARD_WIDTH * MAX_BOARD_HEIGHT
    
    
    




/*
.equ    PLAYER                  (player - game)
.equ	PLAYER_X, 				(player_x - player)
.equ	PLAYER_Y, 				(player_y - player)
.equ	PLAYER_ORIENTATION, 	(player_orientation - player)
.equ	PLAYER_KEYS, 			(player_keys - player)
.equ	PLAYER_ACTIONSLEFT,		(player_actionsleft - player)
.equ	PLAYER_HASWON,			(player_haswon - player)

.equ    CURMAZE,                (curmaze - game)
.equ	BOARD_X, 				(curmaze_board_x - curmaze)
.equ	BOARD_Y, 				(curmaze_board_x - curmaze)
.equ	BOARD_WIDTH,		 	(curmaze_board_width - curmaze)
.equ	BOARD,		 			(curmaze_board - curmaze)

.equ    STATE,                  (state - game)
.equ    LEVEL,                  (level - game)

*/

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ game.s
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Contains functions for setting up and and running the main game
@@@@
.globl checkState
.globl initGame
.globl handleInput

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our global .equ's
.include "defines.s"




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ initGame
@  initialized the gameboard and draws to the screen
@@@@
initGame:
    push    { lr }
    
    ldr     r2, =levels
    ldr     r3, =game
    ldr     r3, [r3, #LEVEL]
    add     r2, r2, r3, lsl #2              @ Use the level number to index the
                                            @ array of maze pointers
    ldr     r2, [r2]                        @ Load the address stored in the array
    
    ldr     r0, [r2, #MAZE_SIZE]            @ Grab the tile size the maze wants
    ldr     r1, =game                       @ Grab the game object again
    add     r1, r1, #CURMAZE                @ We need the curmaze sub-structure
    str     r0, [r1, #CURMAZE_SIZE]         @ And store it to the size
    
    ldr     r0, [r2, #MAZE_WIDTH]           @ We need the maze width
    
    add     r1, r2, #MAZE_BOARD             @ And the maze itself to load the maze
    
    push    { r2 }
    bl      loadBoard                       @ Load board will copy the
                                            @ specified board to the game
    pop     { r2 }
    
    
    ldr     r1, =game
    add     r1, #PLAYER
    
    
    ldr     r2, [r2, #MAZE_MOVES]
    str     r2, [r1, #PLAYER_ACTIONSLEFT]   @ Maze's starting moves
    
    
    mov     r0, #0          
    str     r0, [r1, #PLAYER_KEYS]          @ No keys
    
    mov     r0, #2                          
    str     r0, [r1, #PLAYER_ORIENTATION]   @ Looking downward
    
    
    
    bl      findStart                       @ Find the player's starting 
                                            @ square and set the position.
    bl      clearScr                        @ Clear the screen
                                        
    bl      drawBoard                       @ Render the entire board
    
    bl      drawPlayer                      @ Render the player
    
    bl      writeActionsLeft                
    
    bl      writeKeysLeft
    
    mov     r0, #576
    mov     r1, #16
    ldr     r2, =keys_str
    bl      writeStr_double
    
    mov     r0, #172
    mov     r1, #16
    ldr     r2, =actions_str
    bl      writeStr_double
    
    ldr     r0, =cheating
    mov     r1, #0                      @ Make sure cheating isn't still enabled
    str     r1, [r0]
    
    bl      resetTimer                  @ Make sure the timer is back at 0
    bl      showTimer                   @ Show the time elapsed counter in the top left
    bl      unpauseTimer                @ Make sure it isn't paused
    
    pop     { pc }
@@ END INITGAME
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



    
    
    
    
    
    

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ checkState
@@@@
checkState:
    push    { r4, lr }
    
    ldr     r4, =game
    ldr     r1, [r4, #STATE]            @ Grab the current game state

                                        
    cmp     r1, #STATE_MAIN_MENU        @ Returning to main menu
    beq     state_mainmenu    
    cmp     r1, #STATE_IN_GAME          @ Nothing to be done if we are playing
    beq     state_ingame                    

    cmp     r1, #STATE_GAME_MENU        @ Pause menu
    beq     state_pausemenu
    
    cmp     r1, #STATE_GAME_WON         @ Game won
    beq     state_game_won
    cmp     r1, #STATE_GAME_LOST        @ Game lost
    beq     state_game_lost
    
    cmp     r1, #STATE_GAME_QUIT        @ Inescapeable quit state
state_gamequit:
    beq     state_gamequit
    
    @@ Should not get here, unknown state
 
checkState_end:   
    pop     { r4, pc }

state_ingame:
    add     r2, r4, #PLAYER
    
    ldr     r0, [r2, #PLAYER_ACTIONSLEFT]   
    
    cmp     r0, #0                      @ Check if we ran out of actions
    moveq   r0, #STATE_GAME_LOST        @ If we have the game is lost
    streq   r0, [r4, #STATE]            

    pop     { r4, pc }
state_mainmenu:
    bl      mainMenu

    cmp     r0, #MAINMENU_STARTGAME     @ Start game
    beq     state_mainmenu_start
    
    cmp     r0, #MAINMENU_QUITGAME      @ Quit Game
    moveq   r0, #STATE_GAME_QUIT        @ Update our state
    streq   r0, [r4, #STATE]
    bleq    fadeToBlack
    
    
    pop     { r4, pc }
state_mainmenu_start:              
    bl      fadeToBlack

    bl      initGame
    mov     r0, #STATE_IN_GAME          @ Update our state
    str     r0, [r4, #STATE]
    
    pop     { r4, pc }

state_pausemenu:
    bl      pauseTimer                  @ Pause the timer while we're in the pause menu

    bl      gameMenu                    @ Run the menu code

    cmp     r0, #GAMEMENU_RESTARTGAME   @ Check which menu item was selected
    beq     state_pausemenu_restart      
    cmp     r0, #GAMEMENU_QUITGAME
    beq     state_pausemenu_quit
    
    bl      unpauseTimer                @ Menu was closed so resume timing

    mov     r0, #STATE_IN_GAME          @ Update our state since the menu was 
    str     r0, [r4, #STATE]            @ closed
    
    pop     { r4, pc }
    
state_pausemenu_restart:
    bl      fadeToBlack                 @ Fade to black
    bl      initGame
    mov     r0, #STATE_IN_GAME          @ Update our state
    str     r0, [r4, #STATE]
    
    pop     { r4, pc }

state_pausemenu_quit:
    bl      fadeToBlack                 @ Fade to black
    bl      clearScr                    @ Clear the screen 

    bl      hideTimer                   @ Stop displaying the timer and remove it

    mov     r0, #STATE_MAIN_MENU        @ Update our state
    str     r0, [r4, #STATE]
    
    pop     { r4, pc }
    

state_game_won:
    bl      pauseTimer                  @ Pause the timer so they can see their time

    ldr     r0, =maze_gamewon_width
    ldr     r0, [r0]
    ldr     r1, =maze_gamewon           @ Use a special maze to write out the
                                        @ Game Won message
    mov     r2, #1                      @ Using large tiles
    bl      drawSpecialMaze
    
    ldr     r0, =congratulations_str    @ Write out congratulations string to the
    bl      writeMsg                    @ Message area
    
    bl      waitForRelease              @ Wait for release in case the user lost
                                        @ While pressing a button
    
    bl      waitForButton               @ Then wait for the user to press any button
    
    
    ldr     r0, =game
    ldr     r3, [r0, #LEVEL]            @ Grab the current level
    
    ldr     r2, =num_levels 
    ldr     r2, [r2]                    @ And the highest level
    
    cmp     r3, r2                      @ If we're not at the highest level
    addlt   r3, #1                      @ then increase the level by one
    str     r3, [r0, #LEVEL]            @ Store the new level
    

    bl      hideTimer                   @ Now we can hide the timer    

    mov     r0, #STATE_MAIN_MENU        @ Update our state
    str     r0, [r4, #STATE]
    
    bl      fadeToBlack                 @ Fade to black
    bl      clearScr                    @ Clear the screen just in case    

    bl      waitForRelease              @ And wait for the user to release the button
    
    pop     { r4, pc }
state_game_lost: 

    bl      pauseTimer                  @ Pause the timer so they can see their time

    ldr     r0, =maze_gameover_width
    ldr     r0, [r0]
    ldr     r1, =maze_gameover          @ Use a special maze to write out the
                                        @ Game Over message
    mov     r2, #1                      @ Using large tiles
    bl      drawSpecialMaze
    
    
    ldr     r0, =ungratulations_str     @ Write out the game lost message to the
    bl      writeMsg                    @ Message area
    
    bl      waitForRelease              @ Wait for release in case the user lost
                                        @ While pressing a button
    
    bl      waitForButton               @ Then wait for the user to press any button
    
    bl      hideTimer                   @ Hide the timer from view 

    mov     r0, #STATE_MAIN_MENU        @ Update our state
    str     r0, [r4, #STATE]
    
    bl      fadeToBlack                 @ Fade to black
    bl      clearScr                    @ Clear the screen just in case
    
    bl      waitForRelease              @ And wait for the user to release the button
    
    pop     { r4, pc }
@@ END CHECKSTATE
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

















@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ handleInput
@@@@
handleInput:
    push    { lr }

    bl      snes_getstate
    
    tst     r0, #SNES_Up
    moveq   r0, #0
    beq     move
    
    tst     r0, #SNES_Down
    moveq   r0, #2
    beq     move
    
    tst     r0, #SNES_Left
    moveq   r0, #3
    beq     move
    
    tst     r0, #SNES_Right
    moveq   r0, #1
    beq     move
    
    tst     r0, #SNES_A
    beq     door
    
    tst     r0, #SNES_St
    ldreq   r1, =game
    moveq   r2, #STATE_GAME_MENU
    streq   r2, [r1, #STATE]
    

    
    pop     { pc }
move:
    bl      movePlayer
    
    bl      waitForRelease
    pop     { pc }


door:
    bl      openDoor
    bl      waitForRelease
    pop     { pc }
@@ END HANDLEINPUT
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@








@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ DATA SECTION @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.section .data

.align   4

keys_str:
        .asciz "KEYS COLLECTED: "  
actions_str:
        .asciz "ACTIONS REMAINING: "
congratulations_str:
        .asciz "   CONGRATULATIONS! PRESS ANY KEY TO RETURN TO MENU"
ungratulations_str:
        .asciz "YOU RAN OUT OF ACTIONS! PRESS ANY KEY TO RETURN TO MENU"



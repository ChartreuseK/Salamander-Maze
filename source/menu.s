@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ menu.s
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Contains the functions for handling the main menu and the pause menu
@@@@
.globl mainMenu
.globl gameMenu
.globl cheating

.section .text

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Include our global .equ's
.include "defines.s"

@ Defines for the positions of the menu elements
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
.equ    MENU_HEIGHT,         512
.equ    MENU_WIDTH,          WIDTH / 2                       @ 512
.equ    MENU_X,              (WIDTH - MENU_WIDTH) / 2        @ 256
.equ    MENU_Y,              (HEIGHT - MENU_HEIGHT) / 2      @ 128
.equ    MENU_BG_COLOUR,      0x0000                          @ Black
.equ    MENU_OUTLINE_COLOUR, -1                              @ WHITE

.equ    MENU_STARTGAME_X,    MENU_X + ((MENU_WIDTH)/2) - (5 * 16)
.equ    MENU_STARTGAME_Y,    MENU_Y + (MENU_HEIGHT - 1) - (9 * 16)

.equ    MENU_QUITGAME_X,     MENU_STARTGAME_X
.equ    MENU_QUITGAME_Y,     MENU_STARTGAME_Y + 16          @ One line below

.equ    MENU_LEVELTEXT_X,    MENU_STARTGAME_X - (3 * 16)
.equ    MENU_LEVELTEXT_Y,    MENU_STARTGAME_Y - (3 * 16)

.equ    MENU_LEVELNUM_X,     MENU_LEVELTEXT_X + (14 * 16)
.equ    MENU_LEVELNUM_Y,     MENU_LEVELTEXT_Y


.equ    GAMEMENU_HEIGHT,            128
.equ    GAMEMENU_WIDTH,             WIDTH / 2                       @ 512
.equ    GAMEMENU_X,                 (WIDTH - GAMEMENU_WIDTH) / 2    @ 256
.equ    GAMEMENU_Y,                 (HEIGHT - GAMEMENU_HEIGHT) / 2  @ 128
.equ    GAMEMENU_BG_COLOUR,         0x0003                          @ Dark blue
.equ    GAMEMENU_OUTLINE_COLOUR,    -1                              @ WHITE

.equ    GAMEMENU_RESTARTGAME_X,     GAMEMENU_X + ((GAMEMENU_WIDTH)/2) - (6 * 16)
.equ    GAMEMENU_RESTARTGAME_Y,     GAMEMENU_Y + (GAMEMENU_HEIGHT - 1)- (5 * 16)

.equ    GAMEMENU_QUITGAME_X,        GAMEMENU_RESTARTGAME_X
.equ    GAMEMENU_QUITGAME_Y,        GAMEMENU_RESTARTGAME_Y + 16 @ One line below
   




@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ mainMenu
@ Draws and and deals with the menu selection of the main menu
@@@@
mainMenu:
    push    { r4, lr }
    

    
    mov     r0, #MENU_X
    mov     r1, #MENU_Y
    ldr     r2, =title_menu             @ Draw the fance title menu background
    bl      putImage_double           
    

    mov     r0, #MENU_X
    mov     r1, #MENU_Y
    mov     r2, #MENU_WIDTH
    mov     r3, #MENU_OUTLINE_COLOUR
    push    { r3 }                      @ Load the colour into the 5th argument
    mov     r3, #MENU_HEIGHT
    
    bl      outlineBox
    

    @ Write the level text
    ldr     r0, =MENU_LEVELTEXT_X
    ldr     r1, =MENU_LEVELTEXT_Y
    ldr     r2, =level_str
    bl      writeStr_double
        
        
    @ Write the currently selected level
    ldr     r0, =game
    ldr     r2, [r0, #LEVEL]            @ Grab the current level
    
    mov     r0, #MENU_LEVELNUM_X        @ Now for the number
    ldr     r1, =MENU_LEVELNUM_Y        @
    bl      writeNumber_double
    

    @ Write the state game option    
    ldr     r0, =MENU_STARTGAME_X
    ldr     r1, =MENU_STARTGAME_Y
    ldr     r2, =startGame_str
    
    bl      writeStr_double
    
    @ Write the quit game option
    ldr     r0, =MENU_QUITGAME_X
    ldr     r1, =MENU_QUITGAME_Y
    ldr     r2, =quitGame_str
    
    bl      writeStr_double
    
    
    @ Put the pointer to the left of startgame
   
    ldr     r0, =MENU_STARTGAME_X
    sub     r0, #24
    ldr     r1, =MENU_STARTGAME_Y
    ldr     r2, =pointer_str
    bl      writeStr_double
    
    mov     r4, #0                      @ We're on the first menu element
    
menuLoop:    
    bl      snes_getstate               @ Grab the button pressed
    
    tst     r0, #SNES_Up
    beq     menuUp
    
    tst     r0, #SNES_Down
    beq     menuDown
    
    tst     r0, #SNES_Right
    beq     menuRight
    
    tst     r0, #SNES_Left
    beq     menuLeft
    
    tst     r0, #SNES_A                 @ If we get an A
    moveq   r0, r4                      @ Move the currently selected item to r0
    popeq   { r4, pc }                  @ to return it
    
    b       menuLoop                    @ Keep looping otherwise

menuRight:    
    ldr     r0, =game
    ldr     r3, [r0, #LEVEL]            @ Grab the current level
    
    ldr     r2, =num_levels 
    ldr     r2, [r2]                    @ And the highest level
    
    cmp     r3, r2                      @ If we're already at the highest level
    beq     menuDoneMove                @ Then don't do anything
    
    add     r3, #1                      @ Otherwise increase the level by one
    str     r3, [r0, #LEVEL]
    
    push    { r3 }                      @ Save the current level number
    
    mov     r0, #MENU_LEVELNUM_X        @ Clearing box for level number
    ldr     r1, =MENU_LEVELNUM_Y        @
    mov     r2, #48                     @ 3 characters wide
    mov     r3, #MENU_BG_COLOUR         @ 5th argument is the colour
    push    { r3 }
    mov     r3, #16                     @ 1 tall
    bl      fillBox
    
    pop     { r2 }                      @ Put the current level into r2
    mov     r0, #MENU_LEVELNUM_X        @ Now for the number
    ldr     r1, =MENU_LEVELNUM_Y        @
    bl      writeNumber_double
    
    b       menuDoneMove
menuLeft:
    ldr     r0, =game
    ldr     r3, [r0, #LEVEL]            @ Grab the current level
    
    cmp     r3, #1                      @ If we're already at the lowest level
    beq     menuDoneMove                @ Then don't do anything
    
    sub     r3, #1                      @ Otherwise decrement the level by one
    str     r3, [r0, #LEVEL]
    
    push    { r3 }                      @ Save the current level number
    
    mov     r0, #MENU_LEVELNUM_X        @ Clearing box for level number
    ldr     r1, =MENU_LEVELNUM_Y        @
    mov     r2, #48                     @ 3 characters wide
    mov     r3, #MENU_BG_COLOUR         @ 5th argument is the colour
    push    { r3 }
    mov     r3, #16                     @ 1 tall
    bl      fillBox
    
    pop     { r2 }                      @ Put the current level into r2
    mov     r0, #MENU_LEVELNUM_X        @ Now for the number
    ldr     r1, =MENU_LEVELNUM_Y        @
    bl      writeNumber_double
    
    b       menuDoneMove
    
    
    
menuUp:
    cmp     r4, #0
    beq     menuDoneMove
    
    sub     r4, #1
    
    ldr     r0, =MENU_STARTGAME_X
    sub     r0, #24
    ldr     r1, =MENU_STARTGAME_Y
    mov     r2, #MENU_BG_COLOUR
    push    { r2 }                      @ Colour is the 5th argument
    mov     r2, #16
    mov     r3, #32
    
    bl      fillBox
    
    ldr     r0, =MENU_STARTGAME_X
    sub     r0, #24
    ldr     r1, =MENU_STARTGAME_Y
    add     r1, r4, lsl #4
    ldr     r2, =pointer_str
    bl      writeStr_double
    
    
    b       menuDoneMove
menuDown:
    cmp     r4, #1
    beq     menuDoneMove
    
    add     r4, #1
    
    ldr     r0, =MENU_STARTGAME_X
    sub     r0, #24
    ldr     r1, =MENU_STARTGAME_Y
    mov     r2, #MENU_BG_COLOUR
    push    { r2 }                      @ Colour is the 5th argument
    mov     r2, #16
    mov     r3, #32
    
    bl      fillBox
    
    ldr     r0, =MENU_STARTGAME_X
    sub     r0, #24
    ldr     r1, =MENU_STARTGAME_Y
    add     r1, r4, lsl #4
    ldr     r2, =pointer_str
    bl      writeStr_double
    
    
    b       menuDoneMove
    
menuDoneMove:
    bl      waitForRelease              @ Wait for the user to release the button
    b       menuLoop                    @ Before looking for the next action
@@ END MAIN_MENU
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ gameMenu
@ Draws and and deals with the menu selection of the game/pause menu
@@@@   
gameMenu:
    push    { r4, r5, lr }

    @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    @ Use r5 to keep track of state in cheat code
    @ In the state we're looking for the following buttons
    @ 0 - up, 1 - up, 2 - down, 3 - down, 4 - left, 5 - right, 
    @ 6 -left, 7 -right, 8 - B, 9 - A, 10 - start
    mov     r5, #0

    mov     r0, #GAMEMENU_X
    mov     r1, #GAMEMENU_Y
    mov     r2, #GAMEMENU_WIDTH
    mov     r3, #GAMEMENU_BG_COLOUR
    push    { r3 }                      @ Load the colour into the 5th argument
    mov     r3, #GAMEMENU_HEIGHT
    
    bl      fillBox
    

    mov     r0, #GAMEMENU_X
    mov     r1, #GAMEMENU_Y
    mov     r2, #GAMEMENU_WIDTH
    mov     r3, #GAMEMENU_OUTLINE_COLOUR
    push    { r3 }                      @ Load the colour into the 5th argument
    mov     r3, #GAMEMENU_HEIGHT
    
    bl      outlineBox
    
    
    ldr     r0, =GAMEMENU_RESTARTGAME_X
    ldr     r1, =GAMEMENU_RESTARTGAME_Y
    ldr     r2, =restartGame_str
    
    bl      writeStr_double
    
    
    ldr     r0, =GAMEMENU_QUITGAME_X
    ldr     r1, =GAMEMENU_QUITGAME_Y
    ldr     r2, =quitGame_str
    
    bl      writeStr_double
    

    ldr     r0, =GAMEMENU_RESTARTGAME_X
    sub     r0, #24
    ldr     r1, =GAMEMENU_RESTARTGAME_Y
    ldr     r2, =pointer_str
    bl      writeStr_double
    
    mov     r4, #0                      @ We're on the first menu element
    
    bl      waitForRelease              @ Wait for the user to unpress start
    
gamemenuLoop:    
    bl      snes_getstate
    
    tst     r0, #SNES_Up
    moveq   r0, #0
    beq     gamemenuUp
    
    tst     r0, #SNES_Down
    moveq   r0, #2
    beq     gamemenuDown
    
    tst     r0, #SNES_Left
    beq     gamemenuLeft

    tst     r0, #SNES_Right
    beq     gamemenuRight

    tst     r0, #SNES_B
    beq     gamemenuB

    tst     r0, #SNES_A
    beq     gamemenuAction
    
    tst     r0, #SNES_St
    beq     gamemenuClose
    
    b       gamemenuLoop

gamemenuAction:
    cmp     r5, #9                          @ Up, Up, Down, Down, Left, Right, Left, Right, B, A
    addeq   r5, #1
    movne   r5, #0
    beq     gamemenuDoneMove                @ If we are in the middle of the cheat, ignore the normal
                                            @ Action of A

    bl      waitForRelease                  @ Otherwise we return the current menu item
    mov     r0, r4
    pop     { r4, r5, pc }

gamemenuClose:
    cmp     r5, #10                         @ Up, up, down, down, left, right, left, right, b, a, start
    movne   r5, #0                          @ Failed at pressing start to end the code...
    bleq    konamiCode                      @ Successfully entered the code, woo!

    bl      drawBoard                       @ Render the entire board
    
    bl      drawPlayer                      @ Render the player
    
    bl      waitForRelease
    
    mov     r0, #GAMEMENU_NOACTION
    pop     { r4, r5, pc }
    
gamemenuLeft:
    cmp     r5, #4                          @ Up, Up, Down, Down, Left
    addeq   r5, #1
    beq     gamemenuDoneMove


    cmp     r5, #6                          @ Up, Up, Down, Down, Left, Right, Left
    addeq   r5, #1
    movne   r5, #0                          @ Failed the cheat
    b       gamemenuDoneMove
gamemenuRight:
    cmp     r5, #5                          @ Up, Up, Down, Down, Left, Right
    addeq   r5, #1
    beq     gamemenuDoneMove
    
    cmp     r5, #7                          @ Up, Up, Down, Down, Left, Right, Left, Right
    addeq   r5, #1
    movne   r5, #0

    b       gamemenuDoneMove
gamemenuB:
    cmp     r5, #8                          @ Up, Up, Down, Down, Left, Right, Left, Right, B
    addeq   r5, #1
    movne   r5, #0                          @ Failed the cheat
    b       gamemenuDoneMove
gamemenuUp:
    cmp     r5, #0                          @ Cheat code is looking for up
    addeq   r5, #1
    beq     gm_up_aftercheat
    
    cmp     r5, #1                          @ Followed by up
    addeq   r5, #1
    movne   r5, #0                          @ Failed the cheat code restart
    
gm_up_aftercheat:
    cmp     r4, #0
    beq     gamemenuDoneMove
    
    sub     r4, #1
    
    ldr     r0, =GAMEMENU_RESTARTGAME_X
    sub     r0, #24
    ldr     r1, =GAMEMENU_RESTARTGAME_Y
    mov     r2, #GAMEMENU_BG_COLOUR
    push    { r2 }                      @ Colour is the 5th argument
    mov     r2, #16
    mov     r3, #32
    
    bl      fillBox
    
    ldr     r0, =GAMEMENU_RESTARTGAME_X
    sub     r0, #24
    ldr     r1, =GAMEMENU_RESTARTGAME_Y
    add     r1, r4, lsl #4
    ldr     r2, =pointer_str
    bl      writeStr_double
    
    
    b       gamemenuDoneMove
gamemenuDown:
    cmp     r5, #3                          @ Up, Up, Down, Down
    addeq   r5, #1
    beq     gm_down_aftercheat
    
    cmp     r5, #2                          @ Up, Up, Down
    addeq   r5, #1
    movne   r5, #0                          @ Failed the cheat code
    

gm_down_aftercheat:
    cmp     r4, #1
    beq     gamemenuDoneMove
    
    add     r4, #1
    
    ldr     r0, =GAMEMENU_RESTARTGAME_X
    sub     r0, #24
    ldr     r1, =GAMEMENU_RESTARTGAME_Y
    mov     r2, #GAMEMENU_BG_COLOUR
    push    { r2 }                      @ Colour is the 5th argument
    mov     r2, #16
    mov     r3, #32
    
    bl      fillBox
    
    ldr     r0, =GAMEMENU_RESTARTGAME_X
    sub     r0, #24
    ldr     r1, =GAMEMENU_RESTARTGAME_Y
    add     r1, r4, lsl #4
    ldr     r2, =pointer_str
    bl      writeStr_double
    
    
    b       gamemenuDoneMove
gamemenuDoneMove:
    bl      waitForRelease
    b       gamemenuLoop

@@ END GAMEMENU
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@



@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ komaniCode
@  User entered the konami code in the pause menu
@  Let's give them a reward for it.
@@@@
konamiCode:
    push    { lr }
    ldr     r0, =cheat_str
    bl      writeMsg                    @ Tell the user
    
    ldr     r0, =cheating
    mov     r1, #1                      @ Enable walking through walls
    str     r1, [r0]
    
    pop     { pc }


    
.section .data

cheating:           .int 0

level_str:          .asciz "LEVEL SELECT:"
startGame_str:      .asciz "START GAME"
quitGame_str:       .asciz "QUIT GAME"
restartGame_str:    .asciz "RESTART GAME"
cheat_str:          .asciz "WHAT A CHEATER! GO AHEAD WALLS DO NOT MATTER"
pointer_str:        .asciz ">"


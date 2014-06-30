@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ defines.s @@     Global .equ directives       @@@@@@@@@@@@@@@@@@@@@@@@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@


@@@@@@@@@@@@@@
@ Size of our screen
.equ    WIDTH,          1024
.equ    HEIGHT,         768

@@@@@@@@@@@@@@
@@ Bitmasks for the various buttons
.equ    SNES_B,         0x8000
.equ    SNES_Y,         0x4000
.equ    SNES_Sl,        0x2000
.equ    SNES_St,        0x1000
.equ    SNES_Up,        0x0800
.equ    SNES_Down,      0x0400
.equ    SNES_Left,      0x0200
.equ    SNES_Right,     0x0100
.equ    SNES_A,         0x0080
.equ    SNES_X,         0x0040
.equ    SNES_L,         0x0020
.equ    SNES_R,         0x0010

@@@@@@@@@@@@@@
@ Maximum size of our gameboard
.equ    MAX_BOARD_WIDTH, 60 
.equ    MAX_BOARD_HEIGHT, 60


@@@@@@@@@@@@@@
@ GPIO constants
.equ    GPIO_INPUT,     0
.equ    GPIO_OUTPUT,    1
.equ    GPIO_ALT_0,     4
.equ    GPIO_ALT_1,     5
.equ    GPIO_ALT_2,     6
.equ    GPIO_ALT_3,     7
.equ    GPIO_ALT_4,     3
.equ    GPIO_ALT_5,     2

@@@@@@@@@@@@@@
@ Game states

.equ    STATE_MAIN_MENU,      0
.equ    STATE_IN_GAME,        1
.equ    STATE_GAME_MENU,      2
.equ    STATE_GAME_WON,       3
.equ    STATE_GAME_LOST,      4
.equ    STATE_GAME_QUIT,      5

@@@@@@@@@@@@@@
@ Game struct offsets (had to use hardcoded offsets)
.equ    STATE,                  0
.equ    LEVEL,                  4

.equ    PLAYER,                 8
.equ    PLAYER_X,               0
.equ    PLAYER_Y,               4
.equ    PLAYER_ORIENTATION,     8
.equ    PLAYER_KEYS,            12
.equ    PLAYER_ACTIONSLEFT,     16

.equ    CURMAZE,                28
.equ    CURMAZE_X,              0
.equ    CURMAZE_Y,              4
.equ    CURMAZE_WIDTH,          8
.equ    CURMAZE_SIZE,           12
.equ    CURMAZE_BOARD,          16


@@@@@@@@@@@@@@
@ Maze struct offsets
.equ    MAZE_WIDTH,             0
.equ    MAZE_MOVES,             4
.equ    MAZE_SIZE,              8
.equ    MAZE_BOARD,             12



@@@@@@@@@@@@@
@ Game menu returns
.equ    GAMEMENU_RESTARTGAME,    0
.equ    GAMEMENU_QUITGAME,       1
.equ    GAMEMENU_NOACTION,       -1

@@@@@@@@@@@@@
@ Main menu returns
.equ    MAINMENU_STARTGAME,      0
.equ    MAINMENU_QUITGAME,       1


@@@@@@@@@@@@@
@ Common Colours
.equ    BLACK,                   0
.equ    WHITE,                   -1         @ -1 = 0xFFFF FFFF, since we only care about the lower 16 bits
                                            @ That gives us white that we can use directly with mov intructions

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ mazes.s
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Contains the mazes for the game
@@@@

.globl levels
.globl num_levels

.section .text

levels: .word 0
        .word maze1
        .word maze2
        .word maze3
        .word maze4
        .word maze5
        .word maze6
        .word maze7
        .word maze9
        .word -1
        
num_levels: .int 8


@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@    #   -    Wall tile
@    D   -    Door Wall tile
@    X   -    Exit Door Wall tile
@        -    Floor tile
@    S   -    Start Floor tile
@    K   -    Key Floor tile
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

.align 4
@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Maze 1, 16x16
@@@@@@@@@@@@@@@@@@@@@@@@@@@
maze1:
    .int    16                  @ Width
    .int    150                 @ Actions
    .int    1                   @ Draw the maze with large 32x32 tiles
maze1_board:
    .ascii "################"
    .ascii "#S#        #  K#"
    .ascii "# # # #### # ###"
    .ascii "#K# # #    #   #"
    .ascii "# D # # ###### #"
    .ascii "##### #   #    #"
    .ascii "#K    ### D ####"
    .ascii "# #####KD ####K#"
    .ascii "# #   # # D  # #"
    .ascii "#   # # # ## # #"
    .ascii "# # #   # #    #"
    .ascii "### ##### # ####"
    .ascii "#X#KD     #    #"
    .ascii "# ######### ## #"
    .ascii "#         D    #"
    .asciz "################"


.align 4
@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ Maze 2, 21x21
@@@@@@@@@@@@@@@@@@@@@@@@@@@
maze2:
    .int    21                  @ Width
    .int    196                 @ Actions
    .int    1                   @ Draw the maze with large 32x32 tiles
maze2_board:
    .ascii "#####################"
    .ascii "#S#   #             #"
    .ascii "# # # # ######### # #"
    .ascii "# # # D #K        # #"
    .ascii "# ### ##### #########"
    .ascii "#   # #   #   D #K  #"
    .ascii "### # # # # ### ### #"
    .ascii "#   # D # # # # #   #"
    .ascii "# ### ### # # # # ###"
    .ascii "#   # #   #   #   # #"
    .ascii "### # # ####### ### #"
    .ascii "#   # #   #         #"
    .ascii "# ### ### # ####### #"
    .ascii "#   # #   # D #   # #"
    .ascii "# # # # ##### # # # #"
    .ascii "# # # #   #   # # # #"
    .ascii "# ### ### # # # # # #"
    .ascii "#     #K#   # # # #K#"
    .ascii "# ##### # ### # # ###"
    .ascii "#       #  K# D #   X"
    .asciz "#####################"
    
.align 4
maze3:
    .int  29                    @ Width
    .int  150                   @ Actions   @ 157 sol 1  125 sol2
    .int  1                     @ Large tiles
    .ascii "#############################"
    .ascii "#   #       # K #           #"
    .ascii "# # # ##### # #   # ### ### #"
    .ascii "#K# D     #   ### #   #   # #"
    .ascii "### ########### # # ##### ###"
    .ascii "#   #     #K#   ### #   #   #"
    .ascii "# ### # #   D #     # #   # #"
    .ascii "#     # ##### ####### ##### #"
    .ascii "# #####       #       # # # #"
    .ascii "# #      # ####### # #    # #"
    .ascii "# # ###### #     # # #### # #"
    .ascii "# #      # # #X# # #    # D #"
    .ascii "# # ###  # # ### # # ## # ###"
    .ascii "# D #    # D       #    #   #"
    .ascii "# ######################### #"
    .ascii "#     # #           # #   # #"
    .ascii "# ##### # ##### ##### ### # #"
    .ascii "#     #       # #   #       #"
    .ascii "##### ####### # # # ##### ###"
    .ascii "#              S  #         #"
    .asciz "#############################"

.align 4
maze4:
    .int    21                  @ Width
    .int    190                 @ Actions
    .int    1                   @ Large tiles
    .ascii "#####################"
    .ascii "# #   # #K# # #   #S#"
    .ascii "# # # # # # # # # # #"
    .ascii "#   #K# # # # # # # #"
    .ascii "# # # D # # D # # D #"
    .ascii "# # ### # # # # ### #"
    .ascii "# # # # # # # # # #K#"
    .ascii "# # # # # ### # # D #"
    .ascii "# # # # # D #   # ###"
    .ascii "# # # # #K# # # # # #"
    .ascii "# # D # ### # # # D #"
    .ascii "# ### # # # # # # # #"
    .ascii "# # # # # # # #   # #"
    .ascii "#   #   #   # # # # #"
    .ascii "# # # # # # # ##### #"
    .ascii "### # # # # #K#   # #"
    .ascii "# D # # # # # # # # #"
    .ascii "# # # #   # ### # # #"
    .ascii "#X# # #K# #     #   #"
    .asciz "#####################"
    
.align 4
maze5:
    .int    21                  @ Width
    .int    250                 @ Actions
    .int    1                   @ Large Tiles
    .ascii "#####################"
    .ascii "#X                D #"
    .ascii "# ################# #"
    .ascii "# # D           D # #"
    .ascii "### ############# # #"
    .ascii "# # #K         K# # #"
    .ascii "# # ###### ###### # #"
    .ascii "#   #           # # #"
    .ascii "# # ########## ## # #"
    .ascii "# # D           # # #"
    .ascii "# # ############# # #"
    .ascii "# # #             # #"
    .ascii "# # ###### ###### # #"
    .ascii "# # #          K# D #"
    .ascii "# # # ########### # #"
    .ascii "# #             # # #"
    .ascii "# ################# #"
    .ascii "# D                 #"
    .ascii "################### #"
    .ascii "#K                 S#"
    .asciz "#####################"
    
.align 4
maze6:
    .int    28
    .int    220
    .int    1

    .ascii "############################"
    .ascii "#   D    D   ##  KDD       #"
    .ascii "# #### ##### ## ##### #### #"
    .ascii "#K#### ##### ## ##### #### #"
    .ascii "#    D  D       D   D  D   #"
    .ascii "# #### ## ######## ## #### #"
    .ascii "#      ##   K##  D ## D    #"
    .ascii "###### ##### ## ##### ######"
    .ascii "OOOOO# ## D  D     ## #OOOOO"
    .ascii "###### ## #### ### ## ######"
    .ascii "#S     D  #K    K# D  D  DX#"
    .ascii "###### ## ######## ## ######"
    .ascii "OOOOO# ##          ## #OOOOO"
    .ascii "###### ## ######## ## ######"
    .ascii "#   DD  D  D ## D  D  D    #"
    .ascii "#K#### ##### ## ##### #### #"
    .ascii "#   ##       DD     D ##   #"
    .ascii "### ## ## ######## ## ## ###"
    .ascii "#   DD ## DD ##    ##      #"
    .ascii "#K########## ## ########## #"
    .ascii "#    D                     #"
    .asciz "############################"

.align 4
maze7:
    .int    28
    .int    290
    .int    1
    .ascii "############################"
    .ascii "#S           #            X#"
    .ascii "#### # ############# #######"
    .ascii "# D  #    D        # D     #"
    .ascii "# ####### ######## ####### #"
    .ascii "#    #       D #         D #"
    .ascii "# ## # ##### # ######### ###"
    .ascii "# K# #  K#K  # D         D #" 
    .ascii "# ############ ########### #"
    .ascii "#   D  #K                  #"
    .ascii "###### ########### #########"
    .ascii "#         D                #"
    .ascii "## ########### ### #########"
    .ascii "#            #  K#         #"
    .ascii "############ ############# #"
    .ascii "#            D   #   D     #"
    .ascii "# ########## ###   #########"
    .ascii "# #    #K#K# D #####     # #"
    .ascii "#   # K#   ###     #K# #K# #"
    .ascii "# ###### # D ##### ### ### #"
    .ascii "#   D    # #               #"
    .asciz "############################"
 
.align 4
maze9:
    .int    35              @ Width
    .int    320             @ Actions, 290 is a good solution
    .int    0               @ Small tiles
    .ascii "###################################"
    .ascii "#S  #       #     #   #           #"
    .ascii "### # ### # # ### # # # ######### #"
    .ascii "#   #   # #K# #   # # # D     #K# #"
    .ascii "# ##### # ### # ### # # # ### # # #"
    .ascii "# #     # #   #   # # # #   # #   #"
    .ascii "# ### ### # ##### # # # ### # ### #"
    .ascii "#     #K  # #       # # # # #     #"
    .ascii "### ####### # ####### # # # #######"
    .ascii "# # #       #     #   # # #  D    #"
    .ascii "# # # ########### # ### # ####### #"
    .ascii "# D #   #         # #   #     D   #"
    .ascii "# ##### # ######### # ##### ### ###"
    .ascii "#       # D #   #         # #   #K#"
    .ascii "########### # # # ### # ### # ### #"
    .ascii "#           # # # #   #   # #   # #"
    .ascii "# ########### # ###K#####K# ### # #"
    .ascii "# #     #   # #   #   #   # #   # #"
    .ascii "# # # ### # # ### ### # ### # ### #"
    .ascii "# # #     # D # #     # D   # #   #"
    .ascii "# # ####### ### ############# # # #"
    .ascii "#   #           #   #   #   #   # #"
    .ascii "##### ##### # ### # # # # # # #####"
    .ascii "#  K# #     #   # # # #   # # D   #"
    .ascii "# ### # ####### # # # # ### # ### #"
    .ascii "# #   #   #   # D #   # #K# #   # #"
    .ascii "# # ##### ### # ####### # # ##### #"
    .ascii "#   #   D     # #     #   #  D  # #"
    .ascii "##### ### ####### # # ######### # #"
    .ascii "#   #  K# # #     # #   D       # #"
    .ascii "# # ##### # # ##### ######### ### #"
    .ascii "# # K #   #       # #         #   #"
    .ascii "# ### # ########### # ### #########"
    .ascii "#   #   D           #   #         X"
    .asciz "###################################"





.align 4
maze0:
    .int    28
    .int    1000
    .int    1

    .ascii "############################"
    .ascii "#KKKKKKKKKKKK##KKKKKKKKKKKK#"
    .ascii "#K####K#####K##K#####K####K#"
    .ascii "#K####K#####K##K#####K####K#"
    .ascii "#KKKKKKKKKKKKKKKKKKKKKKKKKK#"
    .ascii "#K####K##K########K##K####K#"
    .ascii "#KKKKKK##KKKK##KKKK##KKKKKK#"
    .ascii "######K#####K##K#####K######"
    .ascii "OOOOO#K##KKKKKKKKKK##K#OOOOO"
    .ascii "######K##K###KK###K##K######"
    .ascii "#SKKKKKDKK#KKKKKK#KKDKKKKKX#"
    .ascii "######K##K########K##K######"
    .ascii "OOOOO#K##KKKKKKKKKK##K#OOOOO"
    .ascii "######K##K########K##K######"
    .ascii "#KKKKKKKKKKKK##KKKKKKKKKKKK#"
    .ascii "#K####K#####K##K#####K####K#"
    .ascii "#KKK##KKKKKKKKKKKKKKKK##KKK#"
    .ascii "###K##K##K########K##K##K###"
    .ascii "#KKKKKK##KKKK##KKKK##KKKKKK#"
    .ascii "#K##########K##K##########K#"
    .ascii "#KKKKKKKKKKKKKKKKKKKKKKKKKK#"
    .asciz "############################"

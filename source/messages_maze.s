.globl maze_gameover
.globl maze_gameover_width
.globl maze_gamewon
.globl maze_gamewon_width
.globl titlemenu_bg_width
.globl titlemenu_bg
.align 4

maze_gameover_width:
	.int	30
maze_gameover:
.ascii "##############################"
.ascii "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
.ascii "O#####OOO#####OOO##O##OO######"
.ascii "#OOOOOOO#OOOOO#O#OO#OO#O#OOOOO"
.ascii "#OOOOOOO#OOOOO#O#OO#OO#O#OOOOO"
.ascii "#OOO###O#######O#OO#OO#O####OO"
.ascii "#OOOOO#O#OOOOO#O#OOOOO#O#OOOOO"
.ascii "#OOOOO#O#OOOOO#O#OOOOO#O#OOOOO"
.ascii "O#####OO#OOOOO#O#OOOOO#O######"
.ascii "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
.ascii "O#####OO#OOOOO#O#######O#####O"
.ascii "#OOOOO#O#OOOOO#O#OOOOOOO#OOOO#"
.ascii "#OOOOO#OO#OOO#OO#OOOOOOO#OOOO#"
.ascii "#OOOOO#OO#OOO#OO####OOOO#####O"
.ascii "#OOOOO#OOO#O#OOO#OOOOOOO#OO#OO"
.ascii "#OOOOO#OOO#O#OOO#OOOOOOO#OOO#O"
.ascii "O#####OOOOO#OOOO#######O#OOOO#"
.ascii "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
.asciz "##############################"

.align 4

maze_gamewon_width:
	.int	30
maze_gamewon:
.ascii "##############################"
.ascii "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
.ascii "O#####OOO#####OOO##O##OO######"
.ascii "#OOOOOOO#OOOOO#O#OO#OO#O#OOOOO"
.ascii "#OOOOOOO#OOOOO#O#OO#OO#O#OOOOO"
.ascii "#OOO###O#######O#OO#OO#O####OO"
.ascii "#OOOOO#O#OOOOO#O#OOOOO#O#OOOOO"
.ascii "#OOOOO#O#OOOOO#O#OOOOO#O#OOOOO"
.ascii "O#####OO#OOOOO#O#OOOOO#O######"
.ascii "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
.ascii "OOO#OOOOOOO#OO#####OO#OOOO#OOO"
.ascii "OOO#OOOOOOO#O#OOOOO#O##OOO#OOO"
.ascii "OOOO#OOOOO#OO#OOOOO#O#O#OO#OOO"
.ascii "OOOO#OOOOO#OO#OOOOO#O#O##O#OOO"
.ascii "OOOOO#O#O#OOO#OOOOO#O#OO#O#OOO"
.ascii "OOOOO#O#O#OOO#OOOOO#O#OOO##OOO"
.ascii "OOOOOO#O#OOOOO#####OO#OOOO#OOO"
.ascii "OOOOOOOOOOOOOOOOOOOOOOOOOOOOOO"
.asciz "##############################"

.align 4
titlemenu_bg_width:
    .int 32
titlemenu_bg:
    .ascii "################################"
    .ascii "###########          ###########"
    .ascii "#######                  #######"
    .ascii "####                        ####"
    .ascii "##                            ##"
    .ascii "##                            ##"
    .ascii "#                              #"
    .ascii "#                              #"
    .ascii "#                              #"
    .ascii "#                              #"
    .ascii "#                              #"
    .ascii "#                              #"
    .ascii "#                              #"
    .ascii "#                              #"
    .ascii "#                              #"
    .ascii "#                              #"
    .ascii "#                              #"
    .ascii "#                              #"
    .ascii "##                            ##"
    .ascii "##                            ##"
    .ascii "####                        ####"
    .ascii "#######                  #######"
    .ascii "###########          ###########"
    .asciz "################################"

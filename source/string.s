@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ string.s
@ 
@ General purpose string manipulation functions
@ Implementing standard C library type functions.
@@@@
.globl strcmp
.globl strcpy
.globl strlen
.globl strcat
.globl strncmp


.section .text

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ strcmp(char* str1, char* str2)
@  Compares two \0 terminated strings, returns 0 if equal, 1 otherwise
@@@@
strcmp:
    ldrb    r2, [r0], #1
    ldrb    r3, [r1], #1

    cmp     r2, #0              @ If either character is \0 then we 
    beq     strcmp_null         @ go to check if both terminated
    cmp     r3, #0
    beq     strcmp_null
    
    cmp     r2, r3              @ Compare the two current characters 
    movne   r0, #1              @ If they're not equal then we return 1
    bxne    lr
    
    b       strcmp              @ Not a recursive call, using it for loop
    
strcmp_null:
    cmp     r2, r3              @ Compare the two current characters 
    movne   r0, #1              @ If they're not equal then we return 1
    moveq   r0, #0              @ If they are then we return 0 
    bx      lr
@@ END STRCMP
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@





    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ strncmp(int len, char* str1, char* str2)
@  Compares two \0 terminated strings first len characters, 
@ returns 0 if equal, 1 otherwise
@@@@
strncmp:
    push    { r4, lr }
    
    
    cmp     r0, #0              @ Check if we've hit the end for the length
strncmp_loop:
    beq     strncmp_end         @ Also lets us use r0 as the return value equals
    
    ldrb    r3, [r1], #1
    ldrb    r4, [r2], #1
    
    cmp     r3, #0              @ If either character is \0 then we 
    beq     strncmp_null        @ go to check if both terminated
    cmp     r4, #0
    beq     strncmp_null
    
    cmp     r3, r4              @ Compare the two current characters 
    movne   r0, #1              @ If they're not equal then we return 1
    bne     strncmp_end
    
    subs    r0, #1
    b       strncmp_loop        @ Not a recursive call, using it for loop
    
strncmp_null:
    cmp     r3, r4              @ Compare the two current characters 
    movne   r0, #1              @ If they're not equal then we return 1
    moveq   r0, #0              @ If they are then we return 0 
strncmp_end:
    pop     {r4, pc}
@@ END STRNCMP
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@




    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ strcpy(char* dest, char* src)
@  Copies two \0 terminated strings, no protection if string is not 
@  \0 terminated, or if memory not allocated.
@@@@
strcpy:
    ldrb    r2, [r1], #1
    strb    r2, [r0], #1
    
    cmp     r2, #0
    bxeq    lr                  @ Keep going till we hit a null
    b       strcpy
@@ END STRCPY
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ strlen(char *str)
@  Counts the number of characters in a \0 terminated string
@@@@
strlen:
    mov     r2, #0
strlen_loop:
    ldrb    r1, [r0], #1
    cmp     r1, #0              @ We keep going and counting till we hit null
    addne   r2, #1
    bne     strlen_loop
    
    mov     r2, r0              @ Return the counter
    bx      lr
@@ END STRLEN
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
    
    
    
    
    
    
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@ strcat(char *dest, char *src)
@  Concatenates src onto dest both must be null terminated, as will the return
@  Dest must be large enough to store both src and dest
@@@@
strcat:
    ldrb    r2, [r0]
    cmp     r2, #0              @ Loop through till the null pointer of dest
    addne   r0, #1  
    bne     strcat      
strcat_loop:
    ldrb    r3, [r1], #1        @ Overwrite the null pointer then every 
    strb    r2, [r0], #1        @ character after that with src
    cmp     r3, #0
    bne     strcat_loop
    bx      lr
@@ END STRCAT
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

    

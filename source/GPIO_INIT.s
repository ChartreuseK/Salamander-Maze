@ This code is created for CPSC359 GPIO related assignments
@ for getting a GPIO virtual memory pointer in order to have
@ access to the GPIO Memory mapped registers. It might not be 
@ the best way to do that in practice. 


@ Code Section
.section .text


@ Read-only Memory
gpioFile:
        .asciz  "/dev/gpiomem"
gpioFileAddr:
	.int	gpioFile
gpioBaseAddr:
	.int	0x3F200000
flags:
	.word	0x101002

@ Align code to word boundary
.align 	2

@ GPIO virtual memory base pointer
.global getGpioPtr
getGpioPtr:

	push	{r4, r5, lr}

	ldr	r0, gpioFileAddr
	ldr	r1, flags
	bl	open
	mov	r4, r0

	str	r4, [sp, #0]	@ sp = file handle number

	ldr	r0, gpioBaseAddr
	str	r0, [sp, #4]	@ sp+4 = gpio address

	mov	r0, #0		@ no preference
	mov	r1, #4096	@ page size
	mov	r2, #0b11	@ read/Write Page
	mov	r3, #1		@ share changes
	bl	mmap
	mov	r5, r0		@ save GPIO virtual memory base pointer
	
	mov	r0, r5		@ return GPIO virtual memory base pointer
	pop	{r4, r5, pc}

@ Data Section
.section .data

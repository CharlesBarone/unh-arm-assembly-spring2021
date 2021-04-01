

	.cpu	cortex-a53
	.fpu	neon-fp-armv8

	
	.text
	.align	2	

	.global main

main:
	bl	uio

	b	terminate

uio
	push	{lr}



	pop	{pc}

terminate:
	mov	r0, #0
	mov	r7, #1
	swi	0

	.data
x:
	.float

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@	Assembly Week 9 Program
@	Charles Barone		4/7/2021
@	Takes user input and computes the sine of
@	said input in degrees.
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.cpu	cortex-a53
	.fpu	neon-fp-armv8
	
	.global main
	.equ	STDIN, 0
	.equ	STDOUT, 1
	.text
prompt:
	.asciz	"Please input a number in degrees from 0.00 to 360.00 >>"

	.align
main:
	bl	uio
	bl	convertFloat
	bl	printFloat
	b	terminate

@ Function to take user input
@ Returns:
@ input - User input in ascii
uio:
	push	{lr}
	ldr	r0, =prompt
	bl	puts
	mov	r0, #STDIN
	ldr	r1, =input
	mov	r2, #inputLen
	bl	read
	pop	{pc}

@ Converts ascii input to float
@ Args:
@ input - User ascii input of floating point number
@ Returns:
@ r0 - floating point number
convertFloat:
	push		{lr}
	push		{r2-r6}

	mov		r2, #0		@ Count of digits right of decimal	
	mov		r3, #0		@ Init r3 with real num value
	mov		r4, #10		@ Decimal number 10, for shifting significant
	mov		r5, #0		@ 0 - no decimal point, 1 - decimal point found
	ldr		r1, =input	@ Load r1 with user input ascii

nextDigit:
	ldrb		r0, [r1], #1	@ Load next character into r0
	subs		r0, #'0'
	blt		notDigit

	cmp		r0, #9
	bgt		notDigit

	mla		r3, r4, r3, r0	@ r3 = r4 * r3 + r0
	add		r2, r5		@ Increment number of decimal places
	b		nextDigit	@ Unconditional branch to nextDigit 

notDigit:
	add		r0, #'0'
	cmp		r0, #'.'	@ Check for decimal
	moveq		r5, #1
	beq		nextDigit
	
	vmov		s3, r3		@ Move int value of significant
	vcvt.f32.s32	s0, s3		@ Convert significant to floating point
	subs		r2, #1		@ Decrement num of decimal places
	blt		copy2r0		@ If none, go to copy "whole" float

	vldr		s1, point1	@ Load 0.1 into floating point reg
	beq		combine		@ For 1 decimal place, multiply significant time 0.1

	vmov		s2, s1		@ Extra copy of 0.1 needed for mult loop

pow10:
	vmul.f32	s1, s2		@ Change final value by factor of 10
	subs		r2, #1		@ Decrement number of decimal places to "shift"
	bgt		pow10

combine:
	vmul.f32	s0, s1		@ Combine significant and exponent

copy2r0:
	vmov		r0, s0		@ Move float number for return
	sub		r1, #1		@ Set r1 to point to char that stopped loop

	pop		{r2-r6}
	pop		{pc}

@ Computes the sine of a float
@
@
sine:
	push	{lr}




	pop	{pc}

@ Prints float to STDOUT
@
@
printFloat:
	push	{lr}



	pop	{pc}

terminate:
	mov	r0, #0
	mov	r7, #1
	swi	0

	.data
point1:
	.float	0.1		@ Floating point value to "shift" num right 1 place

input:
	.space	20
	.equ	inputLen, (.-input)

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

digits:
	.ascii "0123456789"

minus:
	.ascii "-"

nl:
	.asciz "\n"

	.align
main:
	bl	uio
	bl	convertFloat
	bl	sine
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
	
	ldr		r6, =point1	@ Load r6 with address of point1
	vldr		s1, [r6]	@ Load 0.1 into floating point reg
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
@ Approximation: sin(x) = x - x^3/3! + x^5/5!
@ Args:
@ r0 - floating point number
sine:
	push		{lr}
	vmov		s0, r0		@ Move float into s0
	
	ldr		r3, =pi		@ Store address of pi into r3
	vldr		s1, [r3]	@ s1 = pi
	ldr		r3, =num180	@ Store address of num180 into r3
	vldr		s2, [r3]	@ s2 = 180.0
	vdiv.f32	s1, s1, s2	@ s1 = pi/180
	vmul.f32	s0, s0, s1	@ s0 = x in radians
	vmov		r0, s0
	vmov.f32	s1, s0		@ Copy float into s1
	
	vmul.f32	s1, s1, s0	@ x * x = x^2
	vmul.f32	s1, s1, s0	@ x^2 * x = x^3
	vmov.f32	s2, #6.0	@ s2 = 3!
	vdiv.f32	s1, s1, s2	@ s1 = x^3/3!
	vmov		r0, s1
	vsub.f32	s1, s0, s1	@ s1 = x - x^3/3!
	vmov		r0, s1
	vmul.f32	s2, s0, s0	@ s2 = x * x = x^2
	vmul.f32	s2, s2, s0	@ s2 = x^2 * x = x^3
	vmul.f32	s2, s2, s0	@ s2 = x^3 * x = x^4
	vmul.f32	s2, s2, s0	@ s2 = x^4 * x = x^5
	ldr		r3, =fiveFac	@ Store memory address of 5! in r3
	vldr		s3, [r3]	@ s3 = 5!
	vdiv.f32	s2, s2, s3	@ s2 = x^5/5!
	vmov		r0, s2
	vadd.f32	s0, s1, s2	@ Store sin(x) in s0
	
	vmov		r0, s0		@ Store float for return
	pop		{pc}

@ Function to print ASCII
@ Args:
@ r1 - pointer to beginning of ascii string
@ r2 - length of string in bytes
printAscii:
	push	{lr}
	push	{r0-r7}
	mov	r0, #1
	mov	r7, #4		 @ Linux Service command code to write string
	svc	0		 @ Issue cmd to display string.
	pop	{r0-r7}
	pop	{pc}

@ Function to print decimal number as ASCII
@ Args:
@ r0 - decimal number
printDec:
	push	{lr}
	push	{r0-r8}
	ldr	r6, =outBuff
	
	mov	r1, #100
	bl	modN		@ Get 100s place
	ldr	r7, [r6]
	add	r1, #0x30	@ To ascii
	orr	r1, r7		@ or in 100s place
	str	r1, [r6]

	mov	r1, #10
	bl	modN		@ Get 10s place
	add	r1, #0x30	@ To ascii
	lsl	r1, #8		@ Rotate 16 positions to left
	ldr	r7, [r6]
	orr	r1, r7		@ or in 10s place
	str	r1, [r6]

	add	r0, #0x30	@ Remainder is 1s place, convert to ascii
	lsl	r0, #16		@ Rotate 24 positions to left
	ldr	r7, [r6]
	orr	r0, r7		@ or in 1s place
	str	r0, [r6]

	ldr	r0, =#0x2E	@ Load '.' into r0
	str	r0, [r6,#3]

	ldr	r0, =outBuff
	bl	strlen
	
	mov	r2, r0		@ Move strlen to r2
	ldr	r1, =outBuff	
	mov	r0, #STDOUT
	bl	write
	pop	{r0-r8}
	pop	{pc}

@ Prints float to STDOUT
@ Args:
@ r0 - foating point number
printFloat:
	push	{lr}
	push	{r0-r8}
	ldr	r1, =minus	@ Load r0 with negative sign
	mov	r2, #1		@ Character count
	movs	r6, r0, lsl #1	@ Move sign bit to "C" flag
	blcs	printAscii	@ Print negative sign if sign bit was set

	mov	r3, r0, lsl #8
	orr	r3, #0x80000000	@ Set assumed high order bit
	mov	r0, #0		@ set whole part = 0
	cmp	r6, #0		@ If both mantissa and exponent = 0
	beq	display		@ If equal branch to display
	
	mov	r6, r6, lsr #24	@ Right justify biased exponent
	subs	r6, #126	@ Remove the exponent bias
	beq	display		@ If exponent == 0, no shifting
	blt	shiftRight	@ Valuse lt .5 must be right shifted

	rsb	r5, r6, #32	@ Convert left shift to right shift count
	mov	r0, r3, lsr r5	@ Get whole number portion of num
	lsl	r3, r6		@ Get the fractional part of num
	b	display		@ Unconditional branch to display

shiftRight:
	rsb	r6, r6, #0	@ Get positive shift count
	lsr	r3, r6

display:
	bl	printDec	@ Print whole part of num and decimal point

	mov	r4, #10		@ Store decimal number 10 for shifting across each digit
	ldr	r5, =digits	@ Sore address of digits in r5

nxtdfd:
	umull	r3, r1, r4, r3	@ "Shift" next decimal digit into r1
	add	r1, r5		@ Set digit pointer
	bl	printAscii	@ Print digit
	cmp	r3, #0		@ Set Z flag if mantissa is zero
	bne	nxtdfd		@ Otherwise, print next digit

	ldr	r1, =nl		@ Store pointer to newline character in r1
	bl	printAscii	@ Print newline character

	pop	{r0-r8}
	pop	{pc}

terminate:
	mov	r0, #0
	mov	r7, #1
	swi	0

@ Computes mod N of a number
@ Args:
@ r0 - number
@ r1 - mod
@ Returns:
@ r0 - remainder
@ r1 - N
modN:
	push	{lr}
	push	{r3}
	mov	r3, #0
cont:
	sub	r0, r1
	add	r3, #1
	cmp	r0, #0
	bgt	cont
	cmp	r0, #0
	beq	modDone
	add	r0, r1
	sub	r3, #1
modDone:
	mov	r1, r3
	pop	{r3}
	pop	{pc}


	.data
fiveFac:
	.float	120.0		@ Used in sine

pi:
	.float 3.14159		@ Used in sine

num180:
	.float	180.0		@ Used in sine

point1:
	.float	0.1		@ Used in convertFloat
input:
	.space	20		@ User ASCII input buffer
	.equ	inputLen, (.-input)

outBuff:
	.space	20		@ Used as a buffer when generating ASCII output

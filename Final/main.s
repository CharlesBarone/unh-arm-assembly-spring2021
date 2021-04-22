@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@	Final Project Program
@	Charles Barone		4/21/2021
@	Takes ASCII input from a buffer to simulate a
@	targeting system.
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.cpu	cortex-a53
	.fpu	neon-fp-armv8
	
	.global main
	.equ	STDIN, 0
	.equ	STDOUT, 1
	.text

inBuff:
	.ascii "TAR1RNG00123.12BR123.12SP12.12DIR123.12\0"

	.align
main:
	@ readDIR
	ldr	r3, =DIR
	ldr	r6, =#15
	ldr	r8, =#7
	bl	readFloat
	
	@ readBR
	ldr	r3, =BR
	ldr	r6, =#23
	ldr	r8, =#17
	bl	readFloat

	@ readSP
	ldr	r3, =SP
	ldr	r6, =#30
	ldr	r8, =#25
	bl	readFloat

	bl	calcInitValues

	bl	terminate

@ Calculates initial values
@ Args:
@ DIR
@ BR
@ Returns:
@ t_barrel
@ v_projectile
@ v_proj_init_xyplane
@ v_proj_init_z
calcInitValues:
	push		{lr}
	@ t_barrel = sqrt((2 * L_barrel) / K_Charge)
	ldr		r0, =L_barrel
	vldr		s0, [r0]	@ Load value of float L_barrel into s0
	vmov.f32	s1, #2.0
	vmul.f32	s0, s0, s1	@ s0 = L_barrel * 2.0
	ldr		r0, =K_Charge
	vldr		s1, [r0]	@ Load value of float K_Charge into s1. K_CHarge = accel
	vdiv.f32	s0, s0, s1	@ s0 = s0 / K_Charge
	vsqrt.f32	s0, s0
	vmov		r0, s0		@ Move t_barrel into r0
	ldr		r1, =t_barrel
	str		r0, [r1]	@ Store floating point number in t_barrel

	@ v_projectile = K_Charge * t_barrel
	vmul.f32	s2, s0, s1	@ s2 = K_Charge * t_barrel
	vmov		r0, s2
	ldr		r1, =v_projectile
	str		r0, [r1]	@ Store floating point number in v_projectile

	@ v_proj_init_xyplane = v_projectile * cos(Phi). Phi = DIR
	ldr		r0, =DIR
	vldr		s0, [r0]	@ s0 = Phi = DIR
	bl		cosine		@ s0 = cos(Phi)
	ldr		r0, =v_projectile
	vldr		s1, [r0]	@ Load value of float v_projectile into s1
	vmul.f32	s0, s0, s1	@ s0 = v_projectile * cos(Phi)
	vmov		r0, s0		@ Move v_proj_init_xyplane into r0
	ldr		r1, =v_proj_init_xyplane
	str		r0, [r1]	@ Store floating point number in v_proj_init_xyplane

	@ v_proj_init_z = v_projectile * sin(Phi)
	ldr		r0, =DIR
	vldr		s0, [r0]	@ s0 = Phi = DIR
	bl		sine		@ s0 = sin(Phi)
	ldr		r0, =v_projectile
	vldr		s1, [r0]	@ Load value of float v_projectile into s1
	vmul.f32	s0, s0, s1	@ s0 = v_projectile * sin(Phi)
	vmov		r0, s0		@ Move v_proj_init_z into r0
	ldr		r1, =v_proj_init_z
	str		r0, [r1]	@ Store floating point number in v_proj_init_z
	pop		{pc}


@ Computes sin(x)=y
@ Args:
@ s0 - x
@ Returns:
@ s0 - y
sine:
	push		{lr}	
	ldr		r3, =pi		@ Store address of pi into r3
	vldr		s1, [r3]	@ s1 = pi
	ldr		r3, =num180	@ Store address of num180 into r3
	vldr		s2, [r3]	@ s2 = 180.0
	vdiv.f32	s1, s1, s2	@ s1 = pi/180
	vmul.f32	s0, s0, s1	@ s0 = x in radians

	vmov.f32	s1, s0		@ Copy float into s1
	
	vmov.f32	s6, s0
	mov		r1, #3
	bl		power
	vmov.f32	s1, s6		@ s1 = x^3
	vmov.f32	s6, #3.0
	mov		r1, #3
	bl		factorial
	vmov		s2, s6		@ s2 = 3!
	vdiv.f32	s1, s1, s2	@ s1 = x^3/3!
	
	vsub.f32	s1, s0, s1	@ s1 = x - x^3/3!


	vmov.f32	s4, #5.0
	mov		r4, #5
	mov		r5, #0		@ bool. 0 = add, 1 = sub
sineLoop:
	cmp		r4, #51
	beq		endSine
	vmov.f32	s6, s0
	mov		r1, r4
	bl		power
	vmov.f32	s2, s6		@ s2 = x^r4
	vmov.f32	s6, s4
	mov		r1, r4
	bl		factorial
	vmov.f32	s3, s6		@ s3 = r4!
	vdiv.f32	s2, s2, s3	@ s2 = x^r4/r4!
	cmp		r5, #0
	beq		sineAdd
	vsub.f32	s1, s1, s2
	mov		r5, #0
	b		skipSineAdd
sineAdd:
	vadd.f32	s1, s1, s2
	mov		r5, #1
skipSineAdd:
	vmov.f32	s6, #2.0
	vadd.f32	s4, s6
	add		r4, #2
	b		sineLoop	@ Unconditional branch to sineLoop
endSine:	
	vmov.f32	s0, s1		@ Store float for return
	pop		{pc}

@ Computes cos(x)=y
@ Args:
@ s0 - x
@ Returns:
@ s0 - y
cosine:
	push		{lr}
	ldr		r3, =pi
	vldr		s1, [r3]
	ldr		r3, =num180
	vldr		s2, [r3]
	vdiv.f32	s1, s1, s2
	vmul.f32	s0, s0, s1
	
	vmov.f32	s1, #1.0

	vmov.f32	s4, #2.0
	mov		r4, #2
	mov		r5, #0		@ bool. 0 = sub, 1 = add
cosLoop:
	cmp		r4, #50
	beq		endCos
	vmov.f32	s6, s0
	mov		r1, r4
	bl		power
	vmov.f32	s2, s6		@ s2 = x^r4
	vmov.f32	s6, s4
	mov		r1, r4
	bl		factorial
	vmov.f32	s3, s6		@ s3 = r4!
	vdiv.f32	s2, s2, s3	@ s2 = x^r4/r4!
	cmp		r5, #0
	beq		cosSub
	vadd.f32	s1, s1, s2
	mov		r5, #0
	b		skipCosSub
cosSub:
	vsub.f32	s1, s1, s2
	mov		r5, #1
skipCosSub:
	vmov.f32	s6, #2.0
	vadd.f32	s4, s6
	add		r4, #2
	b		cosLoop		@ Unconditional branch to cosLoop
endCos:	
	vmov.f32	s0, s1		@ Store float for return
	pop		{pc}

@ Computes arctan(x)=y
@ Args:
@ s0 - x
@ Returns:
@ s0 - y
arctan:
	push		{lr}	
	ldr		r3, =pi		@ Store address of pi into r3
	vldr		s1, [r3]	@ s1 = pi
	ldr		r3, =num180	@ Store address of num180 into r3
	vldr		s2, [r3]	@ s2 = 180.0
	vdiv.f32	s1, s1, s2	@ s1 = pi/180
	vmul.f32	s0, s0, s1	@ s0 = x in radians

	vmov.f32	s1, s0		@ Copy float into s1
	
	vmov.f32	s6, s0
	mov		r1, #3
	bl		power
	vmov.f32	s1, s6		@ s1 = x^3
	vmov.f32	s2, #3.0	@ s2 = 3
	vdiv.f32	s1, s1, s2	@ s1 = x^3/3
	
	vsub.f32	s1, s0, s1	@ s1 = x - x^3/3


	vmov.f32	s4, #5.0
	mov		r4, #5
	mov		r5, #0		@ bool. 0 = add, 1 = sub
atanLoop:
	cmp		r4, #51
	beq		endAtan
	vmov.f32	s6, s0
	mov		r1, r4
	bl		power
	vmov.f32	s2, s6		@ s2 = x^r4
	vmov.f32	s3, s4		@ s3 = s4
	vdiv.f32	s2, s2, s3	@ s2 = x^r4/r4
	cmp		r5, #0
	beq		atanAdd
	vsub.f32	s1, s1, s2
	mov		r5, #0
	b		skipAtanAdd
atanAdd:
	vadd.f32	s1, s1, s2
	mov		r5, #1
skipAtanAdd:
	vmov.f32	s6, #2.0
	vadd.f32	s4, s6
	add		r4, #2
	b		atanLoop	@ Unconditional branch to sineLoop
endAtan:	
	vmov.f32	s0, s1		@ Store float for return
	pop		{pc}

@ Computes x! (X as an int and float are given, but returns a floating point register)
@ Args:
@ r1 - x
@ s6 - x
@ Returns:
@ s6 - x!
factorial:
	push		{lr}
	vmov.f32	s8, #1.0
	vmov.f32	s9, #1.0
	mov		r2, #1
facLoop:
	cmp		r1, r2
	beq		facEnd
	vmul.f32	s6, s6, s8
	vadd.f32	s8, s9
	sub		r1, #1		@ Decrement Counter	
	b		facLoop		@ Unconditional branch to facLoop
facEnd:
	pop		{pc}


@ Computes a^b=c
@ Args:
@ s6 - a
@ r1 - b (int)
@ Returns:
@ s6 - c
power:
	push		{lr}
	vmov.f32	s7, s6
pow:
	cmp		r1, #1
	beq		endPow
	vmul.f32	s6, s6, s7
	sub		r1, #1
	b		pow
endPow:
	pop		{pc}

@ Reads a float from inBuff
@ Args:
@ r3 - address to store float in
@ r6 - Index of end of str + 1
@ r8 - Index of begining of str
readFloat:
	push	{lr}
	mov	r7, #0		@ Shift amount
	ldr	r5, =inBuff	@ Load inBuff address into r5
	mov	r0, #0		@ Initialize r0 with #0, used to save float as ascii
	ldr	r2, =TempStr	@ Load TempStr address into r2
	str	r0, [r2]	@ Set all bits of TempStr to 0
ReadLoop:
	cmp	r8, r6
	beq	ReadExit
	ldrb	r1, [r5, r8]	@ Load a character into R1 
	strb	r1, [r2, r7]	@ Store character into r2
	add	r7, #1		@ Increment shift amount
	add	r8, #1		@ Increment counter
	b	ReadLoop	@ Unconditional branch to DIRloop
ReadExit:
	push	{r3}
	bl	convertFloat	@ Convert string to float
	pop	{r3}
	str	r0, [r3]	@ Store float into memory pointed to by r3
	pop	{pc}

@ Converts ascii to float
@ Args:
@ TempStr - float in ascii
@ Returns:
@ r0 - floating point number
convertFloat:
	push		{lr}
	push		{r2-r8}

	mov		r2, #0		@ Count of digits right of decimal	
	mov		r3, #0		@ Init r3 with real num value
	mov		r4, #10		@ Decimal number 10, for shifting significant
	mov		r5, #0		@ 0 - no decimal point, 1 - decimal point found
	ldr		r1, =TempStr	@ Load r1 with user input ascii

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

	pop		{r2-r8}
	pop		{pc}


terminate:
	mov	r0, #0
	mov	r7, #1
	swi	0

	.data
tmp:
	.float	90.0

outBuff:
	.space	64

TempStr:
	.space	32

DIR:
	.space	8

BR:
	.space	8

SP:
	.space	8

pi:
	.float	3.14159

num180:
	.float	180.0

point1:
	.float	0.1

K_Charge:
	.float	200000000.0	@ Constant value used in calculations. Also happens to be accel.

L_barrel:
	.float	10.0		@ Constant value used in calculations

m_projectile:
	.float	100.0		@ Constant value used in calculations

m_charge:
	.float	2.0		@ Constant value used in calculations

a_projectile:
	.space	8

t_barrel:
	.space	8

v_projectile:
	.space	8

v_proj_init_xyplane:
	.space	8

v_proj_init_z:
	.space	8

t_flight_uncorrected:
	.space	8

R_projectile_uncorrected:
	.space	8

R_x:
	.space	8

R_y:
	.space	8

D:
	.space	8

D_x:
	.space	8

D_y:
	.space	8

R_aim:
	.space	8

Bearing_aim:
	.space	8

t_flight_corrected:
	.space	8

elev_aim:
	.space	8

M_charge:
	.space	8

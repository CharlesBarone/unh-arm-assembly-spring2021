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


main:

	bl	terminate

terminate:
	mov	r0, #0
	mov	r7, #1
	swi	0

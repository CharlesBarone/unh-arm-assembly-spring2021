@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@	Assembly Week 8 Program
@	Charles Barone		3/27/2021
@	Very simple program for examining the binary
@	represetation of a floating point number.
@
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	.cpu    cortex-a53
        .fpu    neon-fp-armv8
	.syntax	unified
	.text
	.align 	2
	.global main
terminate:
	mov		r0, 0
	mov		r7, 1
	swi		0

main:
	vldr		s0, x		@ Load float x into s0
	
	vmov.f32	r0, s0		@ Pass x into r0
	b		terminate

	.data
x:
	.float	85.125

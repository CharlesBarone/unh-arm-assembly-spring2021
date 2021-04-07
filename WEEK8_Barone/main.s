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
	ldr		r1, =x		@ Load r1 with the address of x
	vldr		s0, [r1]	@ Load value of float x into s0
	
	vmov.f32	r0, s0		@ Pass value of x into r0
	b		terminate

	.data
x:
	.float	85.125

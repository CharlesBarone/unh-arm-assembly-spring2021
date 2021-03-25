@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@	Assembly Week 6 Program
@	Charles Barone		3/16/2021
@	Implements a ring buffer.
@
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.global main

	.text
terminate:
	move	r0, #0
	mov	r7, #1
	swi	0

main:
	
	b terminate

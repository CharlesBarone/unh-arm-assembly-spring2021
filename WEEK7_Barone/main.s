@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@	Assembly Week 7 Program
@	Charles Barone		3/16/2021
@	Implements a data "parser".
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

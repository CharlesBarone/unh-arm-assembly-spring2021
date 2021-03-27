@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@	Assembly Week 7 Program
@	Charles Barone		3/25/2021
@	Implements a command parser.
@
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.global main
	.equ	STDIN, 0
	.equ	STDOUT, 1
	.text
prompt:
	.asciz "Please enter a command >>"

	.align
terminate:
	move	r0, #0
	mov	r7, #1
	swi	0

@ Function to take user input
@ Returns:
@ RxBuff - User input in ascii
uio:
	push	{lr}
	ldr	r0, =prompt
	bl	puts
	mov	r0, #STDIN
	ldr	r1, =RxBuff
	mov	r2, #RxBuffLen
	bl	read
	pop	{pc}

@ Function to parse user input
@ Args:
@ RxBuff - User input in ascii
parser:
	push	{lr}
	mov	r8, #0			@ Counter
	ldr	r5, =RxBuff		@ Load user input ascii into r5
	ldrb	r1, [r5, r8]		@ Get first ascii character
	add	r8, #1			@ Increment Counter
	cmp	r1, #0x41		@ if command == A
	beq	A
	cmp	r1, #0x42		@ if command == B
	beq	B
	b	invalid			@ Unconditional branch to invalid, b/c no valid command
A:
	ldrb	r1, [r5. r8]		@ Verify size == 0
	cmp	r1, #0x30
	bne	invalid
	add	r8, #1			@ Increment Counter
	ldrb	r1, [r5, r8]		@ Verify CR
	cmp	r1, 
	b	skipB
B:


skipB:


	b	valid
invalid:
	
	b	end
valid:
	
	
	pop	{pc}

main:
	bl	uio
	bl	parser
	b	terminate

	.data
TxBuff:
	.space	6
	.equ	TxBuffLen, (.-TxBuff)

RxBuff:
	.space	256
	.equ	RxBuffLen, (.-RxBuff)



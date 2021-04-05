@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@	Assembly Week 7 Program
@	Charles Barone		3/25/2021
@	Implements a command parser.
@	Command Format:	[Command (1 character (A or B)][Size],[Payload][Line Feed]
@	"," is used as a terminator for the size int.
@	(Size is a decminal number)
@
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

	.global main
	.equ	STDIN, 0
	.equ	STDOUT, 1
	.text
prompt:
	.asciz "Please enter a command >>"

validMsg:
	.asciz "Command entered was valid!"

invalidMsg:
	.asciz "Command entered was invalid!"

	.align
terminate:
	mov	r0, #0
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
	ldrb	r1, [r5, r8]		@ Verify size == 0
	cmp	r1, #0x30
	bne	invalid
	add	r8, #1			@ Increment Counter
	ldrb	r1, [r5, r8]
	cmp	r1, #0x2C		@ Verify size is actually 1 digit
	bne	invalid
	add	r8, #1			@ Increment Counter
	ldrb	r1, [r5, r8]		@ Verify LF
	cmp	r1, #0xA
	bne	invalid
	b	skipB
B:
	mov	r9, #0			@ r9 = Size
	mov	r0, r5			@ Move RxBuff to r0 for strlen
	bl	strlen			@ Store length of RxBuff in r0
sizeLoop:
	cmp	r8, r0			@ Compare Counter to strlen, check to see if "," is missing
	bgt	invalid			@ Missing "," branch to invalid
	
	ldrb	r1, [r5, r8]
	add	r8, #1			@ Increment Counter
	cmp	r1, #0x2C		@ Check for end of int
	beq	endSize

	sub	r1, #48
	mov	r10, #10		@ Temp mul value
	mul	r9, r10			@ Multiply current size by 10
	add	r9, r1			@ Add in next digit of size
	b	sizeLoop		@ Unconditional branch to sizeLoop
endSize:
	add	r10, r8, r9		@ Get valid LF location
payload:
	cmp	r10, r8			@ If end of payload
	beq	endPayload
	
	ldrb	r1, [r5, r8]		@ Get chatracter of payload in ASCII
	add	r8, #1			@ Increment Counter

	cmp	r1, #0xA		@ Check for premature LF
	beq	invalid

	b	payload			@ Unconditional branch to payload
endPayload:
	ldrb	r1, [r5, r8]		@ Get character to check for LF
	cmp	r1, #0xA		@ If r1 != LF
	bne	invalid
skipB:
	b	valid
invalid:
	ldr	r1, =TxBuff		@ Load output buffer into r1
	ldr	r0, =#0x15		@ Load r0 with "NAK"
	mov	r8, #0			@ Create store counter, initialized at 0
	strb	r0, [r1, r8]		@ Store return value into out buff
	b	end
valid:
	ldr	r1, =TxBuff		@ Load output buffer into r1
	ldr	r0, =#0x6		@ Load r0 with "ACK"
	mov	r8, #0			@ Create store counter, initialized at 0
	strb	r0, [r1, r8]		@ Store return value into out buff
end:	
	add	r8, #1			@ Increment Counter
	ldr	r0, =#0xD		@ Load r0 with CR
	strb	r0, [r1, r8]		@ Store CR into out buff
	add	r8, #1			@ Increment Counter
	ldr	r0, =#0xA		@ Load r0 with LF
	strb	r0, [r1, r8]		@ Store LF into out buff
	pop	{pc}

@ Function to print a message to STDOUT stating if command was valid or invalid 
@ Args:
@ TxBuff - Transmit Buffer
printOutput:
	push	{lr}
	ldr	r4, =TxBuff		@ Load TxBuff into r4
	ldrb	r5, [r4, #0]		@ Load first character of TxBuff into r5
	cmp	r5, #0x15		@ If command was invalid, branch to false
	beq	false
true:
	ldr	r0, =validMsg		@ Load r0 with valid message
	bl	puts
	b	endPrint		@ Unconditional branch to endPrint
false:
	ldr	r0, =invalidMsg		@ Load r0 with invalid message
	bl	puts
endPrint:
	pop	{pc}

main:
	bl	uio
	bl	parser
	bl	printOutput
	b	terminate

	.data
TxBuff:
	.space	6
	.equ	TxBuffLen, (.-TxBuff)

RxBuff:
	.space	256
	.equ	RxBuffLen, (.-RxBuff)



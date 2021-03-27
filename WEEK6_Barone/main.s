@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@	Assembly Week 6 Program
@	Charles Barone		3/27/2021
@	Implements a Ring Buffer  Data Structure capable of
@	storing 10 32 bit words.
@
@	Buffer Registers:
@	writePtr - Write Pointer
@	readPtr - Read Pointer
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	.global main

	.text
@ Initializes ring buffer data structure
ringInit:
	push	{lr}
	mov	r0, #0
	ldr	r3, =readPtr
	ldr	r4, =writePtr
	str	r0, [r4]
	str	r0, [r3]
	pop	{pc}

@ Exits the program gracefully
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
	pop	{pc}

@ Writes 1 32 bit word to ring buffer
@ Args:
@ r0 - 32 bit word
bufWrite:
	push	{lr}
	ldr	r5, =readPtr	@ Get read pointer
	ldr	r4, [r5]	@ Get read pointer increment amount
	ldr	r5, =writePtr	@ Get write pointer
	ldr	r3, [r5]	@ Get write pointer increment amount
	bl	incrementPtr	@ Increment write pointer by 1 word
	cmp	r3, r4		@ Check if buffer is full
	beq	noWrite

	ldr	r3, [r5]	@ Get original write pointer increment amount
	ldr	r1, =ring	@ Get ring buffer
	str	r0, [r1, r3]	@ Write r0 to buffer
	bl	incrementPtr	@ Increment write pointer
	str	r3, [r5]	@ Store new write pointer
noWrite:
	pop	{pc}

@ Increments a pointer offset by 1 with 
@ respect to the circular Data Structure
@ Args:
@ r3 - pointer
@ Returns:
@ r3 - new pointer
incrementPtr:
	push	{lr}
	push	{r0-r1}
	ldr	r1, =#40	@ Store length of buffer in r1
	mov	r0, r3		@ Move pointer into r0
	add	r0, #4		@ Increment pointer by 1 word
	bl	modN		@ Run modN
	mov	r3, r1		@ Move new pointer back to r3
	pop	{r0-r1}
	pop	{pc}


@ Reads 1 32 bit word from the ring buffer
@ Returns:
@ r0 - 32 bit word
bufRead:
	push	{lr}
	ldr	r5, =writePtr	@ Get write pointer
	ldr	r4, [r5]	@ Get write pointer increment amount
	ldr	r5, =readPtr	@ Get read pointer
	ldr	r3, [r5]	@ Get read pointer increment amount
	cmp	r3, r4		@ Check if buffer is empty
	beq	noRead

	ldr	r1, =ring	@ Get ring buffer
	ldr	r0, [r1, r3]	@ Read 1 word from buffer into r0
	bl	incrementPtr	@ Increment read pointer by 1 word
	str	r3, [r5]
noRead:
	pop	{pc}

@ Program entry point
main:
	bl	ringInit


	b	terminate

	.data
ring:
	.space	40
	.equ	ringLen, (.-fifo)

writePtr:
	.space 8

readPtr:
	.space 8

@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@	Assembly Week 5 Program
@	Charles Barone		3/16/2021
@	Implements a FIFO Data Structure capable of storing
@	10 32 bit words.
@
@	FIFO Registers:
@	fifo - Head Pointer
@	fifo + tailPtr - Tail Pointer
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	.global main

	.text
@ Initializes fifo data structure
fifoInit:
	push	{lr}
	mov	r0, #0
	ldr	r3, =fifo
	ldr	r4, =tailPtr
	str	r0, [r4]
	pop	{pc}

@ Push a 32 bit word onto the end of the fifo
@ Args:
@ r0 - 32 bit word
fifoPush:
	push	{lr}
	ldr	r3, =fifo		@ Get head pointer
	ldr	r5, =tailPtr		@ Get tail pointer increment amount pointer
	ldr	r2, [r5]		@ Get value of tail pointer increment
	
	cmp	r2, #12			@ If fifo is full skip push TODO: Change to 44 from 12
	beq	noPush
	str	r0, [r3, r2]		@ Store 32 bit word argument into headptr + tail increment amount
	add	r2, #4			@ Increment tail pointer increment by 1 word
	str	r2, [r5]		@ Store new tail pointer
noPush:
	pop	{pc}

@ Pop a 32 bit word off the front of the fifo
@ Returns:
@ r0 = 32 bit word
fifoPop:
	push	{lr}
	ldr	r3, =fifo		@ Get head pointer
	ldr	r4, =tailPtr		@ Get tail pointer increment amount
	ldr	r2, [r4]		@ Get value of tail pointer increment
	
	cmp	r2, #0			@ If fifo is empty, skip pop
	beq	noPop

	ldr	r0, [r3]		@ Get return value
	push	{r0}			@ Push return value onto the stack
	push	{r2}			@ Store current tail pointer increment on stack for later	

	ldr	r5, [r3, r2]		@ Get value current end of fifo
loop:
	sub	r2, #4			@ Decrement tail pointer increment by 1 word
	ldr	r6, [r3, r2]		@ Get value of new end of fifo
	str	r5, [r3, r2]		@ Shift value 1 position to left in fifo
	mov	r5, r6			@ Move r6 to r5 ( new value to be shifted)

	cmp	r2, #0			@ If taill pointer increment == decimal number 0, end loop
	beq	endLoop	

	b	loop			@ Unconditional branch to loop

endLoop:
	pop	{r2}			@ Pop original tail pointer increment off stack
	sub	r2, #4			@ Decrement tail pointer increment by 1 word
	str	r2, [r4]		@ Restore tail ptr increment
	pop	{r0}			@ Pop return value off the stack
noPop:
	pop	{pc}

@ Exits the program gracefully
terminate:
	mov	r0, #0
	mov	r7, #1
	swi	0

@ Program entry point
main:
	bl	fifoInit
	mov	r0, #4
	bl	fifoPush
	mov	r0, #3
	bl	fifoPush
	bl	fifoPop
	bl	fifoPop
	b	terminate


	.data
fifo:
	.space	40
	.equ	fifoLen, (.-fifo)

tailPtr:
	.space 8

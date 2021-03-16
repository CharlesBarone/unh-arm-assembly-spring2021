@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@	Assembly Week 5 Program
@	Charles Barone		3/16/2021
@	Implements a FIFO Data Structure capable of storing
@	10 32 bit words.
@
@	FIFO Registers:
@	r4 - Head Pointer
@	r5 - Tail Pointer
@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
	
	.global main
	
	.text
terminate:
	mov	r0, #0
	mov	r7, #1
	swi	0

fifoInit:
	push	{lr}
	ldr	r4, =fifo	@ Head Pointer
	ldr	r5, =fifo	@ Tail Pointer
	pop	{pc}

@ Push a 32 bit word onto the end of the queue.
@ Args:
@ r0 - 32 bit word
fifoPush:
	push	{lr}
	add	r1, r4, #40	@ Get last pointer + 1
	cmp	r5, r1		@ Check if queue is full
	beq	noPush
	add	r5, #4		@ Increment Tail Pointer by 4 bytes
	str	r0, [r5]	@ Store r0 at Tail Pointer
noPush:
	pop	{pc}

@ Pop a 32 bit word off the front of the queue
@ Returns:
@ r0 - 32 bit word
fifoPop:
	push	{lr}
	bl	fifoState
	cmp	r0, #0		@ If queue is empty
	beq	skip		@ Nothing to remove from queue
	
	ldr	r0, [r4]	@ Get return value
	push	{r0}
	mov	r1, #4		@ Counter
	mov	r4, r3		@ temp lead pointer
loop:
	cmp	r1, #40		@ Check if reached end of memory space
	beq	endLoop
	add	r2, r1, r4	@ Get temp pointer
	ldr	r0, [r2]	@ Get value to move
	str	r0, [r3]	@ Move value up in queue
	mov	r3, r2		@ Get new temp lead pointer
	add	r2, #4		@ Increment temp pointer 
	add	r1, #4		@ Increment counter
	b	loop		@ Unconditional branch to loop
endLoop:
	mov	r1, #0		@ Store #0 in r1
	str	r1, [r4,#36]	@ Zero out newly opened queue slot
skip:
	pop	{r0}
	pop	{pc}

@ Returns 0 if queue is empty, 1 if it is not empty.
@ Returns:
@ r0 - #0 or #1
fifoState:
	push	{lr}
	cmp	r4, r5		@ If tail pointer == head pointer
	beq	true
	mov	r0, #0
	pop	{pc}
true:
	mov	r0, #1
	pop	{pc}

main:
	mov	r6, #0		@ Number to push/pop and increment
mainLoop:
	cmp	r6, #10		@ If r6 == 10
	beq	finish
	mov	r0, r6		@ Store number into r0 to be pushed to queue
	bl	fifoPush
	add	r6, #1		@ r6++
	b	mainLoop
finish:
	mov	r6, #0
mainLoop2:
	cmp	r6, #10		@ If r6 == 10
	beq	finish2
	bl	fifoPop
	add	r6, #1		@ r6++
	b	mainLoop2
finish2:
	b	terminate

	.data
fifo:
	.space	40	
	.equ	fifoLen, (.-fifo)

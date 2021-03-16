@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
@
@	Assembly Week 5 Program
@	Charles Barone		3/16/2021
@	Implements a FIFO Data Structure capable of storing
@	32 bit words (32 * 8 Bytes).
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
	


	pop	{pc}

fifoPush:
	push	{lr}



	pop	{pc}

fifoPop:
	push	{lr}



	pop	{pc}

main:
	bl	fifoInit
	
	
	
	bl	terminate

	.data
fifo:
	.space	256	
	.equ	fifoLen, (.-fifo)

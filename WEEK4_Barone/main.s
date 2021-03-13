	.global main
	.equ	STDIN, 0
	.equ	STDOUT, 1
	.text

prompt:
	.asciz "Please Enter (Include Sign) (XXX.XX) >>"

	.align

terminate:
	mov	r0, #0
	mov	r7, #1
	swi	0

uio:
	push	{lr}
	ldr	r0, =prompt
	bl	puts
	mov	r0, #STDIN
	ldr	r1, =inbuff
	mov	r2, #inbuffLen
	bl	read
	pop	{pc}

asc2hexWhole:
	push	{lr}
	mov	r8, #0		@ Counter
	mov	r5, #0		@ Q8.2 Signed
	
	mov	r6, #3		@ Whole Number length
loop:
	cmp	r8, r6		@ Loop until end of string
	beq	endloop		@ Branch to end of loop
	
	ldr	r0, =inbuff	@ Load r0 with buffer
	ldrb	r1, [r0,r8]	@ Load r1 with ascii value
	mov	r2, #0x40
	cmp	r1, r2		@ If A through F
	bgt	AtoF
	b	num
AtoF:
	sub	r1, r1, #7
num:
	sub	r1, r1, #48	@ ascii to hex for single digit
	sub	r2, r6, r8	@ Get Power
	sub	r2, r2, #1	@ ^ Continued
	mov	r4, #16
	mov	r3, #1
	bl	power

	add	r5, r5, r3
	add	r8, r8, #1
	b	loop
endloop:
	pop	{pc}

power:
	push	{lr}
	cmp	r2, #0
	beq	endpow
	mul	r3, r3, r4
	sub	r2, r2, #1
	b	power
endpow:
	mul	r3, r3, r1
	pop	{pc}

asc2hexFrac:
	push	{lr}
	
	
	
	pop	{pc}

main:
	bl	uio
	bl	asc2hexWhole
	bl	terminate

	.data
inbuff:
	.space	20
	.equ	inbuffLen, (.-inbuff)

	.end

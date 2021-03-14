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

asc2hex:
	push	{lr}
	mov	r5, #0		@ Out Number
loop:
	cmp	r8, r6		@ Loop until end of string
	beq	endloop		@ Branch to end of loop
	
	ldr	r0, =inbuff	@ Load r0 with buffer
	ldrb	r1, [r0,r8]	@ Load r1 with ascii value
	ldr	r2, =#0x40
	cmp	r1, r2		@ If A through F
	bgt	AtoF
	b	num
AtoF:
	sub	r1, r1, #7
num:
	sub	r1, r1, #48	@ ascii to hex for single digit
	sub	r2, r6, r8	@ Get Power
	sub	r2, r2, #1	@ ^ Continued
	ldr	r4, =#16
	mov	r3, #1
	bl	power

	add	r5, r5, r3
	add	r8, r8, #1
	b	loop
endloop:
	pop	{pc}

power:
	push	{lr}
pow:
	cmp	r2, #0
	beq	endpow
	mul	r3, r3, r4
	sub	r2, r2, #1
	b	pow
endpow:
	mul	r3, r3, r1
	pop	{pc}

fracPrecision:
	push	{lr}
	mov	r1, #0		@ r0 = #0
	
	cmp	r5, #25		@ If < 1/4
	blt	zero
	
	cmp	r5, #50		@ If < 1/2
	blt	quarter

	cmp	r5, #75		@ If < 3/4
	blt	half

	add	r1, r1, #1
half:
	add	r1, r1, #1
quarter:
	add	r1, r1, #1
zero:
	pop	{pc}

main:
	bl	uio
	mov	r8, #0		@ Counter
	mov	r6, #3		@ Whole Length
	bl	asc2hex		@ Returns Whole number part in r5	
	mov	r0, r5, lsl #2	@ Shift whole part to correct bits for Q8.2 and store in r0
	push	{r0}
	mov	r8, #4		@ Counter
	mov	r6, #6		@ Fractional Length
	bl	asc2hex		@ Returns Fractional number part in r5
	bl	fracPrecision	@ Returns 2 bit Fractional part in r1
	pop	{r0}
	add	r0, r0, r1	@ Combine whole and fractional numbers to make Q8.2 Number
				@ Fix sign


	bl	terminate

	.data
inbuff:
	.space	20
	.equ	inbuffLen, (.-inbuff)

	.end

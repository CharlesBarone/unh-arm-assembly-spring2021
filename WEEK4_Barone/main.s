	.global main
	.equ	STDIN, 0
	.equ	STDOUT, 1
	.text

prompt:
	.asciz "Please Enter (Include Sign +/-) (XXX.XX) >>"

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

getSign:
	push	{lr}
	ldr	r2, =inbuff
	ldrb	r3, [r2,#0]	@ Load r3 with ascii value of sign
	cmp	r3, #43		@ If sign is + do nothing
	beq	positive
	ldr	r1, =#0x200	@ Set sign to -
positive:
	pop	{pc}

hex2dec:
	push	{lr}
	ldr	r6, =outbuff
	and	r1, r0, #0x200	@Get Sign bit
	cmp	r1, #0x200
	beq	neg
	ldr	r1, =#0x2B	@ Load ascii +
	b	skipneg
neg:
	ldr	r1, =#0x2D	@ Load ascii -
skipneg:
	strb	r1, [r6]	@ Store sign in ascii
	push	{r0}
	mov	r0, r0, lsr #2	@ Remove Fractional Bits
	and	r0, r0, #0x7F	@ Remove Sign Bit
	
	mov	r1, #100
	bl	modN		@ Get 100s place
	ldr	r7, [r6]
	add	r1, #0x30	@ To ascii
	lsl	r1, #8		@ Rotate 8 positions to left
	orr	r1, r7		@ or in 100s place
	str	r1, [r6]
	
	mov	r1, #10
	bl	modN		@ Get 10s place
	add	r1, #0x30	@ To ascii
	lsl	r1, #16		@ Rotate 16 positions to left
	ldr	r7, [r6]
	orr	r1, r7		@ or in 10s place
	str	r1, [r6]

	add	r0, #0x30	@ Remainder is 1s place, convert to ascii
	lsl	r0, #24		@ Rotate 24 positions to left
	ldr	r7, [r6]
	orr	r0, r7		@ or in 1s place
	str	r0, [r6]
	
	ldr	r0, =#0x2E	@ Load '.' into r0
	str	r0, [r6,#4]

	pop	{r0}
	and	r0, #3		@ Keep only fractional part
	cmp	r0, #0
	beq	zero2
	cmp	r0, #1
	beq	quarter2
	cmp	r0, #2
	beq	half2
	ldr	r0, =#0x37
	str	r0, [r6,#5]
	ldr	r0, =#0x35
	str	r0, [r6,#6]
	b	decDone	
zero2:
	ldr	r0, =#0x30
	str	r0, [r6,#5]
	str	r0, [r6,#6]
	b	decDone
quarter2:
	ldr	r0, =#0x32
	str	r0, [r6,#5]
	ldr	r0, =#0x35
	str	r0, [r6,#6]
	b	decDone
half2:
	ldr	r0, =#0x35
	str	r0, [r6,#5]
	ldr	r0, =#0x30
	str	r0, [r6,#6]
decDone:	
	ldr	r0, =outbuff
	bl	puts
	pop	{pc}

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


main:
	bl	uio
	mov	r8, #1		@ Counter
	mov	r6, #4		@ Whole Length
	bl	asc2hex		@ Returns Whole number part in r5	
	mov	r0, r5, lsl #2	@ Shift whole part to correct bits for Q8.2 and store in r0
	push	{r0}
	mov	r8, #5		@ Counter
	mov	r6, #7		@ Fractional Length
	bl	asc2hex		@ Returns Fractional number part in r5
	bl	fracPrecision	@ Returns 2 bit Fractional part in r1
	pop	{r0}
	add	r0, r0, r1	@ Combine whole and fractional numbers to make Q8.2 Number
	bl	getSign		@ Get Sign and store into r1
	add	r0, r0, r1
	bl	hex2dec		@ Convert signed hex Q8.2 number in r0 to decimal ascii value and print
	bl	terminate

	.data
inbuff:
	.space	20
	.equ	inbuffLen, (.-inbuff)

outbuff:
	.space 20
	.equ	outbuffLen, (.-outbuff)

	.end

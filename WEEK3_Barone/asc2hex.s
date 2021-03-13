@ Takes ascii from inbuff, length from inbuffLen, and returns a register with the value in r5
asc2hex:
	push	{lr}
	mov	r8, #0		@ Counter
	mov	r5, #0		@ Total Value

	ldr	r0, =inbuff
	bl	strlen
	mov	r6, r0		@ Move strlen to r6
	sub	r7, r6, #1	@ Length w/o line feed
loop:
	cmp	r8, r6		@ Loop till new line feed
	beq	endloop		@ Branch to endloop

	ldr	r0, =inbuff	@ Load r0 with Buffer
	ldrb	r1, [r0, r8]	@ Load r1 with ascii value
	sub	r1, r1, #48	@ Convert to decimal digit
	sub	r2, r7, r8	@ Get Power
	sub	r2, r2, #1	@ ^ Continued
	mov	r4, #10		@ Move #10 into r4
	mov	r3, #1		@ Move #1 into r3
	bl	power

	add	r5, r5, r3
	add	r8, r8, #1
	b	loop
endloop:
	pop	{pc}

@ a*d^b=c, r1 = a, r2 = b, r3 = c, r4 = d
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


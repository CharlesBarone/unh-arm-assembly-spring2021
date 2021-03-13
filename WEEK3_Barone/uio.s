@ Takes user input from STDIN and returns it in inbuff
uio:
	push	{lr}
	ldr	r0, =prompt
	bl	puts
	mov	r0, #STDIN
	ldr	r1, =inbuff
	mov	r2, #inbuffLen
	bl	read
	pop	{pc}


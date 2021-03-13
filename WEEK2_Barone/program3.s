	.global main
	.text

@===============
@ Implemented multiply and divide operations using shifts.
@ Charles Barone
@

ndiv:
	mov	r2, #32
	sub	r2, r1
	mov	r0, r0, ROR r2
	b	nmul
nmul:
	mov	r0, r0, ROR r1
	b	end

main:	
	mov 	r0,#10
	mov 	r1,#5

	b	ndiv

end:

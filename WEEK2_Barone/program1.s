	.global main
	.text

@===============
@ Implemented multiply and divide operations using shifts.
@ Charles Barone
@

ndiv:
	mov	r0, r0, lsl r1
	b	nmul
nmul:
	mov	r0, r0, lsr r1
	b	end

main:	
	mov 	r0,#10
	mov 	r1,#5

	b	ndiv

end:

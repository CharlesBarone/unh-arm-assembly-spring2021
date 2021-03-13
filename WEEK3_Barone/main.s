	.global main
	.equ	STDIN, 0
	.equ	STDOUT, 1
	.text

prompt:
	.asciz "Please Enter >>"

msg:
	.asciz "Done"

	.align
	.include "uio.s"
	.include "asc2hex.s"
	.include "cntFnct.s"
	.include "cntDone.s"
	
terminate:
	mov	r0, #0
	mov	r7, #1
	swi	0

main:
	bl	uio
	bl	asc2hex
	bl	cntFnct
	bl	cntDone
	bl	terminate

	.data
inbuff:
	.space	8
	.equ	inbuffLen, (.-inbuff)

	.end


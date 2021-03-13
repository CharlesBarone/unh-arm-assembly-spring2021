@Counts down value in r5 to 0
cntFnct:
	push	{lr}
count:
	cmp	r5, #0		@ Check if counting is done
	beq	endcnt		@ Branch to endcnt
	sub	r5, r5, #1	@ r5--
	b	count
endcnt:
	pop	{pc}


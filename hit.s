	.data
t:	.word	0

	.text
	.globl	hit
hit:
	stmfd	sp!, {r4}
	mov	r4, r14

	@ generate seed
	ldr	r0, =t
	bl	time
	ldr	r0, =t
	ldr	r0, [r0]
	bl	srand

	@ generate random number, validate it is [1 - 11]
lp:
	bl	rand
	and	r0, r0, #0xF
	cmp	r0, #0x0
	addeq	r0, r0, #1
	cmp	r0, #0xB
	bgt	lp
	cmp	r0, r5
	beq	lp
	mov	r1, r0

	mov	r14, r4
	ldmfd	sp!, {r4}
	mov	pc, lr

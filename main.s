	.data
ans:	.word	0
strt:	.asciz	"Welcome to AssemblyJack!\nLet's play!\n"
	.align	2
card:	.asciz	"Card: %d\n"
	.align	2
pcrd:	.asciz	"Player drew: %d\n"
	.align	2
dcrd:	.asciz	"Dealer drew: %d\n"
	.align	2
str:	.asciz	"%d"
	.align	2
inp:	.asciz	"Hit (0) or stay (1)?\n"
	.align	2
pts:	.asciz	"Starting points: %d\n"
	.align	2
ppts:	.asciz	"Your points: %d\n"
	.align	2
dpts:	.asciz	"Dealer points: %d\n"
	.align	2
won:	.asciz	"You win!!!\n"
	.align	2
lost:	.asciz	"You stink, loser!\n"

	.text
	.globl	main

main:	stmfd	sp!, {lr}

	@ display start game prompt
	ldr	r0, =strt
	bl	printf

	@ create 12 bytes in stack to store points
	@ for first 2 cards(#8), players(#4), and dealers cards(#0).
	sub	sp, sp, #16
	@ scanf demands a double word boundary for the stack pointer, thus 4 extra bytes.

stgm:
	@ this should generate a number [1 - 11] for the first card, move card to r5 for later
	bl	hit
	mov	r5, r1
	ldr	r0, =card
	bl	printf

	@ second card, calculate and store point value in stack
	bl	hit
	add	r4, r1, r5
	mov	r2, r4
	mov	r3, r4
	stmia	sp, {r2, r3, r4}

	ldr	r0, =card
	bl	printf

	@ test if first 2 cards = 21, go to win condition if true
	ldr	r4, [sp, #8]
	cmp	r4, #21
	beq	win


	@ print current point totals
	ldr	r0, =pts
	ldr	r1, [sp, #4]
	bl	printf


plyr:	@ hit or stay for player

	ldr	r0, =inp
	bl	printf

	ldr	r0, =str
	ldr	r1, =ans
	bl	scanf

	ldr	r1, =ans
	ldr	r1, [r1]
	cmp	r1, #0
	bne	dlr
	bl	hit

	ldr	r0, [sp, #4]
	add	r0, r0, r1
	str	r0, [sp, #4]

	ldr	r0, =pcrd
	bl	printf

	   @ display new point value
	ldr	r0, =ppts
	ldr	r1, [sp, #4]
	bl	printf

	   @ test if player pts > 21
	ldr	r0, [sp, #4]
	cmp	r0, #21
	movgt	r0, #21
	strgt	r0, [sp]
	bgt	dlr

	   @ let it ride!
	b	plyr


dlr:	@ hit or stay for 'dealer'
	@ dealer will automatically hit until pts >= 17
	ldr	r1, [sp]
	cmp	r1, #17
	bge	end

	bl	hit
	mov	r5, r1

	ldr	r0, =dcrd
	bl	printf

	ldr	r2, [sp]
	add	r4, r5, r2

	str	r4, [sp]

	b	dlr

end:
	@ plyr wins if : (plyrPts > dlrPts AND plyrPts <= 21)
	@ OR ( plyrPts <= 21 AND dlrPts > 21
	ldr	r0, [sp, #4]   @ plyrPts
	ldr	r1, [sp]       @ dlrPts

	   @ if plyrPts > 21, player loses
	cmp	r0, #21
	bgt	lose

	   @ if dlrPts > 21
	cmp	r1, #21
	bge	win

	   @ if plyrPts > dlrPts, player wins
	cmp	r0, r1
	ble	lose
	b	win


win:	@ player wins!
	ldr	r0, =dpts
	ldr	r1, [sp]
	bl	printf

	ldr	r0, =won
	bl	printf
	b	stop

lose:	@ player loses :(
	ldr	r0, =dpts
	ldr	r1, [sp]
	bl	printf

	ldr	r0, =lost
	bl	printf

stop:
	add	sp, sp, #16

	ldmfd	sp!, {lr}
	mov	r0, #0
	mov	pc, lr
	.end


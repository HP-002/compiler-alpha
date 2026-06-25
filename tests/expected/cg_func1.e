	.text
	.globl	entry


entry:
	pushq %rbp
	movq %rsp, %rbp
	subq $40, %rsp

.L_11:
	pushq $5
	call factorial
	addq $8, %rsp
	movl %eax, -24(%rbp)

.L_13:
	movl -24(%rbp), %ebx
	pushq %rbx
	movl %ebx, -40(%rbp)
	call printInteger
	addq $8, %rsp
	movl %eax, -16(%rbp)

.L_16:
	movl -16(%rbp), %ebx
	pushq $10
	movl %ebx, -32(%rbp)
	call printCharacter
	addq $8, %rsp
	movl %eax, -8(%rbp)

.L_19:
	movl -8(%rbp), %ebx
	movl $0, %eax
	movq %rbp, %rsp
	popq %rbp
	ret

factorial:
	pushq %rbp
	movq %rsp, %rbp
	subq $16, %rsp

.L_0:
	movl 16(%rbp), %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	je .L_2
	movl %ebx, 16(%rbp)

.L_1:
	jmp .L_4

.L_2:
	movl $1, %eax
	movq %rbp, %rsp
	popq %rbp
	ret

.L_3:
	jmp .L_11

.L_4:
	movl 16(%rbp), %ebx
	movl %ebx, 16(%rbp)
	subl $1, %ebx
	pushq %rbx
	movl %ebx, -16(%rbp)
	call factorial
	addq $8, %rsp
	movl %eax, -32(%rbp)

.L_8:
	movl -32(%rbp), %ebx
	movl 16(%rbp), %ecx
	movl %ecx, 16(%rbp)
	imull %ebx, %ecx
	movl %ecx, %eax
	movq %rbp, %rsp
	popq %rbp
	ret

.crash:
    movq %rbx, -8(%rbp)
	pushq $24
	call reserve
	addq $0, %rsp
	movl $20, 0(%rax)
	movb $65, 4(%rax)
	movb $114, 5(%rax)
	movb $114, 6(%rax)
	movb $97, 7(%rax)
	movb $121, 8(%rax)
	movb $32, 9(%rax)
	movb $79, 10(%rax)
	movb $117, 11(%rax)
	movb $116, 12(%rax)
	movb $32, 13(%rax)
	movb $111, 14(%rax)
	movb $102, 15(%rax)
	movb $32, 16(%rax)
	movb $66, 17(%rax)
	movb $111, 18(%rax)
	movb $117, 19(%rax)
	movb $110, 20(%rax)
	movb $100, 21(%rax)
	movb $115, 22(%rax)
	movb $33, 23(%rax)
	movq %rax, %rbx
	movl $1, %ecx
	negl %ecx
	movl %ecx, %eax
	movq %rbp, %rsp
	popq %rbp
	ret
    
	.text
	.globl	entry


entry:
	pushq %rbp
	movq %rsp, %rbp
	subq $56, %rsp

.L_6:
	pushq $10
	pushq $20
	call sum
	addq $16, %rsp
	movl %eax, -40(%rbp)

.L_9:
	movl -40(%rbp), %ebx
	movl -56(%rbp), %ecx
	movl 0(%rcx), %r8d
	pushq %r8
	movl 8(%rcx), %r9d
	pushq %r9
	movl %ebx, -48(%rbp)
	movl %ecx, -56(%rbp)
	movl %r8d, -32(%rbp)
	movl %r9d, -24(%rbp)
	call sum
	addq $16, %rsp
	movl %eax, -16(%rbp)

.L_15:
	movl -16(%rbp), %ebx
	movl -56(%rbp), %ecx
	pushq %rcx
	movl %ebx, -48(%rbp)
	movl %ecx, -56(%rbp)
	call sum2
	addq $8, %rsp
	movl %eax, -8(%rbp)

.L_18:
	movl -8(%rbp), %ebx
	movq %rbp, %rsp
	popq %rbp
	ret

sum2:
	pushq %rbp
	movq %rsp, %rbp
	subq $24, %rsp
	movl %ebx, -48(%rbp)

.L_2:
	movl 16(%rbp), %ebx
	movl 0(%rbx), %ecx
	movl 8(%rbx), %r8d
	movl %ecx, -24(%rbp)
	addl %r8d, %ecx
	movl %ecx, %eax
	movq %rbp, %rsp
	popq %rbp
	ret

sum:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp

.L_0:
	movl 24(%rbp), %ebx
	movl 16(%rbp), %ecx
	movl %ebx, 24(%rbp)
	addl %ecx, %ebx
	movl %ebx, %eax
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
    
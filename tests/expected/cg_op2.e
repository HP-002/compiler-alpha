	.text
	.globl	entry


entry:
	pushq %rbp
	movq %rsp, %rbp
	subq $96, %rsp

.L_0:
	movl $10, %ebx
	movl $12, %ecx
	movl $220, %r8d
	movl %ebx, -96(%rbp)
	imull $2, %ebx
	movl -96(%rbp), %r9d
	movl %r9d, -96(%rbp)
	imull %ecx, %r9d
	movl $5, %r10d
	movl -96(%rbp), %r11d
	movl $100, %eax
	cltd
	idivl %r11d
	movl %eax, -40(%rbp)
	movl -40(%rbp), %r12d
	movl %r11d, %eax
	cltd
	idivl %ecx
	movl %eax, -32(%rbp)
	movl -32(%rbp), %r13d
	movl $2, %r14d
	movl -96(%rbp), %r15d
	movl %r15d, %eax
	movl %r8d, -80(%rbp)
	movl $2, %r8d
	cltd
	idivl %r8d
	movl %edx, -16(%rbp)
	movl %r9d, -80(%rbp)
	movl -16(%rbp), %r9d
	movl %r10d, -80(%rbp)
	movl -96(%rbp), %r10d
	movl %r10d, %eax
	cltd
	idivl %ecx
	movl %edx, -8(%rbp)
	movl %r11d, -96(%rbp)
	movl -8(%rbp), %r11d
	movl $0, %eax
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
    
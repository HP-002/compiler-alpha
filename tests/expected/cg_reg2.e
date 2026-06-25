	.text
	.globl	entry


entry:
	pushq %rbp
	movq %rsp, %rbp
	subq $192, %rsp

.L_0:
	movl $1, %ebx
	movl $2, %ecx
	movl $3, %r8d
	movl $4, %r9d
	movl $5, %r10d
	movl $6, %r11d
	movl $7, %r12d
	movl $8, %r13d
	movl $9, %r14d
	movl $10, %r15d
	movl %r8d, -176(%rbp)
	movl $11, %r8d
	movl %r9d, -168(%rbp)
	movl $12, %r9d
	movl %ebx, -192(%rbp)
	addl %ecx, %ebx
	movl %r10d, -160(%rbp)
	movl -176(%rbp), %r10d
	movl %r11d, -152(%rbp)
	movl -168(%rbp), %r11d
	movl %r10d, -176(%rbp)
	addl %r11d, %r10d
	movl %ebx, -88(%rbp)
	addl %r10d, %ebx
	movl %r12d, -144(%rbp)
	movl -160(%rbp), %r12d
	movl %r13d, -136(%rbp)
	movl -152(%rbp), %r13d
	movl %r12d, -160(%rbp)
	addl %r13d, %r12d
	movl %r14d, -128(%rbp)
	movl -144(%rbp), %r14d
	movl %r15d, -120(%rbp)
	movl -136(%rbp), %r15d
	movl %r14d, -144(%rbp)
	addl %r15d, %r14d
	movl %r12d, -64(%rbp)
	addl %r14d, %r12d
	movl %ebx, -72(%rbp)
	addl %r12d, %ebx
	movl %ebx, -40(%rbp)
	movl -128(%rbp), %ebx
	movl %ecx, -184(%rbp)
	movl -120(%rbp), %ecx
	movl %ebx, -128(%rbp)
	addl %ecx, %ebx
	movl %r8d, -112(%rbp)
	addl %r9d, %r8d
	movl %ebx, -32(%rbp)
	addl %r8d, %ebx
	movl %r8d, -24(%rbp)
	movl -40(%rbp), %r8d
	movl %r8d, -40(%rbp)
	addl %ebx, %r8d
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
    
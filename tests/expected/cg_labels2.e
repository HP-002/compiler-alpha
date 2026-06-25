	.text
	.globl	entry


entry:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp

.L_2:
	movl $5, %ebx
	pushq %rbx
	movl %ebx, -32(%rbp)
	call square
	addq $8, %rsp
	movl %eax, -16(%rbp)

.L_5:
	movl -16(%rbp), %ebx
	pushq %rbx
	movl %ebx, -32(%rbp)
	call printInteger
	addq $8, %rsp
	movl %eax, -8(%rbp)

.L_8:
	movl -8(%rbp), %ebx
	movl $0, %eax
	movq %rbp, %rsp
	popq %rbp
	ret

square:
	pushq %rbp
	movq %rsp, %rbp
	subq $8, %rsp

.L_0:
	movl 16(%rbp), %ebx
	movl %ebx, 16(%rbp)
	imull %ebx, %ebx
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
    
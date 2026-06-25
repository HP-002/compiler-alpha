	.text
	.globl	entry


entry:
	pushq %rbp
	movq %rsp, %rbp
	subq $32, %rsp

.L_0:
	movl $10, %ebx
	movl $20, %ecx
	movl %ebx, -32(%rbp)
	movl %ecx, -24(%rbp)
	movl -32(%rbp), %ebx
	movl -24(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_4
	movl %ebx, -32(%rbp)
	movl %ecx, -24(%rbp)

.L_3:
	jmp .L_8

.L_4:
	pushq $111
	call printInteger
	addq $8, %rsp
	movl %eax, -40(%rbp)

.L_6:
	movl -40(%rbp), %ebx
	movl %ebx, -8(%rbp)
	jmp .L_11

.L_8:
	pushq $0
	call printInteger
	addq $8, %rsp
	movl %eax, -40(%rbp)

.L_10:
	movl -40(%rbp), %ebx
	movl %ebx, -8(%rbp)

.L_11:
	movl -32(%rbp), %ebx
	movl $10, %ecx
	cmpl %ecx, %ebx
	je .L_13
	movl %ebx, -32(%rbp)

.L_12:
	jmp .L_15

.L_13:
	movb $1, %bl
	movb %bl, -16(%rbp)
	jmp .L_16

.L_15:
	movb $0, %bl
	movb %bl, -16(%rbp)

.L_16:
	movb -16(%rbp), %bl
	cmpb $1, %bl
	je .L_18
	movb %bl, -16(%rbp)

.L_17:
	jmp .L_22

.L_18:
	pushq $222
	call printInteger
	addq $8, %rsp
	movl %eax, -40(%rbp)

.L_20:
	movl -40(%rbp), %ebx
	movl %ebx, -8(%rbp)
	jmp .L_25

.L_22:
	pushq $0
	call printInteger
	addq $8, %rsp
	movl %eax, -40(%rbp)

.L_24:
	movl -40(%rbp), %ebx
	movl %ebx, -8(%rbp)

.L_25:
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
    
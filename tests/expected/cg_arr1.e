	.text
	.globl	entry


entry:
	pushq %rbp
	movq %rsp, %rbp
	subq $160, %rsp

.L_0:
	movl $3, %ebx
	movl %ebx, -152(%rbp)
	addl $4, %ebx
	pushq %rbx
	movl %ebx, -144(%rbp)
	call reserve
	addq $8, %rsp
	movq %rax, -136(%rbp)

.L_4:
	movq -136(%rbp), %rbx
	movl $3, 0(%rbx)
	movl 0(%rbx), %ecx
	movq %rbx, -160(%rbp)
	movl %ecx, -128(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_13

.L_8:
	movl $0, %ebx
	movl -128(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_10
	movl %ecx, -128(%rbp)

.L_9:
	jmp .L_13

.L_10:
	movl $0, %ebx
	movl %ebx, -120(%rbp)
	addl $4, %ebx
	movl %ebx, -112(%rbp)
	jmp .L_14

.L_13:
	call .crash

.L_14:
	movq -160(%rbp), %rbx
	movl -112(%rbp), %ecx
	addq %rbx, %rcx
	movb $65, (%rcx)
	movl 0(%rbx), %ecx
	movq %rbx, -160(%rbp)
	movl %ecx, -104(%rbp)
	movl $1, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_22

.L_17:
	movl $1, %ebx
	movl -104(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_19
	movl %ecx, -104(%rbp)

.L_18:
	jmp .L_22

.L_19:
	movl $1, %ebx
	movl %ebx, -96(%rbp)
	addl $4, %ebx
	movl %ebx, -88(%rbp)
	jmp .L_23

.L_22:
	call .crash

.L_23:
	movq -160(%rbp), %rbx
	movl -88(%rbp), %ecx
	addq %rbx, %rcx
	movb $66, (%rcx)
	movl 0(%rbx), %ecx
	movq %rbx, -160(%rbp)
	movl %ecx, -80(%rbp)
	movl $2, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_31

.L_26:
	movl $2, %ebx
	movl -80(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_28
	movl %ecx, -80(%rbp)

.L_27:
	jmp .L_31

.L_28:
	movl $2, %ebx
	movl %ebx, -72(%rbp)
	addl $4, %ebx
	movl %ebx, -64(%rbp)
	jmp .L_32

.L_31:
	call .crash

.L_32:
	movq -160(%rbp), %rbx
	movl -64(%rbp), %ecx
	addq %rbx, %rcx
	movb $67, (%rcx)
	movl 0(%rbx), %ecx
	movq %rbx, -160(%rbp)
	movl %ecx, -56(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_40

.L_35:
	movl $0, %ebx
	movl -56(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_37
	movl %ecx, -56(%rbp)

.L_36:
	jmp .L_40

.L_37:
	movl $0, %ebx
	movl %ebx, -48(%rbp)
	addl $4, %ebx
	movl %ebx, -40(%rbp)
	jmp .L_41

.L_40:
	call .crash

.L_41:
	movq -160(%rbp), %rbx
	movl 0(%rbx), %ecx
	movq %rbx, -160(%rbp)
	movl %ecx, -32(%rbp)
	movl $2, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_48

.L_43:
	movl $2, %ebx
	movl -32(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_45
	movl %ecx, -32(%rbp)

.L_44:
	jmp .L_48

.L_45:
	movl $2, %ebx
	movl %ebx, -24(%rbp)
	addl $4, %ebx
	movl %ebx, -16(%rbp)
	jmp .L_49

.L_48:
	call .crash

.L_49:
	movq -160(%rbp), %rbx
	movl -16(%rbp), %ecx
	addq %rbx, %rcx
	movb (%rcx), %r8b
	movl -40(%rbp), %ecx
	addq %rbx, %rcx
	movb %r8b, (%rcx)
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
    
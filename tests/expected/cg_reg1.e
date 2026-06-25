	.text
	.globl	entry


entry:
	pushq %rbp
	movq %rsp, %rbp
	subq $136, %rsp

.L_0:
	movb $65, %bl
	movl $1111, %ecx
	movb $66, %r8b
	movl $9999, %r9d
	movb %bl, -136(%rbp)
	movl %ecx, -128(%rbp)
	movb %r8b, -120(%rbp)
	movl %r9d, -112(%rbp)
	movl -128(%rbp), %ebx
	movl -112(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_6
	movl %ebx, -128(%rbp)
	movl %ecx, -112(%rbp)

.L_5:
	jmp .L_8

.L_6:
	movb $1, %bl
	movb %bl, -104(%rbp)
	jmp .L_9

.L_8:
	movb $0, %bl
	movb %bl, -104(%rbp)

.L_9:
	movl $4, %ebx
	movl %ebx, -80(%rbp)
	addl $4, %ebx
	pushq %rbx
	movl %ebx, -72(%rbp)
	call reserve
	addq $8, %rsp
	movq %rax, -64(%rbp)

.L_13:
	movq -64(%rbp), %rbx
	movl $1, 0(%rbx)
	movl 0(%rbx), %ecx
	movq %rbx, -96(%rbp)
	movl %ecx, -56(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_22

.L_17:
	movl $0, %ebx
	movl -56(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_19
	movl %ecx, -56(%rbp)

.L_18:
	jmp .L_22

.L_19:
	movl $0, %ebx
	movl %ebx, -48(%rbp)
	addl $4, %ebx
	movl %ebx, -40(%rbp)
	jmp .L_23

.L_22:
	call .crash

.L_23:
	movq -96(%rbp), %rbx
	movl -40(%rbp), %ecx
	addq %rbx, %rcx
	movl $9999, (%rcx)
	movb -136(%rbp), %cl
	pushq %rcx
	movq %rbx, -96(%rbp)
	movb %cl, -136(%rbp)
	call printCharacter
	addq $8, %rsp
	movl %eax, -32(%rbp)

.L_26:
	movl -32(%rbp), %ebx
	movl -128(%rbp), %ecx
	pushq %rcx
	movl %ebx, -88(%rbp)
	movl %ecx, -128(%rbp)
	call printInteger
	addq $8, %rsp
	movl %eax, -24(%rbp)

.L_29:
	movl -24(%rbp), %ebx
	movb -120(%rbp), %cl
	pushq %rcx
	movl %ebx, -88(%rbp)
	movb %cl, -120(%rbp)
	call printCharacter
	addq $8, %rsp
	movl %eax, -16(%rbp)

.L_32:
	movl -16(%rbp), %ebx
	movl %ebx, -88(%rbp)
	movb -104(%rbp), %bl
	cmpb $1, %bl
	je .L_35
	movb %bl, -104(%rbp)

.L_34:
	jmp .L_48

.L_35:
	movq -96(%rbp), %rbx
	movl 0(%rbx), %ecx
	movq %rbx, -96(%rbp)
	movl %ecx, -176(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_42

.L_37:
	movl $0, %ebx
	movl -176(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_39
	movl %ecx, -176(%rbp)

.L_38:
	jmp .L_42

.L_39:
	movl $0, %ebx
	movl %ebx, -168(%rbp)
	addl $4, %ebx
	movl %ebx, -160(%rbp)
	jmp .L_43

.L_42:
	call .crash

.L_43:
	movq -96(%rbp), %rbx
	movl -160(%rbp), %ecx
	addq %rbx, %rcx
	movl (%rcx), %r8d
	pushq %r8
	movq %rbx, -96(%rbp)
	movl %r8d, -152(%rbp)
	call printInteger
	addq $8, %rsp
	movl %eax, -144(%rbp)

.L_46:
	movl -144(%rbp), %ebx
	movl %ebx, -88(%rbp)
	jmp .L_51

.L_48:
	pushq $0
	call printInteger
	addq $8, %rsp
	movl %eax, -144(%rbp)

.L_50:
	movl -144(%rbp), %ebx
	movl %ebx, -88(%rbp)

.L_51:
	pushq $10
	call printCharacter
	addq $8, %rsp
	movl %eax, -8(%rbp)

.L_53:
	movl -8(%rbp), %ebx
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
    
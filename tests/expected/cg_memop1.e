	.text
	.globl	entry


entry:
	pushq %rbp
	movq %rsp, %rbp
	subq $368, %rsp

.L_0:
	movl $12, %ebx
	movl %ebx, -344(%rbp)
	addl $4, %ebx
	pushq %rbx
	movl %ebx, -336(%rbp)
	call reserve
	addq $8, %rsp
	movq %rax, -328(%rbp)

.L_4:
	movq -328(%rbp), %rbx
	movl $3, 0(%rbx)
	movl 0(%rbx), %ecx
	movq %rbx, -368(%rbp)
	movl %ecx, -320(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_13

.L_8:
	movl $0, %ebx
	movl -320(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_10
	movl %ecx, -320(%rbp)

.L_9:
	jmp .L_13

.L_10:
	movl $0, %ebx
	movl %ebx, -312(%rbp)
	addl $4, %ebx
	movl %ebx, -304(%rbp)
	jmp .L_14

.L_13:
	call .crash

.L_14:
	movq -368(%rbp), %rbx
	movl -304(%rbp), %ecx
	addq %rbx, %rcx
	movl $10, (%rcx)
	movl 0(%rbx), %ecx
	movq %rbx, -368(%rbp)
	movl %ecx, -296(%rbp)
	movl $1, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_22

.L_17:
	movl $1, %ebx
	movl -296(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_19
	movl %ecx, -296(%rbp)

.L_18:
	jmp .L_22

.L_19:
	movl $4, %ebx
	movl %ebx, -288(%rbp)
	addl $4, %ebx
	movl %ebx, -280(%rbp)
	jmp .L_23

.L_22:
	call .crash

.L_23:
	movq -368(%rbp), %rbx
	movl -280(%rbp), %ecx
	addq %rbx, %rcx
	movl $20, (%rcx)
	movl 0(%rbx), %ecx
	movq %rbx, -368(%rbp)
	movl %ecx, -272(%rbp)
	movl $2, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_31

.L_26:
	movl $2, %ebx
	movl -272(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_28
	movl %ecx, -272(%rbp)

.L_27:
	jmp .L_31

.L_28:
	movl $8, %ebx
	movl %ebx, -264(%rbp)
	addl $4, %ebx
	movl %ebx, -256(%rbp)
	jmp .L_32

.L_31:
	call .crash

.L_32:
	movq -368(%rbp), %rbx
	movl -256(%rbp), %ecx
	addq %rbx, %rcx
	movl $30, (%rcx)
	movl $1, %ecx
	movl 0(%rbx), %r8d
	movl 0(%rbx), %r9d
	movq %rbx, -368(%rbp)
	movl %ecx, -360(%rbp)
	movl %r8d, -360(%rbp)
	movl %r9d, -240(%rbp)
	movl -360(%rbp), %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_43
	movl %ebx, -360(%rbp)

.L_38:
	movl -360(%rbp), %ebx
	movl -240(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_40
	movl %ebx, -360(%rbp)
	movl %ecx, -240(%rbp)

.L_39:
	jmp .L_43

.L_40:
	movl -360(%rbp), %ebx
	movl %ebx, -360(%rbp)
	imull $4, %ebx
	movl %ebx, -232(%rbp)
	addl $4, %ebx
	movl %ebx, -224(%rbp)
	jmp .L_44

.L_43:
	call .crash

.L_44:
	movq -368(%rbp), %rbx
	movl 0(%rbx), %ecx
	movq %rbx, -368(%rbp)
	movl %ecx, -216(%rbp)
	movl -360(%rbp), %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_51
	movl %ebx, -360(%rbp)

.L_46:
	movl -360(%rbp), %ebx
	movl -216(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_48
	movl %ebx, -360(%rbp)
	movl %ecx, -216(%rbp)

.L_47:
	jmp .L_51

.L_48:
	movl -360(%rbp), %ebx
	movl %ebx, -360(%rbp)
	imull $4, %ebx
	movl %ebx, -208(%rbp)
	addl $4, %ebx
	movl %ebx, -200(%rbp)
	jmp .L_52

.L_51:
	call .crash

.L_52:
	movq -368(%rbp), %rbx
	movl -200(%rbp), %ecx
	addq %rbx, %rcx
	movl (%rcx), %r8d
	movl %r8d, -192(%rbp)
	addl $5, %r8d
	movl -224(%rbp), %ecx
	addq %rbx, %rcx
	movl %r8d, (%rcx)
	movl $2, %ecx
	movl 0(%rbx), %r9d
	movq %rbx, -368(%rbp)
	movl %ecx, -360(%rbp)
	movl %r8d, -184(%rbp)
	movl %r9d, -176(%rbp)
	movl -360(%rbp), %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_63
	movl %ebx, -360(%rbp)

.L_58:
	movl -360(%rbp), %ebx
	movl -176(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_60
	movl %ebx, -360(%rbp)
	movl %ecx, -176(%rbp)

.L_59:
	jmp .L_63

.L_60:
	movl -360(%rbp), %ebx
	movl %ebx, -360(%rbp)
	imull $4, %ebx
	movl %ebx, -168(%rbp)
	addl $4, %ebx
	movl %ebx, -160(%rbp)
	jmp .L_64

.L_63:
	call .crash

.L_64:
	movq -368(%rbp), %rbx
	movl 0(%rbx), %ecx
	movq %rbx, -368(%rbp)
	movl %ecx, -152(%rbp)
	movl -360(%rbp), %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_71
	movl %ebx, -360(%rbp)

.L_66:
	movl -360(%rbp), %ebx
	movl -152(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_68
	movl %ebx, -360(%rbp)
	movl %ecx, -152(%rbp)

.L_67:
	jmp .L_71

.L_68:
	movl -360(%rbp), %ebx
	movl %ebx, -360(%rbp)
	imull $4, %ebx
	movl %ebx, -144(%rbp)
	addl $4, %ebx
	movl %ebx, -136(%rbp)
	jmp .L_72

.L_71:
	call .crash

.L_72:
	movq -368(%rbp), %rbx
	movl -136(%rbp), %ecx
	addq %rbx, %rcx
	movl (%rcx), %r8d
	movl %r8d, -128(%rbp)
	imull $2, %r8d
	movl -160(%rbp), %ecx
	addq %rbx, %rcx
	movl %r8d, (%rcx)
	movl 0(%rbx), %ecx
	movq %rbx, -368(%rbp)
	movl %ecx, -112(%rbp)
	movl %r8d, -120(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_82

.L_77:
	movl $0, %ebx
	movl -112(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_79
	movl %ecx, -112(%rbp)

.L_78:
	jmp .L_82

.L_79:
	movl $0, %ebx
	movl %ebx, -104(%rbp)
	addl $4, %ebx
	movl %ebx, -96(%rbp)
	jmp .L_83

.L_82:
	call .crash

.L_83:
	movq -368(%rbp), %rbx
	movl -96(%rbp), %ecx
	addq %rbx, %rcx
	movl (%rcx), %r8d
	movl 0(%rbx), %ecx
	movq %rbx, -368(%rbp)
	movl %ecx, -80(%rbp)
	movl %r8d, -88(%rbp)
	movl $1, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_91

.L_86:
	movl $1, %ebx
	movl -80(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_88
	movl %ecx, -80(%rbp)

.L_87:
	jmp .L_91

.L_88:
	movl $4, %ebx
	movl %ebx, -72(%rbp)
	addl $4, %ebx
	movl %ebx, -64(%rbp)
	jmp .L_92

.L_91:
	call .crash

.L_92:
	movq -368(%rbp), %rbx
	movl -64(%rbp), %ecx
	addq %rbx, %rcx
	movl (%rcx), %r8d
	movl -88(%rbp), %ecx
	movl %ecx, -88(%rbp)
	addl %r8d, %ecx
	movl 0(%rbx), %r9d
	movq %rbx, -368(%rbp)
	movl %ecx, -48(%rbp)
	movl %r8d, -56(%rbp)
	movl %r9d, -40(%rbp)
	movl $2, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_101

.L_96:
	movl $2, %ebx
	movl -40(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_98
	movl %ecx, -40(%rbp)

.L_97:
	jmp .L_101

.L_98:
	movl $8, %ebx
	movl %ebx, -32(%rbp)
	addl $4, %ebx
	movl %ebx, -24(%rbp)
	jmp .L_102

.L_101:
	call .crash

.L_102:
	movq -368(%rbp), %rbx
	movl -24(%rbp), %ecx
	addq %rbx, %rcx
	movl (%rcx), %r8d
	movl -48(%rbp), %ecx
	movl %ecx, -48(%rbp)
	addl %r8d, %ecx
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
    
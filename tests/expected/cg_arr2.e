	.text
	.globl	entry


entry:
	pushq %rbp
	movq %rsp, %rbp
	subq $616, %rsp

.L_0:
	movl $4, %ebx
	movl %ebx, -584(%rbp)
	imull $4, %ebx
	movl %ebx, -576(%rbp)
	addl $8, %ebx
	pushq %rbx
	movl %ebx, -568(%rbp)
	call reserve
	addq $8, %rsp
	movq %rax, -560(%rbp)

.L_5:
	movq -560(%rbp), %rbx
	movl $2, 0(%rbx)
	movl $2, 4(%rbx)
	movl 0(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -552(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_21

.L_10:
	movl $0, %ebx
	movl -552(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_12
	movl %ecx, -552(%rbp)

.L_11:
	jmp .L_21

.L_12:
	movq -616(%rbp), %rbx
	movl 4(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -544(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_21

.L_14:
	movl $0, %ebx
	movl -544(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_16
	movl %ecx, -544(%rbp)

.L_15:
	jmp .L_21

.L_16:
	movl -544(%rbp), %ebx
	movl %ebx, -544(%rbp)
	imull $0, %ebx
	movl %ebx, -536(%rbp)
	addl $0, %ebx
	movl %ebx, -528(%rbp)
	imull $4, %ebx
	movl %ebx, -520(%rbp)
	addl $8, %ebx
	movl %ebx, -512(%rbp)
	jmp .L_22

.L_21:
	call .crash

.L_22:
	movq -616(%rbp), %rbx
	movl -512(%rbp), %ecx
	addq %rbx, %rcx
	movl $10, (%rcx)
	movl 0(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -504(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_36

.L_25:
	movl $0, %ebx
	movl -504(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_27
	movl %ecx, -504(%rbp)

.L_26:
	jmp .L_36

.L_27:
	movq -616(%rbp), %rbx
	movl 4(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -496(%rbp)
	movl $1, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_36

.L_29:
	movl $1, %ebx
	movl -496(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_31
	movl %ecx, -496(%rbp)

.L_30:
	jmp .L_36

.L_31:
	movl -496(%rbp), %ebx
	movl %ebx, -496(%rbp)
	imull $0, %ebx
	movl %ebx, -488(%rbp)
	addl $1, %ebx
	movl %ebx, -480(%rbp)
	imull $4, %ebx
	movl %ebx, -472(%rbp)
	addl $8, %ebx
	movl %ebx, -464(%rbp)
	jmp .L_37

.L_36:
	call .crash

.L_37:
	movq -616(%rbp), %rbx
	movl -464(%rbp), %ecx
	addq %rbx, %rcx
	movl $20, (%rcx)
	movl 0(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -456(%rbp)
	movl $1, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_51

.L_40:
	movl $1, %ebx
	movl -456(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_42
	movl %ecx, -456(%rbp)

.L_41:
	jmp .L_51

.L_42:
	movq -616(%rbp), %rbx
	movl 4(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -448(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_51

.L_44:
	movl $0, %ebx
	movl -448(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_46
	movl %ecx, -448(%rbp)

.L_45:
	jmp .L_51

.L_46:
	movl -448(%rbp), %ebx
	movl %ebx, -448(%rbp)
	imull $1, %ebx
	movl %ebx, -440(%rbp)
	addl $0, %ebx
	movl %ebx, -432(%rbp)
	imull $4, %ebx
	movl %ebx, -424(%rbp)
	addl $8, %ebx
	movl %ebx, -416(%rbp)
	jmp .L_52

.L_51:
	call .crash

.L_52:
	movq -616(%rbp), %rbx
	movl -416(%rbp), %ecx
	addq %rbx, %rcx
	movl $30, (%rcx)
	movl 0(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -408(%rbp)
	movl $1, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_66

.L_55:
	movl $1, %ebx
	movl -408(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_57
	movl %ecx, -408(%rbp)

.L_56:
	jmp .L_66

.L_57:
	movq -616(%rbp), %rbx
	movl 4(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -400(%rbp)
	movl $1, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_66

.L_59:
	movl $1, %ebx
	movl -400(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_61
	movl %ecx, -400(%rbp)

.L_60:
	jmp .L_66

.L_61:
	movl -400(%rbp), %ebx
	movl %ebx, -400(%rbp)
	imull $1, %ebx
	movl %ebx, -392(%rbp)
	addl $1, %ebx
	movl %ebx, -384(%rbp)
	imull $4, %ebx
	movl %ebx, -376(%rbp)
	addl $8, %ebx
	movl %ebx, -368(%rbp)
	jmp .L_67

.L_66:
	call .crash

.L_67:
	movq -616(%rbp), %rbx
	movl -368(%rbp), %ecx
	addq %rbx, %rcx
	movl $40, (%rcx)
	movl $1, %ecx
	movl $0, %r8d
	movl 0(%rbx), %r9d
	movq %rbx, -616(%rbp)
	movl %ecx, -608(%rbp)
	movl %r8d, -600(%rbp)
	movl %r9d, -360(%rbp)
	movl -608(%rbp), %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_83
	movl %ebx, -608(%rbp)

.L_72:
	movl -608(%rbp), %ebx
	movl -360(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_74
	movl %ebx, -608(%rbp)
	movl %ecx, -360(%rbp)

.L_73:
	jmp .L_83

.L_74:
	movq -616(%rbp), %rbx
	movl 4(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -352(%rbp)
	movl -600(%rbp), %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_83
	movl %ebx, -600(%rbp)

.L_76:
	movl -600(%rbp), %ebx
	movl -352(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_78
	movl %ebx, -600(%rbp)
	movl %ecx, -352(%rbp)

.L_77:
	jmp .L_83

.L_78:
	movl -608(%rbp), %ebx
	movl -352(%rbp), %ecx
	movl %ebx, -608(%rbp)
	imull %ecx, %ebx
	movl -600(%rbp), %r8d
	movl %ebx, -344(%rbp)
	addl %r8d, %ebx
	movl %ebx, -336(%rbp)
	imull $4, %ebx
	movl %ebx, -328(%rbp)
	addl $8, %ebx
	movl %ebx, -320(%rbp)
	movl %ecx, -352(%rbp)
	movl %r8d, -600(%rbp)
	jmp .L_84

.L_83:
	call .crash

.L_84:
	movq -616(%rbp), %rbx
	movl 0(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -312(%rbp)
	movl -608(%rbp), %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_97
	movl %ebx, -608(%rbp)

.L_86:
	movl -608(%rbp), %ebx
	movl -312(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_88
	movl %ebx, -608(%rbp)
	movl %ecx, -312(%rbp)

.L_87:
	jmp .L_97

.L_88:
	movq -616(%rbp), %rbx
	movl 4(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -304(%rbp)
	movl -600(%rbp), %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_97
	movl %ebx, -600(%rbp)

.L_90:
	movl -600(%rbp), %ebx
	movl -304(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_92
	movl %ebx, -600(%rbp)
	movl %ecx, -304(%rbp)

.L_91:
	jmp .L_97

.L_92:
	movl -608(%rbp), %ebx
	movl -304(%rbp), %ecx
	movl %ebx, -608(%rbp)
	imull %ecx, %ebx
	movl -600(%rbp), %r8d
	movl %ebx, -296(%rbp)
	addl %r8d, %ebx
	movl %ebx, -288(%rbp)
	imull $4, %ebx
	movl %ebx, -280(%rbp)
	addl $8, %ebx
	movl %ebx, -272(%rbp)
	movl %ecx, -304(%rbp)
	movl %r8d, -600(%rbp)
	jmp .L_98

.L_97:
	call .crash

.L_98:
	movq -616(%rbp), %rbx
	movl -272(%rbp), %ecx
	addq %rbx, %rcx
	movl (%rcx), %r8d
	movl %r8d, -264(%rbp)
	addl $5, %r8d
	movl -320(%rbp), %ecx
	addq %rbx, %rcx
	movl %r8d, (%rcx)
	movl 0(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -248(%rbp)
	movl %r8d, -256(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_114

.L_103:
	movl $0, %ebx
	movl -248(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_105
	movl %ecx, -248(%rbp)

.L_104:
	jmp .L_114

.L_105:
	movq -616(%rbp), %rbx
	movl 4(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -240(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_114

.L_107:
	movl $0, %ebx
	movl -240(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_109
	movl %ecx, -240(%rbp)

.L_108:
	jmp .L_114

.L_109:
	movl -240(%rbp), %ebx
	movl %ebx, -240(%rbp)
	imull $0, %ebx
	movl %ebx, -232(%rbp)
	addl $0, %ebx
	movl %ebx, -224(%rbp)
	imull $4, %ebx
	movl %ebx, -216(%rbp)
	addl $8, %ebx
	movl %ebx, -208(%rbp)
	jmp .L_115

.L_114:
	call .crash

.L_115:
	movq -616(%rbp), %rbx
	movl -208(%rbp), %ecx
	addq %rbx, %rcx
	movl (%rcx), %r8d
	movl 0(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -192(%rbp)
	movl %r8d, -200(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_129

.L_118:
	movl $0, %ebx
	movl -192(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_120
	movl %ecx, -192(%rbp)

.L_119:
	jmp .L_129

.L_120:
	movq -616(%rbp), %rbx
	movl 4(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -184(%rbp)
	movl $1, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_129

.L_122:
	movl $1, %ebx
	movl -184(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_124
	movl %ecx, -184(%rbp)

.L_123:
	jmp .L_129

.L_124:
	movl -184(%rbp), %ebx
	movl %ebx, -184(%rbp)
	imull $0, %ebx
	movl %ebx, -176(%rbp)
	addl $1, %ebx
	movl %ebx, -168(%rbp)
	imull $4, %ebx
	movl %ebx, -160(%rbp)
	addl $8, %ebx
	movl %ebx, -152(%rbp)
	jmp .L_130

.L_129:
	call .crash

.L_130:
	movq -616(%rbp), %rbx
	movl -152(%rbp), %ecx
	addq %rbx, %rcx
	movl (%rcx), %r8d
	movl -200(%rbp), %ecx
	movl %ecx, -200(%rbp)
	addl %r8d, %ecx
	movl 0(%rbx), %r9d
	movq %rbx, -616(%rbp)
	movl %ecx, -136(%rbp)
	movl %r8d, -144(%rbp)
	movl %r9d, -128(%rbp)
	movl $1, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_145

.L_134:
	movl $1, %ebx
	movl -128(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_136
	movl %ecx, -128(%rbp)

.L_135:
	jmp .L_145

.L_136:
	movq -616(%rbp), %rbx
	movl 4(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -120(%rbp)
	movl $0, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_145

.L_138:
	movl $0, %ebx
	movl -120(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_140
	movl %ecx, -120(%rbp)

.L_139:
	jmp .L_145

.L_140:
	movl -120(%rbp), %ebx
	movl %ebx, -120(%rbp)
	imull $1, %ebx
	movl %ebx, -112(%rbp)
	addl $0, %ebx
	movl %ebx, -104(%rbp)
	imull $4, %ebx
	movl %ebx, -96(%rbp)
	addl $8, %ebx
	movl %ebx, -88(%rbp)
	jmp .L_146

.L_145:
	call .crash

.L_146:
	movq -616(%rbp), %rbx
	movl -88(%rbp), %ecx
	addq %rbx, %rcx
	movl (%rcx), %r8d
	movl -136(%rbp), %ecx
	movl %ecx, -136(%rbp)
	addl %r8d, %ecx
	movl 0(%rbx), %r9d
	movq %rbx, -616(%rbp)
	movl %ecx, -72(%rbp)
	movl %r8d, -80(%rbp)
	movl %r9d, -64(%rbp)
	movl $1, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_161

.L_150:
	movl $1, %ebx
	movl -64(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_152
	movl %ecx, -64(%rbp)

.L_151:
	jmp .L_161

.L_152:
	movq -616(%rbp), %rbx
	movl 4(%rbx), %ecx
	movq %rbx, -616(%rbp)
	movl %ecx, -56(%rbp)
	movl $1, %ebx
	movl $0, %ecx
	cmpl %ecx, %ebx
	jl .L_161

.L_154:
	movl $1, %ebx
	movl -56(%rbp), %ecx
	cmpl %ecx, %ebx
	jl .L_156
	movl %ecx, -56(%rbp)

.L_155:
	jmp .L_161

.L_156:
	movl -56(%rbp), %ebx
	movl %ebx, -56(%rbp)
	imull $1, %ebx
	movl %ebx, -48(%rbp)
	addl $1, %ebx
	movl %ebx, -40(%rbp)
	imull $4, %ebx
	movl %ebx, -32(%rbp)
	addl $8, %ebx
	movl %ebx, -24(%rbp)
	jmp .L_162

.L_161:
	call .crash

.L_162:
	movq -616(%rbp), %rbx
	movl -24(%rbp), %ecx
	addq %rbx, %rcx
	movl (%rcx), %r8d
	movl -72(%rbp), %ecx
	movl %ecx, -72(%rbp)
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
    
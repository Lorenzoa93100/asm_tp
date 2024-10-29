global _start

_start:
section .text
	mov rax, 60
	mov rdi, 0
	syscall

global _start

_start:
section .text

	mov rax, 1
	mov rdi, 1
	mov rsi, "1337"
	mov rdx, 10
	syscall

	mov rax, 10
	mov rdi, 0
	syscall

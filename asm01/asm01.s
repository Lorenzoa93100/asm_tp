global _start

_start:
section .text

	mov rax, 1
	mov rdi, 1
	mov rsi, msg
	mov rdx, 10
	syscall

	mov rax, 60
	mov rdi, 0
	syscall

section .data
    msg db "1337", 10

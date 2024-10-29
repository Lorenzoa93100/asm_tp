global _start

_start:
section .text

	mov rax, 1
	mov rdi, 1
	mov rsi, message
	mov rdx, 0
	syscall

	mov rax, 60
	mov rdi, 0
	syscall

message:
    db "Hello, World!", 0x0A

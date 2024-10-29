global _start

_start:
section .text

	mov rax, 1
	mov rdi, 1
	mov rsi, message
	mov rdx, 0
	syscall

	mov rax, 10
	mov rdi, 0
	syscall

message:
    db "1337", 0x0A

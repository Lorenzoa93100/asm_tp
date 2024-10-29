global _start

_start:
section .text

	move rax, 1
	move rdi, 1
	move rsi, message
	move rdx, 0
	syscall

	move rax, 60
	move rdi, 0
	syscall

message:
    db "Hello, World!", 0x0A

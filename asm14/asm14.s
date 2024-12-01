global _start

section .data
    message db "Hello Universe !"
    message_len equ $ - message
section .bss
    fd resq 1

section .text
_start:

mov rsi, [rsp + 16]
cmp rsi, 0
je error

xor rax, rax
xor rcx, rcx

mov rax, 2
mov rdi, rsi
mov rsi, 0101o
mov rdx, 0777o
syscall

mov [fd], rax

mov rax, 1
mov rdi, [fd]
mov rsi, message
mov rdx, message_len
syscall

mov rax, 3
mov rdi, [fd]
syscall

mov rax, 60
xor rdi, rdi
syscall

error:
mov rax, 60
mov rdi, 1
syscall 

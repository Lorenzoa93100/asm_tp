global _start

section .text

_start:
    pop rax
    cmp al, 2
    jne _exit_error

    pop rax
    pop rax
    mov rsi, rax
    xor rax, rax
strlen:
    cmp byte [rsi+rcx], 0
    je print_result 
    inc rcx
    jmp strlen

print_result: 
    lea rbx, [rsi+rcx]
    mov byte [rbx], 0x0A
    inc rcx

    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall

    jmp _exit

_exit:
    mov rax, 60
    mov rdi, 0
    syscall

_exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

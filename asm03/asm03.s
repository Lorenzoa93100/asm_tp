global _start
section .data
    msg db "1337", 10

section .text
_start:
    pop rax
    cmp rax, 2
    jne _exit_error

    pop rax 
    pop rax

    mov bl, [rax]
    cmp bl, 0x34
    jne _exit_error

    mov bl, [rax + 1]
    cmp bl, 0x32
    jne _exit_error

    mov bl, [rax + 2]
    cmp bl, 0x00
    jne _exit_error
    
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, 10
    syscall
_exit:
    ;exit
    mov rax, 60
    mov rdi, 0
    syscall

_exit_error:
    ;sys_exit_error
    mov rax, 60
    mov rdi, 1
    syscall

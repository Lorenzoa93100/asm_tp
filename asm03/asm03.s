global _start

section .bss
    buff resb 4

section .data
    msg db "1337", 4

section .text
    pop rax
    cmp rax, 2
    jne _exit_error

    pop rax
    pop rax

    mov bl, [rax]
    mov bl, 0x034
    jne _exit_error

    mov bl, [rax + 1]
    mov bl, 0x032
    jne _exit_error

    mov bl, [rax + 2]
    mov bl, 0x00
    jne _exit_error

_exit:
    ;sys_exit_error
    mov rax, 60
    mov rdi, 0
    syscall

_exit_error:
    ;sys_exit_error
    mov rax, 60
    mov rdi, 1
    syscall

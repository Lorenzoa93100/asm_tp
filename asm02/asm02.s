global _start

section .bss
    buff resb 4

section .data
    msg db "1337", 4

section .text
_start:
    ;read
    mov rax, 0     ; on appel le sys_call read
    mov rdi, 0     ; file descriptor de stdin
    mov rsi, buff
    mov rdx, 5
    syscall
    ;compare
    mov al, [buff]
    cmp al, 0x34
    jne _exit_error
    mov al, [buff + 1]
    cmp al, 0x32
    jne _exit_error
    mov al, [buff + 2]
    cmp al, 0x0A
    jne _exit_error

    ;sys_write
    mov rax, 1
    mov rdi, 1
    mov rsi, msg
    mov rdx, 5
    syscall

_exit:
    ;sys_exit
    mov rax, 60
    mov rdi, 0
    syscall

_exit_error:
    ;sys_exit_error
    mov rax, 60
    mov rdi, 1
    syscall

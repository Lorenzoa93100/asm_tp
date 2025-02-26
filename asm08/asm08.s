global _start

section .bss
    sum resq 1
    buffer resb 20

section .text

_start:
    pop rax
    cmp al, 2
    jne _exit_error

    pop rax
    pop rsi
    call atoi

    cmp rax, 0
    je _exit  ; Si le paramètre est 0, sautez à la fin sans erreur

    jle _exit_error

    mov rcx, rax
    dec rcx
    xor rbx, rbx

sum_loop:
    cmp rcx, 0
    jle sum_done
    add rbx, rcx
    dec rcx
    jmp sum_loop

sum_done:
    mov rax, rbx
    call print_number

    xor rdi, rdi
    jmp _exit

_exit:
    mov rax, 60
    syscall

_exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

atoi:
    xor rax, rax
    xor rcx, rcx
atoi_loop:
    movzx rcx, byte [rsi]
    test rcx, rcx
    je atoi_done
    sub rcx, '0'
    imul rax, rax, 10
    add rax, rcx
    inc rsi
    jmp atoi_loop
atoi_done:
    ret

print_number:
    xor rcx, rcx
    lea rsi, [buffer + 20]

print_loop:
    xor rdx, rdx
    mov rbx, 10
    div rbx
    add dl, '0'
    dec rsi
    mov [rsi], dl
    inc rcx
    test rax, rax
    jnz print_loop

    mov rax, 1
    mov rdi, 1
    mov rdx, rcx
    syscall
    ret

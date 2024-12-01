global _start

section .bss
    fd resb 1
    buffer resb 16

section .text
_start:

    mov rsi, [rsp + 16]
    test rsi, rsi
    je error

    mov rax, 2 
    mov rdi, rsi  
    mov rsi, 0
    syscall

    mov [fd], rax

    mov rax, 0
    mov rdi, [fd]
    mov rsi, buffer
    mov rdx, 16
    syscall

    mov rax, 3
    mov rdi, [fd]
    syscall

    mov rsi, buffer
    mov eax, dword [rsi]

    cmp eax, 0x464C457F             ; ELF (\x7F 'E' 'L' 'F')
    jne error

    movzx eax, byte [rsi + 4]
    cmp al, 2                       ; 2 = ELFCLASS64
    jne error

    mov rax, 60
    xor rdi, rdi
    syscall

error:
    mov rax, 60
    mov rdi, 1
    syscall

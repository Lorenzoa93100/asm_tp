global _start

section .bss
    buff resb 64     

section .text
_start:
    ; Lire l'entrée depuis stdin
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buff       ; Stocker l'entrée dans buff
    mov rdx, 64         ; Lire jusqu'à 64 caractères
    syscall

    mov rcx, 0          ; Compteur pour parcourir buff
_loop:
    mov al, [buff + rcx]    ; Charger le caractère actuel
    cmp al, 0x0A            ; Vérifier si c'est le caractère de nouvelle ligne '\n'
    je _pair_or_not         ; Si '\n', on a trouvé la fin
    inc rcx                 ; Passer au caractère suivant
    cmp rcx, 63             ; Éviter de dépasser la limite de buff
    jne _loop               ; Continuer jusqu'à la fin de l'entrée

_pair_or_not:
    mov al, [buff + rcx - 1]; `al` contient maintenant le dernier chiffre avant le '\n'
    sub al, '0'             ; Convertir le caractère ASCII en valeur numérique
    test al, 1              ; Vérifier si impair avec AND 1
    jnz _exit_error         ; Si impair, retourner 1
    jmp _exit               ; Sauter vers _exit si pair

_exit:
    ; Retourner 0 si pair
    mov rax, 60
    xor rdi, rdi
    syscall
    
_exit_error:
    ; Retourner 1 si impair
    mov rax, 60
    mov rdi, 1
    syscall


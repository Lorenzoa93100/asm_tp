global _start

section .bss
    buff resb 64      ; Réserver 64 octets pour la lecture de l'entrée

section .text
_start:
    ; Lire l'entrée depuis stdin
    mov rax, 0          ; sys_read
    mov rdi, 0          ; stdin
    mov rsi, buff       ; Stocker l'entrée dans buff
    mov rdx, 64         ; Lire jusqu'à 64 caractères
    syscall

    mov rcx, 0          ; Compteur pour parcourir buff

; Boucle pour vérifier chaque caractère
_check_digits:
    mov al, [buff + rcx]    ; Charger le caractère actuel
    cmp al, 0x0A            ; Vérifier si c'est le caractère de nouvelle ligne '\n'
    je _pair_or_not         ; Si '\n', on a terminé de vérifier

    ; Vérifier si le caractère est entre '0' et '9'
    cmp al, '0'
    jb _error_invalid_input   ; Sauter vers erreur si inférieur à '0'
    cmp al, '9'
    ja _error_invalid_input   ; Sauter vers erreur si supérieur à '9'

    ; Passer au caractère suivant
    inc rcx
    cmp rcx, 63               ; Éviter de dépasser la limite de buff
    jne _check_digits         ; Continuer à vérifier chaque caractère

_pair_or_not:
    ; Charger le dernier chiffre (juste avant '\n')
    mov al, [buff + rcx - 1]
    sub al, '0'             ; Convertir le caractère ASCII en valeur numérique
    test al, 1              ; Vérifier si impair avec AND 1
    jnz _exit_error         ; Si impair, retourner 1
    jmp _exit               ; Sauter vers _exit si pair

_exit:
    mov rax, 60
    xor rdi, rdi
    syscall
    
_exit_error:
    mov rax, 60
    mov rdi, 1
    syscall

_error_invalid_input:
    mov rax, 60
    mov rdi, 2
    syscall

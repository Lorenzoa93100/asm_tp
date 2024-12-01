global _start

section .data
    hex_chars db "0123456789ABCDEF", 0   ; Table des caractères hexadécimaux
    buffer db 16 dup(0)                  ; Tampon pour stocker le résultat

section .bss
    num resq 1                           ; Espace pour stocker le nombre

section .text

_start:
    ; Vérification du nombre d'arguments (argc == 2)
    pop rax                              ; argc
    cmp al, 2
    jne _exit_error

    ; Lecture de l'argument (argv[1])
    pop rax                              ; argv
    pop rsi                              ; argv[1] (chaîne)
    call atoi                            ; Convertir la chaîne en entier (dans rax)

    ; Conversion en hexadécimal
    mov rcx, 0                           ; Compteur pour buffer
convert_loop:
    xor rdx, rdx                         ; RDX = 0 (remainder)
    mov rbx, 16                          ; Base hexadécimale
    div rbx                              ; RAX /= 16, reste dans RDX
    mov bl, byte [hex_chars + rdx]       ; Charger le caractère correspondant
    mov byte [buffer + rcx], bl          ; Stocker dans le tampon
    inc rcx                              ; Incrémenter l'index
    cmp rcx, 16                          ; Vérifier si le tampon est plein
    je _exit_error                       ; Si oui, erreur (valeur trop grande)
    test rax, rax                        ; Si RAX == 0, fin de conversion
    jnz convert_loop

    ; Afficher le résultat (inversé)
    lea rsi, [buffer + rcx]              ; Pointeur à la fin du résultat
print_loop:
    dec rsi                              ; Reculer d'un caractère
    mov al, byte [rsi]                   ; Charger le caractère
    mov edi, 1                           ; FD stdout
    mov rax, 1                           ; write syscall
    mov rdx, 1                           ; Longueur 1
    syscall
    cmp rsi, buffer                      ; Fin d'affichage ?
    ja print_loop                        ; Continuer tant que rsi > buffer

    ; Sortie propre
    jmp _exit

_exit:
    mov rax, 60                          ; syscall: exit
    xor rdi, rdi                         ; Code de retour 0
    syscall

_exit_error:
    mov rax, 60                          ; syscall: exit
    mov rdi, 1                           ; Code de retour 1 (erreur)
    syscall

; Fonction atoi : Convertit une chaîne en entier
atoi:
    xor rax, rax                         ; Initialiser le résultat à 0
    xor rcx, rcx                         ; Effacer RCX
atoi_loop:
    movzx rcx, byte [rsi]                ; Charger un caractère
    test rcx, rcx                        ; Fin de chaîne ?
    je atoi_done
    sub rcx, '0'                         ; Convertir en chiffre (0-9)
    imul rax, rax, 10                    ; Multiplier le résultat par 10
    add rax, rcx                         ; Ajouter le chiffre au résultat
    inc rsi                              ; Passer au caractère suivant
    jmp atoi_loop
atoi_done:
    ret

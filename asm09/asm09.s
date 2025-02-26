global _start

section .data
    hex_chars db "0123456789ABCDEF", 0   ; Table des caractères hexadécimaux
    newline db 0x0A                      ; Caractère nouvelle ligne

section .bss
    buffer resb 64                       ; Tampon pour stocker le résultat (plus grand pour binaire)
    num resq 1                           ; Espace pour stocker le nombre

section .text

_start:
    ; Vérification du nombre d'arguments (argc == 2 ou argc == 3)
    pop rax                              ; argc
    cmp al, 2
    je decimal_to_hex                    ; Si 2 arguments, conversion décimal vers hexadécimal
    cmp al, 3                            ; Si 3 arguments, vérifier si c'est -b
    jne _exit_error

    ; Vérifier l'option -b
    pop rax                              ; Ignorer argv[0]
    pop rdi                              ; argv[1] (option)
    cmp byte [rdi], '-'
    jne _exit_error
    cmp byte [rdi+1], 'b'
    jne _exit_error
    cmp byte [rdi+2], 0
    jne _exit_error

    ; Lire le nombre depuis argv[2]
    pop rsi                              ; argv[2] (chaîne)
    call atoi                            ; Convertir la chaîne en entier (dans rax)
    
    ; Conversion en binaire
    mov rbx, 2                           ; Base binaire
    jmp convert

decimal_to_hex:
    ; Lecture de l'argument (argv[1])
    pop rax                              ; Ignorer argv[0]
    pop rsi                              ; argv[1] (chaîne)
    call atoi                            ; Convertir la chaîne en entier (dans rax)
    
    ; Conversion en hexadécimal
    mov rbx, 16                          ; Base hexadécimale

convert:
    mov rcx, 0                           ; Compteur pour buffer
convert_loop:
    xor rdx, rdx                         ; RDX = 0 (remainder)
    div rbx                              ; RAX /= base, reste dans RDX
    mov r8b, byte [hex_chars + rdx]      ; Charger le caractère correspondant
    mov byte [buffer + rcx], r8b         ; Stocker dans le tampon
    inc rcx                              ; Incrémenter l'index
    cmp rcx, 64                          ; Vérifier si le tampon est plein
    je _exit_error                       ; Si oui, erreur (valeur trop grande)
    test rax, rax                        ; Si RAX == 0, fin de conversion
    jnz convert_loop

    ; Afficher le résultat (inversé)
    lea rsi, [buffer + rcx - 1]          ; Pointeur à la fin du résultat
    mov r9, rcx                          ; Sauvegarder le compteur
print_loop:
    mov al, byte [rsi]                   ; Charger le caractère
    mov rdi, 1                           ; FD stdout
    mov rax, 1                           ; write syscall
    mov rdx, 1                           ; Longueur 1
    syscall
    dec rsi                              ; Reculer d'un caractère
    dec r9                               ; Décrémenter le compteur
    jnz print_loop                       ; Continuer tant que r9 > 0

    ; Ajouter un saut de ligne
    mov rax, 1                           ; write syscall
    mov rdi, 1                           ; FD stdout
    mov rsi, newline                     ; Nouvelle ligne
    mov rdx, 1                           ; Longueur 1
    syscall

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
atoi_loop:
    movzx rcx, byte [rsi]                ; Charger un caractère
    test rcx, rcx                        ; Fin de chaîne ?
    je atoi_done
    sub rcx, '0'                         ; Convertir en chiffre (0-9)
    cmp rcx, 9                           ; Vérifier si c'est un chiffre valide
    ja _exit_error                       ; Si non, sortir avec erreur
    imul rax, rax, 10                    ; Multiplier le résultat par 10
    add rax, rcx                         ; Ajouter le chiffre au résultat
    inc rsi                              ; Passer au caractère suivant
    jmp atoi_loop
atoi_done:
    ret
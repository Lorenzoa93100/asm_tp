global _start

section .bss
    result resb 20  ; Buffer pour stocker le résultat converti (20 caractères max)

section .text
_start:
    pop rax            ; Récupère argc
    cmp rax, 3         ; Vérifie si 2 arguments (programme + 2 nombres)
    jne exit_error     ; Sinon, erreur
    
    pop rdi            ; Ignore argv[0] (nom du programme)
    pop rdi            ; Récupère argv[1] (premier nombre)
    call atoi          ; Convertit en entier
    mov rbx, rax       ; Stocke le premier nombre
    
    pop rdi            ; Récupère argv[2] (deuxième nombre)
    call atoi          ; Convertit en entier
    add rax, rbx       ; Additionne les deux nombres
    
    mov rdi, result    ; Pointeur vers le buffer résultat
    call itoa          ; Convertit en chaîne ASCII
    
    mov rax, 1         ; syscall write
    mov rdi, 1         ; stdout
    mov rsi, result    ; Buffer contenant le résultat
    mov rdx, r8        ; Taille de la chaîne (stockée dans r8 par itoa)
    syscall
    
    jmp _exit          ; Quitter proprement

; Convertir une chaîne en entier (atoi)
atoi:
    xor rax, rax       ; Réinitialise rax (résultat)
    xor rcx, rcx       ; Initialise compteur
atoi_loop:
    movzx rdx, byte [rdi + rcx]  ; Charge un caractère
    test rdx, rdx       ; Vérifie si fin de chaîne (NULL)
    je atoi_end         ; Si oui, on sort
    sub rdx, '0'        ; Convertit ASCII → chiffre
    cmp rdx, 9
    ja atoi_end         ; Si non valide, stoppe
    imul rax, rax, 10   ; rax *= 10 (décalage à gauche)
    add rax, rdx        ; Ajoute le chiffre converti
    inc rcx             ; Avance au prochain caractère
    jmp atoi_loop       ; Continue
atoi_end:
    ret

; Convertir un entier en chaîne ASCII (itoa)
itoa:
    mov r9, rdi        ; Sauvegarde l'adresse du buffer
    mov rcx, 0         ; Compteur de chiffres
    mov rbx, 10        ; Base 10 pour division
itoa_loop:
    xor rdx, rdx       ; Vide rdx pour div propre
    div rbx            ; rax = quotient, rdx = reste
    add dl, '0'        ; Convertit chiffre en ASCII
    push rdx           ; Stocke temporairement
    inc rcx            ; Augmente la taille
    test rax, rax      ; Vérifie si on a fini
    jnz itoa_loop      ; Continue tant que rax > 0
    
    mov r8, rcx        ; Sauvegarde le nombre de chiffres
    
itoa_pop_loop:
    pop rax            ; Récupère un chiffre
    mov [rdi], al      ; Stocke dans le buffer
    inc rdi            ; Avance le pointeur
    dec rcx            ; Décrément manuel du compteur
    jnz itoa_pop_loop  ; Répète jusqu'à vider la pile
    
    mov byte [rdi], 0x0A  ; Ajoute '\n'
    inc r8            ; Compter '\n' dans la longueur totale
    ret

; Quitter proprement
_exit:
    mov rax, 60        ; syscall exit
    xor rdi, rdi       ; Code 0 (succès)
    syscall

; Quitter en cas d'erreur
exit_error:
    mov rax, 60        ; syscall exit
    mov rdi, 1         ; Code 1 (erreur)
    syscall
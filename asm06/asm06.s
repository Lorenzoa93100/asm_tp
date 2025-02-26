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

; Convertir une chaîne en entier (atoi) avec support des négatifs
atoi:
    xor rax, rax       ; Réinitialise rax (résultat)
    xor rcx, rcx       ; Initialise compteur
    mov r9, 0          ; Flag pour nombre négatif (0 = positif)
    
    ; Vérifier si commence par un signe '-'
    movzx rdx, byte [rdi]
    cmp rdx, '-'
    jne atoi_loop      ; Si pas de signe, commencer la conversion
    mov r9, 1          ; Activer le flag négatif
    inc rdi            ; Avancer au premier chiffre après le signe
    
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
    test r9, r9         ; Vérifier si nombre négatif
    jz atoi_positive    ; Si positif, ne rien faire
    neg rax             ; Sinon, négation du résultat
atoi_positive:
    ret

; Convertir un entier en chaîne ASCII (itoa) avec support des négatifs
itoa:
    mov r9, rdi        ; Sauvegarde l'adresse du buffer
    mov r10, 0         ; Flag pour nombre négatif (0 = positif)
    
    ; Vérifier si le nombre est négatif
    test rax, rax
    jns itoa_positive  ; Si non négatif (sign flag=0), continuer
    mov r10, 1         ; Activer le flag négatif
    neg rax            ; Rendre le nombre positif pour la conversion
    
itoa_positive:
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
    
    ; Si nombre négatif, ajouter le signe '-'
    test r10, r10      ; Vérifier le flag négatif
    jz itoa_pop_loop   ; Si positif, passer directement à l'affichage
    mov byte [rdi], '-'; Sinon, ajouter un signe moins
    inc rdi            ; Avancer le pointeur
    inc r8             ; Augmenter la taille du résultat
    
itoa_pop_loop:
    pop rax            ; Récupère un chiffre
    mov [rdi], al      ; Stocke dans le buffer
    inc rdi            ; Avance le pointeur
    dec rcx            ; Décrément manuel du compteur
    jnz itoa_pop_loop  ; Répète jusqu'à vider la pile
    
    mov byte [rdi], 0x0A  ; Ajoute '\n'
    inc r8             ; Compter '\n' dans la longueur totale
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
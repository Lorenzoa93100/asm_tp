global _start

section .bss
    input_buffer resb 16    ; Buffer pour lire l'entrée

section .text
_start:
    ; Lire l'entrée standard
    mov rax, 0              ; syscall read
    mov rdi, 0              ; fd: stdin
    mov rsi, input_buffer   ; buffer
    mov rdx, 16             ; taille max
    syscall

    ; Convertir l'entrée en nombre
    mov rdi, input_buffer
    call atoi               ; Le nombre est maintenant dans rax
    
    ; Vérifier si le nombre est premier
    call is_prime
    
    ; Sortir avec le code retourné
    mov rax, 60             ; syscall exit
    ; rdi contient déjà 0 si premier, 1 si non premier
    syscall

; Convertir une chaîne ASCII en entier
atoi:
    xor rax, rax            ; Initialiser le résultat à 0
    xor rcx, rcx            ; Compteur de caractères
    
atoi_loop:
    movzx rdx, byte [rdi + rcx]  ; Lire un caractère
    
    ; Vérifier si fin de chaîne ou nouvelle ligne
    cmp rdx, 0
    je atoi_end
    cmp rdx, 10             ; '\n'
    je atoi_end
    
    ; Convertir ASCII en chiffre
    sub rdx, '0'
    
    ; Vérifier si c'est un chiffre valide (0-9)
    cmp rdx, 9
    ja error_invalid_char   ; Si le caractère est supérieur à '9', c'est invalide
    
    ; Multiplier le résultat par 10 et ajouter le nouveau chiffre
    imul rax, 10
    add rax, rdx
    
    inc rcx
    jmp atoi_loop
    
error_invalid_char:
    mov rdi, 2              ; Code d'erreur 2
    mov rax, 60             ; syscall exit
    syscall

atoi_end:
    ret

; Vérifier si un nombre est premier
; Entrée: rax = nombre à vérifier
; Sortie: rdi = 0 si premier, 1 si non premier
is_prime:
    ; Cas spéciaux pour 0 et 1
    cmp rax, 2
    jb not_prime            ; 0 et 1 ne sont pas premiers
    
    ; 2 est premier
    cmp rax, 2
    je prime
    
    ; Vérifier si le nombre est pair (sauf 2)
    test rax, 1
    jz not_prime            ; Si pair et > 2, alors non premier
    
    ; Initialiser le diviseur à 3
    mov rbx, 3
    
check_loop:
    ; Vérifier si diviseur² > nombre
    mov rcx, rbx
    imul rcx, rcx
    cmp rcx, rax
    ja prime                ; Si diviseur² > nombre, alors nombre est premier
    
    ; Vérifier si le diviseur divise le nombre
    mov rcx, rax
    xor rdx, rdx
    div rbx                 ; rdx = reste de rax/rbx
    
    ; Si rdx = 0, alors le nombre n'est pas premier
    test rdx, rdx
    jz not_prime
    
    ; Incrémenter le diviseur de 2 (vérifier seulement les impairs)
    add rbx, 2
    jmp check_loop
    
prime:
    xor rdi, rdi            ; Retourner 0 (nombre premier)
    ret
    
not_prime:
    mov rdi, 1              ; Retourner 1 (nombre non premier)
    ret

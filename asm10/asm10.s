section .bss
    buffer resb 20  ; Buffer pour conversion d'entier

section .data
    newline db 10   ; Caractère de nouvelle ligne
    error_msg db "insufficient params", 10
    error_len equ $ - error_msg

section .text
    global _start

_start:
    mov rdi, [rsp]    ; Charger argc
    cmp rdi, 4        ; Vérifier si on a au moins 3 arguments (plus le nom du programme)
    jl error          ; Moins de 3 arguments -> erreur

    ; Charger argv[1] (premier argument)
    mov rsi, [rsp + 16]  ; argv[1]
    call atoi
    mov rbx, rax        ; Stocker le premier nombre comme max initial

    ; Charger argv[2] (deuxième argument)
    mov rsi, [rsp + 24] ; argv[2]
    call atoi
    cmp rax, rbx        ; Comparer avec le maximum actuel
    jle check_third     ; Si inférieur ou égal, passer au troisième
    mov rbx, rax        ; Sinon, mettre à jour le maximum

check_third:
    ; Charger argv[3] (troisième argument)
    mov rsi, [rsp + 32] ; argv[3]
    call atoi           ; Convertir en entier
    cmp rax, rbx        ; Comparer avec le maximum actuel
    jle display         ; Si inférieur ou égal, garder l'ancien
    mov rbx, rax        ; Sinon, mettre à jour le maximum

display:
    ; Convertir en chaîne
    mov rax, rbx
    call itoa

    ; Écrire le résultat
    mov rax, 1       ; syscall write
    mov rdi, 1       ; stdout
    mov rsi, rdx     ; Adresse du buffer (retour itoa)
    mov rdx, rcx     ; Taille retournée par itoa
    syscall

    ; Écrire nouvelle ligne
    mov rax, 1
    mov rdi, 1
    mov rsi, newline
    mov rdx, 1
    syscall

    ; Exit(0) - succès
    mov rax, 60
    xor rdi, rdi
    syscall

error:
    ; Afficher message d'erreur
    mov rax, 1
    mov rdi, 2       ; stderr
    mov rsi, error_msg
    mov rdx, error_len
    syscall

    ; Exit(1) - erreur, code modifié de -1 à 1
    mov rax, 60
    mov rdi, 1       ; Code de sortie 1 au lieu de -1
    syscall

; ------------------------------------------------
; atoi - Convertir une chaîne en entier (avec support des négatifs)
; Entrée : rsi (adresse de la chaîne)
; Sortie : rax (valeur entière)
; ------------------------------------------------
atoi:
    xor rax, rax     ; Initialiser le résultat à 0
    xor rcx, rcx     ; Initialiser l'index à 0
    xor r8, r8       ; Flag pour nombre négatif (0 = positif)
    
    ; Vérifier si premier caractère est '-'
    movzx rdx, byte [rsi]
    cmp rdx, '-'
    jne atoi_loop    ; Pas un '-', commencer la conversion
    
    ; C'est un nombre négatif
    mov r8, 1        ; Activer le flag négatif
    inc rcx          ; Sauter le signe '-'

atoi_loop:
    movzx rdx, byte [rsi + rcx]  ; Charger le caractère
    test rdx, rdx                 ; Fin de chaîne ?
    jz atoi_end

    cmp rdx, '0'                  ; Vérifier si c'est un chiffre
    jl atoi_end
    cmp rdx, '9'
    jg atoi_end

    sub rdx, '0'                  ; Convertir en valeur numérique
    imul rax, 10                  ; Multiplier résultat par 10
    add rax, rdx                  ; Ajouter nouveau chiffre

    inc rcx                       ; Passer au caractère suivant
    jmp atoi_loop

atoi_end:
    ; Si flag négatif est actif, négation du résultat
    test r8, r8
    jz atoi_positive
    neg rax                       ; Transformer en négatif

atoi_positive:
    ret

; ------------------------------------------------
; itoa - Convertir un entier en chaîne (avec support des négatifs)
; Entrée : rax (entier)
; Sortie : rdx (adresse de la chaîne), rcx (longueur)
; ------------------------------------------------
itoa:
    mov rcx, buffer + 19  ; Fin du buffer
    mov byte [rcx], 0     ; Terminateur de chaîne
    dec rcx

    ; Vérifier si le nombre est négatif
    mov r8, 0             ; Flag pour négatif (0 = positif)
    test rax, rax
    jns itoa_positive     ; Si non négatif, continuer
    
    ; Nombre négatif
    mov r8, 1             ; Activer flag négatif
    neg rax               ; Rendre positif pour la conversion

itoa_positive:
    mov rbx, 10           ; Base 10

itoa_loop:
    xor rdx, rdx          ; Mettre rdx à 0 avant division
    div rbx               ; rax = rax / 10, rdx = reste
    add dl, '0'           ; Convertir en caractère ASCII
    mov [rcx], dl         ; Stocker dans le buffer
    dec rcx               ; Reculer dans le buffer
    
    test rax, rax         ; Vérifier si on a fini
    jnz itoa_loop         ; Si non zéro, continuer
    
    ; Si le nombre était négatif, ajouter le signe '-'
    test r8, r8
    jz itoa_done
    
    mov byte [rcx], '-'   ; Ajouter le signe '-'
    dec rcx               ; Reculer dans le buffer

itoa_done:
    inc rcx               ; Pointer sur le premier caractère
    mov rdx, rcx          ; Retourner l'adresse de la chaîne
    mov rcx, buffer + 19  ; Calcul de la longueur
    sub rcx, rdx          ; Longueur = fin - début

    ret
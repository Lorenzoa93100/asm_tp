section .bss
    buffer resb 20  ; Buffer pour conversion d'entier

section .data
    newline db 10  ; Caractère de nouvelle ligne

section .text
    global _start

_start:
    mov rdi, [rsp]    
    cmp rdi, 4         ; argc >= 4 (programme + 3 arguments)
    jl error           ; Moins de 3 arguments -> erreur

    ; Charger argv[1]
    mov rsi, [rsp + 16]  ; argv[1]
    call atoi
    mov rbx, rax        ; Stocker le premier nombre

    ; Charger argv[2]
    mov rsi, [rsp + 24] ; argv[2]
    call atoi
    cmp rax, rbx
    jle check_third
    mov rbx, rax

check_third:
    ; Charger argv[3] correctement en utilisant l'adresse exacte dans rsp
    mov rsi, [rsp + 32] ; argv[3] ; Récupérer le troisième argument (argv[3])
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

    ; Exit(0)
    mov rax, 60
    xor rdi, rdi
    syscall

error:
    mov rax, 60
    mov rdi, 1
    syscall

; ------------------------------------------------
; atoi - Convertir une chaîne en entier
; Entrée : rsi (adresse de la chaîne)
; Sortie : rax (valeur entière)
; ------------------------------------------------
atoi:
    xor rax, rax   ; Stocker le résultat
    xor rcx, rcx

atoi_loop:
    movzx rdx, byte [rsi + rcx]  ; Charger le caractère
    test rdx, rdx                 ; Fin de chaîne ?
    jz atoi_end

    cmp rdx, '0'
    jl atoi_end
    cmp rdx, '9'
    jg atoi_end

    sub rdx, '0'
    imul rax, rax, 10
    add rax, rdx

    inc rcx
    jmp atoi_loop

atoi_end:
    ret

; ------------------------------------------------
; itoa - Convertir un entier en chaîne
; Entrée : rax (entier)
; Sortie : rdx (adresse de la chaîne), rcx (longueur)
; ------------------------------------------------
itoa:
    mov rcx, buffer + 19  ; Fin du buffer
    mov byte [rcx], 0     ; Terminateur de chaîne
    dec rcx

    mov rbx, 10           ; Base 10
    xor rdx, rdx          ; **Corrigé : Assurer que rdx = 0 avant division**

itoa_loop:
    div rbx               ; rax = rax / 10, rdx = reste
    add dl, '0'
    mov [rcx], dl
    dec rcx
    xor rdx, rdx          ; **Corrigé : Remettre rdx à 0 pour éviter erreur de div**
    test rax, rax
    jnz itoa_loop

    inc rcx               ; Pointer sur le premier chiffre
    mov rdx, rcx          ; Retourner l'adresse de la chaîne
    mov rcx, buffer + 19  ; Calcul de la longueur
    sub rcx, rdx

    ret
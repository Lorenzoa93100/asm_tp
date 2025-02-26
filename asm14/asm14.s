global _start

section .data
    message db "Hello Universe!"    ; Correction: pas d'espace avant le !
    message_len equ $ - message

section .bss
    fd resq 1

section .text
_start:
    ; Vérifier si un argument a été fourni
    cmp qword [rsp], 2    ; rsp contient argc
    jl error              ; si argc < 2, erreur
    
    ; Récupérer le premier argument (nom du fichier)
    mov rdi, [rsp + 16]   ; argv[1]
    
    ; Ouvrir (créer) le fichier
    mov rax, 2            ; syscall open
    mov rsi, 0102o        ; O_CREAT | O_WRONLY
    mov rdx, 0666o        ; Permissions
    syscall
    
    ; Vérifier si l'ouverture a réussi
    cmp rax, 0
    jl error              ; Si erreur (rax < 0)
    
    ; Sauvegarder le descripteur de fichier
    mov [fd], rax
    
    ; Écrire dans le fichier
    mov rax, 1            ; syscall write
    mov rdi, [fd]         ; fd
    mov rsi, message      ; buffer
    mov rdx, message_len  ; longueur
    syscall
    
    ; Fermer le fichier
    mov rax, 3            ; syscall close
    mov rdi, [fd]         ; fd
    syscall
    
    ; Quitter avec succès
    mov rax, 60           ; syscall exit
    xor rdi, rdi          ; code 0 (succès)
    syscall

error:
    mov rax, 60           ; syscall exit
    mov rdi, 1            ; code 1 (erreur)
    syscall

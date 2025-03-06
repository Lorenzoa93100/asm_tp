section .text
    global _start

section .data
    newline db 10      ; Caractère de nouvelle ligne
    buffer times 20 db 0  ; Buffer pour convertir le nombre en chaîne

_start:
    ; Vérifier le nombre d'arguments (argc)
    pop rax         ; Récupérer argc
    cmp rax, 4      ; Vérifier si on a au moins 3 arguments (plus le nom du programme)
    jl error        ; S'il y a moins de 3 arguments, erreur
    
    ; Récupérer le premier argument (argv[1])
    pop rax         ; Sauter le nom du programme (argv[0])
    pop rax         ; Récupérer le premier argument (argv[1])
    call atoi       ; Convertir la chaîne en nombre
    mov rbx, rax    ; rbx = premier nombre (provisoirement le maximum)
    
    ; Récupérer le deuxième argument (argv[2])
    pop rax         ; Récupérer le deuxième argument (argv[2])
    call atoi       ; Convertir la chaîne en nombre
    cmp rax, rbx    ; Comparer avec le maximum actuel
    jle check_third ; Si inférieur ou égal, passer au troisième
    mov rbx, rax    ; Sinon, rbx = deuxième nombre
    
check_third:
    ; Récupérer le troisième argument (argv[3])
    pop rax         ; Récupérer le troisième argument (argv[3])
    call atoi       ; Convertir la chaîne en nombre
    cmp rax, rbx    ; Comparer avec le maximum actuel
    jle display     ; Si inférieur ou égal, afficher le maximum
    mov rbx, rax    ; Sinon, rbx = troisième nombre
    
display:
    ; Convertir le maximum en chaîne et l'afficher
    mov rax, rbx
    call itoa       ; Convertir l'entier en chaîne
    
    ; Afficher le résultat
    mov rax, 1      ; syscall write
    mov rdi, 1      ; File descriptor (stdout)
    mov rsi, buffer ; Adresse du buffer
    mov rdx, rcx    ; Longueur de la chaîne
    syscall
    
    ; Afficher une nouvelle ligne
    mov rax, 1      ; syscall write
    mov rdi, 1      ; File descriptor (stdout)
    mov rsi, newline ; Adresse de la nouvelle ligne
    mov rdx, 1      ; Longueur (1 caractère)
    syscall
    
    ; Sortie avec code 0
    mov rax, 60     ; syscall exit
    mov rdi, 0      ; Code de retour = 0
    syscall
    
error:
    ; En cas d'erreur, retourner 1
    mov rax, 60     ; syscall exit
    mov rdi, 1      ; Code de retour = 1
    syscall

; Fonction pour convertir une chaîne en entier (ASCII to Integer)
atoi:
    push rbx        ; Sauvegarder rbx
    push rcx        ; Sauvegarder rcx
    push rdx        ; Sauvegarder rdx
    
    mov rbx, 0      ; rbx servira à stocker le résultat
    mov rcx, 0      ; rcx servira de compteur
    
atoi_loop:
    movzx rdx, byte [rax + rcx]  ; Charger le caractère actuel
    test rdx, rdx               ; Vérifier si c'est la fin de la chaîne (byte == 0)
    jz atoi_end                 ; Si oui, terminer
    
    cmp rdx, '0'                ; Vérifier si c'est un chiffre
    jl atoi_end
    cmp rdx, '9'
    jg atoi_end
    
    sub rdx, '0'                ; Convertir ASCII en valeur numérique
    imul rbx, 10                ; Multiplier le résultat par 10
    add rbx, rdx                ; Ajouter le chiffre actuel
    
    inc rcx                     ; Passer au caractère suivant
    jmp atoi_loop               ; Continuer la boucle
    
atoi_end:
    mov rax, rbx                ; Mettre le résultat dans rax
    
    pop rdx         ; Restaurer rdx
    pop rcx         ; Restaurer rcx
    pop rbx         ; Restaurer rbx
    ret

; Fonction pour convertir un entier en chaîne (Integer to ASCII)
itoa:
    push rbx        ; Sauvegarder rbx
    push rdx        ; Sauvegarder rdx
    
    mov rcx, buffer  ; Pointeur vers la fin du buffer
    add rcx, 19      ; On commence à la fin
    mov byte [rcx], 0 ; Terminateur de chaîne
    dec rcx
    
    mov rbx, 10     ; Diviseur
    
itoa_loop:
    xor rdx, rdx    ; Mettre rdx à 0
    div rbx         ; Diviser rax par 10, reste dans rdx
    add dl, '0'     ; Convertir le reste en caractère ASCII
    mov [rcx], dl   ; Stocker le caractère
    dec rcx         ; Reculer dans le buffer
    
    test rax, rax   ; Vérifier si le quotient est 0
    jnz itoa_loop   ; Si non, continuer
    
    inc rcx         ; Avancer au premier caractère
    
    mov rax, rcx    ; Retourner l'adresse du début de la chaîne
    sub rcx, buffer ; Calculer la longueur (pointeur fin - pointeur début)
    neg rcx         ; Rendre la longueur positive
    add rcx, 19     ; Ajuster par rapport à la taille totale du buffer
    
    pop rdx         ; Restaurer rdx
    pop rbx         ; Restaurer rbx
    ret

Version 2 of 2
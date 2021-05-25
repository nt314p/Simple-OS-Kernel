; src->esi, dest->edi, n->ecx
memcpy:
    rep movsb
    ret
; memcpy:
;     push eax
; .memcpy_loop:
;     mov al, [esi]
;     mov [edi], al
;     add esi, 1
;     add edi, 1
;     dec ecx
;     jnz .memcpy_loop
;     pop eax
;     ret



; src->esi, dest->edi, n->ecx
memswap:
    push eax
    push ebx
.memswap_loop:
    mov al, [esi]
    mov bl, [edi]
    mov [esi], bl
    mov [edi], al
    add esi, 1
    add edi, 1
    dec ecx
    jnz .memswap_loop
    pop ebx
    pop eax
    ret
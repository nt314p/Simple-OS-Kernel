VGA equ 0xA0000
WIDTH equ 320
HEIGHT equ 200
PIXELS equ WIDTH * HEIGHT
FONT_HEIGHT equ 13

; x->eax, y->ebx, color->edx
set_pixel:
    imul ebx, WIDTH
    add eax, ebx ; compute linear memory location
    add eax, VGA ; vga memory offset
    mov ebx, edx ; ebx now holds color value
    mov [eax], bl
    ret

; x->eax, y->ebx, w->ecx, h->edx, color->esi
draw_rect:
    pushad
    imul ebx, WIDTH
    add eax, ebx
    add eax, VGA
    mov edi, eax ; edi now stores the current pixel pointer
    mov ebx, edx
    mov eax, esi ; eax now holds the color value
.draw_rect_loop_rows:
    mov esi, ecx
    .draw_rect_loop_cols:
        mov [edi], al
        add edi, 1
        dec esi
        jnz .draw_rect_loop_cols
    
    sub edi, ecx
    add edi, WIDTH

    dec ebx
    jnz .draw_rect_loop_rows
    popad
    ret

; color->esi
draw_background:
    push eax
    push ecx
    mov eax, esi ; eax stores the color
    mov ah, al
    mov cx, ax
    sal eax, 16
    mov ax, cx ; eax now contains color:color:color:color
    mov esi, VGA
    mov ecx, PIXELS / 4
.draw_background_loop:
    mov [esi], eax ; store color
    add esi, 4
    dec ecx
    jnz .draw_background_loop
    pop ecx
    pop eax
    ret

; x->eax, y->ebx, w->ecx, h->edx, src->esi
draw_sprite:
    pushad
    imul ebx, WIDTH
    add eax, ebx
    add eax, VGA
    mov edi, eax ; edi stores current pixel pointer
    mov ebx, edx ; ebx stores row iterator (height)
    mov eax, ecx ; eax stores width of sprite
.draw_sprite_loop_rows:
    mov ecx, eax ; ecx stores column iterator (width)
    rep movsb ; move row of pixels from sprite memory into video memory
    
    ; .draw_sprite_loop_cols:
    ;     mov edx, [esi] ; load color into edx
    ;     mov [edi], dl ; store color
    ;     add esi, 1
    ;     add edi, 1
    ;     dec eax
    ;     jnz .draw_sprite_loop_cols
    
    sub edi, eax ; bring pointer back to start
    add edi, WIDTH ; increment a row

    dec ebx
    jnz .draw_sprite_loop_rows
    popad
    ret

; x->eax, y->ebx, cx->color_bg:color_fg, esi->str_src
draw_text:
    pushad
    imul ebx, WIDTH
    add eax, ebx
    add eax, VGA
    mov edi, eax ; edi holds display pointer
    ; mov dh, cl
    ; mov dl, ch
    ; mov cx, dx ; invert forground and background colors
.draw_char:
    xor edx, edx
    mov dl, [esi] ; dl holds char

    cmp dx, 0x0A ; newline character
    jne .draw_char_newline_done
    add edi, WIDTH * FONT_HEIGHT
    inc esi
    jmp .draw_char

.draw_char_newline_done:
    cmp dx, 0
    je .draw_text_done ; if the current char is null terminator, return
    push esi
    sub dl, 0x20 ; array index 0 corresponds to ascii 32
    mov ebx, edx
    imul ebx, FONT_HEIGHT
    add ebx, FONT8x13 ; ebx holds font pointer
    mov esi, FONT_HEIGHT ; char line counter
.draw_char_line:
    mov dl, [ebx] ; line of char
    mov al, ch ; set ax to be color_bg:color_bg
    bt dx, 7 ; copy bit 7 to carry
    cmovc ax, cx ; if bit is set, copy foreground color
    mov [edi], al
    add edi, 1

    mov al, ch
    bt dx, 6
    cmovc ax, cx
    mov [edi], al
    add edi, 1

    mov al, ch
    bt dx, 5
    cmovc ax, cx
    mov [edi], al
    add edi, 1

    mov al, ch
    bt dx, 4
    cmovc ax, cx
    mov [edi], al
    add edi, 1

    mov al, ch
    bt dx, 3
    cmovc ax, cx
    mov [edi], al
    add edi, 1

    mov al, ch
    bt dx, 2
    cmovc ax, cx
    mov [edi], al
    add edi, 1

    mov al, ch
    bt dx, 1
    cmovc ax, cx
    mov [edi], al
    add edi, 1

    mov al, ch
    bt dx, 0
    cmovc ax, cx
    mov [edi], al
    add edi, 1
    
    mov [edi], ch

    add edi, WIDTH - 8 ; increment display pointer
    add ebx, 1 ; increment font pointer
    dec esi
    jnz .draw_char_line

    sub edi, WIDTH * FONT_HEIGHT ; reset display pointer height
    add edi, 9 ; move 8 pixels to the right, next char

    pop esi
    inc esi

    jmp .draw_char

.draw_text_done:
    popad
    ret


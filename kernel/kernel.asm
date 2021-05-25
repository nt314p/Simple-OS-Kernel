[org 0x7E00]
[bits 32]

%include "drivers/screen.asm"
%include "kernel/util.asm"

GRID equ 0x07e00 ; helping myself to some RAM

kernel_main:
    

    ; jmp draw_memory
    mov esi, 0x0F ; black
    call draw_background

    mov eax, 78
    mov ebx, 147
    mov ecx, 164
    mov edx, 36
    mov esi, 0x1C
    call draw_rect

    mov eax, 80
    mov ebx, 149
    mov ecx, 160
    mov edx, 32
    mov esi, 0x35
    call draw_rect

    mov eax, 110
    mov ebx, 152
    mov cx, 0x352A
    mov esi, DS_1
    call draw_text

    mov eax, 96
    mov ebx, 167
    mov cx, 0x352A
    mov esi, DS_2
    call draw_text

    mov eax, 96
    mov ebx, 5
    mov ecx, 128
    mov edx, 128
    mov esi, PFP2
    call draw_sprite

    jmp swapper
    jmp $
    ; mov ecx, 1
    ; mov edx, 1


draw_memory:
    mov esi, FONT8x13
    mov edi, VGA
    mov ecx, 64000
    call memcpy
    jmp $

move_beach_ball:
    mov esi, 0x0F ; white
    call draw_background

    add eax, ecx
    add ebx, edx

    push ecx
    push edx
    mov ecx, 128
    mov edx, 128
    mov esi, DEVSUB
    call draw_sprite
    pop edx
    pop ecx

    cmp eax, 0
    je .inv_x
    cmp eax, WIDTH - 128
    je .inv_x
    jmp .done_inv_x
.inv_x:
    xor ecx, 0xFFFFFFFF
    add ecx, 1
.done_inv_x:
    cmp ebx, 0
    je .inv_y
    cmp ebx, HEIGHT - 128
    je .inv_y
    jmp .done_inv_y
.inv_y:
    xor edx, 0xFFFFFFFF
    add edx, 1
.done_inv_y:

    push eax
    push ebx
    mov eax, 2000
delay5:
    mov ebx, 3000
delay6:
    dec ebx
    nop
    jnz delay6
    dec eax
    jnz delay5
    pop ebx
    pop eax

    jmp move_beach_ball

draw_pfp:
    mov ecx, 204 ;
    mov esi, PFP2; 0x7C00

   ; add esi, 27260 ; 6a7c
    mov edi, VGA
    add edi, 58 ; offset x value of VGA to center image

    mov edx, ebx
    imul edx, WIDTH
    add edi, edx

    mov edx, ebx
    imul edx, 204 ;
    add esi, edx

    call memcpy

    push eax
    push ebx
    mov eax, 2000
delay3:
    mov ebx, 3000
delay4:
    dec ebx
    nop
    jnz delay4
    dec eax
    jnz delay3
    pop ebx
    pop eax

    inc ebx
    cmp ebx, 200
    jne draw_pfp
    jmp $

test_loop:
    

    mov esi, ecx
    mov ebx, 0 ; y value
    mov eax, ecx
    imul eax, 80
    push ecx
    ;xor eax, eax ; zero for x value
    ; mov ebx, 0 
    mov ecx, 80
    mov edx, HEIGHT
    call draw_rect

    ; mov eax, 40
    ; mov ebx, 40
    ; mov ecx, WIDTH - 80
    ; mov edx, HEIGHT - 80
    ; call draw_rect

    ; mov eax, ecx
    ; imul eax, WIDTH
    ; add eax, 0x00000
    ; mov esi, eax
    ; mov edi, VGA
    ; mov ecx, 64000
    ; call memcpy

    pop ecx
    inc ecx
    cmp ecx, 4
    jne test_loop
    jmp $
    ; mov eax, 40
    ; mov ebx, 40
    ; mov ecx, 100
    ; mov edx, 100
    ; mov esi, 0x0A
    ; call draw_rect

swapper:
    
    mov esi, VGA

    mov edi, WIDTH
    imul edi, 100
    add edi, VGA
    
    mov ecx, 32000

    call memcpy

    mov eax, 50000
delay1:
    mov ebx, 5000
delay2:
    dec ebx
    nop
    jnz delay2
    dec eax
    jnz delay1
    jmp swapper

gol:
    mov eax, WIDTH


DS_1: db "Hello World,", 0
DS_2: db `Dev Subbe\nrs! :D`, 0
TEST_STR: db `Hello Agent,`
PFP2: incbin "data/pfp.bin"
BEACH_BALL: incbin "data/beach-ball.bin"
DEVSUB: incbin "data/sub.bin"
FONT8x13: incbin "data/font8x13.bin"

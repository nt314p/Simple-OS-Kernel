[org 0x7E00] ; kernel code is loaded from disk into 0x1000 in ram
[bits 32]

_start:
    xor eax, eax
    mov ebx, eax
    mov ecx, eax
    mov edx, eax
    mov esi, eax
    mov edi, eax
    call kernel_main
    jmp $

%include "kernel/kernel.asm"
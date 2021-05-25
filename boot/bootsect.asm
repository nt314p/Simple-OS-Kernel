; Identical to lesson 13's boot sector, but the %included files have new paths
[org 0x7c00]
KERNEL_OFFSET equ 0x7E00 ; The same one we used when linking the kernel

    mov [BOOT_DRIVE], dl ; Remember that the BIOS sets us the boot drive in 'dl' on boot
    mov bp, 0x7BFF
    mov sp, bp

    mov bx, MSG_REAL_MODE 
    call print
    call print_nl
    
    call load_kernel ; read the kernel from disk

    ; mov ax, 0x4F02 ; see http://www.wagemakers.be/english/doc/vga
    ; mov bx, 0x0105

    mov ax, 0x0013
    int 0x10
    
    call switch_to_pm ; disable interrupts, load GDT,  etc. Finally jumps to 'BEGIN_PM'
    jmp $ ; Never executed

%include "print.asm"
%include "print_hex.asm"
%include "disk.asm"
%include "gdt.asm"
%include "32bit_print.asm"
%include "switch_pm.asm"

[bits 16]
load_kernel:
    mov bx, MSG_LOAD_KERNEL
    call print
    call print_nl
    
    mov bx, 0
    mov es, bx ; reset es register
    mov bx, KERNEL_OFFSET ; Read from disk and store at the kernel offset
    mov dh, 255 ; Our future kernel will be larger, make this big
    mov dl, [BOOT_DRIVE]
    call disk_load ; load kernel into ram
    ;jmp $
    ret

[bits 32]
BEGIN_PM:
    mov ebx, MSG_PROT_MODE
    call print_string_pm
    mov ebx, KERNEL_OFFSET
    call print_string_pm
    call KERNEL_OFFSET ; Give control to the kernel
    jmp $ ; Stay here when the kernel returns control to us (if ever)


BOOT_DRIVE db 0 ; It is a good idea to store it in memory because 'dl' may get overwritten
MSG_REAL_MODE db "16-bit Real Mode", 0
MSG_PROT_MODE db "32-bit Protected Mode", 0
MSG_LOAD_KERNEL db "Loading kernel into memory", 0

; padding
times 510 - ($-$$) db 0
dw 0xaa55
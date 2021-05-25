idt_start:
irq0:
    dw isr0 ; pointer to interrupt function
    dw 0x0008 ; selector https://wiki.osdev.org/Selector
    db 0x00 ; has to be zero
    db 10101110b ; 32 bit interrupt gate type https://wiki.osdev.org/IDT
    dw 0x0000 ; higher part of pointer 
irq1:
    dw isr1
    dw 0x0008
    db 0x00 ; 
    db 10101110b
    dw 0x0000
irq2:


idt_end:


idt_info:
    dw idt_end - idt_start - 1
    dd idt_start

load_idt:
    lidt [idt_info]
    ret

%include "cpu\isr.asm"
; load 'dh' sectors from drive 'dl' into ES:BX
disk_load:
    pusha
    ; reading from disk requires setting specific values in all registers
    ; so we will overwrite our input parameters from 'dx'. Let's save it
    ; to the stack for later use.
    push dx
    mov cl, 0x02 ; cl <- sector (0x01 .. 0x11) ------------
                 ; 0x01 is our boot sector, 0x02 is the first 'available' sector
    mov ch, 0x00 ; ch <- cylinder (0x0 .. 0x3FF, upper 2 bits in 'cl')
                    ; dl <- drive number. Our caller sets it as a parameter and gets it from BIOS
                    ; (0 = floppy, 1 = floppy2, 0x80 = hdd, 0x81 = hdd2)    
    mov dh, 0x00 ; dh <- head number (0x0 .. 0xF)


disk_load_loop:
    mov ax, 0x0201
    ; mov ah, 0x02 ; ah <- int 0x13 function. 0x02 = 'read'
    ; mov al, 0x01 ; al <- number of sectors to read (only read one to prevent page boundary crossing


    ; push dx ; print current head and sector read
    ; mov dl, cl 
    ; call print_hex ; 0xABCD -> AB=head, CD=sector
    ; pop dx

    ; [es:bx] <- pointer to buffer where the data will be stored
    ; caller sets it up for us, and it is actually the standard location for int 13h
    int 0x13      ; BIOS interrupt
    jc disk_error ; if error (stored in the carry bit)

    cmp al, 1    ; BIOS also sets 'al' to the # of sectors read. Compare it.
    jne sectors_error

    add bx, 512
    jnc disk_load_no_inc_es ; if bx register did not overflow, don't increment ES

    mov ax, es ; use ax as an intermediate register for setting the es
    shr ax, 12 ; 0xN000 -> 0x000N
    add ax, 1 ; 
    shl ax, 12 ; undo shift
    mov es, ax ; set es

disk_load_no_inc_es:

    add cx, 1 
    cmp cl, 0x25
    jne disk_load_skip
    ;jmp $
    xor dh, 1 ; toggle head value (floppys have two heads, so 1 xor 1 = 0, 0 xor 1 = 1)
    cmp dh, 0 ; if dh was set to zero, we need to increment cylinder count
    jnz disk_load_no_inc_cyl
    add ch, 1 ; increment cylinder value
disk_load_no_inc_cyl:

    mov cl, 0x01 ; reset sector value

disk_load_skip:
    mov ax, dx ; ax now stores the head value

    pop dx
    sub dx, 0x0100 ; decrement the sector counter
    push dx
    mov dx, ax ; dx now stores the head value

    pop ax
    cmp ah, 0
    push ax

    jnz disk_load_loop

    mov ax, 0
    mov es, ax ; reset ES register
    pop ax
    popa
    ret

disk_error:
    mov bx, DISK_ERROR
    call print
    call print_nl
    mov dh, ah ; ah = error code, dl = disk drive that dropped the error
    call print_hex ; check out the code at http://stanislavs.org/helppc/int_13-1.html
    jmp disk_loop

sectors_error:
    mov bx, SECTORS_ERROR
    call print
    call print_nl
    call print_hex
    call print_nl
    mov dl, al
    call print_hex

disk_loop:
    jmp $

DISK_ERROR: db "Disk read error", 0
SECTORS_ERROR: db "# of sectors read error", 0
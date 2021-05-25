@echo off

echo Compiling kernel...
i386-elf-gcc -ffreestanding -c kernel/kernel.c -o kernel.o -save-temps

echo Generating object file...
nasm boot/kernel_entry.asm -f elf -o kernel_entry.o

echo Linking...
i386-elf-ld -o kernel.bin -Ttext 0x1000 kernel_entry.o kernel.o --oformat binary

echo Compiling bootsector...
cd boot
nasm bootsect.asm -f bin -o bootsect.bin
cd ..

echo Combining binaries...
type boot\bootsect.bin kernel.bin > os-image.bin

echo Running QEmu...
qemu-system-i386 -fda os-image.bin
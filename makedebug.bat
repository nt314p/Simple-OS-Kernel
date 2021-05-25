@echo off

echo Compiling kernel...
i686-elf-gcc -g -ffreestanding -c kernel/kernel.c -o kernel.o
nasm boot/kernel_entry.asm -f elf -o kernel_entry.o

echo Linking...
i686-elf-ld -o kernel.elf -Ttext 0x1000 kernel_entry.o kernel.o

echo Compiling bootsector...
cd boot
nasm bootsect.asm -f bin -o bootsect.bin
cd ..

echo Combining binaries...
type boot\bootsect.bin kernel.bin > os-image.bin

echo Running QEmu...
start qemu-system-x86_64 -s -fda os-image.bin 
timeout /t 5 > nul
i686-elf-gdb -ex "set arch i386:x86-64" -ex "target remote localhost:1234" -ex "symbol-file kernel.elf"
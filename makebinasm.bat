@echo off

echo Assembling kernel...
nasm boot/kernel_entry.asm -f bin -o kernel.bin

echo Assembling bootsector...
cd boot
nasm bootsect.asm -f bin -o bootsect.bin
cd ..

echo Combining binaries...
type boot\bootsect.bin kernel.bin > os-image.bin

echo Running QEmu...
qemu-system-i386 -fda os-image.bin
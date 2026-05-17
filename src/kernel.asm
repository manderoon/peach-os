[BITS 32]

section .text               ; needs to be the first bit of code we run

global _start
extern kernel_main

CODE_SEG equ 0x08
DATA_SEG equ 0x10 

_start:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp

    ; enable the A20 line
    in al, 0x92
    or al, 2
    out 0x92, al

    call kernel_main
    jmp $

times 512-($-$$) db 0   ; solves alignment issues by forcing it to be 512 bytes long
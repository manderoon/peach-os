ORG 0x7c00       ; load code from origin
BITS 16          ; 16 bit instructions for real mode

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start

_start:
    jmp short start
    nop

times 33 db 0   ; 33 null bytes for FAT data
                ; bios parameter block

start:
    jmp 0:step2     ; jmp segment:offset

step2:
    cli             ; clear interrupts
    mov ax, 0x00
    mov ds, ax      ; data segment
    mov es, ax      ; extra segment
    mov ax, 0x00
    mov ss, ax      ; stack segment
    mov sp, 0x00    ; stack pointer
    sti             ; enable interrupts


.load_protected:
    cli
    lgdt[gdt_descriptor]    ; look down and see gdt descriptor, find size + offset and lock in and load
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax            ; reset register
    jmp CODE_SEG:load32     ; CODE_SEG = 0x8

; GDT
gdt_start:
gdt_null:
    dd 0x0      ; 64 bits of null
    dd 0x0

; offset 0x8
gdt_code:           ; CS should point to this
    dw 0xffff       ; segment limit first 0-15 bits
    dw 0            ; base first 0-15 bits
    db 0            ; base 16-23 bits
    db 0x9a         ; access byte
    db 1100111b     ; high 4 bit flags and low 4 bit flags
    db 0            ; base 24-31 bits
;offset 0x10
gdt_data:           ; DS, SS, ES, FS, GS
    dw 0xffff       ; segment limit first 0-15 bits
    dw 0            ; base first 0-15 bits
    db 0            ; base 16-23 bits
    db 0x92         ; access byte
    db 1100111b     ; high 4 bit flags and low 4 bit flags
    db 0            ; base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1    ; size of descriptor
    dd gdt_start                ; offset

[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp
    jmp $

times 510-($-$$) db 0   ; times = repeat this thing N times
                        ; $-$$ = how many bytes we have so far 
                        ; db = define byte

dw 0xAA55   ; dw = define 'word' (2 bytes)

buffer:
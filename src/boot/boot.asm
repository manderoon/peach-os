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
    lgdt[gdt_descriptor]        ; look down and see gdt descriptor, find size + offset and lock in and load
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax                 ; reset register
    jmp CODE_SEG:load32

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
    db 11001111b    ; high 4 bit flags and low 4 bit flags
    db 0            ; base 24-31 bits

;offset 0x10
gdt_data:           ; DS, SS, ES, FS, GS
    dw 0xffff       ; segment limit first 0-15 bits
    dw 0            ; base first 0-15 bits
    db 0            ; base 16-23 bits
    db 0x92         ; access byte
    db 11001111b    ; high 4 bit flags and low 4 bit flags
    db 0            ; base 24-31 bits

gdt_end:

gdt_descriptor:
    dw gdt_end - gdt_start-1    ; size of descriptor
    dd gdt_start                ; offset

; load kernel into memory and jump to it
[BITS 32]
load32:
    mov eax, 1                  ; starting sector we want to load from - 1
    mov ecx, 100                ; total number of sectors we want to laod - 100 sectors
    mov edi, 0x100000           ; address we want to load into - 1MB
    call ata_lba_read           ; label to talk with the driver and load the sector into memory


; LBA = sector offset from the very beginning of the disk
; dummy driver to load the kernel
ata_lba_read:
    mov ebx, eax                ; backup the LBA
    shr eax, 24                 ; send the highest 8 bits of the LBA to the hard disk controller
                                ; 32 - 24 = 8, move eax 24 bits to the right so eax will contain high 8 bits of lba
    or eax, 0xE0                ; selects the master drive (slave vs. master)
    mov dx, 0x1F6               ; port we need to write the 8 bits to
    out dx, al
    ; finished sending highest 8 bits of the LBA

    ; send total sectors to the hard disk controller
    mov eax, ecx
    mov dx, 0x1F6
    out dx, al
    ; finished sending total sectors to read

    ; send more bits of the lba
    mov eax, ebx                ; restore the backup LBA
    mov dx, 0x1F3
    out dx, al                  ; out = talking with the bus on the motherboard, controller listens
    ; finished sending more bits of the LBA

    ; send even more bits of the LBA
    mov dx, 0x1F4
    mov eax, ebx                ; restore the backup LBA
    shr eax, 8
    out dx, al
    ; finished sending even more bits of the LBA

    ; send upper 16 bits of the LBA
    mov dx, 0x1F5
    mov eax, ebx                ; restore the backup LBA
    shr eax, 16                 ; shift to the right by 16
    out dx, al                  ; output to the controller
    ; finished sending upper 16 bits of the LBA

    mov dx, 0x1f7
    mov al, 0x20
    out dx, al
    ; read all sectors into memory

.next_sector:
    push ecx

; checking if we need to read, controller may have delays
.try_again:
    mov dx, 0x1f7           ; read from port 0x1f7
    in al, dx               ; into the al register
    test al, 8              ; test to see if a bit is set in the bitmap
    jz .try_again           ; try again if test fails


    ; we need to read 256 words at a time
    mov ecx, 256
    mov dx, 0x1F0
    rep insw                ; reads a word from io port in dx into the memory location specified in ES in the edi register
                            ; reading a word from the port (0x1F0) and storing it in to edi register
                            ; do insw 256 times
    pop ecx                 ; restore ecx sector number
    loop .next_sector        ; decrements the sector number
    ; end of reading sectors into memory 
    ret


times 510-($-$$) db 0   ; times = repeat this thing N times
                        ; $-$$ = how many bytes we have so far 
                        ; db = define byte

dw 0xAA55   ; dw = define 'word' (2 bytes)

buffer:
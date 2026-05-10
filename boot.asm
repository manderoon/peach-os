ORG 0       ; load code from origin
BITS 16     ; 16 bit instructions for real mode

_start:
    jmp short start
    nop

times 33 db 0   ; 33 null bytes for FAT data
                ; bios parameter block

start:
    jmp 0x7c0:step2     ; jmp segment:offset
                        ; we want out code to start at 0x7c0

step2:
    cli             ; clear interrupts
    mov ax, 0x7c0   ; chuck 0x7c0 into ax bc we cant put directly in segment register
    mov ds, ax      ; data segment = 0x7C0
    mov es, ax      ; extra segment = 0x7C0
    mov ax, 0x00
    mov ss, ax      ; stack segment = 0
    mov sp, 0x7c00  ; stack pointer (grows down from 0x7C00)
    sti             ; enable interrupts

    mov ah, 2       ; read sector command
    mov al, 1       ; one sector to read
    mov ch, 0       ; cylinder low eight bits
    mov cl, 2       ; read sector two
    mov dh, 0       ; head number
    mov bx, buffer
    int 0x13        ; read command
    jc error        ; if carry flag is set, jumps to error message

    mov si, buffer
    call print

    jmp $

error:
    mov si, error_message
    call print
    jmp $           ; did everything we wanted to do, now just loop

print:
    mov bx, 0       ; use page zero to print
.loop:
    lodsb           ; AL = [SI], SI++
                    ; read a byte and then move to the next one
    cmp al, 0       ; check if we've reached null terminator
    je .done        ; if yes, go to done
    call print_char ; print the char in SI if we haven't reached the end
    jmp .loop       ; go back to the start of the loop with the iterated [SI] value
.done:
    ret

print_char:
    mov ah, 0x0e    ; which function to use (print char)
    int 0x10        ; interrupt for video services
    ret

error_message: db "Failed to load sector", 0

times 510-($-$$) db 0   ; times = repeat this thing N times
                        ; $-$$ = how many bytes we have so far 
                        ; db = define byte

dw 0xAA55   ; dw = define 'word' (2 bytes)


buffer:
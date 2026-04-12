ORG 0x7c00  ; load code from this address
BITS 16     ; 16 bit instructions for real mode

start: 
    mov ah, 0x0e    ; which function to use (print char)
    mov al, 'A'     ; the argument ('A')
    int 0x10        ; interrupt for video services

    jmp $           ; did everything we wanted to do, now just loop


times 510-($-$$) db 0   ; times = repeat this thing N times
                        ; $-$$ = how many bytes we have so far 
                        ; db = define byte


dw 0xAA55   ; dw = define 'word' (2 bytes)
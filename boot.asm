ORG 0x7c00  ; load code from this address
BITS 16     ; 16 bit instructions for real mode

start: 
    mov si, message
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

message: db 'Hello, hello', 0

times 510-($-$$) db 0   ; times = repeat this thing N times
                        ; $-$$ = how many bytes we have so far 
                        ; db = define byte

dw 0xAA55   ; dw = define 'word' (2 bytes)
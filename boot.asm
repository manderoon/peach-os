ORG 0x7c00  ; load code from this address
BITS 16     ; 16 bit instructions for real mode

; print_char('A');

; AX (16 bits):
; ┌────────┬────────┐
; │   AH   │   AL   │
; │ (high) │ (low)  │
; │ 8 bits │ 8 bits │
; └────────┴────────┘

; void bios_video_handler() {
;     switch (AH) {
;         case 0x00: change_video_mode(); break;
;         case 0x01: set_cursor_shape(); break;
;         case 0x02: move_cursor(); break;
;         // ...
;         case 0x0E: print_character(AL); break;
;     }
; }

; int 0x10 = bios_video()
; bios_video(0x0E, 'A');
; //         ↑       ↑
; //         AH      AL
; //         function argument
; //         "print"  "the letter A"


start: 
    mov ah, 0x0e    ; which function to use (print char)
    mov al, 'A'     ; the argument ('A')
    int 0x10        ; interrupt for video services

    jmp $           ; did everything we wanted to do, now just loop


times 510-($-$$) db 0   ; times = repeat this thing N times
                        ; $-$$ = how many bytes we have so far 
                        ; db = define byte


dw 0xAA55   ; dw = define 'word' (2 bytes)
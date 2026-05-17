#include <stdint.h>

#include "kernel.h"


uint16_t terminal_make_char(char c, char colour) {
    return (colour << 8) | c;
}

void kernel_main() {
    uint16_t* video_mem = (uint16_t*)(0xB8000);
    video_mem[0] = terminal_make_char('B', 3);
}
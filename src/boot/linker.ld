ENTRY(_start)
OUTPUT_FORMAT(binary)
SECTIONS 
{
    /* 
        kernel will be loaded into 1MB into memory
        need to load it into addr (1024*1024) = 100000
        linker is creating addresses based on this origin
        origin starts at 1MB
    */

     . = 1M;

     /*  text section */
     .text :
     {
        *(.text)
     }


    /* read only data section */
     .rodata :
     {
        *(.rodata)
     }

    /* data section */
     .data :
     {
        *(.data)
     }

    /* bss section */
     .bss :
     {
        *(COMMON)
        *(.bss)
     }
}
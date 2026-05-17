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


   /* make sure all sections are aligned by 16 bytes */

   /*  text section */
   .text : ALIGN(4096)
   {
      *(.text)
   }


   /* read only data section */
   .rodata : ALIGN(4096)
   {
      *(.rodata)
   }

   /* data section */
   .data : ALIGN(4096)
   {
      *(.data)
   }

    /* bss section */
   .bss : ALIGN(4096)
   {
      *(COMMON)
      *(.bss)
   }

   /* assembly section */
   .asm : ALIGN(4096)
   {
      *(.asm)
   }
}
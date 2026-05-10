### PeachOS

```
$ nasm -f bin boot.asm -o boot.bin    # Assemble to raw binary 
$ qemu-system-x86_64 -hda boot.bin    # Boot it in the emulator
```

Debug
```
gdb
(gdb) target remote | qemu-system-x86_64 -hda ./boot.bin -S -gdb stdio
```
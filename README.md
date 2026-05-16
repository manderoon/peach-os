# PeachOS

## Build and run

```
$ make
$ qemu-system-x86_64 -hda /bin/boot.bin    # Boot it in the emulator
```


## Debugging

### Debug boot.bin
```
$ gdb
(gdb) target remote | qemu-system-x86_64 -hda ./bin/boot.bin -S -gdb stdio
```

### Debug os.bin
```
$ gdb
(gdb) add-symbol-file ./build/kernelfull.o 0x100000
(gdb) break _start
(gdb) target remote | qemu-system-x86_64 -hda ./bin/os.bin -S -gdb stdio
(gdb) layout asm
(gdb) stepi   // step through the program
```
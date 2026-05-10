### PeachOS

Build and run
```
$ make
$ qemu-system-x86_64 -hda /bin/boot.bin    # Boot it in the emulator
```

Debug
```
$ gdb
(gdb) target remote | qemu-system-x86_64 -hda ./bin/boot.bin -S -gdb stdio
```
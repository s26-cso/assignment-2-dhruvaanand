## Q3 Part A

The goal is to find the input that makes `target_dhruvaanand` print `You have passed!`

### What I tried first

The binary is a statically linked RISC-V ELF, so any hardcoded strings sit in `.rodata` in plain text. Running `strings` on it and grepping around the success message is the obvious first move:

```bash
strings target_dhruvaanand | grep -C 5 "You have passed!"
```

### What came out

```
Enter the secret code: 
%63s
XoNEM89fY2pfoGZ1eXLAp7QD0YaH203yVdKQ2ROhkmE=
You have passed!
Sorry, try again.
```

Same structure as expected. The program prompts for input, reads up to 63 characters with `%63s`, then compares against the string sitting right above the success message. That's the password.

### Getting it to pass

```bash
echo "XoNEM89fY2pfoGZ1eXLAp7QD0YaH203yVdKQ2ROhkmE=" > q3/a/payload.txt
qemu-riscv64 -L /usr/riscv64-linux-gnu ./target_dhruvaanand < payload.txt
# You have passed!
```
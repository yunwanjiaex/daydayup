# shellcode 加载器
1. 有汇编代码 `sc.s` 如下
    ```x86asm
    .global _start
    _start:
    .intel_syntax noprefix
        mov rax, 59
        lea rdi, [rip+binsh]
        mov rsi, 0
        mov rdx, 0
        syscall
    binsh:
        .string "/bin/sh"
    ```
2. 编译之,提取出有效载荷
    ```bash
    gcc -Wl,-N -nostdlib -static sc.s -o sc.out
    objcopy --dump-section .text=sc_raw sc.out
    xxd sc_raw
    ```
3. 有 `rsc.c` 如下,用来加载 shellcode
    ```c
    #include <sys/mman.h>
    int main() {
        void *page = mmap(0, 0x1000, PROT_READ | PROT_WRITE | PROT_EXEC, MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
        read(0, page, 0x1000);
        ((void (*)())page)();
        return 0;
    }
    ```
4. 编译执行
    ```bash
    gcc rsc.c
    ( cat sc_raw; cat ) | ./a.out
    ```
#include <stdio.h>
#include <sys/mman.h>
#include <sys/ptrace.h>
#include <sys/user.h>
#include <sys/wait.h>
// 这段代码演示了 ptrace 注入的一般流程,不具有较高的可用性

int main(int argc, char *argv[]) {
    struct user_regs_struct regs_ori, regs;
    unsigned long tmp_data;
    siginfo_t info;
    pid_t pid;

    // 只接受一个字符串参数,为要注入的进程 id
    sscanf(argv[1], "%d", &pid);
    // attach 到 pid, 多线程要同时 attach 到所有线程才能确保程序停止
    ptrace(PTRACE_ATTACH, pid, 0, 0);
    waitid(P_PID, pid, &info, WSTOPPED);

    // 在指定地址(如0x45678)设下断点,写入 int3 指令,到了地方再写回来
    // 如果需要根据特征码搜索内存可以使用 /proc/pid/mem
    tmp_data = ptrace(PTRACE_PEEKTEXT, pid, 0x45678, 0);
    ptrace(PTRACE_POKETEXT, pid, 0x45678, 0xcc);
    ptrace(PTRACE_CONT, pid, NULL, NULL);
    waitid(P_PID, pid, &info, WSTOPPED);
    ptrace(PTRACE_POKETEXT, pid, 0x45678, tmp_data);
    // 保存现场用于事后还原,方便起见,只保存了寄存器和 rip 指向的内存
    // 较复杂程序可以为 rsp 和 rbp 重新赋值,指向自建栈,从而避免破坏原有栈
    ptrace(PTRACE_GETREGS, pid, 0, &regs_ori);
    tmp_data = ptrace(PTRACE_PEEKTEXT, pid, regs_ori.rip, 0);

    // 用 mmap 分配一块内存
    regs = regs_ori;
    regs.rax = 9;
    regs.rdi = 0;
    regs.rsi = PAGE_SIZE;
    regs.rdx = PROT_READ | PROT_WRITE | PROT_EXEC;
    regs.r10 = MAP_PRIVATE | MAP_ANONYMOUS;
    regs.r8 = -1;
    regs.r9 = 0;
    ptrace(PTRACE_SETREGS, pid, 0, &regs);
    // 0F05 syscall
    ptrace(PTRACE_POKETEXT, pid, regs_ori.rip, 0x050f);
    ptrace(PTRACE_SINGLESTEP, pid, 0, 0);
    waitid(P_PID, pid, &info, WSTOPPED);
    ptrace(PTRACE_GETREGS, pid, 0, &regs);
    // 还原被改动的内存
    ptrace(PTRACE_POKETEXT, pid, regs_ori.rip, tmp_data);
    tmp_data = regs.rax;

    // tmp_data 保存的是分配到的内存首地址,长度为一页
    // 此时可以将任意代码/数据写入这块内存,然后将 rip 指向 tmp_data
    // 就可以执行了 do what you want here

    // munmap 释放内存
    regs.rip = tmp_data;
    regs.rax = 11;
    regs.rdi = tmp_data;
    regs.rsi = PAGE_SIZE;
    ptrace(PTRACE_SETREGS, pid, 0, &regs);
    ptrace(PTRACE_POKETEXT, pid, tmp_data, 0x050f);
    ptrace(PTRACE_SINGLESTEP, pid, 0, 0);
    waitid(P_PID, pid, &info, WSTOPPED);

    // 恢复进程并退出
    ptrace(PTRACE_SETREGS, pid, 0, &regs_ori);
    ptrace(PTRACE_DETACH, pid, 0, 0);
    return 0;
}
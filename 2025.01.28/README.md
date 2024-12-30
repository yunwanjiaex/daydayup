# 绑定进程到 CPU 指定核心
### 指定进程运行在 CPU 某核上
查看 pid 为 1 的进程可以运行的 CPU 核心,也就是当前内核可以调度进程的 CPU 核心
```bash
taskset -cp 1
```
指定第2,3,4核启动进程
```bash
taskset -c 1,2,3 nginx
```
改变进程的运行核心为第1,2核, pid 为进程号
```bash
taskset -cp 0,1 $pid
```
### 指定 CPU 某核只能运行该进程
修改内核启动参数,指定需要隔离的 CPU 核心
```
GRUB_CMDLINE_LINUX_DEFAULT="... isolcpus=0-2 nohz_full=0-2"
```
`isolcpus` 表示内核不在该核心上调度其它进程, `nohz_full` 表示在这些核心上内核自己都尽量不运行,比如计时器什么的.重启后进入系统就可以用 `taskset` 指定进程运行在被隔离的CPU核心上
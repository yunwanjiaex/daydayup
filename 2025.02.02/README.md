# 手搓 helloworld
```
# ELF头表
00:   7f 45 4c 46 02 01 01 00 00 00 00 00 00 00 00 00 # 固定值
10:   02 00          # ELF 类型, 02 是可执行程序
12:   3e 00          # 架构, 3e 是 amd64
14:   01 00 00 00    # 固定值
18:   78 00 40 00 00 00 00 00    # 程序入口是 0x400078
20:   40 00 00 00 00 00 00 00    # 段头表从 0x40 的位置开始
28:   00 00 00 00 00 00 00 00    # 节头表的位置,因本程序无节头表,所以是0
30:   00 00 00 00    # 固定值
34:   40 00          # ELF 头表大小,64位固定是 0x40
36:   38 00          # 每个段头表大小,64位固定是 0x38
38:   01 00          # 段的数量,本程序中只有1个
3a:   00 00          # 每个节头表大小,无节所以是0
3c:   00 00          # 节的数量,0
3e:   00 00          # 节名称表位置,无,0

# 段头表
40:   01 00 00 00                # 段类型,1是 PT_LOAD
44:   05 00 00 00                # 段权限,5是可读可执行
48:   00 00 00 00 00 00 00 00    # 本段在文件中的位置,本应是 0x40 ,但因为是第1个 PT_LOAD ,所以是0
50:   00 00 40 00 00 00 00 00    # 本段加载到内存的虚拟地址
58:   00 00 40 00 00 00 00 00    # 本段加载到内存的物理地址,无用
60:   af 00 00 00 00 00 00 00    # 本段在文件中的大小,本应是 0x37 ,但实际上为整个文件大小
68:   af 00 00 00 00 00 00 00    # 本段在内存中的大小,同上
70:   00 10 00 00 00 00 00 00    # 对齐, 0x1000 是1页

# 代码
78:   48 c7 c0 01 00 00 00    # mov rax,0x1
7f:   48 c7 c7 01 00 00 00    # mov rdi,0x1
86:   48 8d 35 15 00 00 00    # lea rsi,[rip+0x15]
8d:   48 c7 c2 0d 00 00 00    # mov rdx,0xd
94:   0f 05                   # syscall
96:   48 c7 c0 3c 00 00 00    # mov rax,0x3c
9d:   48 31 ff                # xor rdi,rdi
a0:   0f 05                   # syscall
a2:   68 65 6c 6c 6f 2c 20 77 6f 72 6c 64 0a    # "hello world\n"
```
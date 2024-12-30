# Linux 文件的打开方式
1. 在 Linux 上一个文件要想被运行至少要满足两个条件: 1. 有可执行权限 2. 文件格式可以被执行. 比如 `ELF` 文件和 `#!` 开头的脚本.除此之外,还可以用 `binfmt_misc` 指定文件的打开方式
2. 文件后缀名为 `.edit` ,执行它时用 `vim` 打开
    ```bash
    echo ':vim_edit:E::edit::/usr/bin/vim:' > /proc/sys/fs/binfmt_misc/register
    date > 1.edit
    chmod +x 1.edit
    ./1.edit
    ```
3. 文件内容以 `#!bash` 开头,执行它时删除自己.其中解释器 `/usr/bin/rm` 既可以是二进制文件,也可以是文本脚本文件.内核会将 `rm` 放在 `argv[0]` 的位置, `./1.sh` 自身的命令行依次向后顺移一位
    ```bash
    echo ':rm_self:M::#!bash::/usr/bin/rm:' > /proc/sys/fs/binfmt_misc/register
    echo '#!bash' > 1.sh
    echo echo hello >> 1.sh
    chmod +x ./1.sh
    ./1.sh
    ```
4. 顾名思义, `binfmt_misc` 主要是用来执行各种格式的二进制文件,毕竟大部分文本文件直接在开头加上 `#!` 指定解释器就可以了.比如大名鼎鼎的 `wine` 和 `qemu-arm`
5. 注册后会在同目录生成规则文件,输入 `-1` 可以解除规则
    ```bash
    echo -1 > /proc/sys/fs/binfmt_misc/rm_self
    ```
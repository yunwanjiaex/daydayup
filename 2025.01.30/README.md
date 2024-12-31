# 常见加密 shell 脚本的解密
1. 运行脚本之后用 `ctrl+z` 暂停,用 `ps aww` 查看命令行内容,或查看 `/proc/$pid/fd/` 目录下的文件
2. 调试之 `strace -f -s9999 -e trace=clone,execve,read,write -o ./debug.txt ./1.sh`
3. 对于混淆过的脚本,可用 `bash -xv 1.sh` 执行
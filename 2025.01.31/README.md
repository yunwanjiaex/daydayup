# 一个进程的 hosts
通过给某个进程单独设置 `/etc/hosts` 来劫持它要访问的域名,以`Debian 12` 上的 `ping` 为例
### LD_LIBRARY_PATH
1. 复制 `/lib/x86_64-linux-gnu/libc.so.6` 到 `~/lib/`
2. 替换字符串 `sed -i 's@/etc/hosts@/tmp/hosts@g' ./lib/libc.so.6`
3. 编辑 `/tmp/hosts` ,添加内容如 `127.0.0.1 baidu.com`
4. 如此使用 `LD_LIBRARY_PATH=~/lib ping baidu.com`
### [bwrap](https://github.com/containers/bubblewrap)
```bash
apt install bubblewrap
bwrap --dev-bind / / --ro-bind /tmp/hosts /etc/hosts ping baidu.com
```
### unshare
```bash
unshare -m bash -s << EOF
echo 127.0.0.1 baidu.com > ./test.hosts
mount --bind ./test.hosts /etc/hosts
ping baidu.com
EOF
```
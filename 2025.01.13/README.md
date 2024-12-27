# ssh 免输密登录
ssh 登录时通过脚本输入密码而不是手输
### SSH_ASKPASS
```bash
echo 'echo "this_is_ppsswwdd"' > 1.sh
chmod +x 1.sh
SSH_ASKPASS_REQUIRE=force SSH_ASKPASS="$PWD/1.sh" DISPLAY="none:0" ssh user@host
```
### expect
```tcl
#!/usr/bin/expect -f
set timeout 100
spawn ssh [lrange $argv 0 end]
expect {
    "yes/no" {exp_send "yes\r"; exp_continue}
    "?assword:" {exp_send "this_is_ppsswwdd\r"}
}
interact
```
### [tssh](https://github.com/trzsz/trzsz-ssh)
* 支持登录验证和非明文密码,和 expect 功能相同但通过配置文件实现,详见[Trzsz-ssh(tssh)中文文档](https://trzsz.github.io/cn/ssh#section-6)
* 客户端使用 `tssh` ,服务端使用 [trzsz](https://github.com/trzsz/trzsz) ,可以让普通终端连接 ssh 时和服务器互传文件
* 如果客户端还安装了[lrzsz-win32](https://github.com/trzsz/lrzsz-win32),可以直接支持服务端的 `lrzsz`
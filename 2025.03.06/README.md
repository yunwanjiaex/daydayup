# 另一种 ddns
1. 如果不想花钱买域名,可以在服务端将动态 ip 定时更新到 git 私有仓库,客户端按时同步仓库即可获取到最新 ip .详见 [server.sh](./server.sh) 和 [client.sh](./client.sh)
2. 将所需配置写入本地以免污染其他仓库
    ```bash
    git config --local user.name "yun.wanjia.ex"
    git config --local user.email "yun.wanjia.ex@gmail.com"
    git config --local core.sshCommand 'ssh -i ~/.ssh/ddns'
    ```
3. 若请求频率较高建议自建 ip 获取服务如 [web.sh](./web.sh)
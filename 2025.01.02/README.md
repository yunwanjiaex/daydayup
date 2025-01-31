# 使用 git 进行远控
* 在主控端和被控端都配置好 git ,一台主机一个仓库.克隆时将配置写入本地以免污染其他仓库
    ```bash
    git clone git@github.com:yunwanjiaex/macmini.git \
        --config user.name="yun.wanjia.ex" --config user.email="yun.wanjia.ex@gmail.com" \
        --config core.sshCommand="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no -i ~/.ssh/macmini"
    # cd macmini; git config --local -l
    ```
* 主控端将运行代码写入 `task/run.ps1` ,调度代码写入 `task/sch.ps1`
* 被控端将 `main.ps1` 加入任务计划,每次先运行 `task/sch.ps1 `判断环境,符合条件则执行 `task/run.ps1`
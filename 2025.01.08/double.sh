#!/bin/bash
# 双守护进程,纯 bash 实现,用两个守护进程去监控一个进程的运行状态,守护进程之间相互监控,发现对方挂了就重启它

shopt -u huponexit
# 若这些环境变量为空则定义它们, daddy 为 0 或 1 , daddy_pid 记录另一个守护进程的 pid
: ${id=${EPOCHREALTIME/[^0-9]/}} ${cmd="$@"} ${cmd_pid=/tmp/daddy_$id} ${daddy=0} ${daddy_pid=0}
export id cmd cmd_pid daddy daddy_pid

while :; do
    # daddy 为 0 且 cmd 未启动,则启动它
    if [ $daddy = 0 ] && [ ! -d /proc/$(<$cmd_pid)/fd ]; then
        $cmd &
        echo $! >$cmd_pid
    fi
    # 代替 sleep 命令
    read -t1 </dev/udp/127.0.0.1/0
    # 若另一个守护进程不存在,则启动它
    if [ ! -d /proc/$daddy_pid ]; then
        daddy_pid=$$
        daddy=$(($daddy^1))
        "$0" &
        daddy_pid=$!
        daddy=$(($daddy^1))
    fi
done

# usage: ./double.sh ping 127.0.0.1

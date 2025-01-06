#!/bin/bash
# 简易 expect
export workdir=$(mktemp -dt ttyXXXX)
export line=1

start_program(){
    line=1
    # 一个脚本同时只能运行一个实例
    [ -e $workdir/tty ] && kill $(cat $workdir/pid)
    # 打开伪终端执行命令
    socat pty,rawer,wait-slave,link=$workdir/tty \
        exec:"$1",pty,stderr,setsid,ctty &> /dev/null &
    echo $! > $workdir/pid
    # 等待伪终端建立
    while [ ! -e $workdir/tty ]; do sleep 0.5; done
    # 同时输出到控制台和文件
    tee $workdir/output < $workdir/tty 2> /dev/null &
    echo $! >> $workdir/pid
}

wait_string(){
    local line_match
    local line_output
    while sleep 0.5; do
        # 过滤掉一些控制字符以便于匹配
        awk 'NR>='$line $workdir/output | \
            sed -r 's/\x1B\[[0-9;?]+[a-zA-Z]//g' > $workdir/read
        # 匹配项所在行和该次匹配的总行数
        IFS=. read line_match line_output < \
            <(awk /$1/'{printf NR; exit}END{print "."NR}' $workdir/read)
        # 根据匹配结果修改下一次匹配的开始行数
        if [ "$line_match" ]; then
            ((line+=line_match))
            break
        else # 以防最后一行过长所以带入下次匹配
            ((line+=line_output-1))
            [ $line = 0 ] && line=1
        fi
    done
}

send_string(){
    printf "$1" > $workdir/tty
}

# 需要安装 socat, test.sh 为测试脚本
# 遥遥无期: 1. 对 vim 等应用的控制字符的处理 2. 添加对 lrzsz 的支持
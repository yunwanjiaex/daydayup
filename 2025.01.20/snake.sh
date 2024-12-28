#!/bin/bash

printf "\e[?25l" # 禁用光标
# 移动光标到 (x,y) 然后打印字符串
xy(){ printf "\e[${2};${1}H${3}"; }

clear # 清屏然后画边框
read rows cols < <(stty size)
xy 1 1 ╔
xy 1 $rows ╚
xy $cols 1 ╗
xy $cols $rows ╝
for ((x=2;x<cols;x++)); do
    xy $x 1 ═
    xy $x $rows ═
done
for ((y=2;y<rows;y++)); do
    xy 1 $y ║
    xy $cols $y ║
done

die(){
    printf "\e[?25h" # 显示光标
    xy 1 $((rows-2)) "$1"
    xy 1 $((rows-1)) "GAME OVER"
    kill -TERM -- -$$
}
trap die INT # 玩家 ctrl+c 或游戏结束执行 die
trap 'xy 1 $rows ""; exit' TERM

snake=("3 2" "2 2") # 蛇头 <- 蛇尾 "x y"
act_direct=1 # 蛇头实际行动方向: 右1 左-1 上2 下-2
apple="4 2" # 苹果位置

t=$(mktemp)
echo $act_direct > $t
while :; do
    read key_direct < $t # 玩家按键方向
    read head_x head_y <<< "${snake[0]}"
    # 如果按键方向和实际方向平行,则不做处理
    if [ "$key_direct" != "$act_direct" ] && [ $((key_direct + act_direct)) -ne 0 ]; then
        act_direct=$key_direct
    fi
    case $act_direct in
        1) ((head_x++));;
        -1) ((head_x--));;
        2) ((head_y--));;
        -2) ((head_y++));;
    esac
    snake_head="$head_x $head_y" # 蛇头新坐标

    # 撞墙而死
    if [ $head_x -le 1 ] || [ $head_y -le 1 ] || [ $head_x -ge $cols ] || [ $head_y -ge $rows ]; then
        die "Hit the Wall!"
    fi
    # 撞自己而死
    for snake_body in "${snake[@]}"; do
        if [ "$snake_body" = "$snake_head" ]; then
            die "Hit Yourself!"
        fi
    done

    # 画蛇头,抹蛇尾
    xy ${snake[0]} '+'
    snake=("$snake_head" "${snake[@]}")
    xy ${snake[0]} '@'
    if [ "$snake_head" = "$apple" ]; then
        snake_body=xxx # 随机生成苹果位置并判断是否合法
        while [ "$snake_body" = "xxx" ]; do
            apple="$((RANDOM%(cols-2)+2)) $((RANDOM%(rows-2)+2))"
            for snake_body in "${snake[@]}"; do
                if [ "$snake_body" = "$apple" ]; then
                    snake_body=xxx
                    break
                fi
            done
        done
        xy $apple '#'
    else
        xy ${snake[-1]} ' '
        unset snake[-1]
    fi

    sleep 0.1 # 调整速度
done &

while :; do
    read -rsn1 k # 读取键盘输入
    if [ "$k" = $'\e' ]; then
        read -rsn2 k # 上[A 下[B 左[D 右[C
    fi
    case "$k" in
    '[A'|w) k=2;;
    '[B'|s) k=-2;;
    '[C'|d) k=1;;
    '[D'|a) k=-1;;
esac
    echo "$k" > $t
done
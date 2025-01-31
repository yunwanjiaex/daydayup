#!/bin/bash
cd "$(dirname "$0")"
git stash
git pull
git stash pop
git add -A
git commit -m $(date "+%y.%m.%d_%H.%M.%S_%6N")
git push

find -maxdepth 1 -mindepth 1 -type d -name 'task_*' \
    | xargs -III -P0 bash -c 'cd II
    [ -f run.sh ] || exit
    [ -f sch.sh ] && ! bash sch.sh && exit
    [ ! -f sch.sh ] && [ -f res.txt ] && exit

    echo "=====start======" > res.txt
    bash run.sh &>> res.txt
    echo "=====finish=====" >> res.txt'
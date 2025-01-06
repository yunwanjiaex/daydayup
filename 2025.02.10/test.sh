#!/usr/bin/bash

source ./expect.sh
start_program "ssh root@192.168.222.111"

wait_string ':~]# '
send_string 'date'

wait_string ':~]# '
send_string 'ls -al /\n'

wait_string ':~]# '
send_string 'vim 000.txt\n'
sleep 1
send_string 'ihahaha\e:x\n'

wait_string ':~]# '
send_string 'exit\n'
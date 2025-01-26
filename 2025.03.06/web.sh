#!/bin/bash
echo -en "HTTP/1.0 200\r\n"
echo -en "Content-Type:text/html\r\n"
echo -en "\r\n"

cd "$(dirname "$0")"
head -1 | grep -qi 'get /set' && echo $SOCAT_PEERADDR > ip.txt
cat ip.txt
# socat tcp-listen:8888,fork,reuseaddr system:"bash web.sh"
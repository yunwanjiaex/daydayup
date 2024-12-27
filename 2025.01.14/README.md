# sshd 和 nginx 共用端口
1. 新建一个简单的 https 网站,监听 `127.0.0.1:3443`
    ```bash
    apt-get install -y nginx libnginx-mod-stream
    rm -f /etc/nginx/sites-enabled/default
    echo 'server {
        listen 127.0.0.1:3443 ssl;
        ssl_certificate /etc/nginx/cert/server.crt;
        ssl_certificate_key /etc/nginx/cert/server.key;
        root /var/www/html;
        index index.nginx-debian.html;
        server_name _;
        location / {
            try_files $uri $uri/ =404;
        }
    }' > /etc/nginx/conf.d/s.conf

    mkdir /etc/nginx/cert; cd $_
    openssl req -x509 -nodes -days 3650 -newkey rsa:4096 -out server.crt -keyout server.key -subj "/CN=*"
    systemctl restart nginx.service
    ```
2. 方案一: 重定向 sshd 端口到 nginx
    ```bash
    cat << 'eee' >> /etc/nginx/nginx.conf
    stream {
        log_format stream '{"@access_time":"$time_iso8601","clientip":"$remote_addr",'
            '"ssl_pro": "$ssl_preread_protocol","up_addr":"$upstream_addr"}';
        access_log /var/log/nginx/stream.log stream;
        include /etc/nginx/stream.d/*.conf;
    }
    eee

    mkdir /etc/nginx/stream.d
    # 此处通过协议头识别 ssh 和 https ,也可以使用 ssl_preread_server_name 来通过域名识别
    cat << 'eee' > /etc/nginx/stream.d/ssh.conf
    map $ssl_preread_protocol $upstream {
        "" 127.0.0.1:22;
        # 此处是否为 TLSv1.3 因服务而异,可以查看日志 /var/log/nginx/stream.log
        "TLSv1.3" 127.0.0.1:3443;
        default 127.0.0.1:3443;
    }

    server {
        listen 443 reuseport;
        proxy_pass $upstream;
        ssl_preread on;
    }
    eee

    systemctl restart nginx.service
    ```
    用`ssh xx.xx.xx.xx -p 443`访问可打开shell,用浏览器访问`https://xx.xx.xx.xx`可打开网页
3. 方案二: 通过浏览器访问服务器终端.将 [ttyd](https://github.com/tsl0922/ttyd) 下载到 `/usr/local/bin` 然后编辑 `ttyd.service` 在 `127.0.0.1:8080` 提供服务
    ```ini
    # /usr/lib/systemd/system/ttyd.service
    [Unit]
    Description=TTYD
    After=syslog.target
    After=network.target

    [Service]
    ExecStart=/usr/local/bin/ttyd.x86_64 -Wp 8080 -i lo -- bash --login -i
    Type=simple
    Restart=always
    User=root

    [Install]
    WantedBy=multi-user.target
    ```
    Wiki 中有现成的[配置文件](https://github.com/tsl0922/ttyd/wiki/Nginx-reverse-proxy),改个端口就能用
    ```bash
    sed -i '$d' /etc/nginx/conf.d/s.conf
    echo '
        location ~ ^/ttyd(.*)$ {
            proxy_http_version 1.1;
            proxy_set_header Host $host;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
            proxy_pass http://127.0.0.1:8080/$1;
        }
    }' >> /etc/nginx/conf.d/s.conf
    systemctl restart nginx.service
    ```
    访问 `https://xx.xx.xx.xx/ttyd` 可以打开命令行终端
4. 方案三: `iptables` 拦截流量.在服务器上执行,将源端口为 `40404` 送往本机 `443` 端口的流量重定向到本机 `22` 端口
    ```bash
    iptables -t nat -A PREROUTING -p tcp --sport 40404 --dport 443 -j REDIRECT --to-port 22
    ```
    在客户端上设置 `socat` 代理,监听本地 `9999` 端口,转发流量从本地 `40404` 端口送往服务器的的 `443` 端口.这一步是为了确保源端口为 `40404`
    ```bash
    socat tcp-listen:9999,fork,reuseaddr tcp:xx.xx.xx.xx:443,sourceport=40404,reuseaddr
    ```
    测试连接
    ```bash
    ssh root@127.0.0.1 -p 9999
    ```
5. 方案三改: 在 tcp 数据包中增加关键字做为开关,以达到按时按需启用的目的.服务端执行
    ```bash
    iptables -t nat -N hetshaen
    iptables -t nat -A hetshaen -p tcp -j REDIRECT --to-port 22
    # 如果接收到的数据包含有字符串 MakkaPakka ,则将来源 ip 添加到 cowroar 表中
    iptables -A INPUT -p tcp --dport 443 -m string --string 'MakkaPakka' --algo bm -m recent --name cowroar --set --rsource -j ACCEPT
    # 如果接收到的数据包含有字符串 UpsyDaisy ,则将来源 ip 从 cowroar 表中移除
    iptables -A INPUT -p tcp --dport 443 -m string --string 'UpsyDaisy' --algo bm -m recent --name cowroar --remove -j ACCEPT
    # 如果来源 ip 在 cowroar 表中,则跳转到 hetshaen 链,有效期 3600 秒
    iptables -t nat -A PREROUTING -p tcp --sport 40404 --dport 443 --syn -m recent --rcheck --seconds 3600 --name cowroar --rsource -j hetshaen
    ```
    客户端执行
    ```bash
    # 开启复用
    echo MakkaPakka > /dev/tcp/xx.xx.xx.xx/443
    # 关闭复用
    echo UpsyDaisy > /dev/tcp/xx.xx.xx.xx/443
    ```
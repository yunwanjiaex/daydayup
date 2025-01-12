# nginx 负载均衡
### HTTP
```
http {
    upstream backend {
        server 192.168.11.1 max_fails=3 fail_timeout=10s;
        server 192.168.11.2 max_fails=3 fail_timeout=10s;
        server 192.168.11.3 backup;
    }
    server {
        location / {
            proxy_pass http://backend;
        }
    }
}
```
`11.1`和`11.2`参与负载均衡,都宕机则使用`11.3`
### TCP/UDP
```
stream {
    upstream dns_server {
        server 192.168.11.1:53;
        server 192.168.11.2:53;
    }
    server {
        listen 53 udp;
        proxy_pass dns_server;
    }
}
```
`stream` 块在主配置文件中,与 `http` 块并列.去掉 `udp` 字样即为 `tcp`
### A/B测试
```
http {
    split_clients "${remote_addr}" $variant {
        20%    https://sohu.com/;
        30%    https://163.com/;
        *      https://qq.com/;
    }

    server {
        listen 80;
        server_name _;
        return 302 ${variant};
    }
}
```
根据引号内的值返回页面,值不变则页面不变
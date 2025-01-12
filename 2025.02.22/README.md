# nginx 正反向代理
以 `rocky9` 系统为例,重新编译 nginx 添加 `ngx_http_proxy_connect_module` 模块以支持 https 正向代理
```bash
dnf groupinstall -y "Development Tools"
git clone https://github.com/chobits/ngx_http_proxy_connect_module.git
wget https://mirrors.ustc.edu.cn/rocky/9.5/AppStream/source/tree/Packages/n/nginx-1.20.1-20.el9.0.1.src.rpm

# 解压 srpm 并将模块源代码复制进去
rpm -ivh nginx-1.20.1-20.el9.0.1.src.rpm
cp -rf ngx_http_proxy_connect_module ngx_http_proxy_connect_module/patch/proxy_connect_rewrite_1018.patch rpmbuild/SOURCES
# 对 rpmbuild/SPECS/nginx.spec 打补丁
patch -p0 < new.patch
# 编译需要的依赖库
dnf install -y gd-devel libxslt-devel pcre-devel perl
rpmbuild -bb rpmbuild/SPECS/nginx.spec --target=x86_64
# 将编译好的 rpm 包拷贝到任意机器安装
dnf install $(find ~/rpmbuild/RPMS -name *.rpm)
```
正向代理,代理客户端去访问服务器
```
server {
    listen 9090;
    resolver 223.5.5.5;
    proxy_connect;
    proxy_connect_allow all;
    location / {
        proxy_pass $scheme://$http_host$request_uri;
    }
}
```
反向代理,代理服务器被客户端访问
```
server {
    listen 9090;
    server_name 192.168.xx.xx1;
    location / {
        proxy_pass $scheme://192.168.xx.xx2:8080;
    }
}
```
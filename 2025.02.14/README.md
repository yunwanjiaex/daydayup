# Linux 文件共享
### samba
1. 安装,以 rhel9 为例
    ```bash
    dnf install -y samba
    mv -fv /etc/samba/smb.conf{,.ori}
    mkdir /mnt/share
    chmod -R 777 $_
    ```
2. 有密码共享
    ```bash
    echo '[global]
    workgroup = SAMBA
    security = user
    passdb backend = tdbsam
    [share]
    comment = share folder
    path = /mnt/share
    valid users = tttt
    browseable = yes
    writeable = yes
    available = yes
    public = yes' > /etc/samba/smb.conf
    useradd -M -s /sbin/nologin tttt
    smbpasswd -a tttt
    ```
3. 匿名共享,以任意用户名访问
    ```bash
    echo '[global]
    workgroup = SAMBA
    security = user
    map to guest = bad user
    [share]
    comment = share folder
    path = /mnt/share
    browseable = yes
    writeable = yes
    available = yes
    public = yes
    guest ok = yes' > /etc/samba/smb.conf
    ```
4. 客户端登录
    ```bash
    dnf install -y cifs-utils
    mount -t cifs -o rw,username=xxxxxx,password=yyyyyyy //192.168.xx.xx/share /mnt/public
    ```
### nfs
1. 启用 nfsv4
    ```bash
    dnf install -y nfs-utils
    nfsconf --set nfsd vers3 n
    nfsconf --set nfsd vers4 y
    systemctl mask --now rpc-statd.service rpcbind.service rpcbind.socket
    systemctl enable --now nfs-server
    # 查看启用的版本
    cat /proc/fs/nfsd/versions
    ```
2. 共享 `/mnt/share` ,并允许 `192.168.42.0/24` 访问
    ```bash
    mkdir /mnt/share
    chmod -R 777 $_
    echo '/mnt/share 192.168.42.0/24(rw)' > /etc/exports.d/share.exports
    exportfs -av
    ```
3. 客户端挂载
    ```bash
    dnf install -y nfs-utils
    mount -t nfs 192.168.42.1:/mnt/share /mnt/public
    ```
### http
1. 安装 nginx: `dnf install nginx-all-modules`
2. 配置文件
    ```bash
    mkdir -p /file/{share,tmp}
    chmod -R 777 /file
    echo 'server {
        listen 80;
        server_name _;

        location / {
            root /file/share;
            client_body_temp_path /file/tmp;
            dav_methods PUT DELETE MKCOL COPY MOVE;
            create_full_put_path on;
            dav_access all:rw;
            client_body_in_file_only on;
            client_body_buffer_size 1M;
            client_max_body_size 0;
        }
    }' > /etc/nginx/conf.d/file.conf
    systemctl restart nginx
    ```
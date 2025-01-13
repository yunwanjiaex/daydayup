# NAT 打洞
1. 打洞前须确认当前网络的 NAT 类型,可以使用 [go-stun](https://github.com/ccding/go-stun) .如果一端是 `Full Cone NAT` 直连即可;如果一端是 `Restricted Cone NAT` 或两端均为 `Port Restricted Cone NAT` ,通过辅助服务器,最后也可以连接;其他情况理论无解,但是通过`预测端口+暴力并发`也存在连上的可能,只不过这种情况不在本篇的讨论之列
2. [n2n](https://github.com/ntop/n2n) 可以将两台内网机器A,B通过公网辅助机器C连接起来,如果A和B最终无法直连则所有流量从C中转
3. [pwnat](https://github.com/samyk/pwnat) 在无辅助服务器的情况下, `Full Cone NAT` 的内网机器A为不同内网的机器B提供代理服务,要求A的防火墙不能封 ICMP 数据包
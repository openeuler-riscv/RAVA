# 性能测试工具调研
- 环境：[qemu中的openEuler25.03-RISCV64](https://repo.openeuler.org/openEuler-25.03/virtual_machine_img/riscv64/)
- 所调研测试工具：netperf

## 2 netperf测试
> netperf是一种网络测试工具，以client/server方式工作。server端是netserver，用来侦听来自client端的连接，client端是netperf，用来向server发起网络测试。  
测试时需先使用netserver启动服务端进行监听，再在客户端使用netperf开启测试

下载安装netperf（版本为2.7.0）
```
dnf install -y netperf
```
netperf语法格式：
```
netperf [global options] -- [test options]
```
常用命令行参数如下，其余参数可通过netperf -h查看  
(1) global options:
|参数|说明|　
|---|---|
|-H host|指定远端运行netserver的server IP地址|
|-l testlen|指定测试的时间长度(秒)|
|-t testname|指定进行的测试类型(包括TCP_STREAM，UDP_STREAM，TCP_RR，TCP_CRR，UDP_RR)|
(2) test options:
|参数|说明|
|---|---|
|-s size|设置本地系统的socket发送与接收缓冲大小|
|-S size|设置远端系统的socket发送与接收缓冲大小|
|-p port|设置测试连接Server端的端口|
### 2.1 TCP测试
启动服务端，开放4444端口用于监听：
```
lyl@fedora:~$ netserver -p 4444
Starting netserver with host 'IN(6)ADDR_ANY' port '4444' and family AF_UNSPEC
```
客户端使用netperf，指定服务端IP和测试类型及测试时间
```
netperf -H 192.168.68.130 -t TCP_STREAM -l 30
```
测试正常，可以显示发送socket和接受socket的缓冲大小、向远端发送的测试分组大小、吞吐量等结果:
```
Recv   Send    Send                          
Socket Socket  Message  Elapsed              
Size   Size    Size     Time     Throughput  
bytes  bytes   bytes    secs.    10^6bits/sec  

131072  16384  16384    30.01     341.07  
```
### 2.2 UDP测试
测试时将-t参数改为UDP_STREAM后使用netperf报错：
```
[root@localhost ~]# netperf -H 192.168.68.130 -t UDP_STREAM -l 30 -- -m 2048
MIGRATED UDP STREAM TEST from 0.0.0.0 (0.0.0.0) port 0 AF_INET to 192.168.68.130 () port 0 AF_INET
send_data: data send error: Network is unreachable (errno 101)
netperf: send_omni: send_data failed: Network is unreachable
```
上网搜索找到错误原因：netperf在UDP_STREAM测试时，默认是禁止IP路由的，所以只能在同一个网段测试UDP_STREAM。此时我的客户端IP为10.0.2.15（qemu中），服务端IP为192.168.68.130，不在同一网段导致报错。如果要在不同网段测试UDP_STREAM，则要使用-R 1参数来启用路由：
```
netperf -H 192.168.68.130 -t UDP_STREAM -l 30 -- -m 2048 -R 1
```
最终测试正常，由于UDP是不可靠传输协议，测试结果分两行，第一行为本地发送数据，第二行为远端接受数据。（本次测试实际上服务端与客户端时连在一起的，导致数据看起来都被可靠的接受）
```
Socket  Message  Elapsed      Messages                
Size    Size     Time         Okay Errors   Throughput
bytes   bytes    secs            #      #   10^6bits/sec

212992    2048   30.00      227174      0     124.05
212992           30.00      227174            124.05
```
### 2.3 总结
netperf工具在openEuler25.03-RISCV64环境下可正常执行测试，执行UDP测试时需注意设置参数启用路由
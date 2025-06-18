# 性能测试工具调研
- 环境：[qemu中的openEuler25.03-RISCV64](https://repo.openeuler.org/openEuler-25.03/virtual_machine_img/riscv64/)
- 所调研测试工具：iperf3

## 3 iperf3测试
> iperf是基于TCP/IP和UDP/IP的网络性能测试工具，可以用来测量网络带宽和网络质量，提供网络延迟抖动、数据包丢失率、最大传输单元等统计信息。  
iperf工具以client/server方式工作，服务器端用于监听到达的测试请求，客户端用于发起测试连接会话

下载安装iperf3 (版本为3.18)
```
dnf install -y iperf3
```
常用命令行参数如下，其余参数可通过iperf3 -h查看:  
(1) 通用参数:
|参数|说明|　
|---|---|
|-p|指定服务器端监听的端口或客户端所连接的端口|
|-i|指定每次报告之间的时间间隔|
|-F|指定文件作为数据流进行带宽测试|  
(2) Server端参数:
|参数|说明|　
|---|---|
|-s|服务器模式，默认启动的监听端口为5201|
|-P|服务器关闭之前保持的连接数。默认是0，这意味着永远接受连接|  
(2) Client端参数:
|参数|说明|　
|---|---|
|-c host|iperf客户端模式，host是server端地址|
|-u|表示采用UDP协议发送报文，不带该参数表示采用TCP协议| 
|-b|指定UDP模式使用的带宽，单位bits/sec| 
|-P|指定客户端与服务端之间使用的线程数，需要客户端与服务器端同时使用此参数|
|-t|指定数据传输的总时间|
|-l|设置读写缓冲区的长度|

### 3.1 TCP测试
开启iperf3的Server端，报告时间间隔5秒，端口为520
```
sudo iperf3 -s -i 5 -p 520
```
开启iperf3的Client端，指定IP地址为Server端IP，端口一致，测试时间30秒
```
iperf3 -c 192.168.68.130 -i 5 -t 30 -p 520
```
测试结果正常，可看出数据传输大小，比特率:
```
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-5.01   sec   224 MBytes   376 Mbits/sec    0   67.0 KBytes       
[  5]   5.01-10.01  sec   242 MBytes   407 Mbits/sec    0   67.0 KBytes       
[  5]  10.01-15.00  sec   248 MBytes   417 Mbits/sec    0   67.0 KBytes       
[  5]  15.00-20.00  sec   256 MBytes   429 Mbits/sec    0   67.0 KBytes       
[  5]  20.00-25.01  sec   248 MBytes   416 Mbits/sec    0   67.0 KBytes       
[  5]  25.01-30.04  sec   249 MBytes   415 Mbits/sec    0   67.0 KBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-30.04  sec  1.44 GBytes   412 Mbits/sec    0            sender
[  5]   0.00-30.12  sec  1.44 GBytes   411 Mbits/sec                  receiver

iperf Done.
```
### 3.2 UDP测试
开启iperf3的Client端，-u选择UDP传输，-b设置带宽：
```
iperf3 -u -c 192.168.68.130 -b 100m -t 30 -p 520
```
测试正常：
- Jitter为抖动，在连续传输中的平滑平均值差
- Lost/Total Datagrams为丢包数量/总包数量
```
[ ID] Interval           Transfer     Bitrate         Total Datagrams
[  5]   0.00-5.00   sec  59.6 MBytes   100 Mbits/sec  42836  
[  5]   5.00-10.00  sec  59.6 MBytes   100 Mbits/sec  42800  
[  5]  10.00-15.01  sec  59.7 MBytes   100 Mbits/sec  42846  
[  5]  15.01-20.01  sec  59.6 MBytes   100 Mbits/sec  42796  
[  5]  20.01-25.00  sec  59.6 MBytes   100 Mbits/sec  42791  
[  5]  25.00-30.04  sec  59.6 MBytes  99.3 Mbits/sec  42819  
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
[  5]   0.00-30.04  sec   358 MBytes  99.9 Mbits/sec  0.000 ms  0/256888 (0%)  sender
[  5]   0.00-30.05  sec   358 MBytes  99.9 Mbits/sec  0.051 ms  0/256888 (0%)  receiver

iperf Done.
```
### 3.3 总结
iperf3工具在openEuler25.03-RISCV64环境下可正常执行测试，TCP和UDP网络测试均正常。
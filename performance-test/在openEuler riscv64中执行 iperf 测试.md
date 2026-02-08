## 在openEuler riscv64中执行 iperf 测试

### 1. iperf 介绍

`iperf` 是一个专业的网络性能测试工具，用于测量 TCP 和 UDP 带宽性能。

**功能概述**

- 测量最大 TCP 带宽
- 报告 UDP 带宽、延迟抖动和数据包丢失
- 支持 IPv4 和 IPv6
- 多线程支持
- 可调节各种参数

**版本说明**

iperf 有2个主要版本：

- iperf：版本 2.x（经典版本）
- iperf3  # 版本 3.x（重写版本，不兼容 v2）

主要区别：

- iperf3: 更简洁，单线程设计
- iperf2: 功能更丰富，多线程支持更好

### 2. 安装

iperf 测试需要2台设备，一台作为 server（接收端），另一台作为 client（发送端）

在两台安装了 openEuler RISC-V 操作系统的设备里分别安装 iperf

````
$ yum install -y iperf3
````

执行 help 命令，查看 iperf 命令的参数

````
$ iperf3 -h
Usage: iperf3 [-s|-c host] [options]
       iperf3 [-h|--help] [-v|--version]

Server or Client:
  -p, --port      #         server port to listen on/connect to
  -f, --format   [kmgtKMGT] format to report: Kbits, Mbits, Gbits, Tbits
  -i, --interval  #         seconds between periodic throughput reports
  -I, --pidfile file        write PID file
  -F, --file name           xmit/recv the specified file
  -A, --affinity n[,m]      set CPU affinity core number to n (the core the process will use)
                             (optional Client only m - the Server's core number for this test)
  -B, --bind <host>[%<dev>] bind to the interface associated with the address <host>
                            (optional <dev> equivalent to `--bind-dev <dev>`)
  --bind-dev <dev>          bind to the network interface with SO_BINDTODEVICE
  -V, --verbose             more detailed output
  -J, --json                output in JSON format
  --json-stream             output in line-delimited JSON format
  --logfile f               send output to a log file
  --forceflush              force flushing output at every interval
  --timestamps<=format>     emit a timestamp at the start of each output line
                            (optional "=" and format string as per strftime(3))
  --rcv-timeout #           idle timeout for receiving data (default 120000 ms)
  --snd-timeout #           timeout for unacknowledged TCP data
                            (in ms, default is system settings)
  -d, --debug[=#]           emit debugging output
                            (optional optional "=" and debug level: 1-4. Default is 4 - all messages)
  -v, --version             show version information and quit
  -h, --help                show this message and quit
Server specific:
  -s, --server              run in server mode
  -D, --daemon              run the server as a daemon
  -1, --one-off             handle one client connection then exit
  --server-bitrate-limit #[KMG][/#]   server's total bit rate limit (default 0 = no limit)
                            (optional slash and number of secs interval for averaging
                            total data rate.  Default is 5 seconds)
  --idle-timeout #          restart idle server after # seconds in case it
                            got stuck (default - no timeout)
Client specific:
  -c, --client <host>[%<dev>] run in client mode, connecting to <host>
                              (option <dev> equivalent to `--bind-dev <dev>`)
  --sctp                    use SCTP rather than TCP
  -X, --xbind <name>        bind SCTP association to links
  --nstreams      #         number of SCTP streams
  -u, --udp                 use UDP rather than TCP
  --connect-timeout #       timeout for control connection setup (ms)
  -b, --bitrate #[KMG][/#]  target bitrate in bits/sec (0 for unlimited)
                            (default 1 Mbit/sec for UDP, unlimited for TCP)
                            (optional slash and packet count for burst mode)
  --pacing-timer #[KMG]     set the Server timing for pacing, in microseconds (default 1000)
                            (deprecated - for servers using older versions ackward compatibility)
  --fq-rate #[KMG]          enable fair-queuing based socket pacing in
                            bits/sec (Linux only)
  -t, --time      #         time in seconds to transmit for (default 10 secs)
  -n, --bytes     #[KMG]    number of bytes to transmit (instead of -t)
  -k, --blockcount #[KMG]   number of blocks (packets) to transmit (instead of -t or -n)
  -l, --length    #[KMG]    length of buffer to read or write
                            (default 128 KB for TCP, dynamic or 1460 for UDP)
  --cport         <port>    bind to a specific client port (TCP and UDP, default: ephemeral port)
  -P, --parallel  #         number of parallel client streams to run
  -R, --reverse             run in reverse mode (server sends, client receives)
  --bidir                   run in bidirectional mode.
                            Client and server send and receive data.
  -w, --window    #[KMG]    set send/receive socket buffer sizes
                            (indirectly sets TCP window size)
  -C, --congestion <algo>   set TCP congestion control algorithm (Linux and FreeBSD only)
  -M, --set-mss   #         set TCP/SCTP maximum segment size (MTU - 40 bytes)
  -N, --no-delay            set TCP/SCTP no delay, disabling Nagle's Algorithm
  -4, --version4            only use IPv4
  -6, --version6            only use IPv6
  -S, --tos N               set the IP type of service, 0-255.
                            The usual prefixes for octal and hex can be used,
                            i.e. 52, 064 and 0x34 all specify the same value.
  --dscp N or --dscp val    set the IP dscp value, either 0-63 or symbolic.
                            Numeric values can be specified in decimal,
                            octal and hex (see --tos above).
  -L, --flowlabel N         set the IPv6 flow label (only supported on Linux)
  -Z, --zerocopy            use a 'zero copy' method of sending data
  -O, --omit N              perform pre-test for N seconds and omit the pre-test statistics
  -T, --title str           prefix every output line with this string
  --extra-data str          data string to include in client and server JSON
  --get-server-output       get results from server
  --udp-counters-64bit      use 64-bit counters in UDP test packets
  --repeating-payload       use repeating pattern in payload, instead of
                            randomized payload (like in iperf2)
  --dont-fragment           set IPv4 Don't Fragment flag

[KMG] indicates options that support a K/M/G suffix for kilo-, mega-, or giga-

iperf3 homepage at: https://software.es.net/iperf/
Report bugs to:     https://github.com/esnet/iperf
````

一、通用参数（Server or Client）

基本参数

- **-p, --port #**：指定服务器监听/连接的端口号

  ````
  $ iperf3 -s -p 5201          # 服务器监听5201端口
  $ iperf3 -c server -p 5201   # 客户端连接5201端口
  ````

- **-f, --format [kmgtKMGT]**：报告格式

  ````
  $ iperf3 -c server -f M      # 以Mbits/s显示
  # k=Kbits, m=Mbits, g=Gbits, t=Tbits（小写表示bit/s）
  # K=KBytes, M=MBytes, G=GBytes, T=TBytes（大写表示Byte/s）
  ````

- **-i, --interval #**：定期吞吐量报告间隔（秒）

  ````
  $ iperf3 -c server -i 2      # 每2秒输出一次报告
  ````

文件和进程管理

- **-I, --pidfile file**：将进程ID写入指定文件

  ````
  $ iperf3 -s -I /var/run/iperf3.pid
  ````

- **-F, --file name**：发送/接收指定文件（而不是随机数据）

  ````
  $ iperf3 -c server -F data.bin  # 发送data.bin文件
  $ iperf3 -s -F received.bin     # 接收数据保存到received.bin
  ````

CPU和网络绑定

- **-A, --affinity n[,m]**：设置CPU亲和性

  ````
  $ iperf3 -c server -A 0         # 客户端使用CPU核心0
  $ iperf3 -c server -A 0,1       # 客户端核心0，服务器核心1
  ````

- **-B, --bind <host>[%<dev>]**：绑定到指定IP地址的接口

  ````
  $ iperf3 -c server -B 192.168.1.10    # 绑定到指定IP
  $ iperf3 -c server -B 192.168.1.10%eth0  # 绑定到IP和接口
  ````

- **--bind-dev <dev>**：绑定到指定网络接口

  ````
  $ iperf3 -c server --bind-dev eth0
  ````

输出控制

- **-V, --verbose**：显示更详细的输出

- **-J, --json**：以JSON格式输出结果

  ````
  $ iperf3 -c server -J > result.json
  ````

- **--json-stream**：输出行分隔的JSON格式（适合流式处理）

- **--logfile f**：将输出发送到日志文件

- **--forceflush**：每个间隔强制刷新输出

- **--timestamps<=format>**：为每行输出添加时间戳

  ````
  $ iperf3 -c server --timestamps
  $ iperf3 -c server --timestamps="%H:%M:%S"
  ````

超时设置

- **--rcv-timeout #**：接收数据空闲超时（默认120000ms）
- **--snd-timeout #**：未确认TCP数据超时（默认使用系统设置）

调试信息

- **-d, --debug[=#]**：输出调试信息（1-4级，4级最详细）

  ````
  $ iperf3 -c server -d        # 输出所有调试信息
  $ iperf3 -c server -d=2      # 输出级别2的调试信息
  ````

- **-v, --version**：显示版本信息

- **-h, --help**：显示帮助信息

二、服务器特定参数

运行模式

- **-s, --server**：以服务器模式运行

- **-D, --daemon**：以守护进程模式运行服务器

  ````
  $ iperf3 -s -D              # 后台运行iperf服务器
  ````

- **-1, --one-off**：处理一个客户端连接后退出

服务器限制

- **--server-bitrate-limit #[KMG][/#]**：服务器总比特率限制

  ````
  $ iperf3 -s --server-bitrate-limit 100M  # 限制100Mbps
  $ iperf3 -s --server-bitrate-limit 100M/10 # 100Mbps，10秒平均
  ````

- **--idle-timeout #**：服务器空闲超时后重启（秒）

三、客户端特定参数

连接设置

- **-c, --client <host>[%<dev>]**：以客户端模式运行，连接到指定主机

  ````
  $ iperf3 -c 192.168.1.100
  $ iperf3 -c server%eth0
  ````

传输协议

- **--sctp**：使用SCTP而不是TCP
- **-X, --xbind <name>**：绑定SCTP关联到链接
- **--nstreams #**：SCTP流数量
- **-u, --udp**：使用UDP而不是TCP

连接超时

- **--connect-timeout #**：控制连接设置超时（毫秒）

带宽控制

- **-b, --bitrate #[KMG][/#]**：目标比特率（UDP默认1Mbps，TCP无限制）

  ````
  $ iperf3 -c server -b 100M      # 100Mbps
  $ iperf3 -c server -u -b 10M    # UDP，10Mbps
  $ iperf3 -c server -b 100M/100  # 100Mbps，每100个数据包突发
  ````

- **--pacing-timer #[KMG]**：设置服务器节奏定时器（微秒）

- **--fq-rate #[KMG]**：启用公平排队基于套接字的节奏（仅Linux）

测试时长和数据量

- **-t, --time #**：传输时间（秒，默认10秒）

  ````
  $ iperf3 -c server -t 60        # 测试60秒
  ````

- **-n, --bytes #[KMG]**：传输字节数（替代-t）

  ````
  $ iperf3 -c server -n 100M      # 传输100MB数据
  ````

- **-k, --blockcount #[KMG]**：传输块（数据包）数量

- **-l, --length #[KMG]**：读写缓冲区长度

  ````
  $ iperf3 -c server -l 1460      # TCP MSS大小
  $ iperf3 -c server -u -l 1470   # UDP包大小（包括IP头）
  ````

端口和并行

- **--cport <port>**：绑定到特定客户端端口

  ````
  $ iperf3 -c server --cport 50000
  ````

- **-P, --parallel #**：并行客户端流数量

  ````
  $ iperf3 -c server -P 4         # 使用4个并行连接
  ````

测试方向

- **-R, --reverse**：反向模式（服务器发送，客户端接收）
- **--bidir**：双向模式（客户端和服务器都发送和接收数据）

TCP优化

- **-w, --window #[KMG]**：设置发送/接收套接字缓冲区大小（间接设置TCP窗口大小）

  ````
  $ iperf3 -c server -w 2M        # 设置2MB的TCP窗口
  ````

- **-C, --congestion <algo>**：设置TCP拥塞控制算法（仅Linux和FreeBSD）

  ````
  $ iperf3 -c server -C cubic      # 使用cubic算法
  ````

- **-M, --set-mss #**：设置TCP/SCTP最大段大小（MTU - 40字节）

- **-N, --no-delay**：设置TCP/SCTP无延迟，禁用Nagle算法

网络协议

- **-4, --version4**：仅使用IPv4
- **-6, --version6**：仅使用IPv6
- **-S, --tos N**：设置IP服务类型（0-255）
- **--dscp N or --dscp val**：设置IP DSCP值（0-63或符号）
- **-L, --flowlabel N**：设置IPv6流标签（仅Linux支持）

高级特性

- **-Z, --zerocopy**：使用"零拷贝"方法发送数据

- **-O, --omit N**：执行N秒的预测试并省略预测试统计

  `````
  $ iperf3 -c server -O 2        # 忽略前2秒的数据
  `````

- **-T, --title str**：为每行输出添加前缀字符串

- **--extra-data str**：包含在客户端和服务器JSON中的数据字符串

- **--get-server-output**：从服务器获取结果

- **--udp-counters-64bit**：在UDP测试包中使用64位计数器

- **--repeating-payload**：使用重复模式的有效负载（类似iperf2）

- **--dont-fragment**：设置IPv4不分片标志

 ### 3. 执行测试

两台设备需要在同一网络，可以相互 ping 通

#### 3.1 server 端

关闭 server 端防火墙

````
$ systemctl stop firewalld
$ systemctl status firewalld
````

在 server 端执行 iperf 命令，开启服务端模式，默认端口 5201

````
$ iperf3 -s
-----------------------------------------------------------
Server listening on 5201 (test #1)
-----------------------------------------------------------
````

#### 3.2 client 端

在 client 端执行 iperf 命令，执行压力测试

````
$ iperf3 -c 10.0.0.2 -t 30 -P 1
$ iperf3 -c 10.0.0.2 -t 30 -P 2
````

-c 10.0.0.2：客户端模式，连接到服务器 10.0.0.2（必须提前在 10.0.0.2 上运行 `iperf3 -s`）

-t 30：测试持续 30s（默认10s）

-P 1：使用 1 个并行连接（单线程）（`-P` 指定并行流数量）

-P 2：使用 2 个并行连接（双线程）（创建两个并行TCP流）

#### 3.3 测试结果

##### 3.3.1 单线程测试结果

````
$ iperf3 -c 10.0.0.2 -t 30 -P 1
Connecting to host 10.0.0.2, port 5201
[  5] local 10.0.0.3 port 60882 connected to 10.0.0.2 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   116 MBytes   968 Mbits/sec    0    785 KBytes       
[  5]   1.00-2.00   sec   114 MBytes   957 Mbits/sec    0    785 KBytes       
[  5]   2.00-3.00   sec   113 MBytes   950 Mbits/sec    0    785 KBytes       
[  5]   3.00-4.00   sec   123 MBytes  1.03 Gbits/sec    0    785 KBytes       
[  5]   4.00-5.00   sec   120 MBytes  1.01 Gbits/sec    0    824 KBytes       
[  5]   5.00-6.00   sec   122 MBytes  1.02 Gbits/sec    0    909 KBytes       
[  5]   6.00-7.00   sec   122 MBytes  1.03 Gbits/sec    0    909 KBytes       
[  5]   7.00-8.00   sec   126 MBytes  1.06 Gbits/sec    0    954 KBytes       
[  5]   8.00-9.00   sec   120 MBytes  1.00 Gbits/sec    0   1.05 MBytes       
[  5]   9.00-10.00  sec   105 MBytes   882 Mbits/sec    0   1.10 MBytes       
[  5]  10.00-11.00  sec   119 MBytes   997 Mbits/sec    0   1.10 MBytes       
[  5]  11.00-12.00  sec   130 MBytes  1.09 Gbits/sec    0   1.10 MBytes       
[  5]  12.00-13.00  sec   126 MBytes  1.05 Gbits/sec    0   1.10 MBytes       
[  5]  13.00-14.00  sec   124 MBytes  1.04 Gbits/sec    0   1.10 MBytes       
[  5]  14.00-15.00  sec   124 MBytes  1.04 Gbits/sec    0   1.10 MBytes       
[  5]  15.00-16.00  sec   128 MBytes  1.07 Gbits/sec    0   1.66 MBytes       
[  5]  16.00-17.00  sec   123 MBytes  1.03 Gbits/sec    0   1.66 MBytes       
[  5]  17.00-18.00  sec   130 MBytes  1.09 Gbits/sec    0   1.66 MBytes       
[  5]  18.00-19.00  sec   126 MBytes  1.06 Gbits/sec    0   1.66 MBytes       
[  5]  19.00-20.00  sec   129 MBytes  1.08 Gbits/sec    0   1.66 MBytes       
[  5]  20.00-21.00  sec   133 MBytes  1.11 Gbits/sec    0   1.66 MBytes       
[  5]  21.00-22.00  sec   124 MBytes  1.04 Gbits/sec    0   1.66 MBytes       
[  5]  22.00-23.00  sec   130 MBytes  1.09 Gbits/sec    0   1.66 MBytes       
[  5]  23.00-24.00  sec   131 MBytes  1.10 Gbits/sec    0   1.66 MBytes       
[  5]  24.00-25.00  sec   123 MBytes  1.03 Gbits/sec    0   1.66 MBytes       
[  5]  25.00-26.00  sec   118 MBytes   988 Mbits/sec    0   1.66 MBytes       
[  5]  26.00-27.00  sec   134 MBytes  1.12 Gbits/sec    0   1.66 MBytes       
[  5]  27.00-28.00  sec   125 MBytes  1.05 Gbits/sec    0   1.66 MBytes       
[  5]  28.00-29.00  sec   133 MBytes  1.11 Gbits/sec    0   1.66 MBytes       
[  5]  29.00-30.01  sec   115 MBytes   958 Mbits/sec    0   1.66 MBytes       
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-30.01  sec  3.71 GBytes  1.06 Gbits/sec    0            sender
[  5]   0.00-30.02  sec  3.71 GBytes  1.06 Gbits/sec                  receiver
````

基本信息：

- **客户端IP**: 10.0.0.3 (端口: 60882)
- **服务器IP**: 10.0.0.2 (端口: 5201)
- **测试模式**: 客户端发送（上传）到服务器
- **连接数**: 1个TCP连接 (`-P 1`)
- **测试时长**: 30秒 (`-t 30`)

总体性能

````
# 最终汇总结果
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-30.01  sec  3.71 GBytes  1.06 Gbits/sec    0            sender
[  5]   0.00-30.02  sec  3.71 GBytes  1.06 Gbits/sec                  receiver
````

- **总传输量**: 3.71 GBytes
- **平均带宽**: 1.06 Gbits/sec
- **重传次数**: 0次（网络质量优秀）
- **两端一致**: 发送方和接收方数据完全匹配

拥塞窗口 (Cwnd) 演化

````
时间点        拥塞窗口变化       说明
0-7秒         785KB → 909KB      缓慢增长阶段
7-9秒         909KB → 1.05MB     加速增长
9-15秒        1.10MB → 1.66MB    达到稳定窗口大小
15-30秒       1.66MB             保持稳定
````

TCP 性能分析

```
总带宽: 1.06 Gbps
峰值带宽: 1.12 Gbps (第26-27秒)
谷值带宽: 882 Mbps (第9-10秒)
波动率: (1.12-0.882)/1.06 ≈ 22.5%
```

网络质量评估

- **零重传**: `Retr=0` 表示网络质量极佳，无丢包
- **稳定拥塞窗口**: 最终稳定在1.66MB，TCP连接已充分探测到网络容量
- **对称性**: 发送方和接收方速率完全一致，说明接收方处理能力足够

##### 3.3.2 双线程测试结果

````
$ iperf3 -c 10.0.0.2 -t 10 -P 2
Connecting to host 10.0.0.2, port 5201
[  5] local 10.0.0.3 port 45388 connected to 10.0.0.2 port 5201
[  7] local 10.0.0.3 port 45404 connected to 10.0.0.2 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec  56.2 MBytes   471 Mbits/sec    0   2.67 MBytes       
[  7]   0.00-1.00   sec   106 MBytes   884 Mbits/sec    0   3.96 MBytes       
[SUM]   0.00-1.00   sec   162 MBytes  1.36 Gbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   1.00-2.01   sec  96.2 MBytes   804 Mbits/sec    0   4.07 MBytes       
[  7]   1.00-2.01   sec  93.6 MBytes   782 Mbits/sec    0   3.96 MBytes       
[SUM]   1.00-2.01   sec   190 MBytes  1.59 Gbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   2.01-3.01   sec  97.4 MBytes   817 Mbits/sec    0   4.07 MBytes       
[  7]   2.01-3.01   sec  95.9 MBytes   804 Mbits/sec    0   3.96 MBytes       
[SUM]   2.01-3.01   sec   193 MBytes  1.62 Gbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   3.01-4.00   sec  96.8 MBytes   815 Mbits/sec    0   4.07 MBytes       
[  7]   3.01-4.06   sec   104 MBytes   825 Mbits/sec    0   3.96 MBytes       
[SUM]   3.01-4.00   sec   200 MBytes  1.69 Gbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   4.00-5.00   sec  93.1 MBytes   781 Mbits/sec    0   4.07 MBytes       
[  7]   4.06-5.01   sec  89.4 MBytes   787 Mbits/sec    0   3.96 MBytes       
[SUM]   4.00-5.00   sec   182 MBytes  1.53 Gbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   5.00-6.01   sec  97.0 MBytes   811 Mbits/sec    0   4.07 MBytes       
[  7]   5.01-6.01   sec  96.5 MBytes   813 Mbits/sec    0   3.96 MBytes       
[SUM]   5.00-6.01   sec   194 MBytes  1.62 Gbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   6.01-7.01   sec  98.0 MBytes   822 Mbits/sec    0   4.07 MBytes       
[  7]   6.01-7.01   sec  96.0 MBytes   805 Mbits/sec    0   3.96 MBytes       
[SUM]   6.01-7.01   sec   194 MBytes  1.63 Gbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   7.01-8.01   sec  96.1 MBytes   806 Mbits/sec    0   4.07 MBytes       
[  7]   7.01-8.02   sec  94.5 MBytes   784 Mbits/sec    0   3.96 MBytes       
[SUM]   7.01-8.01   sec   191 MBytes  1.60 Gbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   8.01-9.01   sec  97.1 MBytes   815 Mbits/sec    0   4.07 MBytes       
[  7]   8.02-9.01   sec  97.1 MBytes   824 Mbits/sec    0   3.96 MBytes       
[SUM]   8.01-9.01   sec   194 MBytes  1.63 Gbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   9.01-10.01  sec  96.8 MBytes   805 Mbits/sec    0   4.07 MBytes       
[  7]   9.01-10.01  sec  97.4 MBytes   810 Mbits/sec    0   3.96 MBytes       
[SUM]   9.01-10.01  sec   194 MBytes  1.62 Gbits/sec    0             
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.01  sec   934 MBytes   782 Mbits/sec    0            sender
[  5]   0.00-10.03  sec   934 MBytes   781 Mbits/sec                  receiver
[  7]   0.00-10.01  sec   975 MBytes   817 Mbits/sec    0            sender
[  7]   0.00-10.03  sec   975 MBytes   815 Mbits/sec                  receiver
[SUM]   0.00-10.01  sec  1.86 GBytes  1.60 Gbits/sec    0             sender
[SUM]   0.00-10.03  sec  1.86 GBytes  1.60 Gbits/sec                  receiver

iperf Done.
````

各字段含义

- **[ID]**：连接ID（5和7代表两个并行流）

- **Interval**：时间间隔（0.00-1.00秒）

- **Transfer**：该时间段传输的数据量

- **Bitrate**：该时间段的平均带宽

- **Retr**：TCP重传次数（0表示无丢包）

- **Cwnd**：拥塞窗口大小（TCP流量控制）
- **[SUM]**：两个流的总和统计，用于查看总体带宽利用率

基本信息

- **客户端IP**: 10.0.0.3 (端口: 45388, 45404)
- **服务器IP**: 10.0.0.2 (端口: 5201)
- **测试模式**: 客户端发送（上传）到服务器
- **连接数**: 2个并行TCP连接 (`-P 2`)
- **测试时长**: 10秒 (`-t 10`)

总体性能

````
最终汇总结果：
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.01  sec   934 MBytes   782 Mbits/sec    0            sender             # 连接5
[  5]   0.00-10.03  sec   934 MBytes   781 Mbits/sec                  receiver          # 连接5
[  7]   0.00-10.01  sec   975 MBytes   817 Mbits/sec    0            sender             # 连接7
[  7]   0.00-10.03  sec   975 MBytes   815 Mbits/sec                  receiver          # 连接7
[SUM]   0.00-10.01  sec  1.86 GBytes  1.60 Gbits/sec    0             sender            # 总计
[SUM]   0.00-10.03  sec  1.86 GBytes  1.60 Gbits/sec                  receiver          # 总计
````

- **总传输量**: 1.86 GBytes
- **平均总带宽**: 1.60 Gbits/sec
- **单个连接带宽**: 连接5: 782 Mbps, 连接7: 817 Mbps
- **重传次数**: 0次（网络质量优秀）

拥塞窗口分析

````
连接5拥塞窗口: 2.67MB → 4.07MB (稳定)
连接7拥塞窗口: 3.96MB → 4.07MB (稳定)
````


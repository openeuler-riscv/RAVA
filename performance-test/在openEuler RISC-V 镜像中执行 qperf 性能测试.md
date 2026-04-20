## 在openEuler RISC-V 镜像中执行 qperf 性能测试

### 1. qperf  介绍

qperf是一款用于测量两个节点间网络性能的命令行工具，常用于评估带宽、延迟以及CPU使用率。它的主要优势在于支持RDMA（远程直接内存访问）和传统的TCP/IP协议栈。

在 Linux 网络性能测试领域，qperf 和 iPerf 是最常用的两款工具，它们的主要区别如下：

| 特性       | qperf                                   | iPerf                            |
| :--------- | :-------------------------------------- | :------------------------------- |
| 核心功能   | 带宽 (Bandwidth) 和 延迟 (Latency) 测量 | 专注于带宽 (Bandwidth) 测量      |
| 协议支持   | TCP/UDP 和 RDMA (如 InfiniBand)         | 主要支持 TCP/UDP                 |
| 主要优势   | 支持 RDMA，能测试 RDMA 网络的带宽和延迟 | 功能通用，用户群体庞大，资料丰富 |
| 测试输出   | 带宽、延迟、CPU 使用率等                | 带宽、抖动、丢包率等             |
| 自动化集成 | 命令简洁，输出结构化，易于脚本解析      | 输出信息丰富，但解析相对复杂     |

简单来说：如果测试场景涉及 InfiniBand 或 RDMA 网络，qperf 是不可或缺的。对于常见的 TCP/IP 网络性能基准测试，两者都能胜任，但 qperf 因其对 RDMA 的支持和简洁的输出，在特定场景和自动化集成中更胜一筹。

### 2. qperf 测试

#### 2.1 执行测试

qperf 的使用模式与 iPerf 类似，也分为服务端（`server`）和客户端（`client`）

在测试双方主机上安装 qperf：

````
$ yum install -y qperf
````

qperf 命令行定义

````
$ qperf --help
Synopsis
    qperf 
    qperf SERVERNODE [OPTIONS] TESTS

Description
    qperf measures bandwidth and latency between two nodes.  It can work
    over TCP/IP as well as the RDMA transports.  On one of the nodes, qperf
    is typically run with no arguments designating it the server node.  One
    may then run qperf on a client node to obtain measurements such as
    bandwidth, latency and cpu utilization.

    In its most basic form, qperf is run on one node in server mode by
    invoking it with no arguments.  On the other node, it is run with two
    arguments: the name of the server node followed by the name of the
    test.  A list of tests can be found in the section, TESTS.  A variety
    of options may also be specified.

    One can get more detailed information on qperf by using the --help
    option.  Below are examples of using the --help option:

        qperf --help examples       Some examples of using qperf
        qperf --help opts           Summary of options
        qperf --help options        Description of options
        qperf --help tests          Short summary and description of tests
        qperf --help TESTNAME       More information on test TESTNAME
````

基本语法

```
qperf                              # 在服务端运行（无参数）
qperf SERVERNODE [OPTIONS] TESTS   # 在客户端运行，连接 SERVERNODE 并执行指定的 TESTS
```

工作模式

- **服务端**：直接执行 `qperf`（不加任何参数），它会在后台监听默认端口（19765），等待客户端连接。
- **客户端**：运行 `qperf <服务端主机名> [选项] <测试项>`，发起测试并输出结果。

核心能力

- 可测量 **带宽**、**延迟** 和 **CPU 使用率**。
- 支持 **TCP/IP** 以及 **RDMA** 传输（InfiniBand、RoCE、iWARP 等）。

获取更详细帮助的方法

| 命令                    | 作用                                        |
| :---------------------- | :------------------------------------------ |
| `qperf --help examples` | 查看典型使用示例（你之前问过的）            |
| `qperf --help opts`     | 查看选项的简短摘要                          |
| `qperf --help options`  | 查看所有选项的详细描述                      |
| `qperf --help tests`    | 查看所有测试项的简短摘要（你之前也问过）    |
| `qperf --help TESTNAME` | 查看某个具体测试项（如 `tcp_bw`）的详细说明 |

列出 qperf 支持的所有测试类型

````
$ qperf --help tests
Miscellaneous
    conf                    Show configuration
    quit                    Cause the server to quit
Socket Based
    rds_bw                  RDS streaming one way bandwidth
    rds_lat                 RDS one way latency
    sctp_bw                 SCTP streaming one way bandwidth
    sctp_lat                SCTP one way latency
    sdp_bw                  SDP streaming one way bandwidth
    sdp_lat                 SDP one way latency
    tcp_bw                  TCP streaming one way bandwidth
    tcp_lat                 TCP one way latency
    udp_bw                  UDP streaming one way bandwidth
    udp_lat                 UDP one way latency
RDMA Send/Receive
    rc_bi_bw                RC streaming two way bandwidth
    rc_bw                   RC streaming one way bandwidth
    rc_lat                  RC one way latency
    uc_bi_bw                UC streaming two way bandwidth
    uc_bw                   UC streaming one way bandwidth
    uc_lat                  UC one way latency
    ud_bi_bw                UD streaming two way bandwidth
    ud_bw                   UD streaming one way bandwidth
    ud_lat                  UD one way latency
    xrc_bi_bw               XRC streaming two way bandwidth
    xrc_bw                  XRC streaming one way bandwidth
    xrc_lat                 XRC one way latency
RDMA
    rc_rdma_read_bw         RC RDMA read streaming one way bandwidth
    rc_rdma_read_lat        RC RDMA read one way latency
    rc_rdma_write_bw        RC RDMA write streaming one way bandwidth
    rc_rdma_write_lat       RC RDMA write one way latency
    rc_rdma_write_poll_lat  RC RDMA write one way polling latency
    uc_rdma_write_bw        UC RDMA write streaming one way bandwidth
    uc_rdma_write_lat       UC RDMA write one way latency
    uc_rdma_write_poll_lat  UC RDMA write one way polling latency
InfiniBand Atomics
    rc_compare_swap_mr      RC compare and swap messaging rate
    rc_fetch_add_mr         RC fetch and add messaging rate
Verification
    ver_rc_compare_swap     Verify RC compare and swap
    ver_rc_fetch_add        Verify RC fetch and add
````

**1）Miscellaneous（杂项）**

| 测试项 | 说明                                                        |
| :----- | :---------------------------------------------------------- |
| `conf` | 显示 `qperf` 服务器的配置信息（如支持的传输方式、版本等）。 |
| `quit` | 发送命令让远程的 `qperf` 服务器进程退出。                   |

**2）Socket Based（基于传统 Socket 的协议）**

这些测试使用标准的 BSD Socket API，不依赖 RDMA。

| 测试项                 | 说明                                                         |
| :--------------------- | :----------------------------------------------------------- |
| `rds_bw` / `rds_lat`   | **RDS** (Reliable Datagram Sockets) 协议的带宽 / 单向延迟测试。RDS 常用于 InfiniBand 上的高性能、可靠数据报通信。 |
| `sctp_bw` / `sctp_lat` | **SCTP** (Stream Control Transmission Protocol) 的带宽 / 单向延迟测试。SCTP 提供多流、多宿等特性。 |
| `sdp_bw` / `sdp_lat`   | **SDP** (Sockets Direct Protocol) 的带宽 / 单向延迟测试。SDP 允许传统 Socket 程序透明地使用 RDMA。 |
| `tcp_bw` / `tcp_lat`   | **TCP** 的带宽 / 单向延迟测试。最常用的测试，测量可靠的字节流性能。 |
| `udp_bw` / `udp_lat`   | **UDP** 的带宽 / 单向延迟测试。测量不可靠数据报的性能，可反映网络抖动和丢包影响。 |

**3）RDMA Send/Receive（RDMA 发送/接收操作）**

这类测试使用 RDMA 的 **发送/接收** 原语（而非 RDMA Read/Write）。数据从发送方主动 `send`，接收方预先发布 `receive` 缓冲区。

| 测试项               | 说明                                                         |
| :------------------- | :----------------------------------------------------------- |
| `rc_bi_bw`           | **RC** (Reliable Connected) 传输服务的 **双向带宽**。两端同时发送数据，测试总吞吐量。 |
| `rc_bw`              | RC 服务的 **单向带宽**（一端发、一端收）。                   |
| `rc_lat`             | RC 服务的 **单向延迟**（发送一个小消息，接收方回复确认，测量往返时间）。 |
| `uc_bi_bw`           | **UC** (Unreliable Connected) 服务的双向带宽。UC 不保证可靠传输，但开销更低。 |
| `uc_bw` / `uc_lat`   | UC 服务的单向带宽 / 延迟。                                   |
| `ud_bi_bw`           | **UD** (Unreliable Datagram) 服务的双向带宽。UD 类似 UDP，支持多播，但每个数据报有最大长度限制。 |
| `ud_bw` / `ud_lat`   | UD 服务的单向带宽 / 延迟。                                   |
| `xrc_bi_bw`          | **XRC** (eXtended Reliable Connected) 服务的双向带宽。XRC 用于大规模集群中减少连接开销。 |
| `xrc_bw` / `xrc_lat` | XRC 服务的单向带宽 / 延迟。                                  |

术语解释：

- **RC**：可靠连接，类似 TCP，保证顺序和交付，最常用。
- **UC**：不可靠连接，不保证交付，但顺序可能保持。
- **UD**：不可靠数据报，类似 UDP，支持多播，最大消息受限。
- **XRC**：扩展可靠连接，多个 QP 共享接收队列，节省内存。

**4）RDMA（RDMA Read/Write 操作）**

这类测试使用 RDMA 的核心操作：直接读写远程内存，无需远程 CPU 参与。

| 测试项                                   | 说明                                                         |
| :--------------------------------------- | :----------------------------------------------------------- |
| `rc_rdma_read_bw` / `rc_rdma_read_lat`   | RC 传输上的 **RDMA Read** 操作：本地从远程内存读取数据。测量单向带宽 / 延迟。 |
| `rc_rdma_write_bw` / `rc_rdma_write_lat` | RC 上的 **RDMA Write** 操作：本地向远程内存写入数据。测量带宽 / 延迟。 |
| `rc_rdma_write_poll_lat`                 | RC 上的 RDMA Write **轮询延迟**：发送方写入后立即轮询完成标志，测量更低延迟的完成路径。 |
| `uc_rdma_write_bw` / `uc_rdma_write_lat` | UC 上的 RDMA Write 带宽 / 延迟。UC 无可靠性保证，但性能更高。 |
| `uc_rdma_write_poll_lat`                 | UC 上的 RDMA Write 轮询延迟。                                |

区别：Send/Receive 需要双方 CPU 参与协议握手，而 RDMA Read/Write 直接存取对端内存，延迟更低，CPU 卸载更彻底。

**5）InfiniBand Atomics（InfiniBand 原子操作）**

仅限 InfiniBand 硬件支持的原子操作，用于高性能计算中的同步和锁。

| 测试项               | 说明                                                         |
| :------------------- | :----------------------------------------------------------- |
| `rc_compare_swap_mr` | RC 上的 **比较并交换 (Compare-and-Swap)** 消息速率。测量每秒成功执行 CAS 的次数。 |
| `rc_fetch_add_mr`    | RC 上的 **取并加 (Fetch-and-Add)** 消息速率。测量每秒执行 FAA 的次数。 |

这些操作用于实现分布式锁或计数器，测试的是消息速率（operations per second），而非带宽。

**6）Verification（验证测试）**

用于验证 RDMA 原子操作的正确性，不是性能测试。

| 测试项                | 说明                                                         |
| :-------------------- | :----------------------------------------------------------- |
| `ver_rc_compare_swap` | 验证 RC 连接上 **比较并交换** 操作的逻辑正确性（例如是否在预期值相等时正确交换）。 |
| `ver_rc_fetch_add`    | 验证 RC 连接上 **取并加** 操作的逻辑正确性（例如是否原子地返回旧值并加上增量）。 |

列出一系列典型使用场景

````
$ qperf --help examples
In these examples, we first run qperf on a node called myserver in server
mode by invoking it with no arguments.  In all the subsequent examples, we
run qperf on another node and connect to the server which we assume has a
hostname of myserver.
    * To run a TCP bandwidth and latency test:
        qperf myserver tcp_bw tcp_lat
    * To run a SDP bandwidth test for 10 seconds:
        qperf myserver -t 10 sdp_bw
    * To run a UDP latency test and then cause the server to terminate:
        qperf myserver udp_lat quit
    * To measure the RDMA UD latency and bandwidth:
        qperf myserver ud_lat ud_bw
    * To measure RDMA UC bi-directional bandwidth:
        qperf myserver rc_bi_bw
    * To get a range of TCP latencies with a message size from 1 to 64K
        qperf myserver -oo msg_size:1:64K:*2 -vu tcp_lat
````

**1）TCP 带宽和延迟测试**

````
$ qperf myserver tcp_bw tcp_lat
````

- **作用**：同时测量到 `myserver` 的 **TCP 带宽** 和 **TCP 往返延迟**。
- **说明**：`tcp_bw` 测试单向流带宽（默认使用 64KB 消息，持续约 2 秒），`tcp_lat` 测试小消息（默认 1 字节）的往返时间。两个测试会依次执行，结果同时输出。

**2）SDP 带宽测试（持续 10 秒）**

````
$ qperf myserver -t 10 sdp_bw
````

- **作用**：测量 **SDP**（Sockets Direct Protocol，一种让 Socket 应用使用 RDMA 的协议）的带宽，测试时长为 **10 秒**。
- **参数说明**：`-t 10` 覆盖默认的测试持续时间（通常为 2 秒或一个固定轮次）。SDP 需要底层 RDMA 支持。

**3）UDP 延迟测试后让服务端退出**

````
$ qperf myserver udp_lat quit
````

- **作用**：先执行 **UDP 延迟测试**，然后发送 `quit` 命令让远程 `qperf` 服务器进程退出。
- **说明**：`quit` 是一个特殊测试项，不是性能测试，而是管理命令。多个测试项会按顺序执行。执行 `quit` 后，服务端终止，后续不再接受连接。

**4）RDMA UD 延迟和带宽测试**

````
$ qperf myserver ud_lat ud_bw
````

- **作用**：测量 **UD**（Unreliable Datagram，不可靠数据报）的延迟和带宽。
- **说明**：UD 是 InfiniBand/RDMA 中的一种传输服务，类似 UDP 但由硬件卸载。此命令先测延迟（默认小消息往返），再测单向带宽。

**5）RDMA RC 双向带宽测试**

````
$ qperf myserver rc_bi_bw
````

- **作用**：测量 **RC**（Reliable Connected）传输服务的 **双向带宽**。
- **说明**：两端同时向对方发送数据，测量总吞吐量（即发送+接收的总和）。RC 是 InfiniBand 中最常用的可靠连接模式。

**6）变消息大小的 TCP 延迟测试（1 到 64K，每次翻倍）**

````
$ qperf myserver -oo msg_size:1:64K:*2 -vu tcp_lat
````

- **作用**：测试不同消息大小（从 1 字节到 64K 字节，每次大小乘以 2）下的 **TCP 延迟**。
- **参数说明**：
  - `-oo msg_size:1:64K:*2`：`-oo` 表示覆盖（override）测试选项。`msg_size` 设定消息大小的范围：起始值 `1`，结束值 `64K`（即 65536 字节），步进因子 `*2`（每次翻倍）。因此会测试的消息大小序列为：1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2K, 4K, 8K, 16K, 32K, 64K 字节。
  - `-v`：**详细输出**（verbose），输出每个消息大小的测试结果。
  - `-u`：**以微秒为单位**显示延迟（默认可能为毫秒或自适应）。
- **用途**：获得延迟与消息大小的关系曲线，常用于分析网络协议栈的拷贝开销、小包性能等。

**总结**

| 示例                                               | 测试内容                  | 关键参数                             |
| :------------------------------------------------- | :------------------------ | :----------------------------------- |
| `qperf myserver tcp_bw tcp_lat`                    | TCP 带宽+延迟（顺序执行） | 无                                   |
| `qperf myserver -t 10 sdp_bw`                      | SDP 带宽（10 秒）         | `-t` 指定时长                        |
| `qperf myserver udp_lat quit`                      | UDP 延迟 + 停止服务端     | `quit` 管理命令                      |
| `qperf myserver ud_lat ud_bw`                      | RDMA UD 延迟+带宽         | 需要 RDMA 硬件                       |
| `qperf myserver rc_bi_bw`                          | RDMA RC 双向带宽          | 需要 RDMA 硬件                       |
| `qperf myserver -oo msg_size:1:64K:*2 -vu tcp_lat` | 变消息大小 TCP 延迟       | `-oo` 覆盖选项，`-v` 详细，`-u` 微秒 |

这些示例覆盖了 `qperf` 的主要功能：传统 TCP/UDP、RDMA 各类传输（RC/UD）、单/双向、固定时长、变消息大小以及服务器管理。

qperf 支持的所有选项

````
$ qperf --help options
--access_recv OnOff (-ar)
      If OnOff is non-zero, data is accessed once received.  Otherwise,
      data is ignored.  By default, OnOff is 0.  This can help to mimic
      some applications.
  -ar1
      Cause received data to be accessed.
--alt_port Port (-ap)
      Set alternate path port. This enables automatic path failover.
  --loc_alt_port Port (-lap)
      Set local alternate path port. This enables automatic path failover.
  --rem_alt_port Port (-rap)
      Set remote alternate path port. This enables automatic path failover.
--cpu_affinity PN (-ca)
      Set cpu affinity to PN.  CPUs are numbered sequentially from 0.  If
      PN is "any", any cpu is allowed otherwise the cpu is limited to the
      one specified.
  --loc_cpu_affinity PN (-lca)
      Set local processor affinity to PN.
  --rem_cpu_affinity PN (-rca)
      Set remote processor affinity to PN.
--flip OnOff (-f)
      If non-zero, cause sender and receiver to play opposite roles.
  -f1
      Cause sender and receiver to play opposite roles.
--help Topic (-h)
      Print out information about Topic.  To see the list of topics, type
          qperf --help
--host Host (-H)
      Run test between the current node and the qperf running on node Host.
      This can also be specified as the first non-option argument.
--id Device:Port (-i)
      Use RDMA Device and Port.
  --loc_id Device:Port (-li)
      Use local RDMA Device and Port.
  --rem_id Device:Port (-ri)
      Use remote RDMA Device and Port.
--listen_port Port (-lp)
      Set the port we listen on to ListenPort.  This must be set to the
      same port on both the server and client machines.  The default value
      is 19765.
--loop Var:Init:Last:Incr (-oo)
    Run a test multiple times sequencing through a series of values.  Var
    is the loop variable; Init is the initial value; Last is the value it
    must not exceed and Incr is the increment.  It is useful to set the
    --verbose_used (-vu) option in conjunction with this option.
--msg_size Size (-m)
      Set the message size to Size.  The default value varies by test.  It
      is assumed that the value is specified in bytes however, a trailing
      kib or K, mib or M, or gib or G indicates that the size is being
      specified in kibibytes, mebibytes or gibibytes respectively while a
      trailing kb or k, mb or m, or gb or g indicates kilobytes, megabytes
      or gigabytes respectively.
--mtu_size Size (-mt)
      Set the MTU size.  Only relevant to the RDMA UC/RC tests.  Units are
      specified in the same manner as the --msg_size option.
--no_msgs N (-n)
    Set test duration by number of messages sent instead of time.
--cq_poll OnOff (-cp)
      Turn polling mode on or off.  This is only relevant to the RDMA tests
      and determines whether they poll or wait on the completion queues.
      If OnOff is 0, they wait; otherwise they poll.
  --loc_cq_poll OnOff (-lcp)
      Locally turn polling mode on or off.
  --rem_cq_poll OnOff (-rcp)
      Remotely turn polling mode on or off.
  -cp1
      Turn polling mode on.
  -lcp1
      Turn local polling mode on.
  -rcp1
      Turn remote polling mode on.
--ip_port Port (-ip)
      Use Port to run the socket tests.  This is different from
      --listen_port which is used for synchronization.  This is only
      relevant for the socket tests and refers to the TCP/UDP/SDP/RDS/SCTP
      port that the test is run on.
--precision Digits (-e)
      Set the number of significant digits that are used to report results.
--rd_atomic Max (-nr)
      Set the number of in-flight operations that can be handled for a RDMA
      read or atomic operation to Max.  This is only relevant to the RDMA
      Read and Atomic tests.
  --loc_rd_atomic Max (-lnr)
      Set local read/atomic count.
  --rem_rd_atomic Max (-rnr)
      Set remote read/atomic count.
--service_level SL (-sl)
      Set RDMA service level to SL.  This is only used by the RDMA tests.
      The service level must be between 0 and 15.  The default service
      level is 0.
  --loc_service_level SL (-lsl)
      Set local service level.
  --rem_service_level SL (-rsl)
      Set remote service level.
--sock_buf_size Size (-sb)
      Set the socket buffer size.  This is only relevant to the socket
      tests.
  --loc_sock_buf_size Size (-lsb)
      Set local socket buffer size.
  --rem_sock_buf_size Size (-rsb)
      Set remote socket buffer size.
--src_path_bits N (-sp)
      Set source path bits. If the LMC is not zero, this will cause the
      connection to use a LID with the low order LMC bits set to N.
  --loc_src_path_bits N (-lsp)
      Set local source path bits.
  --rem_src_path_bits N (-rsp)
      Set remote source path bits.
--static_rate Rate (-sr)
      Force InfiniBand static rate.  Rate can be one of: 2.5, 5, 10, 20,
      30, 40, 60, 80, 120, 1xSDR (2.5 Gbps), 1xDDR (5 Gbps), 1xQDR (10
      Gbps), 4xSDR (2.5 Gbps), 4xDDR (5 Gbps), 4xQDR (10 Gbps), 8xSDR (2.5
      Gbps), 8xDDR (5 Gbps), 8xQDR (10 Gbps).
  --loc_static_rate (-lsr)
      Force local InfiniBand static rate
  --rem_static_rate (-rsr)
      Force remote InfiniBand static rate
--time Time (-t)
      Set test duration to Time.  Specified in seconds however a trailing
      m, h or d indicates that the time is specified in minutes, hours or
      days respectively.
--timeout Time (-to)
      Set timeout to Time.  This is the timeout used for various things
      such as exchanging messages.  The default is 5 seconds.
  --loc_timeout Time (-lto)
      Set local timeout to Time.  This may be used on the server to set
      the timeout when initially exchanging data with each client.
      However, as soon as we receive the client's parameters, the client's
      remote timeout will override this parameter.
  --rem_timeout Time (-rto)
      Set remote timeout to Time.
--unify_nodes (-un)
      Unify the nodes.  Describe them in terms of local and remote rather
      than send and receive.
--unify_units (-uu)
      Unify the units that results are shown in.  Uses the lowest common
      denominator.  Helpful for scripts.
--use_bits_per_sec (-ub)
      Use bits/sec rather than bytes/sec when displaying networking speed.
--use_cm OnOff (-cm)
      Use the RDMA Connection Manager (CM) if OnOff is non-zero.  It is
      necessary to use the CM for iWARP devices.  The default is to
      establish the connection without using the CM.  This only works for
      the tests that use the RC transport.
  -cm1
      Use RDMA Connection Manager.
--verbose (-v)
      Provide more detailed output.  Turns on -vc, -vs, -vt and -vu.
  --verbose_conf (-vc)
      Provide information on configuration.
  --verbose_stat (-vs)
      Provide information on statistics.
  --verbose_time (-vt)
      Provide information on timing.
  --verbose_used (-vu)
      Provide information on parameters used.
  --verbose_more (-vv)
      Provide even more detailed output.  Turns on -vvc, -vvs, -vvt and
      -vvu.
  --verbose_more_conf (-vvc)
      Provide more information on configuration.
  --verbose_more_stat (-vvs)
      Provide more information on statistics.
  --verbose_more_time (-vvt)
      Provide more information on timing.
  --verbose_more_used (-vvu)
      Provide more information on parameters used.
--version (-V)
      The current version of qperf is printed.
--wait_server Time (-ws)
      If the server is not ready, continue to try connecting for Time
      seconds before giving up.  The default is 5 seconds.
````

**1）通用控制选项**

这些选项控制测试的基本行为，如主机、端口、时长、消息数量等。

### `--host Host` / `-H`

- **作用**：指定服务端的主机名或 IP 地址。
- **说明**：客户端通过此选项连接到服务端。也可以直接作为第一个非选项参数给出，例如 `qperf myserver tcp_bw`。

### `--listen_port Port` / `-lp`

- **作用**：设置 qperf 服务端监听的端口号。
- **默认值**：19765。
- **说明**：客户端和服务端必须使用相同的端口。如果在一台机器上运行多个 qperf 实例，需要指定不同端口。

### `--time Time` / `-t`

- **作用**：设置测试持续时间。
- **单位**：秒（默认），也可以使用 `m`（分钟）、`h`（小时）、`d`（天），例如 `-t 10m` 表示 10 分钟。
- **说明**：覆盖测试默认的持续时间（通常为 2 秒或固定轮次）。适用于带宽类测试，测量指定时间内的平均吞吐量。

### `--no_msgs N` / `-n`

- **作用**：通过发送固定数量的消息来定义测试时长（而不是时间）。
- **说明**：与 `-t` 互斥，常用于延迟测试或需要精确控制消息个数的场景。

### `--msg_size Size` / `-m`

- **作用**：设置测试使用的消息大小。
- **默认值**：因测试而异（例如 `tcp_bw` 默认 64KB，`tcp_lat` 默认 1 字节）。
- **单位**：字节（默认），支持后缀 `k`/`K`（KiB）、`m`/`M`（MiB）、`g`/`G`（GiB），以及 `kb`/`k`（KB）、`mb`/`m`（MB）、`gb`/`g`（GB）。注意区分：`k` 表示 1024 字节，`kb` 表示 1000 字节。
- **示例**：`-m 4K` 表示 4096 字节。

### `--loop Var:Init:Last:Incr` / `-oo`

- **作用**：自动循环测试一系列参数值（如消息大小）。
- **说明**：`Var` 是循环变量名（例如 `msg_size`），`Init` 为起始值，`Last` 为结束值（不包含），`Incr` 为步进（可以是加法或乘法，如 `*2` 表示翻倍）。
- **典型用法**：`-oo msg_size:1:64K:*2` 测试消息大小从 1 到 64K 每次翻倍。通常与 `--verbose_used` (`-vu`) 配合使用，以显示每次循环的参数。

### `--flip OnOff` / `-f`

- **作用**：交换发送端和接收端的角色。
- **说明**：设置为 1（或使用 `-f1`）时，客户端变成接收方，服务端变成发送方。用于测试双向对称性能或模拟反向流量。

### `--cpu_affinity PN` / `-ca`

- **作用**：将 qperf 进程绑定到指定的 CPU 核心（逻辑编号从 0 开始）。
- **说明**：可以减少 CPU 迁移带来的抖动，提高测试结果的稳定性。如果设置 `any`，则不绑定。
- **本地/远程变体**：`--loc_cpu_affinity` (`-lca`) 仅设置本地端，`--rem_cpu_affinity` (`-rca`) 设置远程端。

### `--timeout Time` / `-to`

- **作用**：设置各种内部操作的超时时间（如连接握手、同步消息）。
- **默认值**：5 秒。
- **说明**：在慢速网络或高延迟环境下，可能需要增大此值，避免误报超时失败。

### `--wait_server Time` / `-ws`

- **作用**：客户端在开始测试前，如果服务端尚未就绪，会持续重试连接，直到超时。
- **默认值**：5 秒。
- **说明**：用于服务端启动较慢的场景（如在容器或虚拟机中）。

### `--version` / `-V`

- **作用**：显示 qperf 的版本信息并退出。

**2）输出与调试选项**

控制输出详细程度、单位格式等。

### `--verbose` / `-v`

- **作用**：开启详细输出模式，相当于同时开启 `-vc -vs -vt -vu`。
- **子选项**：
  - `--verbose_conf` (`-vc`)：显示配置信息（如使用的参数、设备等）。
  - `--verbose_stat` (`-vs`)：显示统计信息（如重传次数、错误计数）。
  - `--verbose_time` (`-vt`)：显示时间相关的详细信息。
  - `--verbose_used` (`-vu`)：显示实际使用的参数（对 `-oo` 循环特别有用）。
- **更详细级别**：`--verbose_more` (`-vv`) 及对应的 `-vvc`、`-vvs`、`-vvt`、`-vvu` 提供更详细的调试输出。

### `--precision Digits` / `-e`

- **作用**：设置结果输出时显示的有效数字位数。
- **说明**：例如 `-e 3` 会将带宽显示为 `1.23 Gb/sec` 而不是 `1.23456789 Gb/sec`。

### `--unify_units` / `-uu`

- **作用**：统一结果使用的单位，采用最小公分母（例如所有带宽都用 `Mb/sec`，而不是混用 `Kb`、`Mb`、`Gb`）。
- **说明**：便于脚本解析输出结果。

### `--use_bits_per_sec` / `-ub`

- **作用**：以比特/秒（bits/sec）为单位显示网络带宽，而不是默认的字节/秒（bytes/sec）。
- **说明**：更符合网络设备（交换机、路由器）的速率标注习惯（如 10 GbE）。

**3）网络协议与套接字选项**

主要针对传统 Socket 协议（TCP/UDP/SCTP/RDS/SDP）的调优。

### `--ip_port Port` / `-ip`

- **作用**：指定用于 Socket 测试（如 `tcp_bw`）的数据端口号。
- **注意**：这与 `--listen_port` 不同，后者用于控制连接和同步。数据端口用于实际传输测试流量。
- **说明**：如果未指定，qperf 会自动分配一个临时端口。

### `--sock_buf_size Size` / `-sb`

- **作用**：设置套接字的发送/接收缓冲区大小（对应 `SO_SNDBUF` / `SO_RCVBUF`）。
- **说明**：增大缓冲区有助于提高高带宽长肥网络（LFN）上的吞吐量。
- **本地/远程变体**：`--loc_sock_buf_size` (`-lsb`)、`--rem_sock_buf_size` (`-rsb`)。

**4）RDMA 专用选项**

这些选项仅在使用 RDMA 传输（如 `rc_bw`、`ud_lat` 等）时有效。

### `--id Device:Port` / `-i`

- **作用**：指定使用的 RDMA 设备（如 `mlx5_0`）和端口号（如 `1`）。
- **说明**：如果系统有多个 RDMA 设备或端口，需要使用此选项选择具体的硬件。
- **本地/远程变体**：`--loc_id` (`-li`)、`--rem_id` (`-ri`)。

### `--use_cm OnOff` / `-cm`

- **作用**：是否使用 RDMA 连接管理器（CM）来建立连接。
- **默认值**：0（不使用 CM）。
- **说明**：对于 iWARP 设备（如某些以太网 RDMA 网卡），必须使用 CM。对于 InfiniBand，默认不使用 CM 也可以工作，但使用 CM 可以简化连接建立。
- **快捷方式**：`-cm1` 等同于 `--use_cm 1`。

### `--cq_poll OnOff` / `-cp`

- **作用**：决定 RDMA 测试是轮询（poll）还是等待（wait）完成队列（CQ）。
- **默认值**：0（等待，即使用事件通知）。
- **说明**：轮询模式会持续检查 CQ 状态，降低延迟但增加 CPU 占用。等待模式会阻塞直到完成，节省 CPU 但可能增加延迟。
- **本地/远程变体**：`--loc_cq_poll` (`-lcp`)、`--rem_cq_poll` (`-rcp`)，以及快捷方式 `-cp1`、`-lcp1`、`-rcp1`。

### `--rd_atomic Max` / `-nr`

- **作用**：设置 RDMA 读操作或原子操作（compare-and-swap / fetch-and-add）的最大未完成请求数（inflight 深度）。
- **说明**：增大该值可以隐藏延迟，提高带宽，但会消耗更多内存和 QP 资源。
- **本地/远程变体**：`--loc_rd_atomic` (`-lnr`)、`--rem_rd_atomic` (`-rnr`)。

### `--service_level SL` / `-sl`

- **作用**：设置 InfiniBand 的服务等级（Service Level），范围 0-15。
- **说明**：用于区分流量优先级或选择不同的虚拟通道（VL）。需要交换机配合配置 QoS。
- **本地/远程变体**：`--loc_service_level` (`-lsl`)、`--rem_service_level` (`-rsl`)。

### `--static_rate Rate` / `-sr`

- **作用**：强制 InfiniBand 链路使用固定的静态速率，而不是自动协商。
- **可选值**：`2.5, 5, 10, 20, 30, 40, 60, 80, 120`（单位 Gbps），或 `1xSDR`（2.5 Gbps）、`4xQDR`（10 Gbps）等。
- **说明**：用于测试特定速率下的性能，或规避某些链路训练问题。
- **本地/远程变体**：`--loc_static_rate` (`-lsr`)、`--rem_static_rate` (`-rsr`)。

### `--src_path_bits N` / `-sp`

- **作用**：设置源路径位（Source Path Bits）。当 LMC（本地多播 LID 掩码）不为 0 时，此选项会使连接使用一个 LID，其低 LMC 位被设置为 N。
- **说明**：用于 InfiniBand 多路径或负载均衡场景。
- **本地/远程变体**：`--loc_src_path_bits` (`-lsp`)、`--rem_src_path_bits` (`-rsp`)。

### `--mtu_size Size` / `-mt`

- **作用**：设置 RDMA 传输的 MTU 大小（仅对 RC/UC 测试有效）。
- **单位**：同 `--msg_size`（字节，支持后缀）。
- **说明**：通常 MTU 由设备限制，此选项可以覆盖默认值（例如 4096）。较小的 MTU 可能减少延迟，但增加包头开销。

**5）特殊功能选项**

这些选项用于模拟特定应用行为或实现高可用。

### `--access_recv OnOff` / `-ar`

- **作用**：是否真正访问接收缓冲区中的数据。
- **默认值**：0（忽略接收数据）。
- **说明**：设置为 1（或使用 `-ar1`）时，qperf 会在收到数据后读取缓冲区，模拟真实应用程序处理数据的 CPU 开销。否则，数据只是 DMA 到内存而不被 CPU 访问，这可能会给出过于乐观的性能数据。

### `--alt_port Port` / `-ap`

- **作用**：启用备用路径（自动故障切换），并指定备用端口号。
- **说明**：当主路径（默认端口）失效时，qperf 会自动切换到备用端口。用于测试网络冗余或高可用性。
- **本地/远程变体**：`--loc_alt_port` (`-lap`)、`--rem_alt_port` (`-rap`)。

### `--unify_nodes` / `-un`

- **作用**：在输出结果时，统一将节点称为“本地”和“远程”，而不是“发送端”和“接收端”。
- **说明**：当测试角色可能翻转（如使用 `--flip`）时，使用 `-un` 可以避免混淆。

**6）帮助与示例**

### `--help Topic` / `-h`

- **作用**：显示指定主题的帮助信息。
- **Topic 可选值**：`examples`（示例）、`opts`/`options`（选项摘要/详细）、`tests`（测试列表）、`TESTNAME`（具体测试的详细说明）。
- **示例**：`qperf --help tcp_bw` 会显示 TCP 带宽测试的详细参数和说明。

总结表格：常用参数速查

| 分类          | 参数                                       | 作用                                                         |
| :------------ | :----------------------------------------- | :----------------------------------------------------------- |
| **基本控制**  | `-H`, `-lp`, `-t`, `-n`, `-m`, `-oo`, `-f` | 指定服务端、端口、时长、消息数量、消息大小、循环测试、角色翻转 |
| **性能调优**  | `-ca`, `-sb`, `-nr`, `-cp`, `-mt`, `-sr`   | CPU 绑定、套接字缓冲区、RDMA 深度、轮询模式、MTU、静态速率   |
| **RDMA 专用** | `-i`, `-cm`, `-sl`, `-sp`                  | 选择 RDMA 设备、使用连接管理器、服务等级、源路径位           |
| **输出控制**  | `-v` 系列, `-e`, `-uu`, `-ub`              | 详细输出、有效数字、统一单位、比特/秒单位                    |
| **高级/模拟** | `-ar`, `-ap`, `-un`                        | 访问接收数据、备用路径故障切换、统一节点命名                 |
| **超时调试**  | `-to`, `-ws`                               | 内部操作超时、等待服务端就绪                                 |

这些参数提供了从简单带宽测试到复杂 RDMA 性能分析的全面控制能力。根据具体测试环境（传统 TCP 还是 RDMA、是否需要模拟真实负载、是否有多路径要求），选择合适的参数组合即可。

根据日常使用频率和通用性，将 `qperf` 

**★★★★★ 最常用（几乎每次测试必备）参数从最常用到极少用排序如下**

| 参数            | 简写  | 说明                                              |
| :-------------- | :---- | :------------------------------------------------ |
| `--host`        | `-H`  | 指定服务端主机名/IP（或直接作为第一个非选项参数） |
| `--time`        | `-t`  | 设置测试时长（秒），带宽测试必备                  |
| `--msg_size`    | `-m`  | 设置消息大小，延迟测试或特定大小带宽测试常用      |
| `--verbose`     | `-v`  | 详细输出，查看实际参数和结果细节                  |
| `--listen_port` | `-lp` | 指定端口（默认19765），多实例或防火墙限制时使用   |

**★★★★ 较常用（特定场景下频繁使用）**

| 参数                 | 简写  | 说明                                       |
| :------------------- | :---- | :----------------------------------------- |
| `--loop`             | `-oo` | 变消息大小循环测试，获得性能曲线           |
| `--use_bits_per_sec` | `-ub` | 以 bits/sec 显示带宽，符合网络设备习惯     |
| `--flip`             | `-f`  | 交换发送/接收角色，测试双向对称性          |
| `--id`               | `-i`  | 指定 RDMA 设备与端口（RDMA 测试必备）      |
| `--use_cm`           | `-cm` | 使用 RDMA 连接管理器（iWARP 或多子网场景） |
| `--cpu_affinity`     | `-ca` | 绑定 CPU 核心，减少调度抖动                |
| `--no_msgs`          | `-n`  | 按消息数定义测试时长（替代 `-t`）          |
| `--precision`        | `-e`  | 控制输出有效数字位数，便于脚本解析         |
| `--unify_units`      | `-uu` | 统一输出单位，方便自动化处理               |

**★★★ 偶尔使用（调试、调优或特殊环境）**

| 参数              | 简写  | 说明                                       |
| :---------------- | :---- | :----------------------------------------- |
| `--timeout`       | `-to` | 调整内部操作超时（高延迟或慢速网络）       |
| `--wait_server`   | `-ws` | 等待服务端就绪的超时时间                   |
| `--cq_poll`       | `-cp` | RDMA 轮询模式（降低延迟，增加 CPU 占用）   |
| `--rd_atomic`     | `-nr` | 设置 RDMA 读/原子操作的最大未完成数        |
| `--sock_buf_size` | `-sb` | 调整套接字缓冲区大小（高带宽长肥网络）     |
| `--mtu_size`      | `-mt` | 设置 RDMA MTU 大小                         |
| `--static_rate`   | `-sr` | 强制 InfiniBand 链路速率                   |
| `--service_level` | `-sl` | 设置 InfiniBand 服务等级（QoS）            |
| `--ip_port`       | `-ip` | 指定 Socket 测试的数据端口（一般自动分配） |
| `--src_path_bits` | `-sp` | 设置 InfiniBand 源路径位（多路径）         |

**★★ 很少使用（高级特性或特定模拟）**

| 参数            | 简写  | 说明                                      |
| :-------------- | :---- | :---------------------------------------- |
| `--access_recv` | `-ar` | 模拟应用真正访问接收数据（增加 CPU 开销） |
| `--alt_port`    | `-ap` | 启用备用路径故障切换                      |
| `--unify_nodes` | `-un` | 输出中用“本地/远程”代替“发送/接收”        |
| `--version`     | `-V`  | 显示版本信息                              |
| `--help`        | `-h`  | 获取帮助（本身不是测试参数）              |

**★ 极少使用（几乎不需要手动指定）**

- 各种 `--loc_*` / `--rem_*` 变体（如 `-lca`, `-rca`, `-lsb`, `-rsb` 等）—— 除非需要对本地和远程做不对称配置，否则统一版本足够。
- `--verbose_conf` (`-vc`)、`--verbose_stat` (`-vs`)、`--verbose_time` (`-vt`)、`--verbose_used` (`-vu`) —— 通常 `-v` 已经包含，更细粒度的调试几乎用不到。
- `--verbose_more` (`-vv`) 系列 —— 极其冗长，仅用于 qperf 自身调试。

**补充说明**

- **传统网络测试（TCP/UDP）** 最常用：`-H`, `-t`, `-m`, `-v`, `-lp`, `-oo`, `-ub`, `-f`。
- **RDMA 测试** 额外常用：`-i`, `-cm`, `-cp`, `-nr`, `-mt`, `-sl`, `-sr`。
- **自动化脚本** 额外常用：`-uu`, `-e`, `-ub`。



服务端执行命令(服务端被动等待)

````
$ qperf
````

客户端执行命令（主动测试）

**1）普通网络测试（TCP/UDP）**

测 TCP 带宽 + 延迟

````
$ qperf 10.0.0.2 tcp_bw tcp_lat
$ qperf 10.0.0.2 -t 10 -v -ub tcp_bw tcp_lat
````

`tcp_bw`：带宽（吞吐量）

`tcp_lat`：延迟

`-t 10`：测 10 秒

`-ub`：用 bps 显示（Gbps/Mbps）

`-v`：详细输出

测 UDP 带宽 + 延迟

````
$ qperf 10.0.0.2 udp_bw udp_lat
$ qperf 10.0.0.2 -t 10 udp_bw udp_lat
````

`udp_bw`：带宽

`udp_lat`：延迟

`-t 10`：测 10 秒

多包大小梯度测试（专业报告常用）

````
$ qperf 10.0.2.100 -oo msg_size:1:64K:*2 tcp_lat
````

`-oo msg_size:1:64K:*2`：msg_size 从 1 → 64K，每次 ×2

**2）RDMA 测试（只有物理 RNIC 网卡能用，QEMU 虚拟机一般没有）**

RC 可靠连接带宽 + 延迟

````
$ qperf 10.0.2.100 -t 10 rc_bw rc_lat
````

RC 双向带宽

````
$ qperf 10.0.2.100 rc_bi_bw
````

UD 无连接模式（不可靠）带宽 + 延迟

````
$ qperf 10.0.2.100 ud_bw ud_lat
````

RDMA Write 测试

````
$ qperf 10.0.2.100 rc_rdma_write_bw rc_rdma_write_lat
````

RDMA Read 测试

````
$ qperf 10.0.2.100 rc_rdma_read_bw rc_rdma_read_lat
````

**3）一次跑完[普通网 + RDMA 全套]（一条命令）**

````
qperf 10.0.2.100 \
    -t 10 -v -ub \
    tcp_bw tcp_lat \
    udp_bw udp_lat \
    rc_bw rc_lat \
    rc_bi_bw \
    ud_bw ud_lat \
    rc_rdma_write_bw rc_rdma_write_lat
````

`-ub`：输出 Gbps、Mbps （网速常用）

| 类型     | 测试项举例       | 适用环境                      |
| -------- | ---------------- | ----------------------------- |
| 普通网络 | tcp_bw / tcp_lat | 虚拟机、千兆网卡、万兆非 RDMA |
| 普通网络 | udp_bw / udp_lat | 视频、实时传输场景            |
| RDMA     | rc_bw / rc_lat   | IB、RoCE 智能网卡             |
| RDMA     | rc_bi_bw         | 双向带宽（高并发场景）        |
| RDMA     | rc_rdma_write_bw | 远程读写（数据库、存储）      |

#### 2.2 测试结果

**TCP带宽 + 延迟测试：**

````
$ qperf 10.0.0.2 -t 30 -v -m 32K tcp_bw tcp_lat 
tcp_bw:
    bw              =  82.2 MB/sec
    msg_rate        =  2.51 K/sec
    msg_size        =    32 KiB (32,768)
    time            =    30 sec
    send_cost       =  18.4 sec/GB
    recv_cost       =  18.3 sec/GB
    send_cpus_used  =   151 % cpus
    recv_cpus_used  =   151 % cpus
tcp_lat:
    latency        =  1.11 ms
    msg_rate       =   905 /sec
    msg_size       =    32 KiB (32,768)
    time           =    30 sec
    loc_cpus_used  =  63.5 % cpus
    rem_cpus_used  =  66.3 % cpus
````

这里 -t 30 的意思是测试项 tcp_bw 和 tcp_lat 各自测试时间是 30s，即总测试时间是 60s

1）TCP 带宽测试 (`tcp_bw`) 结果

| 指标                 | 数值        | 含义                                                        |
| :------------------- | :---------- | :---------------------------------------------------------- |
| **`bw`**             | 82.2 MB/sec | 带宽 **82.2 MB/s**（≈ 658 Mbps）。                          |
| **`msg_rate`**       | 2.51 K/sec  | 每秒发送约 2510 个 32 KiB 消息。                            |
| **`msg_size`**       | 32 KiB      | 消息大小 32 KiB。                                           |
| **`time`**           | 30 sec      | 该测试项的持续运行时间为 30 秒                              |
| **`send_cpus_used`** | 151 % cpus  | 发送端消耗 1.51 个 CPU 核心。                               |
| **`recv_cpus_used`** | 151 % cpus  | 接收端消耗 1.51 个核心。                                    |
| **`send_cost`**      | 18.4 sec/GB | 发送端每成功发送 1 GB 的数据，需要消耗 18.4 秒的 CPU 时间。 |
| **`recv_cost`**      | 18.3 sec/GB | 接收端每接收 1 GB 的数据，需要消耗 18.3 秒的 CPU 时间。     |

2）TCP 延迟测试 (`tcp_lat`) 结果

| 指标                | 数值        | 问题分析                                                     |
| :------------------ | :---------- | :----------------------------------------------------------- |
| **`latency`**       | 1.11 ms     | 往返延迟 **1.11 毫秒**。这是 **32 KiB 消息的往返时间**，包含网络传播延迟 + 数据发送时间 + 处理时间。真实 RTT ≈ 828 μs，32 KiB 发送时间 ≈ 32 KB / 110 MB/s ≈ 291 μs，总和约 1.12 ms，与 1.11 ms 吻合。 |
| **`msg_rate`**      | 905 /sec    | 每秒完成约 905 次请求-响应，与 1.11 ms 对应。                |
| **`msg_size`**      | 32 KiB      | 消息大小 32 KiB。                                            |
| **`time`**          | 30 sec      | 该测试项的持续运行时间为 30 秒                               |
| **`loc_cpus_used`** | 63.5 % cpus | 客户端 CPU 占用 0.64 核。                                    |
| **`rem_cpus_used`** | 66.3 % cpus | 服务端 CPU 占用 0.66 核。                                    |



**UDP 带宽 + 延迟测试：**

````
$ qperf 10.0.0.2 -t 30 -v -m 1400 udp_bw udp_lat
udp_bw:
    send_bw         =  7.7 MB/sec
    recv_bw         =  7.7 MB/sec
    msg_rate        =  5.5 K/sec
    msg_size        =  1.4 KB
    time            =   30 sec
    send_cost       =  188 sec/GB
    recv_cost       =  160 sec/GB
    send_cpus_used  =  145 % cpus
    recv_cpus_used  =  123 % cpus
udp_lat:
    latency        =   713 us
    msg_rate       =   1.4 K/sec
    msg_size       =   1.4 KB
    time           =    30 sec
    loc_cpus_used  =  43.6 % cpus
    rem_cpus_used  =    43 % cpus
````

这里 -t 30 的意思是测试项 tcp_bw 和 tcp_lat 各自测试时间是 30s，即总测试时间是 60s

msg_size：避免超过 MTU，标准以太网 MTU=1500，UDP 净荷安全上限约为 **1472 字节**。大于此值的消息会触发 IP 分片，导致吞吐量暴跌、CPU 飙升、延迟增大。UDP 性能与消息大小强相关。只有指定一个合理的 `msg_size`（如 1400），才能测出该网络路径上 UDP 的真实带宽和延迟。

1）UDP 带宽测试 (`udp_bw`) 结果解读

| 指标                      | 数值       | 含义与异常表现                                               |
| :------------------------ | :--------- | :----------------------------------------------------------- |
| **`send_bw` / `recv_bw`** | 7.7 MB/sec | 有效吞吐量约 **7.7 MB/s**（≈ 61.6 Mbps）。                   |
| **`msg_rate`**            | 5.5 K/sec  | 每秒发送 5500 个 1400 字节的消息。理论最大消息率 = 7.7 MB/s ÷ 1.4 KB ≈ 5.5 K/s，匹配。 |
| **`send_cost`**           | 188 sec/GB | 发送端每成功发送 1 GB 的数据，需要消耗 188 秒的 CPU 时间。   |
| **`recv_cost`**           | 160 sec/GB | 接收端每收到 1 GB 的数据，需要消耗 160 秒的 CPU 时间。       |
| **`send_cpus_used`**      | 145 % cpus | 发送端消耗 1.45 个 CPU 核心。                                |
| **`recv_cpus_used`**      | 123 % cpus | 接收端消耗 1.23 个核心。                                     |

2）UDP 延迟测试 (`udp_lat`) 结果解读

| 指标                | 数值        | 含义                                                         |
| :------------------ | :---------- | :----------------------------------------------------------- |
| **`latency`**       | 713 us      | 往返延迟 713 微秒。                                          |
| **`msg_rate`**      | 1.4 K/sec   | 每秒 1400 次请求-响应，与 713 us 延迟匹配（1s/713us ≈ 1402）。 |
| **`loc_cpus_used`** | 43.6 % cpus | 客户端 CPU 占用约 0.44 核。                                  |
| **`rem_cpus_used`** | 43 % cpus   | 服务端 CPU 占用 0.43 核。                                    |
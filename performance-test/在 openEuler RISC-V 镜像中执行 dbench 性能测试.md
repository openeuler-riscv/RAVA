## 在 openEuler RISC-V 镜像中执行 dbench 性能测试

### 1. dbench 介绍

dbench 是一个开源的、专门用于衡量文件系统和磁盘性能的基准测试工具。它由著名的 Samba 项目开发，旨在模拟真实环境下的文件服务器负载。它的主要用途是测试磁盘子系统的吞吐能力，结果通常以 MB/s 为单位。通过模拟多个客户端同时进行文件读写、删除等操作，可以评估系统在高负载下的性能表现

### 2. 安装 dbench

从源码编译安装

````
$ dnf install -y wget tar autoconf gcc popt-devel
$ wget https://www.samba.org/ftp/tridge/dbench/dbench-4.0.tar.gz
$ tar -xzvf dbench-4.0.tar.gz
$ cd dbench-4.0
$ ./autogen.sh
$ ./configure
$ make
$ make install 
$ dbench V         # 确认 dbench 安装成功
dbench version 4.00 - Copyright Andrew Tridgell 1999-2004

Running for 600 seconds with load '/usr/local/share/client.txt' and minimum warmup 120 secs
create 0 procs?  you must be kidding.
Throughput 0 MB/sec  0 clients  0 procs  max_latency=0.000 ms
````

### 3. 执行测试

执行 help 命令，查看 dbench 支持的选项

````
$ dbench --help
dbench version 4.00 - Copyright Andrew Tridgell 1999-2004

Usage: [OPTION...]
  -t, --timelimit=integer           timelimit
  -c, --loadfile=filename           loadfile
  -D, --directory=STRING            working directory
  -T, --tcp-options=STRING          TCP socket options
  -R, --target-rate=DOUBLE          target throughput (MB/sec)
  -s, --sync                        use O_SYNC
  -S, --sync-dir                    sync directory changes
  -F, --fsync                       fsync on write
  -x, --xattr                       use xattrs
      --no-resolve                  disable name resolution simulation
      --clients-per-process=INT     number of clients per process
      --one-byte-write-fix          try to fix 1 byte writes
      --stat-check                  check for pointless calls with stat
      --fake-io                     fake up read/write calls
      --skip-cleanup                skip cleanup operations
      --per-client-results          show results per client

Help options:
  -?, --help                        Show this help message
      --usage                       Display brief usage message
````

**核心控制选项（最常用）**

|       选项格式        | 简写 |                           功能说明                           |                   实战示例                   |
| :-------------------: | :--: | :----------------------------------------------------------: | :------------------------------------------: |
| `--timelimit=integer` | `-t` | 设置测试总时长（单位：秒），默认会跑完整个 `loadfile` 负载，指定后到时间立即终止 |   `dbench -t 60 32` → 测试 60 秒、32 并发    |
| `--directory=STRING`  | `-D` | 指定测试的工作目录（I/O 操作均在该目录执行），默认是当前目录 |  `dbench -D /mnt/nfs 16` → 测试 NFS 挂载点   |
| `--loadfile=filename` | `-c` | 指定负载文件（记录 I/O 操作序列），默认是 `client.txt`（NetBench 标准负载） | `dbench -c my_load.txt 8` → 用自定义负载测试 |

**负载与并发调优选项**

|          选项格式           | 简写 |                          功能说明                          |                 适用场景                  |
| :-------------------------: | :--: | :--------------------------------------------------------: | :---------------------------------------: |
|   `--target-rate=DOUBLE`    | `-R` |  限制测试的目标吞吐量（单位：MB/sec），强制压测不超过该值  |       模拟低带宽场景、验证 QoS 限制       |
| `--clients-per-process=INT` |  无  | 每个进程启动的客户端数（默认 1:1），减少进程数降低系统开销 | 高并发测试（如 128 客户端），避免进程过多 |
|   `--per-client-results`    |  无  |       输出每个客户端的独立测试结果（默认只输出汇总）       |          定位个别客户端性能瓶颈           |

**I/O 行为控制选项（影响测试真实性）**

|   选项格式   | 简写 |                           功能说明                           |             对应内核行为              |
| :----------: | :--: | :----------------------------------------------------------: | :-----------------------------------: |
|   `--sync`   | `-s` | 所有写操作使用 `O_SYNC` 标志（写数据 + 元数据立即刷盘，不经过页缓存） |    模拟数据库 / 日志等高可靠性场景    |
| `--sync-dir` | `-S` |         同步目录变更（如创建 / 删除文件后立即刷盘）          |     模拟频繁创建 / 删除文件的场景     |
|  `--fsync`   | `-F` |      每次写操作后执行 `fsync()`（仅刷数据，不刷元数据）      |   比 `-s` 轻量，模拟普通持久化场景    |
|  `--xattr`   | `-x` | 在 I/O 操作中加入扩展属性（xattr）读写，模拟带扩展属性的文件系统负载 |      测试 XFS/ext4 的 xattr 性能      |
| `--fake-io`  |  无  |      伪造读 / 写操作（仅统计调用次数，不实际读写数据）       | 测试 dbench 自身 / CPU / 进程调度性能 |

**网络与兼容性选项**

|        选项格式        | 简写 |                           功能说明                           |                   适用场景                    |
| :--------------------: | :--: | :----------------------------------------------------------: | :-------------------------------------------: |
| `--tcp-options=STRING` | `-T` |  设置 TCP 套接字选项（仅 `tbench` 有效，dbench 无网络操作）  | tbench 测试时调优 TCP 参数（如`TCP_NODELAY`） |
|     `--no-resolve`     |  无  | 禁用名称解析仿真（默认会模拟 NetBench 的 DNS / 主机名解析）  |         排除名称解析对测试结果的干扰          |
| `--one-byte-write-fix` |  无  | 修复 1 字节写操作的兼容性问题（部分系统 1 字节写会触发性能异常） |          测试老旧系统 / 特殊文件系统          |

**测试辅助与调试选项**

|     选项格式     | 简写 |                           功能说明                           |            作用            |
| :--------------: | :--: | :----------------------------------------------------------: | :------------------------: |
|  `--stat-check`  |  无  | 检查无意义的 `stat()` 调用（如重复 stat 同一个文件），输出冗余操作统计 | 优化负载脚本、定位无效 I/O |
| `--skip-cleanup` |  无  |   跳过测试后的清理操作（默认会删除测试生成的文件 / 目录）    | 保留测试文件，用于事后分析 |
|     `--help`     | `-?` |              显示完整帮助信息（即你贴出的内容）              |      快速查询选项用法      |
|    `--usage`     |  无  |          显示极简用法提示（仅核心语法，无详细说明）          |    快速回忆基本使用方式    |

测试本地文件系统吞吐量，

````
$ dbench -t 60 32   # 测试当前目录，32并发，测试60秒
$ dbench -D /mnt/dbench_test -t 60 10   # 测试指定目录/mnt/dbench_test，10并发，测试60秒
````

测试结果

````
$ dbench -t 30 32
dbench version 4.00 - Copyright Andrew Tridgell 1999-2004

Running for 30 seconds with load '/usr/local/share/client.txt' and minimum warmup 6 secs
31 of 32 processes prepared for launch   0 sec
32 of 32 processes prepared for launch   0 sec
releasing clients
  32       716   665.80 MB/sec  warmup   1 sec  latency 86.551 ms
  32      1392   392.76 MB/sec  warmup   2 sec  latency 93.882 ms
  32      2096   283.03 MB/sec  warmup   3 sec  latency 101.886 ms
  32      2918   260.22 MB/sec  warmup   4 sec  latency 112.002 ms
  32      3706   245.56 MB/sec  warmup   5 sec  latency 84.655 ms
  32      4966   109.48 MB/sec  execute   1 sec  latency 100.997 ms
  32      5697    93.96 MB/sec  execute   2 sec  latency 93.495 ms
  32      6550   129.47 MB/sec  execute   3 sec  latency 104.455 ms
  32      7308   140.27 MB/sec  execute   4 sec  latency 86.132 ms
  32      7864   122.73 MB/sec  execute   5 sec  latency 86.651 ms
  32      8574   122.35 MB/sec  execute   6 sec  latency 98.519 ms
  32      9292   114.87 MB/sec  execute   7 sec  latency 97.141 ms
  32     10157   126.56 MB/sec  execute   8 sec  latency 87.467 ms
  32     10887   130.10 MB/sec  execute   9 sec  latency 96.489 ms
  32     11438   122.38 MB/sec  execute  10 sec  latency 90.128 ms
  32     12208   122.89 MB/sec  execute  11 sec  latency 92.045 ms
  32     12972   120.20 MB/sec  execute  12 sec  latency 94.190 ms
  32     13816   125.98 MB/sec  execute  13 sec  latency 90.340 ms
  32     14554   128.38 MB/sec  execute  14 sec  latency 108.160 ms
  32     15118   123.54 MB/sec  execute  15 sec  latency 92.951 ms
  32     15851   123.30 MB/sec  execute  16 sec  latency 108.711 ms
  32     16603   121.69 MB/sec  execute  17 sec  latency 150.380 ms
  32     17364   124.62 MB/sec  execute  18 sec  latency 121.116 ms
  32     18080   126.14 MB/sec  execute  19 sec  latency 94.001 ms
  32     18703   123.22 MB/sec  execute  20 sec  latency 86.963 ms
  32     19457   123.15 MB/sec  execute  21 sec  latency 123.935 ms
  32     20251   122.11 MB/sec  execute  22 sec  latency 180.919 ms
  32     21108   125.93 MB/sec  execute  23 sec  latency 77.491 ms
  32     21787   126.16 MB/sec  execute  24 sec  latency 93.703 ms
  32     22319   123.18 MB/sec  execute  25 sec  latency 101.773 ms
  32     22988   122.54 MB/sec  execute  26 sec  latency 119.395 ms
  32     23671   121.69 MB/sec  execute  27 sec  latency 129.959 ms
  32     24433   123.03 MB/sec  execute  28 sec  latency 106.750 ms
  32     25171   124.27 MB/sec  execute  29 sec  latency 101.290 ms
  32  cleanup  30 sec
   0  cleanup  31 sec

 Operation      Count    AvgLat    MaxLat
 ----------------------------------------
 NTCreateX     119289     1.508   118.125
 Close          87850     0.064    44.294
 Rename          5073     3.515    74.980
 Unlink         23951     2.804   106.717
 Qpathinfo     107532     0.803    89.710
 Qfileinfo      18802     0.038    27.088
 Qfsinfo        19816     0.160    34.187
 Sfileinfo       9848     1.363    74.187
 Find           41615     2.182    49.285
 WriteX         58997     0.791    89.477
 ReadX         186546     0.135   131.798
 LockX            384     0.395    12.860
 UnlockX          384     0.351    29.222
 Flush           8564    44.629   180.862

Throughput 124.27 MB/sec  32 clients  32 procs  max_latency=180.919 ms
````

测试输出解读

**准备阶段（Preparation）**

````
31 of 32 processes prepared for launch   0 sec
32 of 32 processes prepared for launch   0 sec
releasing clients
````

- **解析**: 32个模拟客户端进程在 0 秒内全部准备就绪并立即启动。这说明系统资源充足，没有因为进程创建或初始化导致阻塞。

**预热阶段（warmup）**

```
32       716   665.80 MB/sec  warmup   1 sec  latency 86.551 ms
...
32      3706   245.56 MB/sec  warmup   5 sec  latency 84.655 ms
```

- 前几秒（共5秒）是预热（warmup），让系统进入稳定状态，这些数据**不纳入最终统计**。
- 预热时吞吐量波动很大（从665 MB/s骤降到109 MB/s），这是正常的，因为缓存、资源分配等尚未稳定。

**执行阶段（execute）**

````
32      4966   109.48 MB/sec  execute   1 sec  latency 100.997 ms
...
32     25171   124.27 MB/sec  execute  29 sec  latency 101.290 ms
````

- 从 `execute 1 sec` 到 `execute 29 sec` 共29秒，记录了每秒的瞬时吞吐量和延迟。
- 执行阶段吞吐量稳定在 **93 ~ 130 MB/s** 之间，最终平均值即为最后的 **124.27 MB/s**。
- 每行的第二列（如 `5697`）是**累计完成的操作数量**，可忽略其具体数值。

**操作类型统计表（Operation Table）**

这是最详细的性能分解，列出了测试中执行的14类文件系统操作。每一行含义如下：

| 操作          | 计数    | 平均延迟 (ms) | 最大延迟 (ms) | 说明                               |
| :------------ | :------ | :------------ | :------------ | :--------------------------------- |
| **NTCreateX** | 119,289 | 1.508         | 118.125       | 创建文件（模拟Windows NT创建语义） |
| **Close**     | 87,850  | 0.064         | 44.294        | 关闭文件                           |
| **Rename**    | 5,073   | 3.515         | 74.980        | 重命名文件/目录                    |
| **Unlink**    | 23,951  | 2.804         | 106.717       | 删除文件                           |
| **Qpathinfo** | 107,532 | 0.803         | 89.710        | 查询路径信息（如文件属性）         |
| **Qfileinfo** | 18,802  | 0.038         | 27.088        | 查询已打开文件的属性               |
| **Qfsinfo**   | 19,816  | 0.160         | 34.187        | 查询文件系统信息（如空间）         |
| **Sfileinfo** | 9,848   | 1.363         | 74.187        | 设置文件属性                       |
| **Find**      | 41,615  | 2.182         | 49.285        | 查找文件（如通配符搜索）           |
| **WriteX**    | 58,997  | 0.791         | 89.477        | 写入数据                           |
| **ReadX**     | 186,546 | 0.135         | 131.798       | 读取数据                           |
| **LockX**     | 384     | 0.395         | 12.860        | 锁定文件区域                       |
| **UnlockX**   | 384     | 0.351         | 29.222        | 解锁文件区域                       |
| **Flush**     | 8,564   | 44.629        | 180.862       | 将数据强制刷入磁盘                 |

**最终结果行**

````
Throughput 124.27 MB/sec  32 clients  32 procs  max_latency=180.919 ms
````

- **吞吐量**：124.27 MB/s —— 这是测试期间的平均数据传输率，是衡量文件系统性能的核心指标。
- **最大延迟**：180.919 ms —— 所有操作中最长的一次响应时间，通常出现在 `Flush` 操作（180.862 ms），说明写刷盘偶尔会有明显延迟。




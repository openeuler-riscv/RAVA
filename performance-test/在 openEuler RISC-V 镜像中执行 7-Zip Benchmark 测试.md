## 在 openEuler RISC-V 镜像中执行 7-Zip Benchmark 测试

### 1. 7-Zip Benchmark 介绍

**7-Zip Benchmark** 是 7-Zip 内置的**CPU + 内存性能基准测试**，核心用 **LZMA 压缩 / 解压**做密集计算，输出 **MIPS（百万指令 / 秒）** 与 **MB/s**，常用于：

- 测评 **CPU 整数运算、缓存、内存带宽**
- 对比不同架构（RISC-V/ARM/x86）、内核、编译器性能
- 压测系统稳定性（长时间高负载）

测试分两部分：

1. **Compressing（LZMA 压缩）**：重内存带宽 + 缓存延迟
2. **Decompressing（LZMA 解压）**：重 CPU 整数运算

输出关键指标：

- **MIPS**：归一化性能值（对比 Intel Core 2 Duo E6600）
- **MB/s**：压缩 / 解压吞吐
- **Dict**：字典大小（2^N，越大越吃内存）
- **CPU Usage**：线程利用率

### 2. 执行测试

安装

````
$ dnf install -y p7zip
$ 7za -h

7-Zip (a) 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=C.UTF-8,Utf16=on,HugeFiles=on,64 bits,8 CPUs LE)

Usage: 7za <command> [<switches>...] <archive_name> [<file_names>...]
       [<@listfiles...>]

<Commands>
  a : Add files to archive
  b : Benchmark
  d : Delete files from archive
  e : Extract files from archive (without using directory names)
  h : Calculate hash values for files
  i : Show information about supported formats
  l : List contents of archive
  rn : Rename files in archive
  t : Test integrity of archive
  u : Update files to archive
  x : eXtract files with full paths

<Switches>
  -- : Stop switches parsing
  -ai[r[-|0]]{@listfile|!wildcard} : Include archives
  -ax[r[-|0]]{@listfile|!wildcard} : eXclude archives
  -ao{a|s|t|u} : set Overwrite mode
  -an : disable archive_name field
  -bb[0-3] : set output log level
  -bd : disable progress indicator
  -bs{o|e|p}{0|1|2} : set output stream for output/error/progress line
  -bt : show execution time statistics
  -i[r[-|0]]{@listfile|!wildcard} : Include filenames
  -m{Parameters} : set compression Method
    -mmt[N] : set number of CPU threads
  -o{Directory} : set Output directory
  -p{Password} : set Password
  -r[-|0] : Recurse subdirectories
  -sa{a|e|s} : set Archive name mode
  -scc{UTF-8|WIN|DOS} : set charset for for console input/output
  -scs{UTF-8|UTF-16LE|UTF-16BE|WIN|DOS|{id}} : set charset for list files
  -scrc[CRC32|CRC64|SHA1|SHA256|*] : set hash function for x, e, h commands
  -sdel : delete files after compression
  -seml[.] : send archive by email
  -sfx[{name}] : Create SFX archive
  -si[{name}] : read data from stdin
  -slp : set Large Pages mode
  -slt : show technical information for l (List) command
  -snh : store hard links as links
  -snl : store symbolic links as links
  -sni : store NT security information
  -sns[-] : store NTFS alternate streams
  -so : write data to stdout
  -spd : disable wildcard matching for file names
  -spe : eliminate duplication of root folder for extract command
  -spf : use fully qualified file paths
  -ssc[-] : set sensitive case mode
  -ssw : compress shared files
  -stl : set archive timestamp from the most recently modified file
  -stm{HexMask} : set CPU thread affinity mask (hexadecimal number)
  -stx{Type} : exclude archive type
  -t{Type} : Set type of archive
  -u[-][p#][q#][r#][x#][y#][z#][!newArchiveName] : Update options
  -v{Size}[b|k|m|g] : Create volumes
  -w[{path}] : assign Work directory. Empty path means a temporary directory
  -x[r[-|0]]{@listfile|!wildcard} : eXclude filenames
  -y : assume Yes on all queries
````

执行测试

````
# 全线程 + 关闭进度 + 输出耗时，适合CI/自动化
$ 7za b -bd -bt

7-Zip (a) 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=en_US.UTF-8,Utf16=on,HugeFiles=on,64 bits,8 CPUs LE)

LE
CPU Freq: 9142857 16000000 16000000 16000000 21333333 51200000 73142857 204800000 341333333

RAM size:    7663 MB,  # CPU hardware threads:   8
RAM usage:   1765 MB,  # Benchmark threads:      8

                       Compressing  |                  Decompressing
Dict     Speed Usage    R/U Rating  |      Speed Usage    R/U Rating
         KiB/s     %   MIPS   MIPS  |      KiB/s     %   MIPS   MIPS

22:        857   498    167    834  |      12818   742    147   1093
23:        996   550    185   1016  |      12459   726    149   1078
24:        933   506    198   1004  |      14062   742    166   1234
25:       1067   563    217   1219  |      12962   724    159   1154
----------------------------------  | ------------------------------
Avr:             530    192   1018  |              734    155   1140
Tot:             632    174   1079
````

测试结果解析

1)基础环境信息

````
7-Zip (a) 16.02 : Copyright (c) 1999-2016 Igor Pavlov : 2016-05-21
p7zip Version 16.02 (locale=en_US.UTF-8,Utf16=on,HugeFiles=on,64 bits,8 CPUs LE)

LE
CPU Freq: 9142857 16000000 16000000 16000000 21333333 51200000 73142857 204800000 341333333

RAM size:    7663 MB,  # CPU hardware threads:   8
RAM usage:   1765 MB,  # Benchmark threads:      8
````

架构 / 系统：64 位小端 (LE)，当前系统为 `riscv64`

硬件线程：共 8 个逻辑 CPU，测试启用 8 线程满跑

内存：总内存 7663 MB，测试过程占用 1765 MB

CPU Freq：各核心实时运行频率（单位 Hz）

2)表头字段说明（核心列定义）

分为两大块：Compressing 压缩、Decompressing 解压

| 字段        | 含义                                                         |
| ----------- | ------------------------------------------------------------ |
| Dict        | 字典大小，`22`/`23` 代表 `2^22 KiB`、`2^23 KiB`，字典越大，对内存 / 缓存压力越高 |
| Speed KiB/s | 吞吐速度，单位：千字节 / 秒                                  |
| Usage %     | 整体 CPU 占用率（多线程累加，8 线程满负载理论上限 800%）     |
| R/U MIPS    | 原始单线程 MIPS（Raw）                                       |
| Rating MIPS | **综合评分 MIPS**（最终对外参考的性能值，重点指标）          |

3)单轮数据解读（以 Dict=22 为例）

````
22:        857   498    167    834  |      12818   742    147   1093
````

压缩侧

- 吞吐：`857 KiB/s`
- CPU 占用：`498%`（8 线程，负载中等）
- 单线程算力：`167 MIPS`
- 综合评分：`834 MIPS`

解压侧

- 吞吐：`12818 KiB/s`（解压远快于压缩，是 7Z 典型特征）
- CPU 占用：`742%`（解压 CPU 负载更高）
- 单线程算力：`147 MIPS`
- 综合评分：`1093 MIPS`

规律：解压吞吐、CPU 负载普遍高于压缩，属于 LZMA 算法正常表现。

4)平均值 & 总计（最终结论，重点关注）

````
Avr:             530    192   1018  |              734    155   1140
Tot:             632    174   1079
````

Avr（各字典档位平均值）

- 压缩平均：综合评分 1018 MIPS
- 解压平均：综合评分 1140 MIPS

Tot（全局总综合得分，最核心指标）

- 全局综合评分：1079 MIPS
- 这是整机 7-Zip 基准的最终性能值，用于版本 / 硬件横向对比。








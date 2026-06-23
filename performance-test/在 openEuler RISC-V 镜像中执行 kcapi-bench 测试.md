## 在 openEuler RISC-V 镜像中执行 kcapi-bench 测试

### 1. kcapi-bench 介绍

`kcapi-bench` 是一个专门用于测试 Linux 内核加密 API（Kernel Crypto API）性能的命令行工具。它主要用于评估系统内核级加密算法的处理速度，通过在用户态调用内核加密接口来测量吞吐量、延迟和 CPU 占用率，常被用于性能调优或硬件加速验证。

### 核心功能与用途

- **算法覆盖**：支持 AES、SHA、GHASH、RSA 等主流加密哈希算法。
- **测试模式**：支持同步和异步两种接口调用方式。
- **关键指标**：通常输出每秒操作数或吞吐量（MiB/s），以及处理耗时。

### 2. 执行测试

从源码编译安装

````
$ dnf install -y git gcc make autoconf automake libtool
$ git clone https://github.com/smuellerDD/libkcapi.git
$ cd libkcapi
$ autoreconf -i
$ ./configure --enable-kcapi-speed
$ make -j$(nproc)
$ make install
$ kcapi-speed

AF_ALG Kernel Crypto API Speed Test

Kernel Crypto API interface library version: libkcapi 1.5.1
Reported numeric version number 1050100

Usage:
        -a --all        Execute all ciphers
        -l --list       List available ciphers
        -c --cipher     Cipher/cipher type to test
        -t --time       Execution time in seconds
        -b --blocks     Number of blocks to process
        -r --raw        Print out raw numbers for postprocessing
        -v --vmsplice   Use vmsplice kernel interface
        -s --sendmsg    Use sendmsg kernel interface
        -o --aio        Use AIO interface with given number of IOVECs
````

 核心功能选项

| 选项 | 长选项     | 说明                                                         | 使用示例                       |
| :--- | :--------- | :----------------------------------------------------------- | :----------------------------- |
| `-l` | `--list`   | **列出可用的加密算法** 显示当前内核支持的 cipher、hash、aead 等算法列表，是测试前的侦察工具。 | `kcapi-speed -l`               |
| `-c` | `--cipher` | **指定要测试的算法** 必须与内核支持的算法名称完全一致，如 `aes-128-gcm`、`sha256`、`cbc(aes)`。 | `kcapi-speed -c "aes-256-xts"` |
| `-a` | `--all`    | **测试所有支持的算法** 依次测试 `-l` 列出的每个算法，耗时较长，常用于全面性能评估。 | `kcapi-speed -a -t 2`          |

测试控制选项

| 选项 | 长选项     | 说明                                                         | 使用场景                               |
| :--- | :--------- | :----------------------------------------------------------- | :------------------------------------- |
| `-t` | `--time`   | **运行时长（秒）** 指定每个测试持续的时间，默认通常为 5 秒。值越大，结果越稳定。 | `kcapi-speed -c "aes-128-gcm" -t 10`   |
| `-b` | `--blocks` | **数据块大小（字节）** 设置每次操作处理的数据块大小，用于模拟不同业务场景（如 512B 网络包 vs 1MB 文件块）。 | `kcapi-speed -c "aes-128-gcm" -b 4096` |

注意：`-t` 和 `-b` 通常**二选一**，不能同时使用。

- 用 `-t`：固定时间，测试吞吐量。

- 用 `-b`：固定块大小，测试单次操作延迟。

内核接口选项（性能调优）

| 选项 | 长选项       | 说明                                                         | 特点                                       |
| :--- | :----------- | :----------------------------------------------------------- | :----------------------------------------- |
| `-s` | `--sendmsg`  | **使用 sendmsg 系统调用接口** libkcapi 的默认方法，通用性强，适合大多数场景。 | 兼容性好，零拷贝支持有限。                 |
| `-v` | `--vmsplice` | **使用 vmsplice + splice 接口** 通过管道传递内存页，可实现真正的零拷贝，**大块数据时性能可能显著提升**。 | 需内核支持，小数据块可能有额外开销。       |
| `-o` | `--aio`      | **使用异步 I/O 接口** 指定 IOVEC（分散/聚集向量）数量，允许批量提交请求，**对高并发/批量操作有利**。 | 提供最大吞吐潜力，但实现复杂，需测试验证。 |

输出格式选项

| 选项 | 长选项  | 说明                                                         | 用途                     |
| :--- | :------ | :----------------------------------------------------------- | :----------------------- |
| `-r` | `--raw` | **输出原始数值** 仅打印数字结果（如吞吐量、操作次数），便于脚本解析或导入电子表格。 | 批量测试、性能数据分析。 |

查询本机内核支持哪些算法

````
$ kcapi-speed -l
````

单个算法测速

````
# 测试 SM3 哈希算法，跑5秒
$ kcapi-speed -c sm3 -t 5
SM3(G)                  |d|     256 bytes|                2.28 MB/s|8929 ops/s
````

不同数据块大小的测试

````
# 测试 SHA-256 哈希算法, 1024 字节的数据块
$ kcapi-speed -c sha256 -b 1024
kcapi-speed -c sha256 -b 1024
SHA-256(G)              |d|   65536 bytes|               20.99 MB/s|320 ops/s
cryptoperf: could not allocate shash handle for sha256-ssse3
cryptoperf: initialization for SHA-256(SSSE3) failed
````

全量算法遍历测试

````
$ kcapi-speed -a -t 5
````

测试结果：

````
SM3(G) | 256 bytes | 2.28 MB/s | 8929 ops/s
````

Throughput：吞吐 **MB/s（核心指标，优先看）**

- 含义：单位时间加密 / 哈希处理数据总量
- 判定：**数值越大性能越好**
- 场景：业务大包传输、文件加密看此项

OPS：ops/s（每秒运算次数，小包场景核心）

- 含义：每秒完成完整算法运算次数
- 判定：**数值越大性能越好**
- 场景：短报文、网络小包、频繁零碎加密

附加标记

- `(G)`：Generic 内核通用软件实现（无硬件加速）
- `(H)`：Hardware 硬件加速（RISC-V Zk/AES-NI），同算法 MB/s、OPS 成倍提升
- `256 bytes`：测试数据块尺寸（工具固定，不可通过参数修改）
- `d` = decrypt 解密；`e` = encrypt 加密




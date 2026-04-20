## 在 openEuler RISC-V 镜像中执行 memtester 测试

### 1. memtester 介绍

`memtester` 是一个用户空间的内存压力测试工具，主要用于检测系统内存子系统的稳定性和可靠性。它通过分配指定大小的内存块并进行多种模式的读写操作来捕捉内存错误，尤其擅长发现间歇性、非确定性的内存故障。

**核心功能与特点**

| 特点               | 说明                                                         |
| :----------------- | :----------------------------------------------------------- |
| **用户空间工具**   | 无需重启系统，可在操作系统运行时直接测试空闲内存             |
| **多种测试模式**   | 包括随机值、异或比较、减法/乘法/除法、位翻转、棋盘格、Walking 1/0 等十几种测试算法 |
| **灵活的内存指定** | 可测试任意大小内存，支持 B/K/M/G 单位，也可指定物理地址测试特定区域 |
| **需要 root 权限** | 必须以 root 运行才能用 `mlock` 锁定测试内存页，否则测试会变慢且不准确 |

### 2. 执行测试

memtester 安装

````
$ dnf install -y memtester
````

查看 memtester 命令行格式

````
$ memtester
memtester version 4.6.0 (64-bit)
Copyright (C) 2001-2020 Charles Cazabon.
Licensed under the GNU General Public License version 2 (only).

pagesize is 4096
pagesizemask is 0xfffffffffffff000
need memory argument, in MB

Usage: memtester [-p physaddrbase [-d device]] <mem>[B|K|M|G] [loops]
````

| 参数              | 说明                                                         |
| :---------------- | :----------------------------------------------------------- |
| `-p physaddrbase` | 可选，指定要测试的**物理内存起始地址**（十六进制）。默认为 0。 |
| `-d device`       | 可选，与 `-p` 配合使用，指定内存设备文件（如 `/dev/mem`），默认为 `/dev/mem`。 |
| `<mem>[B|K|M|G]`  | **必选**，要测试的内存大小。可以带单位：`B` 字节、`K` KB、`M` MB、`G` GB。例如 `1G`、`512M`。 |
| `[loops]`         | 可选，测试循环次数。如果省略，则无限循环运行直到手动中断（Ctrl+C） |

memtester 测试的内存大小不能超过系统的空闲内存总量，否则会导致测试失败或系统不稳定

使用 `free -h` 查看当前空闲内存，然后选择小于空闲值的测试大小

````
$ free -h
               total        used        free      shared  buff/cache   available
Mem:           7.5Gi       471Mi       3.9Gi        23Mi       3.3Gi       7.0Gi
Swap:             0B          0B          0B
````

available = 最多能测试的内存

测试 1GB 内存，运行 2 轮后退出

````
$ memtester 1G 2
````

测试 512MB 内存，一直运行直到手动停止

````
$ memtester 512M
````

测试从物理地址 0x1000000 开始的 64KB 内存，仅运行 1 轮

````
$ memtester -p 0x1000000 64K 1
````

测试结果

````
$ memtester 2G 2
memtester version 4.6.0 (64-bit)
Copyright (C) 2001-2020 Charles Cazabon.
Licensed under the GNU General Public License version 2 (only).

pagesize is 4096
pagesizemask is 0xfffffffffffff000
want 2048MB (2147483648 bytes)
got  2048MB (2147483648 bytes), trying mlock ...locked.
Loop 1/2:
  Stuck Address       : ok         
  Random Value        : ok
  Compare XOR         : ok
  Compare SUB         : ok
  Compare MUL         : ok
  Compare DIV         : ok
  Compare OR          : ok
  Compare AND         : ok
  Sequential Increment: ok
  Solid Bits          : ok         
  Block Sequential    : ok         
  Checkerboard        : ok         
  Bit Spread          : ok         
  Bit Flip            : ok         
  Walking Ones        : ok         
  Walking Zeroes      : ok         
  8-bit Writes        : ok
  16-bit Writes       : ok

Loop 2/2:
  Stuck Address       : ok         
  Random Value        : ok
  Compare XOR         : ok
  Compare SUB         : ok
  Compare MUL         : ok
  Compare DIV         : ok
  Compare OR          : ok
  Compare AND         : ok
  Sequential Increment: ok
  Solid Bits          : ok         
  Block Sequential    : ok         
  Checkerboard        : ok         
  Bit Spread          : ok         
  Bit Flip            : ok         
  Walking Ones        : ok         
  Walking Zeroes      : ok         
  8-bit Writes        : ok
  16-bit Writes       : ok

Done.
````

pagesize is 4096：系统页大小 4096 字节（4 KB）

trying mlock ...locked：成功分配并锁定（`mlock` 成功），`mlock` 成功意味着测试内存被锁定在物理内存中，不会被交换出去，保证了测试的完整性。

执行了以下 16 项核心测试：

| 测试项                                       | 含义                                                         |
| :------------------------------------------- | :----------------------------------------------------------- |
| **Stuck Address**                            | 检测地址线是否短路或开路。这是基础测试，若失败后续结果不可信。 |
| **Random Value**                             | 写入随机数据后回读比较，检测随机访问的正确性。               |
| **Compare XOR / SUB / MUL / DIV / OR / AND** | 各种位运算和算术运算的读写一致性测试，确保基本运算单元正常。 |
| **Sequential Increment**                     | 按顺序递增模式测试，验证连续访问的准确性。                   |
| **Solid Bits**                               | 全 0 和全 1 模式测试，检查每个存储单元是否“卡死”在某一状态。 |
| **Block Sequential**                         | 以块为单位进行顺序读写，测试大块数据移动能力。               |
| **Checkerboard**                             | 棋盘格模式（010101… 和 101010…），检测相邻位之间的相互干扰。 |
| **Bit Spread**                               | 高/低位交替模式，测试数据线在整字范围内的传输完整性。        |
| **Bit Flip**                                 | 反复翻转特定位，检测数据位在压力下的稳定性。                 |
| **Walking Ones / Zeroes**                    | 在数据中循环移动一个 1 或 0，逐位检查每条数据线。            |
| **8-bit Writes / 16-bit Writes**             | 分别以 8 位和 16 位宽度写入数据，验证不同粒度的访问兼容性。  |

**全部 `ok`**：说明在测试的这段时间内，这 2GB 内存区域没有出现任何数据错误或位翻转，内存的物理地址线、数据线和存储单元都能稳定工作。








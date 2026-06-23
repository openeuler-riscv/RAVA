## 在 openEuler RISC-V 镜像中执行 mbw 性能测试

### 1. mbw 介绍

**mbw（Memory Bandwidth Benchmark）** 是一款**轻量、开源、专注内存拷贝带宽**的 Linux 命令行工具，核心测 **memcpy / 裸循环 / 分块拷贝** 的用户态内存带宽，单位 MB/s。

**核心原理**

- 分配 2 块相同大小内存（arraysize ×2），一块做源、一块做目标。
- 用三种方式反复拷贝，计时并算带宽：
  - 带宽 = 总拷贝数据量 ÷ 耗时。
- 默认单线程、无缓存优化，模拟普通应用的内存拷贝行为。

**三种测试方法**

1）MEMCPY（-t0，默认）

- 调用系统标准库 **libc memcpy()**。
- 最贴近业务：网络、存储、中间件、容器都用它。
- 受 libc 版本、编译器优化、内核影响最大。

2）DUMB（-t1）

- 裸循环：`for (i=0; i<n; i++) b[i]=a[i]`。
- 无库函数、无优化，测**原始内存读写能力**。
- 用于对比：看 memcpy 比裸循环快 / 慢多少。

3）MCBLOCK（-t2）

- 分块 memcpy：把大内存切成**固定小块（默认 4096B）** 再拷贝。
- 模拟**零碎报文、小对象、碎片化拷贝**场景。
- 块大小可用 `-b <bytes>` 自定义。

### 2. 执行测试

安装

````
$ dnf install -y gcc make git
$ git clone https://github.com/raas/mbw.git
$ cd mbw
$ make  # 直接编译，RISC-V 原生支持
````

查看 mbw 命令支持的参数

````
$ ./mbw -h
mbw memory benchmark v1.5, https://github.com/raas/mbw
Usage: mbw [options] array_size_in_MiB
Options:
        -n: number of runs per test (0 to run forever)
        -a: Don't display average
        -t0: memcpy test
        -t1: dumb (b[i]=a[i] style) test
        -t2: memcpy test with fixed block size
        -b <size>: block size in bytes for -t2 (default: 262144)
        -q: quiet (print statistics only)
(will then use two arrays, watch out for swapping)
'Bandwidth' is amount of data copied over the time this operation took.

The default is to run all tests available.
````

基本语法

````
./mbw [选项] 数组大小_MiB
````

选项详解

| 选项        | 说明                                                      |
| :---------- | :-------------------------------------------------------- |
| `-n <次数>` | 每个测试的运行次数（设为 0 表示无限运行）                 |
| `-a`        | 不显示平均值                                              |
| `-t0`       | memcpy 测试（标准内存复制）                               |
| `-t1`       | dumb 测试（逐个元素赋值：`b[i]=a[i]`）                    |
| `-t2`       | 固定块大小的 memcpy 测试                                  |
| `-b <字节>` | 与 `-t2` 配合使用，指定块大小（默认 262144 字节 = 256KB） |
| `-q`        | 安静模式（只显示统计结果）                                |

````
测试 256MB，跑 10 次（默认）
$ ./mbw 256

跑 10 次、静默输出（只看结果）
$ ./mbw -q -n 10 256

更大内存（建议不超过内存 1/2，避免 OOM）
$ ./mbw -q -n 5 1024   # 1GB
````

参数说明

- `-q`：安静模式，不打印每次详情
- `-n N`：循环 N 次
- `SIZE`：测试内存大小（MB）




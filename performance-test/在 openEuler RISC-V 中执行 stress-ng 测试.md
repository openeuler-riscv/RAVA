## 在 openEuler RISC-V 中执行 stress-ng 测试

### 1. stress-ng 测试

**stress-ng** 是 Linux 系统下功能最强大的**系统压力测试工具**之一。它是经典工具 `stress` 的增强版（Next Generation），不仅支持传统的 CPU、内存、磁盘 I/O 压力测试，还涵盖了网络、文件系统、进程调度、中断等 **200 多种** 不同的压力测试场景（Stressors）。

它主要用于：

- **稳定性测试**：让系统在极限负载下运行，检测硬件故障（如散热不良、内存位翻转）或内核 Bug。

- **性能基准**：评估系统在高负载下的吞吐量下降情况。

- **调优验证**：验证内核参数调整或调度策略优化后的效果。

- **故障复现**：模拟特定资源耗尽场景（如 OOM），复现生产环境的偶发故障。

### 2. 执行测试

安装 stress-ng

````
$ yum install -y stress-ng
$ stress-ng --version                 # 验证安装
````

查询 stress-ng 支持的选项和参数

````
$ stress-ng --help
````

stress-ng 拥有超过 270 种不同的压力测试器（ stressors ），其参数主要分为通用控制、资源特定和输出监控三大类。

**通用控制选项**

这些选项用于控制测试的整体行为，如运行时间、并发量、测试方式等。

| 选项                      | 作用与示例                                                   | 关键说明                                           |
| :------------------------ | :----------------------------------------------------------- | :------------------------------------------------- |
| **`-t N`, `--timeout N`** | **指定测试持续时间**。`N` 可以是纯数字（秒），或带单位 `s`（秒）、`m`（分）、`h`（时）、`d`（天）。 示例：`stress-ng --cpu 4 --timeout 60s` （CPU满载运行60秒） | 几乎所有测试都需要设置，避免无限运行。             |
| **`-a N`, `--all N`**     | **并行启动N个所有类型的压力测试器**。`N` 可以是数字或百分比。 示例：`stress-ng --all 4 -t 5m` （并行运行4组所有压力测试，持续5分钟） | 快速给系统施加全方位压力。                         |
| **`--sequential N`**      | **顺序（而非并行）运行所有压力测试器**，每个默认运行60秒。`N` 为每个测试器的实例数。 示例：`stress-ng --sequential 2 -t 30s` （依次运行所有测试，每个测试2个实例，运行30秒） | 适合逐一排查不同子系统的问题。                     |
| **`-x, --exclude`**       | **排除指定的压力测试器**，常与 `--all` 或 `--sequential` 联用。 示例：`stress-ng --class cpu --all 1 -x numa, hsearch` （运行所有CPU类测试，但排除numa和hsearch） | 当你知道某些测试可能引起问题或不需要时，可以跳过。 |

**资源特定选项**

这是 stress-ng 的核心，用来指定对系统哪个部分施压。你可以通过组合多个选项来模拟复杂的真实负载。

| 资源类型 | 选项               | 作用与示例                                                   | 补充说明                                                   |
| :------- | :----------------- | :----------------------------------------------------------- | :--------------------------------------------------------- |
| **CPU**  | **`--cpu N`**      | **启动N个CPU压力工作器**，主要进行整数运算、控制流等，让CPU满载。 示例：`stress-ng --cpu 8 --timeout 10m` | 可以结合 `--cpu-method` 指定算法（如 `matrix`、`prime`）。 |
| **CPU**  | **`--matrix N`**   | **启动N个矩阵运算压力器**，对CPU的浮点单元（FPU）和缓存压力极大。 示例：`stress-ng --matrix 1 -t 1m` | 适合测试科学计算场景下的CPU稳定性。                        |
| **内存** | **`--vm N`**       | **启动N个虚拟内存压力工作器**，通过不断分配和释放内存施压。 示例：`stress-ng --vm 2 --vm-bytes 1G -t 60s` | `--vm-bytes` 指定每个工作器操作的缓冲区大小。              |
| **内存** | **`--vm-bytes N`** | 与 `--vm` 联用，**指定每个内存工作器分配的内存块大小**，可使用 `K`、`M`、`G` 等单位。 示例：`stress-ng --vm 2 --vm-bytes 512M -t 60s` | 总内存压力 ≈ `N` × `--vm-bytes`。                          |
| **I/O**  | **`--io N`**       | **启动N个I/O同步压力工作器**，通过频繁调用 `sync()` 系统调用给磁盘和内核施压。 示例：`stress-ng --io 4 -t 60s` | 这主要测试I/O调用的开销，而非读写大文件的吞吐量。          |
| **I/O**  | **`--hdd N`**      | **启动N个磁盘读写压力工作器**，会在临时目录创建文件并进行读写。 示例：`stress-ng --hdd 4 --hdd-bytes 1G -t 60s` | `--hdd-bytes` 指定每个工作器写入的总数据量。               |
| **网络** | **`--sock N`**     | **启动N个网络套接字压力工作器**，模拟大量TCP/UDP连接。 示例：`stress-ng --sock 10 -t 30s` | 可以用来测试网络栈和文件描述符的极限。                     |

**输出与监控选项**

为了量化测试结果，stress-ng 提供了一系列输出选项，帮你分析系统在压力下的行为。

| 选项                  | 作用与示例                                                   | 关键说明                                                     |
| :-------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **`--metrics`**       | **输出详细的性能指标**，包括每次测试的bogo ops（一种操作次数）、用户/系统时间、实时吞吐率等。 示例：`stress-ng --cpu 4 -t 10s --metrics` | **注意**：官方明确指出bogo ops并非精确的benchmark，但可用于观察系统在压力下的行为变化。 |
| **`--metrics-brief`** | **输出简化的、非零的性能指标**，比 `--metrics` 更简洁。 示例：`stress-ng --cpu 4 -t 10s --metrics-brief` | 日常测试推荐使用这个。                                       |
| **`-v, --verbose`**   | **输出详细的运行信息**，包括所有调试、警告和状态信息。 示例：`stress-ng --cpu 4 -t 10s -v` | 在排查问题时非常有用。                                       |
| **`--times`**         | **测试结束时显示所有子进程累计消耗的用户和系统时间**，以及CPU利用率。 示例：`stress-ng --cpu 4 -t 10s --times` | 帮助你分析负载是在用户态还是内核态。                         |
| **`--tz`**            | **收集并显示测试过程中的设备温度变化**（需要硬件支持）。 示例：`stress-ng --cpu 4 -t 60s --tz` | 监测系统在高负载下的散热能力。                               |

**CPU 压力测试**

````
# 使用所有 CPU 核心进行满载测试，持续 60 秒
$ stress-ng --cpu $(nproc) --timeout 60s  

# 指定 4 个核心，使用矩阵乘法算法（更侧重浮点/整数混合运算）
$ stress-ng --cpu 4 --cpu-method matrixprod --timeout 30s
````

关键参数：

- `--cpu N`：启动 N 个 CPU 压力线程。
- `--cpu-method <算法>`：指定计算方法，如 `fft` (快速傅里叶变换), `matrixprod`, `sin`, `hanoi` 等。不同算法对 CPU 流水线、缓存和 FPU 的压力不同。
- `--cpu-load P`：设置 CPU 负载百分比（例如 `--cpu-load 50` 让 CPU 保持在 50% 负载而非 100%）。

**内存（VM）压力测试**

分配大量内存并频繁读写，测试内存子系统的稳定性、带宽以及触发 OOM (Out Of Memory) Killer。

````
# 启动 2 个内存测试进程，每个进程尝试分配并触摸 1GB 内存，持续 60 秒
$ stress-ng --vm 2 --vm-bytes 1G --timeout 60s

# 快速填满剩余可用内存（常用于测试 OOM）
$ stress-ng --vm 1 --vm-bytes 90% --timeout 30s
````

关键参数：

- `--vm N`：启动 N 个内存压力线程。
- `--vm-bytes B`：每个线程分配的内存大小（支持 `K, M, G, %`）。
- `--vm-hang`：分配内存后挂起（不释放），用于模拟内存泄漏或永久占用。

**磁盘 I/O 压力测试**

模拟频繁的读写操作，测试存储子系统（硬盘/SSD）的性能和文件系统稳定性。

````
# 启动 4 个 I/O 线程，进行随机读写测试
$ stress-ng --io 4 --timeout 60s

# 针对特定目录进行文件创建/删除压力测试
$ stress-ng --file 10 --file-dir /tmp --timeout 30s
````

关键参数：

- `--io N`：启动 N 个 I/O 同步读写线程。
- `--hdd N`：启动 N 个线程进行顺序写（类似 `dd`），更侧重磁盘吞吐。
- `--file N`：频繁创建、写入、删除文件，测试文件系统元数据性能。

**混合压力测试 (全系统烤机)**

同时施加多种压力，模拟真实的高负载生产环境。

````
# CPU 满载 + 内存占满 80% + 磁盘 IO 压力，持续 5 分钟
$ stress-ng --cpu $(nproc) --vm 2 --vm-bytes 80% --io 4 --timeout 5m --metrics-brief
````

测试结果

````
$ stress-ng --cpu $(nproc) --timeout 60s
stress-ng: info:  [11751] setting to a 1 min run per stressor
stress-ng: info:  [11751] dispatching hogs: 8 cpu
stress-ng: info:  [11751] skipped: 0
stress-ng: info:  [11751] passed: 8: cpu (8)
stress-ng: info:  [11751] failed: 0
stress-ng: info:  [11751] metrics untrustworthy: 0
stress-ng: info:  [11751] successful run completed in 1 min, 1.06 sec
````

````
$ stress-ng --cpu $(nproc) --timeout 60s --metrics-brief
stress-ng: info:  [11791] setting to a 1 min run per stressor
stress-ng: info:  [11791] dispatching hogs: 8 cpu
stress-ng: metrc: [11791] stressor       bogo ops real time  usr time  sys time   bogo ops/s     bogo ops/s
stress-ng: metrc: [11791]                           (secs)    (secs)    (secs)   (real time) (usr+sys time)
stress-ng: metrc: [11791] cpu                7925     60.69    480.26      0.06       130.58          16.50
stress-ng: info:  [11791] skipped: 0
stress-ng: info:  [11791] passed: 8: cpu (8)
stress-ng: info:  [11791] failed: 0
stress-ng: info:  [11791] metrics untrustworthy: 0
stress-ng: info:  [11791] successful run completed in 1 min, 1.07 sec
````

测试结果解读：

````
stress-ng: info:  [11791] setting to a 1 min run per stressor
stress-ng: info:  [11791] dispatching hogs: 8 cpu
````

- 设置每个压力测试运行1分钟。
- 启动了 8个 CPU 压力工作器（因为待测系统的 CPU 核心数为8，`$(nproc)` 返回8）。

````
stress-ng: metrc: [11791] stressor       bogo ops real time  usr time  sys time   bogo ops/s     bogo ops/s
stress-ng: metrc: [11791]                           (secs)    (secs)    (secs)   (real time) (usr+sys time)
stress-ng: metrc: [11791] cpu                7925     60.69    480.26      0.06       130.58          16.50
````

这是核心的数据行，表格各列含义如下：

| 列名                          | 值     | 解释                                                         |
| :---------------------------- | :----- | :----------------------------------------------------------- |
| **stressor**                  | cpu    | 压力器类型，此处为 CPU 压力测试。                            |
| **bogo ops**                  | 7925   | 所有 CPU 工作器在测试期间执行的 **bogo 操作总数**。bogo ops 是 stress-ng 自定义的一种操作计数，用于相对比较，**不是精确的基准指标**。 |
| **real time (secs)**          | 60.69  | 测试实际经过的**墙上时间**（约60.69秒），略高于请求的60秒（含启动/停止开销）。 |
| **usr time (secs)**           | 480.26 | 所有 CPU 工作器在**用户态**消耗的 CPU 时间总和。8 个核心跑 60 秒的理想最大用户时间约为 8×60 = 480 秒，480.26 秒非常接近，说明 CPU 工作器几乎一直满载运行在用户态。 |
| **sys time (secs)**           | 0.06   | 所有 CPU 工作器在**内核态**消耗的 CPU 时间总和（极少，说明几乎无系统调用）。 |
| **bogo ops/s (real time)**    | 130.58 | 基于墙上时间的每秒 bogo 操作数：`7925 / 60.69 ≈ 130.58`，反映系统整体的吞吐率。 |
| **bogo ops/s (usr+sys time)** | 16.50  | 基于总 CPU 时间的每秒 bogo 操作数：`7925 / (480.26 + 0.06) ≈ 16.50`，反映每个 CPU 秒的处理能力。 |

````
stress-ng: info:  [11791] skipped: 0
stress-ng: info:  [11791] passed: 8: cpu (8)
stress-ng: info:  [11791] failed: 0
stress-ng: info:  [11791] metrics untrustworthy: 0
stress-ng: info:  [11791] successful run completed in 1 min, 1.07 sec
````

- **skipped: 0**：没有跳过任何压力测试。
- **passed: 8: cpu (8)**：8 个 CPU 压力测试全部通过。
- **failed: 0**：没有失败。
- **metrics untrustworthy: 0**：所有指标可信（无异常警告）。
- **successful run completed**：测试成功完成，总耗时 1 分 1.07 秒。




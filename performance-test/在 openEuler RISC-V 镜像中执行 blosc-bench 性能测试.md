

## 在 openEuler RISC-V 镜像中执行 blosc-bench 性能测试

### 1. blosc-bench 介绍

blosc-bench 是一个用于评估 Blosc 压缩库性能的基准测试工具集

### 2. jmh-core-benchmarks 执行测试

#### 2.1 安装

安装依赖包

````
$ dnf install -y blosc-bench
````

#### 2.2 执行测试

blosc-bench 支持的命令行格式：

Usage: blosc-bench [blosclz | lz4 | lz4hc | zlib | zstd] [noshuffle | shuffle | bitshuffle] [single | suite | hardsuite | extremesuite | debugsuite] [nthreads] [bufsize(bytes)] [typesize] [sbits]

参数解释：

| 位置 | 作用                              | 可选值                                                       | 说明                                                         |
| :--- | :-------------------------------- | :----------------------------------------------------------- | ------------------------------------------------------------ |
| 1    | 压缩器（compressor）              | `blosclz`, `lz4`, `lz4hc`, `zlib`, `zstd`                    | 选择要测试的压缩算法                                         |
| 2    | 数据重排方式（filter)             | `noshuffle`, `shuffle`, `bitshuffle`                         | 数据预处理方式<br>`noshuffle`（不进行重排）: 不对数据做任何重排，直接交给压缩器处理。常用于数据已经是随机分布或无明显字节模式（如加密数据、高熵数据），或者数据类型不适用 shuffle（例如单字节字符流）。效果是压缩比通常较低，但处理开销最小<br>`shuffle`：将数据按类型大小（typesize） 拆分成字节，然后将每个元素相同偏移的字节重新组合在一起。例如，对于 4 字节整数数组 `[a0,a1,a2,...]`（每个整数 4 字节），原始连续存储为 `byte0_0, byte1_0, byte2_0, byte3_0, byte0_1, byte1_1, ...`。`shuffle` 后变成 `byte0_0, byte0_1, ...`（所有元素的第一个字节），然后是 `byte1_0, byte1_1, ...` 等。这样使得每个字节流中连续字节的值通常更相似，从而更容易被压缩器（如 blosclz, lz4, zstd）发现重复模式。常用于同质化的数值数组（整数、浮点数），尤其是数据值变化缓慢或具有同字节模式时，或者压缩器对字节级重复敏感时，改善压缩率。效果是显著提高压缩比，特别是对于低有效位的数值数据。开销很小<br>`bitshuffle`：在 `shuffle` 的基础上进一步细化到位级别。它将数据按位拆分，将每个元素相同位的位置组合在一起。例如，对于 8 字节的 double 数组，`bitshuffle` 会提取所有元素的第 0 位组成一个位流，第 1 位组成另一个位流，...，第 63 位组成第 64 个位流。然后将这些位流按字节打包后再进行压缩。 使用场景是浮点数数组（尤其是科学数据、传感器数据），这些数据的相邻值通常只在低有效位上变化，高位相同，或者整数数据中，如果数值范围有限，高位多为 0，`bitshuffle` 能大量产生连续的 0 位，极易压缩。效果是能达到极高的压缩比（例如从 8 字节/值压缩到远小于 1 字节/值），但需要略微更多的 CPU 开销（位操作）。常与 `zstd` 或 `lz4` 配合使用，在 HDF5 等场景中表现优异。 |
| 3    | 测试集（testset）                 | `single`, `suite`, `hardsuite`, `extremesuite`, `debugsuite` | 测试数据集。`suite` 是标准测试集（约几十MB），`hardsuite` 极大数据集（几TB），耗时长。 |
| 4    | 线程数（nthreads）                | 整数，例如 `1`, `2`, `4`                                     | 使用的线程数，例如 `1`, `2`, `4`。                           |
| 5    | 字节数（bufsize）                 | 整数                                                         | 每个数据块的大小，例如 `1048576`（1MB）。                    |
| 6    | 数据类型的字节大小（typesize）    | 整数                                                         | 数据类型的字节大小，如 `4` 表示 int32/float32。              |
| 7    | 用于 `bitshuffle` 的位数（sbits） | 整数                                                         | 用于 `bitshuffle` 的位数，通常 `0` 表示自动。                |

快速测试（单个线程，默认参数）

````
$ blosc-bench blosclz noshuffle suite 1
````

测试所有压缩算法（多线程）

````
$ for comp in blosclz lz4 lz4hc zlib zstd; do
    blosc-bench $comp suite 4 > ${comp}.txt
done
````

自定义数据块大小和类型

````
$ blosc-bench zstd shuffle suite 4 4194304 8
````

#### 2.3 测试结果

````
$ blosc-bench blosclz noshuffle suite 2
Blosc version: 1.21.5 ($Date:: 2023-05-16 #$)
List of supported compressors in this build: blosclz,lz4,lz4hc,zlib,zstd
Supported compression libraries:
  BloscLZ: 2.5.1
  LZ4: 1.9.4
  Zlib: 1.2.13
  Zstd: 1.5.5
Using compressor: blosclz
Using shuffle type: noshuffle
Running suite: suite
--> 1, 4194304, 8, 19, blosclz, noshuffle
********************** Run info ******************************
Blosc version: 1.21.5 ($Date:: 2023-05-16 #$)
Using synthetic data with 19 significant bits (out of 32)
Dataset size: 4194304 bytes     Type size: 8 bytes
Working set: 256.0 MB           Number of threads: 1
********************** Running benchmarks *********************
memcpy(write):           1937.8 us, 2064.2 MB/s
memcpy(read):             745.6 us, 5364.5 MB/s
Compression level: 0
comp(write):     11091.5 us, 360.6 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    5073.0 us, 788.5 MB/s    OK
Compression level: 1
comp(write):     27439.7 us, 145.8 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    5168.4 us, 773.9 MB/s    OK
Compression level: 2
comp(write):     21311.4 us, 187.7 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    5186.1 us, 771.3 MB/s    OK
Compression level: 3
comp(write):     18234.0 us, 219.4 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    5169.7 us, 773.7 MB/s    OK
Compression level: 4
comp(write):     16731.9 us, 239.1 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    5156.2 us, 775.8 MB/s    OK
Compression level: 5
comp(write):     16741.0 us, 238.9 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    5163.7 us, 774.6 MB/s    OK
Compression level: 6
comp(write):     16784.3 us, 238.3 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    5156.3 us, 775.7 MB/s    OK
Compression level: 7
comp(write):     16752.1 us, 238.8 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    5152.6 us, 776.3 MB/s    OK
Compression level: 8
comp(write):     16740.4 us, 238.9 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    5161.3 us, 775.0 MB/s    OK
Compression level: 9
comp(write):     16761.4 us, 238.6 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    5160.2 us, 775.2 MB/s    OK
--> 2, 4194304, 8, 19, blosclz, noshuffle
********************** Run info ******************************
Blosc version: 1.21.5 ($Date:: 2023-05-16 #$)
Using synthetic data with 19 significant bits (out of 32)
Dataset size: 4194304 bytes     Type size: 8 bytes
Working set: 256.0 MB           Number of threads: 2
********************** Running benchmarks *********************
memcpy(write):           1696.1 us, 2358.3 MB/s
memcpy(read):             725.7 us, 5512.0 MB/s
Compression level: 0
comp(write):     4342.9 us, 921.0 MB/s    Final bytes: 4194320  Ratio: 1.00
decomp(read):    2135.8 us, 1872.9 MB/s   OK
Compression level: 1
comp(write):     14394.5 us, 277.9 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    2059.3 us, 1942.4 MB/s   OK
Compression level: 2
comp(write):     11108.6 us, 360.1 MB/s   Final bytes: 4194320  Ratio: 1.00
decomp(read):    2100.9 us, 1904.0 MB/s   OK
Compression level: 3
comp(write):     9716.9 us, 411.7 MB/s    Final bytes: 4194320  Ratio: 1.00
decomp(read):    2181.5 us, 1833.6 MB/s   OK
Compression level: 4
comp(write):     9289.2 us, 430.6 MB/s    Final bytes: 4194320  Ratio: 1.00
decomp(read):    2061.8 us, 1940.0 MB/s   OK
Compression level: 5
comp(write):     9377.8 us, 426.5 MB/s    Final bytes: 4194320  Ratio: 1.00
decomp(read):    2184.9 us, 1830.8 MB/s   OK
Compression level: 6
comp(write):     9346.1 us, 428.0 MB/s    Final bytes: 4194320  Ratio: 1.00
decomp(read):    2179.2 us, 1835.5 MB/s   OK
Compression level: 7
comp(write):     9340.6 us, 428.2 MB/s    Final bytes: 4194320  Ratio: 1.00
decomp(read):    2181.4 us, 1833.7 MB/s   OK
Compression level: 8
comp(write):     9348.2 us, 427.9 MB/s    Final bytes: 4194320  Ratio: 1.00
decomp(read):    2080.7 us, 1922.4 MB/s   OK
Compression level: 9
comp(write):     9385.8 us, 426.2 MB/s    Final bytes: 4194320  Ratio: 1.00
decomp(read):    2057.3 us, 1944.3 MB/s   OK

Round-trip compr/decompr on 15.0 GB
Elapsed time:      67.7 s, 498.8 MB/s
````

解释以上测试结果

##### 2.3.1 关键参数说明

- 压缩器：blosclz，使用 Blosc 自带的默认压缩算法

- 数据重排：noshuffle，不使用字节重排优化（会导致压缩比极低）

- 测试集：suite，标准测试集

- 测试线程数：2，使用 2 线程
- 数据特征：合成数据（synthetic data），具有 19 个有效位（out of 32），接近随机数据，不可压缩。由于数据不可压缩，所有压缩级别的压缩比（Ratio）均为 1.00，即压缩后大小等于原始大小（加上少量元数据头）。这种情况下，Blosc 的性能主要体现为处理不可压缩数据的开销和吞吐能力。

##### 2.3.2 基础性能

````
memcpy(write): 1937.8 us, 2064.2 MB/s      （1线程）
memcpy(read): 745.6 us, 5364.5 MB/s

memcpy(write): 1696.1 us, 2358.3 MB/s      （2线程）
memcpy(read): 725.7 us, 5512.0 MB/s
````

内存写带宽：~2 GB/s

内存读带宽：~5.3 GB/s

##### 2.3.3 压缩 / 解压缩速度

线程1

````
comp(write): 16740.4 us, 238.9 MB/s
decomp(read): 5161.3 us, 775.0 MB/s
````

线程2

````
comp(write): 9348.2 us, 427.9 MB/s
decomp(read): 2080.7 us, 1922.4 MB/s
````

##### 2.3.4 压缩等级0~9

不同压缩级别表现

| 级别 | 压缩速度 (MB/s) | 解压速度 (MB/s) | 说明                                         |
| :--- | :-------------- | :-------------- | :------------------------------------------- |
| 0    | 360.6           | 788.5           | 最快压缩模式，但压缩比仍为 1.00              |
| 1    | 145.8           | 773.9           | 最慢压缩模式（因尝试压缩随机数据导致耗时）   |
| 2~4  | 187~239         | 771~776         | 逐步优化                                     |
| 5~9  | ~238.8          | ~775            | 稳定在约 239 MB/s（压缩）和 775 MB/s（解压） |

- 对于不可压缩数据，压缩级别 1 最慢，因为 blosclz 会尝试各种匹配策略，最终发现无收益才退出，开销很大。
- 级别 5~9 性能稳定且更快，这是因为 Blosc 内部会快速检测数据难以压缩，提前终止扫描。
- 解压速度始终远快于压缩速度（约 3.2 倍），符合“解压通常比压缩快”的预期。
- 相比 `memcpy` 读取速度（5364 MB/s），解压速度（775 MB/s）约为其 **14%**；相比写入速度（2064 MB/s），压缩速度（239 MB/s）约为 **12%**。对于不可压缩数据，这个开销可接受。

##### 2.3.5 往返吞吐量（Round-trip）

- 数据总量：15.0 GB
- 总耗时：67.7 秒
- 平均吞吐量：498.8 MB/s

这个指标综合了**压缩 + 写入 + 读取 + 解压**的实际端到端性能，比单独看压缩或解压速度更贴近真实应用。双线程下达到 **~500 MB/s**，是单线程下未测的（但可推算单线程往返大约在 200~250 MB/s 左右）。它代表了系统同时处理 I/O 和压缩解压的综合能力。



````
#!/bin/bash

RESULT_FILE="result.txt"
THREADS=2
OUTPUT="$(cat "${RESULT_FILE}")"

# 提取全局固定指标
RATIO=$(echo "$OUTPUT" | awk '/Ratio:/{print $2; exit}')
ROUND_TRIP=$(echo "$OUTPUT" | awk '/Elapsed time:/{print $6}')
echo "blosc_ratio pass $RATIO radio"
echo "blosc_round_trip_mbs $ROUND_TRIP_MBS MB/s"

for ((t=1; t<=THREADS; t++)); do
   block=$(echo "$OUTPUT" | awk -v t="$t" '
       /Number of threads: [0-9]+/ {in_block=0}
       $0 ~ "Number of threads: " t {in_block=1}
       in_block {print}
       /^-->/ {exit}
   ')
   
   # 提取 memcpy
   MEM_R=$(echo "$block" | awk '/memcpy\(read\)/{print $4}')
   MEM_W=$(echo "$block" | awk '/memcpy\(write\)/{print $4}')
   echo "blosc_t${t}_memcpy_read pass $MEM_R MB/s"
   echo "blosc_t${t}_memcpy_write pass $MEM_W MB/s"
   
   # 遍历 level 0~9
   提取 level 0~9
   for lvl in {0..9}; do
       comp=$(echo "$block" | awk -v l="$lvl" '
           $0 ~ "Compression level: " l {getline; print $4; exit}
       ')
       decomp=$(echo "$block" | awk -v l="$lvl" '
           $0 ~ "Compression level: " l {getline; getline; print $3; exit}
       ')
       echo "blosc_t${t}_level${lvl}_comp pass ${comp} MB/s"
       echo "blosc_t${t}_level${lvl}_decomp pass ${decomp} MB/s"
   done
done
   
````






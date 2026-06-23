## 在 openEuler RISC-V 镜像中执行  lzbench 压缩基准测试

### 1. zstd/lz4/lzma 压缩基准测试介绍

这是对三种主流无损压缩算法的**压缩比、压缩速度、解压速度、内存占用**做横向对比的性能测试，常用于选型（数据库 / 日志 / 容器 / 内核）。

#### 1）算法定位（一句话）

- **LZ4**：**速度最快、压缩比最低**，适合实时 / 低延迟场景。
- **ZSTD**：**速度与压缩比均衡**（LZ4 速度 + 接近 LZMA 压缩比），工业界主流。
- **LZMA（xz）**：**压缩比最高、速度最慢**，适合归档 / 冷数据。

#### 2）核心测试指标

- **压缩比**：原始大小 / 压缩后大小（越高越好）。
- **压缩速度**：MB/s（越高越好）。
- **解压速度**：MB/s（越高越好）。
- **内存占用**：压缩 / 解压时 RSS（越低越好）。

#### 3）常用测试工具

- **lzbench**：轻量内存基准，专测这三种算法，结果直观。
- **命令行原生工具**：`zstd`/`lz4`/`xz`（自带`-b` bench 模式）。
- **7-zip**：综合测试，支持多线程。

### 2. 执行测试

生成 1G 随机测试文件

````
$ dd if=/dev/urandom of=test.dat bs=1G count=1 status=none
````

安装 lzbench

````
$ dnf install -y zstd lz4 xz gcc gcc-c++ make git
$ git clone https://github.com/inikep/lzbench.git
$ cd lzbench
$ make -j$(nproc)
$ ./lzbench -h
````

lzbench支持的选项

````
$ # ./lzbench -h
lzbench - in-memory benchmark of open-source compressors

usage: lzbench [options] [input]

where [input] is a file/s or a directory and [options] are:
  -b#   set block/chunk size to # KB, 0=disabled {default: 0}
  -c#   sort results by column # (1=algname, 2=ctime, 3=dtime, 4=comprsize)
  -e#   #=compressors separated by '/' with parameters specified after ',' {fast}
  -h    display this help and exit
  -I#   use # internal threads (if compressor supports it)
  -iX,Y set min. number of compression and decompression iterations {1, 1}
  -j    join files in memory but compress them independently (for many small files)
  -l    list of available compressors and aliases
  -m#   set memory limit to # MB {no limit}
  -o#   output text format 1=Markdown, 2=text, 3=text+origSize, 4=CSV {2}
  -p#   print time for all iterations: 1=fastest 2=average 3=median {1}
  -q    suppress progress information (-qq supresses more)
  -R    read block/chunk size from random blocks (to estimate for large files)
  -r    operate recursively on directories
  -s#   use only compressors with compression speed over # MB {0 MB}
  -T#   use # thread pool threads (works with -b to split input into blocks)
  -tX,Y set min. time in seconds for compression and decompression {1, 2}
  -v    be verbose (-vv gives more)
  -V    output version information and exit
  -x    disable real-time process priority
  -z    show (de)compression times instead of speed

Example usage:
  lzbench -ezstd filename = selects all levels of zstd
  lzbench -ebrotli,2,5/zstd filename = selects levels 2 & 5 of brotli and zstd
  lzbench -t3,5 fname = 3 sec compression and 5 sec decompression loops
  lzbench -t0,0 -i3,5 fname = 3 compression and 5 decompression iterations
  lzbench -o1c4 fname = output markdown format and sort by 4th column
  lzbench -j -r dirname/ = recursively select and join files in given directory
````

`lzbench` 是**内存级压缩算法基准工具**，全程把文件载入内存测试，不受磁盘 IO 干扰，结果只反映算法本身性能。

语法：`lzbench [选项] [测试文件/目录]`

输入内容可以是单个 / 多个文件，也可以是目录。

`-b#`：设置分块大小，单位 KB；`0` 表示禁用分块（默认：0）

`-c#`：按指定列排序结果

列编号：1 = 算法名称，2 = 压缩耗时，3 = 解压耗时，4 = 压缩后大小

`-e#`：指定待测试压缩算法，多算法用 `/` 分隔，算法后用 `,` 指定压缩级别（默认：fast 快速算法组）

`-h`：显示帮助信息并退出

`-I#`：设置算法内部线程数（仅对应算法支持多线程时生效）

`-i X,Y`：设置**压缩、解压**的最小迭代次数（默认：1, 1）

`-j`：将多个文件读入内存合并，但各自独立压缩（适用于大量小文件场景）

`-l`：列出当前支持的所有压缩算法及别名

`-m#`：限制最大内存使用量，单位 MB（默认：不限制）

`-o#`：设置输出格式

1=Markdown 表格，2 = 纯文本（默认），3 = 纯文本 + 原始文件大小，4=CSV 格式

`-p#`：多轮迭代时输出统计值类型

1 = 取最快值（默认），2 = 取平均值，3 = 取中位数

`-q`：屏蔽进度提示；`-qq` 进一步精简输出

`-R`：按随机分块读取数据（用于预估大文件测试效果）

`-r`：递归遍历目录下所有文件

`-s#`：仅保留**压缩速度大于指定 MB/s** 的算法（默认：0 MB，不过滤）

`-T#`：设置线程池线程数（需配合 `-b` 分块参数使用）

`-t X,Y`：设置**压缩、解压**的最小运行时长，单位 秒（默认：1, 2）

`-v`：输出详细日志；`-vv` 输出更多调试信息

`-V`：输出版本信息并退出

`-x`：关闭进程实时优先级提升

`-z`：不展示读写速度，改为直接显示**压缩 / 解压耗时**

示例用法：

````
$ lzbench -ezstd 文件名                  # 测试 zstd 算法的全部压缩级别

$ lzbench -ebrotli,2,5/zstd 文件名       # 测试 brotli 2 级、5 级，以及 zstd 所有级别

$ lzbench -t3,5 文件名                   # 压缩至少运行 3 秒，解压至少运行 5 秒

$ lzbench -t0,0 -i3,5 文件名             # 不限制运行时长，压缩执行 3 轮迭代，解压执行 5 轮迭代

$ lzbench -o1c4 文件名                   # 输出 Markdown 表格格式，并按第 4 列（压缩后大小）排序

$ lzbench -j -r 目录名/                  # 递归读取目录内所有文件，合并载入内存后独立测试
````

列出 lzbench 支持的所有压缩算法、对应版本、可用压缩级别、线程支持，以及预设别名组，方便快速筛选测试对象。

````
$ ./lzbench -l
Available compressors for -e option:
memcpy = memcpy
aceapex = aceapex 1.0; levels=[1-2]; threading=-I,-T
brieflz = brieflz 1.3.0; levels=[1-9]
brotli = brotli 1.2.0; levels=[0-11]
brotli22 = brotli 1.2.0 -d22; levels=[0-11]
brotli24 = brotli 1.2.0 -d24; levels=[0-11]
bsc0 = bsc 3.3.11 -m0 -e2; threading=-I,-T
bsc1 = bsc 3.3.11 -m0 -e1; threading=-I,-T
bsc2 = bsc 3.3.11 -m0 -e0; threading=-I,-T
bsc3 = bsc 3.3.11 -m3 -e1; threading=-I,-T
bsc4 = bsc 3.3.11 -m4 -e1; threading=-I,-T
bsc5 = bsc 3.3.11 -m5 -e1; threading=-I,-T
bsc6 = bsc 3.3.11 -m6 -e1; threading=-I,-T
bzip2 = bzip2 1.0.8; levels=[1-9]
bzip3 = bzip3 1.5.2; levels=[1-10]
crush = crush 1.0; levels=[0-2]; threading=none
csc = csc 2016-10-13; levels=[1-5]
fastlz = fastlz 0.5.0; levels=[1-2]
fastlzma2 = fastlzma2 1.0.1; levels=[1-10]; threading=-I,-T
gipfeli = gipfeli 2016-07-13
glza = glza 0.12; threading=none
kanzi = kanzi 2.5.3; levels=[1-9]; threading=-I,-T
libdeflate = libdeflate 1.25; levels=[1-12]
lizard = lizard 2.1; levels=[10-49]
lz4 = lz4 1.10.0
lz4fast = lz4 1.10.0 --fast; levels=[1-99]
lz4hc = lz4hc 1.10.0; levels=[1-12]
lzav = lzav 5.7; levels=[1-2]
lzf = lzf 3.6; levels=[0-1]
lzfse = lzfse 2017-03-08
lzg = lzg 1.0.10; levels=[1-9]
lzham = lzham 1.0 -d26; levels=[0-4]; threading=-I,-T
lzham22 = lzham 1.0 -d22; levels=[0-4]; threading=-I,-T
lzham24 = lzham 1.0 -d24; levels=[0-4]; threading=-I,-T
lzjb = lzjb 2010
lzlib = lzlib 1.15; levels=[0-9]
lzma = lzma 25.01; levels=[0-9]; threading=-I,-T
lzmat = lzmat 1.01
lzo1 = lzo1 2.10; levels=[1-99]
lzo1a = lzo1a 2.10; levels=[1-99]
lzo1b = lzo1b 2.10; levels=[1-999]
lzo1c = lzo1c 2.10; levels=[1-999]
lzo1f = lzof 2.10; levels=[1-999]
lzo1x = lzo1x 2.10; levels=[1-999]
lzo1y = lzo1y 2.10; levels=[1-999]
lzo1z = lzo1z 2.10
lzo2a = lzo2a 2.10
lzrw = lzrw 15-Jul-1991; levels=[1-5]
lzvn = lzvn 2017-03-08
memlz = memlz 0.2 beta
ppmd8 = ppmd8 25.01; levels=[1-9]
quicklz = quicklz 1.5.1 beta 7; levels=[1-3]
slz_deflate = slz_deflate 1.2.1; levels=[1-3]
slz_gzip = slz_gzip 1.2.1; levels=[1-3]
slz_zlib = slz_zlib 1.2.1; levels=[1-3]
snappy = snappy 1.2.2
tamp = tamp 2.1.0; levels=[8-15]
ucl_nrv2b = ucl_nrv2b 1.03; levels=[1-9]
ucl_nrv2d = ucl_nrv2d 1.03; levels=[1-9]
ucl_nrv2e = ucl_nrv2e 1.03; levels=[1-9]
wflz = wflz 2015-09-16
xz = xz 5.8.1; levels=[0-9]; threading=-I,-T
yalz77 = yalz77 2015-09-19; levels=[1-12]
yappy = yappy 2014-03-22; levels=[1-12]; threading=none
zlib = zlib 1.3.1; levels=[1-9]
zlib-ng = zlib-ng 2.2.5; levels=[1-9]
zling = zling 2018-10-12; levels=[0-4]
zpaq = zpaq 7.15; levels=[1-5]
zstd = zstd 1.5.7; levels=[1-22]; threading=-I,-T
zstd22 = zstd 1.5.7 -d22; levels=[16-22]; threading=-I,-T
zstd22LDM = zstd 1.5.7 --long -d22; levels=[16-22]; threading=-I,-T
zstd24 = zstd 1.5.7 -d24; levels=[16-22]; threading=-I,-T
zstd24LDM = zstd 1.5.7 --long -d24; levels=[16-22]; threading=-I,-T
zstdLDM = zstd 1.5.7 --long; levels=[1-22]; threading=-I,-T
zstd_fast = zstd 1.5.7 --fast; levels=[-5--1]; threading=-I,-T
zxc = zxc 0.11.0; levels=[1-6]

Available aliases for -e option:
FAST: Refers to compressors capable of achieving compression speeds exceeding 100 MB/s (default alias).
FAST = memcpy/density,1,2,3/fastlz/kanzi,1,2,3/lizard,10,11,12,13,14/lz4/lz4fast,3,17/lzav/lzf/lzfse/lzo1b,1/lzo1c,1/lzo1f,1/lzo1x,1/lzo1y,1/lzsse4fast/lzsse8,1/lzvn/quicklz,1,2/snappy/zstd,1,2,3,4,5

ALL: Represents all major supported compressors.
ALL = memcpy/density,1,2,3/brieflz,1,3,6,8/brotli,0,2,5,8,11/bsc1/bsc4/bsc5/bzip2,1,5,9/bzip3,5/fastlz,1,2/fastlzma2,1,3,5,8,10/kanzi,1,2,3,4,5,6,7,8,9/libdeflate,1,3,6,9,12/lizard,10,12,15,19,20,22,25,29,30,32,35,39,40,42,45,49/lz4fast,17,9,3/lz4/lz4hc,1,4,9,12/lzav/lzf,0,1/lzfse/lzg,1,4,6,8/lzham,0,1/lzlib,0,3,6,9/lzma,0,2,4,6,9/lzo1/lzo1a/lzo1b,1,3,6,9,99,999/lzo1c,1,3,6,9,99,999/lzo1f/lzo1x/lzo1y/lzo1z/lzo2a/lzsse2,1,6,12,16/lzsse4,1,6,12,16/lzsse8,1,6,12,16/lzvn/ppmd8,4/quicklz,1,2,3/slz_gzip/snappy/ucl_nrv2b,1,6,9/ucl_nrv2d,1,6,9/ucl_nrv2e,1,6,9/zlib,1,6,9/zlib-ng,1,6,9/zstd_fast,-5,-3,-1/zstd,1,2,5,8,11,15,18,22

POPULAR: Includes commonly used compressors.
POPULAR = memcpy/brotli,0,2,5,8,11/bzip2,1,5,9/bzip3,5/kanzi,1,2,3,4,5,6,7,8,9/libdeflate,1,3,6,9,12/lz4fast,17,9,3/lz4/lz4hc,1,4,9,12/lzlib,0,3,6,9/lzma,0,2,4,6,9/ppmd8,4/snappy/xz,1,3,5,7,9/zlib,1,6,9/zlib-ng,1,6,9/zstd_fast,-5,-3,-1/zstd,1,2,5,8,11,15,18,22

MAINSTREAM: Represents mainstream compressors.
MAINSTREAM = memcpy/lz4fast,17,9,5/lz4/lz4hc,1,3,9/zstd_fast,-5,-3,-1/zstd,1,3,7,12,17,22/zlib,1,6,9/lzma,0,4,9/bzip2,1,9/ppmd8,4

INT_MT: Covers all compressors supporting internal multi-threading with -I option.
INT_MT = memcpy/bsc0/bsc1/bsc4/bsc5/bsc6/fastlzma2,1,5,10/kanzi,1,2,3,4,5,6,7/lzham,1,4/lzma,0,4,9/xz,0,4,9/zstd,1,5,9,14,18,22

OPT: Includes compressors that use optimal parsing (slow compression, fast decompression).
OPT = memcpy/brotli,6,7,8,9,10,11/fastlzma2,1,2,3,4,5,6,7,8,9,10/lzham,0,1,2,3,4/lzlib,0,1,2,3,4,5,6,7,8,9/lzma,0,1,2,3,4,5,6,7,8,9/xz,1,2,3,4,5,6,7,8,9/zstd,18,19,20,21,22

SYMMETRIC: Includes compressors with similar compression and decompression speeds.
SYMMETRIC = memcpy/bsc/bzip2/bzip3/density,1,2,3/ppmd8/zpaq

MISC: Covers miscellaneous compressors.
MISC = memcpy/crush/lzjb/tamp/tornado/zling

BUGGY: Lists potentially unstable codecs that may cause segmentation faults.
BUGGY = memcpy/csc/gipfeli/lzmat/lzrw/lzsse8fast/wflz/yalz77/yappy

UCL: Refers to all UCL compressor variants.
UCL = ucl_nrv2b/ucl_nrv2d/ucl_nrv2e

LZO: Represents all LZO compressor variants.
LZO = lzo1/lzo1a/lzo1b/lzo1c/lzo1f/lzo1x/lzo1y/lzo1z/lzo2a

BSC: Represents all bsc compressor variants.
BSC = bsc0/bsc1/bsc2/bsc3/bsc4/bsc5/bsc6
````

1）可用压缩算法列表（Available compressors）

格式说明：

```
算法名 = 算法全称 版本; levels=[可用级别范围]; threading=线程支持
```

- `levels=[x-y]`：可指定的压缩级别区间
- `threading=-I,-T`：支持 `-I`（内部线程）、`-T`（线程池）参数
- `threading=none`：不支持多线程

| 算法标识                       | 翻译 & 说明                                                  |
| ------------------------------ | ------------------------------------------------------------ |
| memcpy                         | 内存拷贝（基准参照物，无压缩，用于测速对比）                 |
| aceapex                        | aceapex 1.0；级别 1~2；支持多线程                            |
| brieflz                        | brieflz 1.3.0；级别 1~9                                      |
| brotli                         | Brotli 1.2.0；主流通用压缩算法，级别 0~11                    |
| brotli22 / brotli24            | Brotli 扩展配置版本，分别启用 22/24 位窗口，级别 0~11        |
| bsc0~bsc6                      | BSC 系列压缩算法（共 7 个变体），不同预设参数；支持多线程    |
| bzip2                          | BZIP2 1.0.8；经典归档压缩，级别 1~9                          |
| bzip3                          | BZIP3 1.5.2；BZIP2 升级版，级别 1~10                         |
| crush                          | crush 1.0；级别 0~2；不支持多线程                            |
| csc                            | csc 压缩算法；级别 1~5                                       |
| fastlz                         | fastlz 0.5.0；轻量快速压缩，级别 1~2                         |
| fastlzma2                      | 优化版 LZMA2；级别 1~10；支持多线程                          |
| gipfeli                        | Google 出品 gipfeli 算法                                     |
| glza                           | glza 0.12；不支持多线程                                      |
| kanzi                          | kanzi 2.5.3；级别 1~9；支持多线程                            |
| libdeflate                     | 高性能 deflate 实现；级别 1~12                               |
| lizard                         | Lizard 2.1；兼顾速度与压缩比，级别 10~49                     |
| lz4                            | LZ4 1.10.0；**极速压缩 / 解压**，日常高频使用                |
| lz4fast                        | LZ4 极速模式；级别 1~99                                      |
| lz4hc                          | LZ4 HC（高压缩模式）；级别 1~12，压缩比更高、速度略降        |
| lzav                           | lzav 5.7；级别 1~2                                           |
| lzf                            | LZF 3.6；老牌轻量压缩，级别 0~1                              |
| lzfse                          | Apple 开源 LZFSE 算法                                        |
| lzg                            | lzg 1.0.10；级别 1~9                                         |
| lzham / lzham22 / lzham24      | LZHAM 系列，不同窗口配置；级别 0~4；支持多线程               |
| lzjb                           | lzjb 算法                                                    |
| lzlib                          | lzlib 1.15；级别 0~9                                         |
| lzma                           | LZMA 25.01；高压缩比经典算法；级别 0~9；支持多线程           |
| lzmat                          | lzmat 1.01                                                   |
| lzo 系列 (lzo1/lzo1a/lzo1b...) | LZO 家族，老牌高速压缩，多个变体；部分级别范围可达 1~999     |
| lzrw                           | lzrw 算法；级别 1~5                                          |
| lzvn                           | lzvn 算法                                                    |
| memlz                          | memlz 0.2 beta 测试版算法                                    |
| ppmd8                          | PPMD8 25.01；高压缩比文本专用算法；级别 1~9                  |
| quicklz                        | quicklz 1.5.1；级别 1~3                                      |
| slz_deflate/slz_gzip/slz_zlib  | SLZ 系列，分别兼容 deflate/gzip/zlib 格式；级别 1~3          |
| snappy                         | Google Snappy；主打低延迟、高速，常用于大数据组件            |
| tamp                           | tamp 2.1.0；级别 8~15                                        |
| ucl_nrv2b/d/e                  | UCL 压缩家族三个变体；级别 1~9                               |
| wflz / yalz77 / yappy          | 小众压缩算法，部分不支持多线程                               |
| xz                             | XZ 5.8.1（底层基于 LZMA）；级别 0~9；支持多线程              |
| zlib                           | ZLIB 1.3.1；标准 gzip/deflate 实现；级别 1~9                 |
| zlib-ng                        | ZLIB 高性能分支；级别 1~9                                    |
| zling / zpaq                   | 小众归档压缩，zpaq 压缩比极高、速度慢                        |
| zstd                           | Zstandard 1.5.7；**综合性能最优**，主流首选；级别 1~22；支持多线程 |
| zstd22/zstd24/zstdLDM          | ZSTD 扩展版本：大窗口 / 长距离匹配模式，适合大文件 / 冷数据；级别 16~22 |
| zstd_fast                      | ZSTD 极速模式；级别范围 -5 ~ -1                              |
| zxc                            | zxc 0.11.0；级别 1~6                                         |

2）预设别名组（Available aliases）

可以直接在 `-e` 后使用**别名**，无需手动罗列算法，是批量测试的快捷方式。

### FAST（默认别名）

默认分组，仅包含压缩速度 > 100 MB/s 的高速算法

````
FAST = 各类高速压缩组合（lz4、snappy、zstd低级别、lzo、fastlz 等）
````

**ALL**

全部主流压缩算法，完整全量测试

````
ALL = 包含上面绝大多数算法及典型级别
````

用法：`lzbench -eALL test.dat`

**POPULAR**

常用热门算法，日常测试首选，覆盖业界主流

包含：brotli、bzip2、lz4、lz4hc、lzma、xz、snappy、zlib、zstd 等

**MAINSTREAM**

业界主流商用算法集合，偏向生产环境常用选型

以 LZ4、ZSTD、ZLIB、LZMA 为核心。

**INT_MT**

仅筛选支持内部多线程（-I 参数） 的算法，专门做多线程压缩测试

**OPT**

启用最优解析模式的算法，特点：压缩慢、解压快、压缩比高

适合归档、只读冷数据场景。

**SYMMETRIC**

压缩、解压速度相近的对称型算法

**MISC**

其他小众、杂项压缩算法

**BUGGY**

存在稳定性风险的算法，可能触发段错误、崩溃，不建议在正式测试 / 自动化脚本中使用。

**UCL**

UCL 全系列算法集合

**LZO**

LZO 全系列算法集合

**BSC**

BSC 全系列算法集合

示例用法：

三大算法 lz4 /zstd/lzma

````
$ lzbench -elz4/lz4hc/zstd/lzma test.dat
````

使用热门算法分组一键测试，用流行压缩算法集，对 `test.dat` 做 benchmark；压缩至少跑 2 秒、解压至少 3 秒；结果以 Markdown 表格输出

````
$ lzbench -ePOPULAR -t2,3 -o1 test.dat
````

只跑高速算法，模拟实时业务场景，使用高速类压缩算法，静默运行不打印多余信息，结果以 CSV 格式输出，测试文件 `test.dat` 的压 / 解性能。

````
$ lzbench -eFAST -q -o4 test.dat
````

测试多线程兼容算法，使用多线程内置压缩算法集，以当前整机全部 CPU 核心并发，对 `test.dat` 执行压缩 / 解压性能测试。

````
$ lzbench -eINT_MT -I$(nproc) test.dat
````

测试结果

````
$ lzbench -elz4/lz4hc/zstd/lzma test.dat
lzbench 2.2.1 | GCC 12.3.1 | 64-bit Linux | 

Compressor name         Compress. Decompress. Compr. size  Ratio Filename
lz4 1.10.0                685 MB/s   790 MB/s  1077952578 100.39 ../test.dat
lz4hc 1.10.0 -1           796 MB/s   799 MB/s  1077952578 100.39 ../test.dat
lz4hc 1.10.0 -2           797 MB/s   792 MB/s  1077952578 100.39 ../test.dat
lz4hc 1.10.0 -3          3.75 MB/s   218 MB/s  1077943506 100.39 ../test.dat
lz4hc 1.10.0 -4          3.69 MB/s   220 MB/s  1077943165 100.39 ../test.dat
lz4hc 1.10.0 -5          3.78 MB/s   218 MB/s  1077943165 100.39 ../test.dat
lz4hc 1.10.0 -6          3.78 MB/s   215 MB/s  1077943165 100.39 ../test.dat
lz4hc 1.10.0 -7          3.79 MB/s   221 MB/s  1077943165 100.39 ../test.dat
lz4hc 1.10.0 -8          3.78 MB/s   218 MB/s  1077943165 100.39 ../test.dat
lz4hc 1.10.0 -9          3.64 MB/s   218 MB/s  1077943165 100.39 ../test.dat
lz4hc 1.10.0 -10         2.37 MB/s   218 MB/s  1077943165 100.39 ../test.dat
lz4hc 1.10.0 -11         2.39 MB/s   219 MB/s  1077943165 100.39 ../test.dat
lz4hc 1.10.0 -12         2.38 MB/s   219 MB/s  1077943165 100.39 ../test.dat
zstd 1.5.7 -1             123 MB/s   768 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -2            99.0 MB/s   777 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -3             110 MB/s   780 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -4            85.1 MB/s   764 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -5            78.3 MB/s   808 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -6            62.9 MB/s   779 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -7            68.3 MB/s   799 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -8            62.6 MB/s   870 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -9            28.6 MB/s   763 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -10           27.6 MB/s   748 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -11           20.3 MB/s   775 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -12           34.3 MB/s   817 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -13           4.68 MB/s   764 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -14           3.36 MB/s   759 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -15           3.46 MB/s   759 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -16           0.71 MB/s   765 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -17           0.53 MB/s   768 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -18           0.36 MB/s   769 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -19           0.33 MB/s   759 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -20           0.25 MB/s   805 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -21           0.22 MB/s   811 MB/s  1073766410 100.00 ../test.dat
zstd 1.5.7 -22           0.18 MB/s   813 MB/s  1073766410 100.00 ../test.dat
lzma 25.01 -0            0.64 MB/s   378 MB/s  1073808330 100.01 ../test.dat
lzma 25.01 -1            0.58 MB/s   383 MB/s  1073808375 100.01 ../test.dat
lzma 25.01 -2            0.44 MB/s   376 MB/s  1073808378 100.01 ../test.dat
lzma 25.01 -3            0.39 MB/s   347 MB/s  1073808378 100.01 ../test.dat
lzma 25.01 -4            0.35 MB/s   368 MB/s  1073808378 100.01 ../test.dat
lzma 25.01 -5            0.31 MB/s   360 MB/s  1073808276 100.01 ../test.dat
lzma 25.01 -6            0.24 MB/s   295 MB/s  1073808276 100.01 ../test.dat
lzma 25.01 -7            0.22 MB/s   331 MB/s  1073808276 100.01 ../test.dat
lzma 25.01 -8            0.17 MB/s   300 MB/s  1073808276 100.01 ../test.dat
lzma 25.01 -9            0.14 MB/s   313 MB/s  1073808276 100.01 ../test.dat
````

测试工具：lzbench 2.2.1

编译环境：GCC 12.3.1、64 位 Linux（openEuler RISC-V）

测试文件：`test.dat`（**随机数据**，几乎无压缩空间，是标准压测样本）

列字段释义：

- **Compressor name**：算法 + 版本 + 压缩级别

  数字越小：**压缩越快、压缩比越低**

  数字越大：**压缩越慢、压缩比越高**

- **Compress.**：压缩速度（MB/s，数值越高越快）

- **Decompress.**：解压速度（MB/s，数值越高越快）

- **Compr. size**：压缩后文件字节数

- **Ratio**：压缩比 = 原文件大小 ÷ 压缩后大小

- **Filename**：被测文件




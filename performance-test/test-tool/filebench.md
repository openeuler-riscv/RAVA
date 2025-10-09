# Filebench 测试方法与结果

> 参考：[https://github.com/filebench/filebench](https://github.com/filebench/filebench)

> 测试环境：**openEuler RISC-V 25.03**

---

## 1. 工具简介

**Filebench** 是一个基于模型的文件系统与存储性能测试工具。
通过 **Workload Model Language (WML)** 描述应用的 I/O 模型，可模拟文件服务器、邮件服务器、网页服务等多种负载。
测试结果包括吞吐率（ops/s）、带宽（MB/s）和延迟（ms/op），用于综合评估文件系统性能。

---

## 2. 编译与安装

```bash
git clone https://github.com/filebench/filebench.git
cd filebench

libtoolize
aclocal
autoheader
automake --add-missing
autoconf

./configure
make -j"$(nproc)"
sudo make install

filebench -h
```

执行 `filebench -h` 显示帮助信息，说明安装成功。
编译期间出现的 `autoconf` 宏过时警告可忽略。

---

## 3. 功能测试与结果

### （1）File Server 场景

```bash
rm -rf /data/*
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
filebench -f /usr/local/share/filebench/workloads/fileserver.f
```

**输出：**

```
Filebench Version 1.5-alpha3
0.001: Allocated 177MB of shared memory
0.102: File-server Version 3.0 personality successfully loaded
0.104: Populating and pre-allocating filesets
0.246: bigfileset populated: 10000 files, avg. dir. width = 20, avg. dir. depth = 3.1, 0 leafdirs, 1240.757MB total size
0.249: Removing bigfileset tree (if exists)
0.406: Pre-allocating directories in bigfileset tree
0.524: Pre-allocating files in bigfileset tree
8.777: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
8.778: Population and pre-allocation of filesets completed
8.781: Starting 1 filereader instances
12.627: Running...
72.931: Run took 60 seconds...
72.969: Per-Operation Breakdown
statfile1            102421ops     1699ops/s   0.0mb/s    0.464ms/op [0.039ms - 52.558ms]
deletefile1          102429ops     1699ops/s   0.0mb/s    6.793ms/op [0.153ms - 252.355ms]
closefile3           102433ops     1699ops/s   0.0mb/s    0.142ms/op [0.013ms - 45.888ms]
readfile1            102439ops     1699ops/s 222.6mb/s    1.335ms/op [0.035ms - 224.504ms]
openfile2            102440ops     1699ops/s   0.0mb/s    1.047ms/op [0.070ms - 72.996ms]
closefile2           102443ops     1699ops/s   0.0mb/s    0.154ms/op [0.014ms - 45.700ms]
appendfilerand1      102446ops     1699ops/s  13.3mb/s    0.719ms/op [0.011ms - 56.906ms]
openfile1            102448ops     1699ops/s   0.0mb/s    1.163ms/op [0.083ms - 68.410ms]
closefile1           102449ops     1699ops/s   0.0mb/s    0.184ms/op [0.014ms - 45.068ms]
wrtfile1             102461ops     1699ops/s 210.5mb/s    5.290ms/op [0.058ms - 313.030ms]
createfile1          102469ops     1699ops/s   0.0mb/s    6.072ms/op [0.189ms - 243.350ms]
72.977: IO Summary: 1126878 ops 18688.147 ops/s 1699/3398 rd/wr 446.4mb/s 2.124ms/op
72.978: Shutting down processes
```

**结果：**

| 指标   | 数值           | 说明      |
| ---- | ------------ | ------- |
| 吞吐率  | 18,688 ops/s | 文件操作速率  |
| 带宽   | 446.4 MB/s   | 综合读写带宽  |
| 平均延迟 | 2.124 ms/op  | 单操作平均耗时 |

---

### （2）Varmail 场景

```bash
rm -rf /data/*
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
filebench -f /usr/local/share/filebench/workloads/varmail.f
```

**输出：**

```
Filebench Version 1.5-alpha3
0.001: Allocated 177MB of shared memory
0.087: Varmail Version 3.0 personality successfully loaded
0.088: Populating and pre-allocating filesets
0.118: bigfileset populated: 1000 files, avg. dir. width = 1000000, avg. dir. depth = 0.5, 0 leafdirs, 14.959MB total size
0.120: Removing bigfileset tree (if exists)
0.369: Pre-allocating directories in bigfileset tree
0.374: Pre-allocating files in bigfileset tree
0.596: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
0.597: Population and pre-allocation of filesets completed
0.600: Starting 1 filereader instances
1.731: Running...
61.988: Run took 60 seconds...
62.001: Per-Operation Breakdown
closefile4           108959ops     1808ops/s   0.0mb/s    0.048ms/op [0.009ms - 12.905ms]
readfile4            108959ops     1808ops/s  28.2mb/s    0.142ms/op [0.019ms - 27.423ms]
openfile4            108959ops     1808ops/s   0.0mb/s    0.286ms/op [0.050ms - 17.391ms]
closefile3           108960ops     1808ops/s   0.0mb/s    0.053ms/op [0.010ms - 12.631ms]
fsyncfile3           108960ops     1808ops/s   0.0mb/s    0.017ms/op [0.003ms - 13.085ms]
appendfilerand3      108960ops     1808ops/s  14.1mb/s    0.229ms/op [0.001ms - 16.922ms]
readfile3            108961ops     1808ops/s  28.2mb/s    0.151ms/op [0.022ms - 16.683ms]
openfile3            108962ops     1808ops/s   0.0mb/s    0.295ms/op [0.057ms - 23.348ms]
closefile2           108962ops     1808ops/s   0.0mb/s    0.059ms/op [0.013ms - 16.210ms]
fsyncfile2           108962ops     1808ops/s   0.0mb/s    0.020ms/op [0.004ms - 8.616ms]
appendfilerand2      108962ops     1808ops/s  14.1mb/s    0.335ms/op [0.053ms - 29.692ms]
createfile2          108963ops     1808ops/s   0.0mb/s    2.827ms/op [0.142ms - 65.301ms]
deletefile1          108971ops     1809ops/s   0.0mb/s    3.605ms/op [0.107ms - 63.440ms]
62.014: IO Summary: 1416499 ops 23508.745 ops/s 3617/3617 rd/wr  84.6mb/s 0.621ms/op
62.019: Shutting down processes
```

**结果：**

| 指标   | 数值           | 说明      |
| ---- | ------------ | ------- |
| 吞吐率  | 23,509 ops/s | 文件操作速率  |
| 带宽   | 84.6 MB/s    | 数据吞吐量   |
| 平均延迟 | 0.621 ms/op  | 单操作平均耗时 |

---

### （3）Web Server 场景

```bash
rm -rf /data/*
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches
filebench -f /usr/local/share/filebench/workloads/webserver.f
```

**输出：**

```
Filebench Version 1.5-alpha3
0.001: Allocated 177MB of shared memory
0.094: Web-server Version 3.1 personality successfully loaded
0.095: Populating and pre-allocating filesets
0.114: logfiles populated: 1 files, avg. dir. width = 20, avg. dir. depth = 0.0, 0 leafdirs, 0.002MB total size
0.119: Removing logfiles tree (if exists)
0.234: Pre-allocating directories in logfiles tree
0.236: Pre-allocating files in logfiles tree
0.255: bigfileset populated: 1000 files, avg. dir. width = 20, avg. dir. depth = 2.3, 0 leafdirs, 14.760MB total size
0.256: Removing bigfileset tree (if exists)
0.453: Pre-allocating directories in bigfileset tree
0.476: Pre-allocating files in bigfileset tree
0.728: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
0.731: Population and pre-allocation of filesets completed
0.736: Starting 1 filereader instances
2.249: Running...
62.545: Run took 60 seconds...
63.027: Per-Operation Breakdown
appendlog            100513ops     1668ops/s  13.0mb/s   50.528ms/op [0.001ms - 500.910ms]
...
63.056: IO Summary: 3113160 ops 51648.063 ops/s 16660/1668 rd/wr 258.9mb/s 1.813ms/op
63.060: Shutting down processes
```

**结果：**

| 指标   | 数值           | 说明     |
| ---- | ------------ | ------ |
| 吞吐率  | 51,648 ops/s | 文件操作速率 |
| 带宽   | 258.9 MB/s   | 综合带宽   |
| 平均延迟 | 1.813 ms/op  | 平均操作延迟 |

---

## 4. 测试结果汇总

| 场景         | 吞吐率 (ops/s) | 带宽 (MB/s) | 平均延迟 (ms/op) | 特征说明        |
| ---------- | ----------- | --------- | ------------ | ----------- |
| fileserver | 18,688      | 446.4     | 2.124        | 混合读写负载      |
| varmail    | 23,509      | 84.6      | 0.621        | 小文件随机 I/O   |
| webserver  | 51,648      | 258.9     | 1.813        | 读取为主的网页访问模式 |

---

## 5. 结论

* Filebench 在 **openEuler RISC-V 25.03** 上成功编译、安装并运行。
* 各场景体现不同 I/O 模式下的性能差异：

  * **fileserver**：混合读写，带宽最高；
  * **varmail**：小文件频繁创建与同步，延迟最低；
  * **webserver**：读为主的访问模式，整体吞吐最高。
* 工具在 RISC-V 平台运行稳定，可用于文件系统与存储子系统的性能评测。

# BabelStream 测试方法

## 工具简介

BabelStream 是一个基于 STREAM 基准扩展的内存带宽测试工具，支持多种并行编程模型（OpenMP、OpenCL、CUDA、SYCL 等），主要用于评估 CPU/GPU 的可达内存带宽。
它实现了五个核心测试：**Copy、Mul、Add、Triad、Dot**，分别代表不同的内存访问与计算模式。

---

## 配置与编译（根据官网说明）

1. 获取源码：

```bash
git clone https://github.com/UoB-HPC/BabelStream.git
cd BabelStream
```

2. 配置与编译（OpenMP 模型）：

> 注：官网默认构建参数包含 `-march=native`，在 RISC-V 上不兼容，因此需要手动覆盖 `RELEASE_FLAGS`。

```bash
# 清理旧构建目录（如存在）
rm -rf build-omp

# 配置（根据官网说明，增加 -DMODEL=omp，覆盖 RELEASE_FLAGS）
cmake -B build-omp -H. -DMODEL=omp -DRELEASE_FLAGS="-O3"

# 编译
cmake --build build-omp
```

生成的可执行文件为：

```
./build-omp/omp-stream
```

---

## 运行测试与测试结果

### 单线程运行（模拟 serial）

```bash
OMP_NUM_THREADS=1 ./build-omp/omp-stream -s 100000000 -n 10
```

**完整测试报告日志：**

```
BabelStream
Version: 5.0
Implementation: OpenMP
Running kernels 10 times
Precision: double
Array size: 800.0 MB (=0.8 GB)
Total size: 2400.0 MB (=2.4 GB)
Init: 1.558969 s (=1539.478779 MBytes/sec)
Read: 11.495990 s (=208.768443 MBytes/sec)
Function    MBytes/sec  Min (sec)   Max         Average     
Copy        4247.696    0.37667     0.43001     0.39512     
Mul         1474.124    1.08539     1.14250     1.11110     
Add         1951.036    1.23012     1.27909     1.25499     
Triad       1228.588    1.95346     2.01503     1.98245     
Dot         856.989     1.86700     2.04486     1.92364     
```

---

### 多线程运行（使用全部 CPU 核心）

```bash
./build-omp/omp-stream -s 100000000 -n 10
```

**完整测试报告日志：**

```
BabelStream
Version: 5.0
Implementation: OpenMP
Running kernels 10 times
Precision: double
Array size: 800.0 MB (=0.8 GB)
Total size: 2400.0 MB (=2.4 GB)
Init: 0.952699 s (=2519.158198 MBytes/sec)
Read: 0.851732 s (=2817.788416 MBytes/sec)
Function    MBytes/sec  Min (sec)   Max         Average     
Copy        12176.783   0.13140     0.14654     0.13754     
Mul         5017.014    0.31891     0.33526     0.32708     
Add         6399.085    0.37505     0.41497     0.38861     
Triad       4479.494    0.53577     0.56910     0.55665     
Dot         3141.815    0.50926     0.54559     0.52694     
```

---

## 测试结果汇总

| 模型     | 线程数 | 数组大小 | Copy (MB/s) | Mul (MB/s) | Add (MB/s) | Triad (MB/s) | Dot (MB/s) |
| ------ | --- | ---- | ----------- | ---------- | ---------- | ------------ | ---------- |
| OpenMP | 1   | 1e8  | 4247.696    | 1474.124   | 1951.036   | 1228.588     | 856.989    |
| OpenMP | 全核  | 1e8  | 12176.783   | 5017.014   | 6399.085   | 4479.494     | 3141.815   |

---

## 结论与分析

* BabelStream 在 openEuler RISC-V 上能够成功编译并运行。
* 单线程性能反映了单核的内存带宽能力；多线程测试结果则接近系统可利用的总内存带宽。
* **Copy 和 Triad 指标最具代表性**：

  * Copy 代表纯粹的内存拷贝吞吐率
  * Triad 代表典型的流式计算模式
* 多线程性能比单线程提升明显，但仍低于理论峰值，说明内存子系统存在带宽瓶颈，后续可结合 RAJAPerf 或 stress-ng 做进一步分析。

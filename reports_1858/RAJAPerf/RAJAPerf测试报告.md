# RAJAPerf Benchmark 调研报告

## 一、测试环境

* 环境：openEuler-24.03-LTS-SP1


## 二、环境准备与构建

```
sudo dnf install -y git gcc cmake make
git clone --recursive https://github.com/LLNL/RAJAPerf.git
cd RAJAPerf
mkdir build && cd build
cmake -DCMAKE_BUILD_TYPE=Release -DENABLE_OPENMP=Off ..
make -j$(nproc)
```

## 三、测试运行

测试选择数据规模为 `tiny`，执行以下核函数：

* Apps\_FIR
* Basic\_COPY8
* Stream\_COPY

执行命令如下：

```
mkdir ../results
./bin/raja-perf.exe --size tiny --kernels Apps_FIR    > ../results/result_AppsFIR.log
./bin/raja-perf.exe --size tiny --kernels Basic_COPY8 > ../results/result_COPY8.log
./bin/raja-perf.exe --size tiny --kernels Stream_COPY > ../results/result_Stream.log
```


## 四、测试结果汇总

| 测试项          | Reps | Kernels/rep | Bytes/rep | FLOPS/rep | BytesRead/rep | BytesWritten/rep |
| ------------ | ---- | ----------- | --------- | --------- | ------------- | ---------------- |
| Apps\_FIR    | 160  | 1           | 248       | 0         | 248           | 0                |
| Basic\_COPY8 | 50   | 1           | 0         | 0         | 0             | 0                |
| Stream\_COPY | 1800 | 1           | 0         | 0         | 0             | 0                |

## 五、关键性能指标说明

本次测试旨在调研 RAJAPerf 中典型核函数的性能统计指标：

* **Reps**：测试重复次数，表示样本数和运行次数，用于稳定测试输出。
* **Kernels/rep**：每次重复中核函数的调用次数，体现调用密度。
* **Bytes/rep**：每轮重复中涉及的内存传输量，衡量内存带宽压力。
* **FLOPS/rep**：浮点运算次数，用于评估计算密集度。
* **BytesRead/rep / BytesWritten/rep**：读写数据量，衡量内存访问和存储效率。
* **BytesAtomicModifyWritten/rep**：表示原子操作的写入量，反映线程/并发压力。



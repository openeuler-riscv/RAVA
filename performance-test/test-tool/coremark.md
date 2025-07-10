# CoreMark 测试文档

## 一、测试目的
验证 CoreMark 在 openEuler-25.03环境下能否正常执行，并采集 CPU 综合性能指标，为处理器性能评估提供标准化基准数据。

## 二、测试工具安装
```bash
git clone https://github.com/eembc/coremark.git
cd coremark
```
### 4线程测试
```bash
make PORT_DIR=linux XCFLAGS="-DMULTITHREAD=4 -DUSE_PTHREAD -pthread"
```
### 单线程测试
```bash
make PORT_DIR=linux clean # 清理之前的编译文件
make PORT_DIR=linux
```
### 其他自定义配置测试
```bash
# 指定迭代次数
make PORT_DIR=linux ITERATIONS=500000
```

## 三、执行测试
```bash
./coremark.exe
```



## 四、测试结果示例

### 4线程测试
```
[fullname@localhost coremark]$ ./coremark.exe
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 15505
Total time (secs): 15.505000
Iterations/Sec   : 7739.438891
Iterations       : 120000
Compiler version : GCC12.3.1 (openEuler 12.3.1-81.oe2503)
Compiler flags   : -O2 -DMULTITHREAD=4 -DUSE_PTHREAD -pthread -DPERFORMANCE_RUN=1  -lrt
Parallel PThreads : 4
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[1]crclist       : 0xe714
[2]crclist       : 0xe714
[3]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[1]crcmatrix     : 0x1fd7
[2]crcmatrix     : 0x1fd7
[3]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[1]crcstate      : 0x8e3a
[2]crcstate      : 0x8e3a
[3]crcstate      : 0x8e3a
[0]crcfinal      : 0x5275
[1]crcfinal      : 0x5275
[2]crcfinal      : 0x5275
[3]crcfinal      : 0x5275
Correct operation validated. See README.md for run and reporting rules.
CoreMark 1.0 : 7739.438891 / GCC12.3.1 (openEuler 12.3.1-81.oe2503) -O2 -DMULTITHREAD=4 -DUSE_PTHREAD -pthread -DPERFORMANCE_RUN=1  -lrt / Heap / 4:PThreads
```


### 单线程测试
```
[fullname@localhost coremark]$ ./coremark.exe
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 17140
Total time (secs): 17.140000
Iterations/Sec   : 3500.583431
Iterations       : 60000
Compiler version : GCC12.3.1 (openEuler 12.3.1-81.oe2503)
Compiler flags   : -O2 -DPERFORMANCE_RUN=1  -lrt
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0xbd59
Correct operation validated. See README.md for run and reporting rules.
CoreMark 1.0 : 3500.583431 / GCC12.3.1 (openEuler 12.3.1-81.oe2503) -O2 -DPERFORMANCE_RUN=1  -lrt / Heap
```

## 五、结果解读

### 关键指标
- **Iterations/Sec**: 每秒迭代次数
- **CoreMark 分数**: 最终性能得分，似乎等于Iterations/Sec
- **CoreMark / MHz**: 性能效率指标，每MHz的CoreMark分数，MHz是处理器运行频率


### 性能对比
| 测试配置 | CoreMark 分数 | 说明 |
|----------|---------------|------|
| 4线程 | 7739.44 | 多核并行性能 |
| 单线程 | 3500.58 | 单核性能基准 |

- QEMU虚拟机似乎无法获得真实CPU频率，因此无法计算CoreMark / MHz。
## 在 openEuler RISC-V 镜像中执行 CoreMark 测试

### 1. CoreMark 介绍

CoreMark 是一个专门用于测试嵌入式处理器核心性能的行业标准基准测试程序，由 EEMBC（嵌入式微处理器基准评测协会）于 2009 年推出，旨在取代过时的 Dhrystone 测试

CoreMark 通过运行四种典型的嵌入式算法来综合评估 CPU 性能

| 测试算法     | 评估内容                               | 具体操作                     |
| :----------- | :------------------------------------- | :--------------------------- |
| **列表处理** | 控制流效率、分支预测能力、指针操作     | 链表的遍历、插入、删除和排序 |
| **矩阵操作** | 整数运算性能、内存读写速度、缓存命中率 | 常见的矩阵乘法运算           |
| **状态机**   | 分支预测成功率、跳转指令效率           | 通过状态转换处理输入数据流   |
| **CRC计算**  | 位操作能力、逻辑运算效率               | 循环冗余校验计算             |

### 2. 执行测试

从源码编译安装 coremark

````
$ dnf install -y git gcc make
$ git clone https://github.com/eembc/coremark.git
$ cd coremark
$ make
````

执行测试

````
$ ./coremark.exe
2K performance run parameters for coremark.
CoreMark Size    : 666
Total ticks      : 17790
Total time (secs): 17.790000
Iterations/Sec   : 1686.340641
Iterations       : 30000
Compiler version : GCC12.3.1 (openEuler 12.3.1-107.oe2403sp3)
Compiler flags   : -O2 -DPERFORMANCE_RUN=1  -lrt
Memory location  : Please put data memory location here
                        (e.g. code in flash, data on heap etc)
seedcrc          : 0xe9f5
[0]crclist       : 0xe714
[0]crcmatrix     : 0x1fd7
[0]crcstate      : 0x8e3a
[0]crcfinal      : 0x5275
Correct operation validated. See README.md for run and reporting rules.
CoreMark 1.0 : 1686.340641 / GCC12.3.1 (openEuler 12.3.1-107.oe2403sp3) -O2 -DPERFORMANCE_RUN=1  -lrt / Heap
````

关键指标解读

| 参数              | 含义           | 说明                                                         |
| :---------------- | :------------- | :----------------------------------------------------------- |
| CoreMark Size     | 数据缓冲区大小 | 测试用的工作负载大小，固定为 666，用于保持测试一致性         |
| Total time (secs) | 测试总耗时     | 通常要求至少运行 10 秒以上以保证结果稳定                     |
| Iterations/Sec    | 核心性能得分   | 每秒完成的迭代次数（每秒能跑 1686 轮 CoreMark 运算），数值越高性能越强，这是最关键的指标 |
| Iterations        | 总迭代次数     | 总共跑了 3 万轮，根据时间自动调整，确保测试时长足够          |
| crcfinal          | 最终校验值     | 用于验证结果正确性，每次运行应一致                           |
| CoreMark 1.0 : X  | 结果总结行     | 包含得分和编译环境信息，便于记录和对比                       |
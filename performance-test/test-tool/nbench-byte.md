# nbench-byte 测试文档


1. **简介**

   nbench-byte 是 BYTE Magazine 原生基准测试程序（BYTEmark Release 2）的官方 Linux/Unix 移植版。作为算法级测试工具，它直接测量 CPU 整数单元、FPU 浮点单元和内存子系统的原始性能. 

1. **下载与编译**  
   ```bash
   wget http://www.math.utah.edu/~mayer/linux/nbench-byte-2.2.3.tar.gz
   tar -xzvf nbench-byte-2.2.3.tar.gz
   cd nbench-byte-2.2.3
   make
   ```  
   编译可能产生警告（如指针类型不匹配），但通常不影响运行。  

2. **运行测试**  
   ```bash
   ./nbench
   ``` 
4. **示例结果**

    ```bash
    BYTEmark* Native Mode Benchmark ver. 2 (10/95)
    Index-split by Andrew D. Balsa (11/97)
    Linux/Unix* port by Uwe F. Mayer (12/96,11/97)

    TEST                : Iterations/sec.  : Old Index   : New Index
                        :                  : Pentium 90* : AMD K6/233*
    --------------------:------------------:-------------:------------
    NUMERIC SORT        :          669.29  :      17.16  :       5.64
    STRING SORT         :          90.889  :      40.61  :       6.29
    BITFIELD            :      3.6352e+08  :      62.36  :      13.02
    FP EMULATION        :          135.12  :      64.83  :      14.96
    FOURIER             :          5365.8  :       6.10  :       3.43
    ASSIGNMENT          :          11.316  :      43.06  :      11.17
    IDEA                :          3143.5  :      48.08  :      14.28
    HUFFMAN             :          1364.5  :      37.84  :      12.08
    NEURAL NET          :          5.7024  :       9.16  :       3.85
    LU DECOMPOSITION    :          145.09  :       7.52  :       5.43
    ==========================ORIGINAL BYTEMARK RESULTS==========================
    INTEGER INDEX       : 41.740
    FLOATING-POINT INDEX: 7.490
    Baseline (MSDOS*)   : Pentium* 90, 256 KB L2-cache, Watcom* compiler 10.0
    ==============================LINUX DATA BELOW===============================
    CPU                 : 4 CPU
    L2 Cache            :
    OS                  : Linux 6.6.0-72.6.0.56.oe2503.riscv64
    C compiler          : gcc version 12.3.1 (openEuler 12.3.1-81.oe2503) (GCC)
    libc                : /usr/lib64/libc.so.6
    MEMORY INDEX        : 9.706
    INTEGER INDEX       : 10.982
    FLOATING-POINT INDEX: 4.154
    Baseline (LINUX)    : AMD K6/233*, 512 KB L2-cache, gcc 2.7.2.3, libc-5.4.38
    * Trademarks are property of their respective holder.
    ```

3. **结果解读**  
   工具输出两部分：  
   - **分项测试**：10 项任务的每秒迭代次数（如 NUMERIC SORT、IDEA 加密）。 
   
   | 测试名称            | 评测内容                     |
   |---------------------|----------------------------|
   | NUMERIC SORT        | 整型数据排序性能            |
   | STRING SORT         | 字符串排序性能              |
   | BITFIELD            | 位操作性能                  |
   | FP EMULATION        | 浮点运算模拟性能            |
   | FOURIER             | 快速傅里叶变换性能          |
   | ASSIGNMENT          | 内存赋值性能                |
   | IDEA                | IDEA加密算法性能            |
   | HUFFMAN             | 霍夫曼编码性能              |
   | NEURAL NET          | 神经网络推理性能            |
   | LU DECOMPOSITION    | 线性代数(LU分解)性能        | 

   - **综合指标**：

   | 综合指数          | 计算方式                          | 包含分项（几何平均）                | 物理意义               |
   |-------------------|----------------------------------|-------------------------------------|----------------------|
   | **INTEGER INDEX** | 纯算术运算几何平均               | NUMERIC SORT, FP EMULATION,<br>IDEA, HUFFMAN | CPU整数计算核心性能    |
   | **MEMORY INDEX**  | 内存敏感测试几何平均             | STRING SORT, BITFIELD, ASSIGNMENT   | 内存子系统性能         |
   | **FLOATING-POINT INDEX** | FPU测试几何平均 | FOURIER, NEURAL NET, LU DECOMPOSITION | 浮点协处理器性能       | 

---


### 示例结果解读  
在输出中：  
```plaintext
INTEGER INDEX       : 10.982  
FLOATING-POINT INDEX: 4.154  
MEMORY INDEX        : 9.706  
```  
表示被测系统的：  
- 整数性能是 **AMD K6/233 的 10.982 倍**  
- 浮点性能是 **AMD K6/233 的 4.154 倍**  
- 内存性能是 **AMD K6/233 的 9.706 倍**

### 参考

https://github.com/toshsan/nbench/blob/master/bdoc.txt
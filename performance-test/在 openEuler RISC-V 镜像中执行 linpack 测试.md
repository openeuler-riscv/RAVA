## 在 openEuler RISC-V 镜像中执行 linpack 测试

### 1. linpack 介绍

- **Linpack（Linear System Package）** 是经典的**稠密线性方程组求解基准**，核心用来测系统**浮点计算能力**，TOP500 超算排名即基于其高性能版本 **HPL（High-Performance Linpack）**。
  - 原理：对 N×N 稠密矩阵做 **LU 分解**，解 Ax=b，测持续浮点吞吐（单位 **GFlops**）。
  - 用途：评估 CPU 浮点性能、内存带宽、系统稳定性；RISC‑V 平台常用它验证**向量 / 浮点单元优化**与**并行效率**。
  - 版本：
    - **传统 Linpack**：单机串行，矩阵规模小（N≤1000），适合快速验证。
    - **HPL**：分布式并行（MPI），支持大内存与多核心，用于正式跑分。

### 2. 执行测试

编译 linpack

````
$ dnf install -y gcc-gfortran wget
$ wget https://netlib.org/benchmark/linpackd
$ mv linpackd linpackd.f
$ gfortran -O3 linpackd.f -o linpack-f
````

执行测试

````
$ ./linpack-f
 Please send the results of this run to:

 Jack J. Dongarra
 Computer Science Department
 University of Tennessee
 Knoxville, Tennessee 37996-1300

 Fax: 865-974-8296

 Internet: dongarra@cs.utk.edu

 This is version 29.5.04.

     norm. resid      resid           machep         x(1)          x(n)
  1.23217369E+00  1.36796649E-14  2.22044605E-16  1.00000000E+00  1.00000000E+00


    times are reported for matrices of order   100
      dgefa      dgesl      total     mflops       unit      ratio       b(1)
 times for array with leading dimension of 201
  5.524E-03  3.340E-04  5.858E-03  1.172E+02  1.706E-02  1.046E-01  9.378E-15
  5.424E-03  1.860E-04  5.610E-03  1.224E+02  1.634E-02  1.002E-01  1.000E+00
  5.276E-03  1.810E-04  5.457E-03  1.258E+02  1.589E-02  9.745E-02  1.000E+00
  5.215E-03  1.792E-04  5.394E-03  1.273E+02  1.571E-02  9.633E-02  5.298E+02

 times for array with leading dimension of 200
  5.596E-03  3.560E-04  5.952E-03  1.154E+02  1.734E-02  1.063E-01  1.000E+00
  5.129E-03  1.910E-04  5.320E-03  1.291E+02  1.550E-02  9.500E-02  1.000E+00
  5.161E-03  2.420E-04  5.403E-03  1.271E+02  1.574E-02  9.648E-02  1.000E+00
  5.207E-03  1.778E-04  5.385E-03  1.275E+02  1.568E-02  9.616E-02  5.298E+02
  end of tests -- this version dated 05/29/04
````

测试结果解读

1）头部版权 & 版本信息

````
 Please send the results of this run to:

 Jack J. Dongarra
 Computer Science Department
 University of Tennessee
 Knoxville, Tennessee 37996-1300

 Fax: 865-974-8296

 Internet: dongarra@cs.utk.edu
````

Linpack 原作者及联系信息，**仅标识来源，无性能含义**。

````
 This is version 29.5.04.
````

 当前使用的 Linpack 程序版本：`29.5.04`。

2）计算精度校验区（核心：判断计算是否正确）

````
     norm. resid      resid           machep         x(1)          x(n)
  1.23217369E+00  1.36796649E-14  2.22044605E-16  1.00000000E+00  1.00000000E+00
````

**norm. resid（归一化残差）**：`1.23217369E+00`

标准合格范围 `1.0 ~ 2.0`，本次结果正常，代表方程组求解整体偏差在合理区间。

**resid（原始残差）**：`1.36796649E-14`

真实计算误差，数值无限趋近 0，**计算结果精准无误**。

**machep（机器精度）**：`2.22044605E-16`

64 位双精度浮点数标准机器精度，说明 CPU 浮点单元、编译模式均正常。

**x(1) / x(n)**：方程组第一个 / 最后一个解，标准预期值 `1.0`，结果完全符合。

3）测试规格说明

````
    times are reported for matrices of order   100
````

本次测试矩阵规格：**100 阶方阵**，固定计算规模。

````
      dgefa      dgesl      total     mflops       unit      ratio       b(1)
````

性能数据表头，逐字段定义：

- `dgefa`：矩阵 LU 分解耗时（Linpack 核心计算环节，单位：秒）
- `dgesl`：线性方程组回代求解耗时（单位：秒）
- `total`：单次完整运算总耗时（分解 + 求解，单位：秒）
- `mflops`：**每秒百万次双精度浮点运算**（核心性能指标，MFLOPS）
- `unit`：归一化单位耗时（参考值）
- `ratio`：相对性能比值（参考值）
- `b(1)`：边界校验值（用于合法性校验）

4）第一组：leading dimension of 201（内存非对齐布局）

`leading dimension = 201`：矩阵内存行宽非标准对齐，模拟业务中**非最优内存布局**场景。

````
  5.524E-03  3.340E-04  5.858E-03  1.172E+02  1.706E-02  1.046E-01  9.378E-15
````

- dgefa=5.524ms，dgesl=0.334ms，总耗时 = 5.858ms

- 浮点性能：**117.2 MFLOPS**

- b (1) 接近 0，校验正常

````
  5.424E-03  1.860E-04  5.610E-03  1.224E+02  1.634E-02  1.002E-01  1.000E+00
````

第二轮，CPU 进入稳态：

- 总耗时下降至 5.610ms，性能提升至 **122.4 MFLOPS**

````
  5.276E-03  1.810E-04  5.457E-03  1.258E+02  1.589E-02  9.745E-02  1.000E+00
````

第三轮：总耗时 5.457ms，性能 **125.8 MFLOPS**

````
  5.215E-03  1.792E-04  5.394E-03  1.273E+02  1.571E-02  9.633E-02  5.298E+02
````

第四轮（本组最优）：

- 总耗时 5.394ms，性能 **127.3 MFLOPS**
- 多轮递增：CPU 缓存、主频达到稳定状态。

5）第二组：leading dimension of 200（内存标准对齐布局）

`leading dimension = 200`：矩阵内存行宽和矩阵阶数一致，**硬件内存访问最优布局**，理论性能最高。

````
  5.596E-03  3.560E-04  5.952E-03  1.154E+02  1.734E-02  1.063E-01  1.000E+00
````

第一轮热身：总耗时 5.952ms，性能 **115.4 MFLOPS**

````
  5.129E-03  1.910E-04  5.320E-03  1.291E+02  1.550E-02  9.500E-02  1.000E+00
````

**全场最优成绩**

- 矩阵分解耗时：5.129 ms
- 回代耗时：0.191 ms
- 总耗时：5.320 ms
- 单核浮点峰值：**129.1 MFLOPS**

````
  5.161E-03  2.420E-04  5.403E-03  1.271E+02  1.574E-02  9.648E-02  1.000E+00
````

小幅回落，性能 **127.1 MFLOPS**

````
  5.207E-03  1.778E-04  5.385E-03  1.275E+02  1.568E-02  9.616E-02  5.298E+02
````

稳态运行：性能稳定在 **127.5 MFLOPS**

6）结束标识

````
  end of tests -- this version dated 05/29/04
````

测试全部执行完毕，程序编译 / 发布日期：2004-05-29。

````
Please send the results of this run to:

 Jack J. Dongarra
 Computer Science Department
 University of Tennessee
 Knoxville, Tennessee 37996-1300

 Fax: 865-974-8296

 Internet: dongarra@cs.utk.edu

 This is version 29.5.04.

     norm. resid      resid           machep         x(1)          x(n)
  1.23217369E+00  1.36796649E-14  2.22044605E-16  1.00000000E+00  1.00000000E+00


    times are reported for matrices of order   100
      dgefa      dgesl      total     mflops       unit      ratio       b(1)
 times for array with leading dimension of 201
  5.665E-03  1.700E-04  5.835E-03  1.177E+02  1.700E-02  1.042E-01  9.378E-15
  5.147E-03  1.750E-04  5.322E-03  1.290E+02  1.550E-02  9.504E-02  1.000E+00
  5.495E-03  1.790E-04  5.674E-03  1.210E+02  1.653E-02  1.013E-01  1.000E+00
  5.490E-03  1.728E-04  5.662E-03  1.213E+02  1.649E-02  1.011E-01  5.298E+02

 times for array with leading dimension of 200
  5.143E-03  1.700E-04  5.313E-03  1.292E+02  1.547E-02  9.488E-02  1.000E+00
  5.209E-03  1.680E-04  5.377E-03  1.277E+02  1.566E-02  9.602E-02  1.000E+00
  5.174E-03  1.870E-04  5.361E-03  1.281E+02  1.561E-02  9.573E-02  1.000E+00
  5.530E-03  1.626E-04  5.693E-03  1.206E+02  1.658E-02  1.017E-01  5.298E+02
  end of tests -- this version dated 05/29/04
````




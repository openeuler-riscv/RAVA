## 在 openEuler RISC-V 镜像中执行 HPCG 测试

### 1. HPCG 介绍

HPCG（High Performance Conjugate Gradients 高性能共轭梯度法）是衡量超级计算机实际应用性能的重要基准测试，与Linpack（HPL）测试互补。HPCG更注重内存带宽和延迟，能更真实地反映科学计算场景的性能

### 2. 测试方法

安装依赖环境

````
$ yum install git mpich-devel g++ environment-modules -y
````

加载 MPI 环境

````
$ . /etc/profile.d/modules.sh
$ module load mpi/mpich-riscv64
````

获取源码

````
$ git clone https://github.com/hpcg-benchmark/hpcg.git
$ cd hpcg
````

修改配置文件 setup/Make.Linux_MPI，配置 MPdir，MPinc，MPlib 和 CXX

MPdir 为 MPI 安装目录

MPinc 为 MPI 头文件路径

MPlib 为 MPI 库文件路径

CXX 为 mpicxx 编译器目录

确定 MPI 安装路径方法

````
$ which mpicxx    //MPICH 查找，输出类似 /usr/lib64/mpich/bin/mpicxx
$ dirname $(dirname $(which mpicxx))     //提取路径 → /usr/lib64/mpich
````

配置 MPdir，MPinc，MPlib 如下：

````
MPdir        = /usr/lib64/mpich
MPinc        = -I$(MPdir)/include
MPlib        = $(MPdir)/lib
CXX          = $(MPdir)/bin/mpicxx
````

可以直接用命令来实现

````
$ MPI_PATH=$(dirname $(dirname $(which mpicxx)))
$ sed -i "s|^\(MPdir\s*=\).*|\1$MPI_PATH|" setup/Make.Linux_MPI
$ sed -i 's|^\(MPinc\s*=\).*|\1 -I$(MPdir)/include|' setup/Make.Linux_MPI
$ sed -i 's|^\(MPlib\s*=\).*|\1 $(MPdir)/lib|' setup/Make.Linux_MPI
$ sed -i 's|^\(CXX\s*=\s*\).*|\1$(MPdir)/bin/mpicxx|' setup/Make.Linux_MPI
````

配置完成后，编译 HPCG

````
$ mkdir build && cd build
$ ../configure Linux_MPI
$ make -j $(nproc)
````

编译完成后在 当前目录中的 bin 目录下会生成参数文件 hpcg.dat 和 可执行文件 xhpcg。根据 HPCG 官方规定，运行时间至少 1800s，所以需要修改 hpcg.dat，hpcg.dat 内容如下

````
HPCG benchmark input file
Sandia National Laboratories; University of Tennessee, Knoxville
104 104 104
1800
````

第三行表示网格大小，第四行表示运行时长，单位秒，需要将其改为1800

可以直接用命令来实现

````
$ sed -i '$s/.*/1800/' bin/hpcg.dat
````

修改完成后，执行命令执行测试

````
$ mpirun -np $(nproc) bin/xhpcg
````

测试完成后，在当前目录下会生成测试结果，是 HPCG-Benchmark 开头的 txt 文件

````
HPCG-Benchmark
version=3.1
Release date=March 28, 2019
Machine Summary=
Machine Summary::Distributed Processes=8
Machine Summary::Threads per processes=1
Global Problem Dimensions=
Global Problem Dimensions::Global nx=32
Global Problem Dimensions::Global ny=32
Global Problem Dimensions::Global nz=32
Processor Dimensions=
Processor Dimensions::npx=2
Processor Dimensions::npy=2
Processor Dimensions::npz=2
Local Domain Dimensions=
Local Domain Dimensions::nx=16
Local Domain Dimensions::ny=16
Local Domain Dimensions::Lower ipz=0
Local Domain Dimensions::Upper ipz=1
Local Domain Dimensions::nz=16
########## Problem Summary  ##########=
Setup Information=
Setup Information::Setup Time=0.11907
Linear System Information=
Linear System Information::Number of Equations=32768
Linear System Information::Number of Nonzero Terms=830584
Multigrid Information=
Multigrid Information::Number of coarse grid levels=3
Multigrid Information::Coarse Grids=
Multigrid Information::Coarse Grids::Grid Level=1
Multigrid Information::Coarse Grids::Number of Equations=4096
Multigrid Information::Coarse Grids::Number of Nonzero Terms=97336
Multigrid Information::Coarse Grids::Number of Presmoother Steps=1
Multigrid Information::Coarse Grids::Number of Postsmoother Steps=1
Multigrid Information::Coarse Grids::Grid Level=2
Multigrid Information::Coarse Grids::Number of Equations=512
Multigrid Information::Coarse Grids::Number of Nonzero Terms=10648
Multigrid Information::Coarse Grids::Number of Presmoother Steps=1
Multigrid Information::Coarse Grids::Number of Postsmoother Steps=1
Multigrid Information::Coarse Grids::Grid Level=3
Multigrid Information::Coarse Grids::Number of Equations=64
Multigrid Information::Coarse Grids::Number of Nonzero Terms=1000
Multigrid Information::Coarse Grids::Number of Presmoother Steps=1
Multigrid Information::Coarse Grids::Number of Postsmoother Steps=1
########## Memory Use Summary  ##########=
Memory Use Information=
Memory Use Information::Total memory used for data (Gbytes)=0.0235669
Memory Use Information::Memory used for OptimizeProblem data (Gbytes)=0
Memory Use Information::Bytes per equation (Total memory / Number of Equations)=719.205
Memory Use Information::Memory used for linear system and CG (Gbytes)=0.0207158
Memory Use Information::Coarse Grids=
Memory Use Information::Coarse Grids::Grid Level=1
Memory Use Information::Coarse Grids::Memory used=0.00249264
Memory Use Information::Coarse Grids::Grid Level=2
Memory Use Information::Coarse Grids::Memory used=0.000316812
Memory Use Information::Coarse Grids::Grid Level=3
Memory Use Information::Coarse Grids::Memory used=4.1684e-05
########## V&V Testing Summary  ##########=
Spectral Convergence Tests=
Spectral Convergence Tests::Result=PASSED
Spectral Convergence Tests::Unpreconditioned=
Spectral Convergence Tests::Unpreconditioned::Maximum iteration count=11
Spectral Convergence Tests::Unpreconditioned::Expected iteration count=12
Spectral Convergence Tests::Preconditioned=
Spectral Convergence Tests::Preconditioned::Maximum iteration count=2
Spectral Convergence Tests::Preconditioned::Expected iteration count=2
Departure from Symmetry |x'Ay-y'Ax|/(2*||x||*||A||*||y||)/epsilon=
Departure from Symmetry |x'Ay-y'Ax|/(2*||x||*||A||*||y||)/epsilon::Result=PASSED
Departure from Symmetry |x'Ay-y'Ax|/(2*||x||*||A||*||y||)/epsilon::Departure for SpMV=1.62973e-06
Departure from Symmetry |x'Ay-y'Ax|/(2*||x||*||A||*||y||)/epsilon::Departure for MG=5.43242e-08
########## Iterations Summary  ##########=
Iteration Count Information=
Iteration Count Information::Result=PASSED
Iteration Count Information::Reference CG iterations per set=50
Iteration Count Information::Optimized CG iterations per set=50
Iteration Count Information::Total number of reference iterations=50
Iteration Count Information::Total number of optimized iterations=50
########## Reproducibility Summary  ##########=
Reproducibility Information=
Reproducibility Information::Result=PASSED
Reproducibility Information::Scaled residual mean=1.75736e-19
Reproducibility Information::Scaled residual variance=0
########## Performance Summary (times in sec) ##########=
Benchmark Time Summary=
Benchmark Time Summary::Optimization phase=1.8e-06
Benchmark Time Summary::DDOT=0.0206956
Benchmark Time Summary::WAXPBY=0.009283
Benchmark Time Summary::SpMV=0.0833918
Benchmark Time Summary::MG=0.478476
Benchmark Time Summary::Total=0.592246
Floating Point Operations Summary=
Floating Point Operations Summary::Raw DDOT=9.89594e+06
Floating Point Operations Summary::Raw WAXPBY=9.89594e+06
Floating Point Operations Summary::Raw SpMV=8.47196e+07
Floating Point Operations Summary::Raw MG=4.69484e+08
Floating Point Operations Summary::Total=5.73995e+08
Floating Point Operations Summary::Total with convergence overhead=5.73995e+08
GB/s Summary=
GB/s Summary::Raw Read B/W=5.98029
GB/s Summary::Raw Write B/W=1.38251
GB/s Summary::Raw Total B/W=7.3628
GB/s Summary::Total with convergence and optimization phase overhead=7.21769
GFLOP/s Summary=
GFLOP/s Summary::Raw DDOT=0.478166
GFLOP/s Summary::Raw WAXPBY=1.06603
GFLOP/s Summary::Raw SpMV=1.01592
GFLOP/s Summary::Raw MG=0.981207
GFLOP/s Summary::Raw Total=0.969184
GFLOP/s Summary::Total with convergence overhead=0.969184
GFLOP/s Summary::Total with convergence and optimization phase overhead=0.950083
User Optimization Overheads=
User Optimization Overheads::Optimization phase time (sec)=1.8e-06
User Optimization Overheads::Optimization phase time vs reference SpMV+MG time=0.000131543
DDOT Timing Variations=
DDOT Timing Variations::Min DDOT MPI_Allreduce time=0.0065313
DDOT Timing Variations::Max DDOT MPI_Allreduce time=0.0117978
DDOT Timing Variations::Avg DDOT MPI_Allreduce time=0.0101723
Final Summary=
Final Summary::HPCG result is VALID with a GFLOP/s rating of=0.950083
Final Summary::HPCG 2.4 rating for historical reasons is=0.969184
Final Summary::Reference version of ComputeDotProduct used=Performance results are most likely suboptimal
Final Summary::Reference version of ComputeSPMV used=Performance results are most likely suboptimal
Final Summary::Reference version of ComputeMG used=Performance results are most likely suboptimal
Final Summary::Reference version of ComputeWAXPBY used=Performance results are most likely suboptimal
Final Summary::Results are valid but execution time (sec) is=0.592246
Final Summary::You have selected the QuickPath option=Results are official for legacy installed systems with confirmation from the HPCG Benchmark leaders.
Final Summary::After confirmation please upload results from the YAML file contents to=http://hpcg-benchmark.org
````

关键性能指标是 Final Summary::HPCG result is VALID with a GFLOP/s rating of=0.950083，表示每秒十亿次浮点运算次数为 0.950083，即每秒能完成 950083 0000 次浮点运算

FLOP：一次浮点运算（如加法、乘法等涉及小数的运算）

1 GFLOP/s = 10⁹ FLOP/s：表示每秒能完成10亿次浮点运算。

若一个CPU的HPCG测试结果为 50 GFLOP/s，意味着它每秒能完成500亿次浮点运算



参考：

https://github.com/hpcg-benchmark/hpcg/blob/master/INSTALL

https://www.cnblogs.com/lijiaji/p/14283958.html
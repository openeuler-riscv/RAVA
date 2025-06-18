# 性能测试工具调研
- 环境：[qemu中的openEuler25.03-RISCV64](https://repo.openeuler.org/openEuler-25.03/virtual_machine_img/riscv64/)
- 所调研测试工具：sysbench

## 1 sysbench测试
下载安装sysbench

```
dnf install -y sysbench
```
sysbench版本为1.0.20
```
[root@localhost ~]# sysbench --version
sysbench 1.0.20
```
查看帮助
```
sysbench --help
```
从帮助信息可以看出sysbench支持文件IO测试，CPU性能测试，内存测试，线程测试以及mutex互斥测试
```
Compiled-in tests:
    fileio - File I/O test
    cpu - CPU performance test
    memory - Memory functions speed test
    threads - Threads subsystem performance test
    mutex - Mutex performance test
```
sysbench命令行语法：
```
sysbench [options]... [testname] [command]
```
options包含一系列选项，包括--threads(创建工作线程数量)、--time(测试执行时间)等  
testname是内置测试的可选名称(如fileio，memory，cpu等)  
command是一个可选参数，定义测试需执行的命令，主要有
- prepare(为测试做准备)
- run(运行测试)
- cleanup(清除测试产生的临时数据)
- help(显示测试帮助信息)

### 1.1 文件IO测试方法
```
[root@localhost ~]# sysbench --test=fileio help
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.20 (using system LuaJIT 2.1.ROLLING)

fileio options:
  --file-num=N                  number of files to create [128]
  --file-block-size=N           block size to use in all IO operations [16384]
  --file-total-size=SIZE        total size of files to create [2G]
  --file-test-mode=STRING       test mode {seqwr, seqrewr, seqrd, rndrd, rndwr, rndrw}
  --file-io-mode=STRING         file operations mode {sync,async,mmap} [sync]
  --file-async-backlog=N        number of asynchronous operatons to queue per thread [128]
  --file-extra-flags=[LIST,...] list of additional flags to use to open files {sync,dsync,direct} []
  --file-fsync-freq=N           do fsync() after this number of requests (0 - don't use fsync()) [100]
  --file-fsync-all[=on|off]     do fsync() after each write operation [off]
  --file-fsync-end[=on|off]     do fsync() at the end of test [on]
  --file-fsync-mode=STRING      which method to use for synchronization {fsync, fdatasync} [fsync]
  --file-merged-requests=N      merge at most this number of IO requests if possible (0 - don't merge) [0]
  --file-rw-ratio=N             reads/writes ratio for combined test [1.5]
```
--file-num，--file-block-size，--file-total-size用于准备测试文件，--file-test-mode可设置为顺序读\写，随机读\写。  
--file-fsync用于fsync()函数相关的测试

本次测试采用顺序读写文件的方式进行，测试文件数量为2，大小共5G，工作线程设置为4，测试30s：
- 首先使用prepare准备文件
```
[root@localhost ~]# sysbench --threads=4 --time=30 --report-interval=5 fileio --file-num=2 --file-total-size=5G --file-test-mode=seqrewr prepare
sysbench 1.0.20 (using system LuaJIT 2.1.ROLLING)

2 files, 2621440Kb each, 5120Mb total
Creating files for the test...
Extra file open flags: (none)
Creating file test_file.0
Creating file test_file.1
5368709120 bytes written in 46.86 seconds (109.25 MiB/sec).
```
- 执行测试
```
    sysbench --threads=4 --time=60 --report-interval=5 fileio --file-num=2 --file-total-size=10G --file-test-mode=seqrewr run
```
测试正常，结果如下：
```
File operations:
    reads/s:                      0.00
    writes/s:                     22911.19
    fsyncs/s:                     458.49

Throughput:
    read, MiB/s:                  0.00
    written, MiB/s:               357.99

General statistics:
    total time:                          30.0137s
    total number of events:              701454

Latency (ms):
         min:                                    0.01
         avg:                                    0.17
         max:                                  317.97
         95th percentile:                        0.15
         sum:                               118345.56

Threads fairness:
    events (avg/stddev):           175363.5000/1012.16
    execution time (avg/stddev):   29.5864/0.02
```
- 测试后删除临时文件
```
sysbench --threads=4 --time=60 --report-interval=5 fileio --file-num=2 --file-total-size=10G --file-test-mode=seqrewr cleanup
``` 
### 1.2 CPU测试方法
```
[root@localhost ~]# sysbench cpu help
sysbench 1.0.20 (using system LuaJIT 2.1.ROLLING)

cpu options:
  --cpu-max-prime=N upper limit for primes generator [10000]
```
CPU测试主要通过生成素数来测试CPU性能，通过--cpu-max-prime设置素数上限  

本次测试使用默认素数上限，设置线程数量为4，测试时间30s，执行测试：
```
sysbench --threads=4 --time=30 --report-interval=5 cpu run
```
测试正常，结果如下：
```
CPU speed:
    events per second:  3224.53

General statistics:
    total time:                          30.0085s
    total number of events:              96771

Latency (ms):
         min:                                    1.12
         avg:                                    1.24
         max:                                    6.79
         95th percentile:                        1.37
         sum:                               119718.56

Threads fairness:
    events (avg/stddev):           24192.7500/61.04
    execution time (avg/stddev):   29.9296/0.01

```
### 1.3 内存测试方法
```
[root@localhost ~]# sysbench memory help
sysbench 1.0.20 (using system LuaJIT 2.1.ROLLING)

memory options:
  --memory-block-size=SIZE    size of memory block for test [1K]
  --memory-total-size=SIZE    total size of data to transfer [100G]
  --memory-scope=STRING       memory access scope {global,local} [global]
  --memory-hugetlb[=on|off]   allocate memory from HugeTLB pool [off]
  --memory-oper=STRING        type of memory operations {read, write, none} [write]
  --memory-access-mode=STRING memory access mode {seq,rnd} [seq]
```
--memory-block-siz，--memory-total-size用于设置测试内存，--memory-oper设置操作方式为读\写，--memory-access-mode设置访问模式为随机\顺序  

使用默认的顺序写方式进行测试，线程数为4，测试30s：
```
sysbench --threads=4 --time=30 --report-interval=5 memory run
```
测试正常，结果如下：
```
Total operations: 69023675 (2300037.15 per second)

67405.93 MiB transferred (2246.13 MiB/sec)


General statistics:
    total time:                          30.0079s
    total number of events:              69023675

Latency (ms):
         min:                                    0.00
         avg:                                    0.00
         max:                                   10.13
         95th percentile:                        0.00
         sum:                                48754.23

Threads fairness:
    events (avg/stddev):           17255918.7500/1284940.16
    execution time (avg/stddev):   12.1886/0.53
```
### 1.4 线程测试方法
```
[root@localhost ~]# sysbench threads help
sysbench 1.0.20 (using system LuaJIT 2.1.ROLLING)

threads options:
  --thread-yields=N number of yields to do per request [1000]
  --thread-locks=N  number of locks per thread [8]
```
--thread-yields指定每个请求的压力，--thread-locks指定每个线程锁的数量  

测试使用4线程，其余默认：
```
sysbench --threads=4 --report-interval=5 threads run
```
测试正常，结果如下：
```
General statistics:
    total time:                          10.0104s
    total number of events:              16905

Latency (ms):
         min:                                    1.84
         avg:                                    2.36
         max:                                   51.70
         95th percentile:                        2.61
         sum:                                39896.61

Threads fairness:
    events (avg/stddev):           4226.2500/34.52
    execution time (avg/stddev):   9.9742/0.00
```
### 1.5 mutex测试
```
[root@localhost ~]# sysbench mutex help
sysbench 1.0.20 (using system LuaJIT 2.1.ROLLING)

mutex options:
  --mutex-num=N   total size of mutex array [4096]
  --mutex-locks=N number of mutex locks to do per thread [50000]
  --mutex-loops=N number of empty loops to do outside mutex lock [10000]
```
--mutex-num数组互斥的总大小，--mutex-locks每个线程互斥锁的数量，--mutex-loops外部互斥锁的空循环数量  

测试使用默认设置，4线程：
```
sysbench --threads=4 mutex run
```
测试正常：结果如下：
```
General statistics:
    total time:                          0.4573s
    total number of events:              4

Latency (ms):
         min:                                  442.96
         avg:                                  449.20
         max:                                  454.91
         95th percentile:                      458.96
         sum:                                 1796.79

Threads fairness:
    events (avg/stddev):           1.0000/0.00
    execution time (avg/stddev):   0.4492/0.00
```
### 1.6 总结
经测试，sysbench测试工具在openEuler25.03-RISCV64环境下可正常执行各性能测试。
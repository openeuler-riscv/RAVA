### 在openEuler riscv64中使用sysbench进行性能测试

#### 1. sysbench介绍

sysbench是一个开源的、模块化的、跨平台的多线程性能测试工具，可以用来进行CPU、内存、磁盘I/O、线程、数据库的性能测试。目前支持的数据库有MySQL、Oracle和PostgreSQL。

#### 2. sysbench安装和查看使用说明

##### 2.1 sysbench安装

````
$ yum -y install sysbench 
````

##### 2.2 查看使用说明

查看sysbench命令格式和参数

````
$ sysbench --help
Usage:
  sysbench [options]... [testname] [command]

Commands implemented by most tests: prepare run cleanup help

General options:
  --threads=N                     number of threads to use [1]
  --events=N                      limit for total number of events [0]
  --time=N                        limit for total execution time in seconds [10]
  --forced-shutdown=STRING        number of seconds to wait after the --time limit before forcing shutdown, or 'off' to disable [off]
  --thread-stack-size=SIZE        size of stack per thread [64K]
  --rate=N                        average transactions rate. 0 for unlimited rate [0]
  --report-interval=N             periodically report intermediate statistics with a specified interval in seconds. 0 disables intermediate reports [0]
  --report-checkpoints=[LIST,...] dump full statistics and reset all counters at specified points in time. The argument is a list of comma-separated values representing the amount of time in seconds elapsed from start of test when report checkpoint(s) must be performed. Report checkpoints are off by default. []
  --debug[=on|off]                print more debugging info [off]
  --validate[=on|off]             perform validation checks where possible [off]
  --help[=on|off]                 print help and exit [off]
  --version[=on|off]              print version and exit [off]
  --config-file=FILENAME          File containing command line options
  --tx-rate=N                     deprecated alias for --rate [0]
  --max-requests=N                deprecated alias for --events [0]
  --max-time=N                    deprecated alias for --time [0]
  --num-threads=N                 deprecated alias for --threads [1]

Pseudo-Random Numbers Generator options:
  --rand-type=STRING random numbers distribution {uniform,gaussian,special,pareto} [special]
  --rand-spec-iter=N number of iterations used for numbers generation [12]
  --rand-spec-pct=N  percentage of values to be treated as 'special' (for special distribution) [1]
  --rand-spec-res=N  percentage of 'special' values to use (for special distribution) [75]
  --rand-seed=N      seed for random number generator. When 0, the current time is used as a RNG seed. [0]
  --rand-pareto-h=N  parameter h for pareto distribution [0.2]

Log options:
  --verbosity=N verbosity level {5 - debug, 0 - only critical messages} [3]

  --percentile=N       percentile to calculate in latency statistics (1-100). Use the special value of 0 to disable percentile calculations [95]
  --histogram[=on|off] print latency histogram in report [off]

General database options:

  --db-driver=STRING  specifies database driver to use ('help' to get list of available drivers) [mysql]
  --db-ps-mode=STRING prepared statements usage mode {auto, disable} [auto]
  --db-debug[=on|off] print database-specific debug information [off]


Compiled-in database drivers:
  mysql - MySQL driver
  pgsql - PostgreSQL driver

mysql options:
  --mysql-host=[LIST,...]          MySQL server host [localhost]
  --mysql-port=[LIST,...]          MySQL server port [3306]
  --mysql-socket=[LIST,...]        MySQL socket
  --mysql-user=STRING              MySQL user [sbtest]
  --mysql-password=STRING          MySQL password []
  --mysql-db=STRING                MySQL database name [sbtest]
  --mysql-ssl[=on|off]             use SSL connections, if available in the client library [off]
  --mysql-ssl-cipher=STRING        use specific cipher for SSL connections []
  --mysql-compression[=on|off]     use compression, if available in the client library [off]
  --mysql-debug[=on|off]           trace all client library calls [off]
  --mysql-ignore-errors=[LIST,...] list of errors to ignore, or "all" [1213,1020,1205]
  --mysql-dry-run[=on|off]         Dry run, pretend that all MySQL client API calls are successful without executing them [off]

pgsql options:
  --pgsql-host=STRING     PostgreSQL server host [localhost]
  --pgsql-port=N          PostgreSQL server port [5432]
  --pgsql-user=STRING     PostgreSQL user [sbtest]
  --pgsql-password=STRING PostgreSQL password []
  --pgsql-db=STRING       PostgreSQL database name [sbtest]

Compiled-in tests:
  fileio - File I/O test
  cpu - CPU performance test
  memory - Memory functions speed test
  threads - Threads subsystem performance test
  mutex - Mutex performance test

See 'sysbench <testname> help' for a list of options for each test.
````

查看测试CPU性能的帮助文档

````
$ sysbench cpu help
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

cpu options:
  --cpu-max-prime=N upper limit for primes generator [10000]
````

查看磁盘IO性能测试的帮助文档

````
$ sysbench fileio help
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

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
````

查看内存性能测试的帮助文档

````
$ sysbench memory help
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

memory options:
  --memory-block-size=SIZE    size of memory block for test [1K]
  --memory-total-size=SIZE    total size of data to transfer [100G]
  --memory-scope=STRING       memory access scope {global,local} [global]
  --memory-hugetlb[=on|off]   allocate memory from HugeTLB pool [off]
  --memory-oper=STRING        type of memory operations {read, write, none} [write]
  --memory-access-mode=STRING memory access mode {seq,rnd} [seq]
````

查看线程性能测试的帮助文档

````
$ sysbench threads help
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

threads options:
  --thread-yields=N number of yields to do per request [1000]
  --thread-locks=N  number of locks per thread [8]
````

查看mutex(互斥锁)测试的帮助文档，该项测试主要用于评估多线程竞争锁的性能，模拟高并发场景下线程对共享资源的争夺，检测系统的线程调度和锁机制效率。

````
$ sysbench mutex help
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

mutex options:
  --mutex-num=N   total size of mutex array [4096]
  --mutex-locks=N number of mutex locks to do per thread [50000]
  --mutex-loops=N number of empty loops to do outside mutex lock [10000]
````

#### 3. 执行测试

##### 3.1 测试CPU性能

````
$ sysbench --test=cpu run
WARNING: the --test option is deprecated. You can pass a script name or path on the command line without any options.
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Prime numbers limit: 10000

Initializing worker threads...

Threads started!

CPU speed:
    events per second:   351.58

General statistics:
    total time:                          10.0017s
    total number of events:              3521

Latency (ms):
         min:                                    2.78
         avg:                                    2.84
         max:                                   17.03
         95th percentile:                        2.86
         sum:                                 9985.93

Threads fairness:
    events (avg/stddev):           3521.0000/0.00
    execution time (avg/stddev):   9.9859/0.00
````

分析测试结果：

1）测试配置

````
sysbench 1.0.20 (using system LuaJIT 2.1.0-beta3)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Prime numbers limit: 10000

Initializing worker threads...

Threads started!
````

这部分列出了 sysbench 的版本信息、测试配置和被使用的测试参数：

Number of threads：测试采用的线程数量

Prime numbers limit：计算范围的上限数字

2）CPU 性能指标

````
CPU speed:
    events per second:   351.58
````

events per second 指在 CPU 执行素数计算时的每秒事件数，即每秒处理事件个数，是衡量性能的直接指标，值越高表示CPU运算能力越强，整体性能越好。

3）一般统计信息

````
General statistics:
    total time:                          10.0017s
    total number of events:              3521
````

total time：整体任务执行所需的时间，反映CPU处理任务的总效率，时间越短越好。

total number of events：总执行事件数（即计算出的素数个数）。

4）延迟统计

````
Latency (ms):
         min:                                    2.78
         avg:                                    2.84
         max:                                   17.03
         95th percentile:                        2.86
         sum:                                 9985.93
````

延迟统计显示了每个事件（或事务）的执行时间，单位为毫秒：

min：最短执行时间。

avg：平均执行时间，延迟越低，CPU单个任务性能越好。

max：最长执行时间。

95th percentile：95% 的延迟在此时间以下（从排序结果中取95%处的值）。

sum：所有事件执行时间的总和。

5）线程公平性

````
Threads fairness:
    events (avg/stddev):           3521.0000/0.00
    execution time (avg/stddev):   9.9859/0.00
````

线程公平性（通常在单线程测试中不展示）测量任务在多个线程中执行的均衡性：

events (avg/stddev)：每个线程执行事件的平均数和标准偏差，值越小，说明越稳定。

execution time (avg/stddev)：每个线程执行时间的平均值与标准偏差。

在多线程测试中，这是关键指标，而在单线程测试中它们应该是恒定不变的。

##### 3.2 测试 I/O 性能

File I/O 测试主要涉及以下步骤：

准备测试文件

执行 I/O 性能测试

清理测试文件

准备测试文件，完成后会在当前目录下生成很多小文件

````
$ sysbench --test=fileio --file-total-size=1G prepare
````

--file-total-size=1G：定义测试文件总大小为 1G。

执行 I/O 性能测试

````
$ sysbench --test=fileio --file-extra-flags=direct --file-total-size=1G --file-test-mode=rndrw --time=60 --max-requests=0 run
````

--file-extra-flags=direct：绕过缓存，直接访问磁盘

--file-total-size=1G：定义测试文件总大小为 1G（与准备阶段保持一致）。

--file-test-mode=rndrw：设置测试模式为随机读写。其他模式包括 seqwr（顺序写）、seqrd（顺序读）、seqrewr（顺序读取和重写）、rndrd（随机读）、rndwr（随机写）。

--time=60：设置测试运行时间为 60 秒。

--max-requests=0：设置请求总数为 0，意味着测试在运行时间结束前不会被中断。

清理文件

````
$ sysbench --test=fileio --file-total-size=1G cleanup
````

结果分析：

````
sysbench 1.0.20 (using system LuaJIT 2.1.ROLLING)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Extra file open flags: (none)
128 files, 8MiB each
1GiB total file size
Block size 16KiB
Number of IO requests: 0
Read/Write ratio for combined random IO test: 1.50
Periodic FSYNC enabled, calling fsync() each 100 requests.
Calling fsync() at the end of test, Enabled.
Using synchronous I/O mode
Doing random r/w test
Initializing worker threads...

Threads started!


File operations:File operations:
    reads/s:                      1004.89
    writes/s:                     669.93
    fsyncs/s:                     2145.04

Throughput:
    read, MiB/s:                  15.70
    written, MiB/s:               10.47

General statistics:
    total time:                          60.0361s
    total number of events:              229317

Latency (ms):
         min:                                    0.01
         avg:                                    0.26
         max:                                   10.50
         95th percentile:                        0.86
         sum:                                58609.50

Threads fairness:
    events (avg/stddev):           229317.0000/0.00
    execution time (avg/stddev):   58.6095/0.00
````

File operations：

reads/s：每秒读操作次数。

writes/s：每秒写操作次数。

fsyncs/s：每秒 fsync 同步操作次数，表示把数据安全地写入磁盘的次数（反映数据持久化到磁盘的频率）。

Throughput：

read, MiB/s：每秒读取的数据量。

written, MiB/s：每秒写入的数据量。

General statistics：

total time：整体测试的时间。

total number of events：总的 I/O 操作数。

Latency (ms)：

min：最短延迟时间。

avg：平均延迟时间。

max：最长延迟时间。

95th percentile：95% 操作的延迟时间。

sum：所有 I/O 操作总的延迟时间。

Threads fairness：

events (avg/stddev)：每个线程执行的事件平均数和标准偏差。

execution time (avg/stddev)：每个线程的执行时间平均值和标准偏差。

这些指标可以帮助你理解系统在文件 I/O 负载下的性能表现，包括吞吐量、延迟、和文件系统同步操作的效率。

##### 3.3 测试内存性能

````
$ sysbench --test=memory --memory-block-size=1K --memory-total-size=1G --memory-oper=write --threads=4 run
````

--memory-block-size: 每次操作的内存块大小（默认 1KB）。

--memory-total-size: 测试总数据量（默认 100G）。

--memory-oper: 操作模式，可选 read（读）、write（写）或 none（无操作，通常用于调试或空操作测试）(默认 wirte）。

--threads: 并发线程数（默认为 1）。

--time: 测试持续时间（单位：秒，替代 --memory-total-size）

用 --time 代替 --memory-total-size

````
$ sysbench --test=memory --memory-block-size=1K --memory-oper=rnd --threads=4 --time=30 run
````

测试结果分析

````
sysbench 1.0.20 (using system LuaJIT 2.1.ROLLING)

Running the test with following options:
Number of threads: 4
Initializing random number generator from current time


Running memory speed test with the following options:
  block size: 1KiB
  total size: 1024MiB
  operation: write
  scope: global

Initializing worker threads...

Threads started!

Total operations: 1048576 (866669.52 per second)        # 总事务数、每秒事务数（操作效率）

1024.00 MiB transferred (846.36 MiB/sec)                # 总传输大小，每秒传输大小（内存吞吐量）


General statistics:
    total time:                          1.1849s
    total number of events:              1048576

Latency (ms):
         min:                                    0.00      
         avg:                                    0.00
         max:                                    0.50
         95th percentile:                        0.00
         sum:                                 1153.08

Threads fairness:
    events (avg/stddev):           262144.0000/0.00      
    execution time (avg/stddev):   0.2883/0.05          
````

关键指标：

Total operations : 总操作次数。

Operations per second (ops/sec) : 每秒操作数，值越高性能越好。

Total time (s) : 测试总耗时。

Transferred (MB/s) : 内存传输速率，即内存带宽，值越高表示性能越好。

##### 3.4 测试线程

````
$ sysbench  --test=threads --thread-yields=100 --thread-locks=4 run
````

--thread-yields: 每个线程产生的 yield 操作次数（默认为 1000）。

--thread-locks: 每个线程持有的互斥锁数量（默认为 8）。

测试结果解析

````
sysbench 1.0.20 (using system LuaJIT 2.1.ROLLING)

Running the test with following options:
Number of threads: 1
Initializing random number generator from current time


Initializing worker threads...

Threads started!


General statistics:
    total time:                          10.0020s
    total number of events:              29695

Latency (ms):
         min:                                    0.31
         avg:                                    0.33
         max:                                    1.18
         95th percentile:                        0.38
         sum:                                 9920.05

Threads fairness:
    events (avg/stddev):           29695.0000/0.00
    execution time (avg/stddev):   9.9201/0.00
````

关键指标：

total time: 测试从开始到结束的总时间，时间越短，说明线程调度和同步操作的效率越高。

total number of events: 所有线程完成的事件（操作）总数。单位时间内事件越多，系统吞吐量越高。

Latency: 延迟统计

min：最小延迟（最佳情况）。

avg ：平均延迟。

max ：最大延迟（最差情况）。

95th percentile ：95% 的请求延迟低于此值。

sum ：所有事件延迟总和。

avg 和 95th percentile 是核心指标，越低越好

max 过高可能表明存在锁竞争或调度瓶颈。

events (avg/stddev)：每个线程处理事件的均值和标准差。

execution time (avg/stddev)：每个线程执行时间的均值和标准差。

标准差（stddev）越小，说明线程间负载越均衡。

若标准差较大，可能是线程调度不均匀或资源争用导致。

##### 3.5 测试  mutex

测试 4 个线程，全局 1024 个锁，每个线程请求 100,000 次锁，每次锁操作后执行 1000 次空循环

````
$ sysbench --test=mutex --mutex-num=1024 --mutex-locks=100000 --mutex-loops=1000 --threads=4 run
````

--mutex-num: 全局互斥锁的数量（默认为 4096）。

--mutex-locks: 每个线程请求的锁总数（默认为 50,000）。

--mutex-loops: 每次锁操作后的空循环次数（默认为 10,000）。

--threads: 并发线程数（默认为 1）。以上测试cpu，fileio，memory，threads，mutex都可以添加参数 --threads来指定执行测试时创建线程的数目

测试结果分析

````
sysbench 1.0.20 (using system LuaJIT 2.1.ROLLING)

Running the test with following options:
Number of threads: 4
Initializing random number generator from current time


Initializing worker threads...

Threads started!


General statistics:
    total time:                          0.2695s
    total number of events:              4

Latency (ms):
         min:                                  249.72
         avg:                                  255.49
         max:                                  267.19
         95th percentile:                      267.41
         sum:                                 1021.98

Threads fairness:
    events (avg/stddev):           1.0000/0.00
    execution time (avg/stddev):   0.2555/0.01
````

关键指标：

total time: 测试总耗时，越短说明锁操作效率越高。

Latency (ms)

avg：平均延迟，反映锁竞争的平均开销。

max 和 95th percentile：高延迟表明存在严重锁竞争或调度问题。

Threads fairness

events/stddev：事件分布标准差大，说明线程负载不均衡。

execution time/stddev：执行时间差异大，可能因锁竞争或 CPU 调度不均。





参考：

https://github.com/akopytov/sysbench 

https://imysql.com/wp-content/uploads/2014/10/sysbench-manual.pdf

https://blog.csdn.net/qq_39208536/article/details/119672946

https://www.51cto.com/article/669694.html

https://www.cnblogs.com/chenmh/p/5866058.html

https://www.cnblogs.com/muahao/p/6379774.html
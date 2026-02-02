## 在 openEuler RISC-V 执行 rt-tests 性能测试

### 1. rt-tests 介绍

rt-tests (Real-Time Tests) 是一个专门用于测试 Linux 系统实时性能的工具集，它对于评估系统在实时任务中的确定性、响应速度和延迟至关重要。

核心组件

| 工具名称            | 主要功能                                                     |
| ------------------- | ------------------------------------------------------------ |
| **cyclictest**      | 测量系统延迟（从事件触发到线程响应的时长），最常用的实时性测试工具，通过多线程定时唤醒机制测试系统调度延迟和最大延迟。应用场景是实时性基准测试、中断延迟分析。 |
| **cyclicdeadline**  | 测试周期性任务的截止时间（Deadline）满足情况。应用场景是测试周期性任务的截止时间（Deadline）满足情况。 |
| **hackbench**       | 产生调度器负载，用于测试调度器的性能和吞吐量，常作为制造系统压力的工具。 |
| **hwlatdetect**     | 检测系统是否存在硬件引起的延迟（如 BIOS 电源管理、显卡驱动等造成的系统管理中断 SMIs）。应用场景是实时性基准测试、中断延迟分析。 |
| **pi_stress**       | 创建优先级反转场景进行压力测试，测试优先级继承（Priority Inheritance）机制是否正常工作，评估实时系统避免优先级反转的能力。应用场景是死锁预防机制测试。 |
| **pip_stress**      | 创建优先级反转场景进行压力测试。应用场景是死锁预防机制测试   |
| **pmqtest**         | 测试 POSIX 消息队列的通信延迟。应用场景是进程通信性能分析。  |
| **ptsematest**      | 测试 POSIX 信号量的同步延迟性能。应用场景是同步原语性能测试。 |
| **rt-migrate-test** | 测试实时任务在 CPU 之间迁移时的延迟影响。应用场景是多核负载均衡验证。 |
| **signaltest**      | 测量信号传递延迟，信号等待行为的实时性。应用场景是信号处理性能分析。 |
| **svsematest**      | 测试System V信号量操作延迟，系统信号量的性能。应用场景是传统IPC机制测试。 |
| **queuelat**        | 测量中断线程化后的中断处理延迟。应用场景是中断性能分析。     |



### 2. 测试方法

rt-tests 从源码编译安装，先安装依赖

````
$ dnf install -y git make gcc numactl-devel
````

下载 rt-tests 源码，编译安装

````
$ git clone git://git.kernel.org/pub/scm/utils/rt-tests/rt-tests.git
$ cd rt-tests
$ make
$ make install 
````

#### 2.1 cyclictest 时延性能测试

##### 2.1.1 介绍

cyckictest 是 rt-tests 下的一个测试工具，也是 rt-tests 下使用最广泛的测试工具，一般主要用来测试内核的延迟，从而判断内核的实时性。

cyclictest 通过创建多个实时线程来工作，这些线程会定期唤醒（例如，每 1000 微秒）并测量实际唤醒时间与预期唤醒时间之间的差异（延迟）。通过统计这些延迟，可以评估系统的实时性能。

编译完成后生成二进制 cyclictest，执行 help 命令查看执行 cyclictest 时可配置的参数

````
$ cyclictest --help
cyclictest V 2.80
Usage:
cyclictest <options>

-a [CPUSET] --affinity     Run thread #N on processor #N, if possible,
                           or if CPUSET given, pin threads to that set of
                           processors in round-robin order.
                           E.g. -a 2 pins all threads to CPU 2, but
                           -a 3-5,0 -t 5 will run the first and fifth threads
                           on CPU 0, the second thread on CPU 3,
                           the third thread on CPU 4,
                           and the fourth thread on CPU 5.
-A USEC  --aligned=USEC    align thread wakeups to a specific offset
-b USEC  --breaktrace=USEC send break trace command when latency > USEC
-c CLOCK --clock=CLOCK     select clock
                           0 = CLOCK_MONOTONIC (default)
                           1 = CLOCK_REALTIME
         --deepest-idle-state=n
                           Reduce exit from idle latency by limiting idle state
                           up to n on used cpus (-1 disables all idle states).
                           Power management is not suppresed on other cpus.
         --default-system  Don't attempt to tune the system from cyclictest.
                           Power management is not suppressed.
                           This might give poorer results, but will allow you
                           to discover if you need to tune the system
-d DIST  --distance=DIST   distance of thread intervals in us, default=500
-D       --duration=TIME   specify a length for the test run.
                           Append 'm', 'h', or 'd' to specify minutes, hours or days.
-F       --fifo=<path>     create a named pipe at path and write stats to it
-h       --histogram=US    dump a latency histogram to stdout after the run
                           US is the max latency time to be tracked in microseconds
                           This option runs all threads at the same priority.
-H       --histofall=US    same as -h except with an additional summary column
         --histfile=<path> dump the latency histogram to <path> instead of stdout
-i INTV  --interval=INTV   base interval of thread in us default=1000
         --json=FILENAME   write final results into FILENAME, JSON formatted
         --laptop          Save battery when running cyclictest
                           This will give you poorer realtime results
                           but will not drain your battery so quickly
         --latency=PM_QOS  power management latency target value
                           This value is written to /dev/cpu_dma_latency
                           and affects c-states. The default is 0
-l LOOPS --loops=LOOPS     number of loops: default=0(endless)
         --mainaffinity=CPUSET
                           Run the main thread on CPU #N. This only affects
                           the main thread and not the measurement threads
-m       --mlockall        lock current and future memory allocations
-M       --refresh_on_max  delay updating the screen until a new max
                           latency is hit. Useful for low bandwidth.
-N       --nsecs           print results in ns instead of us (default us)
-o RED   --oscope=RED      oscilloscope mode, reduce verbose output by RED
-p PRIO  --priority=PRIO   priority of highest prio thread
         --policy=NAME     policy of measurement thread, where NAME may be one
                           of: other, normal, batch, idle, fifo or rr.
         --priospread      spread priority levels starting at specified value
-q       --quiet           print a summary only on exit
-r       --relative        use relative timer instead of absolute
-R       --resolution      check clock resolution, calling clock_gettime() many
                           times.  List of clock_gettime() values will be
                           reported with -X
         --secaligned [USEC] align thread wakeups to the next full second
                           and apply the optional offset
-s       --system          use sys_nanosleep and sys_setitimer
-S       --smp             Standard SMP testing: options -a -t and same priority
                           of all threads
        --spike=<trigger>  record all spikes > trigger
        --spike-nodes=[num of nodes]
                           These are the maximum number of spikes we can record.
                           The default is 1024 if not specified
-t       --threads         one thread per available processor
-t [NUM] --threads=NUM     number of threads:
                           without NUM, threads = max_cpus
                           without -t default = 1
         --tracemark       write a trace mark when -b latency is exceeded
-u       --unbuffered      force unbuffered output for live processing
-v       --verbose         output values on stdout for statistics
                           format: n:c:v n=tasknum c=count v=value in us
         --dbg_cyclictest  print info useful for debugging cyclictest
-x       --posix_timers    use POSIX timers instead of clock_nanosleep.
````

常用参数说明

| 短选项 | 长选项              | 参数     | 说明                                                         |
| ------ | ------------------- | -------- | ------------------------------------------------------------ |
| -t     | --threads[=NUM]     | [NUM]    | 指定线程数量。如果未指定 NUM，则默认创建与 CPU 核心数相同的线程数。 |
| -p     | --priority=PRIO     | PRIO     | 设置实时线程的优先级。优先级越高（数值越大，通常 99 为最高），线程获得调度的机会就越大。对于测试，通常设置为高优先级（如 80 或 99）。 |
| -i     | --interval=INTV     | INTV     | 设置线程的基础唤醒间隔（单位：微秒）。默认是 1000 微秒（1毫秒）。 |
| -l     | --loops=LOOPS       | LOOPS    | 设置测试循环次数。默认为 0，表示无限循环。通常配合 **-D** 参数指定测试时长。 |
| -a     | --affinity[=CPUSET] | [CPUSET] | 将线程绑定到特定的 CPU 核心上运行。这可以避免线程在核心间迁移带来的延迟，对于精确测试和性能隔离非常有用。例如 `-a 0,2` 或 `-a 1-3`。 |
| -m     | --mlockall          | 无       | 锁定当前和未来的内存分配，防止内存被换出到磁盘（swap），避免因换页操作带来的不可预测延迟。 |
| -n     | --nanosleep         | 无       | 使用 `clock_nanosleep` 系统调用而不是 `posix interval timer`。通常建议使用。 |
| -h     | --histogram=US      | US       | 输出延迟的直方图（所有线程优先级相同）。US 指定要跟踪的最大延迟值（微秒）。结果可用于绘制延迟分布图，直观显示延迟情况。 |
| -D     | --duration=TIME     | TIME     | 指定测试运行的总时间。例如 `-D 1h` 表示运行1小时，`-D 30m` 表示运行30分钟。建议进行长时间测试（如数小时甚至24小时）以捕捉可能的偶发高延迟。 |
| -q     | --quiet             | 无       | 安静模式，只在测试结束时输出摘要信息，避免输出刷屏，适用于脚本自动化测试。 |
| -b     | --breaktrace=USEC   | USEC     | 当延迟超过 USEC 微秒时，触发跟踪并中断测试。这是一个调试功能，可以帮助定位导致高延迟的内核代码路径。需要内核调试支持。 |
| -S     | --smp               | 无       | 为 SMP 系统执行标准测试。相当于 `-t -a -n`，并使所有线程具有相同的优先级。 |

##### 2.1.2 执行测试

常用命令示例：

基础测试：运行5个线程，优先级80：

````
$ cyclictest -t5 -p80
````

绑定CPU并设置间隔：将4个线程分别绑定到4个CPU核心，优先级99，间隔1000微秒，循环100万次：

````
$ cyclictest -a 0-3 -t4 -p99 -i1000 -l1000000 -m
````

输出直方图并指定时长：测试30分钟，并生成最大延迟为1000微秒的直方图：

````
$ cyclictest -t5 -p99 -i1000 -D 30m -h1000 -q -m
````

-q 参数使输出更简洁。

调试高延迟：如果延迟超过100微秒，触发跟踪（需要内核调试支持）：

````
$ cyclictest -t1 -p99 -i1000 -b100
````

解读测试结果

````
$ cyclictest -p 98 -i 1000 -t 2 -D 1m -m
# /dev/cpu_dma_latency set to 0us
policy: fifo: loadavg: 0.03 0.03 0.00 1/683 148286          

T: 0 (148282) P:98 I:1000 C:  59995 Min:     10 Act:   11 Avg:   14 Max:     186
T: 1 (148283) P:98 I:1500 C:  39996 Min:     10 Act:   18 Avg:   16 Max:      89
````

输出字段的含义如下：

`# /dev/cpu_dma_latency set to 0us`：这表示 cyclictest 已成功请求 CPU 进入低功耗状态时也不引入额外延迟。这是预期行为。

`policy: fifo`：表示测试线程使用的是 `SCHED_FIFO` 实时调度策略。这是最高优先级的调度策略，一旦运行就会一直占用CPU直到完成或主动让出。

`loadavg: 0.03 0.03 0.00 1/683 148286`：系统在测试期间的负载平均值（1分钟、5分钟、15分钟），以及进程运行队列信息。负载较低时测试的延迟通常更低。

数据行每一行代表一个线程的结果：

| 字段          | 含义                                          | 说明                                                         |
| ------------- | --------------------------------------------- | ------------------------------------------------------------ |
| T: 0 (146850) | 线程编号（Thread ID）                         | 0 是线程索引号 (Thread Index)，表示第0个线程；括号内是该线程的 PID。 |
| P             | 线程的实时优先级（Priority）                  | Linux 实时优先级范围通常为 0-99，数值越大优先级越高。        |
| I             | 线程的唤醒间隔（Interval），单位是微秒（us）  | 默认是1000us。                                               |
| C             | 计数器（Cycle Count）                         | 线程已经成功触发的次数。线程的时间间隔每达到一次，计数器加1。 |
| Min           | 最小延迟（Minimum Latency），单位是微秒（us） | 该线程测量到的最小延迟。值越小越好。                         |
| Act           | 该线程测量到的最小延迟。值越小越好。          | 最后一次循环测量到的延迟。                                   |
| Avg           | 平均延迟（Average Latency），单位是微秒（us） | 所有测量延迟的平均值。                                       |
| Max           | 最大延迟（Maximum Latency），单位是微秒（us） | 这是最关键的值，表示测量期间遇到的最坏情况延迟。该值越大，说明系统在最坏情况下响应越慢，实时性越差。 |

关键指标解读：

- Max（最大延迟）：这是评估系统实时性能的最重要指标。它显示了最坏情况下的响应时间。即使平均延迟很低，一个很大的最大延迟也可能导致实时任务失败。
- 延迟单位：默认输出是微秒（us），使用 `-N` 参数可以切换为纳秒（ns）显示。
- 调度策略：输出中的 `policy: fifo` 表示线程采用了 `SCHED_FIFO` 实时调度策略。

输出直方图测试结果解析：

````
$ cyclictest -p 98 -i 1000 -t 2 -D 1m -h 1000 -m
# /dev/cpu_dma_latency set to 0us
policy: fifo: loadavg: 0.03 0.01 0.00 1/683 148608          

T: 0 (148604) P:98 I:1000 C:  59998 Min:     10 Act:   17 Avg:   16 Max:      27
T: 1 (148605) P:98 I:1000 C:  59997 Min:     10 Act:   14 Avg:   14 Max:      31
# Histogram
000010 000111   000005
000011 000250   000048
000012 000171   000025
000013 000002   000002
000014 005528   051245
000015 010738   008519
000016 000066   000073
000017 031732   000050
000018 011253   000015
000019 000099   000004
000020 000029   000003
000021 000007   000000
000022 000004   000000
000023 000003   000003
000024 000002   000003
000025 000002   000001
000026 000002   000001
000027 000001   000002
000031 000000   000001
# Min Latencies: 00010 00010           # 每个线程的最小延迟
# Avg Latencies: 00016 00014           # 每个线程的平均延迟
# Max Latencies: 00027 00031           # 每个线程的最大延迟
# Histogram Overflows: 00000 00000
# Histogram Overflow at cycle number:
# Thread 0: 
# Thread 1: 
````

`-h1000`: 生成一个统计范围从 0 到 1000 微秒的直方图。

1）摘要行（Summary Line)

`T: 0 (148604) P:98 I:1000 C:  59998 Min:     10 Act:   17 Avg:   16 Max:      27`
`T: 1 (148605) P:98 I:1000 C:  59997 Min:     10 Act:   14 Avg:   14 Max:      31`

具体解释可以参考上面的描述

2）溢出技术（Histogram Overflows）

`# Histogram Overflows: 00000 00000`

`# Histogram Overflow at cycle number:`

`# Thread 0`: 

`# Thread 1: `

`# Histogram Overflows: 00000`：表示有多少次延迟超过了 `-h` 参数指定的上限（本例中是 1000μs），**`000000`** 表示没有溢出，所有延迟都被成功记录。因为所有线程都没有发生直方图溢出，没有超出1000微秒。这后面是统计溢出的情况，所以为空

3）直方图（Histogram）

第一列数据表示延迟值，如 1us，2us，第二列数据表示线程0对应延迟值上出现的次数，第三列数据表示线程1对应延迟值上出现的次数，例如：

`000011 000250   000048`：表示延迟在10~11us之间，线程0的次数是250，线程1的次数是48 

`000031 000000   000001`：表示延迟在27~31us之间，线程0的次数是0，线程1的次数是1

如果测试中提示 WARN: High resolution timers not available ，内核需要选择 High Resolution Timer Support，即配置 CONFIG_HIGH_RES_TIMERS=y，这个选项使能后，警告会消失。

#### 2.2 cyclicdeadline

##### 2.2.1 介绍

cyclicdeadline 是 rt-tests 测试套件中一个专门用于测试 Linux Deadlin 调度器 SCHED_DEADLINE 实时调度性能的专业工具。

执行 help 命令，查看 cyclicdeadline 的参数

````
$ cyclicdeadline --help
cyclicdeadline V 2.80
Usage:
cyclicdeadline <options>

-a [CPUSET] --affinity     Comma/hyphen separated list of CPUs to run deadline
                           tasks on. An empty CPUSET runs on all CPUs a deadline
                           task.
-D TIME  --duration        Specify a length in seconds for the test run.
                           Append 'm', 'h', or 'd' to specify minutes, hours or
                           days
-h       --help            Show this help menu.
         --histogram=US    dump a latency histogram to stdout after the run
                           US is the max latency time to be tracked in microseconds
                           This option runs all threads at the same priority.
         --histfile=<path> dump the latency histogram to <path> instead of stdout
-i INTV  --interval        The shortest deadline for the tasks in us
                           (default 1000us).
         --json=FILENAME   write final results into FILENAME, JSON formatted
-s STEP  --step            The amount to increase the deadline for each task in us
                           (default 500us).
-t NUM   --threads         The number of threads to run as deadline (default 1).
-q       --quiet           print a summary only on exit
-b USEC  --breaktrace=USEC send break trace command when latency > USEC
         --tracemark       write a trace mark when -b latency is exceeded
                 --debug                   Print debugging info for cyclicdeadline
                 --verbose                 Print useful information about the test
````

参数说明

| 参数           | 缩写 | 值类型   | 说明                                                         | 示例                    |
| -------------- | ---- | -------- | ------------------------------------------------------------ | ----------------------- |
| `--affinity`   | `-a` | CPUSET   | 指定运行 deadline 任务的 CPU 集合                            | `-a 0,2-3`              |
| `--duration`   | `-D` | TIME     | 测试运行时长（可加后缀 s/m/h/d）                             | `-D 5m`                 |
| `--help`       | `-h` | -        | 显示帮助菜单                                                 | `-h`                    |
| `--histogram`  | -    | US       | 输出延迟直方图，指定最大跟踪延迟（单位：微秒）               | `--histogram=1000`      |
| `--histfile`   | -    | path     | 将直方图输出到指定文件而非 stdout                            | `--histfile=./hist.txt` |
| `--interval`   | `-i` | INTV     | 任务的最短截止时间（单位：微秒，默认 1000μs），基准周期，第一个任务的周期（P） | `-i 500`                |
| `--json`       | -    | FILENAME | 以 JSON 格式写入最终结果                                     | `--json=./results.json` |
| `--step`       | `-s` | STEP     | 每个任务截止时间的递增步长（单位：微秒，默认 500μs）(Q)      | `-s 200`                |
| `--threads`    | `-t` | NUM      | 运行的 deadline 线程数（默认 1），创建实时任务的数量         | `-t 4`                  |
| `--quiet`      | `-q` | -        | 仅在退出时打印摘要                                           | `-q`                    |
| `--breaktrace` | `-b` | USEC     | 当延迟 > USEC 时发送中断跟踪命令，触发内核跟踪               | `-b 100`                |
| `--tracemark`  | -    | -        | 当超过 `-b` 设定的延迟时写入跟踪标记                         | `--tracemark`           |
| `--debug`      | -    | -        | 打印调试信息                                                 | `--debug`               |
| `--verbose`    | -    | -        | 打印测试的详细信息，打印每个任务的 Q:P 信息                  | `--verbose`             |

关键特性说明

1）步长测试模式 (`-s/--step`)

这是最强大的功能！**`-s` 参数让每个线程有不同的截止时间**：

- 线程 0: `interval` (基础值)
- 线程 1: `interval + step`
- 线程 2: `interval + 2 * step`

示例：3个线程，截止时间分别为 1000μs, 1500μs, 2000μs

````
$ cyclicdeadline -t 3 -i 1000 -s 500 -D 1m
````

2）强大的调试功能 (`-b/--breaktrace`)

当延迟超过阈值时自动触发内核调试：

示例：当任何延迟超过 100μs 时触发跟踪

````
$ cyclicdeadline -i 1000 -b 100 --tracemark
````

3）多种输出格式

- 人类可读摘要：默认输出或使用 `-q`
- 直方图：`--histogram=1000`
- 机器可读 JSON：`--json=results.json` (非常适合自动化测试)

##### 2.2.1 执行测试

完整测试示例

基础测试：运行4个线程，截止时间从 1ms 开始（-i 指定），每次增加 0.5ms，测试 1 分钟

````
$ cyclicdeadline -q -i 1000 -s 500 -t 4 -D 1m --verbose
Using all CPUS
INFO: interval: 600:1000
INFO:   Tested at 13us of 600us
INFO: interval: 900:1500
INFO:   Tested at 5us of 900us
INFO: interval: 1200:2000
INFO:   Tested at 4us of 1200us
INFO: interval: 1500:2500
INFO:   Tested at 4us of 1500us
T: 0 (163306) I:1000 C:  60001 Min:      1 Act:    4 Avg:    2 Max:      33
T: 1 (163307) I:1500 C:  40001 Min:      1 Act:    5 Avg:    2 Max:      21
T: 2 (163308) I:2000 C:  30001 Min:      1 Act:    7 Avg:    6 Max:     162
T: 3 (163309) I:2500 C:  24001 Min:      3 Act:    3 Avg:    5 Max:      30
````

生成详细报告：绑定到 CPU 0-3，生成直方图和 JSON 报告

````
$ cyclicdeadline -a 0-3 -t 4 -i 500 -s 100 -D 1m \
  --histogram=500 --histfile=./histogram.txt \
  --json=./results.json -q
Creating cpuset 'my_cpuset_all'
Creating cpuset 'my_cpuset'
163329
163330
163331
163332
Removing my_cpuset_all
Removing my_cpuset
````

调试高延迟问题：当延迟超过 50μs 时触发调试跟踪

````
$ cyclicdeadline -t 4 -i 1000 -s 500 -D 1m -b 50 --tracemark --debug
Using all CPUS
INFO: debugfs mountpoint: /sys/kernel/debug/tracing/
DEBUG: deadline thread 163350
DEBUG: thread[163350] runtime=600us deadline=1000us
DEBUG: deadline thread 163351
DEBUG: thread[163351] runtime=900us deadline=1500us
DEBUG: deadline thread 163352
DEBUG: thread[163352] runtime=1200us deadline=2000us
DEBUG: main thread 163349
DEBUG: deadline thread 163353
DEBUG: thread[163353] runtime=1500us deadline=2500us
T: 0 (163350) I:1000 C:  36218 Min:      1 Act:   11 Avg:    6 Max:      33
T: 1 (163351) I:1500 C:  24146 Min:      1 Act:    4 Avg:    3 Max:      13
T: 2 (163352) I:2000 C:  18110 Min:      2 Act:    7 Avg:    5 Max:      18
T: 3 (163353) I:2500 C:  14488 Min:      1 Act:    2 Avg:    1 Max:      16
# Break thread: 163350
# Break value: 51
````

测试结果解析

````
$ cyclicdeadline -q -i 1000 -s 500 -t 4 -D 1m --verbose
Using all CPUS
INFO: interval: 600:1000
INFO:   Tested at 13us of 600us
INFO: interval: 900:1500
INFO:   Tested at 5us of 900us
INFO: interval: 1200:2000
INFO:   Tested at 4us of 1200us
INFO: interval: 1500:2500
INFO:   Tested at 4us of 1500us
T: 0 (163306) I:1000 C:  60001 Min:      1 Act:    4 Avg:    2 Max:      33
T: 1 (163307) I:1500 C:  40001 Min:      1 Act:    5 Avg:    2 Max:      21
T: 2 (163308) I:2000 C:  30001 Min:      1 Act:    7 Avg:    6 Max:     162
T: 3 (163309) I:2500 C:  24001 Min:      3 Act:    3 Avg:    5 Max:      30
````

该命令创建了4个实时任务，即 4 个线程，这 4 个线程生成了不同的周期（Period）和运行时间（Runtime）：

| 线程 | 周期 (P)         | 运行时 (Q) | CPU占用率 (Q/P) | 含义                    |
| ---- | ---------------- | ---------- | --------------- | ----------------------- |
| T0   | 1000 μs (1 ms)   | 600 μs     | 60%             | 每1ms需要CPU运行0.6ms   |
| T1   | 1500 μs (1.5 ms) | 900 μs     | 60%             | 每1.5ms需要CPU运行0.9ms |
| T2   | 2000 μs (2 ms)   | 1200 μs    | 60%             | 每2ms需要CPU运行1.2ms   |
| T3   | 2500 μs (2.5 ms) | 1500 μs    | 60%             | 每2.5ms需要CPU运行1.5ms |

总CPU带宽需求: `60% * 4 = 240%`。这意味着至少需要 3个CPU核心 (`240% / 100% ≈ 3`) 才能满足调度条件。测试成功表明调度器正确地在多个CPU核心上进行了全局调度。

````
T: 0 (163306) I:1000 C:  60001 Min:      1 Act:    4 Avg:    2 Max:      33
T: 1 (163307) I:1500 C:  40001 Min:      1 Act:    5 Avg:    2 Max:      21
T: 2 (163308) I:2000 C:  30001 Min:      1 Act:    7 Avg:    6 Max:     162
T: 3 (163309) I:2500 C:  24001 Min:      3 Act:    3 Avg:    5 Max:      30
````

- `T`: 线程索引，T：0表示第0号线程
- `(163306)`: 操作系统级的线程PID
- `I`: 现成的周期 (Interval) - 单位微秒 (μs)，此线程每 **1000µs (1 ms)** 被激活一次。
- `C`: 已完成的周期数 (Cycles：循环次数) ，在 1 分钟的测试期内，T0 线程成功完成了 **60001** 个周期。
- `Min`: 最小延迟 (Minimum Latency) - 从任务就绪到开始执行的最短时间，T0 线程完成工作的最快时间只比预期晚了 **1µs**。
- `Act`: 当前延迟(Actual Latency) - 最后一次循环的延迟值，单位微秒 (μs)，T0 线程最后一次循环的延迟是 **4µs**
- `Avg`: 平均延迟(Average Latency)，单位 µs，T0 线程所有循环的平均延迟为 **2µs**
- `Max`: 最大延迟**(Maximum Latency)**，单位 µs - **最关键的指标**，最坏情况下，T0 线程完成工作晚了 **33µs**。

| 线程 | 周期 (μs) | 完成周期数 | 最大延迟 (μs) | 延迟占比      |
| ---- | --------- | ---------- | ------------- | ------------- |
| T0   | 1000      | 60001      | 33            | 33/1000=3.3%  |
| T1   | 1500      | 40001      | 21            | 21/1500=1.4%  |
| T2   | 2000      | 30001      | 162           | 162/2000=8.1% |
| T3   | 2500      | 24001      | 30            | 30/2500=1.2%  |

#### 2.3 pi_stress

##### 2.3.1 介绍

`pi_stress` 是 rt-tests 测试套件中专门用于测试和验证 Linux 内核的优先级继承（Priority Inheritance, PI）机制是否正确工作。这对于评估实时系统的稳定性和可靠性至关重要。

### pi_stress 是什么？

在多任务实时系统中，优先级反转（Priority Inversion） 是一个经典问题：当一个高优先级任务等待一个正被低优先级任务占有的资源（如锁），而该低优先级任务又被中等优先级任务抢占时，高优先级任务就无法执行。优先级继承（PI） 是一种解决此问题的机制：低优先级任务在持有高优先级任务所需的锁时，会临时继承高优先级，以防止被中等优先级任务抢占，从而尽快释放资源。

`pi_stress` 通过创建多个不同优先级任务（线程）并让它们竞争相同的锁，来主动制造优先级反转的场景，从而压力测试内核的 PI 机制是否能正确运作。如果内核的 PI 机制有缺陷，`pi_stress` 很可能会测试出来（表现为死锁、任务卡住或测试失败）。

执行 help 命令，查看 pi_stress 的参数

````
$ pi_stress -h
pi_stress V 2.80
Usage:
pi_stress <options>

-d       --debug           turn on debug prints
-D TIME  --duration=TIME   length of test run in seconds (default is infinite)
                           Append 'm', 'h', or 'd'
                           to specify minutes, hours or days.
-g N     --groups=N        set the number of inversion groups
-h       --help            print this message
-i INV   --inversions=INV  number of inversions per group (default is infinite)
         --json=FILENAME   write final results into FILENAME, JSON formatted
-m       --mlockall        lock current and future memory
-p       --prompt          prompt before starting the test
-q       --quiet           suppress running output
-r       --rr              use SCHED_RR for test threads [SCHED_FIFO]
-s OPTS  --sched OPTS      scheduling options per thread type:
   id=[high|med|low]      select thread
   ,policy=[fifo,rr]       scheduling class [SCHED_FIFO, SCHED_RR]
     ,priority=N           scheduling priority
   ,policy=[deadline]      scheduling class [DEADLINE]
     ,runtime=N
     ,deadline=N
     ,period=N
-u       --uniprocessor    force all threads to run on one processor
-v       --verbose         lots of output
-V       --version         print version number on output
````

参数说明

| 参数             | 缩写     | 说明                                                         | 示例                 |
| ---------------- | -------- | ------------------------------------------------------------ | -------------------- |
| `--debug`        | `-d`     | 开启调试打印                                                 | `-d`                 |
| `--duration`     | `-D`     | 测试运行时长（默认无限）                                     | `-D 5m` (5分钟)      |
| `--groups`       | `-g`     | 设置优先级反转组数量。增加组数会创建更多竞争资源的任务组，测试更复杂的场景。 | `-g 4` (4个组)       |
| `--help`         | `-h`     | 显示帮助信息                                                 | `-h`                 |
| `--inversions`   | `-i`     | 每组反转次数（默认无限）                                     | `-i 1000`            |
| `--json`         | `--json` | 将结果写入JSON文件                                           | `--json=result.json` |
| `--mlockall`     | `-m`     | 锁定当前和未来内存分配，防止内存被换出到交换分区，避免换页操作引入不可预测的延迟 | `-m`                 |
| `--prompt`       | `-p`     | 开始测试前提示                                               | `-p`                 |
| `--quiet`        | `-q`     | 安静模式，抑制运行输出                                       | `-q`                 |
| `--rr`           | `-r`     | 测试线程使用 SCHED_RR（轮转）实时调度策略（默认 SCHED_FIFO 先进先出） | `-r`                 |
| `--sched`        | `-s`     | 为不同类型的线程设置精细的调度参数，这是一个高级功能         |                      |
| `--uniprocessor` | `-u`     | 强制所有线程在单单个 CPU 核心上运行。这有助于测试在单核环境下的竞争情况，或者排除多核并行带来的干扰。 | `-u`                 |
| `--verbose`      | `-v`     | 详细输出                                                     | `-v`                 |
| `--version`      | `-V`     | 打印版本号                                                   | `-V`                 |

重点参数解析

1）`-s/--sched`（核心参数）

这是最强大的参数，允许精细控制每个类型线程的调度策略：

基本语法：`-s id=<类型>,policy=<策略>,priority=<优先级>,...`

示例

````
# 设置高优先级线程为 SCHED_FIFO，优先级99
$ pi_stress -s id=high,policy=fifo,priority=99

# 设置中优先级线程为 SCHED_RR，优先级80
$ pi_stress -s id=med,policy=rr,priority=80

# 为低优先级线程设置 DEADLINE 策略
$ pi_stress -s id=low,policy=deadline,runtime=10000,deadline=20000,period=30000
````

2）`-g/--groups` 和 `-i/--inversions`

- `-g N`：创建 N 组独立的测试线程（每组包含高、中、低优先级线程）
- `-i N`：每组完成 N 次优先级反转测试后退出

3）`-D/--duration`

控制测试运行时间，支持单位：

- `s`：秒（默认）
- `m`：分钟
- `h`：小时
- `d`：天

##### 2.3.2 执行测试

使用示例：

基础测试（制造优先级反转）：运行5分钟，创建2组线程，锁定内存

````
$ pi_stress -D 5m -g 2 -m
Starting PI Stress Test
Number of thread groups: 2
Duration of test run: 300 seconds
Number of inversions per group: unlimited
     Admin thread SCHED_FIFO priority 4
2 groups of 3 threads will be created
      High thread SCHED_FIFO priority 3
       Med thread SCHED_FIFO priority 2
       Low thread SCHED_FIFO priority 1
Current Inversions: 8914954
Stopping test
Total inversion performed: 8914958
Test Duration: 0 days, 0 hours, 5 minutes, 1 seconds
````

指定反转次数：每组完成10000次反转测试后自动退出

````
$ pi_stress -i 10000 -g 4 -q --json=./pi_test.json
Total inversion performed: 39778
Test Duration: 0 days, 0 hours, 0 minutes, 1 seconds
````

精细控制调度策略：测试DEADLINE策略与FIFO策略的交互

````
$ pi_stress -g 1 \
  -s id=high,policy=fifo,priority=99 \
  -s id=med,policy=deadline,runtime=5000,deadline=10000,period=15000 \
  -s id=low,policy=fifo,priority=50
````

单核压力测试：强制所有线程在单个CPU核心上运行，制造更激烈的竞争

````
$ pi_stress -g 3 -u -D 5m -v
INFO: admin and test threads running on one processor
INFO: Creating 3 test groups
Starting PI Stress Test
Number of thread groups: 3
Duration of test run: 300 seconds
Number of inversions per group: unlimited
     Admin thread SCHED_FIFO priority 4
3 groups of 3 threads will be created
      High thread SCHED_FIFO priority 3
       Med thread SCHED_FIFO priority 2
       Low thread SCHED_FIFO priority 1

INFO: Releasing all threads
INFO: Press Control-C to stop test
Current Inversions: 13270553
INFO: duration reached (300 seconds)
INFO: setting shutdown flag
Stopping test
INFO: waiting for all threads to complete
INFO: All threads terminated!
Total inversion performed: 13270561
Test Duration: 0 days, 0 hours, 5 minutes, 1 seconds
````

测试结果解读

````
$ pi_stress --duration 1m 
Starting PI Stress Test
Number of thread groups: 63                         # 线程组数63组
Duration of test run: 60 seconds                    # 预设测试时长1分钟
Number of inversions per group: unlimited           # 每个线程组会无限次地进行优先级反转测试，直到时间结束
     Admin thread SCHED_FIFO priority 4             # 管理线程以实时最高优先级（4）运行，确保它能可靠地监控所有测试线程
63 groups of 3 threads will be created              # 63组，每组3个线程
      High thread SCHED_FIFO priority 3             # 每组中的3个线程优先级：高(3)、中(2)、低(1)。这是制造优先级反转的关键
       Med thread SCHED_FIFO priority 2
       Low thread SCHED_FIFO priority 1
Current Inversions: 3596604                         # 测试过程中实时统计到的优先级反转事件发生次数
Stopping test                                       # 60秒时间到，正常停止测试
Total inversion performed: 3596718                  # 总共发生了约359万次优先级反转。这证明测试强度很高，成功制造了激烈的锁竞争场景
Test Duration: 0 days, 0 hours, 1 minutes, 1 seconds   # 实际测试耗时1分1秒，与预设的1分钟基本吻合。
````

pi_stress测试成败判断：

| 结果状态          | 含义         | 解读                                                         |
| ----------------- | ------------ | ------------------------------------------------------------ |
| 测试正常完成      | 通过（PASS） | 程序运行了指定的时间（如 -D 1m）后，自行退出并显示摘要信息（如 Stopping test, Total inversion performed）。这表明在整个测试过程中，内核的优先级继承机制都成功防止了死锁。 |
| 测试中途停止/卡死 | 失败（FAIL） | 测试过程中系统卡死（hang）、触发内核错误（Oops）、内核恐慌（Panic）或在控制台输出 `ERROR` 信息。这表明内核在处理优先级继承时出现了缺陷，导致了无法恢复的死锁。这是最需要关注的“指标”。 |

#### 2.4 pmqtest

pmqtest 是一个用于测试 POSIX 消息队列（Message Queue） 在实时系统（尤其是 PREEMPT_RT 补丁的 Linux 系统）中性能表现的工具，它主要衡量消息传递的延迟时间。

pmqtest 的核心目标是测试消息从一个线程发送到另一个线程并接收回复所需的延迟时间。它关注的是实时系统的响应能力，尤其是在高负载或压力情况下，消息传递的最大延迟（worst-case latency）是否在可接受范围内。

执行 help 命令，查看 pmqtest 的参数

````
$ pmqtest --help
pmqtest V 2.80
Usage:
pmqtest <options>

Function: test POSIX message queue latency

Available options:

-a [NUM] --affinity        run thread #N on processor #N, if possible
                           with NUM pin all threads to the processor NUM
-b USEC  --breaktrace=USEC send break trace command when latency > USEC
-d DIST  --distance=DIST   distance of thread intervals in us default=500
-D TIME  --duration=TIME   specify a length for the test run.
                           Append 'm', 'h', or 'd' to specify
                           minutes, hours or days.
-f TO    --forcetimeout=TO force timeout of mq_timedreceive(), requires -T
-h       --help            print this help message
-i INTV  --interval=INTV   base interval of thread in us default=1000
         --json=FILENAME   write final results into FILENAME, JSON formatted
-l LOOPS --loops=LOOPS     number of loops: default=0(endless)
-p PRIO  --prio=PRIO       priority
-q       --quiet           print a summary only on exit
-S       --smp             SMP testing: options -a -t and same priority
                           of all threads
-t       --threads         one thread per available processor
-t [NUM] --threads=NUM     number of threads:
                           without NUM, threads = max_cpus
                           without -t default = 1
-T TO    --timeout=TO      use mq_timedreceive() instead of mq_receive()
                           with timeout TO in seconds
````

参数说明

| 参数                | 缩写       | 说明                                                         |
| ------------------- | ---------- | ------------------------------------------------------------ |
| `--affinity [NUM]`  | `-a [NUM]` | 设置 CPU 亲和性。若不指定 `NUM`，则尝试让每个线程在其对应的 CPU 核上运行。若指定 `NUM`，则所有线程都绑定到指定的 CPU 核 `NUM` 上。 |
| `--breaktrace USEC` | `-b USEC`  | 设置延迟阈值。当某次测量的延迟超过 `USEC` 微秒时，会触发断点追踪（break trace），方便调试。 |
| `--distance DIST`   | `-d DIST`  | 设置线程间的时间间隔（单位：微秒）。默认值为 500 us。        |
| `--duration TIME`   | `-D TIME`  | 指定测试运行的总时间。可以在时间后加后缀 `m`（分钟）、`h`（小时）或 `d`（天）。 |
| `--forcetimeout TO` | `-f TO`    | 强制 `mq_timedreceive()` 超时，需要与 `-T`/`--timeout` 参数一起使用。 |
| `--help`            | `-h`       | 显示帮助信息。                                               |
| `--interval INTV`   | `-i INTV`  | 设置线程的基本间隔时间（单位：微秒）。默认值为 1000 us。     |
| `--json FILENAME`   |            | 将最终结果以 JSON 格式写入指定的文件。                       |
| `--loops LOOPS`     | `-l LOOPS` | 设置测试循环的次数。默认值为 0，表示无限循环。               |
| `--prio PRIO`       | `-p PRIO`  | 设置测试线程的实时优先级。数值越高，优先级越高。             |
| `--quiet`           | `-q`       | 安静模式。仅在退出时打印摘要信息。                           |
| `--smp`             | `-S`       | 进行 SMP（对称多处理）测试。与 `-a` 和 `-t` 选项一起使用，并让所有线程具有相同优先级。 |
| `--threads [NUM]`   | `-t [NUM]` | 设置测试线程的数量。若不指定 `NUM`，则线程数等于系统最大 CPU 核数。若不使用此选项，默认线程数为 1。 |
| `--timeout TO`      | `-T TO`    | 使用 `mq_timedreceive()` 代替 `mq_receive()`，并设置超时时间 `TO`（单位：秒）。 |

基础延迟测试：运行 100,000 次循环，线程优先级设为 80，间隔时间为 1000 微秒：

````
$ pmqtest -p 80 -i 1000 -l 100000
#0: ID60996, P80, CPU3, I1000; #1: ID60997, P80, CPU7, TO 0, Cycles 99996
#1 -> #0, Min   98, Cur  193, Avg  183, Max 1676
````

绑定到特定 CPU 核心并设置延迟阈值：将测试绑定到 CPU 核心 1，并在延迟超过 40 微秒时停止测试并触发断点追踪

````
$ pmqtest -p 99 -i 1000 -l 300000 -b 40 -a1
````

多线程测试：创建 4 对发送/接收线程进行测试

````
$ pmqtest -p 80 -t 4 -l 1000000
#0: ID61012, P80, CPU2, I1000; #1: ID61013, P80, CPU3, TO 0, Cycles 999998
#2: ID61014, P79, CPU4, I1500; #3: ID61015, P79, CPU7, TO 0, Cycles 999947
#4: ID61016, P78, CPU5, I2000; #5: ID61017, P78, CPU6, TO 0, Cycles 999823
#6: ID61018, P77, CPU0, I2500; #7: ID61019, P77, CPU1, TO 0, Cycles 999726
#1 -> #0, Min   49, Cur  124, Avg  240, Max 6578
#3 -> #2, Min   50, Cur  215, Avg  243, Max 5903
#5 -> #4, Min   52, Cur  204, Avg  242, Max 6090
#7 -> #6, Min   48, Cur  276, Avg  243, Max 6330
````

指定测试持续时间：运行测试持续 5 分钟

````
$ pmqtest -p 80 -D 5m
#0: ID61267, P80, CPU7, I1000; #1: ID61268, P80, CPU6, TO 0, Cycles 74925
#1 -> #0, Min   98, Cur  194, Avg  180, Max 1517
````

输出 JSON 报告：将测试结果输出到 JSON 文件

````
$ pmqtest -p 80 -l 100000 --json=result.json
#0: ID61272, P80, CPU5, I1000; #1: ID61273, P80, CPU4, TO 0, Cycles 99991
#1 -> #0, Min   93, Cur  172, Avg  169, Max  636
````

测试结果解读

````
$ pmqtest -q -S -p 98 -D 5m --json=./aa/result.json 
#0: ID62776, P98, CPU0, I1000; #1: ID62777, P98, CPU0, TO 0, Cycles 74953
#2: ID62778, P98, CPU1, I1500; #3: ID62779, P98, CPU1, TO 0, Cycles 74904
#4: ID62780, P98, CPU2, I2000; #5: ID62781, P98, CPU2, TO 0, Cycles 74857
#6: ID62782, P98, CPU3, I2500; #7: ID62783, P98, CPU3, TO 0, Cycles 74803
#8: ID62784, P98, CPU4, I3000; #9: ID62785, P98, CPU4, TO 0, Cycles 74757
#10: ID62786, P98, CPU5, I3500; #11: ID62787, P98, CPU5, TO 0, Cycles 69488
#12: ID62788, P98, CPU6, I4000; #13: ID62789, P98, CPU6, TO 0, Cycles 37349
#14: ID62790, P98, CPU7, I4500; #15: ID62791, P98, CPU7, TO 0, Cycles 37310
#1 -> #0, Min   35, Cur   84, Avg   83, Max  749
#3 -> #2, Min   33, Cur  126, Avg   75, Max  730
#5 -> #4, Min   34, Cur   49, Avg   81, Max  740
#7 -> #6, Min   32, Cur  131, Avg   77, Max  734
#9 -> #8, Min   33, Cur  132, Avg   77, Max  724
#11 -> #10, Min   33, Cur  122, Avg   80, Max  728
#13 -> #12, Min   34, Cur   80, Avg   82, Max  472
#15 -> #14, Min   34, Cur  143, Avg   85, Max  409
````

测试线程启动信息解读

````
#0: ID62776, P98, CPU0, I1000; #1: ID62777, P98, CPU0, TO 0, Cycles 74953
#2: ID62778, P98, CPU1, I1500; #3: ID62779, P98, CPU1, TO 0, Cycles 74904
#4: ID62780, P98, CPU2, I2000; #5: ID62781, P98, CPU2, TO 0, Cycles 74857
#6: ID62782, P98, CPU3, I2500; #7: ID62783, P98, CPU3, TO 0, Cycles 74803
#8: ID62784, P98, CPU4, I3000; #9: ID62785, P98, CPU4, TO 0, Cycles 74757
#10: ID62786, P98, CPU5, I3500; #11: ID62787, P98, CPU5, TO 0, Cycles 69488
#12: ID62788, P98, CPU6, I4000; #13: ID62789, P98, CPU6, TO 0, Cycles 37349
#14: ID62790, P98, CPU7, I4500; #15: ID62791, P98, CPU7, TO 0, Cycles 37310
````

测试创建了 8 对（16个）生产者/消费者线程，每个 CPU 核心（CPU0 到 CPU7）上绑定了一对。

格式：`#序号: 线程ID, 优先级, 绑定的CPU, 其他信息`

- `#0: ID62776, P98, CPU0, I1000;`
  - 这是一个生产者线程（偶数序号）。
  - 线程 ID 为 62776。
  - 优先级为 98。
  - 绑定到 CPU0。
  - `I1000` 表示消息间隔（Inter-message period）为 1000 纳秒（1微秒）。这是生产者尝试发送消息的周期。
- `#1: ID62777, P98, CPU0, TO 0, Cycles 74953`
  - 这是一个消费者线程（奇数序号），它与 #0 成对工作。
  - 线程 ID 为 62777。
  - 优先级为 98。
  - 绑定到 CPU0。
  - `TO 0`： 超时（Timeout）计数为 0，表示在 5 分钟的测试中没有发生超时（消息丢失或严重延迟），这是一个好迹象。
  - `Cycles 74953`： 消费者线程总共循环执行了 74953 次消息接收操作。这个数字与测试时长（5分钟）和消息间隔（I1000）大致相符，验证了测试基本按预期运行。

后续行（#2 到 #15）是其他 CPU 核心上的线程对，格式相同。注意，每个生产者线程的消息间隔（`I1500`, `I2000` ... `I4500`）逐渐增加（1500ns, 2000ns ... 4500ns）。

延迟结果解读

````
#1 -> #0, Min   35, Cur   84, Avg   83, Max  749
#3 -> #2, Min   33, Cur  126, Avg   75, Max  730
#5 -> #4, Min   34, Cur   49, Avg   81, Max  740
#7 -> #6, Min   32, Cur  131, Avg   77, Max  734
#9 -> #8, Min   33, Cur  132, Avg   77, Max  724
#11 -> #10, Min   33, Cur  122, Avg   80, Max  728
#13 -> #12, Min   34, Cur   80, Avg   82, Max  472
#15 -> #14, Min   34, Cur  143, Avg   85, Max  409
````

这部分显示了每对生产者-消费者线程之间的消息传递延迟统计。单位是纳秒（ns）。

格式：`#消费者 -> #生产者, Min 最小延迟, Cur 当前延迟, Avg 平均延迟, Max 最大延迟`

- `#1 -> #0, Min 35, Cur 84, Avg 83, Max 749`
  - 这对在 CPU0 上通信的线程：
    - Min（最小延迟）: 35 ns。这是最好的情况，代表了进程间通信和调度所需的基本开销。
    - Cur（当前延迟）: 84 ns。工具结束前测量的最后一个延迟值。
    - Avg（平均延迟）: 83 ns。整个测试期间的平均延迟。这个值非常低且稳定，表明系统实时性能很好。
    - Max（最大延迟）: 749 ns。这是最坏情况下的延迟。虽然只有 0.749 微秒，但它是衡量系统“实时性”的关键指标（越小越好）。这个值可能由缓存未命中、中断处理等微小干扰引起。
- `#3 -> #2, Min 33, Cur 126, Avg 75, Max 730`
  - CPU1 上的线程对，延迟特性与 CPU0 非常相似，表现良好。
- `#13 -> #12, Min 34, Cur 80, Avg 82, Max 472`
- `#15 -> #14, Min 34, Cur 143, Avg 85, Max 409`
  - 这是 CPU6 和 CPU7上的线程对。 

#### 2.5 hackbench

Hackbench 是一个内核调度程序的基准测试和压力测试工具，旨在测量进程间通信（IPC）、线程切换、系统调度等相关的时延性能。它通过模拟多进程或多线程环境，执行一系列的数据交换和任务调度操作，从而评估操作系统在处理大量并发任务时的效率。

原理是创建大量 sender 和 receiver 任务，通过 socket 或 pipe 进行数据传输，记录完成全部通信所需时间。总耗时（秒数）越短 表示调度性能越好

核心指标：时间越短，性能越优

执行 help 命令，查看 hackbench 的参数

````
$ hackbench --help
hackbench V 2.80
Usage:
hackbench <options>

-f       --fds=NUM         number of fds
-F       --fifo            use SCHED_FIFO for main thread
-g       --groups=NUM      number of groups to be used
-h       --help            print this message
-l       --loops=LOOPS     how many message should be send
-p       --pipe            send data via a pipe
-i       --inet            send data via a inet tcp connection
-s       --datasize=SIZE   message size
-T       --threads         use POSIX threads
-P       --process         use fork (default)
````

参数说明

| 参数 | 长参数          | 功能说明                                                     |
| ---- | --------------- | ------------------------------------------------------------ |
| -f   | --fds=NUM       | 每个组（子进程）使用的文件描述符（file descriptors）数量     |
| -F   | --fifo          | 主线程使用 SCHED_FIFO 调度策略                               |
| -g   | --groups=NUM    | 创建通信组的数量（启动多少组发送者和接受者）                 |
| -h   | --help          | 显示此帮助信息                                               |
| -l   | --loops=LOOPS   | 每个发送者/接受者对应该发送的消息数量                        |
| -p   | --pipe          | 通过管道（pipe）发送数据（默认使用套接字socket）             |
| -i   | --inet          | 通过TCP 连接发送数据                                         |
| -s   | --datasize=SIZE | 消息大小（字节数）                                           |
| -T   | --threads       | 使用 POSIX 线程模式，即每个 sender/receiver 是一个线程（共享地址空间），而非独立进程 |
| -P   | --process       | 使用 fork 创建进程（默认行为），发送/接收者都是进程，使用进程模式 |

使用线程模式，创建10个组，每个发送者发送10条消息：

````
$ hackbench -T -g 10 -l 10
Running in threaded mode with 10 groups using 40 file descriptors each (== 400 tasks)
Each sender will pass 10 messages of 100 bytes
Time: 1.215
````

总耗时 1.215 秒

标准多线程+pipe测试:

创建 10 个通信组，每个 sender 发送 100 次消息，每条消息的大小为100字节，每个组使用20个 file descriptors

````
$ hackbench -s 100 -l 100 -g 10 -f 20 -p -T
Running in threaded mode with 10 groups using 40 file descriptors each (== 400 tasks)
Each sender will pass 100 messages of 100 bytes
Time: 1.627
````

总耗时 1.627 秒

总耗时越短，表示当前系统的线程调度、上下文切换和 socket 或者 pipe 通信效率越高，性能越好。

#### 2.6 ptsematest

ptsematest 主要用于评估 Linux 实时系统的性能，特别是测量使用 POSIX 互斥锁（Mutex）进行进程间通信的时延。这对于评估和确保实时系统在任务同步方面的表现至关重要。

ptsematest 的核心任务是测量两个线程在使用 POSIX 互斥锁进行进程间通信时的时延

基本工作原理：ptsematest 通常会启动两个线程，这两个线程通过 POSIX 互斥锁来同步。测试会精确测量线程在获取和释放锁的过程中所产生的通信时延。这种时延是评估实时系统性能的一个关键指标。

执行 help 命令，查看 ptsematest 的参数

````
$ ptsematest --help
ptsematest V 2.80
Usage:
ptsematest <options>

Function: test POSIX threads mutex latency

Available options:
-a [NUM] --affinity        run thread #N on processor #N, if possible
                           with NUM pin all threads to the processor NUM
-b USEC  --breaktrace=USEC send break trace command when latency > USEC
-d DIST  --distance=DIST   distance of thread intervals in us default=500
-D       --duration=TIME   specify a length for the test run.
                           Append 'm', 'h', or 'd' to specify minutes, hours or
                           days.
-i INTV  --interval=INTV   base interval of thread in us default=1000
         --json=FILENAME   write final results into FILENAME, JSON formatted
-l LOOPS --loops=LOOPS     number of loops: default=0(endless)
-p PRIO  --prio=PRIO       priority
-q       --quiet           print a summary only on exit
-S       --smp             SMP testing: options -a -t and same priority
                           of all threads
-t       --threads         one thread per available processor
-t [NUM] --threads=NUM     number of threads:
                           without NUM, threads = max_cpus
                           without -t default = 1
````

参数说明

| 参数              | 简写     | 功能说明                                                     |
| ----------------- | -------- | ------------------------------------------------------------ |
| --affinity [NUM]  | -a [NUM] | 线程CPU绑定：无NUM时每个线程绑定到对应CPU；有NUM时所有线程绑定到指定CPU |
| --breaktrace=USEC | -b USEC  | 当延迟超过USEC微秒时触发断点追踪                             |
| --distance=DIST   | -d DIST  | 线程间隔距离（微秒），默认500                                |
| --duration=TIME   | -D TIME  | 测试持续时间，支持m/h/d单位                                  |
| --interval=INTV   | -i INTV  | 线程基础间隔时间（微秒），默认1000                           |
| --json=FILENAME   | 无       | 以JSON格式输出测试结果到文件                                 |
| --loops=LOOPS     | -l LOOPS | 循环次数，0表示无限循环（默认）                              |
| --prio=PRIO       | -p PRIO  | 设置线程优先级                                               |
| --quiet           | -q       | 仅在退出时显示摘要信息                                       |
| --smp             | -S       | SMP测试模式，需与-a和-t配合使用                              |
| --threads [NUM]   | -t [NUM] | 线程数量：无NUM时为CPU数，无-t默认1线程                      |

测试4个线程，持续5分钟，绑定到各自CPU

````
$ ptsematest -t 4 -a -D 5m --json=result.json
#0: ID34479, P0, CPU0, I1000; #1: ID34480, P0, CPU0, Cycles 74885
#2: ID34481, P0, CPU1, I1500; #3: ID34482, P0, CPU1, Cycles 74783
#4: ID34483, P0, CPU2, I2000; #5: ID34484, P0, CPU2, Cycles 74683
#6: ID34485, P0, CPU3, I2500; #7: ID34486, P0, CPU3, Cycles 74573
#1 -> #0, Min   28, Cur  164, Avg   43, Max 2269
#3 -> #2, Min   29, Cur  223, Avg   45, Max  454
#5 -> #4, Min   29, Cur   36, Avg   45, Max 2308
#7 -> #6, Min   29, Cur   42, Avg   45, Max 4263
````

测试结果解析：

线程配置信息

````
#0: ID34479, P0, CPU0, I1000; #1: ID34480, P0, CPU0, Cycles 74885
#2: ID34481, P0, CPU1, I1500; #3: ID34482, P0, CPU1, Cycles 74783
#4: ID34483, P0, CPU2, I2000; #5: ID34484, P0, CPU2, Cycles 74683
#6: ID34485, P0, CPU3, I2500; #7: ID34486, P0, CPU3, Cycles 74573
````

#编号：线程编号

IDxxxxx：线程ID

P0：优先级为0

CPUx：运行的CPU核心

Ixxx：间隔时间（微秒）

Cycles xxx：完成的循环次数

#1 -> #0, Min   28, Cur  164, Avg   43, Max 2269

延迟统计结果

````
#1 -> #0, Min   28, Cur  164, Avg   43, Max 2269
#3 -> #2, Min   29, Cur  223, Avg   45, Max  454
#5 -> #4, Min   29, Cur   36, Avg   45, Max 2308
#7 -> #6, Min   29, Cur   42, Avg   45, Max 4263
````

\#发送方 -> #接收方：线程对通信方向

Min：最小延迟（微秒）

Cur：当前延迟（微秒）

Avg：平均延迟（微秒）

Max：最大延迟（微秒）

测试结果文件 result.json 内容

````
{
  "file_version": 1,
  "cmdline:": "ptsematest -t 4 -a -D 5m --json=result.json",
  "rt_test_version:": "2.80",
  "start_time": "Wed, 29 Oct 2025 18:32:11 +0000",
  "end_time": "Wed, 29 Oct 2025 18:37:11 +0000",
  "return_code": 0,
  "sysinfo": {
    "sysname": "Linux",
    "nodename": "localhost.localdomain",
    "release": "6.6.0-98.0.0.103.oe2403sp2.riscv64",
    "version": "#1 SMP PREEMPT Fri Jun 27 10:45:15 UTC 2025",
    "machine": "riscv64",
    "realtime": 0
  },
  "num_threads": 4,
  "thread": {
    "0": {
      "sender": {
        "cpu": 0,
        "priority": 0,
        "samples": 74895,
        "interval": 1000
      },
      "receiver": {
        "cpu": 0,
        "priority": 0,
        "min": 28,
        "avg": 43.36,
        "max": 2269
      }
    },
    "1": {
      "sender": {
        "cpu": 1,
        "priority": 0,
        "samples": 74793,
        "interval": 1500
      },
      "receiver": {
        "cpu": 1,
        "priority": 0,
        "min": 29,
        "avg": 45.27,
        "max": 454
      }
    },
    "2": {
      "sender": {
        "cpu": 2,
        "priority": 0,
        "samples": 74693,
        "interval": 2000
      },
      "receiver": {
        "cpu": 2,
        "priority": 0,
        "min": 29,
        "avg": 45.29,
        "max": 2308
      }
    },
    "3": {
      "sender": {
        "cpu": 3,
        "priority": 0,
        "samples": 74583,
        "interval": 2500
      },
      "receiver": {
        "cpu": 3,
        "priority": 0,
        "min": 29,
        "avg": 44.63,
        "max": 4263
      }
    }
  }
}
````

#### 2.7  rt-migrate-test

rt-migrate-test 是专门用于测试 Linux 实时系统的任务迁移（task migration）性能。主要测试内容如下：

- **迁移延迟**：将任务从一个 CPU 迁移到另一个 CPU 所需的时间。对于实时系统，这个时间必须是确定且有上限的。
- **负载均衡有效性**：内核能否及时将任务从繁忙的 CPU 迁移到空闲的 CPU。
- **实时性保障**：在迁移过程中，高优先级实时任务的执行是否被破坏，是否出现由于迁移导致的额外调度延迟。
- **内核代码路径稳定性**：频繁迁移是对内核调度和迁移代码路径的压力测试，有助于发现锁竞争、死锁或竞态条件等问题。

执行 help 命令，查看 rt-migrate-test 的参数

````
$ rt-migrate-test --help
rt-migrate-test 2.80
Usage:
rt-migrate-test <options> [NR_TASKS]

-c       --check           Stop if lower prio task is quicker than higher (off)
-D TIME  --duration=TIME   Specify a length for the test run.
                           Append 'm', 'h', or 'd' to specify minutes, hours or
                           days.
-e       --equal           Use equal prio for #CPU-1 tasks (requires > 2 CPUS)
-h       --help            Print this help message
         --json=FILENAME   write final results into FILENAME, JSON formatted
-l LOOPS --loops=LOOPS     Number of iterations to run (50)
-m TIME  --maxerr=TIME     Max allowed error (microsecs)
-p PRIO  --prio=PRIO       base priority to start RT tasks with (2)
-q       --quiet           print a summary only on exit
-r TIME  --run-time=TIME   Run time (ms) to busy loop the threads (20)
-s TIME  --sleep-time=TIME Sleep time (ms) between intervals (100)

  () above are defaults 
````

基本用法：

rt-migrate-test [选项] [NR_TASKS]

NR_TASKS: 任务数量（可选）

选项说明：

| 选项     | 长选项            | 说明                                                         |
| -------- | ----------------- | ------------------------------------------------------------ |
| -c       | --check           | 如果低优先级任务比高优先级任务快，则停止（默认关闭）         |
| -D TIME  | --duration=TIME   | 指定测试运行的时长。可以加上'm'、'h'或'd'分别表示分钟、小时或天 |
| -e       | --equal           | 对于#CPU-1个任务使用相同的优先级（要求CPU数量大于2）         |
| -h       | --help            | 打印帮助信息                                                 |
|          | --json=FILENAME   | 将最终结果写入JSON格式的文件                                 |
| -l LOOPS | --loops=LOOPS     | 循环运行的次数（默认50）                                     |
| -m TIME  | --maxerr=TIME     | 允许的最大错误（微秒）                                       |
| -p PRIO  | --prio=PRIO       | 实时任务的基本优先级（默认2）                                |
| -q       | --quiet           | 仅在退出时打印摘要                                           |
| -r TIME  | --run-time=TIME   | 线程忙碌循环的运行时间（毫秒）（默认20）                     |
| -s TIME  | --sleep-time=TIME | 间隔之间的睡眠时间（毫秒）（默认100）                        |

基础测试

````
$ rt-migrate-test           # 使用所有默认参数
$ rt-migrate-test -l 10     # 测试10次迭代
$ rt-migrate-test -D 2m     # 运行测试2分钟
````

调整任务参数

````
$ rt-migrate-test -p 80              # 使用更高优先级的实时任务（优先级80）
$ rt-migrate-test 5                  # 创建5个任务进行测试
$ rt-migrate-test -r 50 -s 200       # 调整工作负载：繁忙50ms，休眠200ms
````

高级测试场景

````
$ rt-migrate-test -c                           # 启用检查模式，确保调度正确性
$ rt-migrate-test -e                           # 使用相同优先级测试（需要多于2个CPU）
$ rt-migrate-test --json=results.json -D 1m    # 运行测试并将结果保存为JSON
````

组合使用

````
$ rt-migrate-test -p 90 -l 100 -c 3          # 创建3个优先级为90的任务，运行100次迭代，启用检查模式
$ rt-migrate-test -D 2m -r 40 -s 150 -q      # 运行2分钟，繁忙40ms，休眠150ms，安静输出
````

测试结果

````
$ rt-migrate-test
|--------------------------------------------------------------------  |
Iter:      0       1       2       3       4       5       6       7       8  
   0:    20963    1447    1263    1195    1254    1246    1111    1289     488  
 len:    40964   21448   21264   21196   21255   21246   21112   21289   20488  
 loops:  25020   17819   25360   25492   25733   25578   24880   25805   23941  

   1:    21009    1064     879    1003     936     636    1181     691    1182  
 len:    41009   21065   20880   21003   20936   20636   21182   20692   21183  
 loops:  26402   16647   26397   26390   26598   26077   24975   26165   25163  

   2:    20751    1133     725     751     616    1139     446    1006     627  
 len:    40752   21135   20725   20752   20617   21139   20447   21007   20628  
 loops:  23764   17099   27222   25831   25961   25398   25014   26574   25600  

   3:    20811     758     657     827     967     694     934     472     828  
 len:    40812   20759   20658   20827   20968   20695   20935   20472   20829  
 loops:  27382   16808   26522   26476   26030   25393   25043   26847   25175  

   4:      748    1099     817    1028     869     769     614     708     381  
 len:    20801   21100   20817   21029   20870   20770   20615   20709   20382  
 loops:    144   16185   26163   26029   25317   25613   25336   27032   26703  

   5:    21093     856    1125    1053     790    1023     802     697     795  
 len:    41094   20857   21125   21053   20790   21024   20803   20697   20796  
 loops:  27101   17066   24965   26367   25049   25981   25311   27143   25969  

   6:    21233    1382     816    1300     799     801     729    1138    1031  
 len:    41234   21383   20816   21300   20800   20802   20730   21139   21031  
 loops:  25597   16761   26581   26128   25462   25354   24298   26786   26807  

   7:    20983    1491    1383     748     748    1350     595    1141    1211  
 len:    40984   21492   21384   20749   20749   21351   20596   21141   21212  
 loops:  26530   17649   26236   26002   25995   25323   25759   25730   27048  

   8:    20934     903     894    1217    1110    1071    1121     785     640  
 len:    40935   20904   20895   21218   21111   21072   21121   20785   20641  
 loops:  26350   17746   27243   26051   26557   24706   25705   26037   25661  

   9:    21200     979     887    1093    1009     813     757     801     789  
 len:    41201   20980   20888   21094   21010   20814   20757   20801   20790  
 loops:  26591   17943   27306   25921   26332   26365   26131   26698   25310  

  10:    21165    1268    1157    1198    1084     773     972     854     799  
 len:    41165   21269   21157   21198   21084   20774   20973   20855   20800  
 loops:  26988   17051   27027   25290   26286   26010   26009   26447   26799  

  11:    21211     851    1044    1157     809    1042     920     710     715  
 len:    41211   20852   21054   21158   20810   21043   20920   20711   20715  
 loops:  26002   16735   24733   25957   25689   24990   26507   25970   25416  

  12:     1150    1077    1620     848     837    1601    1562     895     720  
 len:    21150   21078   21620   20848   20838   21602   21562   20895   20721  
 loops:    729   17235   26149   26614   25860   26041   26050   26511   26627  

  13:    20885     986     922     975     882     822     800     497     886  
 len:    40885   20987   20923   20976   20883   20822   20800   20498   20887  
 loops:  26555   16638   26034   25658   26010   25932   25864   26314   26176  

  14:    20772     965     883    1254    1189     706     898     453     847  
 len:    40772   20967   20884   21255   21189   20706   20899   20453   20848  
 loops:  26552   16907   26099   26361   25788   26786   25356   25676   25781  

  15:    20936     910     752     911     981     735     910     574     960  
 len:    40937   20911   20753   20912   20982   20736   20911   20574   20961  
 loops:  26857   17237   26461   25904   26562   26277   26149   26099   26526  

  16:    21032    1153     834     872     901     920    1065     939     587  
 len:    41032   21154   20835   20873   20902   20920   21066   20940   20588  
 loops:  26377   17398   26045   26083   25493   26308   25317   26129   25813  

  17:    21168    1077    1195     948    1087     740     780    1067     732  
 len:    41169   21078   21196   20948   21088   20741   20781   21067   20733  
 loops:  27500   16835   26405   26478   26220   26640   25955   26252   25832  

  18:    21397    1221    1417     950     934    1066    1447    1117    1399  
 len:    41398   21222   21418   20951   20935   21067   21448   21118   21400  
 loops:  27633   17302   26500   26312   27033   26760   26303   26311   26286  

  19:    21032     619     742    1271     638    1114     635    1245     945  
 len:    41032   20620   20742   21272   20639   21115   20636   21246   20946  
 loops:  26392   17195   25563   26900   26875   25645   26060   25785   26001  

  20:    21085    1670    1276    1477    1164    1039     915    1325     743  
 len:    41086   21671   21277   21478   21165   21040   20916   21326   20743  
 loops:  27153   17417   26470   25846   26518   26466   26222   25810   26677  

  21:    21361     947    1094     923     949     897     885    1068     860  
 len:    41362   20948   21260   20924   20950   20898   20886   21069   20861  
 loops:  25876   17358   27051   26353   26279   26540   25990   25984   26398  

  22:    21077    1329     756     749    1248     634    1060     794     642  
 len:    41078   21330   20757   20750   21249   20635   21061   20795   20643  
 loops:  26068   17017   27653   26423   25988   26273   26421   26046   26602  

  23:    20923    1101     794     633     669    1006     707    1085     609  
 len:    40924   21102   20795   20634   20670   21007   20708   21086   20609  
 loops:  25949   16859   26696   26386   27262   26847   26062   26463   26052  

  24:    20674    1041     643     926     884     745     986     575     371  
 len:    40675   21043   20643   20927   20885   20746   20987   20576   20372  
 loops:  26429   17119   26503   25861   26347   26799   25459   26010   26349  

  25:    20848     825     898    1077    1076     840    1038     513     840  
 len:    40849   20826   20899   21078   21077   20840   21038   20514   20841  
 loops:  25664   17399   26621   26034   26196   26317   25478   25471   25665  

  26:    20982    1277     935     728     751    1173     725     614    1277  
 len:    40983   21278   20935   20728   20752   21173   20726   20615   21277  
 loops:  26374   17011   27000   26038   26252   26539   25755   25552   25521  

  27:    20997     836     659     980     625     835     627     907     642  
 len:    40998   20838   20660   20981   20625   20836   20628   20927   20643  
 loops:  25735   17146   26694   26704   26359   26030   26434   25638   25833  

  28:    21053    1112    1233   79037     842     826     695    1162     842  
 len:    41054   21113   21234   99037   20842   20826   20696   21163   20843  
 loops:  26211   17135   26572   26493   26334   26563   26562   26450   27036  

  29:    20937     777    1236     768     682    1131     653     464     765  
 len:    40937   20778   21237   20769   20683   21153   20654   20465   20766  
 loops:  25838   17133   26690   25976   25958   25612   26413   25897   26479  

  30:     1115    1138     849    1004     821     923    1243    1221     623  
 len:    21116   21139   20850   21005   20822   20924   21243   21222   20624  
 loops:    231   17476   27229   27046   26111   26929   27040   26544   27619  

  31:    20948    1321     992    1142    1036     594     582    1246     689  
 len:    40949   21322   20992   21143   21037   20594   20583   21247   20690  
 loops:  26540   17999   26481   26980   26697   26594   25878   25721   25900  

  32:      947    1059     962     739     812     574    1038     498     540  
 len:    20948   21060   20963   20739   20813   20575   21039   20499   20541  
 loops:    106   17056   26820   27129   26413   27051   27145   25394   26565  

  33:    20926     941     891     581     787     749     699    1058    1010  
 len:    40927   20941   20892   20581   20788   20750   20699   21059   21010  
 loops:  27031   27191   26624   26327   26640   27077   27529   25679   25791  

  34:    20821    1270    1194     792    1164     976     706     464     614  
 len:    40822   21271   21195   20793   21165   20977   20706   20465   20614  
 loops:  25834   16854   25318   26793   27416   25551   26361   26124   27080  

  35:     1013    1338     825     947    1274     825     490     510    1154  
 len:    21013   21339   20826   20947   21275   20826   20490   20511   21155  
 loops:    403   17522   25442   28042   26989   26277   27470   26490   27052  

  36:    21041    1057    1177    1140     929     744     697     791     697  
 len:    41041   21058   21178   21141   20930   20745   20698   20791   20698  
 loops:  27352   17593   27835   25818   27092   26434   27290   25950   26605  

  37:    20994    1235    1079     998     993     860    1150     548    1029  
 len:    40994   21237   21080   20999   20994   20861   21150   20548   21029  
 loops:  25962   17638   26653   26200   26857   26069   27330   25530   26405  

  38:    21047    1021    1375    1048    1007    1292     993     746     756  
 len:    41047   21022   21376   21049   21008   21293   20994   20747   20757  
 loops:  27583   17999   27706   25853   26542   27725   27650   26981   27996  

  39:    20804     793    1510    1439     773    1244     851     539     506  
 len:    40805   20794   21510   21440   20773   21244   20852   20540   20507  
 loops:  26589   17614   28001   25473   25510   26751   26575   26372   26179  

  40:    20790    1675    1246    1018    1643    1044    1556     621     411  
 len:    40791   21677   21246   21019   21643   21045   21557   20622   20411  
 loops:  15623   17977   27925   26257   27007   26984   26897   26116   25920  

  41:     1022     983     829    1267     712     589     698     586    1289  
 len:    21023   20985   20830   21268   20712   20590   20699   20587   21290  
 loops:    338   16922   26422   26403   27401   26159   26192   26903   25971  

  42:     1641    1808    1572    1336    1887    1415     625     603     580  
 len:    21642   21809   21573   21337   21888   21416   20626   20603   20581  
 loops:    929   17026   26539   26084   26189   27275   26154   26467   26371  

  43:    20832    1048     911     719     949     708     453     685     594  
 len:    40833   21049   20911   20720   20950   20709   20454   20685   20594  
 loops:  26632   17752   26957   26457   25862   27331   27682   26362   27179  

  44:    20892    1525     933    1253    1320     522    1414     917     534  
 len:    40893   21526   20934   21254   21321   20523   21415   20918   20535  
 loops:  27048   17388   26501   26361   25879   27207   26575   26938   26552  

  45:    21393    1542    1020     956    1135    1012    1226    1012     989  
 len:    41394   21543   21021   20957   21136   21013   21270   21013   20990  
 loops:  27020   18175   27305   27031   26304   27488   26163   26434   27474  

  46:    20841     870    1178    1100     871     598     859     615     527  
 len:    40841   20871   21179   21101   20872   20599   20860   20616   20528  
 loops:  26375   18084   26866   25934   25610   26855   26920   26305   26026  

  47:    20889    1185    1362     870    1598    1569     610     541     664  
 len:    40890   21186   21363   20871   21599   21570   20611   20542   20664  
 loops:  26713   17558   27353   26087   27098   26359   26376   25656   27057  

  48:    20749    1208    1116    1194    1273     832    1034     499     419  
 len:    40750   21209   21117   21194   21274   20832   21035   20500   20420  
 loops:  25946   17321   27573   27121   25809   26324   27027   26868   25925  

  49:     1840    1985    1949    1164    1795    1131    1214    1096     892  
 len:    21841   21986   21950   21165   21796   21132   21215   21097   20893  
 loops:    649   16930   26942   26720   26225   26230   26537   26121   26035  

Parent pid: 4906
 Task 0 (prio 2) (pid 4907):
   Max: 21397 us
   Min: 748 us
   Tot: 890955 us
   Avg: 17819 us

 Task 1 (prio 3) (pid 4908):
   Max: 1985 us
   Min: 619 us
   Tot: 57156 us
   Avg: 1143 us

 Task 2 (prio 4) (pid 4909):
   Max: 1949 us
   Min: 643 us
   Tot: 52506 us
   Avg: 1050 us

 Task 3 (prio 5) (pid 4910):
   Max: 79037 us
   Min: 581 us
   Tot: 128604 us
   Avg: 2572 us

 Task 4 (prio 6) (pid 4911):
   Max: 1887 us
   Min: 616 us
   Tot: 50109 us
   Avg: 1002 us

 Task 5 (prio 7) (pid 4912):
   Max: 1601 us
   Min: 522 us
   Tot: 46388 us
   Avg: 927 us

 Task 6 (prio 8) (pid 4913):
   Max: 1562 us
   Min: 446 us
   Tot: 44708 us
   Avg: 894 us

 Task 7 (prio 9) (pid 4914):
   Max: 1325 us
   Min: 453 us
   Tot: 40382 us
   Avg: 807 us

 Task 8 (prio 10) (pid 4915):
   Max: 1399 us
   Min: 371 us
   Tot: 38670 us
   Avg: 773 us
````

测试结果解析：

- 创建了9个实时任务，优先级从2到10（数字越小优先级越高）
- 每个任务执行迁移操作，测试迁移到不同CPU核心的延迟
- 进行了50轮测试（0-49行）

````
Iter:      0       1       2       3       4       5       6       7       8  
   0:    20963    1447    1263    1195    1254    1246    1111    1289     488  
 len:    40964   21448   21264   21196   21255   21246   21112   21289   20488  
 loops:  25020   17819   25360   25492   25733   25578   24880   25805   23941  
````

**每行数据包含：**

- 任务编号（0-49）：每个编号代表一次迁移测试
- 延迟数据（单位：微秒us）：9个值对应9个测试任务(0-8，每一列代表一个任务)在该次迁移中的延迟
- len：任务执行的总长度（包含基准循环）
- loops：测试中完成的循环次数

````
Task 0 (prio 2) (pid 4907):   #任务0（优先级2）
   Max: 21397 us              #最大延迟
   Min: 748 us                #最小延迟
   Tot: 890955 us             #总延迟
   Avg: 17819 us              #平均延迟
````

#### 2.8 signaltest

signaltest 主要用于测量信号在多个线程之间传递的往返延迟，是评估Linux系统实时响应能力的关键指标之一。

工作原理：创建N个线程相互发送信号，精确测量信号从发送到被另一线程接收的总时间

核心指标：最小延迟(Min)、平均延迟(Avg)、最大延迟(Max)，单位通常是微秒（μs）。其中最大延迟（抖动）对实时系统最关键。

执行 help 命令，查看 signaltest 的参数

````
$ signaltest --help
signaltest V 2.80
Usage:
signaltest <options>

-a [NUM] --affinity        run thread #N on processor #N, if possible
                           with NUM pin all threads to the processor NUM
-b USEC  --breaktrace=USEC send break trace command when latency > USEC
-D       --duration=TIME   specify a length for the test run.
                           Append 'm', 'h', or 'd' to specify minutes, hours or
                           days.
-h       --help            display usage information
         --json=FILENAME   write final results into FILENAME, JSON formatted
-l LOOPS --loops=LOOPS     number of loops: default=0(endless)
-m       --mlockall        lock current and future memory allocations
-p PRIO  --prio=PRIO       priority of highest prio thread
-q       --quiet           print a summary only on exit
-t NUM   --threads=NUM     number of threads: default=2
-v       --verbose         output values on stdout for statistics
                           format: n:c:v n=tasknum c=count v=value in us
````

参数说明

| 参数选项 | 长选项            | 参数     | 说明                                                         | 默认值    |
| -------- | ----------------- | -------- | ------------------------------------------------------------ | --------- |
| -a [NUM] | --affinity        | [NUM]    | 将线程绑定到CPU（CPU亲和性（核心））<br>`-a 2,3`：将线程0绑定到CPU2，线程1绑定到CPU3<br>`-a 2`：将所有线程都绑定到CPU2。 | -         |
| -b USEC  | --breaktrace=USEC | USEC     | 延迟追踪触发：当延迟超过`USEC`微秒时，触发内核的断点追踪（需要内核支持），用于深度调试单次超高延迟的原因。 | -         |
| -D       | --duration=TIME   | TIME     | 测试持续时间：例如 `-D 10s` (10秒)， `-D 5m` (5分钟)， `-D 1h` (1小时)。测试时间越长，越能捕捉到罕见的系统延迟峰值。 | -         |
| -h       | --help            | -        | 显示帮助信息                                                 | -         |
|          | --json=FILENAME   | FILENAME | JSON格式输出：将最终的统计结果（最小、平均、最大延迟等）保存到JSON文件，方便用脚本或其他工具进行分析和绘图。 |           |
| -l LOOPS | --loops=LOOPS     | LOOPS    | 信号循环次数：每个线程发送信号的次数。如果同时设置了 `-D` 和 `-l`，先达到的条件会结束测试。默认0表示无限循环，通常配合 `-D` 使用。 | 0（无限） |
| -m       | --mlockall        | -        | 锁定内存：锁定测试进程的内存，防止其被交换到硬盘。对于追求极致稳定性的实时测试非常重要，可以避免因换页导致的巨大延迟。 | -         |
| -p PRIO  | --prio=PRIO       | PRIO     | 线程优先级：设置测试线程的实时优先级（1-99）。数值越高，优先级越高。要获得可靠的低延迟，通常需要设置高优先级（如90以上）。 | -         |
| -q       | --quiet           | -        | 安静模式：只在测试结束时输出摘要信息。在长时间测试或自动化脚本中很有用，避免屏幕被刷屏。 | -         |
| -t NUM   | --threads=NUM     | NUM      | 线程数：默认是2个线程相互发信号。增加线程数可以模拟更复杂的交互，但线程过多可能增加系统调度负载。 | 2         |
| -v       | --verbose         | -        | 详细输出：实时将每一次的延迟数据打印到标准输出（格式：`n:c:v`），可用于实时监控或生成精细的延迟分布图。(在stdout输出统计值) | -         |

基本测试

````
$ signaltest               # 默认参数（2个线程，无限循环）
$ signaltest -l 1000       # 指定循环次数（1000次）
$ signaltest -D 30s        # 指定运行时长（30秒）
$ signaltest -D 5m         # 运行5分钟
$ signaltest -D 1h         # 运行1小时
````

线程配置

`````
$ signaltest -t 4            # 使用4个线程
$ signaltest -t 8 -D 60s     # 使用8个线程，运行60秒 
$ signaltest -t 16 -l 10000  # 16个线程，10000次循环
`````

优先级设置

````
$ signaltest -p 90                    # 设置最高优先级为90
$ signaltest -p 99 -t 4               # 最高优先级99，4个线程
$ signaltest -p 95 -D 30s -l 50000    # 结合运行时长
````

CPU亲和性

`````
$ signaltest -a         # 自动绑定（线程N绑定到CPU N）
$ signaltest -a 0       # 所有线程绑定到CPU 0
$ signaltest -a 2       # 绑定到CPU 2和3
$ signaltest -t 4 -a    # 4个线程分别绑定到CPU 0-3
`````

内存锁定

`````
$ signaltest -m                       # 锁定内存防止换出（需要root）
$ signaltest -m -p 99 -t 4 -D 30s     # 结合其他参数
`````

输出控制

`````
$ signaltest -q                            # 安静模式（只显示摘要）
$ signaltest -v                            # 详细输出（实时统计）
$ signaltest --json=results.json           # 输出到JSON文件
$ signaltest -q --json=signal_test.json    # 安静模式+JSON输出
`````

断点跟踪

````
$ signaltest -b 100                # 当延迟超过100us时触发断点跟踪
$ signaltest -b 50 -p 99 -D 60s    # 结合其他参数
````

示例

````
signaltest \
    -t 4 \          # 4个线程
    -p 99 \         # 优先级99
    -l 100000 \     # 100000次循环
    -D 30s \        # 运行30秒
    -a \            # CPU亲和性
    -m \            # 锁定内存
    -b 100 \        # 延迟>100us时断点跟踪
    -q \            # 安静模式
    --json=comprehensive_results.json    # 结果保存在 comprehensive_results.json
````

测试结果

````
$ signaltest -t 4 -p 60 -D 3m
1.23 0.96 0.84 1/176 8563          

T: 0 ( 8560) P:60 C:  86672 Min:    981 Act: 1093 Avg: 1343 Max:    5933
T: 0 ( 8560) P:60 C:  86673 Min:    981 Act: 1116 Avg: 1343 Max:    5933
T: 1 ( 8561) P:60 C:  86673 Min:    978 Act:12326 Avg: 2074 Max:   17904
T: 2 ( 8562) P:60 C:  86673 Min:    970 Act:12372 Avg: 2074 Max:   17863
T: 3 ( 8563) P:60 C:  86673 Min:    978 Act:12400 Avg: 2074 Max:   18098
````

各字段含义

| 字段    | 含义     | 说明                  |
| ------- | -------- | --------------------- |
| T       | Thread   | 线程编号（0-3）       |
| ( 8560) | PID      | 进程ID                |
| P       | Priority | 实时优先级（1-99）    |
| C       | Count    | 已完成的信号交换次数  |
| Min     | Minimum  | 最小延迟（微秒）      |
| Act     | Actual   | 当前/实际延迟（微秒） |
| Avg     | Average  | 平均延迟（微秒）      |
| Max     | Maximum  | 最大延迟（微秒）      |

#### 2.9 sigwaittest

sigwaittest 是用于测试信号等待延迟的工具，专门测量从信号发送到信号被等待接收的完整延迟。

主要功能：

- 测量信号等待（sigwait）系统调用的延迟

- 测试实时信号的等待性能

- 验证信号屏蔽和等待机制

- 测量信号处理的确定性

与signaltest的区别：

signaltest 关注的是两个实时任务之间通过信号进行来回通信的完整周期延迟

sigwaittest 关注的是信号从发出到被捕获的极端响应速度，也就是信号本身的“唤醒”延迟。

执行 help 命令，查看 signaltest 的参数

````
$ sigwaittest --help
sigwaittest V 2.80
Usage:
sigwaittest <options>

Function: test sigwait() latency

Available options:
-a [NUM] --affinity        run thread #N on processor #N, if possible
                           with NUM pin all threads to the processor NUM
-b USEC  --breaktrace=USEC send break trace command when latency > USEC
-d DIST  --distance=DIST   distance of thread intervals in us default=500
-D       --duration=TIME   specify a length for the test run.
                           Append 'm', 'h', or 'd' to specify minutes, hours or
                           days.
-f [OPT] --fork[=OPT]      fork new processes instead of creating threads
-i INTV  --interval=INTV   base interval of thread in us default=1000
         --json=FILENAME   write final results into FILENAME, JSON formatted
-l LOOPS --loops=LOOPS     number of loops: default=0(endless)
-p PRIO  --prio=PRIO       priority
-q       --quiet           print a summary only on exit
-t       --threads         one thread per available processor
-t [NUM] --threads=NUM     number of threads:
                           without NUM, threads = max_cpus
                           without -t default = 1
````

参数说明

| 短选项   | 长选项            | 参数     | 说明                                                         | 默认值    |
| -------- | ----------------- | -------- | ------------------------------------------------------------ | --------- |
| -a [NUM] | --affinity        | [NUM]    | CPU亲和性绑定，如果可能，让第 N 号线程在第 N 号处理器（CPU核心）上运行。如果指定了数字参数，则将所有线程都固定绑定在指定的处理器（CPU核心）数字上运行。 | -         |
| -b USEC  | --breaktrace=USEC | USEC     | 延迟超过USEC时断点跟踪，当测量到的延迟超过指定的微秒值时，发送断点追踪命令（用于调试） | -         |
| -d DIST  | --distance=DIST   | DIST     | 线程间隔距离（微秒），设置多个线程之间启动间隔的增量，单位是微秒。默认值为 500 微秒 | 500       |
| -D       | --duration=TIME   | TIME     | 测试运行时长，可在时间值后附加 `m`、`h` 或 `d` 来分别指定分钟、小时或天。 | -         |
| -f [OPT] | --fork[=OPT]      | [OPT]    | 使用进程代替线程，创建新的进程来进行测试，而不是默认的创建线程。 | -         |
| -i INTV  | --interval=INTV   | INTV     | 线程基础间隔（微秒），设置线程的基础唤醒间隔，单位是微秒。默认值为 1000 微秒。 | 1000      |
|          | --json=FILENAME   | FILENAME | 输出JSON格式结果，将最终的测试结果以 JSON 格式写入指定的文件名。 | -         |
| -l LOOPS | --loops=LOOPS     | LOOPS    | 循环次数，设置测试循环的次数。默认值为 0，表示无限循环（直到用`Ctrl+C`中断或达到`-D`指定的时长）。 | 0（无限） |
| -p PRIO  | --prio=PRIO       | PRIO     | 优先级，设置测试线程或进程的调度优先级。                     | -         |
| -q       | --quiet           | -        | 安静模式，仅在测试退出时打印结果摘要，减少运行过程中的输出。 | -         |
| -t       | --threads         | -        | 每个可用CPU一个线程，不带数字参数时：为系统中每个可用的处理器（CPU核心）创建一个线程对。 | -         |
| -t [NUM] | --threads=NUM     | NUM      | 线程数量，带数字参数时：指定要创建的线程对数量。特别说明：如果不使用 `-t` 选项，则默认创建 1 个线程对（一个发送，一个接收）。 | 1         |

基础测试

````
$ sigwaittest                 # 默认参数（1个线程）
$ sigwaittest -t              # 使用所有CPU核心（每个核心一个线程）
$ sigwaittest -t 4            # 指定4个线程
$ sigwaittest -t 4 -D 30s     # 指定运行时长（30秒）
$ sigwaittest -t 2 -l 10000   # 指定循环次数（10000次）
````

 线程间隔调整

````
$ sigwaittest -t 4 -d 200    # 调整线程间隔（默认500us）,200us间隔# 
$ sigwaittest -t 4 -i 500    # 调整基础间隔（默认1000us）,500us基础间隔
$ sigwaittest -t 4 -d 100 -i 200  # # 组合调整,密集测试
````

进程模式测试

````
$ sigwaittest -f                     # 使用进程代替线程（测试进程间信号）
$ sigwaittest -f -t 4                # 指定进程数量
$ sigwaittest -f=spawn -t 4 -D 30s   # 进程模式带参数
````

优先级设置

````
$ sigwaittest -p 99 -D 30s           # 以最高优先级99运行1个线程对，持续30秒
````

CPU亲和性

````
$ sigwaittest -a -t 4                    # 自动绑定（线程N绑定到CPU N）
$ sigwaittest -a 0 -t 4                  # 所有线程绑定到CPU 0
````

输出控制

````
$ sigwaittest -q -D 30s                            # 安静模式
$ sigwaittest --json=results.json -D 30s           # JSON输出
$ sigwaittest -b 50 -D 30s                         # 断点跟踪（延迟超过50us时触发）
$ sigwaittest -q --json=test.json -b 100 -D 60s    # 组合使用
````

多核满载测试：在所有CPU核心上各运行一个高优先级线程对，测试1分钟。

````
$ sigwaittest -p 99 -t -a -D 1m
````

- `-t`：为每个CPU核心创建线程对。
- `-a`：将各线程对绑定到对应核心。

指定核心与负载测试：在CPU 0和CPU 1上各运行2个高优先级线程对，循环50万次。

````
$ sigwaittest -p 98 -t 2 -a 0 -l 500000
````

- `-a 0` 将所有线程绑定到CPU 0。

进程模式测试：创建4个独立的实时进程（而非线程）进行测试。

````
$ sigwaittest -p 90 -f -t 4 -D 2m
````

测试结果

````
$ sigwaittest -t -a -p 98 -D 3m
#0: ID9978, P98, CPU0, I1000; #1: ID9979, P98, CPU0, Cycles 44803
#2: ID9980, P97, CPU1, I1500; #3: ID9981, P97, CPU1, Cycles 44591
#4: ID9982, P96, CPU2, I2000; #5: ID9983, P96, CPU2, Cycles 43825
#6: ID9984, P95, CPU3, I2500; #7: ID9985, P95, CPU3, Cycles 40903
#8: ID9986, P94, CPU4, I3000; #9: ID9987, P94, CPU4, Cycles 22958
#10: ID9988, P93, CPU5, I3500; #11: ID9989, P93, CPU5, Cycles 22143
#12: ID9990, P92, CPU6, I4000; #13: ID9991, P92, CPU6, Cycles 22046
#14: ID9992, P91, CPU7, I4500; #15: ID9993, P91, CPU7, Cycles 21976
#1 -> #0, Min  129, Cur  367, Avg  381, Max 2846
#3 -> #2, Min  121, Cur  370, Avg  395, Max 1907
#5 -> #4, Min  131, Cur  605, Avg  395, Max 1869
#7 -> #6, Min  132, Cur  392, Avg  411, Max 2051
#9 -> #8, Min  135, Cur  400, Avg  473, Max 1989
#11 -> #10, Min  139, Cur  442, Avg  453, Max 1961
#13 -> #12, Min  124, Cur  295, Avg  452, Max 1888
#15 -> #14, Min  127, Cur  373, Avg  442, Max 1969
````

`-t`：每个可用CPU一个线程（8个CPU → 16个线程） 

`-a`：自动CPU亲和性绑定 

`-p 98`：最高优先级98 

`-D 3m`：运行3分钟

线程对配置

````
#0: ID9978, P98, CPU0, I1000; #1: ID9979, P98, CPU0, Cycles 44803
#2: ID9980, P97, CPU1, I1500; #3: ID9981, P97, CPU1, Cycles 44591
#4: ID9982, P96, CPU2, I2000; #5: ID9983, P96, CPU2, Cycles 43825
#6: ID9984, P95, CPU3, I2500; #7: ID9985, P95, CPU3, Cycles 40903
#8: ID9986, P94, CPU4, I3000; #9: ID9987, P94, CPU4, Cycles 22958
#10: ID9988, P93, CPU5, I3500; #11: ID9989, P93, CPU5, Cycles 22143
#12: ID9990, P92, CPU6, I4000; #13: ID9991, P92, CPU6, Cycles 22046
#14: ID9992, P91, CPU7, I4500; #15: ID9993, P91, CPU7, Cycles 21976
````

配置分析表

| 线程对 | 发送线程 | 接收线程 | 优先级 | CPU  | 间隔(us) | 循环次数 |
| ------ | -------- | -------- | ------ | ---- | -------- | -------- |
| 0-1    | \#0      | \#1      | 98     | CPU0 | 1000     | 44803    |
| 2-3    | \#2      | \#3      | 97     | CPU1 | 1500     | 44591    |
| 4-5    | \#4      | \#5      | 96     | CPU2 | 2000     | 43825    |
| 6-7    | \#6      | \#7      | 95     | CPU3 | 2500     | 40903    |
| 8-9    | \#8      | \#9      | 94     | CPU4 | 3000     | 22958    |
| 10-11  | \#10     | \#11     | 93     | CPU5 | 3500     | 22143    |
| 12-13  | \#12     | \#13     | 92     | CPU6 | 4000     | 22046    |
| 14-15  | \#14     | \#15     | 91     | CPU7 | 4500     | 21976    |

cycles 值表示在测试期间完成的操作次数

循环次数递减：CPU0-3的循环次数明显高于CPU4-7

间隔递增：每个CPU对的间隔增加500us

优先级递减：从P98递减到P91

延迟统计

格式：`#发送者 -> #接收者, Min 最小延迟, Cur 当前延迟, Avg 平均延迟, Max 最大延迟`

````
#1 -> #0, Min  129, Cur  367, Avg  381, Max 2846
#3 -> #2, Min  121, Cur  370, Avg  395, Max 1907
#5 -> #4, Min  131, Cur  605, Avg  395, Max 1869
#7 -> #6, Min  132, Cur  392, Avg  411, Max 2051
#9 -> #8, Min  135, Cur  400, Avg  473, Max 1989
#11 -> #10, Min  139, Cur  442, Avg  453, Max 1961
#13 -> #12, Min  124, Cur  295, Avg  452, Max 1888
#15 -> #14, Min  127, Cur  373, Avg  442, Max 1969
````

性能汇总表

| 线程对 | CPU  | 最小延迟(us) | 当前延迟(us) | 平均延迟(us) | 最大延迟(us) |
| ------ | ---- | ------------ | ------------ | ------------ | ------------ |
| 1→0    | CPU0 | 129          | 367          | 381          | 2846         |
| 3→2    | CPU1 | 121          | 370          | 395          | 1907         |
| 5→4    | CPU2 | 131          | 605          | 395          | 1869         |
| 7→6    | CPU3 | 132          | 392          | 411          | 2051         |
| 9→8    | CPU4 | 135          | 400          | 473          | 1989         |
| 11→10  | CPU5 | 139          | 442          | 453          | 1961         |
| 13→12  | CPU6 | 124          | 295          | 452          | 1888         |
| 15→14  | CPU7 | 127          | 373          | 442          | 1969         |

#### 2.10 svsematest

svsematest 专门用于测试 System V 信号量的性能和延迟特性

### 主要功能

- 测试System V信号量的操作延迟 
- 测量信号量的获取/释放性能 
- 验证信号量在实时系统中的表现 
- 测试进程间同步性能

执行 help 命令，查看 svsematest 的参数

````
$ svsematest --help
svsematest V 2.80
Usage:
svsematest <options>

Function: test SYSV semaphore latency

Avaiable options:
-a [NUM] --affinity        run thread #N on processor #N, if possible
                           with NUM pin all threads to the processor NUM
-b USEC  --breaktrace=USEC send break trace command when latency > USEC
-d DIST  --distance=DIST   distance of thread intervals in us default=500
-D       --duration=TIME   specify a length for the test run.
                           Append 'm', 'h', or 'd' to specify minutes, hours or
                           days.
-f [OPT] --fork[=OPT]      fork new processes instead of creating threads
-i INTV  --interval=INTV   base interval of thread in us default=1000
         --json=FILENAME   write final results into FILENAME, JSON formatted
-l LOOPS --loops=LOOPS     number of loops: default=0(endless)
-p PRIO  --prio=PRIO       priority
-S       --smp             SMP testing: options -a -t and same priority
                           of all threads
-t       --threads         one thread per available processor
-t [NUM] --threads[=NUM]   number of threads:
                           without NUM, threads = max_cpus
                           without -t default = 1
````

参数说明

| 短选项   | 长选项            | 参数     | 说明                                                         | 默认值    |
| -------- | ----------------- | -------- | ------------------------------------------------------------ | --------- |
| -a [NUM] | --affinity        | [NUM]    | CPU亲和性绑定<br>`-a`（不带NUM）: 让每个线程尽量运行在对应编号的CPU上（如线程0在CPU0，线程1在CPU1）<br>`-a NUM`: 将所有线程强制绑定到指定的CPU核心NUM上 | -         |
| -b USEC  | --breaktrace=USEC | USEC     | 当信号量操作延迟超过USEC（微秒）时触发系统断点跟踪           | -         |
| -d DIST  | --distance=DIST   | DIST     | 线程间隔距离（微秒），线程启动的时间间隔（防止所有线程同时启动） | 500       |
| -D       | --duration=TIME   | TIME     | 测试运行时长，支持分钟(m)、小时(h)、天(d)后缀                | -         |
| -f [OPT] | --fork[=OPT]      | [OPT]    | 使用进程代替线程，使用fork创建新进程代替pthread创建线程。线程模式: 共享内存空间，上下文切换快。进程模式: 独立地址空间，更接近真实多进程应用场景 | -         |
| -i INTV  | --interval=INTV   | INTV     | 线程基础间隔（微秒），线程执行信号量操作的基本时间间隔       | 1000      |
|          | --json=FILENAME   | FILENAME | 输出JSON格式结果，  将测试结果保存为JSON格式文件             | -         |
| -l LOOPS | --loops=LOOPS     | LOOPS    | 循环次数，默认0表示无限循环，直到手动停止                    | 0（无限） |
| -p PRIO  | --prio=PRIO       | PRIO     | 优先级，设置测试线程的实时优先级，通常1-99，数字越大优先级越高 | -         |
| -S       | --smp             | -        | SMP测试模式                                                  | -         |
| -t       | --threads         | -        | 每个可用CPU一个线程                                          | -         |
| -t [NUM] | --threads[=NUM]   | NUM      | 线程数量<br>`-t`（无数字）: 线程数 = 系统CPU核心数<br>`-t NUM`: 创建NUM个线程<br>不使用`-t`: 默认1个线程 | 1         |

SMP测试模式

- 作用: 对称多处理器测试模式(指多个CPU核心对称地访问共享内存、外设等系统资源，区别于非对称多处理AMP，所有核心地位平等，没有主从之分)
- 要求: 必须配合`-a`和`-t`选项使用
- 特点: 所有线程设置为相同优先级
- 用途: 测试多核环境下的信号量性能

基本测试

````
$ svsematest               # 默认参数（1个线程）
$ svsematest -t            # 使用所有CPU核心（每个核心一个线程）
$ svsematest -t 4          # 指定4个线程
$ svsematest -t 4 -D 30s   # 指定运行时长（30秒）
$ svsematest -t 2 -l 10000   # 指定循环次数（10000次）
````

线程间隔调整

````
$ svsematest -t 4 -d 200    # 调整线程间隔（默认500us）,200us间隔
$ svsematest -t 4 -i 500    # 调整基础间隔（默认1000us）,500us基础间隔
$ svsematest -t 4 -d 100 -i 200  # 组合调整,密集测试
````

进程模式测试

````

$ svsematest -f                        # 使用进程代替线程（测试进程间信号量）
$ svsematest -f -t 4                   # 指定进程数量
$ svsematest -f=spawn -t 4 -D 30s      # 进程模式带参数
````

SMP测试模式

````
$ svsematest -t 4 -p 90              # 普通模式，优先级递减，模拟优先级继承/反转场景，无自动CPU绑定，测试不同优先级线程的竞争
$ svsematest -S -t 4 -a -p 90        # SMP对称多处理测试模式,创建4个线程,优先级都是90
$ svsematest -S -t 4 -a 0-3 -p 90    # SMP对称多处理测试模式,创建4个线程,优先级都是90,分别绑定到CPU0-3

# SMP模式详解：
# - 自动设置CPU亲和性 (-a)
# - 所有线程相同优先级
# - 专为SMP架构优化
````

优先级设置

````
$ svsematest -p 90 -t 4           # 设置优先级
$ svsematest -p 99 -t 4 -D 30s    # 最高优先级
````

CPU亲和性

````

$ svsematest -a -t 4      # 自动绑定（线程N绑定到CPU N）
$ svsematest -a 0 -t 4    # 所有线程绑定到CPU 0
````

输出控制

````

$ svsematest -q -D 30s                            # 安静模式
$ svsematest --json=results.json -D 30s           # JSON输出
$ svsematest -b 50 -D 30s                         # 断点跟踪（延迟超过50us时触发）
$ svsematest -q --json=test.json -b 100 -D 60s    # 组合使用
````

测试结果

````
$ svsematest -t -a -p 98 -D 3m
#0: ID10774, P98, CPU0, I1000; #1: ID10775, P98, CPU0, Cycles 44866
#2: ID10776, P97, CPU1, I1500; #3: ID10777, P97, CPU1, Cycles 44737
#4: ID10778, P96, CPU2, I2000; #5: ID10779, P96, CPU2, Cycles 44595
#6: ID10780, P95, CPU3, I2500; #7: ID10781, P95, CPU3, Cycles 44460
#8: ID10782, P94, CPU4, I3000; #9: ID10783, P94, CPU4, Cycles 44152
#10: ID10784, P93, CPU5, I3500; #11: ID10785, P93, CPU5, Cycles 24103
#12: ID10786, P92, CPU6, I4000; #13: ID10787, P92, CPU6, Cycles 22050
#14: ID10788, P91, CPU7, I4500; #15: ID10789, P91, CPU7, Cycles 21968
#1 -> #0, Min   48, Cur  108, Avg   67, Max 2024
#3 -> #2, Min   48, Cur   54, Avg   63, Max 1670
#5 -> #4, Min   46, Cur   66, Avg   63, Max 1475
#7 -> #6, Min   48, Cur   75, Avg   64, Max 1584
#9 -> #8, Min   46, Cur   52, Avg   62, Max 1656
#11 -> #10, Min   48, Cur   56, Avg   65, Max 1568
#13 -> #12, Min   49, Cur   59, Avg   65, Max 1659
#15 -> #14, Min   48, Cur   54, Avg   64, Max 1580
````

`-t`：每个可用CPU一个线程（8个CPU → 16个线程） 

`-a`：自动CPU亲和性绑定 

`-p 98`：最高优先级98 

`-D 3m`：运行3分钟

线程对配置

````
#0: ID10774, P98, CPU0, I1000;  #1: ID10775, P98, CPU0, Cycles 44866
#2: ID10776, P97, CPU1, I1500;  #3: ID10777, P97, CPU1, Cycles 44737
#4: ID10778, P96, CPU2, I2000;  #5: ID10779, P96, CPU2, Cycles 44595
#6: ID10780, P95, CPU3, I2500;  #7: ID10781, P95, CPU3, Cycles 44460
#8: ID10782, P94, CPU4, I3000;  #9: ID10783, P94, CPU4, Cycles 44152
#10: ID10784, P93, CPU5, I3500; #11: ID10785, P93, CPU5, Cycles 24103
#12: ID10786, P92, CPU6, I4000; #13: ID10787, P92, CPU6, Cycles 22050
#14: ID10788, P91, CPU7, I4500; #15: ID10789, P91, CPU7, Cycles 21968
````

配置分析表

| 线程对 | 发送线程 | 接收线程 | 优先级 | CPU  | 间隔(us) | 循环次数 |
| ------ | -------- | -------- | ------ | ---- | -------- | -------- |
| 0-1    | \#0      | \#1      | 98     | CPU0 | 1000     | 44866    |
| 2-3    | \#2      | \#3      | 97     | CPU1 | 1500     | 44737    |
| 4-5    | \#4      | \#5      | 96     | CPU2 | 2000     | 44595    |
| 6-7    | \#6      | \#7      | 95     | CPU3 | 2500     | 44460    |
| 8-9    | \#8      | \#9      | 94     | CPU4 | 3000     | 44152    |
| 10-11  | \#10     | \#11     | 93     | CPU5 | 3500     | 24103    |
| 12-13  | \#12     | \#13     | 92     | CPU6 | 4000     | 22050    |
| 14-15  | \#14     | \#15     | 91     | CPU7 | 4500     | 21968    |

延迟统计

````
#1 -> #0, Min   48, Cur  108, Avg   67, Max 2024
#3 -> #2, Min   48, Cur   54, Avg   63, Max 1670
#5 -> #4, Min   46, Cur   66, Avg   63, Max 1475
#7 -> #6, Min   48, Cur   75, Avg   64, Max 1584
#9 -> #8, Min   46, Cur   52, Avg   62, Max 1656
#11 -> #10, Min   48, Cur   56, Avg   65, Max 1568
#13 -> #12, Min   49, Cur   59, Avg   65, Max 1659
#15 -> #14, Min   48, Cur   54, Avg   64, Max 1580
````

| 线程对 | CPU  | 最小延迟(us) | 当前延迟(us) | 平均延迟(us) | 最大延迟(us) |
| ------ | ---- | ------------ | ------------ | ------------ | ------------ |
| 1→0    | CPU0 | 48           | 108          | 67           | 2024         |
| 3→2    | CPU1 | 48           | 54           | 63           | 1670         |
| 5→4    | CPU2 | 46           | 66           | 63           | 1475         |
| 7→6    | CPU3 | 48           | 75           | 64           | 1584         |
| 9→8    | CPU4 | 46           | 52           | 62           | 1656         |
| 11→10  | CPU5 | 48           | 56           | 65           | 1568         |
| 13→12  | CPU6 | 49           | 59           | 65           | 1659         |
| 15→14  | CPU7 | 48           | 54           | 64           | 1580         |







参考：

https://www.ewbang.com/community/article/details/1000280030.html

https://embedded.pages.openeuler.org/openEuler-23.03/features/preempt_rt.html

https://github.com/canonical/rt-tests-snap

https://wiki.linuxfoundation.org/realtime/documentation/howto/tools/rt-tests

https://blog.csdn.net/Jason_Yansir/article/details/145281538
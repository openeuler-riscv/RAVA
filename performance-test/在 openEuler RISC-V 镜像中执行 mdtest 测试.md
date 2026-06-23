## 在 openEuler RISC-V 镜像中执行 mdtest 测试

### 1. mdtest 介绍

**mdtest** 是 LLNL 开发、现在并入 **IOR 工具集**的**并行文件系统元数据性能基准**。

它用 **MPI** 多进程并发做：**创建 /stat/ 打开 / 删除文件与目录**，测的是**元数据（metadata）吞吐与延迟**，不是读写带宽（那是 IOR 的强项）。

- 典型场景：并行文件系统（Lustre/CEPHFS）、分布式存储、本地文件系统（Ext4/XFS）元数据性能对比
- 核心指标：**op/s（每秒操作数）**、平均延迟、P95/P99 延迟

### 2. 执行测试

下载源码编译安装

````
$ dnf install -y gcc gcc-c++ make openmpi openmpi-devel git automake autoconf
$ git clone https://github.com/hpc/ior.git
$ cd ior
$ ./bootstrap
$ ./configure
$ make -j$(nproc)
$ make install
````

因为 MPI（PMIx）在 RISC-V 架构上的共享内存地址分配问题，禁用共享内存组件

````
$ export PMIX_MCA_gds=hash
$ mdtest -h
Synopsis mdtest

Flags
  -C                            only create files/dirs
  -T                            only stat files/dirs
  -E                            only read files/dir
  -r                            only remove files or directories left behind by previous runs
  -U                            enable rename directory phase
  -D                            perform test on directories only (no files)
  -F                            perform test on files only (no directories)
  -k                            use mknod to create file
  -L                            files only at leaf level of tree
  -P                            print rate AND time
  --print-all-procs             all processes print an excerpt of their results
  -R                            random access to files (only for stat)
  -S                            shared file access (file only, no directories)
  -c                            collective creates: task 0 does all creates
  -t                            time unique working directory overhead
  -u                            unique working directory for each task
  -v                            verbosity (each instance of option increments by one)
  -X, --verify-read             Verify the data read
  --verify-write                Verify the data after a write by reading it back immediately
  -y                            sync file after writing
  -Y                            call the sync command after each phase (included in the timing; note it causes all IO to be flushed from your node)
  -Z                            print time instead of rate
  --warningAsErrors             Any warning should lead to an error.
  --showRankStatistics          Include statistics per rank

Optional arguments
  -a=STRING                     API for I/O [POSIX|DUMMY]
  -b=1                          branching factor of hierarchical directory structure
  -d=./out                      directory or multiple directories where the test will run [dir|dir1@dir2@dir3...]
  -B=0                          no barriers between phases
  -e=0                          bytes to read from each file
  -f=1                          first number of tasks on which the test will run
  -G=-1                         Offset for the data in the read/write buffer, if not set, a random value is used
  -i=1                          number of iterations the test will run
  -I=0                          number of items per directory in tree
  -l=0                          last number of tasks on which the test will run
  -n=0                          every process will creat/stat/read/remove # directories and files
  -N=0                          stride # between tasks for file/dir operation (local=0; set to 1 to avoid client cache)
  -p=0                          pre-iteration delay (in seconds)
  --random-seed=0               random seed for -R
  -s=1                          stride between the number of tasks for each test
  -V=0                          verbosity value
  -w=0                          bytes to write to each file after it is created
  -W=0                          number in seconds; stonewall timer, write as many seconds and ensure all processes did the same number of operations (currently only stops during create phase and files)
  -x=STRING                     StoneWallingStatusFile; contains the number of iterations of the creation phase, can be used to split phases across runs
  -z=0                          depth of hierarchical directory structure
  --dataPacketType=t            type of packet that will be created [offset|incompressible|timestamp|random|o|i|t|r]
  --run-cmd-before-phase=STRING call this external command before each phase (excluded from the timing)
  --run-cmd-after-phase=STRING  call this external command after each phase (included in the timing)
  --saveRankPerformanceDetails=STRINGSave the individual rank information into this CSV file.
  --savePerOpDataCSV=STRING     Store the performance of each rank into an individual file prefixed with this option.


Module POSIX

Flags
  --posix.odirect               Direct I/O Mode
  --posix.rangelocks            Use range locks (read locks for read ops)


Module DUMMY

Flags
  --dummy.delay-only-rank0      Delay only Rank0

Optional arguments
  --dummy.delay-create=0        Delay per create in usec
  --dummy.delay-close=0         Delay per close in usec
  --dummy.delay-sync=0          Delay for sync in usec
  --dummy.delay-xfer=0          Delay per xfer in usec


Module MPIIO

Flags
  --mpiio.showHints             Show MPI hints
  --mpiio.preallocate           Preallocate file size
  --mpiio.useStridedDatatype    put strided access into datatype
  --mpiio.useFileView           Use MPI_File_set_view

Optional arguments
  --mpiio.hintsFileName=STRING  Full name for hints file


Module MMAP

Flags
  --mmap.madv_dont_need         Use advise don't need
  --mmap.madv_pattern           Use advise to indicate the pattern random/sequential
````

1）核心测试模式（互斥，只能选其一）

| 选项 | 说明                  | 使用场景           |
| :--- | :-------------------- | :----------------- |
| `-C` | 只创建文件/目录       | 测试创建性能       |
| `-T` | 只stat文件/目录       | 测试元数据查询性能 |
| `-E` | 只读取文件/目录       | 测试读性能         |
| `-r` | 只删除残留的文件/目录 | 清理测试环境       |
| `-U` | 启用重命名目录阶段    | 测试重命名操作性能 |

2）测试对象选择

| 选项 | 说明                                       |
| :--- | :----------------------------------------- |
| `-F` | **只测试文件**（不创建目录）               |
| `-D` | **只测试目录**（不创建文件）               |
| `-L` | 文件只在树的叶子节点创建（配合 `-z` 使用） |
| `-S` | 共享文件访问（所有进程访问同一个文件）     |

3）目录结构参数

| 选项                | 说明                           | 示例                       |
| :------------------ | :----------------------------- | :------------------------- |
| `-z <深度>`         | 目录树的深度                   | `-z 3` 创建3层嵌套目录     |
| `-b <分支数>`       | 每个目录的子目录数             | `-b 4` 每个目录有4个子目录 |
| `-I <每目录项目数>` | 每个目录的文件数               | `-I 100` 每个目录100个文件 |
| `-u`                | **每个进程使用独立的工作目录** | 避免进程间干扰             |
| `-t`                | 测量唯一工作目录的开销         | 配合 `-u` 使用             |

4）测试控制参数

| 选项        | 说明                          | 典型值         |
| :---------- | :---------------------------- | :------------- |
| `-i <次数>` | 迭代次数（运行多轮）          | `-i 3`         |
| `-n <数量>` | **每个进程**创建的文件/目录数 | `-n 1000`      |
| `-d <路径>` | 测试目录（可用@分隔多个目录） | `-d /mnt/test` |
| `-v`        | 增加详细程度（可多次使用）    | `-vvv`         |
| `-P`        | 同时打印速率和时间            | 结果更详细     |
| `-Z`        | 只打印时间（不打印速率）      | 关注耗时场景   |

5）文件读写参数

| 选项             | 说明                    | 用途             |
| :--------------- | :---------------------- | :--------------- |
| `-w <字节>`      | 写入每个文件的字节数    | `-w 1024` 写1KB  |
| `-e <字节>`      | 从每个文件读取的字节数  | `-e 1024` 读1KB  |
| `-y`             | 写入后同步文件（fsync） | 测试持久化性能   |
| `-Y`             | 每个阶段后调用sync命令  | 刷新所有缓存     |
| `-k`             | 使用mknod创建特殊文件   | 测试设备文件创建 |
| `-X`             | 验证读取的数据正确性    | 数据完整性测试   |
| `--verify-write` | 写入后立即读回验证      | 确保写入正确     |

6）访问模式

| 选项        | 说明                          |                       |
| :---------- | :---------------------------- | --------------------- |
| `-R`        | 随机访问文件（仅stat操作）    |                       |
| `-c`        | 集体创建：只有0号进程执行创建 |                       |
| `-N <步长>` | 任务间文件/目录操作的步长     | `-N 1` 避免客户端缓存 |
| `-s <步长>` | 测试任务数的步长              | 用于扩展性测试        |

7）时间控制

| 选项        | 说明                                      |
| :---------- | :---------------------------------------- |
| `-W <秒数>` | Stonewall计时器：运行指定秒数             |
| `-x <文件>` | Stonewall状态文件（保存创建阶段迭代次数） |
| `-p <秒数>` | 迭代前延迟                                |
| `-B <0/1>`  | 阶段间是否使用屏障（0=无屏障）            |

8）高级功能

| 选项                           | 说明                                           |
| :----------------------------- | :--------------------------------------------- |
| `-a <API>`                     | I/O API选择：`POSIX`（默认）、`MPIIO`、`DUMMY` |
| `-f <起始数>`                  | 测试起始任务数                                 |
| `-l <结束数>`                  | 测试结束任务数                                 |
| `-G <偏移>`                    | 读写缓冲区的数据偏移                           |
| `--random-seed <种子>`         | 随机访问的随机种子                             |
| `--print-all-procs`            | 所有进程都打印结果                             |
| `--showRankStatistics`         | 包含每个rank的统计信息                         |
| `--saveRankPerformanceDetails` | 保存每个rank的详细信息到CSV                    |

9）模块特定选项

POSIX 模块

| 选项                 | 说明                        |
| :------------------- | :-------------------------- |
| `--posix.odirect`    | 使用直接I/O（绕过页面缓存） |
| `--posix.rangelocks` | 使用范围锁                  |

MPIIO 模块

| 选项                         | 说明                   |
| :--------------------------- | :--------------------- |
| `--mpiio.showHints`          | 显示MPI提示信息        |
| `--mpiio.preallocate`        | 预分配文件大小         |
| `--mpiio.useStridedDatatype` | 对步长访问使用数据类型 |
| `--mpiio.useFileView`        | 使用MPI_File_set_view  |

DUMMY 模块（用于性能模拟）

| 选项                   | 说明                 |
| :--------------------- | :------------------- |
| `--dummy.delay-create` | 每次创建延迟（微秒） |
| `--dummy.delay-xfer`   | 每次传输延迟（微秒） |

命令格式

````
mdtest [-d 测试目录] [-z 目录深度] [-b 分支因子] [-I 每目录文件数] [-i 迭代次数] [-u]
````

`-d /mnt/test`：**指定测试目录**（务必放在待测文件系统上）

`-z 3`：目录树深度（3～5 常见）

`-b 2`：每个目录下子目录数（分支因子）

`-I 100`：每个目录下创建**文件数**

`-i 5`：迭代次数（求均值、方差）

`-u`：每个进程用**唯一目录**（避免锁竞争）

`-F`：只测文件（不测目录）

`-L`：只测目录（不测文件）

实用示例

````
# 创建3层目录，每层4个分支，每个目录100个文件
$ mdtest -z 3 -b 4 -I 100 -u

# 基础文件测试：4进程，每进程1000个文件
$ mpirun -np 4 mdtest -F -u -n 1000 -d /testdir

# 深度目录测试：3层嵌套，每个目录500个文件
mpirun -np 8 mdtest -z 3 -b 4 -I 500 -u -d /testdir

# 大文件读写测试：写入1MB，读回验证
mpirun -np 4 mdtest -F -w 1048576 -e 1048576 -X -u -n 100 -d /testdir

# 性能压力测试：Stonewall模式运行60秒
mpirun -np 16 mdtest -F -W 60 -u -d /testdir

# 只测试元数据性能（stat）
mpirun -np 8 mdtest -F -T -u -n 10000 -d /testdir

# 测试目录操作性能
mpirun -np 4 mdtest -D -u -n 500 -d /testdir
````

执行测试

````
$ mkdir -p /data/mdtest
$ mpirun -np 4 --allow-run-as-root mdtest -d /data/mdtest -z 4 -b 2 -I 200 -i 5 -u
````

参数

| 参数              | 含义         | 本命令中的作用                                    |
| :---------------- | :----------- | :------------------------------------------------ |
| `-d /data/mdtest` | 测试目录路径 | 在 `/data/mdtest` 目录下进行所有文件/目录操作     |
| `-z 4`            | 目录树深度   | 创建 **4层嵌套** 的目录结构                       |
| `-b 2`            | 分支因子     | 每层目录 **2个子目录**                            |
| `-I 200`          | 每目录文件数 | 每个叶子目录下创建 **200个文件**                  |
| `-i 5`            | 迭代次数     | 完整测试流程重复 **5次**，取平均结果              |
| `-u`              | 独立工作目录 | 每个进程使用自己 **唯一的工作目录**，避免互相干扰 |

mpirun 命令参数

````
$ mpirun --allow-run-as-root -h
mpirun (Open MPI) 4.1.5

Usage: mpirun [OPTION]...  [PROGRAM]...
Start the given program using Open RTE

-c|-np|--np <arg0>       Number of processes to run
-h|--help <arg0>         This help message
   -n|--n <arg0>         Number of processes to run
-q|--quiet               Suppress helpful messages
-v|--verbose             Be verbose
-V|--version             Print version and exit

For additional mpirun arguments, run 'mpirun --help <category>'

The following categories exist: general (Defaults to this option), debug,
    output, input, mapping, ranking, binding, devel (arguments useful to OMPI
    Developers), compatibility (arguments supported for backwards compatibility),
    launch (arguments to modify launch options), and dvm (Distributed Virtual
    Machine arguments).

Report bugs to http://www.open-mpi.org/community/help/
````

```
mpirun (Open MPI) 4.1.5

用法：mpirun [选项]...  [程序]...
使用 Open RTE 启动指定的程序

-c|-np|--np <参数0>       要运行的进程数量
-h|--help <参数0>         显示此帮助信息
-n|--n <参数0>            要运行的进程数量
-q|--quiet                抑制帮助性的提示消息
-v|--verbose              显示详细信息
-V|--version              打印版本信息并退出

要查看其他 mpirun 参数，请运行 'mpirun --help <分类>'

可用的分类如下：
    general       （默认选项，即此选项）
    debug         （调试相关选项）
    output        （输出控制选项）
    input         （输入控制选项）
    mapping       （进程映射选项）
    ranking       （进程排序选项）
    binding       （CPU绑定选项）
    devel         （对 Open MPI 开发者有用的参数）
    compatibility （为向后兼容性支持的参数）
    launch        （修改启动方式的参数）
    dvm           （分布式虚拟机参数）

报告 bug 请访问：http://www.open-mpi.org/community/help/
```

常用参数

| 参数                  | 说明                                      |
| :-------------------- | :---------------------------------------- |
| `-np 4`               | 启动 4 个进程                             |
| `--allow-run-as-root` | 允许以 root 用户运行（默认禁止）          |
| `--hostfile`          | 指定主机列表文件                          |
| `--map-by`            | 指定进程映射方式（如 node、socket、core） |
| `--bind-to`           | 指定进程绑定方式（如 core、socket）       |
| `--report-bindings`   | 报告进程的 CPU 绑定情况                   |
| `--mca <参数> <值>`   | 设置 MCA（模块化组件架构）参数            |

要查看所有可用参数，可以运行：

````
# 查看启动相关参数（包含 --allow-run-as-root）
$ mpirun --help launch

# 或查看所有兼容性参数
$ mpirun --help compatibility

# 查看所有参数（输出较多）
$ mpirun --help all
````

测试结果

````
$ mpirun -np 4 --allow-run-as-root mdtest -d /data/mdtest -z 4 -b 2 -I 200 -i 5 -u
-- started at 06/13/2026 11:45:33 --

mdtest-4.1.0+dev was launched with 4 total task(s) on 1 node(s)
Command line used: mdtest '-d' '/data/mdtest' '-z' '4' '-b' '2' '-I' '200' '-i' '5' '-u'
WARNING: Read bytes is 0, thus, a read test will actually just open/close
Nodemap: 1111
Path                : /data/mdtest
FS                  : 37.1 GiB   Used FS: 5.6%   Inodes: 2.4 Mi   Used Inodes: 1.7%
4 tasks, 24800 files/directories

SUMMARY rate (in ops/sec): (of 5 iterations)
   Operation                     Max            Min           Mean        Std Dev
   ---------                     ---            ---           ----        -------
   Directory creation           3447.683       2773.860       3184.206        260.869
   Directory stat              49766.827      42636.974      47021.209       2769.132
   Directory rename             5574.874       4712.590       5374.415        370.891
   Directory removal            4455.158       3272.262       4128.215        491.407
   File creation                6515.949       5491.047       6168.335        402.101
   File stat                   50408.448      43730.341      46905.151       2663.311
   File read                   25607.222      21539.311      23862.868       1773.983
   File removal                 9428.141       8356.778       8757.431        431.335
   Tree creation                 723.707        285.788        552.222        184.297
   Tree removal                  257.195        145.099        177.245         46.076
-- finished at 06/13/2026 11:47:53 --
````

1）启动信息

```
-- started at 06/13/2026 11:45:33 --
```

含义：测试开始的时间戳（月/日/年 时:分:秒）

```
mdtest-4.1.0+dev was launched with 4 total task(s) on 1 node(s)
```

含义：

- 使用的 `mdtest` 版本是 4.1.0+开发版
- 启动了 4 个并行任务（进程）
- 运行在 1 个物理节点（单机）上

````
Command line used: mdtest '-d' '/data/mdtest' '-z' '4' '-b' '2' '-I' '200' '-i' '5' '-u'
````

含义：回显你执行时使用的命令行参数，便于确认测试配置。

````
WARNING: Read bytes is 0, thus, a read test will actually just open/close
````

含义：警告信息（非错误）

- 因为没有用 `-e` 参数指定读取字节数，读取操作时只是打开文件然后立即关闭，并没有真正读取数据内容
- 所以 "File read" 的测试结果反映的是 open/close 的性能，而不是实际读取数据的性能

````
Nodemap: 1111
````

含义：

- 表示 4 个进程分别映射到哪个节点
- `1111` 表示 4 个进程都在第 1 个节点上（单机运行）

````
Path                : /data/mdtest
FS                  : 37.1 GiB   Used FS: 5.6%   Inodes: 2.4 Mi   Used Inodes: 1.7%
````

含义：测试目录的文件系统状态

| 项目          | 数值           | 说明                    |
| :------------ | :------------- | :---------------------- |
| `Path`        | `/data/mdtest` | 测试目录路径            |
| `FS`          | 37.1 GiB       | 文件系统总容量          |
| `Used FS`     | 5.6%           | 已用空间占比            |
| `Inodes`      | 2.4 Mi         | 总 inode 数量（≈251万） |
| `Used Inodes` | 1.7%           | 已用 inode 占比         |

````
4 tasks, 24800 files/directories
````

含义：

- 4 个并行任务
- 总共会创建 24,800 个文件/目录（包括所有进程创建的对象总和）

2）测试结果表格

````
SUMMARY rate (in ops/sec): (of 5 iterations)
````

含义：以下是 5 次迭代汇总的每秒操作数统计结果

````
Operation                     Max            Min           Mean        Std Dev
   ---------                     ---            ---           ----        -------
````

含义：表格列标题

| 列名        | 含义                           |
| :---------- | :----------------------------- |
| `Operation` | 操作类型                       |
| `Max`       | 5 次迭代中的最大速率           |
| `Min`       | 5 次迭代中的最小速率           |
| `Mean`      | 平均速率（最关键的指标）       |
| `Std Dev`   | 标准差（衡量稳定性，越小越好） |

目录操作行

````
Directory creation           3447.683       2773.860       3184.206        260.869
````

含义：创建目录的性能

- 平均每秒创建 3,184 个目录
- 最快 3,447，最慢 2,774
- 标准差 260，波动较小

````
Directory stat              49766.827      42636.974      47021.209       2769.132
````

含义：获取目录状态（`stat` 系统调用）的性能

- 平均每秒执行 47,021 次目录 stat
- 速度非常快，说明元数据缓存命中率高

````
Directory rename             5574.874       4712.590       5374.415        370.891
````

含义：重命名目录的性能

- 平均每秒重命名 5,374 个目录

````
Directory removal            4455.158       3272.262       4128.215        491.407
````

含义：删除目录的性能

- 平均每秒删除 4,128 个目录
- 标准差 491 相对较大，说明删除性能不够稳定

文件操作行

````
File creation                6515.949       5491.047       6168.335        402.101
````

含义：创建文件的性能

- 平均每秒创建 6,168 个文件
- 比创建目录（3,184）快约 2 倍
- 原因：创建文件比创建目录开销小

````
File stat                   50408.448      43730.341      46905.151       2663.311
````

含义：获取文件状态的性能

- 平均每秒执行 46,905 次文件 stat
- 与目录 stat 性能相当

````
File read                   25607.222      21539.311      23862.868       1773.983
````

含义：读取文件的性能

- 由于 `Read bytes is 0`，实际是测试`打开+关闭`文件的性能
- 平均每秒打开/关闭 23,863 个文件

````
File removal                 9428.141       8356.778       8757.431        431.335
````

含义：删除文件的性能

- 平均每秒删除 8,757 个文件
- 比删除目录（4,128）快约 2 倍

树操作行

````
 Tree creation                 723.707        285.788        552.222        184.297
````

含义：创建整个目录树结构的性能

- 平均每秒完成 552 次"整棵树"的创建
- 比单个目录创建慢很多，因为树需要维护层级关系

````
Tree removal                  257.195        145.099        177.245         46.076
````

含义：删除整个目录树结构的性能

- 平均每秒完成 177 次"整棵树"的删除
- 最慢的操作：需要从叶子节点向上递归删除
- 标准差 46 较小，说明性能较稳定

3）结束信息

````
-- finished at 06/13/2026 11:47:53 --
````

含义：测试结束的时间戳

总耗时：11:47:53 - 11:45:33 = 2 分 20 秒

````
SUMMARY rate (in ops/sec): (of 5 iterations)
   Operation                     Max            Min           Mean        Std Dev
   ---------                     ---            ---           ----        -------
   Directory creation           4187.943       3202.925       3843.923        426.004
   Directory stat              56270.145      38948.833      47540.906       6209.252
   Directory rename             5950.297       4152.827       5398.597        748.920
   Directory removal            4658.406       3917.647       4234.600        277.742
   File creation                6897.112       5755.957       6521.295        447.035
   File stat                   48092.033      38514.161      41898.481       3918.723
   File read                   25350.589      19355.374      22951.424       2473.981
   File removal                 8947.577       8405.330       8715.405        239.189
   Tree creation                 935.703        371.690        594.614        236.568
   Tree removal                  196.855         92.618        156.068         38.767
-- finished at 06/13/2026 12:25:58 --
````




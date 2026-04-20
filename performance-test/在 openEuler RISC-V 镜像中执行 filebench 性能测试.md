## 在 openEuler RISC-V 镜像中执行 filebench 性能测试

### 1. filebench 介绍

**Filebench** 是一款模型驱动的文件系统 / 存储性能基准测试工具，通过 **WML（Workload Model Language）** 定义负载，可模拟真实应用（Web / 文件 / 数据库服务器）或自定义微基准，适合评估内核态文件系统、块设备、分布式存储的 I/O 性能。

### 2. 执行 filebench 测试

从源码编译安装 filebench 

````
$ yum install -y git autoconf automake libtool bison flex
$ git clone https://github.com/filebench/filebench.git
$ cd filebench
# 生成配置脚本并编译安装
$ libtoolize
$ aclocal
$ autoheader
$ automake --add-missing
$ autoconf
$ ./configure
$ make -j `nproc`
$ make install
````

查看 filebench 支持的选项

````
$ filebench -h
Usage: filebench {-f <wmlscript> | -h | -c [cvartype]}

  Filebench version 1.5-alpha3

  Filebench is a file system and storage benchmark that interprets a script
  written in its Workload Model Language (WML), and procees to generate the
  specified workload. Refer to the README for more details.

  Visit github.com/filebench/filebench for WML definition and tutorials.

Options:
   -f <wmlscript> generate workload from the specified file
   -h             display this help message
   -c             display supported cvar types
   -c [cvartype]  display options of the specific cvar type
````

选项说明

| 选项             | 说明                                                         |
| ---------------- | ------------------------------------------------------------ |
| `-f <wmlscript>` | 从指定的 **.f 脚本文件** 生成 I/O 负载，执行指定的WML脚本文件，最常用<br>**用法**: `filebench -f 脚本文件名`<br/>**示例**: `filebench -f webserver.f` |
| `-h`             | 显示帮助信息<br>示例：`filebench -h`                         |
| `-c`             | 显示支持的 **cvar 类型**<br>**cvar**: 控制变量，用于在WML脚本中定义随机变量分布（如高斯分布、指数分布等） |
| `-c [cvartype]`  | 显示特定cvar类型的详细选项<br>**示例**: `filebench -c gauss` 查看高斯分布的参数选项 |

编辑WML脚本文件

````
$ cp /usr/local/share/filebench/workloads/fileserver.f custom.f
$ vi custom.f
CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2008 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#

set $dir=/tmp
set $nfiles=10000
set $meandirwidth=20
set $filesize=cvar(type=cvar-gamma,parameters=mean:131072;gamma:1.5)
set $nthreads=50
set $iosize=1m
set $meanappendsize=16k
set $runtime=60

define fileset name=bigfileset,path=$dir,size=$filesize,entries=$nfiles,dirwidth=$meandirwidth,prealloc=80

define process name=filereader,instances=1
{
  thread name=filereaderthread,memsize=10m,instances=$nthreads
  {
    flowop createfile name=createfile1,filesetname=bigfileset,fd=1
    flowop writewholefile name=wrtfile1,srcfd=1,fd=1,iosize=$iosize
    flowop closefile name=closefile1,fd=1
    flowop openfile name=openfile1,filesetname=bigfileset,fd=1
    flowop appendfilerand name=appendfilerand1,iosize=$meanappendsize,fd=1
    flowop closefile name=closefile2,fd=1
    flowop openfile name=openfile2,filesetname=bigfileset,fd=1
    flowop readwholefile name=readfile1,fd=1,iosize=$iosize
    flowop closefile name=closefile3,fd=1
    flowop deletefile name=deletefile1,filesetname=bigfileset
    flowop statfile name=statfile1,filesetname=bigfileset
  }
}

echo  "File-server Version 3.0 personality successfully loaded"

run $runtime
````

**文件内容解释:**

这是 **CDDL (Common Development and Distribution License)** 许可证头

表明文件遵循开源许可证

1）Sun Microsystems（2008年）版权所有

````
CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License (the "License").
# You may not use this file except in compliance with the License.
#
# You can obtain a copy of the license at usr/src/OPENSOLARIS.LICENSE
# or http://www.opensolaris.org/os/licensing.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at usr/src/OPENSOLARIS.LICENSE.
# If applicable, add the following below this CDDL HEADER, with the
# fields enclosed by brackets "[]" replaced with your own identifying
# information: Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
# Copyright 2008 Sun Microsystems, Inc.  All rights reserved.
# Use is subject to license terms.
#
````

2）全局变量设置

````
set $dir=/tmp          # 测试目录路径：/tmp
set $nfiles=10000      # 创建的文件总数：10,000个
set $meandirwidth=20   # 目录宽度（每个子目录平均包含20个文件）
set $filesize=cvar(type=cvar-gamma,parameters=mean:131072;gamma:1.5)  
# 文件大小：伽马分布，平均131,072字节（128KB），gamma形状参数1.5

set $nthreads=50       # 并发线程数：50个
set $iosize=1m         # I/O操作大小：1MB
set $meanappendsize=16k # 追加写入的平均大小：16KB
set $runtime=60        # 测试运行时间：60秒
````

3）定义文件集

````
define fileset name=bigfileset,path=$dir,size=$filesize,entries=$nfiles,dirwidth=$meandirwidth,prealloc=80
````

创建一个名为 `bigfileset` 的文件集：

- 路径：`/tmp`
- 文件大小：按伽马分布（128KB平均）
- 文件数量：10,000个
- 目录结构：每目录约20个文件
- 预分配：80%（创建时预分配80%空间）

4）定义工作进程和线程

````
define process name=filereader,instances=1 {
  thread name=filereaderthread,memsize=10m,instances=$nthreads {
    # 每个线程的操作序列
  }
}
````

1个进程，包含50个线程

每个线程分配10MB内存

5）线程操作序列（工作负载模式）

每个线程按顺序执行以下操作：

````
flowop createfile name=createfile1,filesetname=bigfileset,fd=1
# 1. 创建文件（使用文件描述符fd=1）

flowop writewholefile name=wrtfile1,srcfd=1,fd=1,iosize=$iosize
# 2. 写入整个文件（1MB）

flowop closefile name=closefile1,fd=1
# 3. 关闭文件

flowop openfile name=openfile1,filesetname=bigfileset,fd=1
# 4. 重新打开文件

flowop appendfilerand name=appendfilerand1,iosize=$meanappendsize,fd=1
# 5. 随机追加写入（平均16KB）

flowop closefile name=closefile2,fd=1
# 6. 关闭文件

flowop openfile name=openfile2,filesetname=bigfileset,fd=1
# 7. 再次打开文件

flowop readwholefile name=readfile1,fd=1,iosize=$iosize
# 8. 读取整个文件（1MB）

flowop closefile name=closefile3,fd=1
# 9. 关闭文件

flowop deletefile name=deletefile1,filesetname=bigfileset
# 10. 删除文件

flowop statfile name=statfile1,filesetname=bigfileset
# 11. 文件状态查询（stat操作）
````

6）加载提示和运行

````
echo "File-server Version 3.0 personality successfully loaded"
# 显示加载成功的消息

run $runtime
# 运行测试60秒
````

编辑 WML 脚本，设置全局变量后，执行测试

````
$ filebench -f custom.f
Filebench Version 1.5-alpha3
0.001: Allocated 177MB of shared memory
0.070: File-server Version 3.0 personality successfully loaded
0.073: Populating and pre-allocating filesets
0.316: bigfileset populated: 10000 files, avg. dir. width = 20, avg. dir. depth = 3.1, 0 leafdirs, 1240.757MB total size
0.319: Removing bigfileset tree (if exists)
0.385: Pre-allocating directories in bigfileset tree
0.817: Pre-allocating files in bigfileset tree
16.702: Waiting for pre-allocation to finish (in case of a parallel pre-allocation)
16.703: Population and pre-allocation of filesets completed
16.706: Starting 1 filereader instances
17.801: Running...
78.079: Run took 60 seconds...
78.086: Per-Operation Breakdown
statfile1            90383ops     1499ops/s   0.0mb/s    0.151ms/op [0.093ms - 6.326ms]
deletefile1          90381ops     1499ops/s   0.0mb/s    0.924ms/op [0.277ms - 13.677ms]
closefile3           90383ops     1499ops/s   0.0mb/s    0.036ms/op [0.023ms - 2.958ms]
readfile1            90384ops     1500ops/s 196.6mb/s    0.453ms/op [0.058ms - 9.411ms]
openfile2            90384ops     1500ops/s   0.0mb/s    0.265ms/op [0.157ms - 6.657ms]
closefile2           90384ops     1500ops/s   0.0mb/s    0.039ms/op [0.024ms - 4.100ms]
appendfilerand1      90384ops     1500ops/s  11.7mb/s    0.182ms/op [0.001ms - 8.773ms]
openfile1            90384ops     1500ops/s   0.0mb/s    0.284ms/op [0.175ms - 15.464ms]
closefile1           90384ops     1500ops/s   0.0mb/s    0.047ms/op [0.027ms - 4.345ms]
wrtfile1             90386ops     1500ops/s 185.3mb/s    1.466ms/op [0.096ms - 10.989ms]
createfile1          90390ops     1500ops/s   0.0mb/s    1.098ms/op [0.599ms - 9.636ms]
78.089: IO Summary: 994227 ops 16494.724 ops/s 1500/2999 rd/wr 393.7mb/s 0.450ms/op
78.089: Shutting down processes
````

解析以上测试结果：

分项操作性能

````
statfile1            90383ops     1499ops/s   0.0mb/s    0.151ms/op [0.093ms - 6.326ms]
deletefile1          90381ops     1499ops/s   0.0mb/s    0.924ms/op [0.277ms - 13.677ms]
closefile3           90383ops     1499ops/s   0.0mb/s    0.036ms/op [0.023ms - 2.958ms]
readfile1            90384ops     1500ops/s 196.6mb/s    0.453ms/op [0.058ms - 9.411ms]
openfile2            90384ops     1500ops/s   0.0mb/s    0.265ms/op [0.157ms - 6.657ms]
closefile2           90384ops     1500ops/s   0.0mb/s    0.039ms/op [0.024ms - 4.100ms]
appendfilerand1      90384ops     1500ops/s  11.7mb/s    0.182ms/op [0.001ms - 8.773ms]
openfile1            90384ops     1500ops/s   0.0mb/s    0.284ms/op [0.175ms - 15.464ms]
closefile1           90384ops     1500ops/s   0.0mb/s    0.047ms/op [0.027ms - 4.345ms]
wrtfile1             90386ops     1500ops/s 185.3mb/s    1.466ms/op [0.096ms - 10.989ms]
createfile1          90390ops     1500ops/s   0.0mb/s    1.098ms/op [0.599ms - 9.636ms]
````

| 操作名          | 总次数   | 每秒次数(ops/s) | 吞吐量(MB/s) | 单次延迟(ms/op) [最小-最大延迟] | 说明       |
| --------------- | -------- | --------------- | ------------ | ------------------------------- | ---------- |
| statfile1       | 90383ops | 1499ops/s       | 0.0mb/s      | 0.151ms/op [0.093ms - 6.326ms]  | 获取属性   |
| deletefile1     | 90381ops | 1499ops/s       | 0.0mb/s      | 0.924ms/op [0.277ms - 13.677ms] | 删除文件   |
| closefile3      | 90383ops | 1499ops/s       | 0.0mb/s      | 0.036ms/op [0.023ms - 2.958ms]  | 关闭文件   |
| readfile1       | 90384ops | 1500ops/s       | 196.6mb/s    | 0.453ms/op [0.058ms - 9.411ms]  | 全文件读取 |
| openfile2       | 90384ops | 1500ops/s       | 0.0mb/s      | 0.265ms/op [0.157ms - 6.657ms]  | 打开文件   |
| closefile2      | 90384ops | 1500ops/s       | 0.0mb/s      | 0.039ms/op [0.024ms - 4.100ms]  | 关闭文件   |
| appendfilerand1 | 90384ops | 1500ops/s       | 11.7mb/s     | 0.182ms/op [0.001ms - 8.773ms]  | 随机追加   |
| openfile1       | 90384ops | 1500ops/s       | 0.0mb/s      | 0.284ms/op [0.175ms - 15.464ms] | 打开文件   |
| closefile1      | 90384ops | 1500ops/s       | 0.0mb/s      | 0.047ms/op [0.027ms - 4.345ms]  | 关闭文件   |
| wrtfile1        | 90386ops | 1500ops/s       | 185.3mb/s    | 1.466ms/op [0.096ms - 10.989ms] | 全文件写入 |
| createfile1     | 90390ops | 1500ops/s       | 0.0mb/s      | 1.098ms/op [0.599ms - 9.636ms]  | 创建文件   |

全局汇总（最重要）

````
IO Summary: 994227 ops 16494.724 ops/s 1500/2999 rd/wr 393.7mb/s 0.450ms/op
````

`994227 ops`: 总操作次数

`16494.724 ops/s`: 全局综合IOPS

`1500/2999 rd/wr`: 读写配比

`393.7mb/s`: 总聚合吞吐量

`0.450ms/op`: 全局平均单次 IO 延迟

整体性能指标

| 指标              | 含义                         | 示例值                       | 评估要点                                 |
| :---------------- | :--------------------------- | :--------------------------- | :--------------------------------------- |
| **总操作数**      | 测试期间所有操作的总和       | 994,227 ops                  | 结合运行时间可计算平均吞吐               |
| **总吞吐 (IOPS)** | 每秒完成的操作总数           | 16,495 ops/s                 | 越高越好，反映系统并发处理能力           |
| **读写带宽**      | 读/写/追加操作的数据传输速率 | 读 196.6 MB/s，写 185.3 MB/s | 反映大块数据传输能力，通常与 IOPS 结合看 |
| **平均延迟**      | 所有操作的平均响应时间       | 0.450 ms/op                  | 越低越好，影响用户体验                   |
| **读写比例**      | 读操作与写操作的数量比       | 1500/2999 (约1:2)            | 负载特征，影响优化方向                   |

操作级关键指标

Filebench 会为每种定义的 `flowop` 输出单独的性能数据，重点关注：

| 指标             | 含义                 | 示例                                   | 评估要点                                            |
| :--------------- | :------------------- | :------------------------------------- | :-------------------------------------------------- |
| **操作名**       | 具体的文件操作类型   | `readfile1`, `wrtfile1`, `createfile1` | 不同操作的性能差异很大                              |
| **操作数**       | 该操作执行的总次数   | 90,386 ops                             | 应接近总操作数/操作种类，若差异大可能表示负载不均衡 |
| **吞吐 (ops/s)** | 该操作的每秒执行次数 | 1,500 ops/s                            | 与总吞吐一致时表示操作分布均匀                      |
| **带宽 (MB/s)**  | 该操作的数据传输速率 | 196.6 MB/s                             | 仅对有数据传输的操作有意义                          |
| **平均延迟**     | 该操作的平均响应时间 | 0.453 ms                               | 关键性能指标，元数据操作通常比数据操作延迟低        |
| **延迟范围**     | 最小到最大延迟       | [0.058ms – 9.411ms]                    | 反映延迟稳定性，尾延迟（最大）对实时应用重要        |












### 1. 概述

Syzkaller是由Google开发的一款自动化内核模糊测试（Fuzz Testing）工具，专注于发现操作系统内核中的漏洞（如内存泄漏、空指针引用、死锁等）。它通过生成随机的系统调用序列和参数输入，监测内核运行状态（如崩溃或异常），实现对内核代码路径的高覆盖率测试。

从架构上看，**Syzkaller包含三个核心组件**：

- syz-manager作为主控进程运行在主机上，负责管理虚拟机实例和整体调度；
- syz-fuzzer运行在虚拟机中，负责实际的模糊测试过程；
- syz-executor作为执行单元，负责执行具体的系统调用序列。

**工作原理**：

- **覆盖引导**：利用内核的`KCOV`（内核覆盖率）特性收集代码执行路径，指导测试用例生成。
- **动态变异**：基于代码覆盖率反馈，动态调整系统调用序列和参数，探索更深层的内核状态。
- **漏洞检测**：结合`KASAN`（内核地址消毒器）检测内存错误，并通过崩溃日志定位问题。

### 2. 安装与使用

#### 2.1 安装

**安装依赖与编译 Syzkaller：**

在openEuler riscv64环境中搭建 Syzkaller 以测试 RISC-V 虚拟机，需要准备 Go 环境、Syzkaller 源码、RISC-V 交叉编译工具链

```
# 安装go环境及交叉编译工具链
dnf install -y gcc gcc-c++ make cmake automake autoconf git gdb glibc-devel libstdc++-devel binutils patch diffutils pkgconf libstdc++-static go
# 获取并编译syzkaller
git clone https://github.com/google/syzkaller.git
cd syzkaller
make TARGETOS=linux TARGETARCH=riscv64
```

**准备 RISC-V Linux 内核：**
需编译一个启用了调试和 KCOV 选项的 RISC-V 内核镜像（Image）。

以在ubuntu x86环境下编译openEuler kernel内核为例（内核参数参考：https://github.com/google/syzkaller/blob/master/docs/linux/kernel_configs.md）。

```
# 下载编译工具
sudo apt update
sudo apt install -y \
    gcc-riscv64-linux-gnu \
    binutils-riscv64-linux-gnu \
    build-essential bison flex libssl-dev libelf-dev bc cpio dwarves qemu-system-misc clang llvm lld
git clone https://atomgit.com/openeuler/kernel.git
cd kernel && git checkout openEuler-24.03-LTS-SP3
# 生成默认配置
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- defconfig 

```

syzkaller 所需的功能主要是启用`KCOV`来收集内核覆盖，并启用`KASAN`来检测内存错误。

修改内核配置，通过`scripts/config`启用所需选项，以便于让内核更好的被 Fuzz。

```
./scripts/config --enable KCOV
./scripts/config --enable KASAN   #在openEuler-24.03-LTS-SP3分支下开启该参数编译报错，可以下载kernel-source软件包解压源码后进行编译
./scripts/config --enable KASAN_INLINE
./scripts/config --enable DEBUG_INFO_DWARF4
./scripts/config --enable DEBUG_FS
./scripts/config --enable CONFIG_BINFMT_MISC
./scripts/config --enable CONFIG_NAMESPACES
./scripts/config --enable CONFIG_NET_NS
./scripts/config --disable CONFIG_DEBUG_INFO_BTF

```

重新生成配置文件并编译：

```
#修改完成后更新配置
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- olddefconfig
# 编译
make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- clean && make ARCH=riscv CROSS_COMPILE=riscv64-linux-gnu- -j$(nproc) Images
```

编译后会生成以下文件：

-  `bzImage`：经过压缩的可启动内核镜像，位于`arch/riscv64/boot`目录中相应架构的目录下。 

-  `vmlinux`：带有调试符号的未压缩内核镜像。 

#### 2.2 基础命令

Syzkaller 的核心运行依赖于配置文件（JSON 格式）和命令行工具。

**启动 Fuzzer：**

```
./bin/syz-manager -config riscv64_qemu.cfg
```

**常用辅助工具：**

- `syz-executor`: 实际在 RISC-V 虚拟机内执行系统调用的二进制程序，编译时需指定 `TARGETARCH=riscv64`。
- `syz-repro`: 用于根据日志或 crash 信息复现 Bug。

```
./bin/syz-repro -config riscv64_qemu.cfg crash_log.txt
```

#### 2.3 配置文件

Syzkaller 的配置文件（通常为config.json）是整个Fuzzing流程的核心，官方提供了详细的配置说明文档（[https://github.com/google/syzkaller/blob/master/docs/configuration.md](https://github.com/google/syzkaller/blob/master/docs/configuration.md?spm=5176.28103460.0.0.96a029880zcwq8&file=configuration.md)）。syzkaller 的配置分为**顶层全局参数**和 **`vm` 子对象参数**。`vm` 内部的可用字段完全取决于 `type` 的值（例如 `qemu` 和 `none` 的 `vm` 参数完全不同）。

##### 2.3.1 顶层全局参数

| 参数               | 必填 | 说明                                                         |
| ------------------ | ---- | ------------------------------------------------------------ |
| `target`           | ✅    | 目标架构，格式为 `OS/Arch`，如 `linux/riscv64`, `linux/amd64` |
| `http`             | ✅    | Web Dashboard 监听地址，如 `:56789`                          |
| `workdir`          | ✅    | 工作目录，存储 corpus.db、crashes、logs 等持久化数据         |
| `kernel_obj`       | ✅    | 内核编译输出目录（包含 vmlinux/bzImage 及调试符号）          |
| `syzkaller`        | ✅    | syzkaller 安装根目录路径                                     |
| `type`             | ✅    | VM/设备管理类型：`qemu`, `none`, `gce`, `aws`, `adb`, `containers`, `ssh` |
| `vm`               | ✅    | VM/设备特定配置对象（见下方）                                |
| `procs`            | ❌    | 每个 VM 中并行运行的 executor 进程数（默认 1，推荐 4-8）     |
| `cover`            | ❌    | 是否启用覆盖率收集（默认 true，内核需开启 CONFIG_KCOV）      |
| `reproduce`        | ❌    | 是否自动复现 crash（`type: none` 时必须为 false）            |
| `sandbox`          | ❌    | 沙箱模式：`none`, `setuid`, `namespace`, `android`（默认 namespace） |
| `enable_syscalls`  | ❌    | 白名单，仅 fuzz 指定的系统调用列表                           |
| `disable_syscalls` | ❌    | 黑名单，排除指定的系统调用                                   |
| `suppressions`     | ❌    | 抑制规则文件路径，忽略已知的误报或无关 crash                 |
| `ignores`          | ❌    | 忽略规则文件路径，完全跳过匹配的 crash                       |
| `rpc`              | ❌    | RPC 监听端口，供外部 executor 连接（`type: none` 时必填）    |
| `dashboard_client` | ❌    | 上报到 syz-dashboard 的配置（密钥、API 端点等）              |
| `asset_storage`    | ❌    | 外部资产存储后端配置（S3/GCS 等）                            |
| `experimental`     | ❌    | 实验性功能开关对象                                           |

##### 2.3.2 **`vm` 子对象参数（按 type 分类）**

**type：qemu**

| 参数        | 说明                                                |
| ----------- | --------------------------------------------------- |
| `count`     | QEMU 实例数量                                       |
| `kernel`    | 内核镜像路径（bzImage/Image）                       |
| `image`     | 根文件系统磁盘镜像路径                              |
| `cmdline`   | 附加内核命令行参数                                  |
| `qemu_args` | 传递给 QEMU 的额外命令行参数                        |
| `cpu`       | CPU 型号（可选）                                    |
| `mem`       | 内存大小 MB（可选）                                 |
| `snapshot`  | 是否使用临时快照（默认 true，每次重启恢复干净状态） |

**`type: none`**

| 参数         | 说明                                                         |
| ------------ | ------------------------------------------------------------ |
| *(通常为空)* | `type: none` 不需要也不接受 VM 管理参数。executor 通过 `rpc` 端口主动连接到 manager。你的 LAVA 环境中只需确保 executor 启动时指向正确的 `manager_ip:rpc_port` 即可。 |

#### 2.4 执行扫描

 在 Syzkaller 中，`type` 字段决定了 Manager 如何启动和管理测试实例。针对测试 RISC-V 虚拟机的场景，`qemu` 和 `none` 是两种最常用但定位完全不同的模式。

##### 2.4.1 全自动托管模式（type: qemu）

这是 Syzkaller 的标准推荐模式。Manager 完全接管 QEMU 虚拟机的生命周期，包括启动、快照恢复、串口日志捕获、覆盖率收集以及崩溃后的自动重启。

配置示例（config.json）:

```
{
    "name": "riscv64-qemu",
    "target": "linux/riscv64",
    "http": "0.0.0.0:56741",
    "rpc": "0.0.0.0:42173",
    "workdir": "/root/syzkaller/workdir",  
    "kernel_obj": "/root/kernel",  #
    "sshkey": "/root/.ssh/id_rsa",
    "ssh_user": "root",
    "image": "/root/openeuler-rootfs.img",
    "syzkaller": "/root/syzkaller",
    "type": "qemu",
    "vm": {
        "count": 2,
        "cpu": 8,
        "mem": 8192,
        "kernel": "/root/kernel/arch/riscv/boot/Image",
        "cmdline": "root=/dev/vda rw console=ttyS0 earlycon=sbi selinux=0",
        "qemu_args": "-machine virt" 
    }
}

```

配置编写完成后，执行命令`./bin/syz-manager --config=config`执行模糊测试，测试运行流程如下：

1. Manager 启动后，会根据 `vm.count` 拉起对应数量的 `qemu-system-riscv64` 进程。
2. Syzkaller 将编译好的 `syz-executor` (riscv64 ELF) 通过 9p 文件系统或 SSH 传输至虚拟机内。
3. Manager 生成 syscall 序列，发送给 VM 内的 executor 执行。
4. Executor 返回执行结果和覆盖率数据，Manager 据此变异生成新的测试用例。
5. 若触发 Kernel Panic，QEMU 串口输出会被 Manager 捕获并解析为 Crash Report。

用户可在web页面端输入http://<ip地址>:<http端口>来查看服务的运行情况。

##### 2.4.2  外部手动管理模式（type: none）

在此模式下，Syzkaller Manager **不启动任何虚拟机**，仅作为调度中心和语料库管理器。用户需自行在外部启动 RISC-V 环境（QEMU、真实开发板或容器），并在其中手动运行 `syz-executor` 连接到 Manager。

配置示例 (`config.json`)：

```
{
  "target": "linux/riscv64",
  "http": ":56789",
  "workdir": "/root/syzkaller/workdir/",
  "kernel_obj": "/usr/src/linux-6.6.0-138.0.0.121.oe2403sp3.riscv64",
  "syzkaller": "/root/syzkaller",
  "procs": 1,
  "type": "none",
  "sandbox": "none",
  "cover": true,
  "reproduce": false,
  "rpc": ":40697"
}

```

手动执行步骤：

(1) 先启动 Manager：`./bin/syz-manager -config config.json`

(2) 再运行 Executor：`./syz-executor runner 0 <MANAGER_IP> <RPC_PORT>`

(3) Executor 会主动连接 Manager 并请求测试任务，执行结果实时回传。

#### 2.5 结果评估

Syzkaller 的测试结果主要通过 Web Dashboard（默认 `http://<ip地址>:<http端口>`）和文件系统呈现。

| 指标/状态       | 描述                                    | 关注点                                                       |
| --------------- | --------------------------------------- | ------------------------------------------------------------ |
| Crashes         | 发现的内核崩溃总数及去重后的唯一 Bug 数 | 重点关注 "reproduced" 状态的 Bug                             |
| Coverage        | 当前达到的代码覆盖率（基本块/边数量）   | 覆盖率增长曲线是否趋于平稳                                   |
| Corpus          | 有效测试用例集合的大小                  | Corpus 持续增长表示 Fuzzer 仍在探索新路径                    |
| Executor Status | 虚拟机内执行器的健康状态                | 若频繁出现 "lost connection" 或 "executor not responding"，需检查 RISC-V 内核稳定性或 QEMU 配置 |
| Reproduction    | Bug 复现成功率                          | 未复现的 Bug 可能是瞬态错误或环境依赖问题                    |

**Crash 报告关键字段：**

- `HEADLINE`: 错误摘要（如 `BUG: unable to handle kernel paging request`）
- `STACK TRACE`: 内核调用栈，定位问题代码位置
- `SYZ REPRO`: 自动生成的 C 语言或 syzlang 复现脚本
- `BISect LOG`: （若启用）自动二分查找引入该 Bug 的 commit

#### 2.6 问题定位与优化

##### 2.6.1 覆盖率反馈失效

**现象：** Dashboard 显示 Coverage 始终为 0 或不增长。
**排查步骤：**

1. 确认 RISC-V 内核已开启 `CONFIG_KCOV=y` 且编译无警告。
2. 检查 QEMU 版本是否支持 RISC-V 的 KCOV 覆盖率导出。若不支持，需在 Syzkaller 配置中切换为 `"cover": false` 进行盲测，或使用 Syzkaller 提供的 QEMU 插件方案。
3. 验证虚拟机内 `/sys/kernel/debug/kcov` 节点是否存在且可读。

##### 2.6.2 虚拟机启动失败或连接超时

**现象：** Manager 日志报 `failed to boot VM` 或 `SSH connection refused`。
**排查步骤：**

1. 手动使用配置中的 `qemu_args` 和 `kernel` 启动 QEMU，确认能正常进入 Shell。
2. 检查 rootfs 镜像是否包含必要的网络配置或 9p 挂载支持。
3. 确认 `syz-executor` 已成功编译为 RISC-V 64 位架构（使用 `file bin/linux_riscv64/syz-executor` 验证）。

##### 2.6.3 审查与调试测试用例

当需要人工分析某个特定 Crash 或验证修复效果时，可使用复现模式。

**手动复现单个 Bug：**

```
# 使用自动生成的 repro.c 在本地 QEMU 中验证
./bin/syz-repro -config riscv64_qemu.cfg -debug crash_log.txt
```

**导出语料库供离线分析：**

```
# 导出当前 corpus 为文本格式
./bin/syz-db dump -os linux -arch riscv64 workdir/corpus.db > corpus_dump.txt
```

参考：

（1）https://github.com/google/syzkaller/blob/master/docs/linux/setup_linux-host_qemu-vm_riscv64-kernel.md

（2）[Syzkaller内核模糊测试技术详解与实战-先知社区](https://xz.aliyun.com/news/19324)

（3）[Syzkaller部署、使用与原理分析-CSDN博客](https://blog.csdn.net/IronmanJay/article/details/142415369)


# riscv-arch-test测试套件ACT4测试流程

### 1. 介绍

riscv-arch-test 项目地址: https://github.com/riscv/riscv-arch-test

riscv-arch-test (简称 ACT) 是一个指令集兼容性验证工具，主要用于在处理器设计初期或移植过程中，通过编写测试集来验证设计是否正确实现了 RISC-V 规范。

本文使用仓库提供的 QEMU 配置进行测试。实体 DUT 也可以接入，但需要自行提供与 DUT 匹配的配置、链接脚本、`rvmodel_macros.h` 和运行命令。

### 2. 名词解释以及背景知识

- udb: [riscv-unified-db](https://github.com/riscv/riscv-unified-db)

在 act 项目下 sail 有两个含义，即指 sail 语言本身，也指用 sail 编写出来的 sail_riscv_sim 模拟器

- sail: 指 https://github.com/rems-project/sail ，一门 ISA 编程语言

- sail_riscv_sim: 指 https://github.com/riscv/sail-riscv ，用 sail 语言编写的 riscv 模型，也是一个模拟器

- DUT: 被测设备


### 3. 测试步骤

系统: ubuntu 24.04
架构: amd64 (udb docker 镜像没有 riscv 架构)

#### 3.1 安装依赖

```
sudo apt-get update
sudo apt-get install make git build-essential
```

#### 3.2 安装 mise

安装 mise 并且更新 PATH

```
curl https://mise.jdx.dev/install.sh | sh
eval "$(~/.local/bin/mise activate bash)"
echo "eval \"\$(~/.local/bin/mise activate bash)\"" >> ~/.bashrc
```

用 mise --version 测试是否安装成功
```
# mise --version
2026.7.17 linux-x64 (2026-07-30)
```


#### 3.2 安装 riscv-gnu-toolchain

```
wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2025.07.16/riscv64-elf-ubuntu-22.04-gcc-nightly-2025.07.16-nightly.tar.xz
tar xJf riscv64-elf-ubuntu-22.04-gcc-nightly-2025.07.16-nightly.tar.xz --directory=/usr/local --strip-components=1
```

用 riscv64-unknown-elf-gcc --version 测试是否安装成功

```
# riscv64-unknown-elf-gcc --version
riscv64-unknown-elf-gcc () 15.1.0
Copyright (C) 2025 Free Software Foundation, Inc.
This is free software; see the source for copying conditions.  There is NO
warranty; not even for MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
```

#### 3.3 安装 sail model

```
wget https://github.com/riscv/sail-riscv/releases/download/0.10/sail-riscv-Linux-x86_64.tar.gz
tar xf ./sail-riscv-Linux-x86_64.tar.gz --directory=/usr/local --strip-components=1
 --version
```

用 sail_riscv_sim --version 测试是否安装成功

```
# sail_riscv_sim --version
0.10
```

### 3.4 运行 QEMU 测试

当前 ACT4 已内置 QEMU 配置和运行命令，内置的测试流程大概为：先用 Sail 生成期望签名、编译自检 ELF，再用 `qemu-system-riscv64 -bios <elf>` 执行。

#### 3.4.1 安装 QEMU


```
sudo apt-get install -y qemu-system-misc
```

检查 qemu-system-riscv64 是否安装成功

```
qemu-system-riscv64 --version
```


#### 3.4.2 运行 RV64I 最小验证


```
git clone https://github.com/riscv/riscv-arch-test --branch=4.0.0
cd riscv-arch-test
mise trust .mise.toml
env -u DEBUG make qemu-rv64-max EXTENSIONS=I FAST=True --jobs "$(nproc)"
```

`EXTENSIONS=I` 指定了 I 指令集，代表这次测试仅运行了一次 I 指令集的快速验证。如果测试成功，会生成并运行 51 个 ELF，并且打印：

```
RESULT: All 51 tests passed.
```

`env -u DEBUG` 用于清理 `DEBUG` 环境变量，避免外部环境中存在的非空 `DEBUG` 变量意外开启 ACT4 调试模式。

`FAST=True` 用于跳过 objdump 生成，可以快速进行测试验证。

#### 3.4.3 运行 qemu-RVI20U64 大型测试套

运行 `qemu-RVI20U64` 测试套：

```bash
make clean
env -u DEBUG make qemu-RVI20U64 EXCLUDE_EXTENSIONS=Zalrsc,Zicntr FAST=True --jobs "$(nproc)"
```

`make clean` 可避免之前生成的 ELF 混入本次测试。

qemu-RVI20U64 测试套生成的 ELF 位于 `work/qemu-RVI20U64/elfs`，单项日志位于 `work/qemu-RVI20U64/logs`，汇总结果位于 `work/qemu-RVI20U64/summary.log`。

由于测试套中 `Zalrsc` 和 `Zicntr` 这两个指令集无法测试通过，先暂时用 `EXCLUDE_EXTENSIONS` 环境变量跳过。

剩余的其他指令集都可以测试通过:

```text
RESULT: All 342 tests passed.
```

单个指令集测试通过时，在 logs 和 summary.log 中的日志如下：

```
RVCP-SUMMARY: TEST PASSED - Test File "<test_name>.S"
```

#### 3.4.4 单独运行已生成的 ELF


若只需重新执行已生成的 ELF，不必重新编译，使用 run_tests.py 重新执行即可，qemu 的参数可以从 config/qemu/qemu-RVI20U64/run_cmd.txt 中读取

```
# ./run_tests.py "$(cat config/qemu/qemu-RVI20U64/run_cmd.txt)" work/qemu-RVI20U64/elfs

══════ qemu-RVI20U64 ══════
  Running ELFs from: /root/riscv-arch-test/work/qemu-RVI20U64/elfs
  Using command: qemu-system-riscv64 -nographic -semihosting -icount shift=1 -machine virt -cpu rv64,zicsr=true,zifencei=true,zicntr=true,pmu-mask=0xfffffff8 -bios <elf_path>
  Summary available at: /root/riscv-arch-test/work/qemu-RVI20U64/summary.log

  RESULT: All 342 tests passed.
```

单个 qemu-system-riscv64 运行 RV64 ELF 的命令如下，其中 ELF 路径必须紧随 `-bios`：

```
# qemu-system-riscv64 -nographic -semihosting -icount shift=1 -machine virt -cpu rv64,zicsr=true,zifencei=true,zicntr=true,pmu-mask=0xfffffff8 -bios work/qemu-RVI20U64/elfs/rv64i/I/I-add-00.elf

RVCP-SUMMARY: TEST PASSED - Test File "I-add-00.S"

```


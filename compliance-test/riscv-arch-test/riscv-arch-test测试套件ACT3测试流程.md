# riscv-arch-test测试套件ACT4测试流程

### 1. 介绍

riscv-arch-test 项目地址: https://github.com/riscv-non-isa/riscv-arch-test

riscv-arch-test (简称 ACT) 是一个指令集兼容性验证工具，主要用于在处理器设计初期或移植过程中，通过编写测试集来验证设计是否正确实现了 RISC-V 规范。

目前支持的设备有 sail, spike，不支持 QEMU 和开发板

### 2. 名词解释以及背景知识

- act4: riscv-arch-test 4.x 版本，分支为 act4，是目前主要的开发分支，和 act3 分支的区别是依赖更加清晰，测试用例也不再依赖外部而是由 act 本身实现，仅依赖 udb 一个数据库

- act3: riscv-arch-test 3.x 版本，分支为 dev，和 act4 的区别是 act3 借用 riscof 的测试用例，但依赖非常复杂，经常有报错冲突

- udb: [riscv-unified-db](https://github.com/riscv/riscv-unified-db/)

- spike: [riscv-isa-sim](https://github.com/riscv/riscv-isa-sim)，一个模拟器

在 act 项目下 sail 有两个含义，即指 sail 语言本身，也指用 sail 编写出来的 sail_riscv_sim 模拟器

- sail: 指 https://github.com/rems-project/sail ，一门 ISA 编程语言

- sail_riscv_sim: 指 https://github.com/riscv/sail-riscv ，用 sail 语言编写的 riscv 模型，也是一个模拟器

- HTIF: 对于 spike 模拟器，测试用例通过后会打印一行 pass ，打印就是使用 HTIF， qemu 暂时还不支持 HTIF

- DUT: 被测设备


### 3. 测试步骤

系统: ubuntu 24.04
架构: amd64 或者 arm64

关于文档：建议跟着 github actions 快速跑起来之后，再转过头去看 readme 里边的细节。act3 的 CI 自从 2025 年 11 月开始就已经损坏了，依赖比较复杂很难跑通，建议选择更活跃、依赖更简洁的 ACT4 分支  

#### 3.1 安装依赖

```
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv
sudo apt-get install -y gcc git autoconf automake libtool curl make unzip
sudo apt-get install -y autoconf automake autotools-dev curl python3 python3-pip libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev ninja-build git cmake libglib2.0-dev libslirp-dev pkg-config
sudo apt-get install -y device-tree-compiler libboost-regex-dev libboost-system-dev
```

#### 3.2 安装 uv

```
curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env
uv venv
source .venv/bin/activate
```

#### 3.2 安装 riscv-gnu-toolchain

```
wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2024.09.03/riscv64-elf-ubuntu-20.04-gcc-nightly-2024.09.03-nightly.tar.gz
tar xJf riscv64-elf-ubuntu-20.04-gcc-nightly-2024.09.03-nightly.tar.gz --directory=/usr/local --strip-components=1
```

#### 3.3 安装 riscof

```
cd ~
git clone https://github.com/riscv-software-src/riscof.git
cd riscof
uv pip install --editable .
```

#### 3.4 安装 riscv-config

```
cd ~
git clone https://github.com/riscv-software-src/riscv-config.git
cd riscv-config
uv pip install --editable .
```

#### 3.5 安装 riscv-isac

```
cd ~/
git clone https://github.com/riscv-non-isa/riscv-arch-test.git
cd riscv-arch-test/riscv-isac
uv pip install --editable .
```

#### 3.6 安装 riscv-ctg


```
cd ~/riscv-arch-test/riscv-ctg
uv pip install --editable .
```

#### 3.7 安装 spike

```
cd ~/
git clone https://github.com/riscv/riscv-isa-sim.git
cd riscv-isa-sim
mkdir build
cd build
../configure --prefix=/usr/local
make -j$(nproc)
make install
```

#### 3.8 安装 sail riscv

```
wget https://github.com/riscv/sail-riscv/releases/download/0.9/sail-riscv-Linux-x86_64.tar.gz
tar xf ./sail-riscv-Linux-x86_64.tar.gz --directory=/usr/local --strip-components=1
```


### 3.4 运行 riscof rv64 测试

```
cd ~/riscv-arch-test/riscof-plugins/rv64
riscof run --config config.ini --suite ../../riscv-test-suite/rv64i_m --env ../../riscv-test-suite/env
```

```
(riscof) root@v2202512251977419387:~/riscv-arch-test/riscof-plugins/rv64# riscof run --config config.ini --suite ../../riscv-test-suite/rv64i_m --env ../../riscv-test-suite/env
    INFO | ****** RISCOF: RISC-V Architectural Test Framework 1.25.3 *******
    INFO | using riscv_isac version : 0.18.0
    INFO | using riscv_config version : 3.20.0
    INFO | Reading configuration from: /root/riscv-arch-test/riscof-plugins/rv64/config.ini
    INFO | Preparing Models
    INFO | Checked ISA file already exists
    INFO | Input-Platform file
    INFO | Loading input file: /root/riscv-arch-test/riscof-plugins/rv64/spike_simple/spike_simple_platform.yaml
    INFO | Load Schema /root/riscv-config/riscv_config/schemas/schema_platform.yaml
    INFO | Initiating Validation
    INFO | No Syntax errors in Input Platform Yaml. :)
    INFO | Dumping out Normalized Checked YAML: /root/riscv-arch-test/riscof-plugins/rv64/riscof_work/spike_simple_platform_checked.yaml
    INFO | Generating database for suite: /root/riscv-arch-test/riscv-test-suite/rv64i_m
    INFO | Database File Generated: /root/riscv-arch-test/riscof-plugins/rv64/riscof_work/database.yaml
    INFO | Env path set to/root/riscv-arch-test/riscv-test-suite/env
    INFO | Running Build for DUT
    INFO | Running Build for Reference
    INFO | Selecting Tests.
    INFO | Running Tests on DUT.
    INFO | Running Tests on Reference Model.
    INFO | Initiating signature checking.
   ERROR | Signature file : /root/riscv-arch-test/riscof-plugins/rv64/riscof_work/A/src/amoadd.d-01.S/dut/DUT-spike.signature does not exist
```

目前会报错 DUT-spike.signature does not exist ，CI 上也是同样的报错，无法测试成功
# riscv-arch-test测试套件ACT4测试流程

### 1. 介绍

riscv-arch-test 项目地址: https://github.com/riscv-non-isa/riscv-arch-test

riscv-arch-test (简称 ACT) 是一个指令集兼容性验证工具，主要用于在处理器设计初期或移植过程中，通过编写测试集来验证设计是否正确实现了 RISC-V 规范。

目前 ACT4 支持的设备有 sail, cvw, spike，不支持实体板子，act4 分支有计划支持 QEMU 但目前还未支持。

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
架构: amd64 或者 arm64 (udb docker 镜像没有 riscv 架构)

关于文档：建议跟着 github actions 快速跑起来之后，再转过头去看 readme 里边的细节。

#### 3.1 安装依赖

```
sudo apt-get update
sudo apt-get install -y device-tree-compiler libboost-regex-dev build-essential libboost-system-dev git docker.io 
```

#### 3.2 安装 uv

```
curl -LsSf https://astral.sh/uv/install.sh | sh
```


#### 3.2 安装 riscv-gnu-toolchain

```
wget https://github.com/riscv-collab/riscv-gnu-toolchain/releases/download/2025.07.16/riscv64-elf-ubuntu-22.04-gcc-nightly-2025.07.16-nightly.tar.xz
tar xJf riscv64-elf-ubuntu-22.04-gcc-nightly-2025.07.16-nightly.tar.xz --directory=/usr/local --strip-components=1
```

#### 3.3 安装 sail model

```
wget https://github.com/riscv/sail-riscv/releases/download/0.9/sail-riscv-Linux-x86_64.tar.gz
tar xf ./sail-riscv-Linux-x86_64.tar.gz --directory=/usr/local --strip-components=1
```


#### 3.3 安装 spike

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

### 3.4 运行 spike rv64gc 测试


```
cd ~/
git clone https://github.com/riscv-non-isa/riscv-arch-test.git
cd riscv-arch-test
git checkout act4
DOCKER=1 EXTENSIONS=I,M,F,D,Zca,Zcf,Zcd,Zaamo,Zalrsc,Zifencei CONFIG_FILES="config/spike/spike-rv64-max/test_config.yaml" make spike-rv64 --jobs $(nproc)
```

```
# DOCKER=1 EXTENSIONS=I,M,F,D,Zca,Zcf,Zcd,Zaamo,Zalrsc,Zifencei CONFIG_FILES="config/spike/spike-rv64-max/test_config.yaml" make spike-rv64 -j24
make tests
make[1]: Entering directory '/root/riscv-arch-test'
make[1]: Nothing to be done for 'tests'.
make[1]: Leaving directory '/root/riscv-arch-test'
/root/.local/bin/uv run act config/spike/spike-rv64-max/test_config.yaml --workdir work --test-dir tests --extensions I,M,F,D,Zca,Zcf,Zcd,Zaamo,Zalrsc,Zifencei  
Makefiles generated in work
Run make -C work compile to build all tests.
make -C work compile
make[1]: Entering directory '/root/riscv-arch-test/work'
make -f common/Makefile-rv64i.mk compile
make[2]: Entering directory '/root/riscv-arch-test/work'
make[2]: Nothing to be done for 'compile'.
make[2]: Leaving directory '/root/riscv-arch-test/work'
make -C spike-rv64-max compile
make[2]: Entering directory '/root/riscv-arch-test/work/spike-rv64-max'
make[2]: Nothing to be done for 'compile'.
make[2]: Leaving directory '/root/riscv-arch-test/work/spike-rv64-max'
make[1]: Leaving directory '/root/riscv-arch-test/work'
./run_tests.py "spike --isa=rv64imafdcbv_zicbom_zicboz_zicbop_zicfilp_zicond_zicsr_zicclsm_zifencei_zihintntl_zihintpause_zihpm_zimop_zabha_zacas_zawrs_zfa_zfbfmin_zfh_zcb_zcmop_zbc_zkn_zks_zkr_zvfbfmin_zvfbfwma_zvfh_zvbb_zvbc_zvkg_zvkned_zvknha_zvknhb_zvksed_zvksh_zvkt_sscofpmf_smcntrpmf_sstc_svinval" work/spike-rv64-max/elfs

Running tests in /root/riscv-arch-test/work/spike-rv64-max/elfs with command: spike --isa=rv64imafdcbv_zicbom_zicboz_zicbop_zicfilp_zicond_zicsr_zicclsm_zifencei_zihintntl_zihintpause_zihpm_zimop_zabha_zacas_zawrs_zfa_zfbfmin_zfh_zcb_zcmop_zbc_zkn_zks_zkr_zvfbfmin_zvfbfwma_zvfh_zvbb_zvbc_zvkg_zvkned_zvknha_zvknhb_zvksed_zvksh_zvkt_sscofpmf_smcntrpmf_sstc_svinval:
        All 240 tests passed.
```

看到 `All 240 tests passed` 字样就是测试成功了。


项目结构随时会改动，spike 的 yaml 的路径可能会变动，可以参考最新的 github actions，用环境变量 CONFIG_FILES 指定 yaml 文件路径

也可以手动使用 spike 加载 elf 测试，查看是否有 PASSED 字样

```
# spike --isa=rv64i /root/riscv-arch-test/work/spike-rv64-max/elfs/rv64i/Zifencei/Zifencei-fence.i-00.elf

RVCP-SUMMARY: Test File "Zifencei-fence.i-00.S": PASSED
```


### 3.5 运行 qemu 测试(接入 lava)

虽然目前还不支持 qemu 和实体设备测试，不过相信在不久的将来 ACT4 将会支持 qemu，我们现在可以根据目前的 elfs 产物猜测到在 LAVA qemu 上测试的大概流程: 将编译出来的二进制通过 objcopy -O binary 复制为镜像, 通过 tftp 下发 kernel 的形式下发 elf 文件查看返回结果。

对于 qemu 本地测试更加方便，用 qemu-system-riscv64 -kernel 加载 elf 即可。 

```
# qemu-system-riscv64 -machine spike -serial stdio -display none -bios none -kernel ./Zifencei-fence.i-00.elf 
qemu-system-riscv64: HTIF tohost must be 8 bytes
```

这时遇到了一个经典的报错，这是因为 act 使用了 HTIF 打印 pass，HTIF 是一个被废弃的标准，QEMU 没有支持，不过我们简单的修改源码就可以修复这个报错

``` diff
diff --git a/config/spike/spike-rv64-max/model_test.h b/config/spike/spike-rv64-max/model_test.h
index 69230031..700a4672 100644
--- a/config/spike/spike-rv64-max/model_test.h
+++ b/config/spike/spike-rv64-max/model_test.h
@@ -8,8 +8,8 @@
 
 #define RVMODEL_DATA_SECTION \
         .pushsection .tohost,"aw",@progbits;                \
-        .align 8; .global tohost; tohost: .dword 0;         \
-        .align 8; .global fromhost; fromhost: .dword 0;     \
+        .align 8; .global tohost; tohost: .dword 0; .size tohost, 8; \
+        .align 8; .global fromhost; fromhost: .dword 0; .size fromhost, 8; \
         .popsection
 
 ##### STARTUP #####
```

make clean 重编之后 qemu-system-riscv64 再运行 elf 会进入卡住的状态，这就需要等待 act4 适配支持 qemu 了

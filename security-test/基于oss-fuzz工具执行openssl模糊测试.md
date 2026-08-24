# 基于oss\-fuzz工具执行openssl模糊测试

## 一、oss\-fuzz工具介绍

安全测试工具oss\-fuzz工具指导来源于google oss\-fuzz框架：[https://github\.com/google/oss\-fuzz](https://gitee.com/link?target=https%3A%2F%2Fgithub.com%2Fgoogle%2Foss-fuzz)

### 1\. 基本概念

- fuzz测试（模糊测试）是发现软件编程错误的著名技术。许多可检测的错误，如缓冲区溢出，可能会带来严重的安全隐患。谷歌通过部署guided in\-process fuzzing of Chrome components发现了数千个安全漏洞和稳定性漏洞，我们现在希望与开源社区共享这项服务。

- OSS Fuzz与核心基础设施计划（Core Infrastructure Initiative）和OpenSSF合作，旨在通过将现代模糊技术与可扩展的分布式执行相结合，使通用开源软件更加安全和稳定。不符合OSS Fuzz标准的项目（例如封闭源代码）可以运行自己的ClusterFuzz或ClusterFuzzLite实例。

- 支持libFuzzer、AFL\+\+和Honggfuzz这些fuzz引擎与Sanitizers以及ClusterFuzz（一种分布式fuzz执行环境和报告工具）相结合。

- 目前，OSS Fuzz支持C/C\+\+、Rust、Go、Python和Java/JVM代码。LLVM支持的其他语言也可以工作。OSS Fuzz支持对x86\_64和i386版本进行fuzz。

### 2. 安装与使用

#### 2\.1 环境准备



```Plain Text
# 安装git及docker工具
dnf install -y git docker-engine
# 下载oss-fuzz工具
git clone https://github.com/google/oss-fuzz.git
cd oss-fuzz
```

#### 2\.2 基础命令

infra/helper\.py是oss\-fuzz项目中的核心本地辅助脚本，它封装了构建、运行和调试Fuzzer所需的复杂Docker操作，其主要作用包括：构建Fuzzer、运行Fuzzer、复现和调试崩溃等，可通过python3 infra/helper\.py \-\-help 查看该脚本支持的容器与环境配置参数。

```SQL
[root@localhost oss-fuzz]# python3 infra/helper.py --help
usage: helper.py [-h]
                 {generate,build_image,build_fuzzers,fuzzbench_build_fuzzers,check_build,index,run_fuzzer,fuzzbench_run_fuzzer,fuzzbench_measure,coverage,introspector,download_corpora,reproduce,shell,run_clusterfuzzlite,pull_images,check-tests,check-replay}
                 ...

oss-fuzz helpers

positional arguments:
  {generate,build_image,build_fuzzers,fuzzbench_build_fuzzers,check_build,index,run_fuzzer,fuzzbench_run_fuzzer,fuzzbench_measure,coverage,introspector,download_corpora,reproduce,shell,run_clusterfuzzlite,pull_images,check-tests,check-replay}
    generate            Generate files for new project.
    build_image         Build an image.
    build_fuzzers       Build fuzzers for a project.
    check_build         Checks that fuzzers execute without errors.
    index               Index project.
    run_fuzzer          Run a fuzzer in the emulated fuzzing environment.
    coverage            Generate code coverage report for the project.
    introspector        Run a complete end-to-end run of fuzz introspector. This involves (1) building the fuzzers with ASAN; (2) running all fuzzers;
                        (3) building fuzzers with coverge; (4) extracting coverage; (5) building fuzzers using introspector
    download_corpora    Download all corpora for a project.
    reproduce           Reproduce a crash.
    shell               Run /bin/bash within the builder container.
    run_clusterfuzzlite
                        Run ClusterFuzzLite on a project.
    pull_images         Pull base images.
    check-tests         Checks run_test.sh for specific project.
    check-replay        Checks if the replay script works for a specific project.

options:
  -h, --help            show this help message and exit

```

- 构建基础镜像（build\_image）

拉取/构建项目所需的oss\-fuzz基础镜像，基本语法如：

```Plain Text
python3 infra/helper.py build_image [脚本参数] <project>
```

可通过python3 infra/helper\.py build\_image \-\-help命令查看该构建脚本支持的所有参数。

```SQL
# python3 infra/helper.py build_image --help
usage: helper.py build_image [-h] [--pull] [--architecture {i386,x86_64,aarch64,riscv64}] [--cache] [--no-pull] [--external] project

positional arguments:
  project

options:
  -h, --help            show this help message and exit
  --pull                Pull latest base image.
  --architecture {i386,x86_64,aarch64,riscv64}
  --cache               Use docker cache when building image.
  --no-pull             Do not pull latest base image.
  --external            Is project external?
```

- 构建Fuzzer（build\_fuzzers）

用于在构建的项目容器中编译项目及其Fuzz Target，基本语法如：

```Plain Text
python3 infra/helper.py build_fuzzers [脚本参数] <project>
```

可通过python3 infra/helper\.py build\_fuzzers \-\-help命令查看该构建脚本支持的所有参数。

```SQL
python3 infra/helper.py build_fuzzers --help
usage: helper.py build_fuzzers [-h] [--architecture {i386,x86_64,aarch64,riscv64}] [--engine {libfuzzer,afl,honggfuzz,centipede,none,wycheproof}]
                               [--sanitizer {address,none,memory,undefined,thread,coverage,introspector,hwaddress}] [-e E] [--external] [--mount_path MOUNT_PATH]
                               [--clean] [--no-clean]
                               project [source_path]

positional arguments:
  project
  source_path           path of local source

options:
  -h, --help            show this help message and exit
  --architecture {i386,x86_64,aarch64,riscv64}
  --engine {libfuzzer,afl,honggfuzz,centipede,none,wycheproof}
  --sanitizer {address,none,memory,undefined,thread,coverage,introspector,hwaddress}
                        the default is "address"
  -e E                  set environment variable e.g. VAR=value
  --external            Is project external?
  --mount_path MOUNT_PATH
                        path to mount local source in (defaults to WORKDIR)
  --clean               clean existing artifacts.
  --no-clean            do not clean existing artifacts (default).
```

- 运行Fuzzer（run\_fuzzer）

在本地容器中执行指定的Fuzz Target，支持传入语料库目录、运行时长、种子等参数，基本语法如：

```Plain Text
python3 infra/helper.py run_fuzzer [脚本参数] <project> <fuzzer_name> -- [引擎参数]
```

可通过python3 infra/helper\.py run\_fuzzer \-\-help命令查看该构建脚本支持的所有参数。

```SQL
# python3 infra/helper.py run_fuzzer --help
usage: helper.py run_fuzzer [-h] [--architecture {i386,x86_64,aarch64,riscv64}] [--engine {libfuzzer,afl,honggfuzz,centipede,none,wycheproof}]
                            [--sanitizer {address,none,memory,undefined,thread,coverage,introspector,hwaddress}] [-e E] [--base-image-tag BASE_IMAGE_TAG] [--external]
                            [--corpus-dir CORPUS_DIR]
                            project fuzzer_name [fuzzer_args ...]

positional arguments:
  project               name of the project or path (external)
  fuzzer_name           name of the fuzzer
  fuzzer_args           arguments to pass to the fuzzer

options:
  -h, --help            show this help message and exit
  --architecture {i386,x86_64,aarch64,riscv64}
  --engine {libfuzzer,afl,honggfuzz,centipede,none,wycheproof}
  --sanitizer {address,none,memory,undefined,thread,coverage,introspector,hwaddress}
                        the default is "address"
  -e E                  set environment variable e.g. VAR=value
  --base-image-tag BASE_IMAGE_TAG
                        The tag of the base-runner image to use.
  --external            Is project external?
  --corpus-dir CORPUS_DIR
                        directory to store corpus for the fuzz target
```

引擎参数可通过 python3 infra/helper\.py run\_fuzzer \<project\> \<fuzzer\_name\> \-\- \-help=1 命令查看引擎支持的所有参数，可以放在\-\- 之后，透传给libFuzzer/AFL等

```Plain Text
# 以openssl项目的x509_30为例
[root@localhost oss-fuzz]# python3 infra/helper.py run_fuzzer openssl x509_30 -- -help=1
INFO:__main__:Running: docker run --privileged --shm-size=2g --platform linux/amd64 --rm -i -e FUZZING_ENGINE=libfuzzer -e SANITIZER=address -e RUN_FUZZER_MODE=interactive -e HELPER=True -v /root/oss-fuzz/build/out/openssl:/out -t gcr.io/oss-fuzz-base/base-runner:latest run_fuzzer x509_30 -help=1.
Using seed corpus: x509_30_seed_corpus.zip
/out/x509_30 -- -rss_limit_mb=2560 -timeout=25 -help=1 /tmp/x509_30_corpus -dict=x509_30.dict < /dev/null
INFO: libFuzzer ignores flags that start with '--'
Usage:

To run fuzzing pass 0 or more directories.
/out/x509_30 [-flag1=val1 [-flag2=val2 ...] ] [dir1 [dir2 ...] ]

To run individual tests without fuzzing pass 1 or more files:
/out/x509_30 [-flag1=val1 [-flag2=val2 ...] ] file1 [file2 ...]

Flags: (strictly in form -flag=value)
 verbosity                                   1        Verbosity level.
 seed                                        0        Random seed. If 0, seed is generated.
 runs                                        -1        Number of individual test runs (-1 for infinite runs).
 max_len                                     0        Maximum length of the test input. Contents of corpus files are going to be truncated to this value. If 0, libFuzzer tries to guess a good value based on the corpus and reports it.
 len_control                                 100        Try generating small inputs first, then try larger inputs over time.  Specifies the rate at which the length limit is increased (smaller == faster).  If 0, immediately try inputs with size up to max_len. Default value is 0, if LLVMFuzzerCustomMutator is used.
 seed_inputs                                 0        A comma-separated list of input files to use as an additional seed corpus. Alternatively, an "@" followed by the name of a file containing the comma-separated list.
 keep_seed                                   0        If 1, keep seed inputs in the corpus even if they do not produce new coverage. When used with |reduce_inputs==1|, the seed inputs will never be reduced. This option can be useful when seeds arenot properly formed for the fuzz target but still have useful snippets.
 cross_over                                  1        If 1, cross over inputs.
 cross_over_uniform_dist                     0        Experimental. If 1, use a uniform probability distribution when choosing inputs to cross over with. Some of the inputs in the corpus may never get chosen for mutation depending on the input mutation scheduling policy. With this flag, all inputs, regardless of the input mutation scheduling policy, can be chosen as an input to cross over with. This can be particularly useful with |keep_seed==1|; all the initial seed inputs, even though they do not increase coverage because they are not properly formed, will still be chosen as an input to cross over with.
 mutate_depth                                5        Apply this number of consecutive mutations to each input.
 reduce_depth                                0        Experimental/internal. Reduce depth if mutations lose unique features
 shuffle                                     1        Shuffle inputs at startup
 prefer_small                                1        If 1, always prefer smaller inputs during the corpus shuffle.
 timeout                                     1200        Timeout in seconds (if positive). If one unit runs more than this number of seconds the process will abort.
 error_exitcode                              77        When libFuzzer itself reports a bug this exit code will be used.
 timeout_exitcode                            70        When libFuzzer reports a timeout this exit code will be used.
 max_total_time                              0        If positive, indicates the maximal total time in seconds to run the fuzzer.
 help                                        0        Print help.
 fork                                        0        Experimental mode where fuzzing happens in a subprocess
 fork_corpus_groups                          0        For fork mode, enable the corpus-group strategy, The main corpus will be grouped according to size, and each sub-process will randomly select seeds from different groups as the sub-corpus.
 ignore_timeouts                             1        Ignore timeouts in fork mode
 ignore_ooms                                 1        Ignore OOMs in fork mode
 ignore_crashes                              0        Ignore crashes in fork mode
 merge                                       0        If 1, the 2-nd, 3-rd, etc corpora will be merged into the 1-st corpus. Only interesting units will be taken. This flag can be used to minimize a corpus.
 set_cover_merge                             0        If 1, the 2-nd, 3-rd, etc corpora will be merged into the 1-st corpus. Same as the 'merge' flag, but uses the standard greedy algorithm for the set cover problem to compute an approximation of the minimum set of testcases that provide the same coverage as the initial corpora
 stop_file                                   0        Stop fuzzing ASAP if this file exists
 merge_control_file                          0        Specify a control file used for the merge process. If a merge process gets killed it tries to leave this file in a state suitable for resuming the merge. By default a temporary file will be used.The same file can be used for multistep merge process.
 minimize_crash                              0        If 1, minimizes the provided crash input. Use with -runs=N or -max_total_time=N to limit the number attempts. Use with -exact_artifact_path to specify the output. Combine with ASAN_OPTIONS=dedup_token_length=3 (or similar) to ensure that the minimized input triggers the same crash.
 cleanse_crash                               0        If 1, tries to cleanse the provided crash input to make it contain fewer original bytes. Use with -exact_artifact_path to specify the output.
 mutation_graph_file                         0        Saves a graph (in DOT format) to mutation_graph_file. The graph contains a vertex for each input that has unique coverage; directed edges are provided between parents and children where the child has unique coverage, and are recorded with the type of mutation that caused the child.
 use_counters                                1        Use coverage counters
 use_memmem                                  1        Use hints from intercepting memmem, strstr, etc
 use_value_profile                           0        Experimental. Use value profile to guide fuzzing.
 use_cmp                                     1        Use CMP traces to guide mutations
 shrink                                      0        Experimental. Try to shrink corpus inputs.
 reduce_inputs                               1        Try to reduce the size of inputs while preserving their full feature sets
 jobs                                        0        Number of jobs to run. If jobs >= 1 we spawn this number of jobs in separate worker processes with stdout/stderr redirected to fuzz-JOB.log.
 workers                                     0        Number of simultaneous worker processes to run the jobs. If zero, "min(jobs,NumberOfCpuCores()/2)" is used.
 reload                                      1        Reload the main corpus every <N> seconds to get new units discovered by other processes. If 0, disabled
 report_slow_units                           10        Report slowest units if they run for more than this number of seconds.
 only_ascii                                  0        If 1, generate only ASCII (isprint+isspace) inputs.
 dict                                        0        Experimental. Use the dictionary file.
 artifact_prefix                             0        Write fuzzing artifacts (crash, timeout, or slow inputs) as $(artifact_prefix)file
 exact_artifact_path                         0        Write the single artifact on failure (crash, timeout) as $(exact_artifact_path). This overrides -artifact_prefix and will not use checksum in the file name. Do not use the same path for several parallel processes.
 print_pcs                                   0        If 1, print out newly covered PCs.
 print_funcs                                 2        If >=1, print out at most this number of newly covered functions.
 print_final_stats                           0        If 1, print statistics at exit.
 print_corpus_stats                          0        If 1, print statistics on corpus elements at exit.
 print_coverage                              0        If 1, print coverage information as text at exit.
 print_full_coverage                         0        If 1, print full coverage information (all branches) as text at exit.
 dump_coverage                               0        Deprecated.
 handle_segv                                 1        If 1, try to intercept SIGSEGV.
 handle_bus                                  1        If 1, try to intercept SIGBUS.
 handle_abrt                                 1        If 1, try to intercept SIGABRT.
 handle_ill                                  1        If 1, try to intercept SIGILL.
 handle_fpe                                  1        If 1, try to intercept SIGFPE.
 handle_int                                  1        If 1, try to intercept SIGINT.
 handle_term                                 1        If 1, try to intercept SIGTERM.
 handle_trap                                 1        If 1, try to intercept SIGTRAP.
 handle_xfsz                                 1        If 1, try to intercept SIGXFSZ.
 handle_usr1                                 1        If 1, try to intercept SIGUSR1.
 handle_usr2                                 1        If 1, try to intercept SIGUSR2.
 handle_winexcept                            1        If 1, try to intercept uncaught Windows Visual C++ Exceptions.
 close_fd_mask                               0        If 1, close stdout at startup; if 2, close stderr; if 3, close both. Be careful, this will also close e.g. stderr of asan.
 detect_leaks                                1        If 1, and if LeakSanitizer is enabled try to detect memory leaks during fuzzing (i.e. not only at shut down).
 purge_allocator_interval                    1        Purge allocator caches and quarantines every <N> seconds. When rss_limit_mb is specified (>0), purging starts when RSS exceeds 50% of rss_limit_mb. Pass purge_allocator_interval=-1 to disable this functionality.
 trace_malloc                                0        If >= 1 will print all mallocs/frees. If >= 2 will also print stack traces.
 rss_limit_mb                                2048        If non-zero, the fuzzer will exit upon reaching this limit of RSS memory usage.
 malloc_limit_mb                             0        If non-zero, the fuzzer will exit if the target tries to allocate this number of Mb with one malloc call. If zero (default) same limit as rss_limit_mb is applied.
 exit_on_src_pos                             0        Exit if a newly found PC originates from the given source location. Example: -exit_on_src_pos=foo.cc:123. Used primarily for testing libFuzzer itself.
 exit_on_item                                0        Exit if an item with a given sha1 sum was added to the corpus. Used primarily for testing libFuzzer itself.
 ignore_remaining_args                       0        If 1, ignore all arguments passed after this one. Useful for fuzzers that need to do their own argument parsing.
 focus_function                              0        Experimental. Fuzzing will focus on inputs that trigger calls to this function. If -focus_function=auto and -data_flow_trace is used, libFuzzer will choose the focus functions automatically. Disables -entropic when specified.
 entropic                                    1        Enables entropic power schedule.
 entropic_feature_frequency_threshold        255        Experimental. If entropic is enabled, all features which are observed less often than the specified value are considered as rare.
 entropic_number_of_rarest_features          100        Experimental. If entropic is enabled, we keep track of the frequencies only for the Top-X least abundant features (union features that are considered as rare).
 entropic_scale_per_exec_time                0        Experimental. If 1, the Entropic power schedule gets scaled based on the input execution time. Inputs with lower execution time get scheduled more (up to 30x). Note that, if 1, fuzzer stops from being deterministic even if a non-zero random seed is given.
 analyze_dict                                0        Experimental
 use_clang_coverage                          0        Deprecated; don't use
 data_flow_trace                             0        Experimental: use the data flow trace
 collect_data_flow                           0        Experimental: collect the data flow trace
 create_missing_dirs                         0        Automatically attempt to create directories for arguments that would normally expect them to already exist (i.e. artifact_prefix, exact_artifact_path, features_dir, corpus)

Flags starting with '--' will be ignored and will be passed verbatim to subprocesses.
```

- 复现与调试崩溃（reproduce）

用指定的测试用例（crash/proc文件）在本地重现问题，基本语法如：

```Plain Text
python3 infra/helper.py reproduce <project> <fuzzer_name> <testcase_path>
```

可通过python3 infra/helper\.py reproduce \-\-help命令查看该构建脚本支持的所有参数。

```SQL
# python3 infra/helper.py reproduce --help
usage: helper.py reproduce [-h] [--valgrind] [-e E] [--external] [--architecture {i386,x86_64,aarch64,riscv64}] [--base-image-tag BASE_IMAGE_TAG]
                           project fuzzer_name testcase_path [fuzzer_args ...]

positional arguments:
  project               name of the project or path (external)
  fuzzer_name           name of the fuzzer
  testcase_path         path of local testcase
  fuzzer_args           arguments to pass to the fuzzer

options:
  -h, --help            show this help message and exit
  --valgrind            run with valgrind
  -e E                  set environment variable e.g. VAR=value
  --external            Is project external?
  --architecture {i386,x86_64,aarch64,riscv64}
  --base-image-tag BASE_IMAGE_TAG
                        The tag of the base-runner image to use.
```

## 二、在oss\-fuzz工具中进行openssl项目模糊测试

### 1\. 测试环境准备

- 基础依赖包下载

```Plain Text
dnf -y install rpm-build docker-engine git
```

- 开启docker experimental功能

编辑daemon\.json文件

```Plain Text
touch /etc/docker/daemon.json
vim /etc/docker/daemon.json
```

在daemon\.json文件中设置：

```Plain Text
{ 
  "experimental": true 
}
```

重启docker服务

```Plain Text
systemctl restart docker
```

查看experimental值为true

```Plain Text
docker info | grep -i 'experimental'
```

- 设置rpm打包环境

```Plain Text
dnf -y install rpmdevtools
rpmdev-setuptree    *#自动在用户家目录生成一个rpmbuild的文件夹，作为工作路径*
```

### 2\. 测试工具部署

目前oss\-fuzz工具仅支持x86\_64、aarch64及i386架构，在RISC\-V架构上进行测试需要进行相应兼容。

（1）下载oss\-fuzz工具源码

```Plain Text
git clone https://github.com/google/oss-fuzz.git
```

（2）RISC\-V架构兼容

调整infra/constants\.py文件增加riscv64架构兼容

```Plain Text
sed -i "s/ARCHITECTURES = \['i386', 'x86_64', 'aarch64'\]/ARCHITECTURES = ['i386', 'x86_64', 'aarch64', 'riscv64']/" infra/constants.py
```

调整infra/helper\.py文件增加riscv64架构兼容

```Bash
old="platform = 'linux/arm64' if architecture == 'aarch64' else 'linux/amd64'"
new="platform = 'linux/arm64' if architecture == 'aarch64' else 'linux/riscv64' if architecture == 'riscv64' else 'linux/amd64'"
sed -i "s|$old|$new|g" oss-fuzz/infra/helper.py
```

### 3\. 测试数据准备

在openEuler系统中对OpenSSL源码进行测试时需要安装补丁。

（1）下载openEuler openssl仓库源码

当前支持通过openEuler源码仓库下载源码，或通过srpm下载源码。

```Bash
# 1. 下载openssl仓库源码
source /etc/os-release
BRANCH="${NAME}-${VERSION_ID}-$(echo "$VERSION" | sed 's/.*(\(.*\))/\1/')"
git clone --branch $BRANCH https://atomgit.com/src-openeuler/openssl
# 2. 下载srpm包
VER=$(rpm -q openssl --qf '%{VERSION}') 
REL=$(rpm -q openssl --qf '%{RELEASE}') 
echo "${VER}-${REL}"
dnf download --source openssl-${VER}-${REL}
mkdir openssl && cd openssl
rpm2cpio /root/openssl-*.src.rpm | cpio -idmv
```

注意：下载openssl源码仓openEuler\-24\.03\-LTS\-SP3版本，在编译target过程中会出现报错，排查出的原因是spec文件中定义的软件包版本与RV系统中实际的版本存在差异，暂时没有找到解决办法，故建议使用srpm包作为源码进行测试，报错详情如下：

```SQL
-fsanitize=array-bounds,bool,builtin,enum,function,integer-divide-by-zero,null,object-size,return,returns-nonnull-attribute,shift,signed-integer-overflow,unsigned-integer-overflow,unreachable,vla-bound,vptr -fno-sanitize-recover=array-bounds,bool,builtin,enum,function,integer-divide-by-zero,null,object-size,return,returns-nonnull-attribute,shift,signed-integer-overflow,unreachable,vla-bound,vptr -fsanitize=fuzzer-no-link -fno-sanitize=function -O1 -fno-omit-frame-pointer -gline-tables-only -Wno-error=incompatible-function-pointer-types -Wno-error=int-conversion -Wno-error=deprecated-declarations -Wno-error=implicit-function-declaration -Wno-error=implicit-int -Wno-error=unknown-warning-option -Wno-error=vla-cxx-extension -fsanitize=array-bounds,bool,builtin,enum,function,integer-divide-by-zero,null,object-size,return,returns-nonnull-attribute,shift,signed-integer-overflow,unsigned-integer-overflow,unreachable,vla-bound,vptr -fno-sanitize-recover=array-bounds,bool,builtin,enum,function,integer-divide-by-zero,null,object-size,return,returns-nonnull-attribute,shift,signed-integer-overflow,unreachable,vla-bound,vptr -fsanitize=fuzzer-no-link -fno-sanitize=function -fno-sanitize=alignment -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSLDIR="\"/usr/local/ssl\"" -DENGINESDIR="\"/usr/local/lib/engines-3\"" -DMODULESDIR="\"/usr/local/lib/ossl-modules\"" -DOPENSSL_BUILDING_OPENSSL -DPEDANTIC -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION -DFUZZING_BUILD_MODE_UNSAFE_FOR_PRODUCTION -MMD -MF crypto/sm2/libcrypto-lib-sm2_sign.d.tmp -MT crypto/sm2/libcrypto-lib-sm2_sign.o -c -o crypto/sm2/libcrypto-lib-sm2_sign.o crypto/sm2/sm2_sign.c
[1mcrypto/sm2/sm2_crypt.c:121:10: [0m[0;1;31merror: [0m[1minvalid output constraint '=c' in asm[0m
  121 |         :[0;32m"=c"[0m(out_len), [0;32m"=d"[0m(f_ok)[0m
      | [0;1;32m         ^
[0m[1mcrypto/sm2/sm2_crypt.c:319:10: [0m[0;1;31merror: [0m[1minvalid output constraint '=c' in asm[0m
  319 |         :[0;32m"=c"[0m(out_len), [0;32m"=d"[0m(f_ok)[0m
      | [0;1;32m         ^
[0m2 errors generated.
make[1]: *** [Makefile:9404: crypto/sm2/libcrypto-lib-sm2_crypt.o] Error 1
make[1]: *** Waiting for unfinished jobs....
[1mcrypto/sm2/sm2_sign.c:40:10: [0m[0;1;31merror: [0m[1minvalid output constraint '=d' in asm[0m
   40 |         :[0;32m"=d"[0m(f_ok)[0m
      | [0;1;32m         ^
[0m[1mcrypto/sm2/sm2_sign.c:491:10: [0m[0;1;31merror: [0m[1minvalid output constraint '=c' in asm[0m
  491 |         :[0;32m"=c"[0m(out_len),[0;32m"=d"[0m(f_ok)[0m
      | [0;1;32m         ^
[0m[1mcrypto/sm2/sm2_sign.c:562:10: [0m[0;1;31merror: [0m[1minvalid output constraint '=c' in asm[0m
  562 |         :[0;32m"=c"[0m(f_ok)[0m
      | [0;1;32m         ^
[0m3 errors generated.
make[1]: *** [Makefile:9428: crypto/sm2/libcrypto-lib-sm2_sign.o] Error 1
make[1]: Leaving directory '/src/openssl30'
make: *** [Makefile:2200: build_sw] Error 2
```

（2）解压源码并应用所有补丁

- 复制下载的openeuler系统的openssl源码包到/root/rpmbuild/SOURCES

```Plain Text
cp -r ./openeuler-openssl/* /root/rpmbuild/SOURCES
```

- 切换到rpmbuild/SOURCES目录下，应用所有补丁

```Plain Text
cd /root/rpmbuild/SOURCES
dnf builddep openssl.spec -y #下载编译依赖
rpmbuild -bp openssl.spec
```

- 将应用补丁的源码文件拷贝到oss\-fuzz工具openssl目录

```Plain Text
cd /root/rpmbuild/BUILD
cp -r openssl-3.0.12/ /root/oss-fuzz/projects/openssl
```

### 4\. 测试执行 

1. openssl项目文件准备

（1）openssl项目Dockerfile调整

oss\-fuzz工具对openssl源码测试同时包含多个版本，在对openEuler openssl源码测试中可以简略仅对当前系统版本进行测试即可。官方openssl源码支持通过git submodule update \-\-init方式获取测试数据集，故在测试过程中可以将openEuler openssl源码替换到官方openssl源码中进行测试。

```Plain Text
cd /root/oss-fuzz
mv projects/openssl/Dockerfile projects/openssl/Dockerfile.bak
touch projects/openssl/Dockerfile
```

```Shell
# 获取系统中openssl软件包版本
OPENSSL_DIR=$(basename projects/openssl/openssl-*)
BRANCH=$(echo "$OPENSSL_DIR" | sed 's/openssl-\([0-9]*\)\.\([0-9]*\).*/\1.\2/')
VERSION=$(echo "$OPENSSL_DIR" | sed 's/openssl-\([0-9]*\)\.\([0-9]*\).*/\1\2/')
OPENSSL_TARGET=openssl$VERSION


cat > projects/openssl/Dockerfile << 'EOF'
FROM gcr.io/oss-fuzz-base/base-builder
RUN apt-get update && apt-get install -y make
RUN git clone --depth 1 --branch openssl-BRANCH https://atomgit.com/openssl/openssl.git OPENSSL_TARGET
COPY OPENSSL_DIR $SRC/OPENSSL_TARGET
RUN cd $SRC/OPENSSL_TARGET/ && git submodule update --init fuzz/corpora
WORKDIR openssl
COPY build.sh *.options replay_build.sh run_tests.sh $SRC/
ENV AFL_SKIP_OSSFUZZ=1
ENV AFL_LLVM_MODE_WORKAROUND=0
EOF
sed -i "s|BRANCH|$BRANCH|g" projects/openssl/Dockerfile
sed -i "s|OPENSSL_DIR|$OPENSSL_DIR|g" projects/openssl/Dockerfile
sed -i "s|OPENSSL_TARGET|$OPENSSL_TARGET|g" projects/openssl/Dockerfile
```

（2）openssl项目build\.sh调整

build\.sh文件也包含openssl多个版本的测试，需要同步调整

```Bash
BUILDPATH='projects/openssl/build.sh'
sed -i '/^cd \$SRC\/openssl\//,$ d' $BUILDPATH
echo '
# In introspector, indexer builds and when capturing replay builds, only build
# the master branch
if [[ "$SANITIZER" == introspector || -n "${INDEXER_BUILD:-}" || -n "${CAPTURE_REPLAY_SCRIPT:-}" ]]; then
  exit 0
fi
' >> $BUILDPATH

if [ $VERSION='30' ]; then
echo '
cd $SRC/openssl$VERSION/
build_fuzzers "_$VERSION" "" "engines"
' >> $BUILDPATH
else
echo '
cd $SRC/openssl$VERSION/
build_fuzzers "_$VERSION" "no-apps no-docs" "engines"
' >> $BUILDPATH
fi

sed -i "s|\$VERSION|$VERSION|g" $$BUILDPATH

```

2. 下载基础镜像

目前oss\-fuzz官方仍不支持RISC\-V架构，因此需要提前下载兼容RISC\-V环境的基础镜像

```Bash
docker pull zhangzhang1/oss-fuzz-base-image:latest
docker pull zhangzhang1/oss-fuzz-base-clang:latest
docker pull zhangzhang1/oss-fuzz-base-builder:latest
docker pull zhangzhang1/oss-fuzz-base-runner:latest
docker pull zhangzhang1/oss-fuzz-base-runner-debug:latest

docker tag zhangzhang1/oss-fuzz-base-image gcr.io/oss-fuzz-base/base-image
docker tag zhangzhang1/oss-fuzz-base-clang gcr.io/oss-fuzz-base/base-clang
docker tag zhangzhang1/oss-fuzz-base-runner gcr.io/oss-fuzz-base/base-runner
docker tag zhangzhang1/oss-fuzz-base-runner-debug gcr.io/oss-fuzz-base/base-runner-debug
docker tag zhangzhang1/oss-fuzz-base-builder gcr.io/oss-fuzz-base/base-builder
```

3. 构建Fuzzer

```Plain Text
#riscv环境下仅支持以下两种方式
python3 infra/helper.py build_fuzzers --architecture riscv64 openssl --sanitizer undefined  # 使用 UBSan（检测未定义行为）

python3 infra/helper.py build_fuzzers --architecture riscv64  openssl --sanitizer none  #只执行fuzz不进行内存检测
```

构建完成后，可在build/out/openssl/文件夹下查看编译出的fuzz target文件

```SQL
[root@localhost oss-fuzz]# ls build/out/openssl/ -lh
total 228M
-rwxr-xr-x 1 root root   21M Aug 20 05:48 asn1_30
-rw-r--r-- 1 root root   59K Aug 20 05:48 asn1_30.dict
-rw-r--r-- 1 root root 1001K Aug 20 05:48 asn1_30_seed_corpus.zip
-rwxr-xr-x 1 root root   17M Aug 20 05:48 asn1parse_30
-rw-r--r-- 1 root root  124K Aug 20 05:48 asn1parse_30_seed_corpus.zip
-rwxr-xr-x 1 root root   17M Aug 20 05:48 bignum_30
-rw-r--r-- 1 root root    27 Aug 20 05:48 bignum_30.options
-rw-r--r-- 1 root root  138K Aug 20 05:48 bignum_30_seed_corpus.zip
-rwxr-xr-x 1 root root   17M Aug 20 05:48 bndiv_30
-rw-r--r-- 1 root root   85K Aug 20 05:48 bndiv_30_seed_corpus.zip
-rwxr-xr-x 1 root root   20M Aug 20 05:48 client_30
-rw-r--r-- 1 root root  1.6M Aug 20 05:48 client_30_seed_corpus.zip
-rwxr-xr-x 1 root root   18M Aug 20 05:48 cmp_30
-rw-r--r-- 1 root root  3.3M Aug 20 05:48 cmp_30_seed_corpus.zip
-rwxr-xr-x 1 root root   18M Aug 20 05:48 cms_30
-rw-r--r-- 1 root root  493K Aug 20 05:48 cms_30_seed_corpus.zip
-rwxr-xr-x 1 root root   17M Aug 20 05:48 conf_30
-rw-r--r-- 1 root root  159K Aug 20 05:48 conf_30_seed_corpus.zip
-rwxr-xr-x 1 root root   17M Aug 20 05:48 crl_30
-rw-r--r-- 1 root root  628K Aug 20 05:48 crl_30_seed_corpus.zip
-rwxr-xr-x 1 root root   17M Aug 20 05:48 ct_30
-rw-r--r-- 1 root root   63K Aug 20 05:48 ct_30_seed_corpus.zip
-rwxr-xr-x 1 root root  6.4M Aug 20 05:37 llvm-symbolizer
-rw-r--r-- 1 root root    26 Aug 20 05:48 quic-srtm_30.options
-rwxr-xr-x 1 root root   20M Aug 20 05:48 server_30
-rw-r--r-- 1 root root  880K Aug 20 05:48 server_30_seed_corpus.zip
-rwxr-xr-x 1 root root   17M Aug 20 05:48 x509_30
-rw-r--r-- 1 root root   59K Aug 20 05:48 x509_30.dict
-rw-r--r-- 1 root root 1020K Aug 20 05:48 x509_30_seed_corpus.zip

```

- 问题1：RISC\-V 架构不支持ASan方式编译target文件

以ASan方式编译fuzz target，在执行run\_fuzzer时会出现内存映射失败

```Plain Text
#以Asan方式编译
python3 infra/helper.py build_fuzzers --architecture riscv64 openssl --sanitizer address 
```

```Bash
# run fuzz时出现内存映射失败
[root@localhost oss-fuzz]# python3 infra/helper.py run_fuzzer openssl x509_30 -- -max_total_time=60
INFO:__main__:Running: docker run --privileged --shm-size=2g --rm -i -e FUZZING_ENGINE=libfuzzer -e SANITIZER=address -e RUN_FUZZER_MODE=interactive -e HELPER=True -v /root/oss-fuzz/build/out/openssl:/out -t zhangzhang1/oss-fuzz-base-runner:latest run_fuzzer x509_30 -max_total_time=60.
Using seed corpus: x509_30_seed_corpus.zip
/out/x509_30 -- -rss_limit_mb=2560 -timeout=25 -max_total_time=60 /tmp/x509_30_corpus -dict=x509_30.dict < /dev/null
==13==ERROR: AddressSanitizer failed to allocate 0xdfff7540000 (15393017298944) bytes at address 0x6fffba9f7000 (errno: 12)
==13==ReserveShadowMemoryRange failed while trying to map 0xdfff7540000 bytes. Perhaps you're using ulimit -v or ulimit -d
```

原因：ASan 运行时需要映射约 15TB 的虚拟内存（你看到的 `0xdfff7540000` ≈ 15\.4 TB），这是它的 shadow memory 机制决定的。它不会实际占用 15TB 物理内存，但操作系统必须允许它预留这么大的虚拟地址空间。

`errno: 12` \(ENOMEM\) \+ 提示 `ulimit -v` 说明容器或宿主机对虚拟内存加了限制。目前暂未找到解决办法

问题2：RISC\-V 架构不支持MSan方式编译target文件

目前riscv64架构下llvm支持MSan功能不完善，在基础镜像base\-clang编译时开启msan会出现报错fatal error: error in backend: unsupported architecture，具体报错日志如下

```Shell
#13 40329.2 /usr/lib/llvm-20/bin/clang++ -DHAVE___CXA_THREAD_ATEXIT_IMPL -DLIBCXX_BUILDING_LIBCXXABI -D_LIBCPP_BUILDING_LIBRARY -D_LIBCPP_HAS_NO_PRAGMA_SYSTEM_HEADER -D_LIBCXXABI_BUILDING_LIBRARY -D_LIBCXXABI_LINK_PTHREAD_LIB -D__STDC_CONSTANT_MACROS -D__STDC_FORMAT_MACROS -D__STDC_LIMIT_MACROS -I/src/llvm-project/libcxxabi/../libcxx/src -I/src/llvm-project/libcxxabi/include -I/work/msan/include/c++/v1 -fsanitize-ignorelist=/work/msan/ignorelist.txt -fPIC -fno-semantic-interposition -fvisibility-inlines-hidden -Werror=date-time -Werror=unguarded-availability-new -Wall -Wextra -Wno-unused-parameter -Wwrite-strings -Wcast-qual -Wmissing-field-initializers -Wimplicit-fallthrough -Wcovered-switch-default -Wno-noexcept-type -Wnon-virtual-dtor -Wdelete-non-virtual-dtor -Wsuggest-override -Wstring-conversion -Wmisleading-indentation -Wctad-maybe-unsupported -fno-omit-frame-pointer -gline-tables-only -fsanitize=memory -fdiagnostics-color -ffunction-sections -fdata-sections  -O3 -DNDEBUG -std=c++23 -nostdinc++ -fno-omit-frame-pointer -gline-tables-only -gline-tables-only -fsanitize=memory -fsanitize=memory -fstrict-aliasing -funwind-tables -D_DEBUG -UNDEBUG -Wall -Wextra -Wnewline-eof -Wshadow -Wwrite-strings -Wno-unused-parameter -Wno-long-long -Werror=return-type -Wextra-semi -Wundef -Wunused-template -Wformat-nonliteral -Wzero-length-array -Wdeprecated-redundant-constexpr-static-def -Wno-nullability-completeness -Wno-user-defined-literals -Wno-covered-switch-default -Wno-suggest-override -Wno-error -fsized-deallocation -fdebug-prefix-map=/work/msan/include/c++/v1=/src/llvm-project/libcxx/include -MD -MT libcxxabi/src/CMakeFiles/cxxabi_static_objects.dir/stdlib_typeinfo.cpp.o -MF libcxxabi/src/CMakeFiles/cxxabi_static_objects.dir/stdlib_typeinfo.cpp.o.d -o libcxxabi/src/CMakeFiles/cxxabi_static_objects.dir/stdlib_typeinfo.cpp.o -c /src/llvm-project/libcxxabi/src/stdlib_typeinfo.cpp
#13 40329.2 fatal error: error in backend: unsupported architecture
#13 40329.2 PLEASE submit a bug report to https://github.com/llvm/llvm-project/issues/ and include the crash backtrace, preprocessed source, and associated run script.
```

4. 运行Fuzzer，可在执行语句后添加最大执行时间 \-max\_total\_time=1800设置执行时间

```Plain Text
python3 infra/helper.py run_fuzzer --architecture riscv64 openssl x509_30 -- -max_total_time=600
```

进行模糊测试，出现crash相关会在oss\-fuzz项目的build/out/openssl/生成out文件，用于存放crashes文件，out文件命名形式为fuzz target\+"\_libfuzzer\_address\_out"，如x509\_30\_libfuzzer\_address\_out。

5. 复现和调式崩溃

用指定的测试用例（crash/proc文件）在本地重现问题

```Plain Text
python3 infra/helper.py reproduce sleuthkit sleuthkit_fls_hfs_fuzzer  crash-cdff9a3162823e34d63c04591442071ff1a9df72
```

6. 日志解读

```Plain Text
*#588154 NEW    cov: 263 ft: 484 corp: 219/112Kb lim: 4096 exec/s: 5026 rss: 31Mb L: 526/1048 MS: 1 ChangeASCIIInt-*

cov：执行当前语料库覆盖的代码块或边缘总数
ft：libFuzzer 使用不同的信号来评估代码覆盖率，(edge coverage, edge counters, value profiles, indirect caller/callee)，这些信号的组合即为特性ft
crop：当前内存测试语料库中的条目数及其字节大小
Lim：当前对语料库中新词条长度的限制。随时间增加，直到达到最大长度（-max_len）
exec/s：每秒模糊器迭代次数
rss：当前内存消耗，对于 NEW 和 REDUCE 事件，输出行还包括有关产生新输入的变异操作的信息
L：新输入的大小 (字节)
MS：用于生成输入的变异操作的计数和列表
```




## 1. 概述

Checksec（Check Security）是一个开源的安全检查脚本/工具，主要用于检查 Linux 系统上可执行文件及运行中进程所启用的安全缓解机制。它帮助安全研究人员、开发者和运维人员快速评估二进制程序和系统层面的安全防护状态。以下是 Checksec 的关键特性和组成部分：

- **二进制安全检查**：能够检测 ELF 可执行文件和共享库是否启用了关键的安全编译选项，如 PIE（位置无关可执行文件）、Stack Canary（栈保护）、NX/DEP（不可执行栈）、RELRO（重定位只读）等。
- **内核与系统级检查**：除了针对单个文件的检查，Checksec 还能评估操作系统的全局安全配置，包括 ASLR（地址空间布局随机化）、内核指针限制、Yama LSM  ptrace 范围等。
- **多格式输出**：支持终端彩色输出、JSON、XML 等多种格式，便于人工阅读或集成到 CI/CD 流水线及自动化扫描工具中。
- **跨发行版支持**：广泛兼容主流 Linux 发行版（如 RHEL/CentOS、Debian/Ubuntu、openEuler 等），底层依赖 `readelf`、`file` 等标准工具链。
- **轻量与便携**：早期版本为单 Bash 脚本，新版本重构为 Python 实现，无需复杂安装即可运行，适合在受限环境或容器中进行快速安全审计。

## 2. 安装与使用

### 2.1 安装

Checksec 提供多种安装方式，目前openEuler rv系统未支持checksec软件包故可通过源码/脚本安装：

```bash
# 下载最新版 checksec
$ git clone https://github.com/slimm609/checksec.sh.git
$ cd checksec.sh
$ go build -o checksec main.go
```

安装完成后验证版本及功能：

```bash
$ checksec --version
checksec version dev (Built on unknown from Git SHA none)
```

### 2.2 基础命令

Checksec 的命令行接口设计直观，基本语法为：

```bash
checksec [command]
```

支持使用 `checksec --help` 查看完整帮助信息：

```bash
checksec --help
A tool used to quickly survey mitigation technologies in use by processes on a Linux system.

Usage:
  checksec [command]

Available Commands:
  completion  Generate the autocompletion script for the specified shell
  dir         check all files in a directory
  file        Check a single binary file
  fortifyFile Check Fortify for binary file
  fortifyProc Check Fortify for running process
  help        Help about any command
  kernel      Check kernel security flags
  proc        Check a file of a running process
  procAll     Check all running processes

Flags:
      --color string    Color output mode (auto, always, never) (default "auto")
  -h, --help            help for checksec
  -l, --libc string     Set libc location (useful for FORTIFY check on offline embedded file-system)
      --no-banner       disable the banner
      --no-headers      disable the headers
      --no-warnings     disable warnings
  -o, --output string   Output format (table, xml, json or yaml) (default "table")
  -v, --version         version for checksec

Use "checksec [command] --help" for more information about a command.
```

常用子命令说明：

- `checksec file <binary>`：检查指定二进制文件的安全属性。
- `checksec dir <directory>`：递归扫描目录下所有 ELF 文件。
- `checksec proc <pid>`：检查指定 PID 对应进程的安全缓解措施。
- `checksec kernel`：检查当前内核及系统级安全配置。
- `checksec file <binary> -o format`：按指定格式输出检查结果，默认以table形式输出。

### 2.3 执行扫描

Checksec 的核心功能是执行本地安全检查。以下示例展示如何对目标文件或系统进行评估。

**检查单个二进制文件：**

```bash
#检查单个二进制文件
$ checksec file /bin/ls

  _____ _    _ ______ _____ _  __ _____ ______ _____
 / ____| |  | |  ____/ ____| |/ // ____|  ____/ ____|
| |    | |__| | |__ | |    | ' /| (___ | |__ | |
| |    |  __  |  __|| |    |  <  \___ \|  __|| |
| |____| |  | | |___| |____| . \ ____) | |___| |____
 \_____|_|  |_|______\_____|_|\_\_____/|______\_____|

RELRO           Stack Canary      CFI               NX            PIE             RPATH      RUNPATH      Symbols         SafeStack       FORTIFY    Fortified   Fortifiable      Name                            
Full RELRO      Canary Found      Unknown           NX enabled    PIE Enabled     No RPATH   No RUNPATH   No Symbols      No SafeStack FoundYes        5           10               /bin/ls   

#检查单个二进制文件并按json格式输出
$ checksec file /bin/ls -o json
[
  {
    "checks": {
      "canary": "Canary Found",
      "cfi": "Unknown",
      "fortified": "5",
      "fortify_source": "Yes",
      "fortifyable": "10",
      "nx": "NX enabled",
      "pie": "PIE Enabled",
      "relro": "Full RELRO",
      "rpath": "No RPATH",
      "runpath": "No RUNPATH",
      "safestack": "No SafeStack Found",
      "symbols": "No Symbols"
    },
    "name": "/bin/ls"
  }
]
# 检查文件夹下二进制按json格式输出并导出至文件
$ checksec dir /usr/local/bin --output json > scan_results.json

```

**检查系统内核安全配置：**

```bash
$ checksec kernel

  _____ _    _ ______ _____ _  __ _____ ______ _____
 / ____| |  | |  ____/ ____| |/ // ____|  ____/ ____|
| |    | |__| | |__ | |    | ' /| (___ | |__ | |
| |    |  __  |  __|| |    |  <  \___ \|  __|| |
| |____| |  | | |___| |____| . \ ____) | |___| |____
 \_____|_|  |_|______\_____|_|\_\_____/|______\_____|

Kernel configs only print what is supported by the specific kernel/kernel config
Description                                                   Value            Check Type            Config Key            
Stack Protector                                               Enabled          Kernel Config         CONFIG_STACKPROTECTOR 
Virtually-mapped kernel stack                                 Enabled          Kernel Config         CONFIG_VMAP_STACK     
SELinux Kernel Flag                                           Enabled          Kernel Config         CONFIG_SECURITY_SELINUX
Detect stack corruption on calls to schedule                  Disabled         Kernel Config         CONFIG_SCHED_STACK_END_CHECK   
Randomize address of kernel image                             Disabled         Kernel Config         CONFIG_RANDOMIZE_BASE 
Restrict I/O access to /dev/mem                               Enabled          Kernel Config         CONFIG_IO_STRICT_DEVMEM
Allow disabling selinux at boot                               Disabled         Kernel Config         CONFIG_SECURITY_SELINUX_BOOTPARAM
Automatically load TTY Line Disciplines                       Disabled         Kernel Config         CONFIG_LDISC_AUTOLOAD 
Restrict Module RWX                                           Enabled          Kernel Config         CONFIG_STRICT_MODULE_RWX
Debug linked list manipulation                                Enabled          Kernel Config         CONFIG_DEBUG_LIST     
Debug SG table operations                                     Disabled         Kernel Config         CONFIG_DEBUG_SG       
Restrict Kernel RWX                                           Disabled         Kernel Config         CONFIG_STRICT_KERNEL_RWX
Security Landlock support                                     Disabled         Kernel Config         CONFIG_SECURITY_LANDLOCK
SELinux Development Support                                   Disabled         Kernel Config         CONFIG_SECURITY_SELINUX_DEVELOP
kernel runs in confidentiality mode                           Disabled         Kernel Config         CONFIG_LOCK_DOWN_KERNEL_FORCE_CONFIDENTIALITY
Safely execute untrusted bytecode                             Enabled          Kernel Config         CONFIG_SECCOMP        
Stack Protector Strong                                        Enabled          Kernel Config         CONFIG_STACKPROTECTOR_STRONG
Secure computing for BPF                                      Enabled          Kernel Config         CONFIG_SECCOMP_FILTER 
Kernel Heap Randomization                                     Disabled         Kernel Config         CONFIG_COMPAT_BRK     
Debug VM translations                                         Disabled         Kernel Config         CONFIG_DEBUG_VIRTUAL  
SELinux Enabled                                               Disabled         SELinux               SELinux               
Protected symlinks                                            Enabled          Sysctl                fs.protected_symlinks 
Protected hardlinks                                           Enabled          Sysctl                fs.protected_hardlinks
......
```

### 2.4 结果评估

Checksec 的输出结果直接反映安全机制的启用状态。以下是各字段的含义及评估标准：

| 字段          | 描述                 | 安全建议/期望值                                 |
| ------------- | -------------------- | ----------------------------------------------- |
| RELRO         | 重定位表只读保护     | Full RELRO（完全保护 GOT 表）优于 Partial RELRO |
| STACK CANARY  | 栈溢出检测机制       | Canary found 表示已启用栈保护                   |
| NX            | 不可执行栈/数据段    | NX enabled 防止栈上代码执行                     |
| PIE           | 位置无关可执行文件   | PIE enabled 使主程序也受 ASLR 保护              |
| RPATH/RUNPATH | 动态链接库搜索路径   | No RPATH/No RUNPATH 避免劫持风险                |
| FORTIFY       | 编译时缓冲区溢出检查 | Yes 且 Fortified > 0 表示部分函数受保护         |
| ASLR          | 地址空间布局随机化   | Full randomization 为最佳状态                   |
| KPTI          | 内核页表隔离         | Enabled 可缓解 Meltdown 等侧信道攻击            |

**注意**：Checksec 仅反映“机制是否存在”，不代表“绝对安全”。例如，即使所有选项均为绿色（Enabled），若代码逻辑存在漏洞仍可能被利用；反之，某些遗留系统因兼容性无法开启全部保护，需结合业务场景综合评估。

### 2.5 集成与修复建议

Checksec 本身不提供自动修复功能，但其输出可直接指导加固操作。常见的修复流程如下：

#### 2.5.1 编译期加固

对于自研或可重新编译的程序，根据 Checksec 缺失项调整编译参数：

```bash
# 启用 Full RELRO + Stack Canary + NX + PIE + FORTIFY
gcc -Wl,-z,relro,-z,now -fstack-protector-strong -D_FORTIFY_SOURCE=2 -pie -o myapp myapp.c
```

#### 2.5.2 系统级加固

针对 `checksec --kernel` 中发现的问题，修改内核参数或 sysctl 配置：

```bash
# 启用 ASLR（若未启用）
echo 2 > /proc/sys/kernel/randomize_va_space

# 限制 ptrace 范围
echo 1 > /proc/sys/kernel/yama/ptrace_scope
```

------

**参考：**

- [Checksec GitHub Repository](https://github.com/slimm609/checksec.sh)

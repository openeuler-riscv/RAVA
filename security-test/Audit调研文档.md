## 1. 概述

Linux Audit Framework（审计框架）是 Linux 内核提供的一套**安全审计机制**，用于记录系统中与安全相关的事件，包括系统调用执行（`execve`, `connect`, `setuid` 等）、文件访问与修改（读/写/执行/属性变更）、用户登录与认证事件、权限变更与特权提升操作、SELinux 访问控制决策。`auditd` 是该框架的**用户态守护进程**，负责接收内核审计消息并持久化到日志文件（默认 `/var/log/audit/audit.log`）。

## 2. 环境准备与工具安装

### 2.1 确认 auditd 状态

```bash
# 查看 auditd 版本
$ rpm -q audit
audit-3.1.2-13.oe2403sp3.riscv64

# 查看服务状态
$ sudo systemctl status auditd

# 查看内核审计子系统状态
$ sudo auditctl -s
enabled 1
failure 1
pid 414
rate_limit 0
backlog_limit 64
lost 0
backlog 0
backlog_wait_time 15000
backlog_wait_time_actual 0
loginuid_immutable 0 unlocked 
```

### 2.2 安装 auditd

auditd 通常预装在系统中，如未安装：

```bash
$ sudo dnf install -y audit audit-libs
```

**重要提示**：`auditd` 服务**不能**通过 `systemctl restart` 重启。必须使用以下方式：

```
# 正确方式
$ sudo service auditd restart
# 或
$ sudo systemctl stop auditd && sudo systemctl start auditd
```

直接 `systemctl restart auditd` 可能导致审计子系统异常中断，这是由内核审计 netlink 接口的特殊性决定的。

### 2.3 配套工具说明

| 工具 | 用途 | 典型场景 |
|------|------|---------|
| `auditctl` | 运行时规则管理 | 添加/删除/列出审计规则 |
| `ausearch` | 日志检索分析 | 按关键字、时间、进程等条件搜索 |
| `aureport` | 生成审计报告 | 汇总认证、文件访问、系统调用等报告 |
| `autrace` | 进程行为追踪 | 追踪特定进程的系统调用序列 |
| `augenrules` | 规则持久化加载 | 将 `/etc/audit/rules.d/*.rules` 加载到内核 |
| `aulast` / `aulastlog` | 登录审计 | 查看用户登录/登出记录 |

## 3. 核心命令详解

### 3.1 auditctl — 审计规则管理

#### 3.1.1 命令格式

```bash
auditctl [options]
```

#### 3.1.2 完整参数速查

```
$ auditctl -h
usage: auditctl [options]
    -a <l,a>                          Append rule to end of <l>ist with <a>ction
    -A <l,a>                          Add rule at beginning of <l>ist with <a>ction
    -b <backlog>                      Set max number of outstanding audit buffers
                                      allowed Default=64
    -c                                Continue through errors in rules
    -C f=f                            Compare collected fields if available:
                                      Field name, operator(=,!=), field name
    -d <l,a>                          Delete rule from <l>ist with <a>ction
                                      l=task,exit,user,exclude,filesystem
                                      a=never,always
    -D                                Delete all rules and watches
    -e [0..2]                         Set enabled flag
    -f [0..2]                         Set failure flag
                                      0=silent 1=printk 2=panic
    -F f=v                            Build rule: field name, operator(=,!=,<,>,<=,
                                      >=,&,&=) value
    -h                                Help
    -i                                Ignore errors when reading rules from file
    -k <key>                          Set filter key on audit rule
    -l                                List rules
    -m text                           Send a user-space message
    -p [r|w|x|a]                      Set permissions filter on watch
                                      r=read, w=write, x=execute, a=attribute
    -q <mount,subtree>                make subtree part of mount point's dir watches
    -r <rate>                         Set limit in messages/sec (0=none)
    -R <file>                         read rules from file
    -s                                Report status
    -S syscall                        Build rule: syscall name or number
    --signal <signal>                 Send the specified signal to the daemon
    -t                                Trim directory watches
    -v                                Version
    -w <path>                         Insert watch at <path>
    -W <path>                         Remove watch at <path>
    --loginuid-immutable              Make loginuids unchangeable once set
    --backlog_wait_time               Set the kernel backlog_wait_time
    --reset-lost                      Reset the lost record counter
    --reset_backlog_wait_time_actual  Reset the actual backlog wait time counter
```

#### 3.1.3 常用参数详解

| 参数 | 说明 | 示例 |
|------|------|------|
| `-l` | 列出当前所有已加载的审计规则 | `sudo auditctl -l` |
| `-a <list>,<action>` | 添加规则到指定列表，`always` 记录，`never` 忽略 | `-a always,exit` |
| `-d <list>,<action>` | 删除指定规则 | `-d always,exit -S setuid` |
| `-D` | 删除所有规则（慎用） | `sudo auditctl -D` |
| `-w <path>` | 监控文件或目录 | `-w /etc/passwd` |
| `-p [r\|w\|x\|a]` | 设置监控权限过滤 | `-p wa`（写+属性变更） |
| `-S <syscall>` | 指定系统调用名称或编号 | `-S execve` |
| `-F <field>=<value>` | 添加过滤条件 | `-F arch=b64 -F uid=0` |
| `-k <key>` | 为规则设置标签键，便于检索 | `-k privilege_escalation` |
| `-e <0\|1\|2>` | 设置审计使能状态：`0`=禁用, `1`=启用, `2`=锁定 | `sudo auditctl -e 1` |
| `-r <rate>` | 设置每秒最大消息数（0=无限制） | `sudo auditctl -r 0` |
| `-b <backlog>` | 设置内核审计缓冲区队列大小 | `sudo auditctl -b 8192` |

#### 3.1.4 常用参数实战示例

```bash
# 列出当前所有已加载的审计规则
$ sudo auditctl -l

# 添加文件监控规则：监控 /etc/passwd 的读写属性变更
$ sudo auditctl -w /etc/passwd -p wa -k identity_file_change

# 添加系统调用监控：记录所有程序执行（64位架构）
$ sudo auditctl -a always,exit -F arch=b64 -S execve -k process_execution

# 添加带过滤条件的规则：仅监控非root用户的网络连接
$ sudo auditctl -a always,exit -F arch=b64 -S connect,bind -F auid>=1000 -F auid!=-1 -k network_connection

# 删除指定规则（参数需与添加时完全一致）
$ sudo auditctl -d always,exit -F arch=b64 -S execve -k process_execution

# 删除所有规则（慎用，会清空全部审计配置）
$ sudo auditctl -D

# 设置审计使能状态为启用
$ sudo auditctl -e 1

# 设置审计速率限制为每秒500条消息（0表示无限制）
$ sudo auditctl -r 500

# 设置内核审计缓冲区大小为8192
$ sudo auditctl -b 8192

# 查看内核审计子系统状态
$ sudo auditctl -s
```

**注意**：`auditctl` 设置的规则在**重启后失效**。持久化规则需写入 `/etc/audit/rules.d/*.rules` 文件，格式与 `auditctl` 命令行参数一致（去掉开头的 `auditctl`）。

### 3.2 ausearch — 日志检索与分析

#### 3.2.1 命令格式

```bash
ausearch [options]
```

#### 3.2.2 完整参数速查

```
$ ausearch --help
usage: ausearch [options]
    -a,--event <Audit event id>     search based on audit event id
    --arch <CPU>                    search based on the CPU architecture
    -c,--comm  <Comm name>          search based on command line name
    --checkpoint <checkpoint file>  search from last complete event
    --debug                         Write malformed events that are skipped to stderr
    -e,--exit  <Exit code or errno>  search based on syscall exit code
    -escape <option>               escape output
    --eoe-timeout secs             End of Event timeout
    --extra-keys                   add a final column with key information
    --extra-labels                 add columns of information about subject and object labels
    --extra-obj2                   add columns of information about a second object
    --extra-time                   add columns of information about broken down time
    -f,--file  <File name>          search based on file name
    --format [raw|default|interpret|csv|text]  results format options
    -ga,--gid-all <all Group id>   search based on All group ids
    -ge,--gid-effective <effective Group id>  search based on Effective group id
    -gi,--gid <Group Id>           search based on group id
    -h,--help                      help
    -hn,--host <Host Name>          search based on remote host name
    -i,--interpret                 Interpret results to be human readable
    -if,--input <Input File name>   use this file instead of current logs
    --input-logs                   Use the logs even if stdin is a pipe
    --just-one                     Emit just one event
    -k,--key  <key string>         search based on key field
    -l, --line-buffered             Flush output on every line
    -m,--message  <Message type>   search based on message type
    -n,--node  <Node name>          search based on machine's name
    -o,--object  <SE Linux Object context>  search based on context of object
    -p,--pid  <Process id>          search based on process id
    -pp,--ppid <Parent Process id>  search based on parent process id
    -r,--raw                        output is completely unformatted
    -sc,--syscall <SysCall name>    search based on syscall name or number
    -se,--context <SE Linux context> search based on either subject or object
    --session <login session id>    search based on login session id
    -su,--subject <SE Linux context> search based on context of the Subject
    -sv,--success <Success Value>   search based on syscall or event success value
    -te,--end [end date] [end time] ending date & time for search
    -ts,--start [start date] [start time]  starting date & time for search
    -tm,--terminal <TerMinal>       search based on terminal
    -ua,--uid-all <all User id>     search based on All user id's
    -ue,--uid-effective <effective User id>  search based on Effective user id
    -ui,--uid <User Id>             search based on user id
    -ul,--loginuid <login id>       search based on the User's Login id
    -uu,--uuid <guest UUID>         search for events related to the virtual machine
    -v,--version                    version
    -vm,--vm-name <guest name>      search for events related to the virtual machine
    -w,--word                       string matches are whole word
    -x,--executable <executable name>  search based on executable name
```

#### 3.2.3 常用检索示例

```bash
# 按关键字搜索审计事件（推荐加上 --interpret 提高可读性）
$ sudo ausearch -k privilege_escalation --interpret

# 按时间范围搜索今天的系统调用事件
$ sudo ausearch --start today --end now -m SYSCALL --interpret

# 按进程名搜索
$ sudo ausearch -c sshd --interpret

# 按文件路径搜索
$ sudo ausearch -f /etc/passwd --interpret

# 按用户 UID 搜索
$ sudo ausearch -ui 1000 --interpret

# 按登录会话 ID 搜索
$ sudo ausearch --session 12345 --interpret

# 搜索失败的系统调用
$ sudo ausearch -sv no --interpret

# 使用 checkpoint 实现增量查询（适合脚本定时执行）
$ sudo ausearch --checkpoint /var/lib/audit/checkpoint.file --interpret
```

### 3.3 aureport — 审计报告生成

#### 3.3.1 命令格式

```bash
aureport [options]
```

#### 3.3.2 完整参数速查

```
$ aureport --help
usage: aureport [options]
    -a,--avc                        Avc report
    -au,--auth                      Authentication report
    --comm                          Commands run report
    -c,--config                     Config change report
    -cr,--crypto                    Crypto report
    --debug                         Write malformed events that are skipped to stderr
    --eoe-timeout secs              End of Event Timeout
    -e,--event                      Event report
    --escape option                 Escape output
    -f,--file                       File name report
    --failed                        only failed events in report
    -h,--host                       Remote Host name report
    --help                          help
    -i,--interpret                  Interpretive mode
    -if,--input <Input File name>   use this file as input
    --input-logs                    Use the logs even if stdin is a pipe
    --integrity                     Integrity event report
    -k,--key                        Key report
    -l,--login                      Login report
    -m,--mods                       Modification to accounts report
    -ma,--mac                       Mandatory Access Control (MAC) report
    -n,--anomaly                    aNomaly report
    -nc,--no-config                 Don't include config events
    --node <node name>              Only events from a specific node
    -p,--pid                        Pid report
    -r,--response                   Response to anomaly report
    -s,--syscall                    Syscall report
    --success                       only success events in report
    --summary                       sorted totals for main object in report
    -t,--log                        Log time range report
    -te,--end [end date] [end time] ending date & time for reports
    -tm,--terminal                  TerMinal name report
    -ts,--start [start date] [start time]  starting data & time for reports
    --tty                           Report about tty keystrokes
    -u,--user                       User name report
    -v,--version                    Version
    --virt                          Virtualization report
    -x,--executable                 eXecutable name report
```

注意：如果不指定报告类型，默认显示**摘要报告**（Summary Report）。

#### 3.3.3 常用报告示例

```bash
# 生成摘要报告
$ sudo aureport --summary

# 认证报告（登录/登出/失败认证）
$ sudo aureport -au --summary

# 文件访问报告
$ sudo aureport -f --summary

# 可执行文件执行报告
$ sudo aureport -x --summary

# 系统调用报告
$ sudo aureport -s --summary

# 用户活动报告
$ sudo aureport -u --summary

# 异常事件报告
$ sudo aureport -n

# 指定时间范围的报告
$ sudo aureport --start today --end now -au

# 仅显示失败事件
$ sudo aureport --failed -au
```

## 4. 审计规则配置

### 4.1 文件系统监控

监控敏感文件或目录的访问与修改，是审计的基础场景。

#### 4.1.1 权限标志说明

| 标志 | 含义 | 触发场景 |
|------|------|---------|
| `r` | read（读取） | `cat`, `less`, `grep` 等读取文件内容 |
| `w` | write（写入） | `echo`, `vim`, `sed` 等修改文件内容 |
| `x` | execute（执行） | 文件作为可执行程序运行 |
| `a` | attribute（属性变更） | `chmod`, `chown`, `mv`, `touch` 等修改元数据 |

#### 4.1.2 典型监控规则

```bash
# 监控 /etc/passwd 的所有读写执行属性变更
$ sudo auditctl -w /etc/passwd -p rwxa -k identity_file_change

# 监控 /etc/shadow 的任何访问（该文件包含密码哈希，极度敏感）
$ sudo auditctl -w /etc/shadow -p rwa -k shadow_access

# 监控 sudo 配置目录的变更
$ sudo auditctl -w /etc/sudoers.d/ -p wa -k sudoers_change

# 监控 SSH 服务配置
$ sudo auditctl -w /etc/ssh/sshd_config -p wa -k ssh_config_change

# 监控 PAM 认证配置
$ sudo auditctl -w /etc/pam.d/ -p wa -k pam_config_change

# 监控系统二进制文件（检测替换/篡改）
$ sudo auditctl -w /usr/bin/ -p wa -k system_binary_change
$ sudo auditctl -w /usr/sbin/ -p wa -k system_binary_change

# 监控 crontab 文件（计划任务篡改）
$ sudo auditctl -w /etc/crontab -p wa -k cron_change
$ sudo auditctl -w /etc/cron.d/ -p wa -k cron_change
$ sudo auditctl -w /var/spool/cron/ -p wa -k cron_change
```

 **性能提示**：避免监控高频访问目录（如 `/proc`, `/sys`, `/tmp`），否则会产生海量日志，导致磁盘耗尽和系统性能下降。

### 4.2 系统调用审计

监控特定系统调用的执行，常用于检测提权、反弹 Shell、恶意程序执行等攻击行为。

#### 4.2.1 查看系统调用映射

```bash
# 查看当前架构支持的系统调用名称与编号映射
$ ausyscall --dump

# 查看特定系统调用的编号
$ ausyscall x86_64 execve
59

# 查看特定编号的系统调用名称
$ ausyscall x86_64 59
execve
```

#### 4.2.2 典型系统调用监控规则

```bash
# 监控 execve 系统调用（记录所有程序执行）
$ sudo auditctl -a always,exit -F arch=b64 -S execve -k process_execution

# 64位系统需同时配置 b32 规则以覆盖 32 位兼容层调用
$ sudo auditctl -a always,exit -F arch=b32 -S execve -k process_execution

# 监控特权提升相关调用
$ sudo auditctl -a always,exit -F arch=b64 -S setuid,setgid,setreuid,setregid,setresuid,setresgid -k privilege_escalation
$ sudo auditctl -a always,exit -F arch=b32 -S setuid,setgid,setreuid,setregid,setresuid,setresgid -k privilege_escalation

# 监控网络连接创建（仅非 root 用户，排除系统服务噪声）
$ sudo auditctl -a always,exit -F arch=b64 -S connect,bind -F auid>=1000 -F auid!=-1 -k network_connection
$ sudo auditctl -a always,exit -F arch=b32 -S connect,bind -F auid>=1000 -F auid!=-1 -k network_connection

# 监控进程创建（fork/clone，检测可疑子进程）
$ sudo auditctl -a always,exit -F arch=b64 -S fork,clone,clone3 -k process_creation

# 监控文件权限变更
$ sudo auditctl -a always,exit -F arch=b64 -S chmod,fchmod,fchmodat,chown,fchown,lchown,fchownat -k permission_change

# 监控加载内核模块（检测 rootkit 植入）
$ sudo auditctl -a always,exit -F arch=b64 -S init_module,finit_module,delete_module -k kernel_module

# 监控 ptrace 调用（检测进程注入/调试）
$ sudo auditctl -a always,exit -F arch=b64 -S ptrace -k process_injection
```

注意：openEuler riscv系统配置规则包含arch，加载规则不成功有如下失败信息

```
$ auditctl -a always,exit -F arch=b64 -S ptrace -k process_injection
arch elf mapping not found
There was an error while processing parameters
#或添加规则配置文件后手动加载规则
$ augenrules --load
arch elf mapping not found
```

#### 4.2.3 规则过滤条件详解

| 过滤字段 | 说明 | 示例 |
|---------|------|------|
| `auid` | 登录用户 ID（审计 UID，追踪原始登录用户） | `-F auid>=1000` |
| `uid` | 当前有效用户 ID | `-F uid=0` |
| `gid` | 当前有效组 ID | `-F gid=0` |
| `pid` | 进程 ID | `-F pid=1234` |
| `ppid` | 父进程 ID | `-F ppid=1` |
| `exe` | 可执行文件路径 | `-F exe=/usr/bin/curl` |
| `comm` | 进程命令名 | `-F comm=sshd` |
| `arch` | CPU 架构（`b64`/`b32`） | `-F arch=b64` |
| `success` | 系统调用是否成功 | `-F success=yes` |
| `key` | 规则标签（用于检索） | `-k suspicious_activity` |

 **关于 `auid` 的特别说明**：`auid`（Audit UID）在用户登录时被内核设置，用于**追踪用户的原始身份**。即使用户通过 `su`/`sudo` 切换身份，`auid` 仍保持不变。这是审计溯源的关键字段。`auid=-1`（或 `unset`）表示该进程未通过正常登录会话启动（如系统服务）。

### 4.3 规则持久化与加载

运行时规则在系统重启后会丢失，必须通过规则文件实现持久化。

#### 4.3.1 规则文件格式

规则文件位于 `/etc/audit/rules.d/*.rules`，格式与 `auditctl` 命令行参数一致（**去掉开头的 `auditctl`**）。

```bash
# 查看规则文件目录
$ ls -la /etc/audit/rules.d/
-rw-r--r-- 1 root root  548 Jan 15 10:00 audit.rules
-rw-r--r-- 1 root root  256 Jan 15 10:00 custom.rules
```

#### 4.3.2 编写持久化规则文件

```bash
# 创建自定义规则文件
$ sudo tee /etc/audit/rules.d/custom.rules << 'EOF'
# 删除所有现有规则
-D

# 设置缓冲区大小
-b 8192

# 设置失败模式为 printk（记录到内核日志）
-f 1

# 监控身份认证文件
-w /etc/passwd -p rwxa -k identity_file_change
-w /etc/shadow -p rwa -k shadow_access
-w /etc/group -p wa -k identity_file_change
-w /etc/gshadow -p wa -k identity_file_change

# 监控 sudo 配置
-w /etc/sudoers -p wa -k sudoers_change
-w /etc/sudoers.d/ -p wa -k sudoers_change

# 监控 SSH 配置
-w /etc/ssh/sshd_config -p wa -k ssh_config_change

# 监控系统调用
-a always,exit -F arch=b64 -S execve -k process_execution
-a always,exit -F arch=b32 -S execve -k process_execution
-a always,exit -F arch=b64 -S setuid,setgid,setreuid,setregid,setresuid,setresgid -k privilege_escalation
-a always,exit -F arch=b32 -S setuid,setgid,setreuid,setregid,setresuid,setresgid -k privilege_escalation

# 监控非 root 用户的网络连接
-a always,exit -F arch=b64 -S connect,bind -F auid>=1000 -F auid!=-1 -k network_connection
-a always,exit -F arch=b32 -S connect,bind -F auid>=1000 -F auid!=-1 -k network_connection

# 锁定规则（设置后无法修改，除非重启）
# -e 2
EOF
```

#### 4.3.3 加载持久化规则

```bash
# 使用 augenrules 加载所有规则文件
$ sudo augenrules --load

# 验证规则是否加载成功
$ sudo auditctl -l

# 查看内核审计状态
$ sudo auditctl -s
```

#### 4.3.4 从运行时规则导出

```bash
# 将当前运行时规则导出为持久化文件
$ sudo auditctl -l > /etc/audit/rules.d/runtime-export.rules

# 重新加载
$ sudo augenrules --load
```

### 4.4 审计日志轮转与存储配置

审计日志增长极快，需合理配置 `/etc/audit/auditd.conf`。

#### 4.4.1 核心配置项

| 配置项 | 推荐值 | 说明 |
|--------|--------|------|
| `log_file` | `/var/log/audit/audit.log` | 审计日志文件路径 |
| `log_format` | `ENRICHED` | 日志格式：`ENRICHED` 包含解析后的字段信息，可读性更好 |
| `max_log_file` | `50` | 单个日志文件最大大小（MB） |
| `num_logs` | `10` | 保留的日志文件数量 |
| `max_log_file_action` | `ROTATE` | 达到上限时的动作：`ROTATE` 轮转，`SYSLOG` 告警，`SUSPEND` 暂停，`KEEP_LOGS` 保留 |
| `space_left` | `75` | 磁盘剩余空间告警阈值（MB） |
| `space_left_action` | `SYSLOG` | 磁盘空间不足时的动作：`SYSLOG` 记录日志，`EMAIL` 发送邮件，`EXEC` 执行脚本 |
| `admin_space_left` | `50` | 管理员空间告警阈值（MB） |
| `admin_space_left_action` | `SUSPEND` | 管理员空间不足时的动作：`SUSPEND` 暂停审计，`SINGLE` 进入单用户模式 |
| `disk_full_action` | `SUSPEND` | 磁盘满时的动作 |
| `disk_error_action` | `SUSPEND` | 磁盘错误时的动作 |
| `flush` | `INCREMENTAL_ASYNC` | 日志刷盘策略：`NONE`, `INCREMENTAL`, `DATA`, `SYNC`, `INCREMENTAL_ASYNC` |
| `freq` | `50` | 与 `INCREMENTAL` 配合，每 N 条记录刷盘一次 |
| `backlog_wait_time` | `60000` | 内核缓冲区满时的等待时间（毫秒） |

#### 4.4.2 推荐配置示例

```bash
$ sudo tee /etc/audit/auditd.conf << 'EOF'
#
# auditd.conf 推荐配置
#

# 日志文件
log_file = /var/log/audit/audit.log
log_format = ENRICHED
log_group = root

# 日志轮转
max_log_file = 50
num_logs = 10
max_log_file_action = ROTATE

# 磁盘空间管理
space_left = 75
space_left_action = SYSLOG
admin_space_left = 50
admin_space_left_action = SUSPEND
disk_full_action = SUSPEND
disk_error_action = SUSPEND

# 性能优化
flush = INCREMENTAL_ASYNC
freq = 50
backlog_wait_time = 60000
EOF

# 重启 auditd 使配置生效
$ sudo service auditd restart
```

## 5. 日志分析

### 5.1 分析特权提升事件

```bash
# 搜索特权提升相关的审计事件
$ sudo ausearch -k privilege_escalation --interpret

# 典型输出示例：
type=SYSCALL msg=audit(06/26/2026 14:32:15.123:45678) : arch=x86_64 syscall=setuid success=yes exit=0 a0=0 a1=7f... a2=0 a3=7f... items=0 ppid=1234 pid=5678 auid=user1 uid=root gid=root euid=root suid=root fsuid=root egid=root sgid=root fsgid=root tty=pts0 ses=5 comm=sudo exe=/usr/bin/sudo key=privilege_escalation
type=CRED_REFR msg=audit(06/26/2026 14:32:15.123:45678) : pid=5678 uid=root auid=user1 ses=5 subj=unconfined msg='op=PAM:setcred acct=root exe=/usr/bin/sudo hostname=? addr=? terminal=/dev/pts0 res=success'
```

**关键字段解读**：
- `auid=user1`：原始登录用户（即使切换到了 root，仍可追溯）
- `uid=root`：当前有效用户
- `exe=/usr/bin/sudo`：执行提权的程序
- `tty=pts0`：终端设备

### 5.2 追踪文件篡改

```bash
# 搜索 /etc/passwd 的变更记录
$ sudo ausearch -f /etc/passwd --interpret

# 查看谁在什么时间修改了文件
$ sudo ausearch -f /etc/passwd -k identity_file_change --interpret | grep -E "(type=SYSCALL|type=PATH)"
```

### 5.3 检测反弹 Shell

```bash
# 搜索非 root 用户的网络连接
$ sudo ausearch -k network_connection --interpret

# 结合进程执行记录，查找异常
$ sudo ausearch -k process_execution --interpret | grep -E "(comm=bash|comm=sh|comm=nc|comm=ncat|comm=python)"
```

### 5.4 生成每日审计摘要

```bash
# 生成今日认证报告
$ sudo aureport -au --start today --summary

# 生成今日文件访问报告
$ sudo aureport -f --start today --summary

# 生成今日异常报告
$ sudo aureport -n --start today
```

## 6. 性能调优与最佳实践

### 6.1 审计风暴防护

审计规则配置不当可能导致**审计风暴**（Audit Storm），即短时间内产生海量日志，导致：
- 磁盘 I/O 饱和
- 系统性能急剧下降
- 关键日志被覆盖

**防护措施**：

```bash
# 1. 设置速率限制（每秒最多 N 条消息）
$ sudo auditctl -r 500

# 2. 增大内核缓冲区
$ sudo auditctl -b 16384

# 3. 排除高频噪声路径
$ sudo auditctl -a never,exclude -F dir=/proc -F perm=r -F auid=-1
$ sudo auditctl -a never,exclude -F dir=/sys -F perm=r -F auid=-1
$ sudo auditctl -a never,exclude -F dir=/dev/shm -F perm=r -F auid=-1

# 4. 排除已知的安全进程（如监控 Agent 自身）
$ sudo auditctl -a never,exclude -F exe=/usr/sbin/osqueryd
```

### 6.2 规则加载顺序原则

审计规则按**顺序匹配**，匹配到 `never` 规则后跳过后续规则。因此：

1. **先加载排除规则**（`never`），减少噪声
2. **再加载监控规则**（`always`），聚焦关键事件
3. **最后加载兜底规则**（如全量 execve 监控）

```bash
# 规则文件示例（注意顺序）
-D                          # 清空现有规则
-b 8192                     # 设置缓冲区

# 1. 排除规则（先）
-a never,exclude -F dir=/proc -F perm=r -F auid=-1
-a never,exclude -F dir=/sys -F perm=r -F auid=-1

# 2. 关键监控规则（中）
-w /etc/passwd -p wa -k identity_file_change
-w /etc/shadow -p wa -k shadow_access

# 3. 兜底监控规则（后）
-a always,exit -F arch=b64 -S execve -k process_execution
```

### 6.3 日志存储规划

| 场景 | 建议 |
|------|------|
| 单机审计 | `max_log_file=50`, `num_logs=10`，本地轮转 |
| 集中化审计 | 配置 `rsyslog` 转发到 SIEM，本地保留 7 天 |
| 高安全环境 | `log_format=ENRICHED`，远程实时传输，本地加密存储 |

### 6.4 定期维护清单

```bash
# 每日检查
$ sudo ausearch --start today -m ANOM_ABEND --interpret    # 异常终止
$ sudo aureport -n --start today                           # 异常事件

# 每周检查
$ sudo aureport --summary --start last-week                   # 周度摘要
$ sudo df -h /var/log/audit/                                # 磁盘空间

# 每月检查
$ sudo auditctl -s                                          # 审计状态
$ sudo auditctl -l | wc -l                                  # 规则数量监控
```

## 7. 常见问题排查

### 7.1 问题速查表

| 问题现象 | 可能原因 | 解决方案 |
|---------|---------|---------|
| 规则添加失败 `Invalid argument` | 系统调用名拼写错误或架构不匹配 | 使用 `ausyscall --dump` 核实；确认 `arch` 参数正确 |
| 日志中无预期事件 | 规则未生效或被更高优先级规则覆盖 | `auditctl -l` 检查规则顺序；确认 `-e 1` 已启用 |
| auditd 无法启动 | 内核审计子系统被禁用或端口占用 | 检查 `GRUB_CMDLINE_LINUX` 中是否有 `audit=0`；确认无其他进程绑定 netlink socket |
| 日志量过大导致磁盘满 | 缺少轮转配置或规则过于宽泛 | 调整 `auditd.conf` 轮转参数；避免监控 `/proc`、`/sys` 等高频路径 |
| `ausearch` 返回空结果 | 时间范围不对或关键字拼写错误 | 使用 `--start recent` 缩小范围；确认 `-k` 值与规则一致 |
| 审计事件丢失（`lost` 计数增加） | 内核缓冲区不足或速率限制过低 | 增大 `backlog_limit`：`auditctl -b 16384`；调整 `rate_limit` |
| 规则重启后丢失 | 仅使用了 `auditctl` 未写入规则文件 | 将规则写入 `/etc/audit/rules.d/*.rules` 并执行 `augenrules --load` |
| auid 显示为 `-1` | 进程未通过正常登录会话启动 | 这是预期行为（如系统服务）；对于用户进程，检查 PAM 配置是否设置 `pam_loginuid.so` |

### 7.2 诊断命令集

```bash
# 查看内核审计状态
$ sudo auditctl -s

# 查看当前所有规则
$ sudo auditctl -l

# 查看规则数量
$ sudo auditctl -l | wc -l

# 查看丢失的审计事件数
$ sudo auditctl -s | grep lost

# 查看 auditd 进程日志
$ sudo journalctl -u auditd -f

# 查看 auditd 配置文件语法
$ sudo auditd -f -c /etc/audit/auditd.conf

# 测试规则文件语法
$ sudo augenrules --check
```

### 7.3 内核启动参数检查

```bash
# 检查 GRUB 配置中是否禁用了审计
$ grep audit /etc/default/grub
# 不应出现 audit=0

# 检查当前内核参数
$ cat /proc/cmdline | grep audit

# 如果存在 audit=0，需修改 GRUB 配置并重建
$ sudo grub2-mkconfig -o /boot/grub2/grub.cfg
# 重启后生效
```

## 8. 参考资源

- [Linux Audit Documentation Wiki](https://github.com/linux-audit/audit-documentation/wiki)
- [auditctl 手册页](https://man7.org/linux/man-pages/man8/auditctl.8.html)
- [ausearch 手册页](https://man7.org/linux/man-pages/man8/ausearch.8.html)
- [aureport 手册页](https://man7.org/linux/man-pages/man8/aureport.8.html)
- [Red Hat Security Guide - System Auditing](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/9/html/security_hardening/auditing-the-system_security-hardening)
- https://blog.csdn.net/Keyuchen_01/article/details/113629205
- https://blog.csdn.net/ayychiguoguo/article/details/140526556

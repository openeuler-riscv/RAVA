### 1. Nmap介绍

Nmap（Network Mapper）是一款用于网络发现和安全审计的开源工具，由 Gordon Lyon（也被称为 Fyodor Vaskovich）开发。它允许用户在网络上执行主机发现、端口扫描、服务识别和版本检测等操作，以帮助评估网络的安全性、发现主机和服务、以及识别潜在的安全威胁。其核心功能包含：

- 主机发现：探测网络中的存活设备（如-sP扫描局域网存活主机） 
- 端口扫描：识别开放端口及状态（开放/关闭/过滤）
- 服务识别：检测端口对应的服务及版本（如-sV参数）
- 操作系统检测：通过指纹识别目标系统（如-O参数）
- NSE脚本扩展：使用NSE脚本实现漏洞扫描、密码爆破等高级功能 
- 输出格式： 支持文本、XML、JSON 等多种格式的结果导出

### 2. 安装

在openEuler系统可通过包管理器安装软件包

```Plain
dnf update && dnf install -y nmap
```

### 3. 基本语法

Nmap 的命令行结构遵循以下通用模式：

```Plain
nmap [扫描类型] [选项] <目标>
```

- 扫描类型：用于指定执行的操作类型，如 `-sS`（SYN 扫描）、`-sn`（Ping 扫描）等。
- 选项：用于微调扫描行为的各种参数，例如 `-p`（指定端口）、`-T4`（设置时序模板）、`--script`（运行脚本）等。
- 目标：扫描的对象，可以是单个 IP、IP 范围、域名或包含多个目标的文，当前支持的目标格式包含：

查看nmap支持的选项

```
$ nmap --help
Nmap 7.94 ( https://nmap.org )
Usage: nmap [Scan Type(s)] [Options] {target specification}
TARGET SPECIFICATION:
  Can pass hostnames, IP addresses, networks, etc.
  Ex: scanme.nmap.org, microsoft.com/24, 192.168.0.1; 10.0.0-255.1-254
  -iL <inputfilename>: Input from list of hosts/networks
  -iR <num hosts>: Choose random targets
  --exclude <host1[,host2][,host3],...>: Exclude hosts/networks
  --excludefile <exclude_file>: Exclude list from file
HOST DISCOVERY:
  -sL: List Scan - simply list targets to scan
  -sn: Ping Scan - disable port scan
  -Pn: Treat all hosts as online -- skip host discovery
  -PS/PA/PU/PY[portlist]: TCP SYN/ACK, UDP or SCTP discovery to given ports
  -PE/PP/PM: ICMP echo, timestamp, and netmask request discovery probes
  -PO[protocol list]: IP Protocol Ping
  -n/-R: Never do DNS resolution/Always resolve [default: sometimes]
  --dns-servers <serv1[,serv2],...>: Specify custom DNS servers
  --system-dns: Use OS's DNS resolver
  --traceroute: Trace hop path to each host
SCAN TECHNIQUES:
  -sS/sT/sA/sW/sM: TCP SYN/Connect()/ACK/Window/Maimon scans
  -sU: UDP Scan
  -sN/sF/sX: TCP Null, FIN, and Xmas scans
  --scanflags <flags>: Customize TCP scan flags
  -sI <zombie host[:probeport]>: Idle scan
  -sY/sZ: SCTP INIT/COOKIE-ECHO scans
  -sO: IP protocol scan
  -b <FTP relay host>: FTP bounce scan
PORT SPECIFICATION AND SCAN ORDER:
  -p <port ranges>: Only scan specified ports
    Ex: -p22; -p1-65535; -p U:53,111,137,T:21-25,80,139,8080,S:9
  --exclude-ports <port ranges>: Exclude the specified ports from scanning
  -F: Fast mode - Scan fewer ports than the default scan
  -r: Scan ports sequentially - don't randomize
  --top-ports <number>: Scan <number> most common ports
  --port-ratio <ratio>: Scan ports more common than <ratio>
SERVICE/VERSION DETECTION:
  -sV: Probe open ports to determine service/version info
  --version-intensity <level>: Set from 0 (light) to 9 (try all probes)
  --version-light: Limit to most likely probes (intensity 2)
  --version-all: Try every single probe (intensity 9)
  --version-trace: Show detailed version scan activity (for debugging)
SCRIPT SCAN:
  -sC: equivalent to --script=default
  --script=<Lua scripts>: <Lua scripts> is a comma separated list of
           directories, script-files or script-categories
  --script-args=<n1=v1,[n2=v2,...]>: provide arguments to scripts
  --script-args-file=filename: provide NSE script args in a file
  --script-trace: Show all data sent and received
  --script-updatedb: Update the script database.
  --script-help=<Lua scripts>: Show help about scripts.
           <Lua scripts> is a comma-separated list of script-files or
           script-categories.
OS DETECTION:
  -O: Enable OS detection
  --osscan-limit: Limit OS detection to promising targets
  --osscan-guess: Guess OS more aggressively
TIMING AND PERFORMANCE:
  Options which take <time> are in seconds, or append 'ms' (milliseconds),
  's' (seconds), 'm' (minutes), or 'h' (hours) to the value (e.g. 30m).
  -T<0-5>: Set timing template (higher is faster)
  --min-hostgroup/max-hostgroup <size>: Parallel host scan group sizes
  --min-parallelism/max-parallelism <numprobes>: Probe parallelization
  --min-rtt-timeout/max-rtt-timeout/initial-rtt-timeout <time>: Specifies
      probe round trip time.
  --max-retries <tries>: Caps number of port scan probe retransmissions.
  --host-timeout <time>: Give up on target after this long
  --scan-delay/--max-scan-delay <time>: Adjust delay between probes
  --min-rate <number>: Send packets no slower than <number> per second
  --max-rate <number>: Send packets no faster than <number> per second
FIREWALL/IDS EVASION AND SPOOFING:
  -f; --mtu <val>: fragment packets (optionally w/given MTU)
  -D <decoy1,decoy2[,ME],...>: Cloak a scan with decoys
  -S <IP_Address>: Spoof source address
  -e <iface>: Use specified interface
  -g/--source-port <portnum>: Use given port number
  --proxies <url1,[url2],...>: Relay connections through HTTP/SOCKS4 proxies
  --data <hex string>: Append a custom payload to sent packets
  --data-string <string>: Append a custom ASCII string to sent packets
  --data-length <num>: Append random data to sent packets
  --ip-options <options>: Send packets with specified ip options
  --ttl <val>: Set IP time-to-live field
  --spoof-mac <mac address/prefix/vendor name>: Spoof your MAC address
  --badsum: Send packets with a bogus TCP/UDP/SCTP checksum
OUTPUT:
  -oN/-oX/-oS/-oG <file>: Output scan in normal, XML, s|<rIpt kIddi3,
     and Grepable format, respectively, to the given filename.
  -oA <basename>: Output in the three major formats at once
  -v: Increase verbosity level (use -vv or more for greater effect)
  -d: Increase debugging level (use -dd or more for greater effect)
  --reason: Display the reason a port is in a particular state
  --open: Only show open (or possibly open) ports
  --packet-trace: Show all packets sent and received
  --iflist: Print host interfaces and routes (for debugging)
  --append-output: Append to rather than clobber specified output files
  --resume <filename>: Resume an aborted scan
  --noninteractive: Disable runtime interactions via keyboard
  --stylesheet <path/URL>: XSL stylesheet to transform XML output to HTML
  --webxml: Reference stylesheet from Nmap.Org for more portable XML
  --no-stylesheet: Prevent associating of XSL stylesheet w/XML output
MISC:
  -6: Enable IPv6 scanning
  -A: Enable OS detection, version detection, script scanning, and traceroute
  --datadir <dirname>: Specify custom Nmap data file location
  --send-eth/--send-ip: Send using raw ethernet frames or IP packets
  --privileged: Assume that the user is fully privileged
  --unprivileged: Assume the user lacks raw socket privileges
  -V: Print version number
  -h: Print this help summary page.
EXAMPLES:
  nmap -v -A scanme.nmap.org
  nmap -v -sn 192.168.0.0/16 10.0.0.0/8
  nmap -v -iR 10000 -Pn -p 80
SEE THE MAN PAGE (https://nmap.org/book/man.html) FOR MORE OPTIONS AND EXAMPLES
```

### 4. Nmap扫描

#### 4.1 主机发现（ping扫描）

在开始端口扫描之前，Nmap 默认会先确定目标主机是否在线（即“存活”）。这个过程称为主机发现。在某些网络环境中，主机可能会禁用 ICMP（Ping）响应，导致默认的发现机制失效。

| 参数          | 说明                                                         | 适用场景                                                     |
| ------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| -sn           | No port scan。仅执行主机发现，不进行任何端口扫描。这是替代旧版 -sP 的参数。 | 快速绘制网络拓扑图，找出所有活跃设备。                       |
| -Pn           | Treat all hosts as online。跳过主机发现阶段，假设所有指定的目标都是存活的。 | 当目标主机屏蔽了 Ping 请求，但你知道它在线（例如 Web 服务器）。 |
| -PS[端口列表] | 使用 TCP SYN 包进行主机发现。例如 -PS22,80 会向 22 和 80 端口发送 SYN 包。 | 绕过仅屏蔽 ICMP 的防火墙。                                   |
| -PA[端口列表] | 使用 TCP ACK 包进行主机发现。                                | 用于探测 stateful 防火墙的行为。                             |
| -PU[端口列表] | 使用 UDP 包进行主机发现。                                    | 探测开启了 UDP 服务（如 DNS）但屏蔽 ICMP 的主机。            |

示例：

```Plain
#内部网络进行资产清点
nmap -sn 192.168.0.0/24
#对外部目标进行渗透测试，如果ping不通
nmap -Pn <target>
```

#### 4.2 端口扫描技术

端口扫描是 Nmap 的核心功能。不同的扫描技术适用于不同的网络环境和安全策略。

| 参数  | 名称                 | 工作原理                                                    | 优点                                                       | 缺点                                                         |
| ----- | -------------------- | ----------------------------------------------------------- | ---------------------------------------------------------- | ------------------------------------------------------------ |
| `-sS` | **TCP SYN 扫描**     | 发送 SYN 包，收到 SYN/ACK 后不发送 ACK，直接断开。          | **速度快、隐蔽性强**（不会在应用层日志留下完整连接记录）。 | 需要 root/admin 权限（因为要构造原始数据包）。               |
| `-sT` | **TCP Connect 扫描** | 使用操作系统提供的 `connect()` 系统调用完成完整的三次握手。 | 无需特殊权限，普通用户即可运行。                           | **速度慢、易被日志记录**（目标系统会记录一次完整的连接）。   |
| `-sU` | **UDP 扫描**         | 向 UDP 端口发送空包或协议特定的探针。                       | 是发现 DNS、SNMP、DHCP 等 UDP 服务的唯一方法。             | **非常慢且不可靠**。很多服务对空 UDP 包无响应，Nmap 只能靠超时判断端口状态。 |
| `-sA` | **TCP ACK 扫描**     | 发送 ACK 包，根据返回的 RST 包来判断端口是否被过滤。        | 主要用于**映射防火墙规则集**，而非发现开放端口。           | 无法区分 `open` 和 `closed` 状态，只能判断 `unfiltered` 或 `filtered`。 |
| `-sX` | **Xmas 扫描**        | 设置 FIN、PSH、URG 三个 TCP 标志位，像圣诞树一样“点亮”。    | 非常隐蔽，许多老旧 IDS 无法识别。                          | 在现代操作系统上效果不佳，通常所有端口都返回 `closed`。      |
| `-sN` | **Null 扫描**        | 不设置任何 TCP 标志位。                                     | 与 Xmas 扫描类似，用于绕过 IDS。                           | 同样，在现代系统上效果有限。                                 |

注意：绝大多数场景下，-sS（SYN扫描）是最佳选择，仅在没有root权限时使用-sT。

#### 4.3 服务与版本探测

| 参数                        | 说明                                                         |
| --------------------------- | ------------------------------------------------------------ |
| `-sV`                       | **启用版本探测**。Nmap 会向开放的端口发送一系列精心设计的探针，并分析响应以确定服务名称、版本、甚至有时包括模块信息。 |
| `--version-intensity <0-9>` | 控制探测的强度。数值越高，发送的探针越多，结果越准确，但速度越慢。默认值为 7。 |
| `--version-light`           | 等价于 `--version-intensity 2`，牺牲部分准确性换取速度。     |
| `--version-all`             | 等价于 `--version-intensity 9`，进行最全面的探测。           |

示例：

```Bash
# 基础版本探测
nmap -sV 192.168.1.10

# 快速但粗略的探测
nmap -sV --version-light 192.168.1.10

# 对一台关键服务器进行深度探测
nmap -sV --version-all -T2 192.168.1.100
```

#### 4.4 操作系统识别

通过分析 TCP/IP 协议栈的细微差异（如 TCP 窗口大小、TTL 值、DF 位等），Nmap 可以相当准确地猜测远程主机的操作系统。

| 参数             | 说明                                                         |
| ---------------- | ------------------------------------------------------------ |
| `-O`             | **启用 OS 识别**。                                           |
| `--osscan-limit` | 为了提高效率，仅对至少有一个开放和一个关闭端口的主机尝试 OS 识别。因为这能提供更丰富的指纹信息。 |
| `--osscan-guess` | 当匹配度不高时，Nmap 会提供多个可能的 OS 猜测，并给出置信度百分比。 |

注意：OS识别不一定100%准确，尤其是在面对经过特殊加固或虚拟化的系统时。

#### 4.5 NSE 脚本引擎

**NSE**（Nmap Scripting Engine）脚本使用 Lua 语言编写，按功能分为多个类别。你可以通过类别名或具体脚本名来调用它们。

| 类别        | 说明                                                | 风险等级                   |
| ----------- | --------------------------------------------------- | -------------------------- |
| `vuln`      | 检测已知的安全漏洞（如 Heartbleed, Shellshock）。   | **高**（可能触发警报）     |
| `safe`      | 执行安全、无害的信息收集操作。                      | **低**                     |
| `discovery` | 用于服务发现和枚举（如 `dns-brute`, `http-enum`）。 | **中**                     |
| `exploit`   | **直接利用漏洞**。                                  | **极高**（仅限授权测试！） |
| `auth`      | 测试弱认证或默认凭证。                              | **中高**                   |
| `default`   | Nmap 在使用 `-sC` 或 `-A` 时会自动运行的脚本集合。  | **低至中**                 |

示例：

```Bash
# 运行单个脚本
nmap --script http-title example.com
# 运行整个类别
nmap --script vuln 192.168.1.10
# 运行多个脚本
nmap -p 22 --script ssh-auth-methods,ssh2-enum-algos 192.168.1.10
# 传递参数给脚本
nmap -p 22 --script ssh-run --script-args="sshrun.username=root,sshrun.password=openEuler12#$,sshrun.cmd=id" 192.168.1.10
```

**脚本位置**：在 Linux上，脚本通常位于 `/usr/share/nmap/scripts/`,每个脚本文件开头都有详细的注释说明其用途和参数。支持`nmap --script-help scriptname`查看脚本帮助信息

#### 4.6 输出格式

Nmap 提供了多种输出格式以满足不同需求。

| 参数             | 说明                                                         | 适用场景                                                     |
| ---------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| `-oN <file>`     | **Normal output**。生成人类可读的普通文本报告。              | 直接阅读、邮件发送。                                         |
| `-oX <file>`     | **XML output**。生成结构化的 XML 报告。                      | **最重要**！可被其他工具（如 Metasploit, Nessus, 自定义脚本）解析和导入。 |
| `-oG <file>`     | **Greppable output**。生成便于 `grep`, `awk`, `cut` 等命令行工具处理的格式。 | 快速提取特定信息（如所有开放 22 端口的 IP）。                |
| `-oA <basename>` | **All formats**。一次性生成 `.nmap`, `.xml`, `.gnmap` 三种格式的文件。 | **强烈推荐**！兼顾了可读性和可编程性。                       |

#### 4.7 性能与效率调优

大规模网络扫描时可以添加下列参数提高性能。

- **时序模板 (`-T`)**：Nmap 提供了从 `paranoid` (`-T0`) 到 `insane` (`-T5`) 的六种预设模板。`-T4`（aggressive）是速度和可靠性的良好平衡点。
- **自定义速率**：`--min-rate 1000` 强制 Nmap 每秒至少发送 1000 个包，可极大加速扫描，但可能对网络造成压力。
- **减少重试**：`--max-retries 1` 将重试次数从默认的 10 次减少到 1 次，适合在稳定网络中使用。

### 5. 执行测试

进行主机端口扫描

```
$ nmap -sS -sV -p- 127.0.0.1 
Starting Nmap 7.94 ( https://nmap.org ) at 2026-04-23 01:43 UTC
Nmap scan report for localhost (127.0.0.1)
Host is up (0.00045s latency).
Not shown: 65534 closed tcp ports (reset)
PORT   STATE SERVICE VERSION
22/tcp open  ssh     OpenSSH 9.6 (protocol 2.0)

Service detection performed. Please report any incorrect results at https://nmap.org/submit/ .
Nmap done: 1 IP address (1 host up) scanned in 59.56 seconds
```

扫描出结果显示系统仅开放22端口，针对ssh服务可用NSE跑ssh脚本进行ssh配置检查。

(1) 认证方式分析

```
$ nmap -p 22 --script ssh-auth-methods 127.0.0.1
Starting Nmap 7.94 ( https://nmap.org ) at 2026-04-23 02:05 UTC
Nmap scan report for localhost (127.0.0.1)
Host is up (0.0025s latency).

PORT   STATE SERVICE
22/tcp open  ssh
| ssh-auth-methods: 
|   Supported authentication methods: 
|     publickey
|     gssapi-keyex
|     gssapi-with-mic
|_    password

Nmap done: 1 IP address (1 host up) scanned in 3.47 seconds

```

从结果可以看出当前支持publickey认证且无过时认证方式（如 keyboard-interactive 单独暴露），但系统允许password认证可能存在暴力破解的风险。

(2)加密算法分析

```
$ nmap -p 22 --script ssh2-enum-algos 10.0.0.20
Starting Nmap 7.94 ( https://nmap.org ) at 2026-04-23 02:08 UTC
Nmap scan report for 10.0.0.20
Host is up (0.0048s latency).

PORT   STATE SERVICE
22/tcp open  ssh
| ssh2-enum-algos: 
|   kex_algorithms: (5)
|       curve25519-sha256
|       curve25519-sha256@libssh.org
|       diffie-hellman-group-exchange-sha256
|       ext-info-s
|       kex-strict-s-v00@openssh.com
|   server_host_key_algorithms: (3)
|       rsa-sha2-512
|       rsa-sha2-256
|       ssh-ed25519
|   encryption_algorithms: (6)
|       aes128-ctr
|       aes192-ctr
|       aes256-ctr
|       aes128-gcm@openssh.com
|       aes256-gcm@openssh.com
|       chacha20-poly1305@openssh.com
|   mac_algorithms: (4)
|       hmac-sha2-512
|       hmac-sha2-512-etm@openssh.com
|       hmac-sha2-256
|       hmac-sha2-256-etm@openssh.com
|   compression_algorithms: (2)
|       none
|_      zlib@openssh.com
MAC Address: 52:54:00:11:45:20 (QEMU virtual NIC)

Nmap done: 1 IP address (1 host up) scanned in 4.01 seconds
```

从结果分析当前支持现代加密算法（curve25519、chacha20-poly1305等），未发现未发现弱加密或已弃用算法。

（3）检查是否支持SSHv1

```
nmap --script sshv1 -p 22 127.0.0.1
Starting Nmap 7.94 ( https://nmap.org ) at 2026-04-23 02:51 UTC
Nmap scan report for localhost (127.0.0.1)
Host is up (0.0018s latency).

PORT   STATE SERVICE
22/tcp open  ssh

Nmap done: 1 IP address (1 host up) scanned in 3.14 seconds
```

从结果分析当前不支持SSHv1。

参考：

NSE脚本文档：https://nmap.org/nsedoc/scripts/

官方手册：https://nmap.org/man/zh/
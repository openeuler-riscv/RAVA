#### **一、工具简介与核心功能**

LinPEAS 是一个 Bash 脚本，通过系统化的扫描和分析，帮助渗透测试人员和安全研究员快速识别 Linux 系统中的潜在提权路径 。它通过检查系统配置、文件权限、进程、服务、软件版本等超过 15 个类别的风险项，实现高覆盖率的自动化枚举 。

其核心检查模块包括 ：

| 模块名称                 | 检查内容                                                     | 主要目的                           |
| :----------------------- | :----------------------------------------------------------- | :--------------------------------- |
| **系统信息**             | 内核版本、发行版、CVE漏洞、保护机制（SELinux, AppArmor, ASLR）、环境变量 | 识别系统层面的漏洞和配置缺陷       |
| **容器**                 | Docker, LXC等容器环境检测、容器逃逸向量                      | 发现容器隔离突破的可能性           |
| **云环境**               | AWS, Azure, GCP等云服务元数据和凭据                          | 寻找泄露的云服务密钥               |
| **进程、定时任务、服务** | 运行进程、cron jobs、systemd定时器与服务                     | 分析高权限进程和可被篡改的定时任务 |
| **网络信息**             | 网络接口、开放端口、防火墙规则、DNS设置                      | 了解网络配置和潜在暴露面           |
| **用户信息**             | 用户、组、sudo权限、登录会话                                 | 发现用户权限配置不当问题           |
| **软件信息**             | 已安装软件包、数据库配置                                     | 识别存在已知漏洞的软件版本         |
| **有趣权限的文件**       | SUID/SGID文件、全局可写文件、Linux Capabilities              | 寻找因文件权限设置不当导致的提权点 |
| **其他有趣文件**         | 配置文件、备份文件、日志文件、脚本                           | 搜索包含密码、密钥等敏感信息的文件 |
| **API密钥正则匹配**      | 使用正则表达式匹配AWS、GitHub、数据库等各类密钥格式          | 自动化发现硬编码的凭据             |

---

#### **二、获取与安装**

LinPEAS 是一个独立的 Bash 脚本，可以从其官方 GitHub 仓库直接下载 。

**1. 标准下载（推荐）**
使用 `wget` 或 `curl` 从最新发布版本下载。通常使用 `linpeas.sh` 标准版本，它兼容性最好。

```bash
# 使用 wget 下载 
wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh

# 或使用 curl 下载
curl -L https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh -o linpeas.sh

# 下载后赋予执行权限 
chmod +x linpeas.sh
```

#### **三、执行方式与参数详解**

LinPEAS 支持多种执行方式和丰富的命令行参数，以适应不同环境和测试需求。

**1. 基本执行**
最简单的执行方式，将运行所有默认检查（不包括耗时极长的检查）。

```bash
./linpeas.sh
```

**2. 常用命令行参数**
通过参数可以定制扫描行为，提高效率或规避检测。

| 参数        | 功能描述                                                     | 使用示例                                                 |
| :---------- | :----------------------------------------------------------- | :------------------------------------------------------- |
| `-a`        | 执行所有检查项，包括耗时较长的进程监控（1分钟）、`su` 暴力破解、额外枚举等。适用于全面扫描。 | `./linpeas.sh -a`                                        |
| `-s`        | 静默 & 快速模式：跳过一些耗时的检查项，加快执行速度，适合初步快速侦察。 | `./linpeas.sh -s`                                        |
| `-e`        | 启用额外枚举（Extra enumeration），收集更多系统细节（如环境变量、历史命令等）。 | `./linpeas.sh -e`                                        |
| `-o`        | 仅执行指定模块的检查。可选模块包括：`system_information`, `users_information`, `software_information`, `interesting_perms_files` 等。 | `./linpeas.sh -o users_information,software_information` |
| `-P <密码>` | 提供一个密码，用于： 1. 执行 `sudo -l`（尝试列出可执行的 sudo 命令） 2. 对其他用户进行 `su` 暴力破解（使用内置 top1000 密码字典） | `./linpeas.sh -P 'admin123'`                             |
| `-r`        | 启用正则表达式扫描，在文件中搜索 API 密钥、密码、密钥等敏感信息（可能非常耗时，从几分钟到几小时）。 | `./linpeas.sh -r`                                        |
| `-n`        | 跳过将主机名/IP 与已知恶意列表（如泄露数据库、黑名单）进行比对的步骤，提升隐私性或速度。 | `./linpeas.sh -n`                                        |

```
[root@localhost tmp]# ./linpeas.sh -h
Enumerate and search Privilege Escalation vectors.
This tool enum and search possible misconfigurations (known vulns, user, processes and file permissions, special file permissions, readable/writable files, bruteforce other users(top1000pwds), passwords...) inside the host and highlight possible misconfigurations with colors.
        Checks:
            -a Perform all checks: 1 min of processes, su brute, and extra checks.
            -o Only execute selected checks (system_information,container,cloud,procs_crons_timers_srvcs_sockets,network_information,users_information,software_information,interesting_perms_files,interesting_files,api_keys_regex). Select a comma separated list.
            -T Only execute checks matching the specified MITRE ATT&CK technique(s). Ex: -T T1057,T1082
            -s Stealth & faster (don't check some time consuming checks)
            -e Perform extra enumeration
            -r Enable Regexes (this can take from some mins to hours)
            -P Indicate a password that will be used to run 'sudo -l' and to bruteforce other users accounts via 'su'
            -n Do not check hostname & IP in known malicious lists and leaks
	    -D Debug mode
        Network recon:
            -t Automatic network scan - This option writes to files
	    -d <IP/NETMASK> Discover hosts using fping or ping. Ex: -d 192.168.0.1/24
            -p <PORT(s)> -d <IP/NETMASK> Discover hosts looking for TCP open ports (via nc). By default ports 22,80,443,445,3389 and another one indicated by you will be scanned (select 22 if you don't want to add more). You can also add a list of ports. Ex: -d 192.168.0.1/24 -p 53,139
            -i <IP> [-p <PORT(s)>] Scan an IP using nc. By default (no -p), top1000 of nmap will be scanned, but you can select a list of ports instead. Ex: -i 127.0.0.1 -p 53,80,443,8000,8080
             Notice that if you specify some network scan (options -d/-p/-i but NOT -t), no PE check will be performed
        Port forwarding (reverse connection):
            -F LOCAL_IP:LOCAL_PORT:REMOTE_IP:REMOTE_PORT Execute linpeas to forward a port from a your host (LOCAL_IP:LOCAL_PORT) to a remote IP (REMOTE_IP:REMOTE_PORT)
        Firmware recon:
            -f </FOLDER/PATH> Execute linpeas to search passwords/file permissions misconfigs inside a folder
        Misc:
            -h To show this message
	        -w Wait execution between big blocks of checks
            -L Force linpeas execution
            -M Force macpeas execution
	        -q Do not show banner
            -N Do not use colours
            -z <N> Set number of threads for background checks (default: auto-detected CPU count, fallback: 2; must be >= 1)

```

#### **四、输出解读与颜色编码**

LinPEAS 使用一套**颜色编码系统**来直观地标识发现项的风险等级，方便快速聚焦高风险问题 。

| 颜色                         | 含义                                                         | 示例与行动建议                                               |
| :--------------------------- | :----------------------------------------------------------- | :----------------------------------------------------------- |
| **红色/黄色 (Red/Yellow )**  | 用于标识几乎可以确定（99% 确定）会导致权限提升（Privilege Escalation, PE）的配置。 | `[+] SUID binaries` 下列出的异常SUID文件；发现已知的本地提权内核漏洞 (CVE)。 |
| **红色 (RED)**               | 用于标识可疑的配置，这些配置**可能**导致权限提升。           | 某些不常见的可写目录；不标准的 cron 任务。                   |
| **绿色 (GREEN)**             | 用于标识已知的良好配置（注意：这是基于配置项的名称判断的，而非其实际内容！）。 | 保护机制已启用（如 `SELinux status: enabled`）。             |
| **蓝色 (BLUE)**              | 用于标识**无 shell 的用户**和**已挂载的设备**。              | 在 `/etc/passwd` 中发现的 `nologin` 用户。                   |
| **浅青色(Light Cyan)**       | 用于标识**拥有 shell 的用户**。                              | `Current user: www-data`；`Network & IP info:`。             |
| **浅洋红色 (Light Magenta)** | 用户标识当前用户名                                           | 用户列表中的当前用户名会以此颜色突出显示。                   |

#### **五、实战应用示例**

**步骤 1：信息收集与上传**
```bash
# 在攻击机上，下载LinPEAS
wget https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh
chmod +x linpeas.sh
```

**步骤 2：执行扫描**
为了快速获取关键信息，可以先运行核心模块 。
```bash
./linpeas.sh -o system_information user_information processes_info sudo
```

**步骤 3：分析结果并提权**
根据彩色输出进行分析。例如：
* **红色/黄色警报**：发现 `/usr/bin/pkexec` 存在 SUID 位，并且系统内核版本匹配 **CVE-2021-4034 (PwnKit)**。这是一个高风险的提权漏洞 。

  **行动**：搜索或编译该 CVE 的公开利用代码，在目标机上编译执行，可能直接获得 root 权限。

* **红色警告**：发现一个自定义的 cron job 以 root 身份运行脚本 `/opt/scripts/backup.sh`，且该脚本对 `www-data` 用户可写。

  **行动**：编辑 `/opt/scripts/backup.sh` 文件，插入反向 Shell 或添加 SUID Shell 的命令（如 `chmod u+s /bin/bash`），等待 cron 执行 。

**步骤 4：清理痕迹（可选）**
在授权测试结束后，可以考虑清理上传的工具。

```bash
rm /tmp/linpeas.sh
history -c
```

#### **六、最佳实践与注意事项**

1. **输出重定向**：将扫描结果保存到文件以便仔细分析。

   ```bash
   ./linpeas.sh > linpeas_report.txt 2>&1
   ```

2. **结合其他工具**：LinPEAS 是出色的枚举工具，但提权利用可能需要结合其他专门工具，如针对特定内核漏洞的 exploit，或用于搜索敏感文件的 `find`、`strings` 命令。

3. **理解误报**：自动化工具可能存在误报。所有发现都需要**手动验证**其真实性和可利用性。例如，一个标记为 SUID 的系统二进制文件（如 `/usr/bin/passwd`）通常是正常的，需要关注的是非标准的 SUID 文件。

4. **持续更新**：PEASS 项目持续更新以覆盖新的漏洞和检查项。定期从官方仓库获取最新版本 。

参考：

1.[Linux自动化安全检测与权限审计工具：LinPEAS深度解析与实践指南 - AtomGit | GitCode博客](https://blog.gitcode.com/b79665cf58152e757da781fe6e03576b.html)

2.[如何快速掌握LinPEAS：Linux权限提升自动化检测工具详解-CSDN博客](https://blog.csdn.net/gitblog_00875/article/details/154962858)

3.[权限提升-PEAS使用 | Yuy0ung的知识库](https://yuy0ung.github.io/blog/内网渗透/权限提升/权限提升-peas使用/)

4.[PEASS 项目详解：渗透测试必备的提权检测神器_winpeas-CSDN博客](https://blog.csdn.net/2301_79518550/article/details/146030391)
## 1. 介绍

AIDE（Advanced Intrusion Detection Environment）是一个用于检测文件完整性的工具。它通过创建文件的初始数据库，并在后续的检测中对比文件的当前状态与初始数据库，来发现文件的更改。AIDE 可以用于检测未经授权的文件修改，帮助系统管理员及时发现潜在的安全问题。

## 2. 安装

在openEuler系统可通过包管理器安装软件包：

```bash
dnf update && dnf install -y aide
```

## 3. 基本语法

AIDE 的命令行结构遵循以下通用模式：

```bash
aide [选项] <命令>
```

- **命令**：用于指定执行的操作类型，如 `--init`（初始化数据库）、`--check`（执行完整性检查）、`--update`（更新数据库）等。
- **选项**：用于微调行为的各种参数，例如 `-c`（指定配置文件）、`-V`（设置详细级别）、`-B`（覆盖配置项）等。

查看aide支持的选项：

```bash
$ aide --help
AIDE 0.18.6 

Usage: aide [options] command

Commands:
  -i, --init		Initialize the database
  -n, --dry-init	Traverse the file system and match each file against rule tree
  -C, --check		Check the database
  -u, --update		Check and update the database non-interactively
  -E, --compare		Compare two databases

Miscellaneous:
  -D,			--config-check			Test the configuration file
  -p FILE_TYPE:PATH	--path-check=FILE_TYPE:PATH	Match file type and path against rule tree
  -v,			--version			Show version of AIDE and compilation options
  -h,			--help				Show this help message

Options:
  -c CFGFILE	--config=CFGFILE	Get config options from CFGFILE
  -l REGEX	--limit=REGEX		Limit command to entries matching REGEX
  -B "OPTION"	--before="OPTION"	Before configuration file is read define OPTION
  -A "OPTION"	--after="OPTION"	After configuration file is read define OPTION
  -L LEVEL	--log-level=LEVEL	Set log message level to LEVEL
  -W WORKERS	--workers=WORKERS	Number of simultaneous workers (threads) for file attribute processing (i.a. hashsum calculation)
```

## 4. AIDE核心功能

### 4.1 数据库初始化

在使用AIDE之前，必须先生成基准数据库。该过程会扫描配置文件中定义的所有路径，计算哈希值和元数据并存储到数据库中。

| 参数            | 说明                                                         | 适用场景                                 |
| --------------- | ------------------------------------------------------------ | ---------------------------------------- |
| `--init` / `-i` | 扫描文件系统并生成新的基准数据库（默认路径 `/var/lib/aide/aide.db.new.gz`）。 | 系统刚安装完、完成安全加固后首次部署时。 |
| `-c <file>`     | 指定非默认的配置文件路径。                                   | 多环境管理或测试不同监控策略时。         |

示例：

```bash
# 使用默认配置初始化数据库
aide --init

# 使用自定义配置
aide -c /etc/aide/custom.conf -i
```

注意：初始化完成后，需手动将 `aide.db.new.gz` 重命名为 `aide.db.gz` 才能用于后续检查。

### 4.2 完整性检查

检查阶段会将当前文件系统状态与基准数据库进行逐项比对，识别所有偏差。

| 参数             | 说明                                         |
| ---------------- | -------------------------------------------- |
| `--check` / `-C` | 执行完整性检查，输出差异报告。               |
| `--workers=N`    | 启用多线程并行扫描，提升大文件系统检查速度。 |

示例：

```bash
# 基础完整性检查
aide --check

# 以输出报告并使用4线程加速
aide --check --workers=4 > /tmp/check.log
```

### 4.3 数据库更新

当确认某些文件变更属于合法操作（如系统升级、配置调整）后，需要更新基准数据库以避免重复告警。

| 参数              | 说明                                                         |
| ----------------- | ------------------------------------------------------------ |
| `--update` / `-u` | 执行检查并将新数据库自动复制为基准数据库（等价于 check + mv）。 |
| `--compare`       | 仅比较两个数据库文件而不扫描实际文件系统，用于验证数据库一致性。 |

注意：`--update` 应在人工审核变更合法性后执行，切勿盲目自动更新，否则可能掩盖真实入侵痕迹。

### 4.4 配置与规则定义

AIDE的行为完全由配置文件（默认 `/etc/aide.conf`）控制，核心是规则定义和路径选择。

| 指令                         | 说明                                                 | 风险等级 |
| ---------------------------- | ---------------------------------------------------- | -------- |
| `define RULE_NAME attr_list` | 定义命名规则，如 `NORMAL = p+i+n+u+g+s+m+c+sha256`。 | 低       |
| `/path/to/dir RULE_NAME`     | 对指定目录应用某条规则进行递归监控。                 | 中       |
| `!/path/to/exclude`          | 排除特定路径不被扫描。                               | 低       |
| `@@x_include <file>`         | 包含外部配置片段，便于模块化管理。                   | 低       |

常用属性缩写：

- `p`: permissions
- `i`: inode
- `n`: number of links
- `u`: user
- `g`: group
- `s`: size
- `m`: mtime修改时间
- a: atime访问时间
- `c`: ctime创建时间
- `sha256`: SHA-256 hash

示例配置片段：

```conf
# 定义严格监控规则
CRITICAL = p+i+n+u+g+s+m+c+sha256+a+xattrs+acl+selinux

# 监控关键系统目录
/etc     CRITICAL
/usr/bin CRITICAL
/boot    CRITICAL

# 排除频繁变化的临时目录
!/var/log
!/tmp
!/run
```

### 4.5 性能调优

对于大规模文件系统，合理调优可显著缩短检查窗口。

- **多线程扫描**：使用 `--workers` 参数充分利用多核CPU，建议设为CPU核心数。
- **精简监控范围**：通过排除规则跳过日志、缓存、临时文件等高频变动目录。
- **选择性属性**：对大文件或频繁追加写的日志文件，可去掉 `size`、`mtime` 等易变属性，仅保留哈希或权限检查。
- **增量更新**：定期执行 `--update` 而非全量重建，减少I/O压力。

## 5. 执行测试

### 5.1 初始化基准数据库

```bash
$ aide --init
Start timestamp: 2026-04-23 03:00:00 +0000 (AIDE 0.18.6)
AIDE initialized database at /var/lib/aide/aide.db.new.gz
Number of entries:      48231
---------------------------------------------------
End timestamp: 2026-04-23 03:01:12 +0000 (runtime: 1m 12s)
```

初始化完成后，将新数据库设为基准：

```bash
cp /var/lib/aide/aide.db.new.gz /var/lib/aide/aide.db.gz
```

### 5.2 模拟文件篡改并检查

人为修改一个受监控文件后执行检查：

```bash
$ chmod 777 /etc/passwd
$ aide --check
Start timestamp: 2026-06-04 14:37:26 +0800 (AIDE 0.18.6)
AIDE found differences between database and filesystem!!

Summary:
  Total number of entries:	210175
  Added entries:		0
  Removed entries:		0
  Changed entries:		1

---------------------------------------------------
Changed entries:
---------------------------------------------------

f = p.. .c...A.  : /etc/passwd

---------------------------------------------------
Detailed information about changes:
---------------------------------------------------

File: /etc/passwd
 Perm      : -rw-r--r--                       | -rwxrwxrwx
 Ctime     : 2026-06-03 16:15:30 +0800        | 2026-06-04 14:37:26 +0800
 ACL       : A: user::rw-                     | A: user::rwx
             A: group::r--                    | A: group::rwx
             A: other::r--                    | A: other::rwx


---------------------------------------------------
The attributes of the (uncompressed) database(s):
---------------------------------------------------

/var/lib/aide/aide.db.gz
 MD5       : e7RgMvlX4dXw9zPFU3evOw==
 SHA1      : wnq9ZyzMTSwLfA0TkeFiDUNyufo=
 SHA256    : J5FfMosp8EVycW8Sl7cAXX4XkhN0E7T1
             Nnc5ufXIKQ8=
 SHA512    : J2Dva+fb/euuA3b+jmOtEH5RYwnPeUuf
             +Jpu43IZ02F+ZKxv1cWJM1H6fa7TxTim
             4z63qrAyw5FYUU9IQUYr7w==
 RMD160    : ugXnI0ML6Cey7s2OrSoR7bYbdwU=
 TIGER     : zWAiFiV8R8+vTdKvO9Y0HRTkBS3WSfQz
 CRC32     : HmLAIQ==
 WHIRLPOOL : fAea7DTlm6HIhqVUa1C/eJfGrhE0xRhT
             s18vk9hYTst+Hs1pfmMFv2ykgRdr4U72
             uUY8JNzpF57vr/45iNrnIQ==
 GOST      : Ya3fEGYAfgvGVxFXPudbsGAVGkZtR0M7
             590cZoaw3tc=
 STRIBOG256: Kt7Zzo0VEXoQF7sd0+styXU9EhWqTBye
             6Vs7HNFHEHQ=
 STRIBOG512: RjcBxxj3FbsdLccQSXAMFcNivGcM0U+k
             gKiBwRlx2bEe1Ow5tKOEsVtGqn8bErXx
             sYR5gJ9jQZnKvdaHc3dkAw==
 SM3       : gJEcX+Irhx5XiuDc0h8LT46vEYN+qCWq
             VqiQq96MCKo=


End timestamp: 2026-06-04 14:42:41 +0800 (run time: 5m 15s)
```

从结果可以看出AIDE准确识别出 `/etc/passwd` 的权限发生变化，并给出了新旧值对比。

### 5.3 验证合法变更后更新数据库

在确认上述变更为预期操作后，更新基准：

```bash
$ aide --update
...
AIDE updated database at /var/lib/aide/aide.db.gz
```

再次执行 `aide --check` 应返回无差异结果，表明基线已同步。

参考：

- AIDE官方文档：https://aide.github.io/
- AIDE配置最佳实践：https://wiki.archlinux.org/title/AIDE
- Linux文件完整性监控：https://geek-blogs.com/blog/aide-linux/

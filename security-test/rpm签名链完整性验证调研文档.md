### 1. 概述

RPM 签名链完整性验证是保障 Linux 发行版（如 openEuler、CentOS、Fedora 等）软件供应链安全的核心机制。它通过 GPG (GNU Privacy Guard) 非对称加密技术，确保软件包从构建、发布到安装的全生命周期中未被篡改，且来源可信。
在 openEuler 等社区生态中，RPM 签名验证不仅包含对单个 `.rpm` 文件的签名校验，还涉及对仓库元数据 (`repomd.xml`) 的签名验证，从而构建起完整的信任链。若签名验证失败，可能意味着软件包被恶意替换、传输损坏或密钥配置错误。

### 2. 环境准备与工具安装

RPM 签名验证主要依赖 `rpm` 和 `gpg` 工具，通常系统已预装。如需手动配置或导入密钥：

```bash
# 确认 rpm 版本
$ rpm --version

# 导入官方 GPG 公钥（以 openEuler 为例）
$ rpm --import https://repo.openeuler.org/openEuler-24.03-LTS-SP3/OS/x86_64/RPM-GPG-KEY-openEuler

# 查看已导入的 GPG 密钥
$ rpm -qa gpg-pubkey*

# 验证密钥指纹是否与官方公布一致
$ gpg --show-keys /etc/pki/rpm-gpg/RPM-GPG-KEY-openEuler
```

### 3. 基本语法

#### 3.1 RPM 签名验证命令

RPM 签名验证的基本命令格式如下：

```bash
rpm -K [options] <package.rpm>      # 检查 RPM 包签名
rpm -V [options] <package_name>     # 验证已安装包的完整性
```

常用参数说明：

| 参数                          | 说明                                           |
| ----------------------------- | ---------------------------------------------- |
| `-K` / `--checksig`           | 验证 RPM 包的 GPG 签名及 MD5/SHA 摘要          |
| `-V` / `--verify`             | 验证已安装文件是否被修改（大小、权限、哈希等） |
| `--nosignature`               | 仅验证摘要，跳过 GPG 签名检查                  |
| `--nodigest`                  | 仅验证 GPG 签名，跳过摘要检查                  |
| `--verbose` / `-v`            | 显示详细的验证过程信息                         |
| `--define "_gpg_path <path>"` | 指定自定义 GPG 密钥环路径                      |

#### GPG 签名验证命令

针对仓库元数据、独立签名文件或密钥本身的验证，需直接使用 `gpg` 命令：

```
# 导入公钥到 GPG 密钥环
gpg --import /etc/pki/rpm-gpg/RPM-GPG-KEY-openEuler

# 验证签名文件（如仓库元数据签名）
gpg --verify repomd.xml.asc repomd.xml

# 列出密钥信息
gpg --list-keys
gpg --list-keys --with-colons

# 检查密钥是否过期
gpg --list-keys --with-colons | grep "^pub" | grep -v "e$"
```

**注意**：`gpg --verify` 适用于验证分离式签名文件（`.asc`/`.sig` + 原始文件），而 `rpm -K` 用于验证内嵌签名的 RPM 包。两者互补，共同构成完整的签名验证体系。

### 4. RPM 签名链验证流程

（1）单包签名验证

在安装前验证 RPM 包的合法性：

```bash
# 完整验证（签名 + 摘要）
$ rpm -Kv package.rpm

# 预期成功输出示例：
# package.rpm:
#    Header V4 RSA/SHA256 Signature, key ID b675600b: NOKEY
#    Header SHA256 digest: OK
#    Header SHA1 digest: OK
#    Payload SHA256 digest: OK
#    MD5 digest: OK
```

（2）仓库元数据签名验证

DNF/YUM 在安装软件时会自动验证仓库元数据签名。相关配置位于 `/etc/yum.repos.d/*.repo`：

```ini
[OS]
name=OS
baseurl=https://fast-mirror.isrc.ac.cn/openeuler/openEuler-24.03-LTS-SP3/OS/riscv64/rva20/$basearch/
metalink=https://mirrors.openeuler.org/metalink?repo=$releasever/OS/riscv64/rva20&arch=$basearch
metadata_expire=1h
enabled=1
gpgcheck=1    # 开启 GPG 校验
gpgkey=http://fast-mirror.isrc.ac.cn/openeuler/openEuler-24.03-LTS-SP3/OS/riscv64/rva20/$basearch/RPM-GPG-KEY-openEuler   # 指定公钥路径
repo_gpgcheck=1       # 开启仓库元数据签名校验（目前openEuler仓库未定义该字段，默认未开启）
```

（3）已安装包完整性验证

验证系统中已安装的 RPM 包文件是否被篡改：

```bash
# 验证单个包
$ rpm -V bash

# 验证所有已安装包（耗时较长）
$ rpm -Va

# 输出解读：
# S.5....T.  c /etc/bashrc
# S: 文件大小不同  5: MD5/SHA 摘要不同  T: 修改时间不同  c: 配置文件
# 若输出为空，表示验证通过
```

（4） 签名链完整性排查

当验证失败时，按以下步骤排查：

| 错误信息          | 可能原因                    | 解决方案                 |
| ----------------- | --------------------------- | ------------------------ |
| `NOKEY`           | 未导入对应 GPG 公钥         | `rpm --import <key_url>` |
| `BAD signature`   | 签名无效，包可能被篡改      | 重新下载或确认来源       |
| `digest mismatch` | 文件内容损坏                | 检查网络传输或存储介质   |
| `MISSING KEYS`    | repo 文件中 gpgkey 路径错误 | 修正 repo 配置           |

### 5. 执行测试

对 openEuler 24.03-LTS-SP3 系统进行 RPM 签名链完整性验证测试：

```bash
# 1. 验证本地 RPM 包签名
$ rpm -Kv 389-ds-base-3.1.1-7.oe2403sp3.riscv64.rpm 
389-ds-base-3.1.1-7.oe2403sp3.riscv64.rpm:
    Header V4 RSA/SHA256 Signature, key ID b675600b: NOKEY
    Header SHA256 digest: OK
    Header SHA1 digest: OK
    Payload SHA256 digest: OK
    MD5 digest: OK

# 2. 验证仓库元数据签名
$ gpg --verify repomd.xml.asc repomd.xml
gpg: Signature made Thu 01 Jan 2025 00:00:00 AM CST
gpg:                using RSA key B25E7F91...
gpg: Good signature from "openEuler <infrastructure@openeuler.org>"

# 3. 验证已安装的关键系统包
$ rpm -V rpm glibc openssl
# （无输出表示验证通过）

# 4. 检查 GPG 密钥状态
$ gpg --list-keys --with-colons | grep "^pub" | grep -v "e$"
# （无输出表示所有密钥均未过期）

# 5. 模拟篡改测试（验证机制有效性）
$ echo "tampered" >> /usr/bin/test_binary
$ rpm -V test-package
S.5....T.    /usr/bin/test_binary
# 成功检测到文件被修改
```

参考：

- [RPM 官方文档 - Signature Verification](https://rpm-software-management.github.io/rpm-manual/)
- [openEuler 安全指南 - 软件包签名验证](https://docs.openeuler.org/zh/docs/latest/docs/Security/)
- [DNF 配置参考 - gpgcheck & repo_gpgcheck](https://dnf.readthedocs.io/en/latest/conf_ref.html)
- [GnuPG 手册](https://www.gnupg.org/documentation/manuals/gnupg/)
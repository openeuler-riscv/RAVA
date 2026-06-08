### 1. 概述

 OSV-Scanner 是由 Google 开源的安全漏洞扫描工具，隶属于 [OSV（Open Source Vulnerabilities）](https://osv.dev/) 生态系统。它能够快速、准确地检测项目依赖中已知的开源软件漏洞，支持多种语言生态（如 Go、Python、JavaScript、Rust、Java 等），并直接对接权威的 OSV 漏洞数据库。

根据 openEuler 社区与 OpenSSF OSV 的最新协作成果 [openEuler](https://www.openeuler.openatom.cn/zh/news/20260123-openEuler-OpenSSF OSV/20260123-openEuler-OpenSSF OSV)，osv-scanner 已经正式支持 openEuler 生态系统的漏洞扫描。

### 2. 安装

```Plain
# 安装go环境
$ dnf install go
# 通过go install安装
$ go install github.com/google/osv-scanner/v2/cmd/osv-scanner@latest
# 二进制位于 $(go env GOPATH)/bin/osv-scanner
$ cp $(go env GOPATH)/bin/osv-scanner /usr/local/bin
#验证安装成功
$ osv-scanner --version
```

### 3. 基本语法

osv-scanner基本语法如下：

```
osv-scanner [global options] command [command options]
```

支持查看osv-scanner命令的帮助信息

```
osv-scanner --help

NAME:
  osv-scanner - scans various mediums for dependencies and checks them against the OSV database

USAGE:
  osv-scanner [global options] command [command options]

EXAMPLES:
  # Scan a source directory
  $ osv-scanner scan source -r <source_directory>

  # Scan a source directory in offline mode
  $ osv-scanner scan source --offline-vulnerabilities --download-offline-database -r <source_directory>

  # Scan a container image
  $ osv-scanner scan image <image_name>

  # Scan a local image archive (e.g. a tar file) and generate HTML output
  $ osv-scanner scan image --serve --archive <image_name.tar>

  # Fix vulnerabilities in a manifest file and lockfile (non-interactive mode)
  $ osv-scanner fix -M <manifest_file> -L <lockfile>

  For full usage details, please refer to the help command of each subcommand (e.g. osv-scanner scan --help).

  Alternatively, you can access the detailed documentation here: https://google.github.io/osv-scanner/

VERSION:
  2.3.5

COMMANDS:
  scan              scans projects and container images for dependencies, and checks them against the OSV database.
  fix               scans a manifest and/or lockfile for vulnerabilities and suggests changes for remediating them
  experimental-mcp  Run osv-scanner as an MCP service (experimental)


GLOBAL OPTIONS:
    --help, -h  show help  --version, -v  print the version

```

可以用osv-scanner scan命令进行漏洞扫描，osv-scanner scan的帮助信息如下

```
$ osv-scanner scan --help
NAME:
   osv-scanner scan source - scans a source project's dependencies for known vulnerabilities using the OSV database.

USAGE:
   osv-scanner scan source [options] [directory1 directory2...]

DESCRIPTION:
   scans a source project's dependencies for known vulnerabilities using the OSV database.

OPTIONS:
   --lockfile string, -L string [ --lockfile string, -L string ]                    scan package lockfile on this path
   --sbom string, -S string [ --sbom string, -S string ]                            [DEPRECATED] scan sbom file on this path, the sbom file name must follow the relevant spec
   --recursive, -r                                                                  check subdirectories
   --no-ignore                                                                      also scan files that would be ignored by .gitignore
   --include-git-root                                                               include scanning git root (non-submoduled) repositories
   --experimental-exclude string [ --experimental-exclude string ]                  exclude directory paths during scanning; use g:pattern for glob, r:pattern for regex, or just dirname for exact match (can be repeated)
   --data-source string                                                             source to fetch package information from; value can be: deps.dev, native (default: "deps.dev")
   --maven-registry string                                                          URL of the default registry to fetch Maven metadata
   --config string                                                                  set/override config file
   --format string, -f string                                                       sets the output format; value can be: table, html, vertical, json, markdown, sarif, gh-annotations, cyclonedx-1-4, cyclonedx-1-5, spdx-2-3 (default: "table")
   --serve                                                                          output as HTML result and serve it locally
   --port string                                                                    port number to use when serving HTML report (default: 8000)
   --output string                                                                  [DEPRECATED] (Use "--output-file" instead) saves the result to the given file path
   --output-file string                                                             saves the result to the given file path
   --verbosity string                                                               specify the level of information that should be provided during runtime; value can be: error, warn, info (default: "info")
   --offline                                                                        run in offline mode, disabling any features requiring network access
   --offline-vulnerabilities                                                        checks for vulnerabilities using local databases that are already cached
   --download-offline-databases                                                     downloads vulnerability databases for offline comparison
   --call-analysis string [ --call-analysis string ]                                Enable call analysis for specific languages (e.g. --call-analysis=go). Supported: go, rust (*). (*) Will run build scripts.
   --no-call-analysis string [ --no-call-analysis string ]                          disables call graph analysis
   --no-resolve                                                                     disable transitive dependency resolution of manifest files
   --allow-no-lockfiles                                                             has the scanner consider no lockfiles being found as ok
   --all-packages                                                                   when json output is selected, prints all packages
   --all-vulns                                                                      show all vulnerabilities including unimportant and uncalled ones
   --licenses value                                                                 report on licenses based on an allowlist
   --experimental-flag-deprecated-packages                                          report if package versions are deprecated
   --experimental-plugins string [ --experimental-plugins string ]                  list of specific plugins and presets of plugins to use (default: "lockfile", "sbom", "directory")
   --experimental-disable-plugins string [ --experimental-disable-plugins string ]  list of specific plugins and presets of plugins to not use
   --experimental-no-default-plugins                                                disable default plugins, instead using only those enabled by --experimental-plugins
   --help, -h                                                                       show help
```

### 4. osv-scanner扫描

(1) 基础扫描

- 扫描锁定文件

```
# 扫描 package-lock.json
osv-scanner scan -L package-lock.json   

# 扫描多个文件
osv-scanner -L package-lock.json -L yarn.lock   #scan可省略
```

- 扫描清单文件

```
osv-scanner scan -M package.json
```

- 递归扫描目录

```
# 递归扫描当前目录下的所有支持文件
osv-scanner scan -r .

# 扫描指定目录
osv-scanner scan -r /path/to/project
```

- 扫描sbom文件

```
# 扫描 CycloneDX 格式的 SBOM
osv-scanner scan --sbom sbom.cdx.json

# 扫描 SPDX 格式的 SBOM
osv-scanner scan --sbom sbom.spdx.json
```

- 导出扫描结果

```

#支持 table, html, vertical, json, markdown, sarif, gh-annotations, cyclonedx-1-4, cyclonedx-1-5, spdx-2-3格式的结果文件导出，默认导出文件的格式为table
osv-scanner scan -r /path/to/project --output-file "report"

# 以json格式导出文件，文件遵循OSV（Open Source Vulnerabilities）格式规范
osv-scanner scan -r /path/to/project --format json --output-file "report.json"
```

(2) 实验性功能

`--experimental-plugins` 是 `osv-scanner` 的一个实验性功能，其用法是通过指定插件类型来扩展扫描目标，覆盖从语言依赖到操作系统软件包的多种场景。目前该功能仍处于实验阶段，需要关注官方后续是否转成稳定API。

该参数支持对不同目标进行扫描包含：

| 插件        | 类型         | 扫描目标                                                     | 典型路径                                |
| ----------- | ------------ | ------------------------------------------------------------ | --------------------------------------- |
| `lockfile`  | 预设（默认） | package-lock.json, yarn.lock, go.sum, Cargo.lock, poetry.lock, gemfile.lock 等 | 项目根目录                              |
| `sbom`      | 预设（默认） | SPDX, CycloneDX, Syft 等格式的 SBOM 文件                     | 项目目录                                |
| `directory` | 预设（默认） | package.json, go.mod, requirements.txt, pom.xml 等           | 项目目录                                |
| `os/rpm`    | 特定插件     | RPM 数据库                                                   | `/var/lib/rpm`, `/var/lib/rpm/Packages` |
| `os/dpkg`   | 特定插件     | DPKG 状态文件                                                | `/var/lib/dpkg/status`                  |
| `os/apk`    | 特定插件     | APK 数据库                                                   | `/lib/apk/db/installed`                 |

- 预设插件(默认行为，通常无需显示指定)

```
# 扫描锁定文件（lockfile 插件）
osv-scanner --experimental-plugins=lockfile -L package-lock.json
osv-scanner --experimental-plugins=lockfile -L yarn.lock
osv-scanner --experimental-plugins=lockfile -L go.sum

# 扫描 SBOM 文件（sbom 插件）
osv-scanner --experimental-plugins=sbom --sbom sbom.cdx.json
osv-scanner --experimental-plugins=sbom --sbom sbom.spdx.json

# 递归扫描目录中的清单文件（directory 插件）
osv-scanner --experimental-plugins=directory -r .
osv-scanner --experimental-plugins=directory -M pom.xml
```

- 操作系统级插件(扫描系统软件包)

  RPM插件

```
# 扫描系统 RPM 数据库
osv-scanner --experimental-plugins=os/rpm

# 扫描指定 RPM 数据库路径
osv-scanner --experimental-plugins=os/rpm /var/lib/rpm

# 扫描容器中的 RPM 数据库
osv-scanner --experimental-plugins=os/rpm /path/to/container/rootfs/var/lib/rpm
```

​		DPKG 插件

```
# 扫描系统 DPKG 状态
osv-scanner --experimental-plugins=os/dpkg

# 扫描指定路径
osv-scanner --experimental-plugins=os/dpkg /var/lib/dpkg/status

# 扫描容器中的 DPKG 状态
osv-scanner --experimental-plugins=os/dpkg /path/to/container/rootfs/var/lib/dpkg/status
```

​		APK插件

```
# 扫描系统 APK 数据库
osv-scanner --experimental-plugins=os/apk

# 扫描指定路径
osv-scanner --experimental-plugins=os/apk /lib/apk/db/installed
```

### 5. 执行测试

对openEuler 操作系统进行漏洞扫描时 ，可添加实验性功能参数`--experimental-plugins os/rpm`进行RPM软件包扫描，扫描结果内容如下。

```Plain
$ osv-scanner scan /var/lib/rpm --experimental-plugins os/rpm 
Scanning dir /var/lib/rpm
Starting filesystem walk for root: /
Scanned /var/lib/rpm/Packages.db file and found 1062 packages
End status: 1 dirs visited, 4 inodes visited, 1 Extract calls, 10.72914189s elapsed, 10.72920439s wall time

Scanning Result (package view):
Total 13 packages affected by 18 known vulnerabilities (0 Critical, 0 High, 0 Medium, 0 Low, 18 Unknown) from 1 ecosystem.
18 vulnerabilities can be fixed.


openEuler:24.03-LTS-SP3
╭─────────────────────────────────────────────────────────────────────────────────────────────╮
│ Source:os:/var/lib/rpm/Packages.db                                                          │
├────────────────┬─────────────────────┬───────────────┬────────────┬─────────────────────────┤
│ SOURCE PACKAGE │ INSTALLED VERSION   │ FIX AVAILABLE │ VULN COUNT │ BINARY PACKAGES (COUNT) │
├────────────────┼─────────────────────┼───────────────┼────────────┼─────────────────────────┤
│ ImageMagick    │ 7.1.2.8-1.oe2403sp3 │ Fix Available │          2 │ ImageMagick             │
│ curl           │ 8.4.0-22.oe2403sp3  │ Fix Available │          1 │ curl                    │
│ expat          │ 2.5.0-12.oe2403sp3  │ Fix Available │          2 │ expat                   │
│ glib2          │ 2.78.3-10.oe2403sp3 │ Fix Available │          1 │ glib2                   │
│ glibc          │ 2.38-77.oe2403sp3   │ Fix Available │          2 │ glibc                   │
│ gnupg2         │ 2.4.3-12.oe2403sp3  │ Fix Available │          2 │ gnupg2                  │
│ harfbuzz       │ 8.3.0-2.oe2403sp3   │ Fix Available │          1 │ harfbuzz                │
│ httpd          │ 2.4.58-10.oe2403sp3 │ Fix Available │          1 │ httpd                   │
│ libpcap        │ 1.10.4-3.oe2403sp3  │ Fix Available │          1 │ libpcap                 │
│ libpng         │ 1.6.40-1.oe2403sp3  │ Fix Available │          2 │ libpng                  │
│ libsodium      │ 1.0.19-1.oe2403sp3  │ Fix Available │          1 │ libsodium               │
│ openssl        │ 3.0.12-30.oe2403sp3 │ Fix Available │          1 │ openssl                 │
│ tar            │ 1.35-2.oe2403sp3    │ Fix Available │          1 │ tar                     │
╰────────────────┴─────────────────────┴───────────────┴────────────┴─────────────────────────╯

For the most comprehensive scan results, we recommend using the HTML output: `osv-scanner scan image --serve <image_name>`.
You can also view the full vulnerability list in your terminal with: `osv-scanner scan image --format vertical <image_name>`.
```

当前osv-scanner对本地 RPM 包数据库（`/var/lib/rpm/Packages.db`）进行扫描，结果显示系统（openEuler 24.03-LTS-SP3）上安装的 13 个软件包共存在 18 个已知漏洞，且这些漏洞均有修复版本可用。

参考：

https://osv.dev/list?ecosystem=openEuler

[Usage | OSV-Scanner](https://google.github.io/osv-scanner/usage/)

[osv-scanner使用说明-CSDN博客](https://blog.csdn.net/mosaicwang/article/details/146522050)

[Google开源漏洞扫描器OSV-Scanner部署及使用 - 简书](https://www.jianshu.com/p/79994ca4e41d)


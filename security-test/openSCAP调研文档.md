### 1. 概述

OpenSCAP（Security Content Automation Protocol）是一个开源的安全合规性框架，旨在帮助组织实现系统和应用程序的安全标准和政策。它提供了一套工具和库，用于评估、监控和强化计算机系统的安全性。以下是OpenSCAP的一些关键特性和组成部分：

SCAP标准：OpenSCAP 遵循安全合规性协议（SCAP）标准，该标准由国家标准技术研究院（NIST）开发。SCAP 提供了一种标准化的方法，用于评估、监控和报告计算机系统的安全性。
工具集：OpenSCAP 提供了一系列工具，其中包括SCAP Scanner、SCAP Workbench、和oscap工具。这些工具可以用于执行安全性评估、配置基准检查、生成报告以及自动化合规性检查。
安全配置指南：OpenSCAP包含了一系列安全配置指南，这些指南基于不同的安全标准和政策。用户可以使用这些指南来评估其系统的安全性，并采取必要的步骤来加固系统。
多平台支持：OpenSCAP 不仅支持Linux平台，还支持其他操作系统，如Windows。这使得它成为一个跨平台的安全合规性工具。
自定义性：用户可以根据自身需求定制OpenSCAP，以适应其特定的安全标准和政策要求。

### 2. 安装与使用

#### 2.1 安装

安装openscap工具：

```Plain
$ dnf install -y openscap
```

安装完成后可以开始使用OSCAP命令行工具。

显示 OpenSCAP 版本、支持的规范、内置 CPE 名称和支持的 OVAL 对象，输入以下命令：

```Plain
$ oscap --version
```

安装SCAP内容：

```Plain
$ yum install -y scap-security-guide
```

SCAP内容将安装在/usr/share/xml/scap/ssg/content/目录中，可查看指定系统版本的所有SCAP内容。

```Bash
$ ls /usr/share/xml/scap/ssg/content/ssg-*openeuler2403*.xml
/usr/share/xml/scap/ssg/content/ssg-openeuler2403-cpe-dictionary.xml   #标识操作系统平台，用于匹配目标系统是否适用该策略
/usr/share/xml/scap/ssg/content/ssg-openeuler2403-cpe-oval.xml  #自动判断当前系统是否属于openEuler 24.03，通常被ds.xml内部引用
/usr/share/xml/scap/ssg/content/ssg-openeuler2403-ds-1.2.xml   #SCAP1.2版本，-ds.xml通常为最新版如SCAP 1.3
/usr/share/xml/scap/ssg/content/ssg-openeuler2403-ds.xml   #单一文件打包所有SCAP内容（XCCDF + OVAL + CPE + OCIL）
/usr/share/xml/scap/ssg/content/ssg-openeuler2403-ocil.xml    #用于人工回答的合规检查，较少使用
/usr/share/xml/scap/ssg/content/ssg-openeuler2403-oval.xml   #定义如何检测系统状态，用于漏洞检查和配置项验证
/usr/share/xml/scap/ssg/content/ssg-openeuler2403-xccdf.xml  #定义安全策略规则清单，用于合规性检查
```

#### 2.2 基础命令

 oscap是OpenSCAP工具的命令行界面，用于执行SCAP安全性评估和配置规范扫描。其基本命令为

```
oscap [options] module operation [operation-options-and-arguments]
```

支持使用`oscap --help`查看命令行工具的帮助信息和使用指南。

```
$ oscap --help
oscap

OpenSCAP command-line tool

Usage: oscap [options] module operation [operation-options-and-arguments]

Common options:
   --verbose <verbosity_level>   - Turn on verbose mode at specified verbosity level.
                                   Verbosity level must be one of: DEVEL, INFO, WARNING, ERROR.
   --verbose-log-file <file>     - Write verbose information into file.

oscap options:
   -h --help                     - show this help
   -q --quiet                    - quiet mode
   -V --version                  - print info about supported SCAP versions

Commands:
    ds - Data stream utilities
    oval - Open Vulnerability and Assessment Language
    xccdf - eXtensible Configuration Checklist Description Format
    cvss - Common Vulnerability Scoring System
    cpe - Common Platform Enumeration
    cve - Common Vulnerabilities and Exposures
    cvrf - Common Vulnerability Reporting Framework
    info - Print information about a SCAP file.
```

- `oscap info`：显示关于SCAP数据流文件的信息，如文档类型、导入日期、版本等。

```
oscap info /path/to/scap-datastream.xml
```

- `oscap xccdf eval`：执行XCCDF配置规范评估。

```
oscap xccdf eval --profile <profile_id> --results /path/to/results.xml /path/to/xccdf.xml
```

- `oscap oval eval`：执行OVAL安全检查。

```
oscap oval eval --results /path/to/results.xml /path/to/oval.xml
```

- `oscap ds sds-compose`：合并多个 SCAP 数据流文件。

```
oscap ds sds-compose /path/to/output.xml /path/to/input1.xml /path/to/input2.xml
```

#### 2.3 执行扫描

OpenSCAP的主要目标是执行本地系统的配置和漏洞扫描。OpenSCAP能够评估SCAP源数据流、XCCDF基准和OVAL定义，并生成适当的结果。

使用SCAP源数据流扫描可通过oscap xccdf eval 命令完成，并可使用一些额外的参数。

```SQL
$ oscap xccdf eval --help
oscap -> xccdf -> eval

Perform evaluation driven by XCCDF file and use OVAL as checking engine

Usage: oscap [options] xccdf eval [options] INPUT_FILE [oval-definitions-files]

Common options:
   --verbose <verbosity_level>   - Turn on verbose mode at specified verbosity level.
                                   Verbosity level must be one of: DEVEL, INFO, WARNING, ERROR.
   --verbose-log-file <file>     - Write verbose information into file.

INPUT_FILE - XCCDF file or a source data stream file

Options:
   --profile <name>              - The name of Profile to be evaluated.
   --rule <name>                 - The name of a single rule to be evaluated.
   --skip-rule <name>            - The name of the rule to be skipped.
   --tailoring-file <file>       - Use given XCCDF Tailoring file.
   --tailoring-id <component-id> - Use given DS component as XCCDF Tailoring file.
   --cpe <name>                  - Use given CPE dictionary or language (autodetected)
                                   for applicability checks.
   --oval-results                - Save OVAL results as well.
   --check-engine-results        - Save results from check engines loaded from plugins as well.
   --export-variables            - Export OVAL external variables provided by XCCDF.
   --results <file>              - Write XCCDF Results into file.
   --results-arf <file>          - Write ARF (result data stream) into file.
   --stig-viewer <file>          - Writes XCCDF results into FILE in a format readable by DISA STIG Viewer
   --thin-results                - Thin Results provides only minimal amount of information in OVAL/ARF results.
                                   The option --without-syschar is automatically enabled when you use Thin Results.
   --without-syschar             - Don't provide system characteristic in OVAL/ARF result files.
   --report <file>               - Write HTML report into file.
   --skip-valid                  - Skip validation.
   --skip-validation
   --skip-signature-validation   - Skip data stream signature validation.
                                   (only applicable for source data streams)
   --enforce-signature           - Process only signed data streams.
   --fetch-remote-resources      - Download remote content referenced by XCCDF.
   --local-files <dir>           - Use locally downloaded copies of remote resources stored in the given directory.
   --progress                    - Switch to sparse output suitable for progress reporting.
                                   Format is "$rule_id:$result\n".
   --progress-full               - Switch to sparse but a bit more saturated output also suitable for progress reporting.
                                   Format is "$rule_id|$rule_title|$result\n".
   --datastream-id <id>          - ID of the data stream in the collection to use.
                                   (only applicable for source data streams)
   --xccdf-id <id>               - ID of component-ref with XCCDF in the data stream that should be evaluated.
                                   (only applicable for source data streams)
   --benchmark-id <id>           - ID of XCCDF Benchmark in some component in the data stream that should be evaluated.
                                   (only applicable for source data streams)
                                   (only applicable when datastream-id AND xccdf-id are not specified)
   --remediate                   - Automatically execute XCCDF fix elements for failed rules.
                                   Use of this option is always at your own risk.
```

oscap xccdf eval 命令的基本语法如下：

```Plain
# oscap xccdf eval --profile PROFILE_ID --results-arf ARF_FILE --report REPORT_FILE SOURCE_DATA_STREAM_FILE
```

其中：

- PROFILE_ID 是XCCDF配置文件的ID
- ARF_FILE 是 SCAP 结果数据流中结果的路径 格式（ARF）将被生成
- REPORT_FILE 是生成 HTML 格式报告的文件路径
- SOURCE_DATA_STREAM_FILE 是被评估的 SCAP 源数据的文件路径

例如，在openEuler 24.03 (LTS-SP3)系统中可以用/usr/share/xml/scap/ssg/content/ssg-openeuler2403-ds.xml 数据流评估系统基线。

```Plain
$ oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_standard --results-arf result.xml --report report.html /usr/share/xml/scap/ssg/content/ssg-openeuler2403-ds.xml
--- Starting Evaluation ---

Title   uninstall debugging tools
Rule    xccdf_org.ssgproject.content_rule_debugging_tools
Result  notchecked

Title   Uninstall development and compilation tools
Rule    xccdf_org.ssgproject.content_rule_development_and_compliation_tools
Result  notchecked

Title   Uninstall network sniffing Package
Rule    xccdf_org.ssgproject.content_rule_network_sniffing_tools
Result  notchecked

Title   IMA metrics should be enabled
Rule    xccdf_org.ssgproject.content_rule_ima_verification
Result  notchecked

Title   Install AIDE
Rule    xccdf_org.ssgproject.content_rule_package_aide_installed
Result  fail

Title   Build and Test AIDE Database
Rule    xccdf_org.ssgproject.content_rule_aide_build_database
Result  fail

Title   Configure System Cryptography Policy
Rule    xccdf_org.ssgproject.content_rule_configure_crypto_policy
Result  pass

Title   Configure SSH to use System Crypto Policy
Rule    xccdf_org.ssgproject.content_rule_configure_ssh_crypto_policy
Result  pass
......
```

#### 2.4 结果评估

在评估一个 XCCDF 基准（benchmark）时，`oscap` 通常会处理一个 XCCDF 文件、一个 OVAL 文件以及 CPE 字典。它执行系统分析，并基于该分析生成 XCCDF 格式的评估结果。XCCDF 检查清单中每条规则的评估结果都会输出到标准输出流（stdout）。以下是一条 XCCDF 规则的示例输出：

```Plain
Title   Ensure logging is configured
Rule    xccdf_org.ssgproject.content_rule_rsyslog_logging_configured
Result  pass
```

result的含义由[XCCDF规范](https://csrc.nist.gov/CSRC/media/Publications/nistir/7275/rev-4/final/documents/nistir-7275r4_updated-march-2012_clean.pdf)定义。 下表列出了单一规则的可能结果：

| 结果          | 描述                                                         | 示例情况                                                     |
| ------------- | ------------------------------------------------------------ | ------------------------------------------------------------ |
| pass          | 目标系统或系统组件满足规则的所有条件。                       |                                                              |
| fail          | 目标系统或系统组件未满足规则的所有条件。                     |                                                              |
| error         | 检查引擎无法完成评估，因此目标是否遵守规则尚不确定。         | OpenSCAP 权限不足，无法收集所有必要信息。                    |
| unknown       | 测试工具遇到了一些问题，结果未知。                           | OpenSCAP 无法解释校验引擎的输出（该输出对 OpenSCAP 毫无意义）。 |
| notapplicable | 该规则不适用于测试对象。                                     | 该规则可能是针对不同版本的目标作系统，或者是针对未安装的平台功能测试。 |
| notchecked    | 该规则未被检查机车评估。该状态适用于没有<xccdf：check>元素或对应于不支持的检查系统的规则。如果检查引擎不支持所指示的检查码，它也可能对应到由检查机返回的状态。 | 该规则未提及任何OVAL检定。                                   |
| notselected   | 该规则未被基准选中。OpenSCAP不会显示未被选中的规则。         | 该规则存在于基准测试中，但不属于所选配置。                   |
| informational | 规则被检查过，但核对引擎输出的只是审计员或管理者的信息;它不是一个合规类别。该状态值设计用于主要目的是从目标中提取信息，而非测试目标的规则。 |                                                              |
| fixed         | 该规则最初被评估为“失败”，但后来通过自动修复修复，因此现在被评为“通过”。 |                                                              |

#### 2.5 修复系统

OpenSCAP 允许自动修复处于不合规状态的系统。要实现系统修复，SCAP 内容中的规则必须附带修复脚本（remediation script）。例如，`scap-security-guide` 软件包中提供的 SCAP 源数据流（source data streams）就包含了带有修复脚本的规则。

系统修复包含以下步骤：

1. `oscap` 命令首先执行一次标准的 XCCDF 评估。
2. 通过评估 OVAL 定义对结果进行分析，所有失败的规则将被标记为修复候选。
3. `oscap` 程序查找相应的 `<xccdf:fix>` 元素，解析该元素，准备执行环境，并运行修复脚本。
4. 修复脚本的任何输出都会被 `oscap` 捕获并存储在 `<xccdf:rule-result>` 元素中，脚本的返回值也会一并保存。
5. 每当 `oscap` 执行一个修复脚本后，会立即再次评估对应的 OVAL 定义（以验证修复是否成功）。在第二次评估中，如果 OVAL 返回成功，则该规则的结果标记为“已修复”（fixed）；否则标记为“错误”（error）。
6. 修复的详细结果会保存在一个输出的 XCCDF 文件中。该文件包含两个 `<xccdf:TestResult>` 元素：  
   1. 第一个表示修复前的扫描结果；  
   2. 第二个基于第一个生成，包含修复后的结果。

OpenSCAP 的修复功能支持三种操作模式：在线修复（online）、离线修复（offline） 和 修复方案审查（review）。

##### 2.5.1 扫描时执行修复

修复脚本可以在扫描过程中直接执行，评估与修复通过单条命令完成。

要启用扫描时修复，请在 `oscap xccdf eval` 命令中使用 `--remediate` 选项。

例如，我们在评估 OSPP 配置文件时同时执行修复：

```Bash
$ oscap xccdf eval --remediate --profile xccdf_org.ssgproject.content_profile_ospp --results-arf results.xml /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
```

该命令的输出包含两个部分：  

- 第一部分显示修复前的扫描结果；  
- 第二部分显示应用修复后的扫描结果。 第二部分仅包含 “fixed”（已修复）或 “error”（错误）两类结果：  
- fixed 表示修复后重新扫描通过；  
- error 表示即使执行了修复，规则仍然不合规。

##### 2.5.2 扫描后执行修复

此功能允许你推迟修复脚本的执行。

第一步：仅对系统进行评估，结果保存在 XCCDF 结果文件的 `<xccdf:TestResult>` 元素中。

第二步：`oscap` 执行修复脚本并验证结果。你可以安全地将结果写回原输入文件，原始数据不会丢失。在离线修复过程中，系统会基于输入的 `<xccdf:TestResult>` 创建一个新的 `<xccdf:TestResult>`，继承所有原始数据，仅对失败的 `<xccdf:rule-result>` 元素执行修复。

例如：

```Bash
# 先执行评估
$ oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_ospp --results results.xml /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml

# 再执行修复
$ oscap xccdf remediate --results remediation-results.xml results.xml
```

##### 2.5.3 审查修复方案

审查模式允许用户将修复指令导出到文件中供人工审核，不会实际执行修复脚本。

要生成 Shell 脚本形式的修复方案，请按以下步骤操作：

1. 运行扫描并生成 XCCDF 结果文件（使用 `--results` 选项）：

```Bash
$ oscap xccdf eval --profile xccdf_org.ssgproject.content_profile_ospp --results results.xml /usr/share/xml/scap/ssg/content/ssg-rhel8-ds.xml
```

1. 获取结果 ID（result ID）：

```Bash
$ oscap info results.xml
```

1. 基于扫描结果生成修复脚本：

```Bash
$ oscap xccdf generate fix --fix-type bash --output my-remediation-script.sh --result-id xccdf_org.open-scap_testresult_xccdf_org.ssgproject.content_profile_ospp results.xml
```

生成的 `my-remediation-script.sh` 是一个可读、可编辑的 Bash 脚本，包含所有建议的修复操作，适用于安全审计或手动复核场景。

参考：

[OpenSCAP User Manual](https://static.open-scap.org/openscap-1.3/oscap_user_manual.html#_introduction)

[OpenSCAP部署、使用与原理分析-CSDN博客](https://blog.csdn.net/IronmanJay/article/details/142598513)

[OpenSCAP 基本使用 | 个人博客](https://lawsssscat.github.io/blog/zh/z-security-vulnerability/scap-implement-openscap-usage.html#oval-组件)
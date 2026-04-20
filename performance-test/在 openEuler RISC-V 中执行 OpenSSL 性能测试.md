## 在 openEuler RISC-V 中执行 OpenSSL 性能测试

### 1. openssl 介绍

**OpenSSL** 是一个开源的软件库和命令行工具，为网络通信提供安全加密功能。它实现了 **SSL（安全套接层）** 和 **TLS（传输层安全）** 协议，并包含了大量通用的密码算法、证书管理工具，是互联网上保障数据传输安全的基础设施之一。

OpenSSL 的两大组成部分：

**libcrypto**（加密库）

- 提供各种加密算法：对称加密（AES、ChaCha20）、非对称加密（RSA、ECC）、哈希函数（SHA-256、MD5）、消息认证码（HMAC）等。
- 还包含伪随机数生成器、大数运算等底层功能。

**libssl**（SSL/TLS 协议库）

- 实现了 TLS 协议的各版本（如 TLS 1.2、TLS 1.3），让应用程序能够轻松建立加密连接。
- 许多 Web 服务器（如 Apache、Nginx）、数据库、邮件服务器都依赖它实现 HTTPS、SMTPS 等安全协议。

**openssl 命令行工具**

- 一个功能强大的瑞士军刀，可以直接在终端中执行各种密码学操作，例如生成密钥、创建证书、测试服务器连接、计算文件哈希等。这也是你在之前的对话中看到的各种 `openssl` 命令的来源。

**核心作用**：

- **加密通信：** 当您访问以 `https://` 开头的网站时，浏览器和服务器之间建立的安全连接通常就是由 OpenSSL（或其衍生库）处理的。它确保数据在传输过程中是加密的。
- **数字证书管理：** 它用于生成、管理和验证数字证书（如 SSL 证书）。这些证书就像网站的“身份证”，证明网站的身份并启用加密。
- **通用加密工具：** 除了网络通信，它还提供了大量的加密算法（如 AES, RSA, SHA-256 等），开发者可以用它来加密文件、计算哈希值、生成随机数等。

### 2. 使用 openssl speed 执行性能测试

#### 2.1 openssl speed 介绍

`openssl speed` 是 OpenSSL 内置的一个**性能基准测试工具**。它通过执行大量的加密、解密、签名和验证操作，来测量当前计算机 CPU 处理各种加密算法的速度。

命令格式

````
openssl speed [选项] [算法...]
````

如果不指定算法，默认会测试 OpenSSL 支持的所有算法。

查看 openssl speed 支持的选项

````
$ openssl speed -help
Usage: speed [options] [algorithm...]

General options:
 -help               Display this summary
 -mb                 Enable (tls1>=1) multi-block mode on EVP-named cipher
 -mr                 Produce machine readable output
 -multi +int         Run benchmarks in parallel
 -async_jobs +int    Enable async mode and start specified number of jobs
 -engine val         Use engine, possibly a hardware device
 -primes +int        Specify number of primes (for RSA only)

Selection options:
 -evp val            Use EVP-named cipher or digest
 -hmac val           HMAC using EVP-named digest
 -cmac val           CMAC using EVP-named cipher
 -decrypt            Time decryption instead of encryption (only EVP)
 -aead               Benchmark EVP-named AEAD cipher in TLS-like sequence

Timing options:
 -elapsed            Use wall-clock time instead of CPU user time as divisor
 -seconds +int       Run benchmarks for specified amount of seconds
 -bytes +int         Run [non-PKI] benchmarks on custom-sized buffer
 -misalign +int      Use specified offset to mis-align buffers

Random state options:
 -rand val           Load the given file(s) into the random number generator
 -writerand outfile  Write random data to the specified file

Provider options:
 -provider-path val  Provider load path (must be before 'provider' argument if required)
 -provider val       Provider to load (can be specified multiple times)
 -propquery val      Property query used when fetching algorithms

Parameters:
 algorithm           Algorithm(s) to test (optional; otherwise tests all)
````

选项和参数说明：

**1) 通用选项 (General options)**

控制命令的基本行为和输出格式。

- `-help`: 显示帮助信息（即您刚才看到的内容）。

- `-mb`: 多块模式 (Multi-block)。主要用于 TLS 1.2+ 环境下的 EVP 命名密码算法。启用后，OpenSSL 会尝试一次性处理多个数据块，这通常能显著提高吞吐量，模拟真实的 TLS 记录层行为。

- `-mr`: 机器可读输出 (Machine Readable)。默认输出是人类可读的表格，加上此参数后，输出将变为简单的文本格式（通常是 `type:value`），方便脚本解析或导入到 Excel/数据库中进行分析。

- `-multi <整数>`

  : 

  并行测试

  。默认 

  ```
  openssl speed
  ```

   是单线程的。使用此选项可以启动多个进程并行运行基准测试，从而利用多核 CPU 来测试系统的总吞吐能力。

  - 例如：`-multi 4` 会使用 4 个并行任务。

- `-async_jobs <整数>`: 异步模式。启用异步引擎并启动指定数量的作业。这用于测试支持异步操作（如某些硬件加速卡）的性能。

- `-engine <值>`

  : 

  指定引擎

  。强制使用特定的加密引擎（通常是硬件加速设备，如 HSM 或专用的加密卡）。如果不指定，通常使用默认的软实现。

  - *注：在 OpenSSL 3.0+ 中，Engine 机制逐渐被 Provider 机制取代，但在旧版本或特定硬件中仍常用。*

- `-primes <整数>`: 指定素数数量。仅用于 RSA 算法测试。RSA 密钥生成涉及寻找大素数，此参数控制测试中使用的素数数量，影响测试的耗时和强度。

**2) 选择选项 (Selection options)**

决定具体测试哪些算法或操作模式。

- `-evp <值>`

  : 

  使用 EVP 接口

  。EVP (Envelope) 是 OpenSSL 的高级加密 API。此选项告诉工具测试通过 EVP 接口调用的特定密码或摘要算法。

  - 例如：`-evp aes-256-gcm`。

- `-hmac <值>`: 测试基于指定摘要算法的 HMAC (消息认证码) 性能。

- `-cmac <值>`: 测试基于指定密码算法的 CMAC (密码消息认证码) 性能。

- `-decrypt`: 测试解密而非加密。默认情况下，对称加密测试的是“加密”速度。加上此参数后，测试的是“解密”速度。这对某些算法（如 RSA）很重要，因为公钥加密和私钥解密的速度差异巨大。

- `-aead`: AEAD 模式测试。针对支持“带关联数据的认证加密” (AEAD, 如 AES-GCM) 的算法，模拟 TLS 协议中的完整序列（加密 + 认证标签生成）进行测试。

**3)  计时选项 (Timing options)**

控制如何计算速度和测试持续时间。

- `-elapsed`: 使用墙钟时间 (Wall-clock time)。默认情况下，OpenSSL 使用 CPU 用户态时间（即只计算 CPU 实际干活的时间，排除等待 I/O 或其他进程占用的时间）。使用此参数后，它将使用实际经过的物理时间。这在多核或多任务环境下可能更有参考价值。
- `-seconds <整数>`: 指定测试时长。默认情况下，每个算法测试固定次数。使用此参数可以强制测试运行指定的秒数（例如 `-seconds 5`），时间越长，结果通常越稳定。
- `-bytes <整数>`**: **自定义缓冲区大小。默认测试会使用多种数据包大小（16, 64, ... 8192 字节）。使用此参数可以强制仅在特定的数据块大小上进行测试（非 PKI 算法）。这对于模拟特定应用场景（如小包 VoIP 或大包文件传输）非常有用。
- `-misalign <整数>`**: **内存不对齐测试。默认情况下，测试使用的内存缓冲区是完美对齐的（性能最佳）。此参数可以让缓冲区偏移指定的字节数，用于测试在非对齐内存访问下的性能表现（这在某些架构上会显著降低性能）。

**4) 随机状态选项 (Random state options)**

控制随机数生成器 (RNG) 的行为，影响密钥生成的测试。

- `-rand <文件>`: 从指定文件加载种子数据到随机数生成器。用于确保测试的可重复性或模拟特定的熵源。
- `-writerand <输出文件>`: 将测试过程中生成的随机数据写入指定文件。

**5) Provider 选项 (Provider options) -** ***OpenSSL 3.0+ 特有***

OpenSSL 3.0 引入了 "Provider" 架构来替代旧的 "Engine" 架构，用于模块化加载算法实现。

- `-provider-path <路径>`: 指定搜索 Provider 库文件的路径。

- `-provider <名称>`: 显式加载指定的 Provider（例如 `default`, `fips`, `legacy` 等）。可以多次使用以加载多个 Provider。

- `-propquery <查询字符串>`

  : 

  属性查询

  。在获取算法时添加属性过滤条件。例如，您可以强制测试只使用 FIPS 认证的算法实现，或者强制使用软件实现而不是硬件实现。

  - 例如：`-propquery "?fips=yes"` 仅测试符合 FIPS 标准的算法。

**6) 参数 (Parameters)**

- `algorithm`: 命令行最后的部分。您可以直接列出想要测试的算法名称（如 `aes-128-cbc`, `sha256`, `rsa2048`）。如果不填，默认测试所有支持的算法。

#### 2.2 执行测试

**测试所有默认支持的算法**

直接运行该命令会测试 OpenSSL 支持的所有主要算法（对称加密、哈希、非对称加密等）

````
$ openssl speed
````

**测试特定算法**

测试对称加密 (AES):

````
$ openssl speed aes-128-cbc
$ openssl speed aes-256-gcm
````

测试哈希算法:

````
$ openssl speed sha256
$ openssl speed md5
````

测试非对称加密 (RSA/ECDSA):

````
$ openssl speed rsa2048
$ openssl speed ecdsap256
````

**测试特定数据块大小**

默认情况下，它会测试多种数据块大小（16, 64, 256, 1024, 8192 字节等）。您可以使用 `-bytes` 参数指定单一大小（通常用于模拟特定场景）：

````
# 仅测试 1024 字节块的 AES 加密速度
$ openssl speed -bytes 1024 aes-128-cbc
````

**指定测试时间和数据大小**

每种算法测试 10 秒，每次操作 8192 字节数据。

````
$ openssl speed -seconds 10 -bytes 8192 aes-256-cbc
````

**测试 EVP 接口下的 AES-256-GCM（更接近实际应用）**

使用 EVP（高级加密接口）测试指定的加密算法或摘要算法，EVP 测试通常能利用硬件加速（如果 CPU 支持 AES-NI），EVP 接口更接近应用程序实际调用的方式，结果更真实。

````
$ openssl speed -evp aes-256-gcm
````

**测试多线程**

例如4个线程

````
$ openssl speed -multi 4 aes-256-cbc
````

#### 2.3 测试结果

````
$ openssl speed aes-256-cbc rsa2048
Doing aes-256-cbc for 3s on 16 size blocks: 2290476 aes-256-cbc's in 2.97s
Doing aes-256-cbc for 3s on 64 size blocks: 1013689 aes-256-cbc's in 2.98s
Doing aes-256-cbc for 3s on 256 size blocks: 316776 aes-256-cbc's in 2.99s
Doing aes-256-cbc for 3s on 1024 size blocks: 85140 aes-256-cbc's in 2.98s
Doing aes-256-cbc for 3s on 8192 size blocks: 10885 aes-256-cbc's in 2.98s
Doing aes-256-cbc for 3s on 16384 size blocks: 5350 aes-256-cbc's in 2.98s
Doing 2048 bits private rsa's for 10s: 1286 2048 bits private RSA's in 9.93s
Doing 2048 bits public rsa's for 10s: 49216 2048 bits public RSA's in 9.93s
version: 3.0.12
built on: Fri Jan 30 13:11:41 2026 UTC
options: bn(64,64)
compiler: gcc -fPIC -pthread -Wa,--noexecstack -Wall -O3 -O2 -g -grecord-gcc-switches -pipe -fstack-protector-strong -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -specs=/usr/lib/rpm/generic-hardened-cc1 -fasynchronous-unwind-tables -fstack-clash-protection -Wa,--noexecstack -Wa,--generate-missing-build-notes=yes -specs=/usr/lib/rpm/generic-hardened-ld -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSL_BUILDING_OPENSSL -DZLIB -DNDEBUG -DPURIFY -DDEVRANDOM="\"/dev/urandom\""
CPUINFO: N/A
The 'numbers' are in 1000s of bytes per second processed.
type             16 bytes     64 bytes    256 bytes   1024 bytes   8192 bytes  16384 bytes
aes-256-cbc      12339.26k    21770.50k    27121.96k    29256.16k    29922.79k    29414.23k
                  sign    verify    sign/s verify/s
rsa 2048 bits 0.007722s 0.000202s    129.5   4956.3
````

这份测试结果展示了系统在 **AES-256-CBC 对称加密** 和 **RSA-2048 非对称加密** 方面的性能表现。

**测试过程原始数据**

AES-256-CBC（对称加密）

````
Doing aes-256-cbc for 3s on 16 size blocks: 2290476 aes-256-cbc's in 2.97s
Doing aes-256-cbc for 3s on 64 size blocks: 1013689 aes-256-cbc's in 2.98s
Doing aes-256-cbc for 3s on 256 size blocks: 316776 aes-256-cbc's in 2.99s
Doing aes-256-cbc for 3s on 1024 size blocks: 85140 aes-256-cbc's in 2.98s
Doing aes-256-cbc for 3s on 8192 size blocks: 10885 aes-256-cbc's in 2.98s
Doing aes-256-cbc for 3s on 16384 size blocks: 5350 aes-256-cbc's in 2.98s
````

- 针对 6 种不同的数据块大小（16, 64, 256, 1024, 8192, 16384 字节）分别测试。
- 每个测试的目标运行时间约 3 秒，记录实际耗时和完成的操作次数。例如：16 字节块，2.97 秒内完成 2,290,476 次加密操作。

RSA-2048（非对称加密）

````
Doing 2048 bits private rsa's for 10s: 1286 2048 bits private RSA's in 9.93s
Doing 2048 bits public rsa's for 10s: 49216 2048 bits public RSA's in 9.93s
````

- 分别测试私钥操作（通常用于签名或解密）和公钥操作（通常用于验证或加密）。
- 目标运行时间 10 秒，实际耗时 9.93 秒。
- 私钥操作：完成 1,286 次。
- 公钥操作：完成 49,216 次。

**关键性能指标与计算方式**

AES-256-CBC：吞吐量（Throughput）

指标含义：单位时间内处理的数据量，通常以千字节每秒（kB/s） 表示。它反映了对称加密算法在连续数据流上的处理能力。

计算公式：吞吐量 = (操作次数 × 块大小) / 耗时

以 16 字节块为例，从原始数据计算示例：每秒字节数 = 36,647,616 / 2.97 ≈ 12,339,265 字节/秒

`openssl speed` 结果的数值单位实际上是 “1000s of bytes per second”，即 千字节（KB，1 KB = 1000 字节），转换为 KB/s = 12,339,265 / 1000 = 12,339.27 KB/s，与表格中 12339.26k 完全吻合。

对其他块大小同样计算：

| 块大小 | 操作次数  | 耗时 | 总字节数   | KB/s (计算值) | 表格值    | 解读                                         |
| :----- | :-------- | :--- | :--------- | :------------ | :-------- | -------------------------------------------- |
| 16     | 2,290,476 | 2.97 | 36,647,616 | 12,339.27     | 12339.26k | 小包性能。受限于函数调用开销，速度相对较慢。 |
| 64     | 1,013,689 | 2.98 | 64,876,096 | 21,770.50     | 21770.50k | 中等包。                                     |
| 256    | 316,776   | 2.99 | 81,094,656 | 27,121.96     | 27121.96k | 接近峰值。                                   |
| 1024   | 85,140    | 2.98 | 87,183,360 | 29,256.16     | 29256.16k | 高性能区间。                                 |
| 8192   | 10,885    | 2.98 | 89,169,920 | 29,922.79     | 29922.79k | 峰值性能。                                   |
| 16384  | 5,350     | 2.98 | 87,654,400 | 29,414.23     | 29414.23k | 大包性能略有下降，属正常现象。               |

随着数据包增大，吞吐量显著增加并趋于稳定

RSA-2048：操作延迟与每秒操作数

关键指标：

- 平均每次操作时间（秒）
- 每秒操作数（ops/s）

计算公式：

平均时间 (s) = 总耗时 / 操作次数

每秒操作数 = 操作次数 / 总耗时

私钥操作：

- 操作次数 = 1,286，耗时 = 9.93 秒
- 平均时间 = 9.93 / 1286 ≈ 0.007722 秒（约 7.72 毫秒）
- 每秒操作数 = 1286 / 9.93 ≈ 129.5 sign/s

公钥操作：

- 操作次数 = 49,216，耗时 = 9.93 秒
- 平均时间 = 9.93 / 49216 ≈ 0.000202 秒（约 0.202 毫秒）
- 每秒操作数 = 49216 / 9.93 ≈ 4,956.3 verify/s

**指标解读与观察**

AES-256-CBC 吞吐量趋势

- 随着数据块从 16 字节增加到 8192 字节，吞吐量从 12.3 MB/s 提升至 29.9 MB/s。
- 这是因为每次加密操作的固定开销（如函数调用、上下文切换）被分摊到更多数据上。当块大小超过 1024 字节后，吞吐量趋于稳定（约 29.3 MB/s），达到当前硬件上 AES-256-CBC 的极限性能。

RSA-2048 性能对比

- 私钥操作（签名）：约 130 次/秒，平均每次 7.7 毫秒。
- 公钥操作（验证）：约 4,956 次/秒，平均每次 0.2 毫秒。
- 验证速度比签名快约 38 倍，这是 RSA 算法的典型特征：公钥指数通常很小（如 65537），计算快速；私钥指数很大，涉及模幂运算，计算复杂。
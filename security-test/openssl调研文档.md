### 1. 概述

OpenSSL 是一个功能强大的开源密码学工具包，用于实现 TLS/SSL 协议以及通用的加密操作。它提供了一套完整的命令行工具和开发库（libcrypto、libssl），广泛应用于证书管理、数据加密、数字签名、安全通信等领域。

OpenSSL 工具包包括以下核心组件：

- **libcrypto**：全强度的通用加密库，提供对称加密、非对称加密、哈希函数、随机数生成等基础密码学功能。
- **libssl**：实现 TLS 协议（最高支持 TLSv1.3）以及 DTLS 协议，提供安全的网络通信能力。
- **openssl**：命令行工具，是一个用于加密任务、测试和分析的"瑞士军刀"，支持密钥生成、证书管理、数据加解密、哈希计算、SSL/TLS 测试等操作。

OpenSSL 支持国际主流密码算法（AES、RSA、SHA 系列等），在较新版本中扩展了对国密算法（SM2/SM3/SM4）的支持。

### 2. 安装与版本检查

#### 2.1 安装

在 openEuler 系统上安装 OpenSSL：

```Plain
$ dnf install -y openssl
```

安装完成后，OpenSSL 命令行工具 `openssl` 和开发库将部署到系统中。

#### 2.2 版本与能力检查

显示 OpenSSL 版本：

```Plain
$ openssl version
OpenSSL 3.0.12 24 Oct 2023 (Library: OpenSSL 3.0.12 24 Oct 2023)
```

支持查看帮助信息：

```Plain
# 支持列出所有支持的密码算法：
$ openssl help
help:

Standard commands
asn1parse         ca                ciphers           cmp               
cms               crl               crl2pkcs7         dgst              
dhparam           dsa               dsaparam          ec                
.....             


# 支持二级命令查看帮助信息
$ openssl list --help
Usage: list [options]

General options:
 -help                     Display this summary

Output options:
 -1                        List in one column
 -verbose                  Verbose listing
......
```

### 3. 命令行工具架构

OpenSSL 命令行工具采用 `openssl <command> [options] [args]` 的调用格式。

#### 3.1 命令格式

```Plain
openssl [global-options] <command> [command-options] [command-args]
```

#### 3.2 核心子命令分类

| 功能类别 | 子命令 | 说明 |
|----------|--------|------|
| **对称加密** | `enc` | 数据加解密（AES、SM4 等） |
| **哈希摘要** | `dgst` | 消息摘要计算（SHA、SM3 等） |
| **密钥生成** | `genrsa`、`ecparam`、`genpkey` | 生成 RSA、ECC、SM2 密钥对 |
| **密钥操作** | `rsa`、`ec`、`pkey` | 密钥格式转换、信息查看 |
| **证书请求** | `req` | 生成证书签名请求（CSR） |
| **证书管理** | `x509`、`ca`、`crl` | 证书签发、验证、吊销 |
| **格式转换** | `pkcs12`、`pkcs7` | 证书格式转换 |
| **TLS/SSL 测试** | `s_client`、`s_server` | SSL/TLS 客户端/服务端测试 |
| **随机数** | `rand` | 生成随机数 |
| **信息查询** | `list`、`version`、`speed` | 算法列表、版本、性能测试 |

### 4. 对称加密操作（enc）

`openssl enc` 子命令用于执行对称加密和解密操作。

#### 4.1 基本语法

```Plain
openssl enc -<cipher> [-e|-d] -K <key> -iv <iv> [-in <file>] [-out <file>]
```

常用参数：

| 参数 | 说明 |
|------|------|
| `-e` | 加密模式（默认） |
| `-d` | 解密模式 |
| `-K <hex>` | 十六进制编码的密钥 |
| `-iv <hex>` | 十六进制编码的初始化向量（IV） |
| `-in <file>` | 输入文件 |
| `-out <file>` | 输出文件 |
| `-pass <arg>` | 密码短语（用于密钥派生） |
| `-pbkdf2` | 使用 PBKDF2 进行密钥派生 |
| `-nosalt` | 不使用盐值（不推荐） |

#### 4.2 国际算法示例（AES-256-CBC）

```Plain
# 加密文件
$ openssl enc -aes-256-cbc -salt -in plaintext.txt -out encrypted.bin
enter aes-256-cbc encryption password:
Verifying - enter aes-256-cbc encryption password:

# 解密文件
$ openssl enc -aes-256-cbc -d -in encrypted.bin -out decrypted.txt
enter aes-256-cbc decryption password:
```

#### 4.3 国密算法示例（SM4-CBC）

```Plain
# 生成 SM4 密钥（128 位 = 16 字节）和 IV（128 位）
$ KEY=$(openssl rand -hex 16)
$ IV=$(openssl rand -hex 16)

# SM4-CBC 加密
$ openssl enc -sm4-cbc -K $KEY -iv $IV -in data.txt -out data.sm4

# SM4-CBC 解密
$ openssl enc -sm4-cbc -d -K $KEY -iv $IV -in data.sm4 -out data_dec.txt
```

### 5. 哈希摘要操作（dgst）

`openssl dgst` 子命令用于计算消息摘要和执行数字签名/验签。

#### 5.1 基本语法

```Plain
openssl dgst [-<digest>] [-sign <key>] [-verify <key>] [-signature <file>] [file...]
```

#### 5.2 国际算法示例（SHA-256）

```Plain
# 计算文件 SHA-256 哈希
$ openssl dgst -sha256 /etc/os-release
SHA2-256(/etc/os-release)= 529ae04c383a32a87b45c4f3811a3eabbe8157613d59f54f250e1fe161955db5

# 计算字符串哈希
$ echo -n "abc" | openssl dgst -sha256
(stdin)= ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad
```

#### 5.3 国密算法示例（SM3）

```Plain
# 计算 SM3 哈希
$ echo -n "abc" | openssl dgst -sm3
(stdin)= 66c7f0f462eeedd9d1f2d46bdc10e4e24167c4875cf2f7a2297da02b8f4ba8e0
```

#### 5.4 数字签名与验签

```Plain
# RSA + SHA-256 签名
$ openssl dgst -sha256 -sign rsa_priv.pem -out data.sig data.txt

# RSA + SHA-256 验签
$ openssl dgst -sha256 -verify rsa_pub.pem -signature data.sig data.txt
Verified OK

# SM2 + SM3 签名
$ openssl dgst -sm3 -sign sm2_priv.pem -out data.sig data.txt

# SM2 + SM3 验签
$ openssl dgst -sm3 -verify sm2_pub.pem -signature data.sig data.txt
Verified OK
```

### 6. 非对称密钥生成

#### 6.1 RSA 密钥生成（genrsa）

```Plain
# 生成 RSA 2048 位私钥
$ openssl genrsa -out rsa_priv.pem 2048

# 提取公钥
$ openssl rsa -in rsa_priv.pem -pubout -out rsa_pub.pem
```

#### 6.2 ECC 密钥生成（ecparam）

```Plain
# 生成 P-256 曲线密钥
$ openssl ecparam -genkey -name prime256v1 -out ecc_priv.pem
$ openssl ec -in ecc_priv.pem -pubout -out ecc_pub.pem
```

#### 6.3 SM2 密钥生成（国密）

```Plain
# 生成 SM2 密钥对
$ openssl ecparam -genkey -name SM2 -out sm2_priv.pem

# 查看密钥信息
$ openssl ec -in sm2_priv.pem -text -noout

# 提取公钥
$ openssl ec -in sm2_priv.pem -pubout -out sm2_pub.pem
```

> SM2 是国产椭圆曲线公钥密码算法，密钥长度 256 位，安全强度相当于 RSA 2048 位。

### 7. 证书签名请求（CSR）

`openssl req` 子命令用于生成证书签名请求和自签名证书。

#### 7.1 基本语法

```Plain
openssl req [-new|-x509] -key <keyfile> [-out <file>] [-subj <dn>] [-days <n>]
```

常用参数：

| 参数 | 说明 |
|------|------|
| `-new` | 生成新的 CSR |
| `-x509` | 生成自签名证书 |
| `-key <file>` | 指定私钥文件 |
| `-out <file>` | 输出文件 |
| `-subj <dn>` | 主题可分辨名称（非交互式） |
| `-days <n>` | 证书有效期天数 |
| `-sha256` / `-sm3` | 指定签名摘要算法 |

#### 7.2 RSA CSR 生成

```Plain
# 生成 RSA 私钥和 CSR
$ openssl req -new -newkey rsa:2048 -nodes \
    -keyout server.key -out server.csr \
    -subj "/C=CN/O=Example/CN=server.example.com"
```

#### 7.3 SM2 CSR 生成（国密）

```Plain
# 生成 SM2 CSR（使用 SM3 摘要）
$ openssl ecparam -genkey -name SM2 -out sm2.key
$ openssl req -new -sm3 -key sm2.key -out sm2.csr \
    -subj "/C=CN/O=openEuler/OU=RV/CN=rv.openeuler.local"

# 查看 CSR 内容
$ openssl req -in sm2.csr -noout -text
```

### 8. 证书管理（x509 / ca）

#### 8.1 x509 子命令

`openssl x509` 用于处理 X.509 证书。

```Plain
# 查看证书详细信息
$ openssl x509 -in cert.pem -text -noout

# 查看证书有效期
$ openssl x509 -in cert.pem -noout -dates

# 提取证书公钥
$ openssl x509 -in cert.pem -pubkey -noout

# PEM 转 DER 格式
$ openssl x509 -in cert.pem -outform DER -out cert.der

# 计算证书指纹
$ openssl x509 -in cert.pem -noout -fingerprint -sha256
```

#### 8.2 自签名证书生成

```Plain
# RSA 自签名证书
$ openssl req -new -x509 -key rsa.key -out cert.pem -days 365 \
    -subj "/C=CN/O=Test/CN=localhost"

# SM2 自签名证书（国密）
$ openssl req -new -x509 -sm3 -key sm2.key -out sm2_cert.pem -days 365 \
    -subj "/C=CN/O=openEuler/CN=SM2-Test"
```

#### 8.3 CA 签发证书

```Plain
# 初始化 CA 目录结构
$ mkdir -p ca/{certs,crl,newcerts,private}
$ touch ca/index.txt
$ echo 1000 > ca/serial

# 使用 CA 签发证书
$ openssl ca -config ca.conf -in server.csr -out server.crt -days 365
```

#### 8.4 证书链验证

```Plain
# 验证单证书（自签名）
$ openssl verify -CAfile ca.crt server.crt

# 验证证书链（根 CA + 中间 CA）
$ openssl verify -CAfile root.crt -untrusted inter.crt server.crt
server.crt: OK
```

### 9. 证书吊销（CRL）

#### 9.1 生成 CRL

```Plain
# 吊销证书
$ openssl ca -config ca.conf -revoke server.crt

# 生成 CRL 文件
$ openssl ca -config ca.conf -gencrl -out ca.crl

# 查看 CRL 内容
$ openssl crl -in ca.crl -text -noout
```

#### 9.2 验证 CRL

```Plain
# 检查证书是否在 CRL 中
$ openssl verify -crl_check -CAfile ca.crt -CRLfile ca.crl server.crt
```

### 10. 格式转换（PKCS#12）

`openssl pkcs12` 用于在 PKCS#12 格式与 PEM 格式之间转换。

#### 10.1 导出 PKCS#12

```Plain
# 将证书和私钥打包为 PKCS#12
$ openssl pkcs12 -export -in cert.pem -inkey key.pem -out bundle.p12 \
    -name "My Certificate" -passout pass:exportpassword

# 包含证书链
$ openssl pkcs12 -export -in cert.pem -inkey key.pem \
    -certfile ca-chain.pem -out bundle.p12
```

#### 10.2 从 PKCS#12 提取

```Plain
# 提取私钥
$ openssl pkcs12 -in bundle.p12 -nocerts -nodes -out key.pem

# 提取证书
$ openssl pkcs12 -in bundle.p12 -clcerts -nokeys -out cert.pem

# 提取 CA 证书
$ openssl pkcs12 -in bundle.p12 -cacerts -nokeys -out ca.pem
```

### 11. TLS/SSL 测试（s_client / s_server）

#### 11.1 s_client — SSL/TLS 客户端测试

```Plain
# 测试远程 HTTPS 服务
$ openssl s_client -connect www.example.com:443 -tls1_2

# 显示证书链
$ openssl s_client -connect www.example.com:443 -showcerts

# 指定 SNI
$ openssl s_client -connect 192.168.1.1:443 -servername www.example.com

# 使用客户端证书双向认证
$ openssl s_client -connect server:443 \
    -cert client.crt -key client.key -CAfile ca.crt
```

#### 11.2 s_server — SSL/TLS 服务端测试

```Plain
# 启动简单的 TLS 服务端
$ openssl s_server -accept 4433 -cert server.crt -key server.key -www

# TLS 1.2 服务端
$ openssl s_server -accept 4433 -cert server.crt -key server.key -tls1_2

# 要求客户端证书
$ openssl s_server -accept 4433 -cert server.crt -key server.key -Verify 1
```

### 12. 性能测试（speed）

`openssl speed` 用于测试密码算法的执行性能。

```Plain
# 测试所有算法
$ openssl speed

# 测试指定算法
$ openssl speed sm3
$ openssl speed -evp sm4-cbc
$ openssl speed sm2

# 多线程测试
$ openssl speed -multi $(nproc) sm3

# 测试指定时长（秒）
$ openssl speed -seconds 5 aes-256-gcm
```

### 13. 参考

- [OpenSSL 官方文档](https://www.openssl.org/docs/)
- [OpenSSL 1.1.1 文档](https://www.openssl.org/docs/man1.1.1/)
- [GM/T 0003-2012 SM2 椭圆曲线公钥密码算法](http://www.oscca.gov.cn/)
- [GM/T 0004-2012 SM3 密码杂凑算法](http://www.oscca.gov.cn/)
- [GM/T 0002-2012 SM4 分组密码算法](http://www.oscca.gov.cn/)

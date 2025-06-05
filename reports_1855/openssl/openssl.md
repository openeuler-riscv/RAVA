```bash
[root@special ~]# which openssl
/usr/bin/openssl
[root@special ol]# openssl version -a
OpenSSL 3.0.12 24 Oct 2023 (Library: OpenSSL 3.0.12 24 Oct 2023)
built on: Mon Mar 24 23:07:58 2025 UTC
platform: linux64-riscv64
options:  bn(64,64)
compiler: gcc -fPIC -pthread -Wall -O3 -O2 -flto=auto -ffat-lto-objects -g -grecord-gcc-switches -pipe -fstack-protector-strong -Wall -Werror=format-security -Wp,-U_FORTIFY_SOURCE,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -specs=/usr/lib/rpm/generic-hardened-cc1 -fasynchronous-unwind-tables -fstack-clash-protection -Wa,--noexecstack -Wa,--generate-missing-build-notes=yes -specs=/usr/lib/rpm/generic-hardened-ld -DOPENSSL_USE_NODELETE -DOPENSSL_PIC -DOPENSSL_BUILDING_OPENSSL -DZLIB -DNDEBUG -DPURIFY -DDEVRANDOM="\"/dev/urandom\""
OPENSSLDIR: "/etc/pki/tls"
ENGINESDIR: "/usr/lib64/engines-3"
MODULESDIR: "/usr/lib64/ossl-modules"
Seeding source: os-specific
CPUINFO: N/A
```

OPENSSL性能指标：对称加密算法、非对称加密算法、哈希摘要计算、随机数生成。

```bash
#此脚本会测试几种常见的加密算法、哈希算法、随机数生成。
#等待执行结束，会把所有输出内容重定向到文本文件，分析文本内容查看性能
./openssl_perf.sh 

#此脚本会运行openssl的常用命令，测试加解密功能、证书密钥相关功能
#运行结束，会把所有输出内容重定向到文本文件，分析文本内容查看命令执行结果
./openssl_func.sh
```


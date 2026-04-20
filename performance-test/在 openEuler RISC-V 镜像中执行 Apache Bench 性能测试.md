## 在 openEuler RISC-V 镜像中执行 Apache Bench 性能测试

### 1. Apache Bench 介绍

Apache Bench（通常简称 `ab`）是 Apache 官方提供的一款命令行性能测试工具。它专门用来对 HTTP 服务器进行基准测试，可以模拟多个用户同时访问网站，并给出服务器在处理高并发请求时的关键性能数据，比如每秒请求数、响应时间等

### 2. 执行测试

#### 2.1 测试方法

安装 filebench

````
$ dnf install -y httpd-tools
$ ab -V                  # 查看版本，验证安装成功
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/
````

基本语法

````
ab [选项] <URL>
````

查看 ab 命令行选项

````
$ ab -h
Usage: ab [options] [http[s]://]hostname[:port]/path
Options are:
    -n requests     Number of requests to perform
    -c concurrency  Number of multiple requests to make at a time
    -t timelimit    Seconds to max. to spend on benchmarking
                    This implies -n 50000
    -s timeout      Seconds to max. wait for each response
                    Default is 30 seconds
    -b windowsize   Size of TCP send/receive buffer, in bytes
    -B address      Address to bind to when making outgoing connections
    -p postfile     File containing data to POST. Remember also to set -T
    -u putfile      File containing data to PUT. Remember also to set -T
    -T content-type Content-type header to use for POST/PUT data, eg.
                    'application/x-www-form-urlencoded'
                    Default is 'text/plain'
    -v verbosity    How much troubleshooting info to print
    -w              Print out results in HTML tables
    -i              Use HEAD instead of GET
    -x attributes   String to insert as table attributes
    -y attributes   String to insert as tr attributes
    -z attributes   String to insert as td or th attributes
    -C attribute    Add cookie, eg. 'Apache=1234'. (repeatable)
    -H attribute    Add Arbitrary header line, eg. 'Accept-Encoding: gzip'
                    Inserted after all normal header lines. (repeatable)
    -A attribute    Add Basic WWW Authentication, the attributes
                    are a colon separated username and password.
    -P attribute    Add Basic Proxy Authentication, the attributes
                    are a colon separated username and password.
    -X proxy:port   Proxyserver and port number to use
    -V              Print version number and exit
    -k              Use HTTP KeepAlive feature
    -d              Do not show percentiles served table.
    -S              Do not show confidence estimators and warnings.
    -q              Do not show progress when doing more than 150 requests
    -l              Accept variable document length (use this for dynamic pages)
    -g filename     Output collected data to gnuplot format file.
    -e filename     Output CSV file with percentages served
    -r              Don't exit on socket receive errors.
    -m method       Method name
    -h              Display usage information (this message)
    -I              Disable TLS Server Name Indication (SNI) extension
    -Z ciphersuite  Specify SSL/TLS cipher suite (See openssl ciphers)
    -f protocol     Specify SSL/TLS protocol
                    (SSL2, TLS1, TLS1.1, TLS1.2, TLS1.3 or ALL)
    -E certfile     Specify optional client certificate chain and private key
````

选项详解

| 选项              | 参数示例                     | 作用说明                                                     |
| :---------------- | :--------------------------- | :----------------------------------------------------------- |
| `-n requests`     | `-n 1000`                    | 总共要执行的请求次数（总请求数）。                           |
| `-c concurrency`  | `-c 10`                      | 并发数，即同时发出的请求数量。                               |
| `-t timelimit`    | `-t 60`                      | 测试持续的最长时间（秒）。设置此项后会自动隐含 `-n 50000`，即最多发 50000 个请求，时间到即停止。 |
| `-s timeout`      | `-s 30`                      | 每个响应等待的超时时间（秒），默认 30 秒。                   |
| `-b windowsize`   | `-b 8192`                    | 设置 TCP 发送/接收缓冲区大小（字节）。                       |
| `-B address`      | `-B 192.168.1.10`            | 绑定到指定的本地 IP 地址发起连接。                           |
| `-p postfile`     | `-p data.txt`                | 包含要 POST 的数据的文件，需同时用 `-T` 指定内容类型。       |
| `-u putfile`      | `-u data.txt`                | 包含要 PUT 的数据的文件，需同时用 `-T` 指定内容类型。        |
| `-T content-type` | `-T 'application/json'`      | 设置 POST/PUT 数据的内容类型头，默认 `text/plain`。          |
| `-v verbosity`    | `-v 4`                       | 设置详细级别（1-4），打印调试信息。                          |
| `-w`              | `-w`                         | 以 HTML 表格形式输出结果。                                   |
| `-i`              | `-i`                         | 使用 HEAD 请求方法（代替默认的 GET）。                       |
| `-x attributes`   | `-x 'border="1"'`            | 插入到 HTML 输出中 `<table>` 标签的属性。                    |
| `-y attributes`   | `-y 'bgcolor="#fff"'`        | 插入到 HTML 输出中 `<tr>` 标签的属性。                       |
| `-z attributes`   | `-z 'align="center"'`        | 插入到 HTML 输出中 `<td>` 或 `<th>` 标签的属性。             |
| `-C attribute`    | `-C 'session=abc123'`        | 添加 Cookie（可重复使用多次以添加多个 Cookie）。             |
| `-H attribute`    | `-H 'Accept-Encoding: gzip'` | 添加任意请求头（可重复使用多次）。插入在所有标准头之后。     |
| `-A attribute`    | `-A 'user:pass'`             | 添加基本 WWW 认证（Basic Authentication），用户名和密码用冒号分隔。 |
| `-P attribute`    | `-P 'proxyuser:proxypass'`   | 添加基本代理认证，用户名和密码用冒号分隔。                   |
| `-X proxy:port`   | `-X 192.168.1.1:8080`        | 指定使用的代理服务器和端口。                                 |
| `-V`              | `-V`                         | 显示版本号并退出。                                           |
| `-k`              | `-k`                         | 启用 HTTP KeepAlive 功能（长连接），默认是短连接。           |
| `-d`              | `-d`                         | 不显示“服务百分比”表格。                                     |
| `-S`              | `-S`                         | 不显示置信度估计和警告信息。                                 |
| `-q`              | `-q`                         | 当请求数超过 150 时，不显示进度输出（安静模式）。            |
| `-l`              | `-l`                         | 接受可变文档长度（用于动态页面），默认会校验响应内容长度是否变化。 |
| `-g filename`     | `-g out.dat`                 | 将收集到的数据输出为 gnuplot 格式的文件，可用于绘制图表。    |
| `-e filename`     | `-e out.csv`                 | 输出一个 CSV 文件，包含每个百分位（1%~100%）的响应时间。     |
| `-r`              | `-r`                         | 遇到 socket 接收错误时不退出程序（继续测试）。               |
| `-m method`       | `-m PUT`                     | 指定自定义的 HTTP 方法（如 PUT、DELETE 等）。                |
| `-h`              | `-h`                         | 显示帮助信息（即当前看到的这个）。                           |
| `-I`              | `-I`                         | 禁用 TLS 的 SNI（服务器名称指示）扩展。                      |
| `-Z ciphersuite`  | `-Z 'ECDHE-RSA-AES128-SHA'`  | 指定 SSL/TLS 密码套件，格式参考 `openssl ciphers`。          |
| `-f protocol`     | `-f TLS1.2`                  | 指定 SSL/TLS 协议版本（如 SSL2、TLS1、TLS1.1、TLS1.2、TLS1.3 或 ALL）。 |
| `-E certfile`     | `-E client.pem`              | 指定客户端证书文件（包含证书链和私钥），用于 HTTPS 客户端认证。 |

**常用示例**

1）基础 GET 请求压测

对百度首页发起 1000 个请求，并发 10 个：

```
$ ab -n 1000 -c 10 https://www.baidu.com/
```

2）POST 接口压测

使用 POST 方法提交表单数据：

```
# 准备 postdata.txt（如：username=test&password=123）
$ ab -n 100 -c 5 -p postdata.txt -T 'application/x-www-form-urlencoded' http://127.0.0.1:8080/login
```

JSON 接口（登录）

````
# login.json 里有 {"user":"admin", "pass":"123"}
$ ab -n 500 -c 50 -p login.json -T "application/json" -H "Authorization: Bearer mytoken" http://www.example.com/api/login
````

3）按时间压测（持续 60 秒）

```
$ ab -t 60 -c 100 http://127.0.0.1:8080/
```

4）测试 HTTPS 并指定 TLS 1.2 协议

````
$ ab -n 500 -c 20 -f TLS1.2 https://secure.example.com/
````

#### 2.2 测试结果

````
$ ab -n 1000 -c 100 "http://localhost/index.html"
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Completed 1000 requests
Finished 1000 requests


Server Software:        nginx/1.24.0
Server Hostname:        localhost
Server Port:            80

Document Path:          /index.html
Document Length:        3510 bytes

Concurrency Level:      100
Time taken for tests:   1.990 seconds
Complete requests:      1000
Failed requests:        0
Total transferred:      3744000 bytes
HTML transferred:       3510000 bytes
Requests per second:    502.40 [#/sec] (mean)
Time per request:       199.043 [ms] (mean)
Time per request:       1.990 [ms] (mean, across all concurrent requests)
Transfer rate:          1836.92 [Kbytes/sec] received

Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        2   85  25.0     80     173
Processing:    24  104  29.6    104     202
Waiting:        7   75  31.0     75     181
Total:        103  189  27.2    189     287

Percentage of the requests served within a certain time (ms)
  50%    189
  66%    199
  75%    205
  80%    208
  90%    227
  95%    233
  98%    247
  99%    255
 100%    287 (longest request)
````

1）**基础信息（压测配置）**

````
$ ab -n 1000 -c 100 "http://localhost/index.html"
This is ApacheBench, Version 2.3 <$Revision: 1903618 $>
Copyright 1996 Adam Twiss, Zeus Technology Ltd, http://www.zeustech.net/
Licensed to The Apache Software Foundation, http://www.apache.org/

Benchmarking localhost (be patient)
Completed 100 requests
Completed 200 requests
Completed 300 requests
Completed 400 requests
Completed 500 requests
Completed 600 requests
Completed 700 requests
Completed 800 requests
Completed 900 requests
Completed 1000 requests
Finished 1000 requests
````

含义：本次压测执行的是 `ab -n 1000 -c 100 http://localhost/index.html`，即：

- 总请求数（`-n`）：1000 个
- 并发数（`-c`）：100 个（同时发起 100 个请求）
- 目标地址：本地 nginx 服务器的 index.html 静态页面

2）**服务器与文档基础信息**

````
Server Software:        nginx/1.24.0  # 服务器软件是 Nginx 1.24.0
Server Hostname:        localhost     # 目标主机是本地
Server Port:            80            # 端口 80

Document Path:          /index.html   # 压测的页面路径
Document Length:        3510 bytes    # 单个页面的大小（3510 字节，约 3.4KB）
````

核心结论：压测对象是 Nginx 托管的小体积静态页面，这类场景 Nginx 本身性能优势明显。

3）核心性能指标（最关键）

````
Concurrency Level:      100          # 实际并发数（和你设置的 -c 一致，说明无异常）
Time taken for tests:   1.990 seconds # 压测总耗时（1.99 秒）
Complete requests:      1000         # 成功完成的请求数（1000 个，和 -n 一致）
Failed requests:        0            # 失败请求数（0 个，核心指标！无失败说明服务器扛住了）

# 吞吐量（QPS）：服务器每秒能处理的请求数 = 1000 / 1.99 ≈ 502.40
Requests per second:    502.40 [#/sec] (mean)  

# 用户视角的平均响应时间（含并发排队）= 199.043 毫秒
# 解释：1 个用户发起请求，平均要等 ~200 毫秒才能拿到结果（含 100 并发的排队时间）
Time per request:       199.043 [ms] (mean)  

# 服务器视角的平均响应时间（纯处理时间）= 1.990 毫秒
# 解释：服务器同时处理 100 个请求，每个请求的实际处理耗时仅 ~2 毫秒（无排队）
Time per request:       1.990 [ms] (mean, across all concurrent requests)

# 带宽吞吐：每秒从服务器接收的数据量 ≈ 1836.92 KB/s（约 1.8 MB/s）
Transfer rate:          1836.92 [Kbytes/sec] received
````

核心结论：

1. **QPS=502.4**：本地 Nginx 在 100 并发下，每秒能处理 500+ 个静态页面请求（这个数值对本地测试来说是正常的）；
2. **零失败**：服务器在 100 并发、1000 次请求下无报错，稳定性达标；
3. **响应时间**：用户感知的平均等待时间～200ms（主要是并发排队导致），服务器实际处理仅～2ms（静态页面处理极快）。

4）连接时间分布（细化耗时）

````
Connection Times (ms)
              min  mean[+/-sd] median   max
Connect:        2   85  25.0     80     173  # 建立TCP连接的耗时
Processing:    24  104  29.6    104     202  # 服务器处理请求的耗时（核心）
Waiting:        7   75  31.0     75     181  # 等待服务器返回响应的耗时
Total:        103  189  27.2    189     287  # 单个请求的总耗时（Connect+Processing）
````

字段解释：

- `min`：最小值；`mean`：平均值；`+/-sd`：标准差（越小说明耗时越稳定）；`median`：中位数；`max`：最大值；

核心结论：

1. **Connect 平均 85ms**：本地 TCP 连接耗时偏高（正常本地连接应 <10ms），可能是本地端口 / 资源临时占用导致；
2. **Processing 平均 104ms**：静态页面处理耗时稍高，但属于可接受范围；
3. **Total 平均 189ms**：和前面「Time per request」的 199ms 接近，数据一致。

5）响应时间百分位数（核心参考）

````
Percentage of the requests served within a certain time (ms)
  50%    189  # 50%的请求响应时间 ≤ 189ms
  66%    199  # 66%的请求响应时间 ≤ 199ms
  75%    205  # 75%的请求响应时间 ≤ 205ms
  80%    208  # 80%的请求响应时间 ≤ 208ms
  90%    227  # 90%的请求响应时间 ≤ 227ms（重点：90分位）
  95%    233  # 95%的请求响应时间 ≤ 233ms（重点：95分位）
  98%    247  # 98%的请求响应时间 ≤ 247ms
  99%    255  # 99%的请求响应时间 ≤ 255ms
 100%    287 (longest request) # 最慢的请求耗时 287ms
````

核心结论：

- 绝大多数请求（95%）的响应时间 ≤ 233ms，没有出现极端长尾；

- 最慢请求 287ms，和平均值差距不大(Time per request: 199.043 [ms] (mean) )，说明服务器性能稳定，无突发卡顿；

- 百分位数是生产环境的核心参考（比平均值更有意义），比如可以承诺「95% 的请求响应时间 < 250ms」。

**性能表现**：本地 Nginx 在 100 并发下处理静态页面，QPS 约 502，零失败，95% 请求响应时间 ≤ 233ms，整体性能稳定且符合预期；












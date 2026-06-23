## 在 openEuler RISC-V 镜像中执行 memtier_benchmark 测试

### 1. memtier_benchmark 介绍

`memtier_benchmark` 是 **Redis 官方（Redis Labs）推出的一款开源的高性能压测工具**。可以把它理解为一个“流量发生器”，专门用来给 Redis 或 Memcached 这样的内存数据库施加压力，以评估其在不同负载下的性能表现

相比于早期简单自带的 `redis-benchmark` 工具，`memtier_benchmark` 最大优势在于**支持多线程**，能生成更复杂的流量模式，得出的结果也更贴近真实场景。

核心功能

- **支持多种数据库与协议**：不仅支持 Redis，也支持 Memcached（包括文本和二进制协议）。
- **高度可定制的测试模式**：可以通过 `--ratio` 参数精确控制读写比例（如 `1:2` 表示 1次写、2次读），或通过 `--key-pattern` 设置键的访问规律（如顺序 `S:S` 或随机 `R:R`）。
- **强大的并发能力**：支持通过 `-t`（线程数）和 `-c`（每个线程的客户端数）灵活控制总并发连接数，最大化利用测试机资源。

### 2. 执行测试

#### 2.1 Server 端安装

````
$ dnf install -y redis
$ redis-server --bind 0.0.0.0 --protected-mode no &    #关闭 Redis保护模式,允许所有 IP（内网 / 外网）远程连接 redis，后台运行 redis-server
````

#### 2.2 Client 端安装

从源码编译安装

````
$ dnf install -y git gcc gcc-c++ make autoconf automake libtool libevent-devel pkgconfig zlib-devel openssl-devel
$ git clone https://github.com/RedisLabs/memtier_benchmark.git
$ cd memtier_benchmark
$ autoreconf -ivf
$ ./configure
$ make
$ make install
$ memtier_benchmark --version
````

memtier_benchmark 支持的选项

````
$ memtier_benchmark --help
Usage: memtier_benchmark [options]
A memcache/redis NoSQL traffic generator and performance benchmarking tool.

Connection and General Options:
  -h, --host=ADDR                Server address (default: localhost)
  -s, --server=ADDR              Same as --host
  -p, --port=PORT                Server port (default: 6379)
  -S, --unix-socket=SOCKET       UNIX Domain socket name (default: none)
  -4, --ipv4                     Force IPv4 address resolution.
  -6  --ipv6                     Force IPv6 address resolution.
  -P, --protocol=PROTOCOL        Protocol to use (default: redis).
                                 other supported protocols are resp2, resp3, memcache_text and memcache_binary.
                                 when using one of resp2 or resp3 the redis protocol version will be set via HELLO command.
  -a, --authenticate=CREDENTIALS Authenticate using specified credentials.
                                 A simple password is used for memcache_text
                                 and Redis <= 5.x. <USER>:<PASSWORD> can be
                                 specified for memcache_binary or Redis 6.x
                                 or newer with ACL user support.
  -u, --uri=URI                  Server URI on format redis://user:password@host:port/dbnum
                                 User, password and dbnum are optional. For authentication
                                 without a username, use username 'default'. For TLS, use
                                 the scheme 'rediss'.
      --tls                      Enable SSL/TLS transport security
      --cert=FILE                Use specified client certificate for TLS
      --key=FILE                 Use specified private key for TLS
      --cacert=FILE              Use specified CA certs bundle for TLS
      --tls-skip-verify          Skip verification of server certificate
      --tls-protocols            Specify the tls protocol version to use, comma delemited. Use a combination of 'TLSv1', 'TLSv1.1', 'TLSv1.2' and 'TLSv1.3'.
      --sni=STRING               Add an SNI header
  -x, --run-count=NUMBER         Number of full-test iterations to perform
  -D, --debug                    Print debug output
      --cluster-mode             Run client in cluster mode
      --transaction              In --cluster-mode, pin one full rotation of --command entries to
                                 a single shard connection so that keyless commands (MULTI/EXEC/
                                 UNWATCH) stay on the same connection as the keyed ones. Hash-tag
                                 your keys so they map to the same slot, otherwise the cross-slot
                                 keyed commands of the same rotation will get MOVED back. In
                                 standalone mode this flag is a no-op (each client already runs
                                 through a single connection). Requires at least one --command.
                                 --pipeline > 1 is supported: each rotation is sent contiguously
                                 on its pinned connection, so multiple whole transactions can be
                                 in flight without interleaving MULTI/EXEC blocks.
                                 Note: if --reconnect-on-error triggers mid-rotation, the
                                 interrupted rotation's stats will be inaccurate (server-side
                                 WATCH/MULTI state is lost on reconnect).
  -h, --help                     Display this help
  -v, --version                  Display version information

Results Output Options:
  -o, --out-file=FILE            Name of output file (default: stdout)
      --json-out-file=FILE       Name of JSON output file, if not set, will not print to json
      --client-stats=FILE        Produce per-client stats file
      --hdr-file-prefix=FILE     Prefix of HDR Latency Histogram output files, if not set, will not save latency histogram files
      --show-config              Print detailed configuration before running
      --hide-histogram           Don't print detailed latency histogram
      --print-percentiles        Specify which percentiles info to print on the results table (by default prints percentiles: 50,99,99.9)
      --print-all-runs           When performing multiple test iterations, print and save results for all iterations
      --realtime-latencies       Replace the periodic single-line progress output with a per-tick block: line 1 = throughput + miss ratio, then one or more latency lines carrying the percentiles configured by --print-percentiles (immediate and overall, side-by-side). Redraws in place on a TTY; appends cleanly when stderr is redirected to a file.
      --command-stats-breakdown=command|line
                                 How to group command statistics in the output (default: command)
                                 command: aggregate by command name (first word, e.g., SET, GET)
                                 line: show each command line separately
      --command-miss-tracking=auto|off
                                 Track per-key cache misses for arbitrary commands (default: auto)
                                 auto: enable for commands with known reply shape (GET, MGET, HGET, HMGET, GETEX, EXISTS, ...)
                                 off:  disable; mb.json will not contain per-arbitrary-command Hits/Misses fields
      --miss-rate-threshold=PERCENTAGE
                                 Warn when miss rate exceeds this percentage (default: 1.0).
                                 Accepts fractional values, e.g. 0.5 for half a percent.
                                 0 warns on any miss.
      --statsd-host=HOST         StatsD server hostname to send real-time metrics (default: none, disabled)
      --statsd-port=PORT         StatsD server UDP port (default: 8125)
      --statsd-prefix=PREFIX     Prefix for StatsD metric names (default: memtier)
      --statsd-run-label=LABEL   Label for this benchmark run, used to distinguish runs in dashboards (default: default)
      --graphite-port=PORT       Graphite HTTP port for event annotations (default: 8080 for host access; use 80 when running inside the Docker network)

Test Options:
  -n, --requests=NUMBER          Number of total requests per client (default: 10000)
                                 use 'allkeys' to run on the entire key-range
      --rate-limiting=NUMBER     The max number of requests to make per second from an individual connection (default is unlimited rate).
                                 If you use --rate-limiting and a very large rate is entered which cannot be met, memtier will do as many requests as possible per second.
  -c, --clients=NUMBER           Number of clients per thread (default: 50)
  -t, --threads=NUMBER           Number of threads (default: 4)
      --test-time=SECS           Number of seconds to run the test
      --clients-start=NUMBER     Starting number of clients per thread for staircase ramp-up.
                                 Must be less than --clients. Requires --clients-step and --step-duration.
      --clients-step=NUMBER      Number of clients to add per step in staircase ramp-up.
      --step-duration=SECS       Duration in seconds of each step before adding more clients.
      --ratio=RATIO              Set:Get ratio (default: 1:10)
      --pipeline=NUMBER          Number of concurrent pipelined requests (default: 1)
      --reconnect-interval=NUM   Number of requests after which re-connection is performed
      --reconnect-on-error       Enable automatic reconnection on connection errors (default: disabled)
      --max-reconnect-attempts=NUM Maximum number of reconnection attempts (default: 0, unlimited)
      --reconnect-backoff-factor=NUM Backoff factor for reconnection delays (default: 0, no backoff)
      --retry-on-error           Resend a request when the server returns a transient error or the
                                 connection drops mid-flight. Excludes permanent errors (WRONGTYPE,
                                 NOAUTH, NOPERM, syntax/argcount/unknown-command). Default: disabled.
      --max-retries=N            Maximum retries per request when --retry-on-error is set.
                                 -1 = unlimited (default), 0 = disable retries even with the master
                                 switch on, N>0 = bounded. MOVED/ASK redirects count toward this.
      --retry-backoff-ms=NUM     Delay between retries in milliseconds (default: 0, immediate).
      --retry-backoff-factor=NUM Exponential multiplier applied to retry-backoff-ms on each
                                 successive retry (default: 0, constant backoff).
      --retry-on=LIST            Restrict retries to error-status prefixes in this comma list
                                 (e.g. LOADING,BUSY,TRYAGAIN). Default: retry everything not
                                 classified as permanent.
      --max-retry-queue=NUM      Hard cap on per-connection retry queue depth. When full, the
                                 pipeline stops accepting new work until the queue drains.
                                 Default: 0 (auto = max(pipeline * 4, 64)).
      --failed-keys-file=PATH    Append every request that ultimately fails (retries exhausted or
                                 permanent error) as CSV: timestamp,command,key,status,retries.
                                 Off by default. The benchmark continues if the file is unwritable.
      --connection-timeout=SECS  Connection timeout in seconds, 0 to disable (default: 0)
      --connection-stage-timeout=SECS
                                 Abort with exit code 2 if no thread reaches steady state within
                                 SECS, or if connection-setup failures (AUTH / HELLO / SELECT /
                                 CLUSTER SLOTS / -ERR during initial probe) persist for SECS
                                 without a successful handshake. Bounds the *startup* phase;
                                 --test-time still bounds the steady-state run. Default: 30,
                                 0 disables the supervisor.
      --thread-conn-start-min-jitter-micros=NUM Minimum jitter in microseconds between connection creation (default: 0)
      --thread-conn-start-max-jitter-micros=NUM Maximum jitter in microseconds between connection creation (default: 0)
      --multi-key-get=NUM        Enable multi-key get commands, up to NUM keys (default: 0).
                                 In cluster mode, keys are probed from the key space so that all
                                 keys in one batch route to the same shard (no hash-tag prefix).
      --select-db=DB             DB number to select, when testing a redis server
      --distinct-client-seed     Use a different random seed for each client
      --randomize                random seed based on timestamp (default is constant value)

Arbitrary command:
      --command=COMMAND          Specify a command to send in quotes.
                                 Each command that you specify is run with its ratio and key-pattern options.
                                 For example: --command="set __key__ 5" --command-ratio=2 --command-key-pattern=G
                                 To use a generated key or object, enter:
                                   __key__: Use key generated from Key Options.
                                   __data__: Use data generated from Object Options.
      --command-ratio            The number of times the command is sent in sequence.(default: 1)
      --command-key-pattern      Key pattern for the command (default: R):
                                 G for Gaussian distribution.
                                 R for uniform Random.
                                 Z for zipf distribution (will limit keys to positive).
                                 S for Sequential.
                                 P for Parallel (Sequential were each client has a subset of the key-range).
      --monitor-input=FILE       Read commands from Redis MONITOR output file.
                                 Commands can be referenced as __monitor_line1__, __monitor_line2__, etc.
                                 Use __monitor_line@__ to select commands from the file.
                                 By default, selection is sequential; use --monitor-pattern=R for random.
                                 For example: --monitor-input=monitor.txt --command="__monitor_line1__"
      --monitor-pattern=S|R      Pattern for selecting monitor commands (default: S for Sequential)
                                 S for Sequential selection.
                                 R for Random selection.
      --scan-incremental-iteration
                                 Enable SCAN cursor iteration mode. When used with
                                 --command="SCAN 0 [MATCH pattern] [COUNT count] [TYPE type]",
                                 automatically follows the cursor returned by each SCAN response.
                                 Sends "SCAN 0 ..." initially, then "SCAN <cursor> ..." until
                                 the cursor returns 0, then restarts. Requires --pipeline 1.
                                 Stats are reported separately for "SCAN 0" and "SCAN <cursor>".
      --scan-incremental-max-iterations=NUMBER
                                 Maximum number of continuation SCANs per iteration cycle
                                 (default: 0, follow cursor until it returns 0).

Object Options:
  -d  --data-size=SIZE           Object data size in bytes (default: 32)
      --data-offset=OFFSET       Actual size of value will be data-size + data-offset
                                 Will use SETRANGE / GETRANGE (default: 0)
  -R  --random-data              Indicate that data should be randomized
      --data-size-range=RANGE    Use random-sized items in the specified range (min-max)
      --data-size-list=LIST      Use sizes from weight list (size1:weight1,..sizeN:weightN)
      --data-size-pattern=R|S    Use together with data-size-range
                                 when set to R, a random size from the defined data sizes will be used,
                                 when set to S, the defined data sizes will be evenly distributed across
                                 the key range, see --key-maximum (default R)
      --expiry-range=RANGE       Use random expiry values from the specified range

Imported Data Options:
      --data-import=FILE         Read object data from file
      --data-verify              Enable data verification when test is complete
      --verify-only              Only perform --data-verify, without any other test
      --generate-keys            Generate keys for imported objects
      --no-expiry                Ignore expiry information in imported data

Key Options:
      --key-prefix=PREFIX        Prefix for keys (default: "memtier-")
      --key-minimum=NUMBER       Key ID minimum value (default: 0)
      --key-maximum=NUMBER       Key ID maximum value (default: 10000000)
      --key-pattern=PATTERN      Set:Get pattern (default: R:R)
                                 G for Gaussian distribution.
                                 R for uniform Random.
                                 Z for zipf distribution (will limit keys to positive).
                                 S for Sequential.
                                 P for Parallel (Sequential were each client has a subset of the key-range).
      --key-stddev               The standard deviation used in the Gaussian distribution
                                 (default is key range / 6)
      --key-median               The median point used in the Gaussian distribution
                                 (default is the center of the key range)
      --key-zipf-exp             The exponent used in the zipf distribution, limit to (0, 5)
                                 Higher exponents result in higher concentration in top keys
                                 (default is 1, though any number >2 seems insane)

WAIT Options:
      --wait-ratio=RATIO         Set:Wait ratio (default is no WAIT commands - 1:0)
      --num-slaves=RANGE         WAIT for a random number of slaves in the specified range
      --wait-timeout=RANGE       WAIT for a random number of milliseconds in the specified range (normal 
                                 distribution with the center in the middle of the range)
````

1）连接与全局参数（Connection and General Options）

| 参数                                                         | 释义                                                         |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| `-s/--host ADDR -p --port PORT`                              | 指定 Redis 服务 IP、端口，默认`127.0.0.1:6379`               |
| `-S --unix-socket FILE`                                      | 使用 Redis 本地 unix 域套接字连接                            |
| `-4/-6`                                                      | 强制 IPv4/IPv6 协议解析                                      |
| `-P --protocol [redis/resp2/resp3/memcache_text/memcache_binary]` | 协议类型：redis 默认；resp2/resp3 为 Redis 新版协议；memcache_开头为 memcached 协议 |
| `-a --authenticate [user:pass / password]`                   | 鉴权：Redis5 及以下直接填密码；Redis6+ACL 格式`用户名:密码`  |
| `-u --uri redis://user:pass@ip:port/db`                      | URI 快捷连接，`rediss://`开启 TLS 加密                       |
| `--tls --cert/--key/--cacert`                                | TLS 加密：客户端证书、私钥、CA 根证书；`--tls-skip-verify`跳过证书校验 |
| `--sni STRING`                                               | TLS SNI 域名                                                 |
| `-x --run-count N`                                           | 整体压测循环执行 N 轮                                        |
| `-D --debug`                                                 | 开启调试日志，打印每条指令详情                               |
| `--cluster-mode`                                             | Redis 集群模式，自动路由槽位、规避 MOVED 报错；搭配`--transaction`保证 MULTI/EXEC 同连接 |
| `-h/-v`                                                      | 帮助 / 版本                                                  |

2）结果输出参数（Results Output Options，自动化解析关键）

| 参数                                     | 释义                                                       |
| ---------------------------------------- | ---------------------------------------------------------- |
| `-o --out-file FILE`                     | 标准文本结果输出文件（吞吐、延迟、分位数在此）             |
| `--json-out-file FILE`                   | JSON 结构化结果，方便 awk/python 解析入库                  |
| `--client-stats FILE`                    | 单客户端细分统计文件                                       |
| `--hdr-file-prefix xxx`                  | HDR 高精度延迟直方图前缀，生成延迟分布文件                 |
| `--show-config`                          | 压测前打印全部配置参数                                     |
| `--hide-histogram`                       | 关闭冗长延迟直方图打印，精简日志                           |
| `--print-percentiles 50,95,99,99.9`      | 自定义打印延迟分位数，默认 50/99/99.9                      |
| `--print-all-runs`                       | 多轮`-x`循环时，保存每轮结果                               |
| `--realtime-latencies`                   | 实时刷新吞吐 & 延迟，控制台动态打印                        |
| `--command-stats-breakdown command/line` | command：按 SET/GET 聚合统计；line：每条自定义指令单独统计 |
| `--command-miss-tracking auto/off`       | auto 自动统计 GET 类 key 命中率 / 缺失率；off 关闭         |
| `--miss-rate-threshold 1.0`              | 缺失率超过阈值打印告警，单位 %                             |
| `--statsd-host/port/prefix`              | 实时指标推送到 StatsD 监控                                 |

3）压测核心控制参数（Test Options，调并发、时长、流水线）

| 参数                                             | 释义                                                         |
| ------------------------------------------------ | ------------------------------------------------------------ |
| `-n --requests N`                                | **单客户端总请求数**，`allkeys`遍历全 key 范围；和`--test-time`二选一 |
| `--test-time SEC`                                | **压测持续秒数（推荐）**，固定时长跑压测，自动化首选         |
| `-t --threads N`                                 | 压测进程线程数，绑定 CPU 核数                                |
| `-c --clients N`                                 | **单线程下客户端连接数**，总连接 = threads×clients           |
| `--rate-limiting QPS`                            | 单连接限速 QPS，限流压测场景                                 |
| `--ratio S:G`                                    | 默认`1:10`，SET:GET 读写比例，1 写 10 读                     |
| `--pipeline N`                                   | Redis 流水线，单连接批量打包 N 条请求，大幅提升吞吐，常用 20/50/100 |
| `--clients-start/--clients-step/--step-duration` | 阶梯加压：起始连接、每步新增连接、每步持续秒，爬坡性能测试   |
| `--reconnect-interval N`                         | 每 N 条请求主动重连一次                                      |
| `--reconnect-on-error`                           | 异常断连后自动重连                                           |
| `--retry-on-error`                               | 临时报错 (LOADING/BUSY) 自动重试，永久报错 (WRONGTYPE/NOAUTH) 不重试 |
| `--max-retries/-retry-backoff-ms`                | 最大重试次数、重试间隔毫秒                                   |
| `--select-db N`                                  | 指定 Redis 库号 db=N                                         |
| `--distinct-client-seed --randomize`             | 每个客户端独立随机种子；基于时间戳随机（默认固定种子）       |
| `--multi-key-get N`                              | 开启 MGET，单次最多 N 个不同 key，批量读压测                 |

4）自定义指令参数（Arbitrary command，模拟业务混合指令）

脱离默认 SET/GET，自定义 HSET/HGET/LPOP 等任意 Redis 命令

a）`--command="SET __key__ __data__"`：

`__key__`：使用工具自动生成的 key；`__data__`：自动生成 value 数据

b）`--command-ratio N`：本条指令在一轮循环中执行 N 次

c）`--command-key-pattern R/Z/S/G/P`：本条指令 key 分布模式

R 随机、Z 齐普夫 (热点 key)、S 顺序、G 高斯、P 分片顺序

d）`--monitor-input file`：导入 Redis monitor 日志回放真实业务流量；`__monitor_line1__`引用日志里的指令

e）`--scan-incremental-iteration`：自动迭代 SCAN 游标，循环全量遍历，搭配`SCAN 0`压测遍历性能

5）Key/Value 数据配置（Object + Key Options，控制 key 范围、value 大小、分布）

a）对象 value 配置

`-d --data-size SIZE`：value 固定字节大小，默认 32 字节

`--data-size-range min-max`：value 在区间随机大小

`-R --random-data`：value 内容随机二进制，非固定字符串

`--expiry-range min-max`：SET 时随机设置 key 过期时间 (ms)

b）Key 配置（高频：热点 / 随机 / 顺序压测）

| 参数                          | 释义                                                         |
| ----------------------------- | ------------------------------------------------------------ |
| `--key-prefix memtier-`       | key 前缀                                                     |
| `--key-minimum/--key-maximum` | key 数字编号上下限，key 范围`[min,max]`                      |
| `--key-pattern=R:R`           | SET 分布：GET 分布，R/Z/S/G/P                                |
| `--key-zipf-exp 1.2`          | Zipf 热点系数 (0~5)，数值越大少数热点 key 访问越密集，线上业务仿真 |
| `--key-stddev/key-median`     | 高斯分布标准差、中位数                                       |

6）WAIT 等待参数（WAIT Options，主从同步延迟压测）

`--wait-ratio=1:1`：SET:WAIT 比例，写完等待主从同步完成

`--num-slaves 1-3`：WAIT 等待随机 N 个从库同步成功

`--wait-timeout 100-500`：WAIT 超时随机毫秒区间

#### 2.3 Client 端执行测试

````
$ memtier_benchmark \
-s ${SERVERIP} -p 6379 \
-t 4 -c 30 \
--test-time=300 \
--ratio=1:10 \
--data-size=128 \
--key-minimum=1 --key-maximum=100000 \
--key-pattern=R:R \
--out-file=run.log --json-out-file=result.json
````

1）连接参数

- `-s ${SERVERIP}`：Redis 服务 IP 地址（变量，由 lava 多节点缓存赋值）
- `-p 6379`：Redis 端口默认 6379

2）并发参数

- `-t 4`：**4 个工作线程**

- `-c 30`：每个线程创建 30 个客户端连接

  总连接数 = 4 × 30 = 120 个 TCP 连接

3）压测时长

- `--test-time=300`：持续压测 **300 秒（5 分钟）**，跑完自动结束，不用指定总请求`-n`

4）读写配比

- `--ratio=1:10`：SET:GET = 1:10

  每 1 次写 (SET)，搭配 10 次读 (GET)，标准读多写少业务模型

5）Value 数据

- `--data-size=128`：写入的 value 固定 **128 字节**

6）Key 范围

- `--key-minimum=1`：key 编号从 1 开始

- --key-maximum=100000 ：最大 key 编号 100000

  一共预生成 10 万个可用 KEY

7）KEY 分布模式

- --key-pattern=R:R

  前 R=SET 的 key 随机分布；后 R=GET 的 key 随机分布

  R=Random 均匀随机取key，无热点，均匀压全量 key

8）结果落地

- `--out-file=run.log`：人类可读文本日志（吞吐、P50/P99 延迟、命中率）
- `--json-out-file=result.json`：结构化 JSON 结果，方便脚本 awk/python 提取指标、写入 result.txt 适配 LAVA 报告

测试结果：

````
4         Threads
30        Connections per thread
300       Seconds


ALL STATS
============================================================================================================================
Type         Ops/sec     Hits/sec   Misses/sec    Avg. Latency     p50 Latency     p99 Latency   p99.9 Latency       KB/sec 
----------------------------------------------------------------------------------------------------------------------------
Sets          157.65          ---          ---        68.60511        51.96700       288.76700       325.63100        26.77 
Gets         1574.17         1.60      1572.57        68.64697        51.96700       286.71900       327.67900        58.42 
Waits           0.00          ---          ---             ---             ---             ---             ---          --- 
Totals       1731.81         1.60      1572.57        68.64316        51.96700       286.71900       325.63100        85.19 


Request Latency Distribution
Type     <= msec         Percent
------------------------------------------------------------------------
SET       8.831        0.000
SET      34.047        5.000
SET      38.399       10.000
SET      40.703       15.000
SET      42.495       20.000
SET      44.031       25.000
SET      45.823       30.000
SET      47.359       35.000
SET      48.895       40.000
SET      50.431       45.000
SET      51.967       50.000
SET      52.735       52.500
SET      53.759       55.000
SET      54.783       57.500
SET      55.807       60.000
SET      56.831       62.500
SET      58.111       65.000
SET      59.391       67.500
SET      60.671       70.000
SET      61.951       72.500
SET      63.231       75.000
SET      63.999       76.250
SET      65.023       77.500
SET      66.047       78.750
SET      67.071       80.000
SET      68.607       81.250
SET      70.143       82.500
SET      72.191       83.750
SET      75.775       85.000
SET      80.895       86.250
SET      91.135       87.500
SET      97.791       88.125
SET     105.983       88.750
SET     115.199       89.375
SET     125.439       90.000
SET     137.215       90.625
SET     148.479       91.250
SET     159.743       91.875
SET     171.007       92.500
SET     181.247       93.125
SET     192.511       93.750
SET     197.631       94.062
SET     202.751       94.375
SET     208.895       94.688
SET     212.991       95.000
SET     218.111       95.312
SET     224.255       95.625
SET     228.351       95.938
SET     233.471       96.250
SET     239.615       96.562
SET     244.735       96.875
SET     248.831       97.031
SET     250.879       97.188
SET     253.951       97.344
SET     257.023       97.500
SET     261.119       97.656
SET     264.191       97.812
SET     268.287       97.969
SET     270.335       98.125
SET     274.431       98.281
SET     276.479       98.438
SET     278.527       98.516
SET     280.575       98.594
SET     282.623       98.672
SET     284.671       98.750
SET     284.671       98.828
SET     286.719       98.906
SET     288.767       98.984
SET     288.767       99.062
SET     290.815       99.141
SET     292.863       99.219
SET     292.863       99.258
SET     294.911       99.297
SET     294.911       99.336
SET     296.959       99.375
SET     296.959       99.414
SET     299.007       99.453
SET     299.007       99.492
SET     301.055       99.531
SET     303.103       99.570
SET     303.103       99.609
SET     305.151       99.629
SET     305.151       99.648
SET     307.199       99.668
SET     307.199       99.688
SET     309.247       99.707
SET     309.247       99.727
SET     309.247       99.746
SET     311.295       99.766
SET     313.343       99.785
SET     315.391       99.805
SET     315.391       99.814
SET     315.391       99.824
SET     317.439       99.834
SET     319.487       99.844
SET     319.487       99.854
SET     321.535       99.863
SET     321.535       99.873
SET     323.583       99.883
SET     325.631       99.893
SET     325.631       99.902
SET     325.631       99.907
SET     325.631       99.912
SET     327.679       99.917
SET     327.679       99.922
SET     327.679       99.927
SET     329.727       99.932
SET     329.727       99.937
SET     331.775       99.941
SET     333.823       99.946
SET     333.823       99.951
SET     339.967       99.954
SET     342.015       99.956
SET     344.063       99.958
SET     344.063       99.961
SET     346.111       99.963
SET     346.111       99.966
SET     346.111       99.968
SET     352.255       99.971
SET     354.303       99.973
SET     358.399       99.976
SET     362.495       99.977
SET     362.495       99.978
SET     362.495       99.979
SET     362.495       99.980
SET     364.543       99.982
SET     364.543       99.983
SET     366.591       99.984
SET     380.927       99.985
SET     380.927       99.987
SET     419.839       99.988
SET     419.839       99.988
SET     419.839       99.989
SET     419.839       99.990
SET     419.839       99.990
SET     419.839       99.991
SET     419.839       99.991
SET     532.479       99.992
SET     532.479       99.993
SET     532.479       99.993
SET     573.439       99.994
SET     573.439       99.994
SET     573.439       99.995
SET     573.439       99.995
SET     573.439       99.995
SET     573.439       99.995
SET     573.439       99.996
SET     577.535       99.996
SET     577.535       99.996
SET     577.535       99.997
SET     577.535       99.997
SET     577.535       99.997
SET     577.535       99.997
SET     577.535       99.997
SET     577.535       99.998
SET     577.535       99.998
SET     577.535       99.998
SET     602.111       99.998
SET     602.111      100.000
---
GET       6.879        0.000
GET      33.791        5.000
GET      38.399       10.000
GET      40.703       15.000
GET      42.495       20.000
GET      44.031       25.000
GET      45.567       30.000
GET      47.359       35.000
GET      48.895       40.000
GET      50.431       45.000
GET      51.967       50.000
GET      52.735       52.500
GET      53.759       55.000
GET      54.783       57.500
GET      55.807       60.000
GET      56.831       62.500
GET      58.111       65.000
GET      59.391       67.500
GET      60.671       70.000
GET      61.951       72.500
GET      63.231       75.000
GET      63.999       76.250
GET      64.767       77.500
GET      66.047       78.750
GET      67.071       80.000
GET      68.607       81.250
GET      70.143       82.500
GET      72.191       83.750
GET      75.775       85.000
GET      80.895       86.250
GET      90.111       87.500
GET      97.279       88.125
GET     105.471       88.750
GET     115.199       89.375
GET     126.463       90.000
GET     137.215       90.625
GET     149.503       91.250
GET     160.767       91.875
GET     172.031       92.500
GET     183.295       93.125
GET     193.535       93.750
GET     198.655       94.062
GET     204.799       94.375
GET     209.919       94.688
GET     215.039       95.000
GET     220.159       95.312
GET     225.279       95.625
GET     230.399       95.938
GET     236.543       96.250
GET     241.663       96.562
GET     246.783       96.875
GET     249.855       97.031
GET     252.927       97.188
GET     254.975       97.344
GET     258.047       97.500
GET     261.119       97.656
GET     264.191       97.812
GET     268.287       97.969
GET     270.335       98.125
GET     272.383       98.281
GET     276.479       98.438
GET     278.527       98.516
GET     280.575       98.594
GET     280.575       98.672
GET     282.623       98.750
GET     284.671       98.828
GET     286.719       98.906
GET     286.719       98.984
GET     288.767       99.062
GET     290.815       99.141
GET     292.863       99.219
GET     292.863       99.258
GET     294.911       99.297
GET     294.911       99.336
GET     296.959       99.375
GET     299.007       99.414
GET     299.007       99.453
GET     301.055       99.492
GET     301.055       99.531
GET     303.103       99.570
GET     305.151       99.609
GET     305.151       99.629
GET     307.199       99.648
GET     307.199       99.668
GET     309.247       99.688
GET     309.247       99.707
GET     311.295       99.727
GET     311.295       99.746
GET     313.343       99.766
GET     313.343       99.785
GET     315.391       99.805
GET     317.439       99.814
GET     317.439       99.824
GET     317.439       99.834
GET     319.487       99.844
GET     321.535       99.854
GET     321.535       99.863
GET     323.583       99.873
GET     323.583       99.883
GET     325.631       99.893
GET     327.679       99.902
GET     327.679       99.907
GET     329.727       99.912
GET     329.727       99.917
GET     331.775       99.922
GET     331.775       99.927
GET     333.823       99.932
GET     333.823       99.937
GET     335.871       99.941
GET     337.919       99.946
GET     339.967       99.951
GET     342.015       99.954
GET     342.015       99.956
GET     344.063       99.958
GET     344.063       99.961
GET     346.111       99.963
GET     346.111       99.966
GET     348.159       99.968
GET     350.207       99.971
GET     352.255       99.973
GET     354.303       99.976
GET     358.399       99.977
GET     360.447       99.978
GET     364.543       99.979
GET     366.591       99.980
GET     372.735       99.982
GET     378.879       99.983
GET     385.023       99.984
GET     391.167       99.985
GET     397.311       99.987
GET     405.503       99.988
GET     409.599       99.988
GET     415.743       99.989
GET     421.887       99.990
GET     423.935       99.990
GET     434.175       99.991
GET     438.271       99.991
GET     442.367       99.992
GET     454.655       99.993
GET     466.943       99.993
GET     483.327       99.994
GET     485.375       99.994
GET     491.519       99.995
GET     495.615       99.995
GET     503.807       99.995
GET     511.999       99.995
GET     516.095       99.996
GET     522.239       99.996
GET     532.479       99.996
GET     544.767       99.997
GET     552.959       99.997
GET     552.959       99.997
GET     557.055       99.997
GET     557.055       99.997
GET     565.247       99.998
GET     573.439       99.998
GET     573.439       99.998
GET     585.727       99.998
GET     589.823       99.998
GET     593.919       99.998
GET     593.919       99.998
GET     598.015       99.999
GET     598.015       99.999
GET     598.015       99.999
GET     606.207       99.999
GET     606.207       99.999
GET     606.207       99.999
GET     618.495       99.999
GET     618.495       99.999
GET     622.591       99.999
GET     622.591       99.999
GET     622.591       99.999
GET     622.591       99.999
GET     622.591       99.999
GET     626.687       99.999
GET     626.687       99.999
GET     626.687       99.999
GET     626.687      100.000
GET     626.687      100.000
GET     638.975      100.000
GET     638.975      100.000
GET     638.975      100.000
GET     638.975      100.000
GET     638.975      100.000
GET     638.975      100.000
GET     638.975      100.000
GET     638.975      100.000
GET     638.975      100.000
GET     638.975      100.000
GET     655.359      100.000
GET     655.359      100.000
---
WAIT      0.000      100.000
````

关键指标：

- **Ops/sec**：每秒总操作数（包含请求、响应全过程）。
- **Hits/sec**：每秒**命中**的读操作数（读取到已存在的有效数据）。
- **Misses/sec**：每秒**未命中**的读操作数（读取了不存在的 key）。
- **Avg. / p50 / p99 / p99.9 Latency**：平均延迟 / 50%请求的延迟 / 99%请求的延迟 / 99.9%请求的延迟（单位毫秒）。
- **KB/sec**：每秒网络读写吞吐量。

操作类型

| 操作                       | 解读                                                         |
| :------------------------- | :----------------------------------------------------------- |
| **Sets (157.65 ops/sec)**  | 每秒写入 157.65 个新 key。这是数据填充的来源，量不大，平均延迟约 68.6μs，99.9% 的写入在 325μs 内完成，性能正常。 |
| **Gets (1574.17 ops/sec)** | 每秒执行 1574 次读操作，但**命中率极低**：只有 1.6 次/秒命中，1572.57 次/秒都是 Miss（读不存在的 key）。 |
| **Waits (0)**              | 没有等待类操作（如阻塞读）。                                 |
| **Totals**                 | 总处理能力约 1731 请求/秒，吞吐量仅 85.19 KB/s（非常低，因为大部分读未命中可能返回空或极小数据）。 |
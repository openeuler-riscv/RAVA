## 在 openEuler RISC-V 镜像中执行 k6 测试

### 1. k6 介绍

k6 是 Grafana 推出的开源轻量负载 / 性能测试工具，核心定位面向开发者、CI/CD 自动化压测k6：

- 底层架构：核心引擎由 Go 编写，单机可支撑上万虚拟用户（VU），内存占用远低于 JMeter，适合嵌入式、RISC-V 低资源设备；

- 脚本语言：用标准 JavaScript 编写压测用例，上手简单，无需复杂 GUI；

- 核心用途：HTTP/HTTPS API、Web、TCP、WebSocket、S3 等接口性能压测，支持负载、压力、稳定性、冒烟测试；

- 输出能力：控制台实时指标、JSON/CSV 报告，可对接 Prometheus+Grafana、LAVA 测试框架做自动化采集；

- 生态扩展：支持浏览器压测、SQL、MQTT 等扩展插件，适配云原生自动化流水线。

核心指标

- `http_req_duration`：请求耗时（p95/p99 分位数）
- `http_reqs`：吞吐量 QPS
- `http_req_failed`：错误率
- `vus`：并发虚拟用户数

### 2. 执行测试

安装 go

````
$ dnf install golang git openssl-devel glibc-devel -y

# 查看 go 版本
$ go version

# 查看系统 Go 根目录
$ go env GOROOT

# 确认目标架构为 riscv64
$ go env GOARCH
````

从源码编译 k6

````
$ git clone https://github.com/grafana/k6.git
$ cd k6
$ CGO_ENABLED=1 go build -o k6 .
$ ./k6 version
k6 v2.0.1-0.20260617153741-2ed76b60eb10 (commit/2ed76b60eb, go1.25.11, linux/riscv64)
````

k6 命令行格式

````
$ ./k6 -h

         /\      Grafana   /‾‾/  
    /\  /  \     |\  __   /  /   
   /  \/    \    | |/ /  /   ‾‾\ 
  /          \   |   (  |  (‾)  |
 / __________ \  |_|\_\  \_____/ 

Grafana k6 is an easy-to-use, open-source load and performance testing tool

Usage:
  k6 [command]

Core Commands:
  new         Create a test
  run         Run a test
  cloud       Run and manage Grafana Cloud tests

Additional Commands:
  archive     Create an archive
  completion  Generate the autocompletion script for the specified shell
  deps        Resolve and list the dependencies of a test
  features    List available feature flags
  inspect     Inspect a script or archive
  x           Extension subcommands

Flags:
  -h, --help      Show help
      --version   Show version information

Examples:
  # Create a test
  $ k6 new test.js

  # Run a test
  $ k6 run test.js

  # Run a test in Grafana Cloud
  $ k6 cloud run test.js

  # Run locally, stream results to Grafana Cloud
  $ k6 cloud run --local-execution test.js

Documentation:
  # Look up the JavaScript API, examples, and best practices
  $ k6 x docs

  # Discover available k6 extensions
  $ k6 x explore

Use "k6 [command] --help" for more information about a command.
$ ./k6 run -h
Start a test. This also exposes a REST API to interact with it. Various k6 subcommands offer
a commandline interface for interacting with it.

Usage:
  k6 run [flags]

Examples:
  # Run a single VU, once.
  k6 run script.js

  # Run a single VU, 10 times.
  k6 run -i 10 script.js

  # Run 5 VUs, splitting 10 iterations between them.
  k6 run -u 5 -i 10 script.js

  # Run 5 VUs for 10s.
  k6 run -u 5 -d 10s script.js

  # Ramp VUs from 0 to 100 over 10s, stay there for 60s, then 10s down to 0.
  k6 run -u 0 -s 10s:100 -s 60s:100 -s 10s:0

  # Send metrics to a remote storage using the OpenTelemetry output.
  k6 run -o opentelemetry

Flags:
  -u, --vus int                             number of virtual users (default 1)
  -d, --duration duration                   test duration limit
  -i, --iterations int                      script total iteration limit (among all VUs)
  -s, --stage stage                         add a stage, as `[duration]:[target]`
      --execution-segment string            limit execution to the specified segment, e.g. 10%, 1/3, 0.2:2/3
      --execution-segment-sequence string   the execution segment sequence
  -p, --paused                              start the test in a paused state
      --no-setup                            don't run setup()
      --no-teardown                         don't run teardown()
      --max-redirects int                   follow at most n redirects (default 10)
      --batch int                           max parallel batch reqs (default 20)
      --batch-per-host int                  max parallel batch reqs per host (default 6)
      --rps int                             limit requests per second
      --user-agent string                   user agent for http requests (default "Grafana k6/2.0.0")
      --http-debug string[="headers"]       log all HTTP requests and responses. Excludes body by default. To
                                            include body use '--http-debug=full'
      --insecure-skip-tls-verify            skip verification of TLS certificates
      --no-connection-reuse                 disable keep-alive connections
      --no-vu-connection-reuse              don't reuse connections between iterations
      --min-iteration-duration duration     minimum amount of time k6 will take executing a single iteration
  -w, --throw                               throw warnings (like failed http requests) as errors
      --blacklist-ip ip range               blacklist an ip range from being called
      --block-hostnames pattern             block a case-insensitive hostname pattern, with optional leading
                                            wildcard, from being called
      --summary-trend-stats stats           define stats for trend metrics (response times), one or more as
                                            'avg,p(95),...' (default 'avg, min, med, max, p(90), p(95)')
      --summary-time-unit string            define the time unit used to display the trend stats. Possible units
                                            are: 's', 'ms' and 'us'
      --system-tags strings                 only include these system tags in metrics (default "proto, subproto,
                                            status, method, url, name, group, check, error, error_code,
                                            tls_version, scenario, service, expected_response")
      --tag tag                             add a tag to be applied to all samples, as `[name]=[value]`
      --console-output string               redirects the console logging to the provided output file
      --discard-response-bodies             Read but don't process or save HTTP response bodies
      --local-ips string                    Client IP Ranges and/or CIDRs from which each VU will be making
                                            requests, e.g. '192.168.220.1,192.168.0.10-192.168.0.25',
                                            'fd:1::0/120', etc.
      --dns string                          DNS resolver configuration. Possible ttl values are: 'inf' for a
                                            persistent cache, '0' to disable the cache, or a positive duration,
                                            e.g. '1s', '1m', etc. Milliseconds are assumed if no unit is provided.
                                            Possible select values to return a single IP are: 'first', 'random' or
                                            'roundRobin'. Possible policy values are: 'preferIPv4', 'preferIPv6',
                                            'onlyIPv4', 'onlyIPv6' or 'any'. (default
                                            "ttl=5m,select=random,policy=preferIPv4")
      --include-system-env-vars             pass the real system environment variables to the runtime (default true)
      --compatibility-mode string           JavaScript compiler compatibility mode, "extended" or "base"
                                            base: pure Sobek - Golang JS VM supporting ES6+
                                            extended: base + sets "global" as alias for "globalThis"
                                             (default "extended")
  -t, --type string                         override test type, "js" or "archive"
  -e, --env VAR=value                       add/override environment variable with VAR=value
      --no-thresholds                       don't run thresholds
      --summary-mode string                 determine the summary mode, "compact", "full" or "disabled" (default
                                            "compact")
      --summary-export string               output the end-of-test summary report to JSON file
      --new-machine-readable-summary        enables the new machine-readable summary, which is used for summary
                                            exports and as handleSummary() argument
      --traces-output string                set the output for k6 traces, possible values are
                                            none,otel[=host:port] (default "none")
  -o, --out uri                             uri for an external metrics database
  -l, --linger                              keep the API server alive past test end
      --no-usage-report                     don't send anonymous usagestats
                                            (https://grafana.com/docs/k6/latest/set-up/usage-collection/)
      --features stringArray                enable feature flags (comma-separated)
  -h, --help                                help for run

Global Flags:
  -a, --address string              address for the REST API server (e.g. localhost:6565); the server is disabled
                                    when not set
  -c, --config string               JSON config file (default "/root/.config/k6/config.json")
      --log-format string           log output format
      --log-output string           change the output for k6 logs, possible values are: 'stderr', 'stdout',
                                    'none', 'loki[=host:port]', 'file[=./path.fileformat]' (default "stderr")
      --no-color                    disable colored output
      --profiling-enabled           enable profiling (pprof) endpoints, requires the REST API to be enabled (--address)
  -q, --quiet                       disable progress updates
      --secret-source stringArray   setting secret sources for k6 file[=./path.fileformat],
  -v, --verbose                     enable verbose logging
````

k6 run 核心参数详解

1）并发 & 时长控制（基础压测配置）

| 参数              | 含义                           | 示例                           |
| ----------------- | ------------------------------ | ------------------------------ |
| `-u/--vus int`    | 虚拟并发用户数                 | `-u 50` 50 并发                |
| `-d/--duration`   | 压测持续时间                   | `-d 60s` 压 60 秒；支持 `m/h`  |
| `-i/--iterations` | 全局总请求迭代次数，跑完即停止 | `-i 10000` 总请求 1 万次       |
| `-s/--stage`      | 阶梯加压，格式 `时长:目标并发` | `-s 10s:20 -s 30s:20 -s 10s:0` |

示例：10 秒升到 20 并发，稳定 30 秒，10 秒逐步降为 0，压力场景测试。

2）执行流程控制

`--no-setup`：不执行脚本 `setup()` 前置初始化函数

`--no-teardown`：不执行脚本 `teardown()` 后置清理函数

`-p/--paused`：启动后先暂停，需要调用 REST API 手动开始测试（适合分步自动化）

3）HTTP 请求调优

`--max-redirects`：最大跳转次数，默认 10

`--batch`/`--batch-per-host`：单 VU 并行请求批数，调大提升吞吐量

`--rps int`：全局限制每秒总请求量，限流压测

`--user-agent`：自定义请求 UA 标识

`--insecure-skip-tls-verify`：跳过 HTTPS 证书校验，内网自签证书必备

`--no-connection-reuse`：关闭 HTTP 长连接，模拟短连接场景

`--http-debug=full`：打印完整请求响应报文，定位接口报错

4）错误与断言处理

`-w/--throw`：把接口非 200、check 失败等警告直接抛出为错误，自动化测试用来判定用例失败

`--blacklist-ip / --block-hostnames`：禁止访问指定 IP / 域名，隔离无关服务

5）指标输出与报告

趋势统计配置（延迟指标）

`--summary-trend-stats`：自定义输出延迟分位数，默认 `avg,min,med,max,p(90),p(95)

示例：只保留 p95/p99：

```
$ k6 run --summary-trend-stats="avg,p(95),p(99)" test.js
```

`--summary-time-unit ms`：所有延迟统一展示毫秒，方便脚本提取数据

导出结构化报告（自动化核心）

`--summary-export report.json`：测试结束输出汇总 JSON，包含 QPS、延迟、错误率

`-o/--out uri` 指标实时输出：

- `-o csv=result.csv` 输出 CSV 时序指标，awk 直接解析
- `-o json=stream.json` 实时每一秒指标写入文件
- `-o opentelemetry` 对接 Prometheus/Grafana 可视化

`--new-machine-readable-summary`：标准化机器可读输出，适配 LAVA `lava-test-case` 解析

静默无控制台输出（自动化脚本专用）

`-e VAR=value` 向 JS 脚本注入环境变量，多服务测试不用改脚本

````
$ k6 run -e TARGET=http://192.168.1.100:8080 test.js
````

JS 内读取：`const url = __ENV.TARGET`

7）过滤与标签（多测试用例区分指标）

`--tag module=api-test`：给所有指标打自定义标签，多轮压测区分结果

`--system-tags`：控制指标附带的内置标签（状态码、接口路径等）

8）DNS、网络客户端配置

`--dns`：自定义 DNS 缓存、IPv4/IPv6 优先策略，RISC-V 内网域名解析异常时调整

`--local-ips`：多网卡场景指定客户端出口 IP

9）全局通用 Flags（所有子命令都能用）

`-a/--address 0.0.0.0:6565` 开启 k6 内置 REST 管理 API，可远程启停测试、实时查询指标；不填则关闭 API，节省 RISC-V 设备资源。

`-c --config` 指定 json 配置文件，统一管理压测参数，不用每次传大量命令行参数

`--log-output file=k6.log`：日志输出到文件，而非终端

`--no-color`：关闭彩色日志，防止自动化日志乱码

`-v/--verbose` 详细 debug 日志，排查编译 / 网络问题时开启

`--profiling-enabled`：开启 pprof 性能采样，定位 k6 自身 CPU / 内存占用高的问题（RISC-V 性能调优用）

编写测试脚本 test_url.js

````
import http from 'k6/http';
import { check, sleep } from 'k6';

// 压测并发、时长配置
export const options = {
  vus: 20,
  duration: '30s',
};

export default function () {
  // 读取命令行传入的 TARGET_URL
  const targetUrl = __ENV.TARGET_URL;
  if (!targetUrl) {
    throw new Error("必须通过 -e TARGET_URL=xxx 传入目标地址");
  }

  const res = http.get(targetUrl);

  // 校验返回状态码
  check(res, {
    'response status is 200': (r) => r.status === 200,
  });

  sleep(0.5);
}
````

这是一个简单的 HTTP 压测脚本，用于对指定 URL 进行并发访问测试。

配置部分

- `vus: 20`：模拟 20 个虚拟用户（并发用户）
- `duration: '30s'`：测试持续运行 30 秒

主要逻辑 (`default` 函数)

- 获取目标 URL：从环境变量 `TARGET_URL` 读取，如果未设置则报错

- 发送 HTTP GET 请求

- 校验响应：检查 HTTP 状态码是否为 200

- 睡眠 0.5 秒

在执行测试之前需要先调高文件句柄

````
$ ulimit -n 65535
````

`ulimit`：Linux 内置命令，用来查看 / 修改进程资源软限制；

`-n`：指定修改 open files（可打开文件句柄数）；

`65535`：设置上限为 65535 个。

每一条 HTTP 连接、每一个打开的文件，都会占用一个文件句柄。

为什么 k6 压测必须调大这个值:

用 k6 开 50 并发持续压测，会大量创建短时 HTTP 连接：

- 系统默认 `ulimit -n` 通常只有 **1024**；

- 并发高、请求频繁时，句柄会快速耗尽；

- 耗尽后 k6 直接报错：

​      too many open files / cannot create socket

​      压测中断、QPS 暴跌、大量请求失败。

执行 `ulimit -n 65535` 把单进程能同时持有的连接 / 文件上限拉高，适配高并发压测场景。

测试示例

````
$ ./k6 run \
  -u 50 \
  -d 60s \
  -e TARGET_URL=http://10.30.190.110:80 \
  -q \
  --summary-export result.json \
  -o csv=metrics.csv \
  test_url.js


    TOTAL RESULTS 

    checks_total.......: 5850    96.713218/s
    checks_succeeded...: 100.00% 5850 out of 5850
    checks_failed......: 0.00%   0 out of 5850

    ✓ response status is 200

    HTTP
    http_req_duration..............: avg=9.71ms   min=2.05ms   med=7.65ms   max=107.78ms p(90)=16.14ms  p(95)=22.06ms 
      { expected_response:true }...: avg=9.71ms   min=2.05ms   med=7.65ms   max=107.78ms p(90)=16.14ms  p(95)=22.06ms 
    http_req_failed................: 0.00%  0 out of 5850
    http_reqs......................: 5850   96.713218/s

    EXECUTION
    iteration_duration.............: avg=515.74ms min=504.53ms med=512.79ms max=648.17ms p(90)=525.33ms p(95)=536.39ms
    iterations.....................: 5850   96.713218/s
    vus............................: 50     min=50        max=50
    vus_max........................: 50     min=50        max=50

    NETWORK
    data_received..................: 10 MB  168 kB/s
    data_sent......................: 421 kB 7.0 kB/s
````

`./k6 run`：执行压测脚本的主命令

`-u 50` / `--vus 50`：并发虚拟用户固定 50 个

`-d 60s` / `--duration 60s`：压测持续运行 60 秒

`-e TARGET_URL=http://10.30.190.110:80`：注入环境变量，脚本读取该地址作为被测服务

`-q` / `--quiet`：静默模式，关闭实时滚动日志，只输出最终汇总结果（适合自动化）

`--summary-export result.json`：测试结束后把最终汇总指标存入 JSON 文件，便于程序解析判分

`-o csv=metrics.csv`：实时输出每秒时序指标到 CSV，可观察性能波动

`test_url.js`：你的压测脚本文件

1）Checks 校验结果

````
checks_total.......: 5850    96.713218/s
checks_succeeded...: 100.00% 5850 out of 5850
checks_failed......: 0.00%   0 out of 5850

✓ response status is 200
````

总共执行 5850 次状态码 200 校验，每秒约 96.71 次；

成功率 100%，没有接口报错、没有非 200 返回，服务可用性满分。

2）HTTP 请求核心性能指标

````
http_req_duration..............: avg=9.71ms   min=2.05ms   med=7.65ms   max=107.78ms p(90)=16.14ms  p(95)=22.06ms 
http_req_failed................: 0.00%  0 out of 5850
http_reqs......................: 5850   96.713218/s
````

`http_reqs`：总请求量 5850 次，QPS = 96.71 req/s（系统每秒处理 96.71 个请求）

`http_req_failed`：请求失败率 0%，无连接超时、5xx/4xx 错误

`http_req_duration` 单次接口耗时（仅接口网络 + 服务处理耗时，不含 sleep）：

- avg=9.71ms：平均响应 9.71 毫秒
- med=7.65ms：中位数 7.65ms，大部分请求很快
- max=107.78ms：最差单次耗时 107.78ms，存在少量毛刺
- p90=16.14ms：90% 的请求耗时 ≤16.14ms
- p95=22.06ms：95% 的请求耗时 ≤22.06ms

性能评判参考：p95 延迟越低，服务稳定性越好；

3）EXECUTION 执行层指标

````
iteration_duration.............: avg=515.74ms min=504.53ms med=512.79ms max=648.17ms p(90)=525.33ms p(95)=536.39ms
iterations.....................: 5850   96.713218/s
vus............................: 50     min=50        max=50
````

`iteration_duration`：一次完整循环耗时（http 请求 + sleep (0.5)）

脚本里写了`sleep(0.5)`即 500ms 等待，所以单次循环平均 515ms，和 500ms 基线吻合，差值就是接口耗时；

`iterations`：总循环次数 = 总请求数，每秒 96.71 轮；

`vus`：全程稳定 50 并发，没有自动降并发，系统负载扛得住。

4）NETWORK 网络流量统计

````
data_received..................: 10 MB  168 kB/s
data_sent......................: 421 kB 7.0 kB/s
````

下行接收总数据 10MB，平均每秒 168KB；

上行发送请求总 421KB，流量压力很小，不存在带宽瓶颈。

测试结果 result.json 

````

$ cat result.json 
{
    "metrics": {
        "http_req_connecting": {
            "p(90)": 0,
            "p(95)": 0,
            "avg": 0.18340452991452996,
            "min": 0,
            "med": 0,
            "max": 130.5731
        },
        "data_sent": {
            "count": 421200,
            "rate": 6963.351694869552
        },
        "http_req_duration{expected_response:true}": {
            "min": 2.0513,
            "med": 7.655150000000001,
            "max": 107.786,
            "p(90)": 16.144270000000002,
            "p(95)": 22.067334999999986,
            "avg": 9.716778102564119
        },
        "vus": {
            "value": 50,
            "min": 50,
            "max": 50
        },
        "http_req_failed": {
            "passes": 0,
            "fails": 5850,
            "value": 0
        },
        "http_req_receiving": {
            "min": 0.4987,
            "med": 1.0407,
            "max": 56.6957,
            "p(90)": 2.9100100000000007,
            "p(95)": 4.511279999999999,
            "avg": 1.78367478632479
        },
        "http_reqs": {
            "count": 5850,
            "rate": 96.71321798429935
        },
        "http_req_sending": {
            "med": 0.2405,
            "max": 81.0968,
            "p(90)": 2.28562,
            "p(95)": 3.7328999999999994,
            "avg": 1.0442032478632437,
            "min": 0.1302
        },
        "iteration_duration": {
            "p(95)": 536.39706,
            "avg": 515.7438086837636,
            "min": 504.5315,
            "med": 512.7915,
            "max": 648.1731,
            "p(90)": 525.33593
        },
        "iterations": {
            "count": 5850,
            "rate": 96.71321798429935
        },
        "checks": {
            "passes": 5850,
            "fails": 0,
            "value": 1
        },
        "http_req_duration": {
            "avg": 9.716778102564119,
            "min": 2.0513,
            "med": 7.655150000000001,
            "max": 107.786,
            "p(90)": 16.144270000000002,
            "p(95)": 22.067334999999986
        },
        "data_received": {
            "count": 10167300,
            "rate": 168087.57285671227
        },
        "vus_max": {
            "value": 50,
            "min": 50,
            "max": 50
        },
        "http_req_tls_handshaking": {
            "avg": 0,
            "min": 0,
            "med": 0,
            "max": 0,
            "p(90)": 0,
            "p(95)": 0
        },
        "http_req_waiting": {
            "p(95)": 16.057325,
            "avg": 6.888900068376086,
            "min": 1.2625,
            "med": 5.37335,
            "max": 71.6267,
            "p(90)": 12.54293
        },
        "http_req_blocked": {
            "min": 0.0603,
            "med": 0.1018,
            "max": 132.6196,
            "p(90)": 0.2014,
            "p(95)": 0.3703299999999998,
            "avg": 0.3630004786324799
        }
    },
    "root_group": {
        "groups": {},
        "checks": {
                "response status is 200": {
                    "name": "response status is 200",
                    "path": "::response status is 200",
                    "id": "1119f4883e70b9c066ed858b5348728c",
                    "passes": 5850,
                    "fails": 0
                }
            },
        "name": "",
        "path": "",
        "id": "d41d8cd98f00b204e9800998ecf8427e"
    }
````

输出的 JSON 分为两大块:

metrics：所有性能时序汇总指标（吞吐量、延迟、连接、流量、并发、校验等）；

root_group：分组信息，存放每条 `check` 断言的成功 / 失败明细。

单位约定：

- 时间类（`avg/min/max/p90/p95`）：毫秒 ms
- data_received/data_sent：字节 Byte
- rate：每秒数量

**核心业务性能指标**:

1）吞吐量指标 http_reqs

````
"http_reqs": {
    "count": 5850,
    "rate": 96.71321798429935
}
````

count=5850：测试期间总共发起 5850 次 HTTP 请求

rate≈96.71：稳定吞吐量 96.71 QPS

2）请求整体耗时 http_req_duration（单接口总耗时：网络 + 服务处理）

````
"http_req_duration": {
    "avg": 9.7167,
    "min": 2.0513,
    "med": 7.6551,
    "max": 107.786,
    "p(90)": 16.1442,
    "p(95)": 22.0673
}
````

avg=9.72ms：接口平均响应 9.72 毫秒

med=7.66ms：中位数，一半请求低于 7.66ms

max=107.79ms：单次最大延迟毛刺

p90=16.14ms：90% 请求耗时 ≤16.14ms

p95=22.07ms：95% 请求耗时 ≤22.07ms

3）请求失败指标 http_req_failed

````
"http_req_failed": {
    "passes": 0,
    "fails": 5850,
    "value": 0
}
````

value=0：请求失败率 0%

fails=5850、passes=0 是 k6 内部计数逻辑，`value` 代表失败比例，无 5xx/4xx / 连接超时 / 断连。

4）Check 校验指标 checks（业务断言：状态码 200）

````
"checks": {
    "passes": 5850,
    "fails": 0,
    "value": 1
}
````

- passes=5850：全部 5850 次校验通过
- fails=0：无接口返回非 200
- value=1：校验成功率 100%

root_group 里明细对应：`response status is 200` 这条断言全量通过。

5）迭代次数 iterations

````
"iterations": {
    "count": 5850,
    "rate": 96.7132
}
````

一次 iteration = 脚本一轮循环（http 请求 + sleep），总 5850 轮，每秒 96.71 轮，和 QPS 完全对齐。

6）单次迭代总耗时 iteration_duration（包含 sleep 等待）

````
"iteration_duration": {
    "avg": 515.74ms,
    "p95": 536.40ms
}
````

测试脚本脚本里 `sleep(0.5)` 即 500ms，循环平均 515.74ms，差值就是接口耗时，符合预期；sleep 限制了理论最大 QPS，想压满服务可缩短 / 移除 sleep。

7）并发用户 vus /vus_max

````
"vus": {"value":50,"min":50,"max":50},
"vus_max": {"value":50,"min":50,"max":50}
````

全程固定 50 个并发虚拟用户，无降载、无资源限制导致并发下跌。

**网络细分耗时（定位延迟瓶颈）**：

1）http_req_connecting 建立 TCP 连接：avg=0.18ms，几乎无连接开销，长连接复用正常。

2）http_req_sending 发送请求报文：avg=1.04ms，上传耗时极低。

3）http_req_waiting 服务处理等待（服务端真正处理耗时）：avg=6.89ms，是整个请求延迟的主要组成，说明大部分耗时消耗在后端业务逻辑。

4）http_req_receiving 接收响应体：avg=1.78ms，下载报文耗时很小。

5）http_req_blocked 客户端排队阻塞：avg=0.36ms，无大量连接排队阻塞，句柄限制放开后无瓶颈。

6）http_req_tls_handshaking TLS 握手：全部为 0，使用 HTTP 而非 HTTPS，无证书握手开销。

网络流量统计

````
"data_sent": {"count":421200,"rate":6963.35 B/s},
"data_received": {"count":10167300,"rate":168087.57 B/s}
````

总上传：421 KB，每秒约 6.96 KB/s

总下载：10.17 MB，每秒约 168.09 KB/s




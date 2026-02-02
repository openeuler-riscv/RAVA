在 openEuler RISC-V 执行 wrk 性能测试

### 1. wrk 介绍

wrk 是一款现代的、高性能的 HTTP 基准测试工具，它使用异步事件驱动模型（基于 epoll, kqueue）来实现非常高的并发和极低的系统开销。它通常被用来对 Web 服务进行性能压测和基准测试。

### 2. 测试方法

安装 wrk

````
$ yum install -y wrk
````

wrk 命令格式：

wrk <选项> <目标 URL>

````
$ wrk --help
Usage: wrk <options> <url>                            
  Options:                                            
    -c, --connections <N>  Connections to keep open   
    -d, --duration    <T>  Duration of test           
    -t, --threads     <N>  Number of threads to use   
                                                      
    -s, --script      <S>  Load Lua script file       
    -H, --header      <H>  Add header to request      
        --latency          Print latency statistics   
        --timeout     <T>  Socket/request timeout     
    -v, --version          Print version details      
                                                      
  Numeric arguments may include a SI unit (1k, 1M, 1G)
  Time arguments may include a time unit (2s, 2m, 2h)
````

常用选项

| 选项      | 全称          | 说明                                        | 示例                                                     |
| --------- | ------------- | ------------------------------------------- | -------------------------------------------------------- |
| -c        | --connections | 建立的总连接数（并发用户数）                | -c 100                                                   |
| -d        | --duration    | 测试持续时间                                | -d 30s（30秒）或 -d 1m（1分钟）                          |
| -t        | --threads     | 使用的线程数（建议设置为CPU核心数或稍多）   | -t 4                                                     |
| -s        | --script      | 指定Lua脚本（用于复杂请求、参数化、认证等） | -s post.lua                                              |
| -H        | --header      | 添加HTTP请求头                              | -H "Authorization: Bearer token" 或 -H "User-Agent: wrk" |
| --latency |               | 打印延迟统计信息                            |                                                          |
| --timeout |               | 请求超时时间                                | --timeout 2s                                             |
| -v        | --version     | 打印版本信息                                |                                                          |

#### 2.1 基础 GET 请求测试

使用8个线程，保持1000个并发连接，对目标 URL 持续测试1分钟，请求超时10s，打印延迟统计信息

````
$ wrk -t8 -c1000 -d1m --timeout 10s --latency http://10.30.190.110/
````

为了减少网络因素的干扰，目标 URL 建议是内网中同一个网络中的 web server，也可以自己简单搭建一个 web server，例如在 ip 为 10.240.124.27 的机器上用 nginx 搭建

````
$ apt install -y nginx
$ systemctl status nginx
$ curl http://10.240.124.27:80    //访问测试，确认可以访问web server
````

目标 URL 就是 http://10.240.124.27:80，端口 80 可以省略，即 http://10.240.124.27

测试结果

````
$ wrk -t8 -c1000 -d1m --timeout 10s --latency http://10.240.124.27
Running 1m test @ http://10.240.124.27
  8 threads and 1000 connections
  Thread Stats   Avg      Stdev     Max   +/- Stdev
    Latency   123.48ms   29.29ms 431.43ms   89.96%
    Req/Sec     1.00k   236.74     1.74k    76.89%
  Latency Distribution
     50%  115.42ms
     75%  132.79ms
     90%  148.74ms
     99%  231.89ms
  473520 requests in 1.00m, 387.89MB read
  Socket errors: connect 0, read 928, write 0, timeout 0
Requests/sec:   7878.81
Transfer/sec:      6.45MB
````

测试结果解析

- **Latency（延迟）**: 服务器处理请求所需的时间。

  - `Avg`: 平均延迟
  - `Stdev`: 标准差，表示延迟的波动范围（数值越大，说明延迟波动越大，性能越不稳定）
  - `Max`: 最大延迟
  - `+/- Stdev`: 延迟数据在标准差范围内的分布比例。89.96% 的请求延迟在 `平均值 ± 标准差` (即 123.48ms ± 29.29ms) 的范围内。

- **Req/Sec（每秒请求数）**: 每个线程每秒完成的请求数。

  - `Avg` (平均值): 平均值，每个线程每秒平均完成的请求数。

  - `Stdev` (标准差): 吞吐量的波动范围。

  - `Max` (最大值): 线程在某一秒达到的最高吞吐量。

  - `+/- Stdev` (分布): 在 `平均值 ± 标准差` 的范围内秒级吞吐量的比例

- **Latency Distribution（延迟分布）**

  - `50%` (中位数)**: **115.42ms。有一半的请求响应时间快于 115.42ms，另一半慢于这个值。这个值通常比平均延迟更具参考价值。

  - `75%`**: **132.79ms。75% 的请求响应时间在 132.79ms 以内。

  - `90%`**: **148.74ms。90% 的请求响应时间在 148.74ms 以内。这是衡量“绝大多数用户体验”的一个关键指标，表现良好。

  - `99%` (尾部延迟)**: **231.89ms。99% 的请求响应时间在 231.89ms 以内。只有 1% 的请求慢于这个值。这个值与 90% 的差距 (`231.89ms - 148.74ms = 83.15ms`) 是评估系统是否存在长尾延迟问题的关

- **总数据**:

  - `473520 requests in 1.00m`: 1分钟内总共完成了 473520 个请求
  - `387.89MB read`: 总共读取的数据量

- **汇总指标（最重要）**:

  - **`Requests/sec`（QPS：Request Per Second 每秒请求数）**: 系统每秒处理的请求数。这是衡量吞吐量的**核心指标**。
  - **`Transfer/sec`**: 每秒传输的数据量。

- **Socket error**:

  - `connect 0`: 连接错误数为 0

  - `read 928`: 出现了 928 次 socket 读错误。这通常在极高并发下，服务器或中间件（如负载均衡器）来不及处理，主动断开连接或无法响应时发生。虽然相对于 47 万的总请求数，这个错误率（~0.2%）很低，但它表明系统在当时的压力下已经接近极限，出现了少量不稳定。

  - `write 0`: 写错误为 0

  - `timeout 0`: 超时请求为 0

#### 2.2 带自定义的 Header 的测试

测试需要 Cookie 或 Token 认证的接口

````
$ wrk -t4 -c100 -d30s -H "Content-Type: application/json" -H "Authorization: Bearer YOUR_TOKEN" http://your-website.com/api/endpoint
````

#### 2.3 使用 lua 脚本进行 POST 请求测试

这是 wrk 最强大的功能之一，可以使用 lua 脚本模拟复杂的请求。

创建一个 Lua 脚本文件 post.lua

````
wrk.method = "POST"
wrk.body   = '{"username": "test", "password": "test"}'
wrk.headers["Content-Type"] = "application/json"
````

运行测试

````
wrk -t4 -c100 -d30s -s post.lua http://your-website.com/api/login
````





参考：

https://www.cnblogs.com/quanxiaoha/p/10661650.html

https://ken.io/note/http-benchmark-test-wrk-install-and-use

https://juejin.cn/post/7098758040316280845

https://blog.csdn.net/IT_LanTian/article/details/139775587
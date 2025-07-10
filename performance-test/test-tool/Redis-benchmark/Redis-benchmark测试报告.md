# Redis-benchmark 调研报告

## 一、测试环境

* **操作系统**：openEuler 24.03 LTS-SP1
* **Redis 版本**：4.0.14

---

## 二、环境准备与构建

Redis 自带 `redis-benchmark` 工具，无需单独编译，准备过程如下：

```bash
sudo dnf install -y redis
sudo systemctl enable --now redis
redis-cli ping  # 返回 PONG 表示服务正常
redis-server --version  # 输出 v=4.0.14
```

---

## 三、测试运行与结果

使用 `redis-benchmark` 进行标准测试：

* **请求总数**：10000
* **并发客户端数**：10
* **测试命令**：默认包含 SET、GET、INCR、LPUSH、HSET、LRANGE 等操作

```bash
mkdir -p test_Redis-benchmark
cd test_Redis-benchmark
redis-benchmark -n 10000 -c 10 | tee redis.log
```

### 结果（详细见日志）：

* **吞吐率**：多数操作在 4400–4700 ops/sec
* **延迟分布**：

  * 超过 90% 的请求延迟 ≤ 2ms
  * 所有操作 100% 延迟 ≤ 30ms

---

## 四、关键性能指标说明

| 指标名称 | 含义说明         |
| ---- | ------------ |
| 吞吐率  | 每秒处理请求数量     |
| 延迟分布 | 各百分位的请求响应时间  |
| 最大延迟  | 所有请求中耗时最长的一个 |

---

## 五、结论

Redis 在 openEuler RISC-V 虚拟环境下运行稳定，测试命令执行顺利。

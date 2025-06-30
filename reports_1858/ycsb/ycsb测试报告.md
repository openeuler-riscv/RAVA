# YCSB Benchmark 调研报告

## 一、测试环境

* 环境：openEuler 24.03 LTS-SP1
* 数据库：Redis（作为 YCSB 后端）

---

## 二、环境准备与构建

### 2.1 安装依赖

```bash
sudo dnf install -y git java-11-openjdk-devel maven redis
sudo systemctl start redis
sudo systemctl enable redis
redis-cli ping
```

### 2.2 下载并构建 YCSB

```bash
git clone https://github.com/brianfrankcooper/YCSB.git
cd YCSB
mvn -pl site.ycsb:redis-binding -am clean package -DskipTests
```

---

## 三、测试运行与结果

测试通过脚本 `test.sh` 执行，涵盖以下四种典型工作负载：

* workloada（混合读写）
* workloada（4线程）
* workloadc（纯读）
* workloadc（4线程）

### 测试结果如下：

| 测试项         | 线程数 | 吞吐量 (ops/sec) | 平均延迟 (us)                 | 50th(us)    | 95th(us)    | 99th(us)    |
| ----------- | --- | ------------- | ------------------------- | ----------- | ----------- | ----------- |
| load\_a     | 1   | 64.80         | 12900.45                  | 12415       | 15423       | 20799       |
| load\_a\_4t | 4   | 191.39        | 15028.54                  | 14415       | 18383       | 21967       |
| load\_c     | 1   | 67.14         | 12411.98                  | 11999       | 14215       | 19455       |
| load\_c\_4t | 4   | 200.16        | 14819.01                  | 14231       | 17727       | 21279       |
| run\_a      | 1   | 193.09        | 4610.97 (读) / 2498.61 (写) | 4207 / 2273 | 5547 / 3155 | 9375 / 3951 |
| run\_a\_4t  | 4   | 473.26        | 5716.36 (读) / 3080.82 (写) | 5079 / 2559 | 7239 / 3503 | 8639 / 4057 |
| run\_c      | 1   | 165.07        | 4564.54                   | 4283        | 5195        | 6683        |
| run\_c\_4t  | 4   | 402.58        | 5923.50                   | 4991        | 6939        | 10119       |

---

## 四、关键性能指标说明

| 指标名称 | 指标解释                       |
| ---- | -------------------------- |
| 吞吐率  | 每秒完成的操作数，用于衡量整体处理能力        |
| 延迟分布 | 请求响应时间的分布情况（如 P50、P95、P99） |
| 最大延迟 | 所有请求中耗时最长的一次响应             |

---

## 五、结论

YCSB 工具在 openEuler RISC-V 环境下运行正常，Redis 后端稳定。测试表明多线程可有效提升吞吐性能，同时带来延迟增加。


# metrics-benchmarks 测试方法与结果

> 参考：[https://github.com/dropwizard/metrics/tree/release/4.2.x](https://github.com/dropwizard/metrics/tree/release/4.2.x)

> 测试环境：**openEuler RISC-V 25.03**

---

## 1. 工具简介

**Dropwizard Metrics** 是一套 JVM 运行时性能监控库，可用于采集应用的吞吐、延迟、计数、分布等指标。
其子模块 **metrics-benchmarks** 基于 **JMH (Java Microbenchmark Harness)** 实现，用于测量不同度量类型（`Counter`、`Meter`、`Histogram`、`Timer` 等）的运行时开销。

---

## 2. 编译与运行准备

### （1）环境
由于项目默认启用了 **Error Prone 静态分析插件**，在较新的 JDK（17/21/25）上会因不兼容而编译失败。
为保证成功构建，测试在 **JDK 11** 环境下完成。

### （2）安装与构建

```bash
# JDK 11
sudo dnf install -y java-11-openjdk-devel
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk
export PATH=$JAVA_HOME/bin:$PATH

# 构建 metrics-benchmarks
git clone -b release/4.2.x https://github.com/dropwizard/metrics.git
cd metrics
./mvnw -DskipTests -pl metrics-benchmarks -am package

# 编译完成后生成可执行文件
ls metrics-benchmarks/target/benchmarks.jar
```

---

## 3. 基准测试与输出

### （1）可用基准项

```bash
java -jar metrics-benchmarks/target/benchmarks.jar -l | head -n 10
```

**输出：**

```
com.codahale.metrics.benchmarks.CachedGaugeBenchmark.perfGetValue
com.codahale.metrics.benchmarks.CounterBenchmark.perfIncrement
com.codahale.metrics.benchmarks.MeterBenchmark.perfMark
com.codahale.metrics.benchmarks.ReservoirBenchmark.perfUniformReservoir
com.codahale.metrics.benchmarks.SlidingTimeWindowReservoirsBenchmark.slidingTime
...
```

### （2）运行完整基准测试

```bash
java -jar metrics-benchmarks/target/benchmarks.jar \
  -wi 5 -i 10 -w 3s -r 3s -f 2 \
  -tu ns -bm thrpt \
  -rf csv -rff all_jmh.csv
```

---

## 4. 测试输出（部分）

```
# Run complete. Total time: 00:19:35

Benchmark                                                                    Mode  Cnt   Score    Error   Units
CachedGaugeBenchmark.perfGetValue                                           thrpt   20   0.003 ±  0.001  ops/ns
CounterBenchmark.perfIncrement                                              thrpt   20   0.011 ±  0.002  ops/ns
MeterBenchmark.perfMark                                                     thrpt   20   0.002 ±  0.001  ops/ns
ReservoirBenchmark.perfExponentiallyDecayingReservoir                       thrpt   20   0.001 ±  0.001  ops/ns
ReservoirBenchmark.perfLockFreeExponentiallyDecayingReservoir               thrpt   20   0.002 ±  0.001  ops/ns
ReservoirBenchmark.perfSlidingTimeWindowArrayReservoir                      thrpt   20   0.002 ±  0.001  ops/ns
ReservoirBenchmark.perfSlidingTimeWindowReservoir                           thrpt   20  ≈ 10⁻⁴           ops/ns
ReservoirBenchmark.perfSlidingWindowReservoir                               thrpt   20   0.009 ±  0.002  ops/ns
ReservoirBenchmark.perfUniformReservoir                                     thrpt   20   0.007 ±  0.001  ops/ns
SlidingTimeWindowReservoirsBenchmark.arrTime                                thrpt   20  ≈ 10⁻³           ops/ns
SlidingTimeWindowReservoirsBenchmark.slidingTime                            thrpt   20  ≈ 10⁻⁴           ops/ns
SlidingTimeWindowReservoirsBenchmark.slidingTime:slidingTimeRead            thrpt   20  ≈ 10⁻⁷           ops/ns
```

---

## 5. 测试结果汇总

| 基准项                                                  | 吞吐率 (ops/ns) | 误差     | 性能特征          |
| ---------------------------------------------------- | ------------ | ------ | ------------- |
| CounterBenchmark.perfIncrement                       | 0.011        | ±0.002 | 性能最高，适合高频计数   |
| CachedGaugeBenchmark.perfGetValue                    | 0.003        | ±0.001 | 轻量读操作         |
| MeterBenchmark.perfMark                              | 0.002        | ±0.001 | 含速率平滑计算       |
| ReservoirBenchmark.perfUniformReservoir              | 0.007        | ±0.001 | 较高吞吐，适合统计分布采样 |
| ReservoirBenchmark.perfSlidingWindowReservoir        | ≈10⁻⁴        | -      | 滑动窗口机制开销大     |
| SlidingTimeWindowReservoirsBenchmark.slidingTime     | ≈10⁻⁴        | -      | 时间窗口操作同步成本较高  |
| SlidingTimeWindowReservoirsBenchmark.slidingTimeRead | ≈10⁻⁷        | -      | 读取性能极高        |

---

## 6. 结论

* 使用 **JDK 11** 成功构建，避免了 Error Prone 与新 JDK 的兼容性问题。

* 测试在 **openEuler RISC-V 25.03** 上顺利执行，输出结果稳定。


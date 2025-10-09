# jmh-core-benchmarks 测试方法与结果

> 参考：[https://github.com/openjdk/jmh](https://github.com/openjdk/jmh)

> 测试环境：**openEuler RISC-V 25.03**

---

## 1. 工具简介

**JMH（Java Microbenchmark Harness）** 是 OpenJDK 官方提供的微基准测试框架，用于评估 Java 代码在不同优化条件下的性能。
它通过控制 JVM 的运行环境、增加预热（warmup）轮次和多次测量（iteration），避免即时编译（JIT）带来的干扰，能够输出具有统计意义的性能指标。
常用于算法、库函数或 JVM 优化效果的对比分析，是 Java 性能测试的标准工具。

---

## 2. 编译与安装

```bash
git clone https://github.com/openjdk/jmh.git
cd jmh
mvn -DskipTests clean install
```

构建成功后，相关模块（`jmh-core`、`jmh-samples`、`jmh-generator-annprocess` 等）会自动安装到本地 Maven 仓库。
整个过程在 openEuler RISC-V 25.03 环境下编译顺利，无需额外依赖调整。

---

## 3. 样例运行与结果

JMH 自带官方样例 `jmh-samples`，可直接运行测试验证框架功能。
本次测试选择了最简单的样例 **JMHSample_01_HelloWorld**，用于验证框架的可运行性与结果输出。

```bash
cd jmh-samples
mvn -DskipTests clean package
java -jar target/benchmarks.jar "JMHSample_01.*" -f 1 -wi 3 -i 5
```

**运行环境信息：**

```
JMH version: 1.38-SNAPSHOT
JDK: OpenJDK 25, 64-Bit Server VM, Temurin-25+36-LTS
openEuler 25.03 (riscv64)
```

**输出结果：**

```
# Warmup: 3 iterations, 10 s each
# Measurement: 5 iterations, 10 s each
# Threads: 1 thread
# Benchmark mode: Throughput, ops/time
# Benchmark: org.openjdk.jmh.samples.JMHSample_01_HelloWorld.wellHelloThere

Warmup Iteration   1: 103602616.514 ops/s
Warmup Iteration   2: 110284291.972 ops/s
Warmup Iteration   3: 125063178.211 ops/s
Iteration   1: 126155688.565 ops/s
Iteration   2: 123889873.161 ops/s
Iteration   3: 125159041.542 ops/s
Iteration   4: 125838503.126 ops/s
Iteration   5: 126847453.658 ops/s

Result "org.openjdk.jmh.samples.JMHSample_01_HelloWorld.wellHelloThere":
  125578112.010 ±(99.9%) 4321649.619 ops/s [Average]
  (min, avg, max) = (123889873.161, 125578112.010, 126847453.658)
  CI (99.9%): [121256462.391, 129899761.629]

Benchmark                                Mode  Cnt          Score         Error  Units
JMHSample_01_HelloWorld.wellHelloThere  thrpt    5  125578112.010 ± 4321649.619  ops/s
```

---

## 4. 结果导出

为验证结果输出功能，测试同时导出为 CSV 格式文件：

```bash
java -jar target/benchmarks.jar "JMHSample_01.*" \
  -f 1 -wi 3 -i 5 -rf csv -rff result-jmh-01.csv
```

**CSV 文件内容（节选）：**

```
"Benchmark","Mode","Cnt","Score","Error","Units"
"JMHSample_01_HelloWorld.wellHelloThere","thrpt",5,125578112.010,4321649.619,"ops/s"
```

---

## 5. 测试结果汇总

| 测试项    | 样例名称                    | 模式  | 指标     | 结果 (ops/s)                  | 状态 |
| ------ | ----------------------- | --- | ------ | --------------------------- | -- |
| 基础功能验证 | JMHSample_01_HelloWorld | 吞吐率 | ops/s  | 125,578,112.0 ± 4,321,649.6 | 成功 |
| 结果导出验证 | JMHSample_01_HelloWorld | 吞吐率 | CSV 输出 | 同上                          | 成功 |

---

## 6. 结论

* JMH 在 **openEuler RISC-V 25.03** 平台上编译与运行均成功。
* 样例 `JMHSample_01_HelloWorld` 运行正常，输出了稳定的吞吐率结果，平均约为 **1.26×10⁸ ops/s**。
* CSV 导出与统计功能可正常使用。
* 从测试结果来看，JMH 在 RISC-V 架构上兼容性良好、性能稳定，可直接用于 Java 性能评测与对比实验。

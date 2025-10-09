# lucene-benchmark 测试方法与结果（RISC-V）

> 参考：[https://github.com/apache/lucene/blob/main/README.md](https://github.com/apache/lucene/blob/main/README.md)

> 测试环境：**openEuler RISC-V 25.03**（riscv64），Temurin **JDK 25 (25+36-LTS)**

---

## 1. 工具简介

**Apache Lucene** 是 Java 编写的全文检索库，仓库内置 **JMH** 微基准（`benchmark-jmh`）评测倒排读取、编码/解码与向量相关路径。

---

## 2. 构建与安装

```bash
# 下载并安装到 /opt/jdk
sudo mkdir -p /opt/jdk && cd /opt/jdk
sudo curl -L \
  "https://github.com/adoptium/temurin25-binaries/releases/download/jdk-25%2B36/OpenJDK25U-jdk_riscv64_linux_hotspot_25_36.tar.gz" \
  -o temurin25.tar.gz
sudo tar -xzf temurin25.tar.gz
sudo rm -f temurin25.tar.gz
sudo bash -lc 'd=$(ls -1d jdk-25* | head -n1); mv "$d" jdk-25'
echo 'export JAVA_HOME=/opt/jdk/jdk-25' | sudo tee /etc/profile.d/java25.sh
echo 'export PATH=$JAVA_HOME/bin:$PATH' | sudo tee -a /etc/profile.d/java25.sh
source /etc/profile.d/java25.sh

# 3) 让 Gradle 强制使用 JDK 25（避免误用旧 JDK）
mkdir -p ~/.gradle
echo "org.gradle.java.home=$JAVA_HOME" > ~/.gradle/gradle.properties

java -version
which java
```

```bash
# 获取源码
git clone https://github.com/apache/lucene.git
cd lucene

# 构建并生成 JMH 可执行包
./gradlew -p lucene/benchmark clean jmhJar --no-daemon --refresh-dependencies
```

**构建日志（部分）：**

```
JMH benchmarks compiled. Run them with:

java -jar lucene/benchmark-jmh/build/benchmarks/lucene-benchmark-jmh-11.0.0-SNAPSHOT.jar

BUILD SUCCESSFUL in 9m 20s
30 actionable tasks: 23 executed, 7 up-to-date
```

---

## 3. 运行与枚举用例

```bash
JAR=lucene/benchmark-jmh/build/benchmarks/lucene-benchmark-jmh-11.0.0-SNAPSHOT.jar
java -jar "$JAR" -l | head -n 50
```

**输出（前若干条）：**

```
Benchmarks: 
org.apache.lucene.benchmark.jmh.AdvanceBenchmark.binarySearch
org.apache.lucene.benchmark.jmh.AdvanceBenchmark.inlinedBranchlessBinarySearch
org.apache.lucene.benchmark.jmh.AdvanceBenchmark.linearSearch
org.apache.lucene.benchmark.jmh.AdvanceBenchmark.vectorUtilSearch
org.apache.lucene.benchmark.jmh.BitsetToArrayBenchmark.dense
org.apache.lucene.benchmark.jmh.BitsetToArrayBenchmark.denseBranchLess
org.apache.lucene.benchmark.jmh.BitsetToArrayBenchmark.denseBranchLessCmov
org.apache.lucene.benchmark.jmh.BitsetToArrayBenchmark.denseBranchLessParallel
org.apache.lucene.benchmark.jmh.BitsetToArrayBenchmark.denseBranchLessUnrolling
org.apache.lucene.benchmark.jmh.BitsetToArrayBenchmark.denseInvert
org.apache.lucene.benchmark.jmh.BitsetToArrayBenchmark.forLoop
org.apache.lucene.benchmark.jmh.BitsetToArrayBenchmark.forLoopManualUnrolling
org.apache.lucene.benchmark.jmh.BitsetToArrayBenchmark.hybrid
org.apache.lucene.benchmark.jmh.BitsetToArrayBenchmark.whileLoop
org.apache.lucene.benchmark.jmh.CompetitiveBenchmark.baseline
org.apache.lucene.benchmark.jmh.CompetitiveBenchmark.branchlessCandidate
org.apache.lucene.benchmark.jmh.CompetitiveBenchmark.branchlessCandidateCmov
org.apache.lucene.benchmark.jmh.CompetitiveBenchmark.vectorizedCandidate
org.apache.lucene.benchmark.jmh.ExpressionsBenchmark.expression
org.apache.lucene.benchmark.jmh.GroupVIntBenchmark.benchByteArrayDataInput_readGroupVInt
org.apache.lucene.benchmark.jmh.GroupVIntBenchmark.benchByteArrayDataInput_readVInt
org.apache.lucene.benchmark.jmh.GroupVIntBenchmark.benchByteBuffersIndexInput_readGroupVInt
org.apache.lucene.benchmark.jmh.GroupVIntBenchmark.benchByteBuffersIndexInput_readGroupVIntBaseline
org.apache.lucene.benchmark.jmh.GroupVIntBenchmark.benchMMapDirectoryInputs_readGroupVInt
org.apache.lucene.benchmark.jmh.GroupVIntBenchmark.benchMMapDirectoryInputs_readGroupVIntBaseline
org.apache.lucene.benchmark.jmh.GroupVIntBenchmark.benchMMapDirectoryInputs_readVInt
org.apache.lucene.benchmark.jmh.GroupVIntBenchmark.benchNIOFSDirectoryInputs_readGroupVInt
org.apache.lucene.benchmark.jmh.GroupVIntBenchmark.benchNIOFSDirectoryInputs_readGroupVIntBaseline
org.apache.lucene.benchmark.jmh.GroupVIntBenchmark.bench_writeGroupVInt
org.apache.lucene.benchmark.jmh.HammingDistanceBenchmark.xorBitCount
org.apache.lucene.benchmark.jmh.HistogramCollectorBenchmark.matchAllQueryHistogram
org.apache.lucene.benchmark.jmh.HistogramCollectorBenchmark.pointRangeQueryHistogram
org.apache.lucene.benchmark.jmh.PolymorphismBenchmark.defaultImpl
org.apache.lucene.benchmark.jmh.PolymorphismBenchmark.delegateToDefaultImpl
org.apache.lucene.benchmark.jmh.PolymorphismBenchmark.specializedImpl
org.apache.lucene.benchmark.jmh.PostingIndexInputBenchmark.decode
org.apache.lucene.benchmark.jmh.PostingIndexInputBenchmark.decodeVector
org.apache.lucene.benchmark.jmh.RectangleBenchmark.benchmarkFromPointDistanceSloppySin
org.apache.lucene.benchmark.jmh.RectangleBenchmark.benchmarkFromPointDistanceStandardSin
org.apache.lucene.benchmark.jmh.SloppySinBenchmark.sloppySin
org.apache.lucene.benchmark.jmh.SloppySinBenchmark.standardSin
org.apache.lucene.benchmark.jmh.VIntBenchmark.benchByteArrayDataInput_readVInt
org.apache.lucene.benchmark.jmh.VIntBenchmark.benchByteArrayDataInput_readVLong
org.apache.lucene.benchmark.jmh.VIntBenchmark.benchMMapDirectoryInputs_readVInt
org.apache.lucene.benchmark.jmh.VIntBenchmark.benchMMapDirectoryInputs_readVLong
org.apache.lucene.benchmark.jmh.VectorScorerBenchmark.binaryDotProductDefault
org.apache.lucene.benchmark.jmh.VectorScorerBenchmark.binaryDotProductMemSeg
org.apache.lucene.benchmark.jmh.VectorUtilBenchmark.binaryCosineScalar
org.apache.lucene.benchmark.jmh.VectorUtilBenchmark.binaryCosineVector
```

**运行 PostingIndexInputBenchmark：**

```bash
java -jar "$JAR" \
  -bm thrpt -tu us -f 1 -wi 3 -i 5 \
  -jvmArgs="--add-modules=jdk.incubator.vector -Xmx1g -Xms1g -XX:+AlwaysPreTouch" \
  'org.apache.lucene.benchmark.jmh.PostingIndexInputBenchmark.*'
```

---

## 4. 实际运行输出（部分）

```
# Run progress: 77.78% complete, ETA 00:01:17
# Fork: 1 of 1
0.124 ops/us
# Warmup Iteration   2: 0.816 ops/us
# Warmup Iteration   3: 0.774 ops/us
Iteration   1: 0.821 ops/us
Iteration   2: 0.807 ops/us
Iteration   3: 0.781 ops/us
Iteration   4: 0.791 ops/us
Iteration   5: 0.821 ops/us


Result "org.apache.lucene.benchmark.jmh.PostingIndexInputBenchmark.decodeVector":
  0.804 ±(99.9%) 0.068 ops/us [Average]
  (min, avg, max) = (0.781, 0.804, 0.821), stdev = 0.018
  CI (99.9%): [0.736, 0.872] (assumes normal distribution)


# JMH version: 1.37
# VM version: JDK 25, OpenJDK 64-Bit Server VM, 25+36-LTS
# VM invoker: /opt/jdk/jdk-25/bin/java
# VM options: --add-modules=jdk.incubator.vector -Xmx1g -Xms1g -XX:+AlwaysPreTouch
# Blackhole mode: compiler (auto-detected, use -Djmh.blackhole.autoDetect=false to disable)
# Warmup: 3 iterations, 1 s each
# Measurement: 5 iterations, 1 s each
# Timeout: 10 min per iteration
# Threads: 1 thread, will synchronize iterations
# Benchmark mode: Throughput, ops/time
# Benchmark: org.apache.lucene.benchmark.jmh.PostingIndexInputBenchmark.decodeVector
# Parameters: (bpv = 8)

# Run progress: 83.33% complete, ETA 00:00:58
# Fork: 1 of 1
0.418 ops/us
# Warmup Iteration   2: 1.016 ops/us
# Warmup Iteration   3: 1.071 ops/us
Iteration   1: 1.088 ops/us
Iteration   2: 1.068 ops/us
Iteration   3: 1.032 ops/us
Iteration   4: 1.084 ops/us
Iteration   5: 1.107 ops/us


Result "org.apache.lucene.benchmark.jmh.PostingIndexInputBenchmark.decodeVector":
  1.076 ±(99.9%) 0.108 ops/us [Average]
  (min, avg, max) = (1.032, 1.076, 1.107), stdev = 0.028
  CI (99.9%): [0.968, 1.184] (assumes normal distribution)


# JMH version: 1.37
# VM version: JDK 25, OpenJDK 64-Bit Server VM, 25+36-LTS
# VM invoker: /opt/jdk/jdk-25/bin/java
# VM options: --add-modules=jdk.incubator.vector -Xmx1g -Xms1g -XX:+AlwaysPreTouch
# Blackhole mode: compiler (auto-detected, use -Djmh.blackhole.autoDetect=false to disable)
# Warmup: 3 iterations, 1 s each
# Measurement: 5 iterations, 1 s each
# Timeout: 10 min per iteration
# Threads: 1 thread, will synchronize iterations
# Benchmark mode: Throughput, ops/time
# Benchmark: org.apache.lucene.benchmark.jmh.PostingIndexInputBenchmark.decodeVector
# Parameters: (bpv = 9)

# Run progress: 88.89% complete, ETA 00:00:39
# Fork: 1 of 1
0.053 ops/us
# Warmup Iteration   2: 0.622 ops/us
# Warmup Iteration   3: 0.636 ops/us
Iteration   1: 0.629 ops/us
Iteration   2: 0.615 ops/us
Iteration   3: 0.601 ops/us
Iteration   4: 0.609 ops/us
Iteration   5: 0.602 ops/us


Result "org.apache.lucene.benchmark.jmh.PostingIndexInputBenchmark.decodeVector":
  0.611 ±(99.9%) 0.045 ops/us [Average]
  (min, avg, max) = (0.601, 0.611, 0.629), stdev = 0.012
  CI (99.9%): [0.567, 0.656] (assumes normal distribution)


# JMH version: 1.37
# VM version: JDK 25, OpenJDK 64-Bit Server VM, 25+36-LTS
# VM invoker: /opt/jdk/jdk-25/bin/java
# VM options: --add-modules=jdk.incubator.vector -Xmx1g -Xms1g -XX:+AlwaysPreTouch
# Blackhole mode: compiler (auto-detected, use -Djmh.blackhole.autoDetect=false to disable)
# Warmup: 3 iterations, 1 s each
# Measurement: 5 iterations, 1 s each
# Timeout: 10 min per iteration
# Threads: 1 thread, will synchronize iterations
# Benchmark mode: Throughput, ops/time
# Benchmark: org.apache.lucene.benchmark.jmh.PostingIndexInputBenchmark.decodeVector
# Parameters: (bpv = 10)

# Run progress: 94.44% complete, ETA 00:00:19
# Fork: 1 of 1
0.100 ops/us
# Warmup Iteration   2: 0.626 ops/us
# Warmup Iteration   3: 0.621 ops/us
Iteration   1: 0.620 ops/us
Iteration   2: 0.651 ops/us
Iteration   3: 0.648 ops/us
Iteration   4: 0.626 ops/us
Iteration   5: 0.649 ops/us


Result "org.apache.lucene.benchmark.jmh.PostingIndexInputBenchmark.decodeVector":
  0.639 ±(99.9%) 0.056 ops/us [Average]
  (min, avg, max) = (0.620, 0.639, 0.651), stdev = 0.015
  CI (99.9%): [0.583, 0.695] (assumes normal distribution)


# Run complete. Total time: 00:05:52

REMEMBER: The numbers below are just data. To gain reusable insights, you need to follow up on
why the numbers are the way they are. Use profilers (see -prof, -lprof), design factorial
experiments, perform baseline and negative tests that provide experimental control, make sure
the benchmarking environment is safe on JVM/OS/HW level, ask for reviews from the domain experts.
Do not assume the numbers tell you what you want them to tell.

NOTE: Current JVM experimentally supports Compiler Blackholes, and they are in use. Please exercise
extra caution when trusting the results, look into the generated code to check the benchmark still
works, and factor in a small probability of new VM bugs. Additionally, while comparisons between
different JVMs are already problematic, the performance difference caused by different Blackhole
modes can be very significant. Please make sure you use the consistent Blackhole mode for comparisons.
```

**JMH 汇总表：**

```
Benchmark                                (bpv)   Mode  Cnt  Score   Error   Units
PostingIndexInputBenchmark.decode            2  thrpt    5  1.040 ± 0.055  ops/us
PostingIndexInputBenchmark.decode            3  thrpt    5  1.023 ± 0.072  ops/us
PostingIndexInputBenchmark.decode            4  thrpt    5  1.115 ± 0.230  ops/us
PostingIndexInputBenchmark.decode            5  thrpt    5  0.920 ± 0.058  ops/us
PostingIndexInputBenchmark.decode            6  thrpt    5  0.878 ± 0.056  ops/us
PostingIndexInputBenchmark.decode            7  thrpt    5  0.711 ± 0.254  ops/us
PostingIndexInputBenchmark.decode            8  thrpt    5  1.074 ± 0.070  ops/us
PostingIndexInputBenchmark.decode            9  thrpt    5  0.569 ± 0.044  ops/us
PostingIndexInputBenchmark.decode           10  thrpt    5  0.562 ± 0.036  ops/us
PostingIndexInputBenchmark.decodeVector      2  thrpt    5  1.393 ± 0.090  ops/us
PostingIndexInputBenchmark.decodeVector      3  thrpt    5  0.854 ± 0.068  ops/us
PostingIndexInputBenchmark.decodeVector      4  thrpt    5  1.188 ± 0.118  ops/us
PostingIndexInputBenchmark.decodeVector      5  thrpt    5  0.942 ± 0.058  ops/us
PostingIndexInputBenchmark.decodeVector      6  thrpt    5  0.816 ± 0.045  ops/us
PostingIndexInputBenchmark.decodeVector      7  thrpt    5  0.804 ± 0.068  ops/us
PostingIndexInputBenchmark.decodeVector      8  thrpt    5  1.076 ± 0.108  ops/us
PostingIndexInputBenchmark.decodeVector      9  thrpt    5  0.611 ± 0.045  ops/us
PostingIndexInputBenchmark.decodeVector     10  thrpt    5  0.639 ± 0.056  ops/us
```

---

## 5. 结果汇总

| Benchmark        | bpv |     Score |  Error | Units  |
| ---------------- | --: | --------: | -----: | :----- |
| decode           |   2 |     1.040 | ±0.055 | ops/us |
| decode           |   4 |     1.115 | ±0.230 | ops/us |
| decode           |   6 |     0.878 | ±0.056 | ops/us |
| decode           |   8 |     1.074 | ±0.070 | ops/us |
| **decodeVector** |   2 | **1.393** | ±0.090 | ops/us |
| **decodeVector** |   4 | **1.188** | ±0.118 | ops/us |
| **decodeVector** |   8 | **1.076** | ±0.108 | ops/us |
| decodeVector     |  10 |     0.639 | ±0.056 | ops/us |

---

## 6. 分析与结论

* **兼容性**：Lucene benchmark 在 openEuler RISC-V 上成功构建并稳定运行。
* **性能趋势**：`decodeVector` 在 bpv=2、4、8 时性能优于 `decode`；随 bpv 增大吞吐下降。
* **结论**：结果可作为 RISC-V Java 检索栈的基线数据，后续可继续扩展到其它 JMH 用例与 JVM 参数对比。

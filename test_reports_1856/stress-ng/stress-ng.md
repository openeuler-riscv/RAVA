# stress-ng 测试文档

## 一、测试目的
验证 stress-ng 在 openEuler-25.03环境下能否正常执行，并采集关键性能指标，为系统稳定性与压力测试提供基准数据。



## 二、测试工具安装
```bash
sudo dnf install stress-ng
```

## 三、执行测试

### 使用脚本进行测试

stress-ng 仅提供应用层性能数据，需配合系统监控工具(sar/iostat)获取系统层资源使用率。因此，编写了脚本在每次执行`stress-ng`时使用`sar`和`iostat`进行监控，并从监控log中总结系统性能指标的平均值和峰值。
```
./run_stress_tests.sh

cat test_results/$(date +%Y-%m-%d)/performance_report.txt

```

### 手动测试命令
```bash
# CPU 测试
stress-ng --cpu 4 --cpu-method matrixprod --timeout 60s --metrics

# 内存测试
stress-ng --vm 2 --vm-bytes 2G --vm-method all --timeout 60s --metrics

# 磁盘测试
stress-ng --hdd 1 --hdd-bytes 5G --timeout 60s --metrics --hdd-opts sync

# 混合测试
stress-ng --cpu 2 --vm 1 --vm-bytes 1G --vm-method all --hdd 1 --hdd-bytes 2G --timeout 60s --metrics
```

## 四、 测试结果示例

### `stress-ng`输出

```
[fullname@localhost stress-ng]$ cat test_results/2025-06-17/mixed_test.log
stress-ng: info:  [5273] setting to a 1 min, 0 secs run per stressor
stress-ng: info:  [5273] dispatching hogs: 2 cpu, 1 vm, 1 hdd
stress-ng: metrc: [5273] stressor       bogo ops real time  usr time  sys time   bogo ops/s     bogo ops/s CPU used per       RSS Max
stress-ng: metrc: [5273]                           (secs)    (secs)    (secs)   (real time) (usr+sys time) instance (%)          (KB)
stress-ng: metrc: [5273] cpu                1364     61.10    112.91      0.50        22.32          12.03        92.81          5608
stress-ng: metrc: [5273] vm                 5914     60.49      2.09     54.37        97.77         104.75        93.34       1050120
stress-ng: metrc: [5273] hdd               97966     61.07     20.03     32.25      1604.28        1873.89        85.61          1788
stress-ng: metrc: [5273] miscellaneous metrics:
stress-ng: metrc: [5273] hdd                    0.00 MB/sec read rate (harmonic mean of 1 instance)
stress-ng: metrc: [5273] hdd                  163.56 MB/sec write rate (harmonic mean of 1 instance)
stress-ng: metrc: [5273] hdd                  163.56 MB/sec read/write combined rate (harmonic mean of 1 instance)
stress-ng: info:  [5273] skipped: 0
stress-ng: info:  [5273] passed: 4: cpu (2) vm (1) hdd (1)
stress-ng: info:  [5273] failed: 0
stress-ng: info:  [5273] metrics untrustworthy: 0
stress-ng: info:  [5273] successful run completed in 1 min, 1.14 secs
```

### 经总结的系统性能数据
```
========== stress-ng 性能测试报告 ==========
生成时间: 2025-06-17 05:29:47
测试目录: test_results/2025-06-17

=== 测试环境信息 ===
测试时间: 2025-06-17 10:18:02
操作系统: openEuler 25.03
内核版本: 6.6.0-72.6.0.56.oe2503.riscv64
CPU信息:
CPU核心数: 4
内存大小: 7.5Gi
stress-ng版本: stress-ng, version 0.17.03 (gcc 12.3.1, riscv64 Linux 6.6.0-72.6.0.56.oe2503.riscv64)


=== 测试完成状态 ===
✓ cpu 测试完成
✓ memory 测试完成
✓ disk 测试完成
✓ mixed 测试完成

=== stress-ng 性能指标 ===
--- cpu 测试性能 ---

--- memory 测试性能 ---

--- disk 测试性能 ---
  stress-ng: metrc: [2110] hdd                    0.00 MB/sec read rate (harmonic mean of 1 instance)
  stress-ng: metrc: [2110] hdd                    7.07 MB/sec write rate (harmonic mean of 1 instance)
  stress-ng: metrc: [2110] hdd                    7.07 MB/sec read/write combined rate (harmonic mean of 1 instance)

--- mixed 测试性能 ---
  stress-ng: metrc: [2129] hdd                    0.00 MB/sec read rate (harmonic mean of 1 instance)
  stress-ng: metrc: [2129] hdd                  198.06 MB/sec write rate (harmonic mean of 1 instance)
  stress-ng: metrc: [2129] hdd                  198.06 MB/sec read/write combined rate (harmonic mean of 1 instance)

=== 系统监控指标 ===
--- cpu 测试监控数据 ---
  CPU使用率: 平均 96.98%, 峰值 100.00%
  内存使用率: 平均 4.94%, 峰值 4.95%
  磁盘I/O: 平均 读取0.08MB/s, 写入0.01MB/s; 峰值 读取2.61MB/s, 写入0.07MB/s

--- memory 测试监控数据 ---
  CPU使用率: 平均 49.93%, 峰值 54.11%
  内存使用率: 平均 18.41%, 峰值 30.34%
  磁盘I/O: 平均 读取0.03MB/s, 写入0.01MB/s; 峰值 读取1.95MB/s, 写入0.07MB/s

--- disk 测试监控数据 ---
  CPU使用率: 平均 32.98%, 峰值 96.97%
  内存使用率: 平均 5.21%, 峰值 5.77%
  磁盘I/O: 平均 读取0.08MB/s, 写入9.19MB/s; 峰值 读取2.28MB/s, 写入10.53MB/s

--- mixed 测试监控数据 ---
  CPU使用率: 平均 98.99%, 峰值 100.00%
  内存使用率: 平均 11.76%, 峰值 18.71%
  磁盘I/O: 平均 读取0.03MB/s, 写入111.12MB/s; 峰值 读取1.32MB/s, 写入625.78MB/s

============================================
```




---



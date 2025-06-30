Test Tool List

| 工具名称 | 评测维度 | 使用场景 | 工具下载地址 | 关键指标 | 关键指标的解释 | 备注 |
| -------- | -------- | -------- | ------------ | -------- | -------------- | ---- |
|nbench-byte | 	CPU 整数/浮点性能、内存子系统性能 |硬件性能对比 |http://www.math.utah.edu/~mayer/linux/nbench-byte-2.2.3.tar.gz|三大维度相对于AMD K6/233基准系统的几何平均性能比值：INTEGER INDEX, FLOATING-POINT INDEX, MEMORY INDEX|4项整数操作测试的几何平均/4项FPU测试的几何平均/	3项内存敏感测试几何平均|      |
| stress-ng  | CPU / 内存 / 磁盘 I/O   | 系统稳定性测试、性能基准、压力测试 | https://repo.openeuler.org/openEuler-25.03/EPOL/main/riscv64/Packages/stress-ng-0.17.03-1.oe2503.riscv64.rpm      | • CPU bogo ops/s<br>• 内存带宽 (MB/s)<br>• 磁盘 I/O 吞吐 (MB/s)<br>• CPU/内存/磁盘使用率 (%) | • bogo ops/s：stress-ng 标准化操作数/秒，反映处理能力<br>• 内存带宽：stress-ng 测量的内存读写速率<br>• 磁盘 I/O：stress-ng 测量的磁盘吞吐量<br>• 系统使用率：通过 sar/iostat 监控的实际资源占用 | stress-ng 的metrics输出仅提供应用层性能数据，需配合系统监控工具(sar/iostat)获取系统层资源使用率 |
|  fpmark      |          |          |              |          |                |   未能测试，因为似乎是收费的，官网<https://www.eembc.org/fpmark/>，一篇介绍它的博客也提到它是收费的<https://zhuanlan.zhihu.com/p/398166793>   |
| CoreMark | CPU 综合性能 | 处理器性能基准测试 | https://github.com/eembc/coremark.git | • CoreMark 分数<br>• CoreMark/MHz<br>• Iterations/Sec<br>• 多线程扩展效率 | • CoreMark 分数：EEMBC 官方标准化 CPU 性能指标,似乎等于Iterations/Sec<br>• CoreMark/MHz：处理器性能效率指标，每MHz的CoreMark分数，MHz是处理器运行频率<br>• Iterations/Sec：每秒算法迭代次数 | 官方跑分榜：<https://www.eembc.org/coremark/scores.php> |
|          |          |          |              |          |                |      |
|          |          |          |              |          |                |      |
|          |          |          |              |          |                |      |
|          |          |          |              |          |                |      |
|          |          |          |              |          |                |      |
|          |          |          |              |          |                |      |
|          |          |          |              |          |                |      |


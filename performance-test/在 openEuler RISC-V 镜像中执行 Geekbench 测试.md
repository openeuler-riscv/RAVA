## 在 openEuler RISC-V 镜像中执行 Geekbench 测试

### 1. Geekbench 介绍

Geekbench 是一款主流的跨平台基准测试工具，通过模拟真实场景（如图片编辑、机器学习、文件压缩）对设备的 **CPU** 和 **GPU** 性能进行量化评估，并以直观的分数呈现。其核心价值在于提供了一个跨操作系统（Windows, macOS, iOS, Android 等）和跨架构（x86, ARM）的性能衡量标准。

**核心功能与主要用途**

- **CPU基准测试**：通过一系列模拟日常应用（如网页浏览、视频会议、照片编辑）的任务，分别评估处理器在单核和多核状态下的性能，反映设备的即时响应能力和高负载处理能力。
- **GPU基准测试**：测试显卡在图像处理、计算机视觉和机器学习等任务中的表现，可用于评估设备的游戏、视频编辑潜力。
- **跨平台比较**：这是Geekbench的核心优势之一。其测试方法在不同操作系统上保持一致，让你能大致对比一部安卓手机和一台Windows笔记本的性能差



### 2. 执行测试

从官网下载 Geekbench 6 压缩包，并执行测试

````
$ wget https://cdn.geekbench.com/Geekbench-6.6.0-LinuxRISCVPreview.tar.gz
$ tar -xvf Geekbench-6.6.0-LinuxRISCVPreview.tar.gz
$ cd Geekbench-6.6.0-LinuxRISCVPreview
$ ./geekbench6
Geekbench 6.6.0 Preview : https://www.geekbench.com/

Geekbench 6 for Linux/RISC-V is a preview build. Preview builds require an 
active Internet connection and automatically upload benchmark results to the
Geekbench Browser.

System Information
  Operating System              openEuler 24.03 (LTS-SP3)
  Kernel                        Linux 6.6.0-138.0.0.121.oe2403sp3.riscv64 riscv64
  Model                         QEMU QEMU Virtual Machine
  Motherboard                   N/A

CPU Information
  Name                          rv64imafdch_zicbom_zicbop_zicboz_ziccrse_zicntr_zicsr_zifencei_zihintntl_zihintpause_zihpm_zaamo_zalrsc_zawrs_zfa_zca_zcd_zba_zbb_zbc_zbs_sstc_svadu_svvptc
  Topology                      1 Processor, 8 Cores
  Base Frequency                0.00 Hz

Memory Information
  Size                          7.48 GB


Single-Core
  Running File Compression
  Running Navigation
  Running HTML5 Browser
  Running PDF Renderer
  Running Photo Library
  Running Clang
  Running Text Processing
  Running Asset Compression
  Running Object Detection
  Running Background Blur
  Running Horizon Detection
  Running Object Remover
  Running HDR
  Running Photo Filter
  Running Ray Tracer
  Running Structure from Motion

Multi-Core
  Running File Compression
  Running Navigation
  Running HTML5 Browser
  Running PDF Renderer
  Running Photo Library
  Running Clang
  Running Text Processing
  Running Asset Compression
  Running Object Detection
  Running Background Blur
  Running Horizon Detection
  Running Object Remover
  Running HDR
  Running Photo Filter
  Running Ray Tracer
  Running Structure from Motion


Uploading results to the Geekbench Browser. This could take a minute or two
depending on the speed of your internet connection.

Upload succeeded. Visit the following link and view your results online:

  https://browser.geekbench.com/v6/cpu/17308843

Visit the following link and add this result to your profile:

  https://browser.geekbench.com/v6/cpu/17308843/claim?key=962830
````

测试结果可以到 https://browser.geekbench.com/v6/cpu/17308843 查看，内容如下：

![total_result](D:\git\gitee\rava\test-tool-docs\image\geekbench_testresult_total.jpeg)

![singe_core_performance](D:\git\gitee\rava\test-tool-docs\image\geekbench_single-core_performance.jpeg)

![multi_core_performance](D:\git\gitee\rava\test-tool-docs\image\geekbench_multi-core_performance.jpeg)

**分数解读**：

- **分数越高，性能越强**。分数翻倍，意味着理论性能翻倍。
- **单核分数**：主要反映处理器单个核心的爆发力，直接影响应用启动、网页加载等日常操作的流畅度。
- **多核分数**：反映处理器所有核心协同工作的能力，影响视频渲染、程序编译、游戏等重度任务的效率。

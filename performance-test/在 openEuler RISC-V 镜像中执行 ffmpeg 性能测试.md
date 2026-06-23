## 在 openEuler RISC-V 镜像中执行 ffmpeg 性能测试

### 1. ffmpeg 性能测试介绍

使用 FFmpeg 自带的 `-benchmark` 全局参数执行性能测试，用于测试整个转码或处理流程的总耗时和资源占用。适合评估将一个视频从一种格式转码为另一种格式（或进行滤镜处理）时，硬件和软件配置能达到的整体处理速度。

### 2. 执行测试

基本命令格式

````
ffmpeg [输入选项] -i 输入文件 [处理选项] 输出文件 -benchmark
````

`-benchmark`是FFmpeg内置的性能分析工具。在任意转码、解码命令后加上 `-benchmark` 选项，任务结束后会在终端输出详细的性能报告

安装相关软件包

````
$ dnf install -y ffmpeg
$ ffmpeg -version
````

执行测试

````
$ ffmpeg -benchmark -threads 0 -f lavfi -i testsrc=duration=10:size=1920x1080:rate=30 -an -f null -
ffmpeg version 6.1.1 Copyright (c) 2000-2023 the FFmpeg developers
  built with gcc 12 (GCC)
  configuration: --prefix=/usr --bindir=/usr/bin --datadir=/usr/share/ffmpeg --docdir=/usr/share/doc/ffmpeg --incdir=/usr/include/ffmpeg --libdir=/usr/lib64 --mandir=/usr/share/man --arch=riscv64 --optflags='-O2 -g -grecord-gcc-switches -pipe -fstack-protector-strong -Wall -Werror=format-security -Wp,-D_FORTIFY_SOURCE=2 -Wp,-D_GLIBCXX_ASSERTIONS -specs=/usr/lib/rpm/generic-hardened-cc1 -fasynchronous-unwind-tables -fstack-clash-protection' --extra-ldflags='-Wl,-z,relro -Wl,-z,now -specs=/usr/lib/rpm/generic-hardened-ld ' --extra-cflags=' ' --enable-libopencore-amrnb --enable-libopencore-amrwb --enable-libvo-amrwbenc --enable-version3 --enable-bzlib --disable-crystalhd --enable-fontconfig --enable-frei0r --enable-gcrypt --enable-gnutls --enable-ladspa --enable-libaom --enable-libdav1d --enable-libass --enable-libbluray --enable-libcdio --enable-libdrm --enable-libjack --enable-libfreetype --enable-libfribidi --enable-libgsm --enable-libmp3lame --enable-openal --enable-opencl --enable-opengl --enable-libopenjpeg --enable-libopus --enable-libpulse --enable-librsvg --enable-libsrt --enable-libsoxr --enable-libspeex --enable-libssh --enable-libtheora --enable-libvorbis --enable-libv4l2 --enable-libvidstab --enable-libvpx --enable-libx264 --enable-libx265 --enable-libxvid --enable-libzimg --enable-libzvbi --enable-avfilter --enable-libmodplug --enable-postproc --enable-pthreads --disable-static --enable-shared --enable-gpl --disable-debug --disable-stripping --shlibdir=/usr/lib64
  libavutil      58. 29.100 / 58. 29.100
  libavcodec     60. 31.102 / 60. 31.102
  libavformat    60. 16.100 / 60. 16.100
  libavdevice    60.  3.100 / 60.  3.100
  libavfilter     9. 12.100 /  9. 12.100
  libswscale      7.  5.100 /  7.  5.100
  libswresample   4. 12.100 /  4. 12.100
  libpostproc    57.  3.100 / 57.  3.100
Input #0, lavfi, from 'testsrc=duration=10:size=1920x1080:rate=30':
  Duration: N/A, start: 0.000000, bitrate: N/A
  Stream #0:0: Video: wrapped_avframe, rgb24, 1920x1080 [SAR 1:1 DAR 16:9], 30 fps, 30 tbr, 30 tbn
Stream mapping:
  Stream #0:0 -> #0:0 (wrapped_avframe (native) -> wrapped_avframe (native))
Press [q] to stop, [?] for help
Output #0, null, to 'pipe:':
  Metadata:
    encoder         : Lavf60.16.100
  Stream #0:0: Video: wrapped_avframe, rgb24(progressive), 1920x1080 [SAR 1:1 DAR 16:9], q=2-31, 200 kb/s, 30 fps, 30 tbn
    Metadata:
      encoder         : Lavc60.31.102 wrapped_avframe
[out#0/null @ 0x2ae9b91540] video:141kB audio:0kB subtitle:0kB other streams:0kB global headers:0kB muxing overhead: unknown
frame=  300 fps=107 q=-0.0 Lsize=N/A time=00:00:09.96 bitrate=N/A speed=3.54x    
bench: utime=2.802s stime=0.052s rtime=2.813s
bench: maxrss=45740kB
````

| 参数                 | 作用                        | 解释                                                         |
| :------------------- | :-------------------------- | :----------------------------------------------------------- |
| **`-benchmark`**     | 开启基准测试模式            | 命令结束时，会输出 `bench:` 开头的性能数据 (`utime`, `stime`, `rtime`, `maxrss`)。 |
| **`-threads 0`**     | 自动使用所有CPU核心         | `0` 表示让FFmpeg根据你CPU的逻辑核心数自动创建最佳数量的处理线程。这是测试**最大并行处理能力**的典型设置。 |
| **`-f lavfi`**       | 使用Libavfilter虚拟输入设备 | 告诉FFmpeg从内置的滤镜图中生成视频数据，而不是从文件或真实设备读取。 |
| **`-i testsrc=...`** | 输入源：测试图案            | `testsrc` 是FFmpeg内置的一个生成彩色测试图案的滤镜。 - `duration=10`: 生成10秒长度的视频。 - `size=1920x1080`: 视频分辨率为1080p (Full HD)。 - `rate=30`: 帧率为30 fps。 **因此，总共需要处理 10秒 × 30帧/秒 = 300帧 无压缩的原始视频帧。** |
| **`-an`**            | 禁用音频处理                | 此命令没有音频输入源，此参数可省略，但加上表示明确不处理任何音频流。 |
| **`-f null -`**      | 输出到空设备                | `-f null` 指定“空输出格式”，它将所有收到的视频帧直接丢弃而不进行编码或写入硬盘。最后的 `-` 是输出文件名（此处指代标准输出，但被 `null` 覆盖）。这确保了测试**不受磁盘写入速度的影响**，纯粹考验CPU的计算能力。 |

测试结果说明

运行时间 (rtime):    2.816 秒   (实际耗时，越低越快)  

CPU时间 (utime):      2.783 秒  

处理速度 (fps):      107 fps    (每秒帧数，越高性能越强)  

加速比 (speed):      3.54x  

最大内存 (maxrss):   44780 KB   (44MB)

**fps=107**

- 每秒处理 **107 帧** 1080p 视频
- 这是 **CPU 视频处理能力的核心评分**

**rtime=2.816s**

- 跑完 10 秒的视频，只用了 2.8 秒实际时间
- 说明处理速度很快

**speed=3.54x**

- 实时播放速度的 **3.54 倍**
- 代表转码 / 解码性能

**maxrss=44780kB**

- 内存占用约 **44MB**，非常稳定




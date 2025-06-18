# 性能测试工具调研
- 环境：[qemu中的openEuler25.03-RISCV64](https://repo.openeuler.org/openEuler-25.03/virtual_machine_img/riscv64/)
- 所调研测试工具：libmicro

## 4 libmicro测试
> libmicro用于对系统调用和库调用进行性能测试，包含了一系列的基准测试程序，可用于测试各种系统调用和库函数的性能，例如文件操作、网络操作、内存管理、进程管理等。  
  
下载libmicro-0.4.0并解压编译：
```
cd /opt/
wget https://codeload.github.com/redhat-performance/libMicro/zip/0.4.0-rh
unzip 0.4.0-rh
cd libMicro-0.4.0-rh/
make
```
### 4.1 基准测试
编译完成后会在libMicro-0.4.0-rh目录下的bin目录创建一系列基准测试程序，bin目录下的程序是符号链接，实际会执行bin-riscv64下的可执行程序。  
测试特定系统调用或库函数可选择相应测试程序完成测试，所有基准测试均支持以下选项，特定测试选项可通过-h查看：
|参数|说明|　
|---|---|
|-1|单进程，将覆盖 -P > 1|
|-A|与时钟对齐|
|-B|批处理大小（默认 10）|
|-C|最小样本数（默认 0）|
|-D |持续时间（毫秒，默认 10 秒）|
|-E|ehco名字到stderr|
|-H|禁止显示头部|
|-I|指定每次操作的近似时间（纳秒）|
|-L|打印参数行|
|-M|报告平均值而非中位数|
|-N |测试名称|
|-P |进程数（默认 1）|
|-S|打印详细统计信息|
|-T|线程数（默认 1）|
|-V|打印 libMicro 版本并退出|
|-W|标记可能的基准测试问题|

运行libMicro-0.4.0-rh目录下的bench，该脚本会执行所有系统调用、库函数测试。
```
./bench
```
测试结果正常，以mmap测试结果为例，名为mmap_z8k的测试实际执行的是bin目录下的mmap程序，并设置了一些选项:
```
Running:            mmap_z8k# bin/mmap -E -C 200 -L -S -W -N mmap_z8k -l 8k -I 300 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_z8k       1   1     27.71730          199        0      333     8192  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     21.81316                21.81316
#                    max     47.71990                41.99026
#                   mean     28.78858                28.52415
#                 median     27.85261                27.71730
#                 stddev      5.35170                 4.93006
#         standard error      0.37654                 0.34948
#   99% confidence level      0.87584                 0.81290
#                   skew      0.92806                 0.67044
#               kurtosis      0.48083                -0.49380
#       time correlation     -0.00189                 0.00037
#
#           elasped time      3.69953
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          218
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2     21.00000 |*                                   21.84314
#                 11     22.00000 |*********                           22.63155
#                 36     23.00000 |********************************    23.52608
#                 23     24.00000 |********************                24.47353
#                  9     25.00000 |********                            25.46934
#                 10     26.00000 |********                            26.45829
#                 13     27.00000 |***********                         27.63428
#                 13     28.00000 |***********                         28.51682
#                 10     29.00000 |********                            29.62654
#                 12     30.00000 |**********                          30.33368
#                 11     31.00000 |*********                           31.54759
#                  6     32.00000 |*****                               32.59168
#                 12     33.00000 |**********                          33.47410
#                  8     34.00000 |*******                             34.36216
#                  5     35.00000 |****                                35.44497
#                  5     36.00000 |****                                36.40654
#                  3     37.00000 |**                                  37.60905
#
#                 10        > 95% |********                            39.85562
#
#        mean of 95%     27.92460
#          95th %ile     37.93655
 for      3.72583 seconds
```

### 4.2 总结
libmicro工具在openEuler25.03-RISCV64环境下可正常测试系统调用与库函数调用的性能。
## 在 openEuler RISC-V 镜像中执行 libmicro 测试

### 1. libmicro 介绍

- **libMicro（简称 libmicro）** 是一个**轻量级系统调用 & 库函数微基准测试工具**，最初由 Sun（Oracle）工程师开发，用来测 Solaris 系统调用性能，现在广泛用于 Linux（含 openEuler）做**内核 / GLibc 性能对比**。

  核心特点：

  - 测**系统调用**：open/close/read/write/stat/fork/exec 等时延
  - 测**库函数**：malloc/free、memcpy、sqrt、strlen 等时延
  - 极简、无依赖、可移植，适合 RISC-V/x86/ARM 对比
  - 输出：**单次调用耗时（纳秒 / 微秒）**，越小越好

### 2. 执行测试

安装依赖

````
$ dnf install -y gcc make git
````

下载源码编译

````
$ git clone https://github.com/redhat-performance/libMicro.git
$ cd libMicro
$ make
````

编译完成后，将 bench 文件中的 ARCH=\`arch -k\` 改为 ARCH=\`uname -m\`

````
$ sed -i.bak 's/ARCH=`arch -k`/ARCH=`uname -m`/' bench
````

执行测试

````
$ ./bench
!Libmicro_#:                            0.4.1
!Options:                  -E -C 200 -L -S -W
!Machine_name:          localhost.localdomain
!OS_name:                               Linux
!OS_release:   6.6.0-138.0.0.121.oe2403sp3.riscv64
!OS_build:                 #1 SMP Fri Feb  6 
!Processor:                           riscv64
!#CPUs:                                     8
!CPU_MHz:                                    
!CPU_NAME:                                   
!IP_address:                              ::1
!Run_by:                                 root
!Date:	                       04/28/26 09:37
!Compiler:                                gcc
!Compiler Ver.:                            12
!sizeof(long):                              8
!extra_CFLAGS:                         [none]
!TimerRes:                         1000 nsecs
# 
# Obligatory null system call: use very short time
# for default since SuSe implements this "syscall" in userland
# 
# bin/getpid -E -C 200 -L -S -W -N getpid -I 5 
             prc thr   usecs/call      samples   errors cnt/samp 
getpid         1   1      1.44063          177        0    20000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      1.38417                 1.38417
#                    max      3.15788                 1.59198
#                   mean      1.53754                 1.45203
#                 median      1.44743                 1.44063
#                 stddev      0.31364                 0.04870
#         standard error      0.02207                 0.00366
#   99% confidence level      0.05133                 0.00851
#                   skew      4.04627                 1.20003
#               kurtosis     16.12777                 1.02731
#       time correlation     -0.00140                 0.00005
#
#           elasped time      6.23400
#      number of samples          177
#     number of outliers           25
#      getnsecs overhead          412
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                168      1.00000 |********************************     1.44490
#
#                  9        > 95% |*                                    1.58523
#
#        mean of 95%      1.44490
#          95th %ile      1.57458
 
# bin/getenv -E -C 200 -L -S -W -N getenv -s 100 -I 100 
             prc thr   usecs/call      samples   errors cnt/samp 
getenv         1   1      0.95854          196        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.92757                 0.92757
#                    max      2.36142                 1.53045
#                   mean      1.07442                 1.05180
#                 median      0.96264                 0.95854
#                 stddev      0.21091                 0.16058
#         standard error      0.01484                 0.01147
#   99% confidence level      0.03452                 0.02668
#                   skew      2.36481                 1.32491
#               kurtosis      8.08142                 0.42388
#       time correlation     -0.00237                -0.00194
#
#           elasped time      0.23679
#      number of samples          196
#     number of outliers            6
#      getnsecs overhead          434
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                111      0.00000 |********************************     0.94459
#                 75      1.00000 |*********************                1.15595
#
#                 10        > 95% |**                                   1.46061
#
#        mean of 95%      1.02982
#          95th %ile      1.41064
# bin/getenv -E -C 200 -L -S -W -N getenvT2 -s 100 -I 100 -T 2 
             prc thr   usecs/call      samples   errors cnt/samp 
getenvT2       1   2      8.04890          199        0        1 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      4.15770                 4.15770
#                    max     46.88410                14.47450
#                   mean      8.64404                 8.37630
#                 median      8.04890                 8.04890
#                 stddev      3.48921                 2.07943
#         standard error      0.24550                 0.14741
#   99% confidence level      0.57103                 0.34287
#                   skew      6.68737                 0.71396
#               kurtosis     68.97912                -0.06089
#       time correlation     -0.01112                -0.00757
#
#           elasped time      0.08894
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          407
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1      4.00000 |*                                    4.15770
#                 10      5.00000 |*****                                5.77306
#                 59      6.00000 |********************************     6.42091
#                 28      7.00000 |***************                      7.50033
#                 28      8.00000 |***************                      8.50970
#                 29      9.00000 |***************                      9.46838
#                 21     10.00000 |***********                         10.50772
#                 13     11.00000 |*******                             11.49308
#
#                 10        > 95% |*****                               13.32250
#
#        mean of 95%      8.11459
#          95th %ile     12.04250
 
# bin/gettimeofday -E -C 200 -L -S -W -N gettimeofday 
             prc thr   usecs/call      samples   errors cnt/samp 
gettimeofday   1   1      0.39553          186        0    20000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.38188                 0.38188
#                    max      0.61208                 0.43019
#                   mean      0.40679                 0.39856
#                 median      0.39702                 0.39553
#                 stddev      0.03531                 0.01077
#         standard error      0.00248                 0.00079
#   99% confidence level      0.00578                 0.00184
#                   skew      4.02739                 0.91667
#               kurtosis     17.73136                 0.07925
#       time correlation     -0.00002                 0.00006
#
#           elasped time      1.66303
#      number of samples          186
#     number of outliers           16
#      getnsecs overhead          410
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                176      0.00000 |********************************     0.39708
#
#                 10        > 95% |*                                    0.42451
#
#        mean of 95%      0.39708
#          95th %ile      0.42118
 
# bin/log -E -C 200 -L -S -W -N log -I 20 
             prc thr   usecs/call      samples   errors cnt/samp 
log            1   1      0.22107          176        0     5000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.21124                 0.21124
#                    max      1.02543                 0.27186
#                   mean      0.25044                 0.22753
#                 median      0.22502                 0.22107
#                 stddev      0.08744                 0.01530
#         standard error      0.00615                 0.00115
#   99% confidence level      0.01431                 0.00268
#                   skew      5.76462                 1.25668
#               kurtosis     41.46666                 0.75414
#       time correlation     -0.00044                -0.00007
#
#           elasped time      0.27656
#      number of samples          176
#     number of outliers           26
#      getnsecs overhead          808
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                167      0.00000 |********************************     0.22533
#
#                  9        > 95% |*                                    0.26832
#
#        mean of 95%      0.22533
#          95th %ile      0.26362
# bin/exp -E -C 200 -L -S -W -N exp -I 20 
             prc thr   usecs/call      samples   errors cnt/samp 
exp            1   1      0.22185          200        0     5000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.20608                 0.20608
#                    max      1.04883                 0.48624
#                   mean      0.28597                 0.27962
#                 median      0.22221                 0.22185
#                 stddev      0.11889                 0.10007
#         standard error      0.00836                 0.00708
#   99% confidence level      0.01946                 0.01646
#                   skew      2.14970                 0.96113
#               kurtosis      7.93712                -0.98179
#       time correlation     -0.00131                -0.00135
#
#           elasped time      0.31251
#      number of samples          200
#     number of outliers            2
#      getnsecs overhead          778
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                190      0.00000 |********************************     0.26987
#
#                 10        > 95% |*                                    0.46481
#
#        mean of 95%      0.26987
#          95th %ile      0.45727
# bin/lrand48 -E -C 200 -L -S -W -N lrand48 
             prc thr   usecs/call      samples   errors cnt/samp 
lrand48        1   1      0.20626          179        0    10000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.16894                 0.18896
#                    max      0.51395                 0.24426
#                   mean      0.21830                 0.20837
#                 median      0.20767                 0.20626
#                 stddev      0.03923                 0.01258
#         standard error      0.00276                 0.00094
#   99% confidence level      0.00642                 0.00219
#                   skew      4.62931                 0.97858
#               kurtosis     28.75054                 0.26730
#       time correlation     -0.00012                -0.00004
#
#           elasped time      0.46334
#      number of samples          179
#     number of outliers           23
#      getnsecs overhead          454
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                170      0.00000 |********************************     0.20673
#
#                  9        > 95% |*                                    0.23932
#
#        mean of 95%      0.20673
#          95th %ile      0.23417
 
# bin/memset -E -C 200 -L -S -W -N memset_10 -s 10 -I 10 
             prc thr   usecs/call      samples   errors cnt/samp     size       alignment
memset_10      1   1      0.21904          196        0    10000       10          4k
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.20266                 0.20266
#                    max      0.33286                 0.24498
#                   mean      0.22085                 0.21918
#                 median      0.21935                 0.21904
#                 stddev      0.01430                 0.00939
#         standard error      0.00101                 0.00067
#   99% confidence level      0.00234                 0.00156
#                   skew      3.41483                 0.44349
#               kurtosis     20.80755                -0.33130
#       time correlation     -0.00005                -0.00001
#
#           elasped time      0.48110
#      number of samples          196
#     number of outliers            6
#      getnsecs overhead          425
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                186      0.00000 |********************************     0.21804
#
#                 10        > 95% |*                                    0.24048
#
#        mean of 95%      0.21804
#          95th %ile      0.23655
# bin/memset -E -C 200 -L -S -W -N memset_256 -s 256 -I 20 
             prc thr   usecs/call      samples   errors cnt/samp     size       alignment
memset_256     1   1      0.27586          194        0     5000      256          4k
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.25226                 0.25226
#                    max      1.27785                 0.31985
#                   mean      0.28650                 0.27961
#                 median      0.27648                 0.27586
#                 stddev      0.07215                 0.01366
#         standard error      0.00508                 0.00098
#   99% confidence level      0.01181                 0.00228
#                   skew     12.84899                 0.66972
#               kurtosis    173.45927                -0.02543
#       time correlation     -0.00015                 0.00001
#
#           elasped time      0.32046
#      number of samples          194
#     number of outliers            8
#      getnsecs overhead          774
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                184      0.00000 |********************************     0.27784
#
#                 10        > 95% |*                                    0.31217
#
#        mean of 95%      0.27784
#          95th %ile      0.30428
# bin/memset -E -C 200 -L -S -W -N memset_256_u -s 256 -a 1 -I 20 
             prc thr   usecs/call      samples   errors cnt/samp     size       alignment
memset_256_u   1   1      0.19171          200        0     5000      256           1
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.17988                 0.17988
#                    max      1.08551                 0.37270
#                   mean      0.22252                 0.21727
#                 median      0.19171                 0.19171
#                 stddev      0.08236                 0.05393
#         standard error      0.00579                 0.00381
#   99% confidence level      0.01348                 0.00887
#                   skew      6.15167                 1.72984
#               kurtosis     57.51167                 1.52085
#       time correlation     -0.00057                -0.00054
#
#           elasped time      0.24341
#      number of samples          200
#     number of outliers            2
#      getnsecs overhead          430
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                190      0.00000 |********************************     0.20968
#
#                 10        > 95% |*                                    0.36159
#
#        mean of 95%      0.20968
#          95th %ile      0.35391
# bin/memset -E -C 200 -L -S -W -N memset_1k -s 1k -I 100 
             prc thr   usecs/call      samples   errors cnt/samp     size       alignment
memset_1k      1   1      0.45062          175        0     1000     1024          4k
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.40659                 0.40659
#                    max      0.75040                 0.49338
#                   mean      0.47226                 0.45014
#                 median      0.45370                 0.45062
#                 stddev      0.06270                 0.01691
#         standard error      0.00441                 0.00128
#   99% confidence level      0.01026                 0.00297
#                   skew      2.40825                 0.13463
#               kurtosis      5.44257                -0.23588
#       time correlation     -0.00010                 0.00005
#
#           elasped time      0.12553
#      number of samples          175
#     number of outliers           27
#      getnsecs overhead          447
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                166      0.00000 |********************************     0.44816
#
#                  9        > 95% |*                                    0.48664
#
#        mean of 95%      0.44816
#          95th %ile      0.47955
# bin/memset -E -C 200 -L -S -W -N memset_4k -s 4k -I 250 
             prc thr   usecs/call      samples   errors cnt/samp     size       alignment
memset_4k      1   1      1.17558          186        0      400     4096          4k
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.97078                 0.97078
#                    max      2.35318                 1.41558
#                   mean      1.19649                 1.14930
#                 median      1.18070                 1.17558
#                 stddev      0.20231                 0.09391
#         standard error      0.01423                 0.00689
#   99% confidence level      0.03311                 0.01602
#                   skew      2.94990                -0.41579
#               kurtosis     12.00349                -0.61032
#       time correlation     -0.00162                -0.00112
#
#           elasped time      0.12295
#      number of samples          186
#     number of outliers           16
#      getnsecs overhead          809
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 23      0.00000 |****                                 0.98948
#                153      1.00000 |********************************     1.16320
#
#                 10        > 95% |**                                   1.30435
#
#        mean of 95%      1.14049
#          95th %ile      1.27030
# bin/memset -E -C 200 -L -S -W -N memset_4k_uc -s 4k -u -I 400 
             prc thr   usecs/call      samples   errors cnt/samp     size       alignment
memset_4k_uc   1   1      1.42213          173        0      250     4096          4k
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      1.37400                 1.37400
#                    max      2.88952                 1.55320
#                   mean      1.49967                 1.43987
#                 median      1.44978                 1.42213
#                 stddev      0.19511                 0.03785
#         standard error      0.01373                 0.00288
#   99% confidence level      0.03193                 0.00669
#                   skew      4.40851                 0.62779
#               kurtosis     24.41887                -0.49203
#       time correlation     -0.00056                -0.00011
#
#           elasped time      1.28034
#      number of samples          173
#     number of outliers           29
#      getnsecs overhead          564
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                164      1.00000 |********************************     1.43516
#
#                  9        > 95% |*                                    1.52567
#
#        mean of 95%      1.43516
#          95th %ile      1.51736
 
# bin/memset -E -C 200 -L -S -W -N memset_10k -s 10k -I 600 
             prc thr   usecs/call      samples   errors cnt/samp     size       alignment
memset_10k     1   1      2.41918          194        0      166    10240          4k
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.26106                 2.26106
#                    max      4.70812                 3.19621
#                   mean      2.60462                 2.55247
#                 median      2.42520                 2.41918
#                 stddev      0.38468                 0.27422
#         standard error      0.02707                 0.01969
#   99% confidence level      0.06296                 0.04579
#                   skew      2.12262                 0.61040
#               kurtosis      7.32795                -1.22294
#       time correlation     -0.00234                -0.00170
#
#           elasped time      0.10996
#      number of samples          194
#     number of outliers            8
#      getnsecs overhead          644
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                184      2.00000 |********************************     2.52442
#
#                 10        > 95% |*                                    3.06851
#
#        mean of 95%      2.52442
#          95th %ile      2.99593
# bin/memset -E -C 200 -L -S -W -N memset_1m -s 1m -I 200000 
             prc thr   usecs/call      samples   errors cnt/samp     size       alignment
memset_1m      1   1    268.06660          195        0        1  1048576          4k
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    249.76260               249.76260
#                    max    556.06660               292.05380
#                   mean    271.80230               268.34019
#                 median    268.45060               268.06660
#                 stddev     26.50309                 8.46004
#         standard error      1.86475                 0.60584
#   99% confidence level      4.33741                 1.40917
#                   skew      7.86570                 0.38292
#               kurtosis     73.96539                -0.21325
#       time correlation      0.00393                 0.01840
#
#           elasped time      0.61634
#      number of samples          195
#     number of outliers            7
#      getnsecs overhead          422
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    248.00000 |*                                  249.76260
#                  0    250.00000 |                                           -
#                  2    252.00000 |**                                 253.74340
#                 11    254.00000 |***************                    255.24100
#                 10    256.00000 |*************                      257.10468
#                 10    258.00000 |*************                      258.88132
#                 13    260.00000 |******************                 261.05811
#                 14    262.00000 |*******************                262.80031
#                 23    264.00000 |********************************   265.14931
#                 13    266.00000 |******************                 267.05245
#                 20    268.00000 |***************************        268.87172
#                 13    270.00000 |******************                 271.04605
#                 17    272.00000 |***********************            272.96072
#                 18    274.00000 |*************************          275.00704
#                  6    276.00000 |********                           277.23993
#                  7    278.00000 |*********                          278.88443
#                  3    280.00000 |****                               280.86660
#                  4    282.00000 |*****                              282.80580
#
#                 10        > 95% |*************                      287.75556
#
#        mean of 95%    267.29071
#          95th %ile    285.34660
# bin/memset -E -C 200 -L -S -W -N memset_10m -s 10m -I 2000000 
             prc thr   usecs/call      samples   errors cnt/samp     size       alignment
memset_10m     1   1   3934.12380          187        0        1 10485760          4k
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   3348.62620              3348.62620
#                    max   8003.01340              4869.72700
#                   mean   4130.86005              3943.11255
#                 median   3951.91580              3934.12380
#                 stddev    788.16164               317.62183
#         standard error     55.45486                23.22681
#   99% confidence level    128.98800                54.02556
#                   skew      3.07577                 0.48723
#               kurtosis     10.46518                -0.11294
#       time correlation      2.26566                -1.82525
#
#           elasped time      8.59495
#      number of samples          187
#     number of outliers           15
#      getnsecs overhead          842
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2   3320.00000 |****                              3352.72220
#                  0   3360.00000 |                                           -
#                  3   3400.00000 |*******                           3419.41873
#                  5   3440.00000 |************                      3463.45756
#                  6   3480.00000 |**************                    3492.96753
#                  5   3520.00000 |************                      3539.26940
#                  6   3560.00000 |**************                    3575.41660
#                  9   3600.00000 |**********************            3620.31900
#                  6   3640.00000 |**************                    3651.94353
#                  6   3680.00000 |**************                    3696.31687
#                  6   3720.00000 |**************                    3740.60487
#                 13   3760.00000 |********************************  3781.86288
#                  8   3800.00000 |*******************               3819.14780
#                  9   3840.00000 |**********************            3858.12593
#                  7   3880.00000 |*****************                 3899.29317
#                 12   3920.00000 |*****************************     3944.17607
#                  8   3960.00000 |*******************               3974.18780
#                 10   4000.00000 |************************          4015.26812
#                  5   4040.00000 |************                      4063.87484
#                  9   4080.00000 |**********************            4096.58140
#                 12   4120.00000 |*****************************     4134.28807
#                  7   4160.00000 |*****************                 4179.83260
#                  5   4200.00000 |************                      4223.31676
#                  1   4240.00000 |**                                4252.81820
#                  4   4280.00000 |*********                         4309.94460
#                  3   4320.00000 |*******                           4339.05607
#                  4   4360.00000 |*********                         4390.05340
#                  2   4400.00000 |****                              4433.51580
#                  1   4440.00000 |**                                4457.41340
#                  3   4480.00000 |*******                           4505.35367
#
#                 10        > 95% |************************          4676.05020
#
#        mean of 95%   3901.70364
#          95th %ile   4532.60060
# bin/memset -E -C 200 -L -S -W -N memsetP2_10m -s 10m -P 2 -I 2000000 
             prc thr   usecs/call      samples   errors cnt/samp     size       alignment
memsetP2_10m   2   1   4263.56170          202        0        1 10485760          4k
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   3709.44970              3709.44970
#                    max   9477.66730              9477.66730
#                   mean   5075.53097              5075.53097
#                 median   4263.56170              4263.56170
#                 stddev   1549.46845              1549.46845
#         standard error    109.02022               109.02022
#   99% confidence level    253.58103               253.58103
#                   skew      1.22616                 1.22616
#               kurtosis     -0.12201                -0.12201
#       time correlation    -17.29483               -17.29483
#
#           elasped time     10.68020
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          415
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  6   3600.00000 |***                               3751.47210
#                 34   3800.00000 |**********************            3908.94674
#                 49   4000.00000 |********************************  4096.42975
#                 22   4200.00000 |**************                    4265.79588
#                 14   4400.00000 |*********                         4482.66296
#                 10   4600.00000 |******                            4686.21002
#                  6   4800.00000 |***                               4873.15743
#                 12   5000.00000 |*******                           5062.86197
#                  0   5200.00000 |                                           -
#                  2   5400.00000 |*                                 5508.60490
#                  0   5600.00000 |                                           -
#                  0   5800.00000 |                                           -
#                  2   6000.00000 |*                                 6076.60490
#                  1   6200.00000 |*                                 6290.74890
#                  0   6400.00000 |                                           -
#                  1   6600.00000 |*                                 6602.27530
#                  1   6800.00000 |*                                 6944.95690
#                  2   7000.00000 |*                                 7157.96170
#                  1   7200.00000 |*                                 7264.06090
#                  3   7400.00000 |*                                 7529.49023
#                 10   7600.00000 |******                            7694.39690
#                 11   7800.00000 |*******                           7904.00272
#                  4   8000.00000 |**                                8012.03530
#
#                 11        > 95% |*******                           8413.27283
#
#        mean of 95%   4883.30500
#          95th %ile   8034.64650
 
# bin/memrand -E -C 200 -L -S -W -N memrand -s 128m -B 10000 
             prc thr   usecs/call      samples   errors cnt/samp     size
memrand        1   1      0.09485          190        0    10000 134217728 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.09165                 0.09165
#                    max      0.20705                 0.10686
#                   mean      0.09796                 0.09636
#                 median      0.09495                 0.09485
#                 stddev      0.00969                 0.00361
#         standard error      0.00068                 0.00026
#   99% confidence level      0.00159                 0.00061
#                   skew      7.58791                 1.39362
#               kurtosis     78.11291                 0.62569
#       time correlation     -0.00004                -0.00000
#
#           elasped time      2.63221
#      number of samples          190
#     number of outliers           12
#      getnsecs overhead          498
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                180      0.00000 |********************************     0.09584
#
#                 10        > 95% |*                                    0.10568
#
#        mean of 95%      0.09584
#          95th %ile      0.10407
#
# benchmark cachetocache not compiled/supported on this platform
#
 
# bin/isatty -E -C 200 -L -S -W -N isatty_yes 
             prc thr   usecs/call      samples   errors cnt/samp 
isatty_yes     1   1      6.80056          175        0    20000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      6.39046                 6.39046
#                    max     13.85075                 7.52796
#                   mean      7.37699                 6.83931
#                 median      6.86291                 6.80056
#                 stddev      1.64521                 0.24818
#         standard error      0.11576                 0.01876
#   99% confidence level      0.26925                 0.04364
#                   skew      2.99835                 0.62698
#               kurtosis      7.91712                -0.08167
#       time correlation     -0.00156                 0.00034
#
#           elasped time     29.83543
#      number of samples          175
#     number of outliers           27
#      getnsecs overhead          769
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                134      6.00000 |********************************     6.73084
#                 32      7.00000 |*******                              7.12841
#
#                  9        > 95% |**                                   7.42626
#
#        mean of 95%      6.80748
#          95th %ile      7.29627
# bin/isatty -E -C 200 -L -S -W -N isatty_no -f /tmp/libmicro.2378/ifile 
             prc thr   usecs/call      samples   errors cnt/samp 
isatty_no      1   1      3.17382          202        0    20000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.99596                 2.99596
#                    max      6.45607                 6.45607
#                   mean      3.61767                 3.61767
#                 median      3.17382                 3.17382
#                 stddev      1.04964                 1.04964
#         standard error      0.07385                 0.07385
#   99% confidence level      0.17178                 0.17178
#                   skew      1.95524                 1.95524
#               kurtosis      2.02207                 2.02207
#       time correlation      0.01005                 0.01005
#
#           elasped time     14.64572
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          618
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2      2.00000 |*                                    2.99637
#                170      3.00000 |********************************     3.19278
#                  2      4.00000 |*                                    4.51467
#                  0      5.00000 |                                           -
#                 17      6.00000 |***                                  6.08873
#
#                 11        > 95% |**                                   6.31506
#
#        mean of 95%      3.46232
#          95th %ile      6.22547
 
# bin/malloc -E -C 200 -L -S -W -N malloc_10 -s 10 -g 10 -I 50 
             prc thr   usecs/call      samples   errors cnt/samp   glob  sizes
malloc_10      1   1      0.60481          165        0     2000     10 10 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.57902                 0.57902
#                    max      1.50651                 0.64326
#                   mean      0.67364                 0.60694
#                 median      0.60755                 0.60481
#                 stddev      0.18385                 0.01249
#         standard error      0.01294                 0.00097
#   99% confidence level      0.03009                 0.00226
#                   skew      2.75659                 0.77248
#               kurtosis      6.22094                 0.18592
#       time correlation     -0.00142                 0.00003
#
#           elasped time      2.74803
#      number of samples          165
#     number of outliers           37
#      getnsecs overhead          811
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                156      0.00000 |********************************     0.60522
#
#                  9        > 95% |*                                    0.63668
#
#        mean of 95%      0.60522
#          95th %ile      0.63287
# bin/malloc -E -C 200 -L -S -W -N malloc_100 -s 100 -g 10 -I 50 
             prc thr   usecs/call      samples   errors cnt/samp   glob  sizes
malloc_100     1   1      0.32779          167        0     2000     10 100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.31459                 0.31459
#                    max      0.66568                 0.35134
#                   mean      0.34939                 0.32868
#                 median      0.32963                 0.32779
#                 stddev      0.06139                 0.00802
#         standard error      0.00432                 0.00062
#   99% confidence level      0.01005                 0.00144
#                   skew      3.48100                 0.62188
#               kurtosis     12.52715                -0.24150
#       time correlation     -0.00007                 0.00007
#
#           elasped time      1.43065
#      number of samples          167
#     number of outliers           35
#      getnsecs overhead          437
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                158      0.00000 |********************************     0.32766
#
#                  9        > 95% |*                                    0.34666
#
#        mean of 95%      0.32766
#          95th %ile      0.34398
# bin/malloc -E -C 200 -L -S -W -N malloc_1k -s 1k -g 10 -I 50 
             prc thr   usecs/call      samples   errors cnt/samp   glob  sizes
malloc_1k      1   1      0.47771          201        0     2000     10 1024 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.45682                 0.45682
#                    max      1.19306                 0.98121
#                   mean      0.58169                 0.57865
#                 median      0.47821                 0.47771
#                 stddev      0.18519                 0.18052
#         standard error      0.01303                 0.01273
#   99% confidence level      0.03031                 0.02962
#                   skew      1.30690                 1.27497
#               kurtosis      0.00213                -0.22890
#       time correlation     -0.00201                -0.00198
#
#           elasped time      2.37711
#      number of samples          201
#     number of outliers            1
#      getnsecs overhead          805
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                190      0.00000 |********************************     0.55748
#
#                 11        > 95% |*                                    0.94428
#
#        mean of 95%      0.55748
#          95th %ile      0.93011
# bin/malloc -E -C 200 -L -S -W -N malloc_10k -s 10k -g 10 -I 50 
             prc thr   usecs/call      samples   errors cnt/samp   glob  sizes
malloc_10k     1   1      0.81111          202        0     2000     10 10240 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.75671                 0.75671
#                    max      1.80400                 1.80400
#                   mean      0.95531                 0.95531
#                 median      0.81111                 0.81111
#                 stddev      0.29062                 0.29062
#         standard error      0.02045                 0.02045
#   99% confidence level      0.04756                 0.04756
#                   skew      1.59132                 1.59132
#               kurtosis      0.79210                 0.79210
#       time correlation     -0.00309                -0.00309
#
#           elasped time      3.88548
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          804
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                159      0.00000 |********************************     0.81472
#                 32      1.00000 |******                               1.42393
#
#                 11        > 95% |**                                   1.62421
#
#        mean of 95%      0.91679
#          95th %ile      1.56786
# bin/malloc -E -C 200 -L -S -W -N malloc_100k -s 100k -g 10 -I 2000 
             prc thr   usecs/call      samples   errors cnt/samp   glob  sizes
malloc_100k    1   1     70.89241          191        0       50     10 102400 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     63.22009                63.22009
#                    max    131.69855                89.85228
#                   mean     74.21698                72.34942
#                 median     71.09618                70.89241
#                 stddev     10.01189                 5.91609
#         standard error      0.70443                 0.42807
#   99% confidence level      1.63851                 0.99570
#                   skew      2.53247                 1.07525
#               kurtosis      8.19579                 0.48118
#       time correlation     -0.01916                -0.00898
#
#           elasped time      7.53436
#      number of samples          191
#     number of outliers           11
#      getnsecs overhead          836
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2     63.00000 |**                                  63.52524
#                  5     64.00000 |*******                             64.43271
#                  5     65.00000 |*******                             65.22948
#                 15     66.00000 |*********************               66.45938
#                 17     67.00000 |************************            67.50764
#                 22     68.00000 |********************************    68.53705
#                 17     69.00000 |************************            69.58539
#                 16     70.00000 |***********************             70.54710
#                 16     71.00000 |***********************             71.45692
#                 11     72.00000 |****************                    72.51196
#                 10     73.00000 |**************                      73.41155
#                 13     74.00000 |******************                  74.55277
#                  3     75.00000 |****                                75.13689
#                  2     76.00000 |**                                  76.46834
#                  2     77.00000 |**                                  77.47161
#                  4     78.00000 |*****                               78.47039
#                  5     79.00000 |*******                             79.38393
#                  3     80.00000 |****                                80.80114
#                  5     81.00000 |*******                             81.43439
#                  3     82.00000 |****                                82.46702
#                  2     83.00000 |**                                  83.54034
#                  3     84.00000 |****                                84.44693
#
#                 10        > 95% |**************                      87.36027
#
#        mean of 95%     71.52009
#          95th %ile     85.10860
 
# bin/malloc -E -C 200 -L -S -W -N mallocT2_10 -s 10 -g 10 -T 2 -I 200 
             prc thr   usecs/call      samples   errors cnt/samp   glob  sizes
mallocT2_10    1   2      0.75890          179        0      500     10 10 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.55891                 0.55891
#                    max      1.74690                 0.96032
#                   mean      0.79202                 0.73425
#                 median      0.76668                 0.75890
#                 stddev      0.18244                 0.07890
#         standard error      0.01284                 0.00590
#   99% confidence level      0.02986                 0.01372
#                   skew      1.93970                -0.74441
#               kurtosis      4.61627                 0.14569
#       time correlation     -0.00096                 0.00033
#
#           elasped time      0.89873
#      number of samples          179
#     number of outliers           23
#      getnsecs overhead          458
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                170      0.00000 |********************************     0.72692
#
#                  9        > 95% |*                                    0.87260
#
#        mean of 95%      0.72692
#          95th %ile      0.82469
# bin/malloc -E -C 200 -L -S -W -N mallocT2_100 -s 100 -g 10 -T 2 -I 200 
             prc thr   usecs/call      samples   errors cnt/samp   glob  sizes
mallocT2_100   1   2      0.99728          201        0      500     10 100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.48630                 0.48630
#                    max      1.76850                 1.21191
#                   mean      0.82984                 0.82517
#                 median      0.99774                 0.99728
#                 stddev      0.24386                 0.23524
#         standard error      0.01716                 0.01659
#   99% confidence level      0.03991                 0.03859
#                   skew      0.02530                -0.22849
#               kurtosis     -0.82345                -1.75567
#       time correlation     -0.00238                -0.00243
#
#           elasped time      0.92617
#      number of samples          201
#     number of outliers            1
#      getnsecs overhead          492
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                102      0.00000 |********************************     0.61398
#                 88      1.00000 |***************************          1.03415
#
#                 11        > 95% |***                                  1.11161
#
#        mean of 95%      0.80858
#          95th %ile      1.07792
# bin/malloc -E -C 200 -L -S -W -N mallocT2_1k -s 1k -g 10 -T 2 -I 200 
             prc thr   usecs/call      samples   errors cnt/samp   glob  sizes
mallocT2_1k    1   2      1.37831          178        0      500     10 1024 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.67073                 1.29670
#                    max      2.36028                 1.48814
#                   mean      1.32417                 1.37916
#                 median      1.37391                 1.37831
#                 stddev      0.22262                 0.03865
#         standard error      0.01566                 0.00290
#   99% confidence level      0.03643                 0.00674
#                   skew     -0.95721                 0.18968
#               kurtosis      6.28906                -0.44534
#       time correlation      0.00141                -0.00016
#
#           elasped time      1.43556
#      number of samples          178
#     number of outliers           24
#      getnsecs overhead          459
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                169      1.00000 |********************************     1.37486
#
#                  9        > 95% |*                                    1.45995
#
#        mean of 95%      1.37486
#          95th %ile      1.44129
# bin/malloc -E -C 200 -L -S -W -N mallocT2_10k -s 10k -g 10 -T 2 -I 200 
             prc thr   usecs/call      samples   errors cnt/samp   glob  sizes
mallocT2_10k   1   2      2.18300          177        0      500     10 10240 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      1.09623                 2.08081
#                    max      3.20224                 2.33686
#                   mean      2.09479                 2.18628
#                 median      2.17880                 2.18300
#                 stddev      0.34768                 0.05233
#         standard error      0.02446                 0.00393
#   99% confidence level      0.05690                 0.00915
#                   skew     -1.59355                 0.54631
#               kurtosis      4.18120                 0.06552
#       time correlation     -0.00263                 0.00048
#
#           elasped time      2.22697
#      number of samples          177
#     number of outliers           25
#      getnsecs overhead          826
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                168      2.00000 |********************************     2.17957
#
#                  9        > 95% |*                                    2.31151
#
#        mean of 95%      2.17957
#          95th %ile      2.29001
# bin/malloc -E -C 200 -L -S -W -N mallocT2_100k -s 100k -g 10 -T 2 -I 10000 
             prc thr   usecs/call      samples   errors cnt/samp   glob  sizes
mallocT2_100k   1   2    194.24191          202        0       10     10 102400 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    117.62111               117.62111
#                    max    283.44255               283.44255
#                   mean    184.54737               184.54737
#                 median    194.24191               194.24191
#                 stddev     36.42708                36.42708
#         standard error      2.56300                 2.56300
#   99% confidence level      5.96154                 5.96154
#                   skew      0.03482                 0.03482
#               kurtosis     -0.64000                -0.64000
#       time correlation      0.13273                 0.13273
#
#           elasped time      3.88717
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          833
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    116.00000 |*                                  117.62111
#                  2    120.00000 |***                                120.11583
#                  4    124.00000 |******                             125.79967
#                 10    128.00000 |****************                   130.28210
#                 10    132.00000 |****************                   133.99461
#                  8    136.00000 |*************                      138.28799
#                  6    140.00000 |**********                         142.21631
#                  8    144.00000 |*************                      145.57663
#                 10    148.00000 |****************                   150.18021
#                  1    152.00000 |*                                  153.19231
#                  2    156.00000 |***                                157.60063
#                  2    160.00000 |***                                163.59103
#                  1    164.00000 |*                                  165.23199
#                  5    168.00000 |********                           170.20351
#                  5    172.00000 |********                           173.99385
#                  8    176.00000 |*************                      177.37215
#                  8    180.00000 |*************                      181.54111
#                  5    184.00000 |********                           186.27314
#                  1    188.00000 |*                                  188.24127
#                  8    192.00000 |*************                      194.10335
#                  6    196.00000 |**********                         198.22228
#                 16    200.00000 |**************************         202.06671
#                 19    204.00000 |********************************   206.01939
#                 19    208.00000 |********************************   210.21550
#                 10    212.00000 |****************                   214.35967
#                  6    216.00000 |**********                         217.57162
#                  2    220.00000 |***                                221.55199
#                  3    224.00000 |*****                              224.74772
#                  0    228.00000 |                                           -
#                  4    232.00000 |******                             234.41663
#                  1    236.00000 |*                                  238.49151
#
#                 11        > 95% |******************                 259.07298
#
#        mean of 95%    180.25532
#          95th %ile    238.61183
 
# bin/close -E -C 200 -L -S -W -N close_bad -B 32 -b 
             prc thr   usecs/call      samples   errors cnt/samp 
close_bad      1   1      3.19862          192        0       32 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.78262                 2.78262
#                    max     21.65462                 4.00662
#                   mean      3.51241                 3.27913
#                 median      3.22262                 3.19862
#                 stddev      1.54893                 0.24340
#         standard error      0.10898                 0.01757
#   99% confidence level      0.25349                 0.04086
#                   skew      8.99297                 1.27479
#               kurtosis     94.50889                 1.07380
#       time correlation     -0.00312                -0.00048
#
#           elasped time      0.05363
#      number of samples          192
#     number of outliers           10
#      getnsecs overhead          812
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  8      2.00000 |*                                    2.94463
#                174      3.00000 |********************************     3.25743
#
#                 10        > 95% |*                                    3.92422
#
#        mean of 95%      3.24368
#          95th %ile      3.85462
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 1X to avoid.
# bin/close -E -C 200 -L -S -W -N close_tmp -B 32 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp 
close_tmp      1   1     10.75803          195        0       32 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      8.26203                 8.26203
#                    max     79.97403                24.63003
#                   mean     14.30453                12.71897
#                 median     11.94203                10.75803
#                 stddev      9.67113                 4.30620
#         standard error      0.68046                 0.30837
#   99% confidence level      1.58275                 0.71728
#                   skew      4.07932                 0.60126
#               kurtosis     20.41230                -0.74492
#       time correlation      0.03589                 0.04182
#
#           elasped time      0.86911
#      number of samples          195
#     number of outliers            7
#      getnsecs overhead          831
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 62      8.00000 |********************************     8.58371
#                 33      9.00000 |*****************                    9.30882
#                  3     10.00000 |*                                   10.35003
#                  4     11.00000 |**                                  11.55403
#                  2     12.00000 |*                                   12.09803
#                  2     13.00000 |*                                   13.52203
#                 11     14.00000 |*****                               14.49330
#                 23     15.00000 |***********                         15.54760
#                 28     16.00000 |**************                      16.44146
#                 11     17.00000 |*****                               17.41330
#                  1     18.00000 |*                                   18.10203
#                  3     19.00000 |*                                   19.57936
#                  2     20.00000 |*                                   20.72603
#
#                 10        > 95% |*****                               22.50923
#
#        mean of 95%     12.18977
#          95th %ile     20.88603
# bin/close -E -C 200 -L -S -W -N close_usr -B 32 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp 
close_usr      1   1     17.60706          167        0       32 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     15.25506                15.25506
#                    max     90.69506                21.12706
#                   mean     21.61558                17.68591
#                 median     18.00706                17.60706
#                 stddev     11.11879                 1.23287
#         standard error      0.78232                 0.09540
#   99% confidence level      1.81967                 0.22191
#                   skew      3.31022                 0.37526
#               kurtosis     11.87506                -0.46747
#       time correlation     -0.00555                 0.01307
#
#           elasped time      1.25749
#      number of samples          167
#     number of outliers           35
#      getnsecs overhead          798
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 11     15.00000 |*******                             15.66888
#                 45     16.00000 |********************************    16.54982
#                 44     17.00000 |*******************************     17.46924
#                 41     18.00000 |*****************************       18.40823
#                 17     19.00000 |************                        19.42542
#
#                  9        > 95% |******                              20.31462
#
#        mean of 95%     17.53618
#          95th %ile     19.94306
# bin/close -E -C 200 -L -S -W -N close_zero -B 32 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp 
close_zero     1   1     18.10303          187        0       32 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      8.63103                 8.63103
#                    max     63.19903                28.69503
#                   mean     19.95539                17.41738
#                 median     18.38303                18.10303
#                 stddev     10.26896                 4.44926
#         standard error      0.72252                 0.32536
#   99% confidence level      1.68058                 0.75679
#                   skew      2.49692                -0.46047
#               kurtosis      6.76292                 0.32109
#       time correlation     -0.02965                -0.01991
#
#           elasped time      1.11921
#      number of samples          187
#     number of outliers           15
#      getnsecs overhead          799
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 13      8.00000 |********                             8.83534
#                 17      9.00000 |**********                           9.42068
#                  3     10.00000 |*                                   10.19636
#                  1     11.00000 |*                                   11.13503
#                  0     12.00000 |                                           -
#                  0     13.00000 |                                           -
#                  0     14.00000 |                                           -
#                  0     15.00000 |                                           -
#                 10     16.00000 |******                              16.67423
#                 40     17.00000 |*************************           17.60823
#                 50     18.00000 |********************************    18.50031
#                 29     19.00000 |******************                  19.46827
#                  4     20.00000 |**                                  20.24903
#                  3     21.00000 |*                                   21.64170
#                  1     22.00000 |*                                   22.85503
#                  1     23.00000 |*                                   23.00703
#                  5     24.00000 |***                                 24.76543
#
#                 10        > 95% |******                              26.40383
#
#        mean of 95%     16.90968
#          95th %ile     25.07103
 
# bin/memcpy -E -C 200 -L -S -W -N memcpy_10 -s 10 -I 10 
             prc thr   usecs/call      samples   errors cnt/samp     size
memcpy_10      1   1      0.21342          199        0    10000       10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.19522                 0.19522
#                    max      0.28613                 0.24112
#                   mean      0.21618                 0.21530
#                 median      0.21352                 0.21342
#                 stddev      0.01148                 0.00893
#         standard error      0.00081                 0.00063
#   99% confidence level      0.00188                 0.00147
#                   skew      2.27008                 0.56472
#               kurtosis      9.82436                -0.24684
#       time correlation     -0.00004                -0.00003
#
#           elasped time      0.46918
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          830
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                189      0.00000 |********************************     0.21424
#
#                 10        > 95% |*                                    0.23539
#
#        mean of 95%      0.21424
#          95th %ile      0.23132
# bin/memcpy -E -C 200 -L -S -W -N memcpy_1k -s 1k -I 50 
             prc thr   usecs/call      samples   errors cnt/samp     size
memcpy_1k      1   1      0.88959          198        0     2000     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.83161                 0.83161
#                    max      1.32505                 1.02617
#                   mean      0.90512                 0.89990
#                 median      0.89202                 0.88959
#                 stddev      0.05842                 0.04376
#         standard error      0.00411                 0.00311
#   99% confidence level      0.00956                 0.00723
#                   skew      2.60384                 0.60506
#               kurtosis     13.35521                -0.46678
#       time correlation     -0.00006                -0.00003
#
#           elasped time      0.39788
#      number of samples          198
#     number of outliers            4
#      getnsecs overhead          782
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                188      0.00000 |********************************     0.89468
#
#                 10        > 95% |*                                    0.99807
#
#        mean of 95%      0.89468
#          95th %ile      0.98265
# bin/memcpy -E -C 200 -L -S -W -N memcpy_10k -s 10k -I 800 
             prc thr   usecs/call      samples   errors cnt/samp     size
memcpy_10k     1   1      5.72351          158        0      125    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      5.36306                 5.36306
#                    max      9.81951                 6.13106
#                   mean      6.03472                 5.71842
#                 median      5.77266                 5.72351
#                 stddev      0.69803                 0.15102
#         standard error      0.04911                 0.01201
#   99% confidence level      0.11424                 0.02795
#                   skew      2.22886                -0.02648
#               kurtosis      5.56680                -0.35464
#       time correlation     -0.00087                -0.00004
#
#           elasped time      0.18367
#      number of samples          158
#     number of outliers           44
#      getnsecs overhead          593
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                150      5.00000 |********************************     5.70257
#
#                  8        > 95% |*                                    6.01561
#
#        mean of 95%      5.70257
#          95th %ile      5.97132
# bin/memcpy -E -C 200 -L -S -W -N memcpy_1m -s 1m -I 500000 
             prc thr   usecs/call      samples   errors cnt/samp     size
memcpy_1m      1   1    915.14300          195        0        1  1048576
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    848.07100               848.07100
#                    max  15352.00700              1083.07900
#                   mean   1012.93373               934.58325
#                 median    916.16700               915.14300
#                 stddev   1016.12427                54.11533
#         standard error     71.49425                 3.87528
#   99% confidence level    166.29564                 9.01390
#                   skew     13.91062                 0.95227
#               kurtosis    193.31160                -0.14469
#       time correlation     -2.30771                -0.06744
#
#           elasped time      0.23963
#      number of samples          195
#     number of outliers            7
#      getnsecs overhead          825
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    847.00000 |**                                 850.24700
#                  3    854.00000 |****                               858.22567
#                  1    861.00000 |*                                  863.17500
#                  3    868.00000 |****                               871.36700
#                  7    875.00000 |**********                         878.60814
#                 16    882.00000 |***********************            885.19100
#                 15    889.00000 |*********************              892.56380
#                 18    896.00000 |**************************         900.11011
#                 22    903.00000 |********************************   906.85791
#                 15    910.00000 |*********************              912.99260
#                 11    917.00000 |****************                   919.09936
#                  9    924.00000 |*************                      927.85767
#                 11    931.00000 |****************                   933.87755
#                  4    938.00000 |*****                              941.19100
#                  4    945.00000 |*****                              947.20700
#                  2    952.00000 |**                                 955.07900
#                  4    959.00000 |*****                              962.18300
#                  2    966.00000 |**                                 970.05500
#                  4    973.00000 |*****                              976.64700
#                  2    980.00000 |**                                 985.67100
#                  1    987.00000 |*                                  991.17500
#                  4    994.00000 |*****                              999.75100
#                  5   1001.00000 |*******                           1003.41180
#                  5   1008.00000 |*******                           1010.52860
#                  5   1015.00000 |*******                           1017.74780
#                  3   1022.00000 |****                              1024.88167
#                  1   1029.00000 |*                                 1031.11100
#                  6   1036.00000 |********                          1038.02300
#
#                 10        > 95% |**************                    1059.52700
#
#        mean of 95%    927.82953
#          95th %ile   1044.16700
# bin/memcpy -E -C 200 -L -S -W -N memcpy_10m -s 10m -I 5000000 
             prc thr   usecs/call      samples   errors cnt/samp     size
memcpy_10m     1   1  11047.10500          196        0        1 10485760
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   7166.40100              7166.40100
#                    max  71942.08100             20354.24100
#                   mean  12526.80021             11943.22908
#                 median  11127.23300             11047.10500
#                 stddev   5529.96974              3154.27671
#         standard error    389.08731               225.30548
#   99% confidence level    905.01709               524.06055
#                   skew      6.40270                 0.90798
#               kurtosis     63.63365                -0.04531
#       time correlation    -22.92143                -9.69629
#
#           elasped time      2.56324
#      number of samples          196
#     number of outliers            6
#      getnsecs overhead          831
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1   6800.00000 |*                                 7166.40100
#                  6   7200.00000 |*********                         7378.02767
#                  3   7600.00000 |****                              7875.52100
#                  9   8000.00000 |**************                    8171.25789
#                  4   8400.00000 |******                            8594.88100
#                  6   8800.00000 |*********                         8998.37967
#                 13   9200.00000 |********************              9429.95300
#                 10   9600.00000 |****************                  9756.55780
#                 20  10000.00000 |******************************** 10214.87460
#                 14  10400.00000 |**********************           10630.17243
#                 17  10800.00000 |***************************      10972.35300
#                 14  11200.00000 |**********************           11334.00786
#                 10  11600.00000 |****************                 11840.90980
#                  5  12000.00000 |********                         12086.51620
#                  8  12400.00000 |************                     12597.53700
#                  6  12800.00000 |*********                        12952.08633
#                  4  13200.00000 |******                           13388.03300
#                  3  13600.00000 |****                             13824.79033
#                  4  14000.00000 |******                           14222.20900
#                  3  14400.00000 |****                             14515.90500
#                  3  14800.00000 |****                             14910.82767
#                  2  15200.00000 |***                              15348.67300
#                  0  15600.00000 |                                           -
#                  2  16000.00000 |***                              16165.69700
#                  3  16400.00000 |****                             16612.45967
#                  4  16800.00000 |******                           17038.97700
#                  2  17200.00000 |***                              17453.63300
#                  5  17600.00000 |********                         17830.59300
#                  3  18000.00000 |****                             18187.79833
#                  2  18400.00000 |***                              18418.11300
#
#                 10        > 95% |****************                 19140.77540
#
#        mean of 95%  11556.26423
#          95th %ile  18433.21700
 
# bin/strcpy -E -C 200 -L -S -W -N strcpy_10 -s 10 -I 5 
             prc thr   usecs/call      samples   errors cnt/samp     size
strcpy_10      1   1      0.15960          198        0    20000       10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.14876                 0.14876
#                    max      0.35167                 0.30470
#                   mean      0.17901                 0.17597
#                 median      0.15967                 0.15960
#                 stddev      0.04842                 0.04379
#         standard error      0.00341                 0.00311
#   99% confidence level      0.00792                 0.00724
#                   skew      2.07168                 2.21672
#               kurtosis      2.60649                 3.12486
#       time correlation     -0.00046                -0.00042
#
#           elasped time      0.74881
#      number of samples          198
#     number of outliers            4
#      getnsecs overhead          776
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                188      0.00000 |********************************     0.16949
#
#                 10        > 95% |*                                    0.29768
#
#        mean of 95%      0.16949
#          95th %ile      0.29326
# bin/strcpy -E -C 200 -L -S -W -N strcpy_1k -s 1k -I 100 
             prc thr   usecs/call      samples   errors cnt/samp     size
strcpy_1k      1   1      0.66437          165        0     1000     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.64235                 0.64235
#                    max      1.23448                 0.72555
#                   mean      0.70189                 0.66916
#                 median      0.67051                 0.66437
#                 stddev      0.08371                 0.01905
#         standard error      0.00589                 0.00148
#   99% confidence level      0.01370                 0.00345
#                   skew      2.82695                 1.03217
#               kurtosis      9.96811                 0.57549
#       time correlation     -0.00020                -0.00001
#
#           elasped time      0.15941
#      number of samples          165
#     number of outliers           37
#      getnsecs overhead          466
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                156      0.00000 |********************************     0.66637
#
#                  9        > 95% |*                                    0.71753
#
#        mean of 95%      0.66637
#          95th %ile      0.71249
 
# bin/strlen -E -C 200 -L -S -W -N strlen_10 -s 10 -I 5 
             prc thr   usecs/call      samples   errors cnt/samp     size
strlen_10      1   1      0.29720          201        0    20000       10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.13980                 0.13980
#                    max      0.55241                 0.35021
#                   mean      0.26839                 0.26697
#                 median      0.29761                 0.29720
#                 stddev      0.06921                 0.06640
#         standard error      0.00487                 0.00468
#   99% confidence level      0.01133                 0.01089
#                   skew     -0.71596                -1.14069
#               kurtosis      0.59305                -0.50257
#       time correlation     -0.00045                -0.00048
#
#           elasped time      1.11657
#      number of samples          201
#     number of outliers            1
#      getnsecs overhead          766
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                190      0.00000 |********************************     0.26302
#
#                 11        > 95% |*                                    0.33519
#
#        mean of 95%      0.26302
#          95th %ile      0.31971
# bin/strlen -E -C 200 -L -S -W -N strlen_1k -s 1k -I 100 
             prc thr   usecs/call      samples   errors cnt/samp     size
strlen_1k      1   1      0.75656          166        0     1000     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.70254                 0.70254
#                    max      1.14670                 0.82363
#                   mean      0.78494                 0.75533
#                 median      0.76168                 0.75656
#                 stddev      0.07562                 0.02449
#         standard error      0.00532                 0.00190
#   99% confidence level      0.01238                 0.00442
#                   skew      2.25699                 0.44019
#               kurtosis      5.53532                 0.07179
#       time correlation     -0.00012                 0.00007
#
#           elasped time      0.18651
#      number of samples          166
#     number of outliers           36
#      getnsecs overhead          431
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                157      0.00000 |********************************     0.75201
#
#                  9        > 95% |*                                    0.81311
#
#        mean of 95%      0.75201
#          95th %ile      0.79854
 
# bin/strchr -E -C 200 -L -S -W -N strchr_10 -s 10 -I 5 
             prc thr   usecs/call      samples   errors cnt/samp     size
strchr_10      1   1      0.23750          190        0    20000       10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.22835                 0.22835
#                    max      0.49531                 0.25326
#                   mean      0.24236                 0.23814
#                 median      0.23766                 0.23750
#                 stddev      0.02674                 0.00552
#         standard error      0.00188                 0.00040
#   99% confidence level      0.00438                 0.00093
#                   skew      8.03833                 0.54683
#               kurtosis     70.89716                -0.21458
#       time correlation     -0.00002                -0.00002
#
#           elasped time      1.01398
#      number of samples          190
#     number of outliers           12
#      getnsecs overhead          809
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                180      0.00000 |********************************     0.23744
#
#                 10        > 95% |*                                    0.25082
#
#        mean of 95%      0.23744
#          95th %ile      0.24836
# bin/strchr -E -C 200 -L -S -W -N strchr_1k -s 1k -I 200 
             prc thr   usecs/call      samples   errors cnt/samp     size
strchr_1k      1   1      0.91024          176        0      500     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.83856                 0.83856
#                    max      1.90864                 0.97424
#                   mean      0.94116                 0.90643
#                 median      0.91434                 0.91024
#                 stddev      0.12158                 0.02945
#         standard error      0.00855                 0.00222
#   99% confidence level      0.01990                 0.00516
#                   skew      4.66056                -0.02144
#               kurtosis     28.31908                -0.66036
#       time correlation     -0.00031                 0.00006
#
#           elasped time      0.12653
#      number of samples          176
#     number of outliers           26
#      getnsecs overhead          814
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                167      0.00000 |********************************     0.90343
#
#                  9        > 95% |*                                    0.96218
#
#        mean of 95%      0.90343
#          95th %ile      0.95223
# bin/strcmp -E -C 200 -L -S -W -N strcmp_10 -s 10 -I 10 
             prc thr   usecs/call      samples   errors cnt/samp     size
strcmp_10      1   1      0.17545          194        0    10000       10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.16232                 0.16232
#                    max      0.28335                 0.19875
#                   mean      0.17932                 0.17748
#                 median      0.17594                 0.17545
#                 stddev      0.01298                 0.00766
#         standard error      0.00091                 0.00055
#   99% confidence level      0.00212                 0.00128
#                   skew      3.90587                 0.84128
#               kurtosis     24.13523                 0.19812
#       time correlation     -0.00005                -0.00002
#
#           elasped time      0.39472
#      number of samples          194
#     number of outliers            8
#      getnsecs overhead          635
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                184      0.00000 |********************************     0.17645
#
#                 10        > 95% |*                                    0.19629
#
#        mean of 95%      0.17645
#          95th %ile      0.19455
# bin/strcmp -E -C 200 -L -S -W -N strcmp_1k -s 1k -I 200 
             prc thr   usecs/call      samples   errors cnt/samp     size
strcmp_1k      1   1      1.24613          167        0      500     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      1.16268                 1.16268
#                    max     10.74220                 1.35058
#                   mean      1.34665                 1.24769
#                 median      1.25842                 1.24613
#                 stddev      0.68295                 0.04078
#         standard error      0.04805                 0.00316
#   99% confidence level      0.11177                 0.00734
#                   skew     12.94450                 0.18858
#               kurtosis    174.44681                -0.22022
#       time correlation     -0.00059                 0.00018
#
#           elasped time      0.16661
#      number of samples          167
#     number of outliers           35
#      getnsecs overhead          805
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                158      1.00000 |********************************     1.24265
#
#                  9        > 95% |*                                    1.33619
#
#        mean of 95%      1.24265
#          95th %ile      1.32242
 
# bin/strcasecmp -E -C 200 -L -S -W -N scasecmp_10 -s 10 -I 50 
             prc thr   usecs/call      samples   errors cnt/samp     size
scasecmp_10    1   1      0.28208          174        0     2000       10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.25865                 0.25865
#                    max      0.91504                 0.30870
#                   mean      0.29155                 0.28157
#                 median      0.28362                 0.28208
#                 stddev      0.04852                 0.00905
#         standard error      0.00341                 0.00069
#   99% confidence level      0.00794                 0.00160
#                   skew     10.60520                 0.20649
#               kurtosis    132.14777                 0.25566
#       time correlation     -0.00014                -0.00002
#
#           elasped time      0.15060
#      number of samples          174
#     number of outliers           28
#      getnsecs overhead          834
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                165      0.00000 |********************************     0.28045
#
#                  9        > 95% |*                                    0.30193
#
#        mean of 95%      0.28045
#          95th %ile      0.29667
# bin/strcasecmp -E -C 200 -L -S -W -N scasecmp_1k -s 1k -I 20000 
             prc thr   usecs/call      samples   errors cnt/samp     size
scasecmp_1k    1   1     25.84900          189        0        5     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     22.67460                22.67460
#                    max    283.79460                33.01700
#                   mean     29.75110                26.59777
#                 median     26.05380                25.84900
#                 stddev     20.21576                 2.27409
#         standard error      1.42238                 0.16542
#   99% confidence level      3.30845                 0.38476
#                   skew     10.28261                 0.96403
#               kurtosis    121.82894                 0.04058
#       time correlation     -0.03259                -0.00525
#
#           elasped time      0.06001
#      number of samples          189
#     number of outliers           13
#      getnsecs overhead          803
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     22.00000 |*                                   22.67460
#                  4     23.00000 |**                                  23.85220
#                 48     24.00000 |********************************    24.51140
#                 43     25.00000 |****************************        25.35843
#                 30     26.00000 |********************                26.45316
#                 18     27.00000 |************                        27.56136
#                 11     28.00000 |*******                             28.44158
#                 14     29.00000 |*********                           29.32694
#                  6     30.00000 |****                                30.54233
#                  4     31.00000 |**                                  31.17380
#
#                 10        > 95% |******                              32.08516
#
#        mean of 95%     26.29121
#          95th %ile     31.27620
 
# bin/strtol -E -C 200 -L -S -W -N strtol -I 20 
             prc thr   usecs/call      samples   errors cnt/samp 
strtol         1   1      0.34062          199        0     5000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.31364                 0.31364
#                    max      0.55346                 0.38542
#                   mean      0.34424                 0.34247
#                 median      0.34164                 0.34062
#                 stddev      0.02257                 0.01553
#         standard error      0.00159                 0.00110
#   99% confidence level      0.00369                 0.00256
#                   skew      4.34426                 0.57532
#               kurtosis     35.19941                -0.23509
#       time correlation      0.00001                 0.00004
#
#           elasped time      0.38071
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          843
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                189      0.00000 |********************************     0.34051
#
#                 10        > 95% |*                                    0.37950
#
#        mean of 95%      0.34051
#          95th %ile      0.37400
 
# bin/getcontext -E -C 200 -L -S -W -N getcontext -I 100 
             prc thr   usecs/call      samples   errors cnt/samp 
getcontext     1   1      4.42927          191        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      4.16534                 4.16534
#                    max      9.72028                 4.76412
#                   mean      4.54437                 4.44652
#                 median      4.43414                 4.42927
#                 stddev      0.56774                 0.10819
#         standard error      0.03995                 0.00783
#   99% confidence level      0.09291                 0.01821
#                   skew      7.18781                 0.70580
#               kurtosis     58.38286                 0.49384
#       time correlation      0.00020                -0.00016
#
#           elasped time      0.95260
#      number of samples          191
#     number of outliers           11
#      getnsecs overhead          807
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                181      4.00000 |********************************     4.43178
#
#                 10        > 95% |*                                    4.71338
#
#        mean of 95%      4.43178
#          95th %ile      4.66428
# bin/setcontext -E -C 200 -L -S -W -N setcontext -I 100 
             prc thr   usecs/call      samples   errors cnt/samp 
setcontext     1   1      2.84301          202        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.50817                 2.50817
#                    max      6.98125                 6.98125
#                   mean      3.70380                 3.70380
#                 median      2.84301                 2.84301
#                 stddev      1.25691                 1.25691
#         standard error      0.08844                 0.08844
#   99% confidence level      0.20570                 0.20570
#                   skew      0.53412                 0.53412
#               kurtosis     -1.37439                -1.37439
#       time correlation     -0.01692                -0.01692
#
#           elasped time      0.77512
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          889
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                117      2.00000 |********************************     2.68860
#                  4      3.00000 |*                                    3.12026
#                 14      4.00000 |***                                  4.87258
#                 56      5.00000 |***************                      5.13521
#
#                 11        > 95% |***                                  5.93938
#
#        mean of 95%      3.57505
#          95th %ile      5.38817
 
# bin/mutex -E -C 200 -L -S -W -N mutex_st -I 10 
             prc thr   usecs/call      samples   errors cnt/samp holdtime
mutex_st       1   1      0.16491          171        0    10000        0
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.15802                 0.15802
#                    max      0.57674                 0.18101
#                   mean      0.17593                 0.16616
#                 median      0.16632                 0.16491
#                 stddev      0.03654                 0.00502
#         standard error      0.00257                 0.00038
#   99% confidence level      0.00598                 0.00089
#                   skew      7.33230                 0.76265
#               kurtosis     71.26700                -0.03894
#       time correlation     -0.00003                -0.00001
#
#           elasped time      0.37904
#      number of samples          171
#     number of outliers           31
#      getnsecs overhead          813
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                162      0.00000 |********************************     0.16549
#
#                  9        > 95% |*                                    0.17813
#
#        mean of 95%      0.16549
#          95th %ile      0.17702
# bin/mutex -E -C 200 -L -S -W -N mutex_mt -t -I 10 
             prc thr   usecs/call      samples   errors cnt/samp holdtime
mutex_mt       1   1      0.18562          168        0    10000        0
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.17881                 0.17881
#                    max      0.43361                 0.20172
#                   mean      0.19913                 0.18670
#                 median      0.18752                 0.18562
#                 stddev      0.04025                 0.00509
#         standard error      0.00283                 0.00039
#   99% confidence level      0.00659                 0.00091
#                   skew      3.81760                 0.76653
#               kurtosis     14.63678                -0.11973
#       time correlation     -0.00024                -0.00001
#
#           elasped time      0.43404
#      number of samples          168
#     number of outliers           34
#      getnsecs overhead          804
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                159      0.00000 |********************************     0.18603
#
#                  9        > 95% |*                                    0.19867
#
#        mean of 95%      0.18603
#          95th %ile      0.19701
# bin/mutex -E -C 200 -L -S -W -N mutex_T2 -T 2 -I 100 
             prc thr   usecs/call      samples   errors cnt/samp holdtime
mutex_T2       1   2      0.89212          201        0     1000        0
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.48124                 0.48124
#                    max      2.65519                 2.04540
#                   mean      1.05498                 1.04702
#                 median      0.89519                 0.89212
#                 stddev      0.37875                 0.36236
#         standard error      0.02665                 0.02556
#   99% confidence level      0.06199                 0.05945
#                   skew      1.29475                 1.12304
#               kurtosis      0.94901                -0.05924
#       time correlation     -0.00051                -0.00076
#
#           elasped time      0.29582
#      number of samples          201
#     number of outliers            1
#      getnsecs overhead          809
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                126      0.00000 |********************************     0.81624
#                 64      1.00000 |****************                     1.35913
#
#                 11        > 95% |**                                   1.87448
#
#        mean of 95%      0.99911
#          95th %ile      1.77814
 
# bin/longjmp -E -C 200 -L -S -W -N longjmp -I 10 
             prc thr   usecs/call      samples   errors cnt/samp 
longjmp        1   1      0.16862          172        0    10000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.16312                 0.16312
#                    max      0.43453                 0.19683
#                   mean      0.19361                 0.17229
#                 median      0.17251                 0.16862
#                 stddev      0.05685                 0.00819
#         standard error      0.00400                 0.00062
#   99% confidence level      0.00930                 0.00145
#                   skew      2.34780                 1.20195
#               kurtosis      4.03526                 0.66307
#       time correlation     -0.00054                -0.00001
#
#           elasped time      0.41372
#      number of samples          172
#     number of outliers           30
#      getnsecs overhead          828
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                163      0.00000 |********************************     0.17111
#
#                  9        > 95% |*                                    0.19358
#
#        mean of 95%      0.17111
#          95th %ile      0.18923
# bin/siglongjmp -E -C 200 -L -S -W -N siglongjmp -I 20 
             prc thr   usecs/call      samples   errors cnt/samp 
siglongjmp     1   1      2.83581          202        0     5000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.68466                 2.68466
#                    max      6.37142                 6.37142
#                   mean      3.36966                 3.36966
#                 median      2.83581                 2.83581
#                 stddev      1.03429                 1.03429
#         standard error      0.07277                 0.07277
#   99% confidence level      0.16927                 0.16927
#                   skew      1.55393                 1.55393
#               kurtosis      0.68542                 0.68542
#       time correlation      0.00259                 0.00259
#
#           elasped time      3.43041
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          804
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                135      2.00000 |********************************     2.80533
#                 30      3.00000 |*******                              3.29944
#                  2      4.00000 |*                                    4.63595
#                 24      5.00000 |*****                                5.42211
#
#                 11        > 95% |**                                   5.77863
#
#        mean of 95%      3.23092
#          95th %ile      5.53502
 
# bin/getrusage -E -C 200 -L -S -W -N getrusage -I 200 
             prc thr   usecs/call      samples   errors cnt/samp 
getrusage      1   1     13.65445          191        0      500 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     12.87212                12.87212
#                    max     24.29228                14.50796
#                   mean     13.92393                13.64797
#                 median     13.67442                13.65445
#                 stddev      1.41465                 0.29456
#         standard error      0.09953                 0.02131
#   99% confidence level      0.23152                 0.04958
#                   skew      5.72719                 0.13827
#               kurtosis     36.54365                 0.24326
#       time correlation      0.00087                 0.00053
#
#           elasped time      1.43641
#      number of samples          191
#     number of outliers           11
#      getnsecs overhead          805
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  3     12.00000 |*                                   12.93509
#                174     13.00000 |********************************    13.61233
#                  4     14.00000 |*                                   14.06866
#
#                 10        > 95% |*                                   14.31371
#
#        mean of 95%     13.61119
#          95th %ile     14.13471
 
# bin/times -E -C 200 -L -S -W -N times -I 200 
             prc thr   usecs/call      samples   errors cnt/samp 
times          1   1     11.10677          200        0      500 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      5.29249                 5.29249
#                    max     21.82856                14.72046
#                   mean     10.23150                10.11751
#                 median     11.10677                11.10677
#                 stddev      2.65283                 2.40601
#         standard error      0.18665                 0.17013
#   99% confidence level      0.43415                 0.39572
#                   skew     -0.17843                -1.16447
#               kurtosis      2.46360                -0.12619
#       time correlation     -0.02868                -0.02854
#
#           elasped time      1.06189
#      number of samples          200
#     number of outliers            2
#      getnsecs overhead          793
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 39      5.00000 |**********                           5.57428
#                  3      6.00000 |*                                    6.18559
#                  0      7.00000 |                                           -
#                  2      8.00000 |*                                    8.50453
#                  0      9.00000 |                                           -
#                 30     10.00000 |********                            10.85872
#                116     11.00000 |********************************    11.32309
#
#                 10        > 95% |**                                  13.12983
#
#        mean of 95%      9.95896
#          95th %ile     11.86657
# bin/time -E -C 200 -L -S -W -N time -I 50 
             prc thr   usecs/call      samples   errors cnt/samp 
time           1   1      0.46361          186        0     2000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.41804                 0.41804
#                    max      0.77708                 0.54502
#                   mean      0.48003                 0.46911
#                 median      0.46617                 0.46361
#                 stddev      0.04915                 0.02544
#         standard error      0.00346                 0.00187
#   99% confidence level      0.00804                 0.00434
#                   skew      3.05027                 1.05202
#               kurtosis     12.88513                 0.70680
#       time correlation     -0.00008                 0.00001
#
#           elasped time      0.22675
#      number of samples          186
#     number of outliers           16
#      getnsecs overhead          785
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                176      0.00000 |********************************     0.46540
#
#                 10        > 95% |*                                    0.53449
#
#        mean of 95%      0.46540
#          95th %ile      0.52415
# bin/localtime_r -E -C 200 -L -S -W -N localtime_r -I 200 
             prc thr   usecs/call      samples   errors cnt/samp 
localtime_r    1   1      0.75047          197        0      500 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.71412                 0.71412
#                    max     14.50638                 1.68231
#                   mean      0.97989                 0.89334
#                 median      0.75047                 0.75047
#                 stddev      1.00283                 0.27269
#         standard error      0.07056                 0.01943
#   99% confidence level      0.16412                 0.04519
#                   skew     12.17127                 1.45293
#               kurtosis    160.88337                 0.45831
#       time correlation     -0.00531                -0.00301
#
#           elasped time      0.12274
#      number of samples          197
#     number of outliers            5
#      getnsecs overhead          828
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                154      0.00000 |********************************     0.75804
#                 33      1.00000 |******                               1.33058
#
#                 10        > 95% |**                                   1.53399
#
#        mean of 95%      0.85908
#          95th %ile      1.45242
# bin/strftime -E -C 200 -L -S -W -N strftime -I 10000 
             prc thr   usecs/call      samples   errors cnt/samp   format
strftime       1   1      8.41580          181        0       10       %c
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      7.51980                 7.51980
#                    max    189.51020                 9.82380
#                   mean      9.97284                 8.49684
#                 median      8.51820                 8.41580
#                 stddev     12.97565                 0.44553
#         standard error      0.91296                 0.03312
#   99% confidence level      2.12355                 0.07703
#                   skew     13.15472                 0.50766
#               kurtosis    178.50246                 0.53037
#       time correlation     -0.02782                 0.00033
#
#           elasped time      0.05399
#      number of samples          181
#     number of outliers           21
#      getnsecs overhead          834
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 19      7.00000 |****                                 7.76906
#                135      8.00000 |********************************     8.44500
#                 17      9.00000 |****                                 9.10549
#
#                 10        > 95% |**                                   9.54476
#
#        mean of 95%      8.43556
#          95th %ile      9.31180
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 2X to avoid.
 
# bin/mktime -E -C 200 -L -S -W -N mktime -I 500 
             prc thr   usecs/call      samples   errors cnt/samp 
mktime         1   1     56.06126          202        0      200 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     46.91054                46.91054
#                    max    140.87534               140.87534
#                   mean     71.35029                71.35029
#                 median     56.06126                56.06126
#                 stddev     27.72252                27.72252
#         standard error      1.95055                 1.95055
#   99% confidence level      4.53698                 4.53698
#                   skew      1.17573                 1.17573
#               kurtosis     -0.31619                -0.31619
#       time correlation     -0.33571                -0.33571
#
#           elasped time      2.91657
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          804
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2     45.00000 |*                                   47.37326
#                 12     48.00000 |*******                             49.30702
#                 46     51.00000 |****************************        52.75956
#                 52     54.00000 |********************************    55.27322
#                 17     57.00000 |**********                          58.21046
#                  9     60.00000 |*****                               61.23289
#                  7     63.00000 |****                                64.66268
#                  0     66.00000 |                                           -
#                  2     69.00000 |*                                   70.10286
#                  1     72.00000 |*                                   72.01134
#                  1     75.00000 |*                                   75.87566
#                  1     78.00000 |*                                   80.01134
#                  1     81.00000 |*                                   81.35662
#                  0     84.00000 |                                           -
#                  0     87.00000 |                                           -
#                  2     90.00000 |*                                   92.59630
#                  1     93.00000 |*                                   93.81102
#                  1     96.00000 |*                                   96.39534
#                  0     99.00000 |                                           -
#                  0    102.00000 |                                           -
#                  3    105.00000 |*                                  107.21817
#                  3    108.00000 |*                                  110.13059
#                  7    111.00000 |****                               112.44051
#                 10    114.00000 |******                             115.69812
#                  7    117.00000 |****                               118.86684
#                  6    120.00000 |***                                120.85742
#
#                 11        > 95% |******                             132.15319
#
#        mean of 95%     67.84855
#          95th %ile    122.02094
# bin/mktime -E -C 200 -L -S -W -N mktimeT2 -T 2 -I 1000 
             prc thr   usecs/call      samples   errors cnt/samp 
mktimeT2       1   2    348.06612          201        0      100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    220.79572               220.79572
#                    max    561.05556               456.64596
#                   mean    344.99980               343.92489
#                 median    349.63796               348.06612
#                 stddev     48.30333                45.93817
#         standard error      3.39861                 3.24023
#   99% confidence level      7.90517                 7.53677
#                   skew      0.08136                -0.35267
#               kurtosis      1.04855                -0.49699
#       time correlation      0.07113                 0.07788
#
#           elasped time      7.10898
#      number of samples          201
#     number of outliers            1
#      getnsecs overhead          428
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    217.00000 |*                                  220.79572
#                  0    224.00000 |                                           -
#                  0    231.00000 |                                           -
#                  0    238.00000 |                                           -
#                  2    245.00000 |***                                250.17044
#                  5    252.00000 |*********                          255.57178
#                  6    259.00000 |***********                        262.27327
#                 10    266.00000 |******************                 269.33050
#                  5    273.00000 |*********                          277.14951
#                  5    280.00000 |*********                          284.70151
#                  3    287.00000 |*****                              290.04543
#                  2    294.00000 |***                                298.77588
#                  1    301.00000 |*                                  302.12692
#                  1    308.00000 |*                                  312.77652
#                 10    315.00000 |******************                 319.61249
#                 17    322.00000 |********************************   325.59911
#                 16    329.00000 |******************************     331.91892
#                  8    336.00000 |***************                    338.91476
#                 10    343.00000 |******************                 346.31815
#                 13    350.00000 |************************           353.58312
#                 10    357.00000 |******************                 358.99271
#                 13    364.00000 |************************           368.04987
#                 14    371.00000 |**************************         374.24303
#                 12    378.00000 |**********************             381.66889
#                  6    385.00000 |***********                        387.87241
#                 10    392.00000 |******************                 395.12430
#                  6    399.00000 |***********                        402.70420
#                  4    406.00000 |*******                            408.47316
#
#                 11        > 95% |********************               421.40221
#
#        mean of 95%    339.43936
#          95th %ile    409.96692
 
# bin/cascade_mutex -E -C 200 -L -S -W -N c_mutex_1 -I 50 
             prc thr   usecs/call      samples   errors cnt/samp 
c_mutex_1      1   1      1.16053          197        0     2000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      1.07260                 1.07260
#                    max      3.75855                 1.26665
#                   mean      1.17721                 1.15975
#                 median      1.16156                 1.16053
#                 stddev      0.18982                 0.03836
#         standard error      0.01336                 0.00273
#   99% confidence level      0.03107                 0.00636
#                   skew     12.49413                 0.30794
#               kurtosis    166.40804                -0.22600
#       time correlation     -0.00035                 0.00009
#
#           elasped time      0.51208
#      number of samples          197
#     number of outliers            5
#      getnsecs overhead          852
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                187      1.00000 |********************************     1.15513
#
#                 10        > 95% |*                                    1.24614
#
#        mean of 95%      1.15513
#          95th %ile      1.23657
# bin/cascade_mutex -E -C 200 -L -S -W -N c_mutex_10 -T 10 -I 5000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_mutex_10     1  10   2391.50890          185        0       20 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   2124.25770              2124.25770
#                    max   4551.00970              2732.61610
#                   mean   2476.39489              2411.90006
#                 median   2403.95050              2391.50890
#                 stddev    269.86317               116.71709
#         standard error     18.98751                 8.58121
#   99% confidence level     44.16494                19.95990
#                   skew      3.59513                 0.81195
#               kurtosis     18.93243                 0.52876
#       time correlation      0.02690                 0.00560
#
#           elasped time     10.67809
#      number of samples          185
#     number of outliers           17
#      getnsecs overhead          862
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1   2120.00000 |*                                 2124.25770
#                  0   2140.00000 |                                           -
#                  1   2160.00000 |*                                 2176.00810
#                  2   2180.00000 |**                                2189.68490
#                  0   2200.00000 |                                           -
#                  1   2220.00000 |*                                 2233.26250
#                  4   2240.00000 |*****                             2247.96650
#                  6   2260.00000 |********                          2275.97183
#                  4   2280.00000 |*****                             2284.68330
#                 10   2300.00000 |**************                    2309.22666
#                 22   2320.00000 |********************************  2328.14890
#                 19   2340.00000 |***************************       2349.18469
#                 17   2360.00000 |************************          2370.91746
#                 11   2380.00000 |****************                  2390.01246
#                 17   2400.00000 |************************          2409.51850
#                 11   2420.00000 |****************                  2428.03079
#                 15   2440.00000 |*********************             2451.06901
#                  4   2460.00000 |*****                             2470.12330
#                  8   2480.00000 |***********                       2490.14890
#                  3   2500.00000 |****                              2507.25930
#                  4   2520.00000 |*****                             2529.66890
#                  1   2540.00000 |*                                 2558.44650
#                  3   2560.00000 |****                              2572.98730
#                  4   2580.00000 |*****                             2591.82250
#                  2   2600.00000 |**                                2613.15370
#                  2   2620.00000 |**                                2631.36170
#                  3   2640.00000 |****                              2650.38463
#
#                 10        > 95% |**************                    2699.71882
#
#        mean of 95%   2395.45327
#          95th %ile   2665.26250
# bin/cascade_mutex -E -C 200 -L -S -W -N c_mutex_200 -T 200 -I 2000000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_mutex_200    1 200  66025.76600          196        0        1 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min  54603.30200             54603.30200
#                    max  97271.20600             77622.82200
#                   mean  66719.52853             66152.77335
#                 median  66097.19000             66025.76600
#                 stddev   5143.04763              3893.52302
#         standard error    361.86357               278.10879
#   99% confidence level    841.69466               646.88104
#                   skew      1.86321                 0.30634
#               kurtosis      7.34040                 0.24133
#       time correlation     15.63469                10.58802
#
#           elasped time     50.18034
#      number of samples          196
#     number of outliers            6
#      getnsecs overhead          436
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1  54600.00000 |*                                54603.30200
#                  0  55200.00000 |                                           -
#                  0  55800.00000 |                                           -
#                  1  56400.00000 |*                                56943.27000
#                  0  57000.00000 |                                           -
#                  0  57600.00000 |                                           -
#                  3  58200.00000 |*****                            58499.92067
#                  1  58800.00000 |*                                59397.28600
#                  0  59400.00000 |                                           -
#                  5  60000.00000 |********                         60227.95480
#                  4  60600.00000 |*******                          60945.25400
#                  7  61200.00000 |************                     61553.13514
#                  6  61800.00000 |**********                       62069.05133
#                 12  62400.00000 |*********************            62690.08600
#                 13  63000.00000 |***********************          63283.10015
#                 13  63600.00000 |***********************          63942.39862
#                 15  64200.00000 |**************************       64473.51853
#                  7  64800.00000 |************                     65157.34086
#                 10  65400.00000 |*****************                65630.87320
#                 13  66000.00000 |***********************          66214.09338
#                  9  66600.00000 |****************                 66930.68333
#                  9  67200.00000 |****************                 67555.84956
#                 18  67800.00000 |******************************** 68134.26022
#                  9  68400.00000 |****************                 68714.37756
#                  8  69000.00000 |**************                   69193.68600
#                  5  69600.00000 |********                         70067.51960
#                  6  70200.00000 |**********                       70576.20867
#                  4  70800.00000 |*******                          70910.91800
#                  1  71400.00000 |*                                71849.38200
#                  3  72000.00000 |*****                            72363.60067
#                  3  72600.00000 |*****                            72894.92867
#
#                 10        > 95% |*****************                75094.64280
#
#        mean of 95%  65672.02768
#          95th %ile  73094.69400
 
# bin/cascade_cond -E -C 200 -L -S -W -N c_cond_1 -I 100 
             prc thr   usecs/call      samples   errors cnt/samp 
c_cond_1       1   1      1.07859          202        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      0.93370                 0.93370
#                    max      2.43668                 2.43668
#                   mean      1.37733                 1.37733
#                 median      1.07859                 1.07859
#                 stddev      0.44771                 0.44771
#         standard error      0.03150                 0.03150
#   99% confidence level      0.07327                 0.07327
#                   skew      0.51634                 0.51634
#               kurtosis     -1.49600                -1.49600
#       time correlation     -0.00568                -0.00568
#
#           elasped time      0.30156
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          445
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 56      0.00000 |*************                        0.97340
#                130      1.00000 |********************************     1.46092
#                  5      2.00000 |*                                    2.01161
#
#                 11        > 95% |**                                   2.15761
#
#        mean of 95%      1.33240
#          95th %ile      2.02656
# bin/cascade_cond -E -C 200 -L -S -W -N c_cond_10 -T 10 -I 3000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_cond_10      1  10   2080.88729          202        0       33 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   1773.53671              1773.53671
#                    max   2392.41671              2392.41671
#                   mean   2086.99409              2086.99409
#                 median   2080.88729              2080.88729
#                 stddev    107.63047               107.63047
#         standard error      7.57285                 7.57285
#   99% confidence level     17.61446                17.61446
#                   skew      0.00818                 0.00818
#               kurtosis      0.20164                 0.20164
#       time correlation     -0.47087                -0.47087
#
#           elasped time     14.91797
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          808
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1   1760.00000 |*                                 1773.53671
#                  1   1780.00000 |*                                 1788.09859
#                  0   1800.00000 |                                           -
#                  1   1820.00000 |*                                 1826.68682
#                  0   1840.00000 |                                           -
#                  4   1860.00000 |******                            1871.48306
#                  2   1880.00000 |***                               1889.13576
#                  6   1900.00000 |*********                         1910.18173
#                  2   1920.00000 |***                               1935.53200
#                  3   1940.00000 |****                              1949.28824
#                  7   1960.00000 |**********                        1976.21879
#                 10   1980.00000 |***************                   1991.96193
#                 10   2000.00000 |***************                   2010.46546
#                 21   2020.00000 |********************************  2032.09491
#                 15   2040.00000 |**********************            2048.28293
#                 18   2060.00000 |***************************       2068.34162
#                 17   2080.00000 |*************************         2090.14537
#                 11   2100.00000 |****************                  2110.06034
#                 16   2120.00000 |************************          2131.86612
#                  7   2140.00000 |**********                        2149.93415
#                  7   2160.00000 |**********                        2167.35506
#                 12   2180.00000 |******************                2192.14314
#                 13   2200.00000 |*******************               2210.89938
#                  2   2220.00000 |***                               2231.79929
#                  5   2240.00000 |*******                           2246.75271
#
#                 11        > 95% |****************                  2312.29829
#
#        mean of 95%   2074.01846
#          95th %ile   2253.44635
# bin/cascade_cond -E -C 200 -L -S -W -N c_cond_200 -T 200 -I 2000000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_cond_200     1 200  67350.31650          202        0        1 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min  39655.21250             39655.21250
#                    max  87941.29250             87941.29250
#                   mean  65240.40442             65240.40442
#                 median  67350.31650             67350.31650
#                 stddev  11545.06077             11545.06077
#         standard error    812.30764               812.30764
#   99% confidence level   1889.42757              1889.42757
#                   skew     -0.35342                -0.35342
#               kurtosis     -0.72353                -0.72353
#       time correlation      9.89415                 9.89415
#
#           elasped time     48.59195
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          423
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1  38000.00000 |*                                39655.21250
#                  3  40000.00000 |****                             41428.60983
#                  6  42000.00000 |*********                        42757.82583
#                  4  44000.00000 |******                           45285.64450
#                  6  46000.00000 |*********                        47161.40983
#                  8  48000.00000 |************                     49499.32450
#                 10  50000.00000 |****************                 50839.28930
#                  7  52000.00000 |***********                      53178.08336
#                  8  54000.00000 |************                     55036.34850
#                  3  56000.00000 |****                             57009.62317
#                  3  58000.00000 |****                             59726.12450
#                  7  60000.00000 |***********                      61078.00564
#                  7  62000.00000 |***********                      63113.29707
#                 20  64000.00000 |******************************** 65068.37090
#                 16  66000.00000 |*************************        67165.06850
#                 16  68000.00000 |*************************        68977.42050
#                 17  70000.00000 |***************************      71159.32544
#                 14  72000.00000 |**********************           72919.02964
#                 10  74000.00000 |****************                 74813.97090
#                  9  76000.00000 |**************                   76894.96361
#                 11  78000.00000 |*****************                79048.43432
#                  5  80000.00000 |********                         81008.35170
#
#                 11        > 95% |*****************                84772.75723
#
#        mean of 95%  64115.50452
#          95th %ile  81329.32450
 
# bin/cascade_lockf -E -C 200 -L -S -W -N c_lockf_1 -I 1000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_lockf_1      1   1    122.77665          173        0      100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    110.67553               110.67553
#                    max    251.74689               139.98497
#                   mean    130.56398               122.89107
#                 median    123.67777               122.77665
#                 stddev     22.31551                 6.12300
#         standard error      1.57011                 0.46552
#   99% confidence level      3.65208                 1.08281
#                   skew      2.82947                 0.56741
#               kurtosis      8.97113                 0.34410
#       time correlation     -0.04033                -0.02365
#
#           elasped time      2.67195
#      number of samples          173
#     number of outliers           29
#      getnsecs overhead          351
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    110.00000 |*                                  110.67553
#                  2    111.00000 |***                                111.68161
#                  3    112.00000 |****                               112.59724
#                  6    113.00000 |*********                          113.50476
#                  5    114.00000 |*******                            114.66913
#                  5    115.00000 |*******                            115.38081
#                  6    116.00000 |*********                          116.43510
#                  7    117.00000 |**********                         117.41345
#                 12    118.00000 |******************                 118.36812
#                  6    119.00000 |*********                          119.61846
#                 12    120.00000 |******************                 120.31073
#                 10    121.00000 |***************                    121.45953
#                 17    122.00000 |*************************          122.54158
#                 21    123.00000 |********************************   123.62291
#                  8    124.00000 |************                       124.64161
#                  8    125.00000 |************                       125.47745
#                  6    126.00000 |*********                          126.65804
#                  9    127.00000 |*************                      127.40058
#                  5    128.00000 |*******                            128.48443
#                  4    129.00000 |******                             129.33473
#                  5    130.00000 |*******                            130.62868
#                  2    131.00000 |***                                131.77249
#                  2    132.00000 |***                                132.77601
#                  2    133.00000 |***                                133.39681
#
#                  9        > 95% |*************                      138.27773
#
#        mean of 95%    122.04668
#          95th %ile    136.54689
# bin/cascade_lockf -E -C 200 -L -S -W -N c_lockf_10 -P 10 -I 50000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_lockf_10    10   1   7827.78100          201        0        2 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   4243.78100              4243.78100
#                    max  13440.32500             11052.86900
#                   mean   7456.41245              7426.64174
#                 median   7914.30900              7827.78100
#                 stddev   1970.36199              1929.19964
#         standard error    138.63419               136.07525
#   99% confidence level    322.46312               316.51103
#                   skew     -0.01204                -0.11529
#               kurtosis     -1.20000                -1.50069
#       time correlation      7.37583                 6.82164
#
#           elasped time      3.77454
#      number of samples          201
#     number of outliers            1
#      getnsecs overhead          374
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  3   4200.00000 |******                            4264.68767
#                  6   4400.00000 |************                      4521.96767
#                  6   4600.00000 |************                      4728.23967
#                 13   4800.00000 |***************************       4922.68315
#                 11   5000.00000 |***********************           5077.67773
#                 10   5200.00000 |*********************             5280.96500
#                  8   5400.00000 |*****************                 5476.18100
#                  7   5600.00000 |**************                    5737.01071
#                  6   5800.00000 |************                      5945.30633
#                  3   6000.00000 |******                            6117.78633
#                  4   6200.00000 |********                          6314.91700
#                  6   6400.00000 |************                      6483.73833
#                  2   6600.00000 |****                              6746.62900
#                  3   6800.00000 |******                            6878.66100
#                  2   7000.00000 |****                              7112.32500
#                  3   7200.00000 |******                            7295.64233
#                  4   7400.00000 |********                          7513.79700
#                  2   7600.00000 |****                              7694.27700
#                  3   7800.00000 |******                            7853.63700
#                  4   8000.00000 |********                          8099.20500
#                  6   8200.00000 |************                      8317.80767
#                  9   8400.00000 |*******************               8530.01744
#                 10   8600.00000 |*********************             8712.10740
#                 15   8800.00000 |********************************  8897.57087
#                  8   9000.00000 |*****************                 9104.26100
#                 12   9200.00000 |*************************         9310.12767
#                 10   9400.00000 |*********************             9502.98100
#                  8   9600.00000 |*****************                 9684.53300
#                  4   9800.00000 |********                          9908.42100
#                  2  10000.00000 |****                             10030.27700
#
#                 11        > 95% |***********************          10362.27409
#
#        mean of 95%   7256.68407
#          95th %ile  10049.86100
# bin/cascade_lockf -E -C 200 -L -S -W -N c_lockf_200 -P 200 -I 5000000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_lockf_200  200   1 204286.81100          202        0        1 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min 136809.81900            136809.81900
#                    max 245903.83500            245903.83500
#                   mean 200187.88981            200187.88981
#                 median 204286.81100            204286.81100
#                 stddev  25270.68930             25270.68930
#         standard error   1778.03949              1778.03949
#   99% confidence level   4135.71986              4135.71986
#                   skew     -0.40368                -0.40368
#               kurtosis     -0.79957                -0.79957
#       time correlation    -10.74324               -10.74324
#
#           elasped time    108.27196
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          330
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2 136000.00000 |***                             138158.81100
#                  2 140000.00000 |***                             142902.55500
#                  2 144000.00000 |***                             145500.31500
#                  0 148000.00000 |                                           -
#                  2 152000.00000 |***                             155313.05100
#                  6 156000.00000 |*********                       158304.79500
#                  9 160000.00000 |**************                  161860.25811
#                  2 164000.00000 |***                             165782.36300
#                  8 168000.00000 |************                    170253.16300
#                  9 172000.00000 |**************                  174646.83233
#                  6 176000.00000 |*********                       177559.66433
#                  9 180000.00000 |**************                  181577.22167
#                  8 184000.00000 |************                    186450.44300
#                  7 188000.00000 |***********                     189532.98243
#                 16 192000.00000 |*************************       194240.85900
#                  6 196000.00000 |*********                       198733.85100
#                  7 200000.00000 |***********                     201863.42357
#                 10 204000.00000 |****************                205677.74860
#                 15 208000.00000 |************************        209726.75980
#                  7 212000.00000 |***********                     214230.32643
#                 10 216000.00000 |****************                218225.80620
#                 13 220000.00000 |********************            221631.91377
#                 12 224000.00000 |*******************             225843.52567
#                 20 228000.00000 |********************************229510.26060
#                  3 232000.00000 |****                            232489.98967
#
#                 11        > 95% |*****************               237042.89536
#
#        mean of 95% 198065.35023
#          95th %ile 233578.84300
 
# bin/cascade_flock -E -C 200 -L -S -W -N c_flock -I 1000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_flock        1   1     43.14771          182        0      100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     40.08851                40.08851
#                    max    127.71475                52.72723
#                   mean     47.23045                44.06696
#                 median     43.79795                43.14771
#                 stddev     11.38900                 2.92312
#         standard error      0.80133                 0.21668
#   99% confidence level      1.86389                 0.50399
#                   skew      3.71317                 0.76537
#               kurtosis     16.44642                -0.41545
#       time correlation     -0.01184                -0.00148
#
#           elasped time      0.97666
#      number of samples          182
#     number of outliers           20
#      getnsecs overhead          365
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 10     40.00000 |*****                               40.56697
#                 57     41.00000 |********************************    41.47563
#                 23     42.00000 |************                        42.47654
#                 13     43.00000 |*******                             43.44093
#                 16     44.00000 |********                            44.50355
#                 13     45.00000 |*******                             45.55017
#                 13     46.00000 |*******                             46.33668
#                 15     47.00000 |********                            47.57037
#                 12     48.00000 |******                              48.47678
#
#                 10        > 95% |*****                               50.68512
#
#        mean of 95%     43.68218
#          95th %ile     49.28659
# bin/cascade_flock -E -C 200 -L -S -W -N c_flock_10 -P 10 -I 50000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_flock_10    10   1    376.58800          190        0        2 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    274.44400               274.44400
#                    max   2250.50800               592.01200
#                   mean    423.89984               395.45318
#                 median    386.95600               376.58800
#                 stddev    169.64552                73.07394
#         standard error     11.93622                 5.30134
#   99% confidence level     27.76364                12.33092
#                   skew      6.66522                 0.74921
#               kurtosis     64.97899                -0.21759
#       time correlation     -0.53108                -0.48342
#
#           elasped time      0.80661
#      number of samples          190
#     number of outliers           12
#      getnsecs overhead         1000
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    270.00000 |**                                 274.44400
#                  3    279.00000 |******                             282.50800
#                  5    288.00000 |**********                         294.30960
#                  3    297.00000 |******                             301.96400
#                  8    306.00000 |*****************                  310.38000
#                  7    315.00000 |**************                     319.88400
#                  7    324.00000 |**************                     329.22800
#                 14    333.00000 |*****************************      336.50571
#                 12    342.00000 |*************************          347.25467
#                 12    351.00000 |*************************          355.23333
#                 15    360.00000 |********************************   364.10373
#                 10    369.00000 |*********************              374.01520
#                  5    378.00000 |**********                         384.42160
#                 12    387.00000 |*************************          391.43600
#                  8    396.00000 |*****************                  400.98800
#                  9    405.00000 |*******************                408.54533
#                  5    414.00000 |**********                         418.82800
#                  4    423.00000 |********                           427.27600
#                  2    432.00000 |****                               434.06000
#                  2    441.00000 |****                               443.02000
#                  6    450.00000 |************                       455.18000
#                  3    459.00000 |******                             463.67067
#                  4    468.00000 |********                           473.26000
#                  7    477.00000 |**************                     480.81657
#                  2    486.00000 |****                               487.75600
#                  4    495.00000 |********                           500.36400
#                  2    504.00000 |****                               506.76400
#                  3    513.00000 |******                             517.94267
#                  3    522.00000 |******                             523.83067
#                  2    531.00000 |****                               534.98800
#
#                 10        > 95% |*********************              563.90320
#
#        mean of 95%    386.09484
#          95th %ile    542.47600
# bin/cascade_flock -E -C 200 -L -S -W -N c_flock_200 -P 200 -I 5000000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_flock_200  200   1  10225.85500          201        0        1 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   5340.35100              5340.35100
#                    max  21585.85500             16326.84700
#                   mean  10145.14530             10088.22634
#                 median  10266.81500             10225.85500
#                 stddev   2453.84863              2322.45017
#         standard error    172.65219               163.81300
#   99% confidence level    401.58899               381.02905
#                   skew      0.56526                 0.14849
#               kurtosis      1.27455                -0.56512
#       time correlation      3.63887                 5.02698
#
#           elasped time     53.59630
#      number of samples          201
#     number of outliers            1
#      getnsecs overhead          386
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1   5100.00000 |**                                5340.35100
#                  2   5400.00000 |*****                             5643.32700
#                  3   5700.00000 |********                          5833.62033
#                  1   6000.00000 |**                                6058.30300
#                  5   6300.00000 |*************                     6443.71100
#                  4   6600.00000 |**********                        6677.02300
#                  9   6900.00000 |************************          7104.95900
#                 10   7200.00000 |**************************        7385.59900
#                  6   7500.00000 |****************                  7697.38567
#                  5   7800.00000 |*************                     7963.32700
#                  6   8100.00000 |****************                  8285.69500
#                  9   8400.00000 |************************          8495.05322
#                 10   8700.00000 |**************************        8839.19260
#                  7   9000.00000 |******************                9159.24929
#                  9   9300.00000 |************************          9439.56522
#                  6   9600.00000 |****************                  9807.65767
#                  7   9900.00000 |******************               10105.38871
#                 10  10200.00000 |**************************       10366.18140
#                 12  10500.00000 |******************************** 10653.74833
#                 10  10800.00000 |**************************       10929.48380
#                  6  11100.00000 |****************                 11259.39100
#                 11  11400.00000 |*****************************    11541.39245
#                 12  11700.00000 |******************************** 11864.91633
#                  8  12000.00000 |*********************            12089.79100
#                  5  12300.00000 |*************                    12477.81020
#                  3  12600.00000 |********                         12671.93500
#                  3  12900.00000 |********                         13093.48167
#                  5  13200.00000 |*************                    13261.81020
#                  3  13500.00000 |********                         13675.83900
#                  2  13800.00000 |*****                            13895.10300
#
#                 11        > 95% |*****************************    14761.84918
#
#        mean of 95%   9817.64818
#          95th %ile  13968.31900
 
# bin/cascade_fcntl -E -C 200 -L -S -W -N c_fcntl_1 -I 2000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_fcntl_1      1   1    170.08900          179        0       50 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    151.71332               151.71332
#                    max    368.69380               207.71076
#                   mean    182.57430               171.08717
#                 median    171.60964               170.08900
#                 stddev     36.07614                12.47089
#         standard error      2.53831                 0.93212
#   99% confidence level      5.90410                 2.16811
#                   skew      2.45030                 0.78089
#               kurtosis      6.12334                 0.31445
#       time correlation     -0.03481                -0.01151
#
#           elasped time      1.87826
#      number of samples          179
#     number of outliers           23
#      getnsecs overhead          382
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    150.00000 |**                                 151.71332
#                  6    152.00000 |************                       153.29028
#                 12    154.00000 |*************************          154.74393
#                  9    156.00000 |*******************                157.09899
#                 10    158.00000 |*********************              159.01290
#                  7    160.00000 |**************                     160.78962
#                  9    162.00000 |*******************                163.09565
#                 14    164.00000 |*****************************      165.13759
#                 11    166.00000 |***********************            166.88341
#                 10    168.00000 |*********************              168.65335
#                 15    170.00000 |********************************   170.93585
#                 12    172.00000 |*************************          172.99844
#                  9    174.00000 |*******************                175.01273
#                 12    176.00000 |*************************          176.88196
#                  6    178.00000 |************                       179.13177
#                  7    180.00000 |**************                     180.79199
#                  5    182.00000 |**********                         182.82449
#                  1    184.00000 |**                                 184.99332
#                  5    186.00000 |**********                         186.98090
#                  2    188.00000 |****                               188.78468
#                  3    190.00000 |******                             190.93252
#                  1    192.00000 |**                                 192.39172
#                  1    194.00000 |**                                 195.99108
#                  2    196.00000 |****                               196.20100
#
#                  9        > 95% |*******************                202.37913
#
#        mean of 95%    169.43054
#          95th %ile    196.75396
# bin/cascade_fcntl -E -C 200 -L -S -W -N c_fcntl_10 -P 10 -I 20000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_fcntl_10    10   1   7747.55283          202        0        5 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   4188.21417              4188.21417
#                    max   9842.87017              9842.87017
#                   mean   7186.11906              7186.11906
#                 median   7747.55283              7747.55283
#                 stddev   1434.06484              1434.06484
#         standard error    100.90045               100.90045
#   99% confidence level    234.69445               234.69445
#                   skew     -0.51795                -0.51795
#               kurtosis     -0.90989                -0.90989
#       time correlation     -9.86683                -9.86683
#
#           elasped time      9.49428
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          699
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1   4000.00000 |*                                 4188.21417
#                  1   4200.00000 |*                                 4322.87017
#                  9   4400.00000 |**********                        4504.94306
#                  9   4600.00000 |**********                        4692.08380
#                  4   4800.00000 |****                              4866.46483
#                  4   5000.00000 |****                              5162.17683
#                  8   5200.00000 |*********                         5324.37417
#                  4   5400.00000 |****                              5514.71017
#                  5   5600.00000 |*****                             5698.27283
#                  6   5800.00000 |*******                           5863.27194
#                  6   6000.00000 |*******                           6067.74483
#                  3   6200.00000 |***                               6254.33328
#                  5   6400.00000 |*****                             6470.45417
#                  5   6600.00000 |*****                             6672.39550
#                  5   6800.00000 |*****                             6870.13843
#                  6   7000.00000 |*******                           7093.18128
#                  4   7200.00000 |****                              7320.17150
#                  7   7400.00000 |********                          7516.79931
#                 12   7600.00000 |**************                    7708.06483
#                 27   7800.00000 |********************************  7918.92745
#                 18   8000.00000 |*********************             8102.40913
#                 22   8200.00000 |**************************        8289.13247
#                  6   8400.00000 |*******                           8519.02306
#                  8   8600.00000 |*********                         8712.99283
#                  4   8800.00000 |****                              8920.64083
#                  2   9000.00000 |**                                9020.70483
#
#                 11        > 95% |*************                     9375.12714
#
#        mean of 95%   7060.05054
#          95th %ile   9033.56883
# bin/cascade_fcntl -E -C 200 -L -S -W -N c_fcntl_200 -P 200 -I 5000000 
             prc thr   usecs/call      samples   errors cnt/samp 
c_fcntl_200  200   1 243075.78650          202        0        1 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min 160700.87450            160700.87450
#                    max 292984.26650            292984.26650
#                   mean 236623.87046            236623.87046
#                 median 243075.78650            243075.78650
#                 stddev  33802.45419             33802.45419
#         standard error   2378.33238              2378.33238
#   99% confidence level   5532.00111              5532.00111
#                   skew     -0.50757                -0.50757
#               kurtosis     -0.85680                -0.85680
#       time correlation   -123.10336              -123.10336
#
#           elasped time    122.09959
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          363
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  3 160000.00000 |******                          161944.99183
#                  0 164000.00000 |                                           -
#                  6 168000.00000 |*************                   170155.76517
#                  5 172000.00000 |***********                     174337.55930
#                  2 176000.00000 |****                            177398.79450
#                  3 180000.00000 |******                          181329.99450
#                  5 184000.00000 |***********                     185846.09050
#                  3 188000.00000 |******                          190502.30383
#                  6 192000.00000 |*************                   193758.00517
#                  4 196000.00000 |*********                       198001.57850
#                  5 200000.00000 |***********                     201591.11450
#                  7 204000.00000 |****************                206170.69850
#                  2 208000.00000 |****                            211739.27450
#                  7 212000.00000 |****************                214256.42193
#                  2 216000.00000 |****                            217983.37050
#                  6 220000.00000 |*************                   221851.80783
#                  5 224000.00000 |***********                     225891.58170
#                  9 228000.00000 |********************            229410.77672
#                  9 232000.00000 |********************            233803.58028
#                  8 236000.00000 |******************              238212.28250
#                  5 240000.00000 |***********                     242228.60570
#                  5 244000.00000 |***********                     245293.00250
#                 11 248000.00000 |*************************       249786.27959
#                  8 252000.00000 |******************              253198.71450
#                 10 256000.00000 |**********************          258499.13370
#                 13 260000.00000 |*****************************   262010.11758
#                 10 264000.00000 |**********************          266320.63770
#                 14 268000.00000 |********************************269455.29736
#                 10 272000.00000 |**********************          273410.42970
#                  8 276000.00000 |******************              277980.68250
#
#                 11        > 95% |*************************       284036.20541
#
#        mean of 95% 233893.31714
#          95th %ile 279662.79450
 
# bin/file_lock -E -C 200 -L -S -W -N file_lock -I 1000 
             prc thr   usecs/call      samples   errors cnt/samp 
file_lock      1   1     82.74586          188        0      100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     73.74490                73.74490
#                    max    203.16570                98.79706
#                   mean     87.00953                83.39157
#                 median     83.17594                82.74586
#                 stddev     16.28284                 5.30881
#         standard error      1.14566                 0.38718
#   99% confidence level      2.66480                 0.90059
#                   skew      4.23270                 0.61759
#               kurtosis     21.38118                -0.02447
#       time correlation     -0.06298                -0.01130
#
#           elasped time      1.77697
#      number of samples          188
#     number of outliers           14
#      getnsecs overhead          358
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2     73.00000 |***                                 73.79610
#                  2     74.00000 |***                                 74.23130
#                  4     75.00000 |******                              75.53690
#                 10     76.00000 |****************                    76.70119
#                 15     77.00000 |************************            77.45229
#                  8     78.00000 |************                        78.50746
#                 10     79.00000 |****************                    79.40941
#                 15     80.00000 |************************            80.47156
#                 20     81.00000 |********************************    81.45472
#                 13     82.00000 |********************                82.47923
#                 12     83.00000 |*******************                 83.45477
#                 12     84.00000 |*******************                 84.54533
#                 13     85.00000 |********************                85.30980
#                  8     86.00000 |************                        86.24794
#                  6     87.00000 |*********                           87.46821
#                  7     88.00000 |***********                         88.59327
#                  8     89.00000 |************                        89.34458
#                  6     90.00000 |*********                           90.35290
#                  4     91.00000 |******                              91.45370
#                  3     92.00000 |****                                92.60954
#
#                 10        > 95% |****************                    95.95725
#
#        mean of 95%     82.68563
#          95th %ile     93.05754
 
# bin/getsockname -E -C 200 -L -S -W -N getsockname -I 100 
             prc thr   usecs/call      samples   errors cnt/samp 
getsockname    1   1      4.74727          181        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      4.67636                 4.67636
#                    max     10.30119                 4.91930
#                   mean      4.90949                 4.76128
#                 median      4.75623                 4.74727
#                 stddev      0.69431                 0.05452
#         standard error      0.04885                 0.00405
#   99% confidence level      0.11363                 0.00943
#                   skew      5.80890                 0.87038
#               kurtosis     35.31819                 0.11220
#       time correlation     -0.00153                 0.00013
#
#           elasped time      1.00761
#      number of samples          181
#     number of outliers           21
#      getnsecs overhead          764
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                171      4.00000 |********************************     4.75352
#
#                 10        > 95% |*                                    4.89390
#
#        mean of 95%      4.75352
#          95th %ile      4.86528
# bin/getpeername -E -C 200 -L -S -W -N getpeername -I 100 
             prc thr   usecs/call      samples   errors cnt/samp 
getpeername    1   1      4.99326          176        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      4.56599                 4.56599
#                    max     13.66398                 5.72618
#                   mean      5.34546                 5.02356
#                 median      5.03908                 4.99326
#                 stddev      1.13165                 0.25890
#         standard error      0.07962                 0.01952
#   99% confidence level      0.18520                 0.04539
#                   skew      4.55474                 0.38811
#               kurtosis     25.58049                -0.20992
#       time correlation      0.00067                 0.00205
#
#           elasped time      1.09769
#      number of samples          176
#     number of outliers           26
#      getnsecs overhead          793
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 91      4.00000 |********************************     4.82951
#                 76      5.00000 |**************************           5.18733
#
#                  9        > 95% |***                                  5.60262
#
#        mean of 95%      4.99235
#          95th %ile      5.52010
 
# bin/chdir -E -C 200 -L -S -W -N chdir_tmp -I 2000 /tmp/libmicro.2378/0/1/2/3/4/5/6/7/8/9 /tmp/libmicro.2378/1/2/3/4/5/6/7/8/9/0 
             prc thr   usecs/call      samples   errors cnt/samp  dirs  gets
chdir_tmp      1   1     39.85140          174        0       50     2     n
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     36.98932                36.98932
#                    max    134.93492                50.23476
#                   mean     44.71071                40.74249
#                 median     40.21492                39.85140
#                 stddev     11.88684                 3.41864
#         standard error      0.83635                 0.25917
#   99% confidence level      1.94536                 0.60282
#                   skew      3.38084                 0.79026
#               kurtosis     16.83562                -0.47630
#       time correlation     -0.05605                -0.00947
#
#           elasped time      0.46956
#      number of samples          174
#     number of outliers           28
#      getnsecs overhead          390
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     36.00000 |*                                   36.98932
#                 54     37.00000 |********************************    37.46994
#                 19     38.00000 |***********                         38.41807
#                 20     39.00000 |***********                         39.62279
#                 17     40.00000 |**********                          40.32786
#                  6     41.00000 |***                                 41.58879
#                  3     42.00000 |*                                   42.53940
#                 13     43.00000 |*******                             43.52953
#                 20     44.00000 |***********                         44.44020
#                  9     45.00000 |*****                               45.55906
#                  2     46.00000 |*                                   46.62004
#                  1     47.00000 |*                                   47.25492
#
#                  9        > 95% |*****                               48.72095
#
#        mean of 95%     40.30730
#          95th %ile     47.51092
# bin/chdir -E -C 200 -L -S -W -N chdir_usr -I 2000 /var/tmp/libmicro.2378/0/1/2/3/4/5/6/7/8/9 /var/tmp/libmicro.2378/1/2/3/4/5/6/7/8/9/0 
             prc thr   usecs/call      samples   errors cnt/samp  dirs  gets
chdir_usr      1   1     52.63608          189        0       50     2     n
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     48.43256                48.43256
#                    max    178.89016                62.75320
#                   mean     55.84242                53.34427
#                 median     53.09176                52.63608
#                 stddev     12.40465                 3.21440
#         standard error      0.87279                 0.23381
#   99% confidence level      2.03011                 0.54385
#                   skew      6.17557                 0.48488
#               kurtosis     50.18552                -0.80272
#       time correlation     -0.04462                 0.00494
#
#           elasped time      0.57983
#      number of samples          189
#     number of outliers           13
#      getnsecs overhead          388
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  9     48.00000 |*********                           48.73180
#                 17     49.00000 |*****************                   49.57854
#                 32     50.00000 |********************************    50.40168
#                 24     51.00000 |************************            51.61272
#                 19     52.00000 |*******************                 52.51428
#                 22     53.00000 |**********************              53.50974
#                  3     54.00000 |***                                 54.30349
#                 11     55.00000 |***********                         55.61127
#                 20     56.00000 |********************                56.51934
#                 18     57.00000 |******************                  57.46538
#                  4     58.00000 |****                                58.59064
#
#                 10        > 95% |**********                          60.03397
#
#        mean of 95%     52.97054
#          95th %ile     59.05656
 
# bin/chdir -E -C 200 -L -S -W -N chgetwd_tmp -I 3000 -g /tmp/libmicro.2378/0/1/2/3/4/5/6/7/8/9 /tmp/libmicro.2378/1/2/3/4/5/6/7/8/9/0 
             prc thr   usecs/call      samples   errors cnt/samp  dirs  gets
chgetwd_tmp    1   1     58.67073          180        0       33     2     y
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     54.79194                54.79194
#                    max    277.22491                75.82273
#                   mean     66.24155                60.30827
#                 median     59.01206                58.67073
#                 stddev     21.66522                 5.36574
#         standard error      1.52436                 0.39994
#   99% confidence level      3.54566                 0.93026
#                   skew      5.40299                 1.04781
#               kurtosis     43.52676                -0.12831
#       time correlation     -0.11376                -0.00650
#
#           elasped time      0.45569
#      number of samples          180
#     number of outliers           22
#      getnsecs overhead          762
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  3     54.00000 |**                                  54.83331
#                 31     55.00000 |*********************               55.63426
#                 47     56.00000 |********************************    56.34643
#                  4     57.00000 |**                                  57.40042
#                 16     58.00000 |**********                          58.68624
#                 14     59.00000 |*********                           59.37777
#                  7     60.00000 |****                                60.22224
#                  5     61.00000 |***                                 61.55965
#                  8     62.00000 |*****                               62.30903
#                  3     63.00000 |**                                  63.46232
#                  2     64.00000 |*                                   64.24842
#                  1     65.00000 |*                                   65.24915
#                  2     66.00000 |*                                   66.88600
#                 14     67.00000 |*********                           67.63294
#                  6     68.00000 |****                                68.48277
#                  5     69.00000 |***                                 69.57633
#                  3     70.00000 |**                                  70.32002
#
#                  9        > 95% |******                              72.87140
#
#        mean of 95%     59.64705
#          95th %ile     70.64067
# bin/chdir -E -C 200 -L -S -W -N chgetwd_usr -I 3000 -g /var/tmp/libmicro.2378/0/1/2/3/4/5/6/7/8/9 /var/tmp/libmicro.2378/1/2/3/4/5/6/7/8/9/0 
             prc thr   usecs/call      samples   errors cnt/samp  dirs  gets
chgetwd_usr    1   1     70.88106          194        0       33     2     y
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     64.55088                64.55088
#                    max    271.87985                87.69948
#                   mean     75.49252                71.69964
#                 median     71.24567                70.88106
#                 stddev     22.26338                 5.87244
#         standard error      1.56645                 0.42162
#   99% confidence level      3.64355                 0.98068
#                   skew      5.76634                 0.63885
#               kurtosis     38.54055                -0.67009
#       time correlation     -0.07919                 0.00927
#
#           elasped time      0.51971
#      number of samples          194
#     number of outliers            8
#      getnsecs overhead          765
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  6     64.00000 |*****                               64.79783
#                 34     65.00000 |********************************    65.48681
#                 29     66.00000 |***************************         66.40146
#                  5     67.00000 |****                                67.39481
#                  4     68.00000 |***                                 68.67403
#                 11     69.00000 |**********                          69.49739
#                  9     70.00000 |********                            70.67247
#                 17     71.00000 |****************                    71.46379
#                 11     72.00000 |**********                          72.38956
#                  6     73.00000 |*****                               73.55484
#                  8     74.00000 |*******                             74.38652
#                  0     75.00000 |                                           -
#                  7     76.00000 |******                              76.69481
#                  9     77.00000 |********                            77.43104
#                 11     78.00000 |**********                          78.58010
#                  8     79.00000 |*******                             79.26991
#                  3     80.00000 |**                                  80.19791
#                  5     81.00000 |****                                81.37861
#                  1     82.00000 |*                                   82.40106
#
#                 10        > 95% |*********                           84.67946
#
#        mean of 95%     70.99422
#          95th %ile     82.79670
 
# bin/realpath -E -C 200 -L -S -W -N realpath_tmp -I 3000 -f /tmp/libmicro.2378/0/1/2/3/4/5/6/7/8/9 
             prc thr   usecs/call      samples   errors cnt/samp 
realpath_tmp   1   1    350.76215          188        0       33 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    325.48797               325.48797
#                    max    778.83294               468.42906
#                   mean    382.39355               367.56729
#                 median    351.86373               350.76215
#                 stddev     67.48248                34.88619
#         standard error      4.74805                 2.54434
#   99% confidence level     11.04397                 5.91813
#                   skew      2.71613                 1.00055
#               kurtosis      9.22149                -0.29622
#       time correlation      0.44441                 0.36251
#
#           elasped time      2.56765
#      number of samples          188
#     number of outliers           14
#      getnsecs overhead          657
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    324.00000 |*                                  325.48797
#                  2    328.00000 |**                                 331.53888
#                 13    332.00000 |******************                 334.72724
#                 23    336.00000 |********************************   338.11528
#                 22    340.00000 |******************************     341.75384
#                 22    344.00000 |******************************     345.99653
#                 19    348.00000 |**************************         350.32936
#                  7    352.00000 |*********                          353.42189
#                  9    356.00000 |************                       357.78017
#                  4    360.00000 |*****                              362.41209
#                  3    364.00000 |****                               365.87908
#                  2    368.00000 |**                                 369.07003
#                  1    372.00000 |*                                  372.25839
#                  1    376.00000 |*                                  378.98421
#                  4    380.00000 |*****                              381.08458
#                  2    384.00000 |**                                 385.81476
#                  2    388.00000 |**                                 390.13185
#                  3    392.00000 |****                               393.28142
#                  3    396.00000 |****                               398.42470
#                  3    400.00000 |****                               402.72757
#                  5    404.00000 |******                             405.62993
#                  9    408.00000 |************                       410.04813
#                  4    412.00000 |*****                              415.28191
#                  3    416.00000 |****                               417.63763
#                  3    420.00000 |****                               421.55520
#                  5    424.00000 |******                             426.63745
#                  2    428.00000 |**                                 431.08797
#                  1    432.00000 |*                                  432.40288
#
#                 10        > 95% |*************                      448.39822
#
#        mean of 95%    363.02623
#          95th %ile    432.55803
# bin/realpath -E -C 200 -L -S -W -N realpath_usr -I 3000 -f /var/tmp/libmicro.2378/0/1/2/3/4/5/6/7/8/9 
             prc thr   usecs/call      samples   errors cnt/samp 
realpath_usr   1   1    489.25403          195        0       33 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    358.85694               358.85694
#                    max    933.37524               616.24555
#                   mean    461.10670               450.09244
#                 median    492.97767               489.25403
#                 stddev     89.29246                65.78160
#         standard error      6.28260                 4.71072
#   99% confidence level     14.61332                10.95713
#                   skew      1.78634                 0.08689
#               kurtosis      6.31525                -1.43075
#       time correlation      0.72819                 0.80776
#
#           elasped time      3.09269
#      number of samples          195
#     number of outliers            7
#      getnsecs overhead          793
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    354.00000 |*                                  358.85694
#                  2    360.00000 |**                                 364.09718
#                 13    366.00000 |****************                   368.75382
#                 23    372.00000 |*****************************      375.40115
#                 16    378.00000 |********************               381.24918
#                 14    384.00000 |*****************                  387.11557
#                  9    390.00000 |***********                        393.22041
#                  3    396.00000 |***                                398.63262
#                  3    402.00000 |***                                406.53241
#                  3    408.00000 |***                                412.69969
#                  2    414.00000 |**                                 418.10930
#                  2    420.00000 |**                                 425.02518
#                  0    426.00000 |                                           -
#                  3    432.00000 |***                                435.85605
#                  0    438.00000 |                                           -
#                  0    444.00000 |                                           -
#                  0    450.00000 |                                           -
#                  0    456.00000 |                                           -
#                  0    462.00000 |                                           -
#                  1    468.00000 |*                                  473.27342
#                  0    474.00000 |                                           -
#                  0    480.00000 |                                           -
#                  3    486.00000 |***                                488.90494
#                 25    492.00000 |********************************   495.61028
#                 22    498.00000 |****************************       500.39779
#                 18    504.00000 |***********************            507.10206
#                 11    510.00000 |**************                     512.40123
#                  4    516.00000 |*****                              517.86979
#                  0    522.00000 |                                           -
#                  3    528.00000 |***                                529.20037
#                  4    534.00000 |*****                              535.17888
#
#                 10        > 95% |************                       564.38848
#
#        mean of 95%    443.91427
#          95th %ile    536.03997
 
# bin/stat -E -C 200 -L -S -W -N stat_tmp -I 1000 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp 
stat_tmp       1   1     27.00314          180        0      100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     25.25722                25.25722
#                    max     86.44378                32.80666
#                   mean     30.02029                27.71985
#                 median     27.19514                27.00314
#                 stddev      7.89283                 1.93022
#         standard error      0.55534                 0.14387
#   99% confidence level      1.29172                 0.33464
#                   skew      3.74582                 0.87779
#               kurtosis     17.39885                -0.20834
#       time correlation      0.00812                -0.00331
#
#           elasped time      0.62464
#      number of samples          180
#     number of outliers           22
#      getnsecs overhead          486
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 37     25.00000 |**********************              25.67997
#                 53     26.00000 |********************************    26.59030
#                 26     27.00000 |***************                     27.30522
#                 13     28.00000 |*******                             28.47455
#                 24     29.00000 |**************                      29.51653
#                 15     30.00000 |*********                           30.39838
#                  3     31.00000 |*                                   31.22117
#
#                  9        > 95% |*****                               32.44314
#
#        mean of 95%     27.47126
#          95th %ile     31.67514
# bin/stat -E -C 200 -L -S -W -N stat_usr -I 1000 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp 
stat_usr       1   1     31.06177          177        0      100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     27.28065                27.28065
#                    max     99.86177                43.56225
#                   mean     36.52748                32.12969
#                 median     31.63009                31.06177
#                 stddev     13.58584                 4.05305
#         standard error      0.95590                 0.30465
#   99% confidence level      2.22341                 0.70861
#                   skew      2.69011                 1.13682
#               kurtosis      7.13812                 0.10745
#       time correlation      0.04099                 0.03096
#
#           elasped time      0.75325
#      number of samples          177
#     number of outliers           25
#      getnsecs overhead          895
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  7     27.00000 |*****                               27.55018
#                 32     28.00000 |**************************          28.56969
#                 38     29.00000 |********************************    29.51014
#                 10     30.00000 |********                            30.49243
#                 28     31.00000 |***********************             31.56435
#                 19     32.00000 |****************                    32.38947
#                  3     33.00000 |**                                  33.66102
#                  6     34.00000 |*****                               34.57622
#                  1     35.00000 |*                                   35.33185
#                  1     36.00000 |*                                   36.16897
#                  2     37.00000 |*                                   37.71649
#                 12     38.00000 |**********                          38.69057
#                  4     39.00000 |***                                 39.67361
#                  5     40.00000 |****                                40.27675
#
#                  9        > 95% |*******                             41.62490
#
#        mean of 95%     31.62102
#          95th %ile     40.56193
 
# bin/fcntl -E -C 200 -L -S -W -N fcntl_tmp -I 100 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp 
fcntl_tmp      1   1      1.98567          172        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      1.89249                 1.89249
#                    max      3.34862                 2.17460
#                   mean      2.07403                 1.98923
#                 median      2.00846                 1.98567
#                 stddev      0.24799                 0.06767
#         standard error      0.01745                 0.00516
#   99% confidence level      0.04059                 0.01200
#                   skew      2.95953                 0.74889
#               kurtosis      9.78895                -0.03457
#       time correlation     -0.00116                 0.00002
#
#           elasped time      0.43352
#      number of samples          172
#     number of outliers           30
#      getnsecs overhead          374
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 92      1.00000 |********************************     1.93657
#                 71      2.00000 |************************             2.03623
#
#                  9        > 95% |***                                  2.15682
#
#        mean of 95%      1.97998
#          95th %ile      2.13467
# bin/fcntl -E -C 200 -L -S -W -N fcntl_usr -I 100 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp 
fcntl_usr      1   1      1.99544          176        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      1.89227                 1.89227
#                    max      3.59646                 2.20843
#                   mean      2.10012                 1.99585
#                 median      2.00440                 1.99544
#                 stddev      0.30562                 0.07652
#         standard error      0.02150                 0.00577
#   99% confidence level      0.05002                 0.01342
#                   skew      2.54765                 0.65882
#               kurtosis      5.92917                -0.49297
#       time correlation      0.00032                -0.00019
#
#           elasped time      0.43734
#      number of samples          176
#     number of outliers           26
#      getnsecs overhead          596
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 97      1.00000 |********************************     1.93880
#                 70      2.00000 |***********************              2.05314
#
#                  9        > 95% |**                                   2.16522
#
#        mean of 95%      1.98673
#          95th %ile      2.13956
# bin/fcntl_ndelay -E -C 200 -L -S -W -N fcntl_ndelay -I 100 
             prc thr   usecs/call      samples   errors cnt/samp 
fcntl_ndelay   1   1      2.32144          184        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.21674                 2.21674
#                    max      7.91043                 2.48349
#                   mean      2.41962                 2.31195
#                 median      2.32656                 2.32144
#                 stddev      0.52944                 0.05787
#         standard error      0.03725                 0.00427
#   99% confidence level      0.08665                 0.00992
#                   skew      7.48368                 0.27518
#               kurtosis     66.14553                -0.75144
#       time correlation     -0.00220                -0.00010
#
#           elasped time      0.50566
#      number of samples          184
#     number of outliers           18
#      getnsecs overhead          480
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                174      2.00000 |********************************     2.30503
#
#                 10        > 95% |*                                    2.43252
#
#        mean of 95%      2.30503
#          95th %ile      2.40362
 
# bin/lseek -E -C 200 -L -S -W -N lseek_t8k -s 8k -I 50 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
lseek_t8k      1   1      1.66657          181        0     2000     8192
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      1.61255                 1.61255
#                    max      4.50253                 1.72967
#                   mean      1.76312                 1.66748
#                 median      1.66810                 1.66657
#                 stddev      0.40691                 0.02225
#         standard error      0.02863                 0.00165
#   99% confidence level      0.06659                 0.00385
#                   skew      5.24391                -0.08768
#               kurtosis     29.24816                 0.24168
#       time correlation     -0.00125                -0.00005
#
#           elasped time      0.72945
#      number of samples          181
#     number of outliers           21
#      getnsecs overhead          754
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                171      1.00000 |********************************     1.66480
#
#                 10        > 95% |*                                    1.71336
#
#        mean of 95%      1.66480
#          95th %ile      1.70254
# bin/lseek -E -C 200 -L -S -W -N lseek_u8k -s 8k -I 50 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
lseek_u8k      1   1      1.66720          184        0     2000     8192
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      1.59258                 1.59258
#                    max      4.58509                 1.74964
#                   mean      1.74561                 1.66747
#                 median      1.67015                 1.66720
#                 stddev      0.34846                 0.02782
#         standard error      0.02452                 0.00205
#   99% confidence level      0.05703                 0.00477
#                   skew      5.57257                 0.32698
#               kurtosis     33.88671                 0.06981
#       time correlation     -0.00085                -0.00005
#
#           elasped time      0.72136
#      number of samples          184
#     number of outliers           18
#      getnsecs overhead          760
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                174      1.00000 |********************************     1.66395
#
#                 10        > 95% |*                                    1.72880
#
#        mean of 95%      1.66395
#          95th %ile      1.71674
 
# bin/open -E -C 200 -L -S -W -N open_tmp -B 256 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp 
open_tmp       1   1     62.93588          181        0      256 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     51.59988                51.59988
#                    max    141.25988                87.52088
#                   mean     69.22935                64.29032
#                 median     63.61188                62.93588
#                 stddev     17.06928                 7.85207
#         standard error      1.20099                 0.58364
#   99% confidence level      2.79350                 1.35755
#                   skew      2.18672                 1.13826
#               kurtosis      4.71602                 0.84831
#       time correlation     -0.03480                -0.02162
#
#           elasped time      4.08428
#      number of samples          181
#     number of outliers           21
#      getnsecs overhead          542
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     50.00000 |*                                   51.59988
#                  4     52.00000 |****                                52.78963
#                 10     54.00000 |***********                         55.26098
#                 23     56.00000 |*************************           57.11784
#                 24     58.00000 |**************************          59.18201
#                 18     60.00000 |*******************                 60.77377
#                 29     62.00000 |********************************    63.13540
#                 21     64.00000 |***********************             64.90836
#                  8     66.00000 |********                            66.85813
#                  9     68.00000 |*********                           68.72277
#                  5     70.00000 |*****                               70.55348
#                  7     72.00000 |*******                             73.08688
#                  3     74.00000 |***                                 74.36888
#                  4     76.00000 |****                                77.21963
#                  3     78.00000 |***                                 79.46055
#                  2     80.00000 |**                                  81.46038
#
#                 10        > 95% |***********                         84.81388
#
#        mean of 95%     63.09012
#          95th %ile     81.68188
# bin/open -E -C 200 -L -S -W -N open_usr -B 256 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp 
open_usr       1   1     65.61903          190        0      256 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     52.18903                52.18903
#                    max    166.70503               102.81803
#                   mean     71.73784                68.39355
#                 median     65.98603                65.61903
#                 stddev     18.22140                11.94418
#         standard error      1.28205                 0.86652
#   99% confidence level      2.98206                 2.01553
#                   skew      2.08644                 1.03951
#               kurtosis      5.59503                 0.34081
#       time correlation     -0.07447                -0.04281
#
#           elasped time      4.23415
#      number of samples          190
#     number of outliers           12
#      getnsecs overhead          504
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 11     52.00000 |****************                    53.20294
#                  7     54.00000 |**********                          55.07446
#                 10     56.00000 |***************                     56.92193
#                 21     58.00000 |********************************    58.95622
#                 21     60.00000 |********************************    60.94241
#                 18     62.00000 |***************************         62.92303
#                 14     64.00000 |*********************               65.39025
#                 19     66.00000 |****************************        66.95335
#                  7     68.00000 |**********                          68.81775
#                  6     70.00000 |*********                           71.51170
#                  7     72.00000 |**********                          73.01975
#                  9     74.00000 |*************                       75.02581
#                  2     76.00000 |***                                 77.32403
#                  4     78.00000 |******                              79.13278
#                  2     80.00000 |***                                 81.47853
#                  5     82.00000 |*******                             82.75183
#                  6     84.00000 |*********                           84.60936
#                  5     86.00000 |*******                             86.77223
#                  3     88.00000 |****                                88.94036
#                  2     90.00000 |***                                 91.59353
#                  1     92.00000 |*                                   93.17403
#
#                 10        > 95% |***************                     98.69793
#
#        mean of 95%     66.70998
#          95th %ile     95.24403
# bin/open -E -C 200 -L -S -W -N open_zero -B 256 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp 
open_zero      1   1     59.86966          188        0      256 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     49.16666                49.16666
#                    max    158.92366                88.60766
#                   mean     65.47858                62.49423
#                 median     60.71366                59.86966
#                 stddev     14.62934                 9.03718
#         standard error      1.02932                 0.65910
#   99% confidence level      2.39419                 1.53308
#                   skew      2.31152                 0.91199
#               kurtosis      8.36517                -0.01496
#       time correlation      0.01988                -0.01654
#
#           elasped time      3.87903
#      number of samples          188
#     number of outliers           14
#      getnsecs overhead          343
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2     48.00000 |**                                  49.27616
#                 12     50.00000 |************                        50.88924
#                  8     52.00000 |********                            53.21041
#                 32     54.00000 |********************************    55.29969
#                 20     56.00000 |********************                56.96806
#                 21     58.00000 |*********************               58.98718
#                 19     60.00000 |*******************                 61.01334
#                 15     62.00000 |***************                     63.02679
#                  5     64.00000 |*****                               64.83586
#                  6     66.00000 |******                              66.98499
#                  8     68.00000 |********                            68.93879
#                  7     70.00000 |*******                             70.52180
#                  5     72.00000 |*****                               73.32906
#                  9     74.00000 |*********                           74.97177
#                  1     76.00000 |*                                   76.38166
#                  7     78.00000 |*******                             78.93009
#                  1     80.00000 |*                                   80.19366
#
#                 10        > 95% |**********                          83.99426
#
#        mean of 95%     61.28637
#          95th %ile     80.39766
 
# bin/dup -E -C 200 -L -S -W -N dup -B 512 
             prc thr   usecs/call      samples   errors cnt/samp 
dup            1   1      1.84280          175        0      512 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      1.79030                 1.79030
#                    max      4.47780                 2.06780
#                   mean      1.96367                 1.87356
#                 median      1.84680                 1.84280
#                 stddev      0.32137                 0.06647
#         standard error      0.02261                 0.00503
#   99% confidence level      0.05259                 0.01169
#                   skew      4.65433                 1.48715
#               kurtosis     26.34983                 0.87761
#       time correlation     -0.00082                -0.00022
#
#           elasped time      0.42397
#      number of samples          175
#     number of outliers           27
#      getnsecs overhead          359
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                158      1.00000 |********************************     1.85687
#                  8      2.00000 |*                                    2.00992
#
#                  9        > 95% |*                                    2.04535
#
#        mean of 95%      1.86425
#          95th %ile      2.02680
 
# bin/socket -E -C 200 -L -S -W -N socket_u -B 256 
             prc thr   usecs/call      samples   errors cnt/samp 
socket_u       1   1    115.19714          200        0      256 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     84.08314                84.08314
#                    max    197.10414               178.99414
#                   mean    120.00834               119.27948
#                 median    115.41614               115.19714
#                 stddev     21.95875                20.80696
#         standard error      1.54501                 1.47127
#   99% confidence level      3.59370                 3.42218
#                   skew      1.04740                 0.91391
#               kurtosis      0.83854                 0.39416
#       time correlation     -0.05901                -0.06232
#
#           elasped time      8.46495
#      number of samples          200
#     number of outliers            2
#      getnsecs overhead          476
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2     84.00000 |***                                 84.93114
#                  4     87.00000 |******                              88.90039
#                  5     90.00000 |********                            91.98534
#                 10     93.00000 |****************                    94.63594
#                  4     96.00000 |******                              98.09889
#                 16     99.00000 |**************************         100.83864
#                 19    102.00000 |********************************   103.41982
#                  6    105.00000 |**********                         106.67447
#                  8    108.00000 |*************                      109.67764
#                 18    111.00000 |******************************     112.05336
#                 18    114.00000 |******************************     115.24203
#                 18    117.00000 |******************************     118.50959
#                  3    120.00000 |*****                              120.82681
#                  6    123.00000 |**********                         124.46864
#                  9    126.00000 |***************                    127.86647
#                  7    129.00000 |***********                        130.83514
#                  7    132.00000 |***********                        133.38343
#                  9    135.00000 |***************                    136.40936
#                  5    138.00000 |********                           139.42854
#                  0    141.00000 |                                           -
#                  1    144.00000 |*                                  145.09114
#                  5    147.00000 |********                           147.98714
#                  2    150.00000 |***                                152.12564
#                  2    153.00000 |***                                154.52564
#                  3    156.00000 |*****                              157.63647
#                  2    159.00000 |***                                160.35114
#                  1    162.00000 |*                                  163.56514
#
#                 10        > 95% |****************                   172.14444
#
#        mean of 95%    116.49711
#          95th %ile    164.77914
# bin/socket -E -C 200 -L -S -W -N socket_i -B 256 -f PF_INET 
             prc thr   usecs/call      samples   errors cnt/samp 
socket_i       1   1    117.76757          200        0      256 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     94.38957                94.38957
#                    max    215.49857               180.43957
#                   mean    126.70792               125.96967
#                 median    118.04157               117.76757
#                 stddev     20.51102                19.16651
#         standard error      1.44315                 1.35528
#   99% confidence level      3.35677                 3.15237
#                   skew      1.25733                 1.02945
#               kurtosis      1.36288                 0.18141
#       time correlation      0.00363                -0.00472
#
#           elasped time      9.19784
#      number of samples          200
#     number of outliers            2
#      getnsecs overhead          366
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     93.00000 |*                                   94.38957
#                  2     96.00000 |*                                   97.05157
#                  2     99.00000 |*                                  101.51407
#                  2    102.00000 |*                                  102.73057
#                  6    105.00000 |*****                              106.89724
#                 25    108.00000 |**********************             109.73553
#                 35    111.00000 |********************************   112.41243
#                 21    114.00000 |*******************                115.34443
#                 16    117.00000 |**************                     118.17051
#                  7    120.00000 |******                             121.21100
#                  6    123.00000 |*****                              124.70574
#                 11    126.00000 |**********                         127.26475
#                  8    129.00000 |*******                            130.62945
#                  7    132.00000 |******                             133.89586
#                  2    135.00000 |*                                  136.28357
#                  2    138.00000 |*                                  139.87757
#                  4    141.00000 |***                                142.95157
#                  5    144.00000 |****                               146.14157
#                  7    147.00000 |******                             148.97828
#                 10    150.00000 |*********                          151.38097
#                  5    153.00000 |****                               154.71557
#                  5    156.00000 |****                               156.91737
#                  0    159.00000 |                                           -
#                  0    162.00000 |                                           -
#                  1    165.00000 |*                                  165.68957
#
#                 10        > 95% |*********                          175.05047
#
#        mean of 95%    123.38647
#          95th %ile    167.52957
 
# bin/socketpair -E -C 200 -L -S -W -N socketpair -B 256 
             prc thr   usecs/call      samples   errors cnt/samp 
socketpair     1   1    216.49715          196        0      256 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    156.62315               156.62315
#                    max    426.92715               341.87115
#                   mean    228.17830               223.28826
#                 median    223.51115               216.49715
#                 stddev     48.48759                40.01737
#         standard error      3.41158                 2.85838
#   99% confidence level      7.93532                 6.64860
#                   skew      1.24162                 0.59754
#               kurtosis      2.02616                -0.21682
#       time correlation     -0.15930                -0.10233
#
#           elasped time      8.17700
#      number of samples          196
#     number of outliers            6
#      getnsecs overhead          365
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    155.00000 |*                                  156.62315
#                  7    160.00000 |************                       162.61401
#                  3    165.00000 |*****                              167.24515
#                  5    170.00000 |********                           171.82595
#                  6    175.00000 |**********                         177.65482
#                 11    180.00000 |*******************                183.06515
#                 13    185.00000 |***********************            187.30838
#                 13    190.00000 |***********************            192.43638
#                 14    195.00000 |************************           197.85743
#                 12    200.00000 |*********************              202.70348
#                  7    205.00000 |************                       208.03943
#                  6    210.00000 |**********                         211.98748
#                  3    215.00000 |*****                              217.70582
#                  5    220.00000 |********                           224.20475
#                  8    225.00000 |**************                     228.04240
#                  6    230.00000 |**********                         232.66348
#                  5    235.00000 |********                           237.40315
#                  9    240.00000 |****************                   242.05604
#                  6    245.00000 |**********                         248.68215
#                 18    250.00000 |********************************   252.03059
#                  5    255.00000 |********                           257.33595
#                  6    260.00000 |**********                         263.21682
#                  6    265.00000 |**********                         268.65882
#                  3    270.00000 |*****                              274.24715
#                  2    275.00000 |***                                279.20015
#                  3    280.00000 |*****                              281.11782
#                  0    285.00000 |                                           -
#                  1    290.00000 |*                                  290.25515
#                  0    295.00000 |                                           -
#                  2    300.00000 |***                                302.42215
#
#                 10        > 95% |*****************                  317.55855
#
#        mean of 95%    218.21997
#          95th %ile    304.11515
 
# bin/setsockopt -E -C 200 -L -S -W -N setsockopt -I 200 
             prc thr   usecs/call      samples   errors cnt/samp 
setsockopt     1   1      4.70226          183        0      500 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      4.44063                 4.44063
#                    max     16.35436                 5.32690
#                   mean      5.12226                 4.70712
#                 median      4.76473                 4.70226
#                 stddev      1.51359                 0.21555
#         standard error      0.10650                 0.01593
#   99% confidence level      0.24771                 0.03706
#                   skew      4.03387                 0.39128
#               kurtosis     18.80983                -0.98004
#       time correlation     -0.00019                -0.00022
#
#           elasped time      0.60250
#      number of samples          183
#     number of outliers           19
#      getnsecs overhead          741
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                171      4.00000 |********************************     4.67840
#                  2      5.00000 |*                                    5.01049
#
#                 10        > 95% |*                                    5.13741
#
#        mean of 95%      4.68224
#          95th %ile      5.03250
 
# bin/bind -E -C 200 -L -S -W -N bind -B 100 
             prc thr   usecs/call      samples   errors cnt/samp 
bind           1   1     29.74657          175        0      100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     25.68385                25.68385
#                    max     63.79457                40.51393
#                   mean     33.42618                30.72547
#                 median     31.21345                29.74657
#                 stddev      8.00248                 3.26512
#         standard error      0.56305                 0.24682
#   99% confidence level      1.30966                 0.57410
#                   skew      2.03038                 0.78016
#               kurtosis      3.76195                -0.03166
#       time correlation     -0.00225                 0.00090
#
#           elasped time     10.91660
#      number of samples          175
#     number of outliers           27
#      getnsecs overhead          575
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  3     25.00000 |**                                  25.81441
#                 10     26.00000 |********                            26.68302
#                 25     27.00000 |*********************               27.50483
#                 38     28.00000 |********************************    28.54856
#                 18     29.00000 |***************                     29.56737
#                  4     30.00000 |***                                 30.49473
#                 17     31.00000 |**************                      31.44987
#                 17     32.00000 |**************                      32.56332
#                 16     33.00000 |*************                       33.48737
#                 10     34.00000 |********                            34.69428
#                  5     35.00000 |****                                35.47227
#                  3     36.00000 |**                                  36.33430
#
#                  9        > 95% |*******                             38.74412
#
#        mean of 95%     30.29072
#          95th %ile     36.88385
 
# bin/listen -E -C 200 -L -S -W -N listen -B 100 
             prc thr   usecs/call      samples   errors cnt/samp 
listen         1   1      3.08605          193        0      100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.95549                 2.95549
#                    max      7.71709                 5.23645
#                   mean      3.59299                 3.46321
#                 median      3.09629                 3.08605
#                 stddev      0.88023                 0.63768
#         standard error      0.06193                 0.04590
#   99% confidence level      0.14405                 0.10677
#                   skew      1.88382                 1.09864
#               kurtosis      4.05526                -0.21029
#       time correlation      0.00148                 0.00164
#
#           elasped time      0.08759
#      number of samples          193
#     number of outliers            9
#      getnsecs overhead          387
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 68      2.00000 |**************************           2.98523
#                 83      3.00000 |********************************     3.30640
#                 32      4.00000 |************                         4.42261
#
#                 10        > 95% |***                                  4.94487
#
#        mean of 95%      3.38224
#          95th %ile      4.70653
 
# bin/connection -E -C 200 -L -S -W -N connection -B 256 
             prc thr   usecs/call      samples   errors cnt/samp 
connection     1   1    618.03316          192        0      256 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    496.81816               496.81816
#                    max   1570.29516               791.09616
#                   mean    643.60645               617.75668
#                 median    622.13116               618.03316
#                 stddev    138.61897                62.83679
#         standard error      9.75320                 4.53485
#   99% confidence level     22.68594                10.54807
#                   skew      3.71189                 0.40754
#               kurtosis     17.59645                -0.40783
#       time correlation     -0.69678                -0.37872
#
#           elasped time     71.27261
#      number of samples          192
#     number of outliers           10
#      getnsecs overhead          470
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    496.00000 |**                                 496.81816
#                  3    504.00000 |******                             507.92650
#                  2    512.00000 |****                               516.99416
#                  4    520.00000 |********                           525.25791
#                  4    528.00000 |********                           531.88566
#                  5    536.00000 |**********                         538.80776
#                 13    544.00000 |***************************        547.57070
#                 10    552.00000 |*********************              556.03926
#                  9    560.00000 |*******************                564.61150
#                  4    568.00000 |********                           573.79691
#                 15    576.00000 |********************************   580.21103
#                  8    584.00000 |*****************                  587.09779
#                  6    592.00000 |************                       596.58966
#                  2    600.00000 |****                               602.36316
#                  9    608.00000 |*******************                610.94661
#                  8    616.00000 |*****************                  619.83791
#                  9    624.00000 |*******************                627.03872
#                 14    632.00000 |*****************************      635.82309
#                 11    640.00000 |***********************            644.02962
#                  6    648.00000 |************                       651.26466
#                  4    656.00000 |********                           660.78716
#                  5    664.00000 |**********                         669.23736
#                  2    672.00000 |****                               674.33416
#                  8    680.00000 |*****************                  683.38054
#                  4    688.00000 |********                           689.34516
#                  8    696.00000 |*****************                  699.17304
#                  5    704.00000 |**********                         707.93716
#                  1    712.00000 |**                                 715.80316
#                  2    720.00000 |****                               721.46516
#
#                 10        > 95% |*********************              754.41276
#
#        mean of 95%    610.24810
#          95th %ile    722.29116
 
# bin/poll -E -C 200 -L -S -W -N poll_10 -n 10 -I 500 
             prc thr   usecs/call      samples   errors cnt/samp     nfds flags
poll_10        1   1      7.19305          196        0      200       10   ---
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      6.95753                 6.95753
#                    max     12.77257                 8.16841
#                   mean      7.40439                 7.34124
#                 median      7.23785                 7.19305
#                 stddev      0.54029                 0.29942
#         standard error      0.03801                 0.02139
#   99% confidence level      0.08842                 0.04975
#                   skew      5.58556                 0.81276
#               kurtosis     48.23376                -0.43728
#       time correlation      0.00087                 0.00072
#
#           elasped time      0.31262
#      number of samples          196
#     number of outliers            6
#      getnsecs overhead          366
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  4      6.00000 |*                                    6.98185
#                182      7.00000 |********************************     7.31049
#
#                 10        > 95% |*                                    8.04476
#
#        mean of 95%      7.30342
#          95th %ile      7.95337
# bin/poll -E -C 200 -L -S -W -N poll_100 -n 100 -I 1000 
             prc thr   usecs/call      samples   errors cnt/samp     nfds flags
poll_100       1   1     64.64300          193        0        1      100   ---
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     50.56300                50.56300
#                    max    460.67500               128.64300
#                   mean     77.74716                71.05361
#                 median     64.64300                64.64300
#                 stddev     43.91242                19.32846
#         standard error      3.08967                 1.39129
#   99% confidence level      7.18657                 3.23615
#                   skew      5.47209                 1.23087
#               kurtosis     38.50382                 0.52614
#       time correlation     -0.18302                -0.13621
#
#           elasped time      0.03141
#      number of samples          193
#     number of outliers            9
#      getnsecs overhead          381
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 12     48.00000 |*******                             50.64833
#                 28     51.00000 |****************                    52.16300
#                  7     54.00000 |****                                55.90243
#                  1     57.00000 |*                                   57.73100
#                 12     60.00000 |*******                             62.63767
#                 53     63.00000 |********************************    64.28074
#                 20     66.00000 |************                        67.42060
#                  8     69.00000 |****                                70.37100
#                  4     72.00000 |**                                  72.89900
#                  2     75.00000 |*                                   76.67500
#                  2     78.00000 |*                                   79.61900
#                  4     81.00000 |**                                  82.11500
#                  3     84.00000 |*                                   85.29367
#                  3     87.00000 |*                                   89.30433
#                  1     90.00000 |*                                   91.52300
#                  3     93.00000 |*                                   94.25367
#                  2     96.00000 |*                                   98.05100
#                  1     99.00000 |*                                   99.71500
#                  4    102.00000 |**                                 104.13100
#                  7    105.00000 |****                               106.04186
#                  6    108.00000 |***                                109.61367
#
#                 10        > 95% |******                             118.30060
#
#        mean of 95%     68.47181
#          95th %ile    111.49100
# bin/poll -E -C 200 -L -S -W -N poll_1000 -n 1000 -I 5000 
             prc thr   usecs/call      samples   errors cnt/samp     nfds flags
poll_1000      1   1    469.63100          138        0        1     1000   ---
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    456.57500               456.57500
#                    max   1637.75900               492.67100
#                   mean    580.72613               469.28039
#                 median    473.72700               469.63100
#                 stddev    235.99407                 7.80175
#         standard error     16.60449                 0.66413
#   99% confidence level     38.62203                 1.54476
#                   skew      2.63174                 0.61089
#               kurtosis      6.87638                 0.20598
#       time correlation     -1.95706                -0.00837
#
#           elasped time      0.13481
#      number of samples          138
#     number of outliers           64
#      getnsecs overhead          385
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    456.00000 |*****                              456.57500
#                  4    457.00000 |***********                        457.59900
#                  4    458.00000 |***********                        458.62300
#                  5    459.00000 |**************                     459.49340
#                  6    460.00000 |*****************                  460.62833
#                 11    461.00000 |********************************   461.53209
#                  7    462.00000 |********************               462.60929
#                  5    463.00000 |**************                     463.69180
#                  5    464.00000 |**************                     464.51100
#                  5    465.00000 |**************                     465.53500
#                  2    466.00000 |*****                              466.55900
#                  2    467.00000 |*****                              467.58300
#                  6    468.00000 |*****************                  468.60700
#                 10    469.00000 |*****************************      469.63100
#                  9    470.00000 |**************************         470.62656
#                  5    471.00000 |**************                     471.62780
#                  9    472.00000 |**************************         472.56078
#                  6    473.00000 |*****************                  473.55633
#                  8    474.00000 |***********************            474.59100
#                  7    475.00000 |********************               475.66529
#                  3    476.00000 |********                           476.62833
#                  4    477.00000 |***********                        477.56700
#                  2    478.00000 |*****                              478.59100
#                  1    479.00000 |**                                 479.61500
#                  1    480.00000 |**                                 480.63900
#                  0    481.00000 |                                           -
#                  0    482.00000 |                                           -
#                  1    483.00000 |**                                 483.45500
#                  1    484.00000 |**                                 484.47900
#
#                  7        > 95% |********************               488.75786
#
#        mean of 95%    468.23961
#          95th %ile    484.73500
 
# bin/poll -E -C 200 -L -S -W -N poll_w10 -n 10 -I 500 -w 1 
             prc thr   usecs/call      samples   errors cnt/samp     nfds flags
poll_w10       1   1      7.18729          150        0      200       10   -w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      7.01194                 7.01194
#                    max     45.39785                 8.29706
#                   mean      8.82058                 7.34547
#                 median      7.46761                 7.18729
#                 stddev      3.64814                 0.31816
#         standard error      0.25668                 0.02598
#   99% confidence level      0.59704                 0.06042
#                   skew      5.60591                 0.99996
#               kurtosis     48.45520                -0.02704
#       time correlation     -0.00193                -0.00002
#
#           elasped time      0.37288
#      number of samples          150
#     number of outliers           52
#      getnsecs overhead          493
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                142      7.00000 |********************************     7.30194
#
#                  8        > 95% |*                                    8.11818
#
#        mean of 95%      7.30194
#          95th %ile      7.99754
# bin/poll -E -C 200 -L -S -W -N poll_w100 -n 100 -I 2000 -w 10 
             prc thr   usecs/call      samples   errors cnt/samp     nfds flags
poll_w100      1   1     53.85248          186        0       50      100   -w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     49.57216                49.57216
#                    max    166.85088                65.09088
#                   mean     57.81462                55.04781
#                 median     54.41056                53.85248
#                 stddev     12.44616                 3.80552
#         standard error      0.87571                 0.27903
#   99% confidence level      2.03690                 0.64903
#                   skew      5.09076                 0.67879
#               kurtosis     33.89556                -0.45829
#       time correlation     -0.00731                -0.01050
#
#           elasped time      0.59860
#      number of samples          186
#     number of outliers           16
#      getnsecs overhead          496
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     49.00000 |*                                   49.57216
#                 27     50.00000 |*****************************       50.62479
#                 21     51.00000 |***********************             51.35611
#                 18     52.00000 |*******************                 52.52498
#                 29     53.00000 |********************************    53.50202
#                 12     54.00000 |*************                       54.49205
#                  7     55.00000 |*******                             55.19319
#                 11     56.00000 |************                        56.58516
#                 14     57.00000 |***************                     57.53851
#                 14     58.00000 |***************                     58.28384
#                 11     59.00000 |************                        59.42723
#                  5     60.00000 |*****                               60.43885
#                  6     61.00000 |******                              61.49067
#
#                 10        > 95% |***********                         63.79194
#
#        mean of 95%     54.55098
#          95th %ile     62.09056
# bin/poll -E -C 200 -L -S -W -N poll_w1000 -n 1000 -I 40000 -w 100 
             prc thr   usecs/call      samples   errors cnt/samp     nfds flags
poll_w1000     1   1    463.39300          194        0        1     1000   -w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    445.47300               445.47300
#                    max   3199.52100              1125.40900
#                   mean    601.32377               565.78508
#                 median    464.41700               463.39300
#                 stddev    285.43176               186.66202
#         standard error     20.08291                13.40155
#   99% confidence level     46.71285                31.17201
#                   skew      4.36492                 1.61448
#               kurtosis     32.31282                 1.15279
#       time correlation     -2.69784                -1.91554
#
#           elasped time      0.14026
#      number of samples          194
#     number of outliers            8
#      getnsecs overhead          479
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 75    440.00000 |********************************   451.94468
#                 48    460.00000 |********************               466.76900
#                  5    480.00000 |**                                 483.36100
#                  0    500.00000 |                                           -
#                  3    520.00000 |*                                  534.81700
#                  5    540.00000 |**                                 548.69220
#                  2    560.00000 |*                                  572.06500
#                  6    580.00000 |**                                 592.11833
#                  7    600.00000 |**                                 608.10614
#                  8    620.00000 |***                                630.43300
#                  1    640.00000 |*                                  659.48900
#                  0    660.00000 |                                           -
#                  1    680.00000 |*                                  692.51300
#                  1    700.00000 |*                                  711.71300
#                  0    720.00000 |                                           -
#                  0    740.00000 |                                           -
#                  0    760.00000 |                                           -
#                  1    780.00000 |*                                  790.56100
#                  1    800.00000 |*                                  802.59300
#                  4    820.00000 |*                                  830.68900
#                  2    840.00000 |*                                  853.02500
#                  0    860.00000 |                                           -
#                  0    880.00000 |                                           -
#                  1    900.00000 |*                                  909.60100
#                  1    920.00000 |*                                  933.40900
#                  3    940.00000 |*                                  954.40100
#                  3    960.00000 |*                                  969.84633
#                  5    980.00000 |**                                 988.70500
#                  1   1000.00000 |*                                 1007.39300
#
#                 10        > 95% |****                              1044.74340
#
#        mean of 95%    539.75474
#          95th %ile   1008.41700
 
# bin/select -E -C 200 -L -S -W -N select_10 -n 10 -I 500 
             prc thr   usecs/call      samples   errors cnt/samp    maxfd flags
select_10      1   1     11.13703          187        0      200       10   ---
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     10.63016                10.63016
#                    max     35.79624                12.20711
#                   mean     11.73171                11.10817
#                 median     11.18056                11.13703
#                 stddev      2.82118                 0.36794
#         standard error      0.19850                 0.02691
#   99% confidence level      0.46171                 0.06258
#                   skew      5.56949                 0.69154
#               kurtosis     35.58210                -0.20776
#       time correlation     -0.01545                -0.00007
#
#           elasped time      0.49908
#      number of samples          187
#     number of outliers           15
#      getnsecs overhead          817
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 82     10.00000 |***************************         10.75915
#                 95     11.00000 |********************************    11.31853
#
#                 10        > 95% |***                                 11.97172
#
#        mean of 95%     11.05938
#          95th %ile     11.80519
# bin/select -E -C 200 -L -S -W -N select_100 -n 100 -I 1000 
             prc thr   usecs/call      samples   errors cnt/samp    maxfd flags
select_100     1   1     39.94304          164        0      100      100   ---
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     39.14176                39.14176
#                    max    131.73952                42.01152
#                   mean     43.18638                40.14213
#                 median     40.15040                39.94304
#                 stddev      9.69856                 0.64415
#         standard error      0.68239                 0.05030
#   99% confidence level      1.58723                 0.11700
#                   skew      5.29020                 1.17160
#               kurtosis     36.95841                 0.86060
#       time correlation     -0.00794                 0.00265
#
#           elasped time      0.88604
#      number of samples          164
#     number of outliers           38
#      getnsecs overhead          832
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 89     39.00000 |********************************    39.70280
#                 52     40.00000 |******************                  40.31340
#                 14     41.00000 |*****                               41.21353
#
#                  9        > 95% |***                                 41.83033
#
#        mean of 95%     40.04410
#          95th %ile     41.54048
# bin/select -E -C 200 -L -S -W -N select_1000 -n 1000 -I 5000 
             prc thr   usecs/call      samples   errors cnt/samp    maxfd flags
select_1000    1   1    481.07680          162        0       20     1000   ---
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    470.92640               470.92640
#                    max    981.56960               500.46880
#                   mean    503.18677               481.90603
#                 median    483.07360               481.07680
#                 stddev     61.66745                 6.30162
#         standard error      4.33891                 0.49510
#   99% confidence level     10.09230                 1.15161
#                   skew      4.15694                 0.64823
#               kurtosis     21.91380                -0.02732
#       time correlation     -0.13486                -0.00171
#
#           elasped time      2.04962
#      number of samples          162
#     number of outliers           40
#      getnsecs overhead          480
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    470.00000 |**                                 470.92640
#                  4    471.00000 |*********                          471.64960
#                  2    472.00000 |****                               472.60320
#                  4    473.00000 |*********                          473.62400
#                 12    474.00000 |***************************        474.45813
#                  7    475.00000 |****************                   475.61669
#                  8    476.00000 |******************                 476.50720
#                  8    477.00000 |******************                 477.58400
#                 14    478.00000 |********************************   478.46560
#                 10    479.00000 |**********************             479.51520
#                 10    480.00000 |**********************             480.44960
#                  9    481.00000 |********************               481.42809
#                 11    482.00000 |*************************          482.40567
#                 10    483.00000 |**********************             483.35520
#                  7    484.00000 |****************                   484.39200
#                 10    485.00000 |**********************             485.45056
#                  3    486.00000 |******                             486.78133
#                  2    487.00000 |****                               487.42560
#                  6    488.00000 |*************                      488.56907
#                  4    489.00000 |*********                          489.38400
#                  6    490.00000 |*************                      490.39307
#                  1    491.00000 |**                                 491.88000
#                  2    492.00000 |****                               492.55200
#                  2    493.00000 |****                               493.37760
#
#                  9        > 95% |********************               496.60889
#
#        mean of 95%    481.04116
#          95th %ile    493.77440
 
# bin/select -E -C 200 -L -S -W -N select_w10 -n 10 -I 500 -w 1 
             prc thr   usecs/call      samples   errors cnt/samp    maxfd flags
select_w10     1   1     11.58856          187        0      200       10   -w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     11.07784                11.07784
#                    max     30.81800                12.67784
#                   mean     11.88910                11.61686
#                 median     11.62824                11.58856
#                 stddev      1.56057                 0.38809
#         standard error      0.10980                 0.02838
#   99% confidence level      0.25540                 0.06601
#                   skew      9.18712                 0.80358
#               kurtosis    105.02262                -0.09804
#       time correlation      0.00285                -0.00048
#
#           elasped time      0.49359
#      number of samples          187
#     number of outliers           15
#      getnsecs overhead          368
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                155     11.00000 |********************************    11.47710
#                 22     12.00000 |****                                12.18231
#
#                 10        > 95% |**                                  12.53909
#
#        mean of 95%     11.56475
#          95th %ile     12.37832
# bin/select -E -C 200 -L -S -W -N select_w100 -n 100 -I 2000 -w 10 
             prc thr   usecs/call      samples   errors cnt/samp    maxfd flags
select_w100    1   1     42.35320          178        0       50      100   -w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     40.35128                40.35128
#                    max    126.42872                45.80920
#                   mean     46.53056                42.11247
#                 median     42.51192                42.35320
#                 stddev     14.45933                 1.27458
#         standard error      1.01735                 0.09553
#   99% confidence level      2.36637                 0.22221
#                   skew      3.60959                 0.51883
#               kurtosis     12.83592                -0.46265
#       time correlation     -0.11022                 0.00043
#
#           elasped time      0.48567
#      number of samples          178
#     number of outliers           24
#      getnsecs overhead          484
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 58     40.00000 |********************************    40.73431
#                 23     41.00000 |************                        41.36348
#                 58     42.00000 |********************************    42.59543
#                 25     43.00000 |*************                       43.40997
#                  5     44.00000 |**                                  44.22610
#
#                  9        > 95% |****                                45.01731
#
#        mean of 95%     41.95778
#          95th %ile     44.32952
# bin/select -E -C 200 -L -S -W -N select_w1000 -n 1000 -I 40000 -w 100 
             prc thr   usecs/call      samples   errors cnt/samp    maxfd flags
select_w1000   1   1    542.27850          184        0        2     1000   -w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    518.34250               518.34250
#                    max   3214.91850               932.93450
#                   mean    667.63296               605.81033
#                 median    554.31050               542.27850
#                 stddev    268.37916               110.67045
#         standard error     18.88309                 8.15873
#   99% confidence level     43.92207                18.97721
#                   skew      4.98576                 1.17573
#               kurtosis     39.16583                 0.04119
#       time correlation     -1.50543                -0.28000
#
#           elasped time      0.28686
#      number of samples          184
#     number of outliers           18
#      getnsecs overhead          371
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  5    500.00000 |*                                  519.23850
#                 85    520.00000 |********************************   526.37789
#                 13    540.00000 |****                               547.32958
#                 12    560.00000 |****                               571.76117
#                  9    580.00000 |***                                585.79850
#                  5    600.00000 |*                                  612.11530
#                  1    620.00000 |*                                  625.35050
#                  4    640.00000 |*                                  648.80650
#                  3    660.00000 |*                                  666.99317
#                  3    680.00000 |*                                  695.23850
#                  7    700.00000 |**                                 711.89679
#                  6    720.00000 |**                                 729.81983
#                  8    740.00000 |***                                752.93450
#                  2    760.00000 |*                                  766.27850
#                  4    780.00000 |*                                  786.82250
#                  1    800.00000 |*                                  813.76650
#                  6    820.00000 |**                                 824.73183
#
#                 10        > 95% |***                                868.66570
#
#        mean of 95%    590.70370
#          95th %ile    840.77450
 
# bin/semop -E -C 200 -L -S -W -N semop -I 200 
             prc thr   usecs/call      samples   errors cnt/samp 
semop          1   1     10.96507          172        0      500 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     10.64712                10.64712
#                    max     24.80955                11.41512
#                   mean     11.64345                10.98985
#                 median     11.02344                10.96507
#                 stddev      2.26984                 0.15795
#         standard error      0.15971                 0.01204
#   99% confidence level      0.37147                 0.02801
#                   skew      4.04013                 0.40060
#               kurtosis     15.89050                -0.48402
#       time correlation      0.00087                 0.00040
#
#           elasped time      1.20263
#      number of samples          172
#     number of outliers           30
#      getnsecs overhead          471
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 97     10.00000 |********************************    10.87322
#                 66     11.00000 |*********************               11.11352
#
#                  9        > 95% |**                                  11.33997
#
#        mean of 95%     10.97052
#          95th %ile     11.28098
 
# bin/sigaction -E -C 200 -L -S -W -N sigaction -I 100 
             prc thr   usecs/call      samples   errors cnt/samp 
sigaction      1   1      3.86155          182        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      3.71844                 3.71844
#                    max      9.49457                 4.01950
#                   mean      4.05433                 3.86887
#                 median      3.86564                 3.86155
#                 stddev      0.82570                 0.05210
#         standard error      0.05810                 0.00386
#   99% confidence level      0.13513                 0.00898
#                   skew      5.04983                 0.57280
#               kurtosis     25.25537                 0.50057
#       time correlation     -0.00362                -0.00038
#
#           elasped time      0.83620
#      number of samples          182
#     number of outliers           20
#      getnsecs overhead          469
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                172      3.00000 |********************************     3.86172
#
#                 10        > 95% |*                                    3.99172
#
#        mean of 95%      3.86172
#          95th %ile      3.96958
# bin/signal -E -C 200 -L -S -W -N signal -I 1000 
             prc thr   usecs/call      samples   errors cnt/samp 
signal         1   1     35.35379          184        0      100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     32.83219                32.83219
#                    max    109.73203                40.51219
#                   mean     38.40494                35.82326
#                 median     35.67379                35.35379
#                 stddev     10.63622                 1.73184
#         standard error      0.74836                 0.12767
#   99% confidence level      1.74069                 0.29697
#                   skew      4.61526                 0.66887
#               kurtosis     22.95432                -0.31483
#       time correlation     -0.03426                 0.00291
#
#           elasped time      0.79551
#      number of samples          184
#     number of outliers           18
#      getnsecs overhead          749
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2     32.00000 |*                                   32.88211
#                 15     33.00000 |*******                             33.55121
#                 64     34.00000 |********************************    34.52883
#                 29     35.00000 |**************                      35.49106
#                 29     36.00000 |**************                      36.60563
#                 20     37.00000 |**********                          37.27737
#                 11     38.00000 |*****                               38.41578
#                  4     39.00000 |**                                  39.07475
#
#                 10        > 95% |*****                               39.73779
#
#        mean of 95%     35.59828
#          95th %ile     39.26291
# bin/sigprocmask -E -C 200 -L -S -W -N sigprocmask -I 200 
             prc thr   usecs/call      samples   errors cnt/samp 
sigprocmask    1   1      3.48011          186        0      500 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      3.39819                 3.39819
#                    max      8.13982                 3.91378
#                   mean      3.78160                 3.55423
#                 median      3.50622                 3.48011
#                 stddev      0.90467                 0.12517
#         standard error      0.06365                 0.00918
#   99% confidence level      0.14806                 0.02135
#                   skew      3.88391                 0.68758
#               kurtosis     14.00043                -0.67008
#       time correlation     -0.00561                -0.00005
#
#           elasped time      0.39790
#      number of samples          186
#     number of outliers           16
#      getnsecs overhead         1000
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                176      3.00000 |********************************     3.53859
#
#                 10        > 95% |*                                    3.82950
#
#        mean of 95%      3.53859
#          95th %ile      3.77195
 
# bin/pthread_create -E -C 200 -L -S -W -N pthread_8 -B 8 
             prc thr   usecs/call      samples   errors cnt/samp 
pthread_8      1   1    470.53575          180        0        8 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    383.04775               383.04775
#                    max   1140.77575               641.89575
#                   mean    525.65290               484.37095
#                 median    484.16775               470.53575
#                 stddev    135.94250                54.97878
#         standard error      9.56488                 4.09788
#   99% confidence level     22.24791                 9.53166
#                   skew      2.30161                 0.79302
#               kurtosis      5.29662                 0.26389
#       time correlation     -0.16107                 0.23190
#
#           elasped time      1.73969
#      number of samples          180
#     number of outliers           22
#      getnsecs overhead          706
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    376.00000 |*                                  383.04775
#                  1    384.00000 |*                                  391.91175
#                  1    392.00000 |*                                  398.02375
#                  2    400.00000 |***                                403.35175
#                  8    408.00000 |***************                    412.67975
#                  4    416.00000 |*******                            420.09575
#                 12    424.00000 |**********************             427.80508
#                  8    432.00000 |***************                    435.61175
#                 17    440.00000 |********************************   443.28869
#                 11    448.00000 |********************               451.35611
#                 13    456.00000 |************************           460.13083
#                 14    464.00000 |**************************         468.63404
#                  5    472.00000 |*********                          477.65895
#                  6    480.00000 |***********                        482.74908
#                 13    488.00000 |************************           491.74190
#                  4    496.00000 |*******                            498.12775
#                  9    504.00000 |****************                   508.25664
#                  8    512.00000 |***************                    517.33175
#                  6    520.00000 |***********                        523.42108
#                  6    528.00000 |***********                        533.13842
#                  6    536.00000 |***********                        539.58642
#                  5    544.00000 |*********                          548.13575
#                  3    552.00000 |*****                              555.03708
#                  4    560.00000 |*******                            563.87975
#                  1    568.00000 |*                                  571.78375
#                  2    576.00000 |***                                577.03175
#                  0    584.00000 |                                           -
#                  1    592.00000 |*                                  599.17575
#
#                  9        > 95% |****************                   624.13219
#
#        mean of 95%    477.01510
#          95th %ile    599.91175
# bin/pthread_create -E -C 200 -L -S -W -N pthread_32 -B 32 
             prc thr   usecs/call      samples   errors cnt/samp 
pthread_32     1   1    522.13653          193        0       32 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    439.51253               439.51253
#                    max    921.16853               648.29653
#                   mean    538.26916               527.54316
#                 median    523.69653               522.13653
#                 stddev     68.39320                44.90276
#         standard error      4.81213                 3.23217
#   99% confidence level     11.19301                 7.51803
#                   skew      2.33996                 0.69729
#               kurtosis      8.25291                 0.15419
#       time correlation     -0.15523                -0.03849
#
#           elasped time      8.23867
#      number of samples          193
#     number of outliers            9
#      getnsecs overhead          495
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    438.00000 |**                                 439.51253
#                  1    444.00000 |**                                 444.04853
#                  4    450.00000 |*********                          452.99853
#                  2    456.00000 |****                               460.20453
#                  3    462.00000 |******                             463.38986
#                  8    468.00000 |******************                 470.28953
#                  6    474.00000 |*************                      477.26053
#                  3    480.00000 |******                             483.62186
#                 11    486.00000 |*************************          487.66526
#                 11    492.00000 |*************************          494.16417
#                 12    498.00000 |***************************        501.50986
#                 11    504.00000 |*************************          506.18889
#                 10    510.00000 |**********************             514.58293
#                 13    516.00000 |*****************************      518.91438
#                 14    522.00000 |********************************   524.71825
#                 14    528.00000 |********************************   531.10053
#                 10    534.00000 |**********************             536.81253
#                  9    540.00000 |********************               542.89831
#                  6    546.00000 |*************                      548.50586
#                  5    552.00000 |***********                        554.40533
#                  3    558.00000 |******                             560.61920
#                  4    564.00000 |*********                          567.61653
#                  3    570.00000 |******                             574.10186
#                  3    576.00000 |******                             579.25920
#                  4    582.00000 |*********                          584.70453
#                  2    588.00000 |****                               590.70053
#                  2    594.00000 |****                               597.59253
#                  3    600.00000 |******                             603.87786
#                  1    606.00000 |**                                 607.45653
#                  4    612.00000 |*********                          615.07653
#
#                 10        > 95% |**********************             634.89733
#
#        mean of 95%    521.67682
#          95th %ile    616.85653
# bin/pthread_create -E -C 200 -L -S -W -N pthread_128 -B 128 
             prc thr   usecs/call      samples   errors cnt/samp 
pthread_128    1   1    553.46472          198        0      128 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    483.74672               483.74672
#                    max    781.23072               641.00472
#                   mean    560.56051               557.60360
#                 median    554.27072               553.46472
#                 stddev     37.30416                30.25463
#         standard error      2.62471                 2.15010
#   99% confidence level      6.10508                 5.00114
#                   skew      1.84786                 0.55377
#               kurtosis      7.17020                -0.00320
#       time correlation     -0.03003                -0.01022
#
#           elasped time     37.53618
#      number of samples          198
#     number of outliers            4
#      getnsecs overhead          420
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    480.00000 |*                                  483.74672
#                  0    485.00000 |                                           -
#                  1    490.00000 |*                                  491.91072
#                  1    495.00000 |*                                  497.38072
#                  1    500.00000 |*                                  501.03472
#                  0    505.00000 |                                           -
#                  3    510.00000 |*****                              513.54672
#                  3    515.00000 |*****                              518.23939
#                 12    520.00000 |********************               522.47722
#                 11    525.00000 |******************                 526.90872
#                 19    530.00000 |********************************   532.32767
#                 13    535.00000 |*********************              537.15964
#                 12    540.00000 |********************               542.95305
#                 12    545.00000 |********************               548.00455
#                 16    550.00000 |**************************         552.89959
#                 12    555.00000 |********************               557.42589
#                 10    560.00000 |****************                   562.43752
#                 13    565.00000 |*********************              567.47964
#                  8    570.00000 |*************                      572.11022
#                  7    575.00000 |***********                        576.51586
#                  6    580.00000 |**********                         582.81939
#                  5    585.00000 |********                           588.94232
#                  5    590.00000 |********                           593.38272
#                  6    595.00000 |**********                         597.36105
#                  7    600.00000 |***********                        601.73129
#                  1    605.00000 |*                                  608.62272
#                  3    610.00000 |*****                              612.38205
#
#                 10        > 95% |****************                   628.13632
#
#        mean of 95%    553.85186
#          95th %ile    613.56672
# bin/pthread_create -E -C 200 -L -S -W -N pthread_512 -B 512 
             prc thr   usecs/call      samples   errors cnt/samp 
pthread_512    1   1    602.17518          202        0      512 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    490.88618               490.88618
#                    max    952.54618               952.54618
#                   mean    645.89299               645.89299
#                 median    602.17518               602.17518
#                 stddev    107.77019               107.77019
#         standard error      7.58268                 7.58268
#   99% confidence level     17.63732                17.63732
#                   skew      1.26363                 1.26363
#               kurtosis      0.67042                 0.67042
#       time correlation     -0.01075                -0.01075
#
#           elasped time    157.33536
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          422
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    480.00000 |*                                  490.88618
#                  1    500.00000 |*                                  510.92718
#                  8    520.00000 |*******                            532.91830
#                 26    540.00000 |*************************          551.12987
#                 33    560.00000 |********************************   571.30283
#                 27    580.00000 |**************************         589.25688
#                 20    600.00000 |*******************                608.51355
#                 13    620.00000 |************                       627.16491
#                  2    640.00000 |*                                  650.17493
#                 12    660.00000 |***********                        670.85280
#                 14    680.00000 |*************                      689.62296
#                  7    700.00000 |******                             711.19446
#                  5    720.00000 |****                               731.45868
#                  3    740.00000 |**                                 749.71401
#                  3    760.00000 |**                                 766.63651
#                  4    780.00000 |***                                788.11068
#                  1    800.00000 |*                                  806.27068
#                  1    820.00000 |*                                  829.32768
#                  4    840.00000 |***                                849.06743
#                  4    860.00000 |***                                873.37180
#                  2    880.00000 |*                                  895.58218
#
#                 11        > 95% |**********                         920.95731
#
#        mean of 95%    630.05159
#          95th %ile    902.13218
 
# bin/fork -E -C 200 -L -S -W -N fork_10 -B 10 
             prc thr   usecs/call      samples   errors cnt/samp 
fork_10        1   1   3439.61430          192        0       10 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   2950.73110              2950.73110
#                    max   5379.73590              4147.50550
#                   mean   3524.15234              3464.22257
#                 median   3455.02550              3439.61430
#                 stddev    363.81988               241.19892
#         standard error     25.59828                17.40703
#   99% confidence level     59.54159                40.48876
#                   skew      2.10892                 0.61076
#               kurtosis      6.50967                 0.29274
#       time correlation     -0.22693                 0.30531
#
#           elasped time      7.92276
#      number of samples          192
#     number of outliers           10
#      getnsecs overhead          785
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1   2920.00000 |*                                 2950.73110
#                  2   2960.00000 |***                               2994.53270
#                  2   3000.00000 |***                               3023.87030
#                  2   3040.00000 |***                               3071.02550
#                  4   3080.00000 |*******                           3103.65270
#                  5   3120.00000 |********                          3145.85942
#                  4   3160.00000 |*******                           3167.73590
#                 11   3200.00000 |*******************               3221.06012
#                  8   3240.00000 |**************                    3257.44790
#                 14   3280.00000 |************************          3295.59601
#                 14   3320.00000 |************************          3335.72401
#                 18   3360.00000 |********************************  3382.80932
#                 12   3400.00000 |*********************             3416.33323
#                 13   3440.00000 |***********************           3462.75276
#                 14   3480.00000 |************************          3499.18184
#                 12   3520.00000 |*********************             3538.54123
#                 10   3560.00000 |*****************                 3585.67766
#                  8   3600.00000 |**************                    3620.20950
#                  9   3640.00000 |****************                  3660.66461
#                  5   3680.00000 |********                          3695.06646
#                  2   3720.00000 |***                               3751.72950
#                  1   3760.00000 |*                                 3780.91350
#                  4   3800.00000 |*******                           3809.94390
#                  3   3840.00000 |*****                             3864.81323
#                  4   3880.00000 |*******                           3909.54070
#
#                 10        > 95% |*****************                 4050.66582
#
#        mean of 95%   3432.00041
#          95th %ile   3930.51990
# bin/fork -E -C 200 -L -S -W -N fork_100 -B 100 -C 100 
             prc thr   usecs/call      samples   errors cnt/samp 
fork_100       1   1   3135.62793           98        0      100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   2480.14505              2903.66633
#                    max   3811.42697              3519.95817
#                   mean   3163.50565              3164.74950
#                 median   3135.62793              3135.62793
#                 stddev    187.07665               146.85714
#         standard error     18.52335                14.83481
#   99% confidence level     43.08531                34.50577
#                   skew      0.09913                 0.57113
#               kurtosis      2.36246                -0.45205
#       time correlation      0.62366                 0.40305
#
#           elasped time     36.81114
#      number of samples           98
#     number of outliers            4
#      getnsecs overhead          343
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2   2900.00000 |*******                           2909.60169
#                  3   2920.00000 |**********                        2935.23028
#                  0   2940.00000 |                                           -
#                  0   2960.00000 |                                           -
#                  4   2980.00000 |**************                    2990.32873
#                  4   3000.00000 |**************                    3014.56809
#                  6   3020.00000 |*********************             3032.26622
#                  8   3040.00000 |****************************      3047.61385
#                  6   3060.00000 |*********************             3069.26462
#                  9   3080.00000 |********************************  3091.19287
#                  5   3100.00000 |*****************                 3109.25481
#                  4   3120.00000 |**************                    3132.35241
#                  3   3140.00000 |**********                        3146.18196
#                  4   3160.00000 |**************                    3172.42345
#                  5   3180.00000 |*****************                 3191.06422
#                  4   3200.00000 |**************                    3213.90185
#                  3   3220.00000 |**********                        3229.94004
#                  4   3240.00000 |**************                    3253.18185
#                  2   3260.00000 |*******                           3272.10665
#                  4   3280.00000 |**************                    3291.84105
#                  2   3300.00000 |*******                           3307.71113
#                  2   3320.00000 |*******                           3331.70217
#                  2   3340.00000 |*******                           3347.50761
#                  2   3360.00000 |*******                           3366.00233
#                  0   3380.00000 |                                           -
#                  3   3400.00000 |**********                        3410.73918
#                  2   3420.00000 |*******                           3435.63689
#
#                  5        > 95% |*****************                 3490.36457
#
#        mean of 95%   3147.24331
#          95th %ile   3447.28489
# bin/fork -E -C 200 -L -S -W -N fork_1000 -B 1000 -C 50 
             prc thr   usecs/call      samples   errors cnt/samp 
fork_1000      1   1   3241.40514           52        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   2878.99337              2878.99337
#                    max   3560.05321              3560.05321
#                   mean   3227.68537              3227.68537
#                 median   3241.40514              3241.40514
#                 stddev    125.71568               125.71568
#         standard error     17.43363                17.43363
#   99% confidence level     40.55062                40.55062
#                   skew     -0.37415                -0.37415
#               kurtosis      0.93741                 0.93741
#       time correlation      3.36708                 3.36708
#
#           elasped time    184.39001
#      number of samples           52
#     number of outliers            0
#      getnsecs overhead          810
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1   2860.00000 |****                              2878.99337
#                  0   2880.00000 |                                           -
#                  1   2900.00000 |****                              2901.92713
#                  0   2920.00000 |                                           -
#                  0   2940.00000 |                                           -
#                  0   2960.00000 |                                           -
#                  0   2980.00000 |                                           -
#                  1   3000.00000 |****                              3010.86818
#                  2   3020.00000 |*********                         3032.50210
#                  0   3040.00000 |                                           -
#                  1   3060.00000 |****                              3078.89122
#                  1   3080.00000 |****                              3088.17711
#                  1   3100.00000 |****                              3116.47919
#                  1   3120.00000 |****                              3130.76937
#                  4   3140.00000 |******************                3154.21596
#                  1   3160.00000 |****                              3164.45026
#                  6   3180.00000 |***************************       3194.86246
#                  5   3200.00000 |**********************            3208.63499
#                  1   3220.00000 |****                              3238.62012
#                  4   3240.00000 |******************                3248.82261
#                  3   3260.00000 |*************                     3266.29423
#                  4   3280.00000 |******************                3286.17794
#                  7   3300.00000 |********************************  3308.99843
#                  1   3320.00000 |****                              3336.01813
#                  2   3340.00000 |*********                         3349.98012
#                  1   3360.00000 |****                              3365.24719
#                  1   3380.00000 |****                              3382.29935
#
#                  3        > 95% |*************                     3483.61553
#
#        mean of 95%   3212.01617
#          95th %ile   3430.46729
 
# bin/exit -E -C 200 -L -S -W -N exit_10 -B 10 
             prc thr   usecs/call      samples   errors cnt/samp 
exit_10        1   1    761.75350          194        0       10 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    540.54390               540.54390
#                    max   1503.94870              1099.67350
#                   mean    789.51353               768.07657
#                 median    767.02710               761.75350
#                 stddev    155.83782               114.50532
#         standard error     10.96471                 8.22100
#   99% confidence level     25.50392                19.12205
#                   skew      1.70824                 0.65013
#               kurtosis      4.11437                 0.13642
#       time correlation     -0.03218                -0.24629
#
#           elasped time      7.93412
#      number of samples          194
#     number of outliers            8
#      getnsecs overhead          513
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    540.00000 |*                                  540.54390
#                  2    560.00000 |***                                574.41270
#                  3    580.00000 |*****                              591.43670
#                  8    600.00000 |**************                     609.97110
#                 11    620.00000 |*******************                631.04921
#                 13    640.00000 |***********************            650.47227
#                  9    660.00000 |****************                   669.08434
#                 12    680.00000 |*********************              689.30123
#                 10    700.00000 |*****************                  709.91606
#                 16    720.00000 |****************************       731.34870
#                 12    740.00000 |*********************              749.83670
#                 16    760.00000 |****************************       770.91830
#                 18    780.00000 |********************************   788.00488
#                  9    800.00000 |****************                   812.17981
#                  9    820.00000 |****************                   830.00594
#                 11    840.00000 |*******************                849.13561
#                  3    860.00000 |*****                              872.51617
#                  6    880.00000 |**********                         892.46283
#                  4    900.00000 |*******                            909.12630
#                  4    920.00000 |*******                            927.21910
#                  3    940.00000 |*****                              947.94230
#                  2    960.00000 |***                                970.85430
#                  2    980.00000 |***                                991.29590
#
#                 10        > 95% |*****************                 1044.87926
#
#        mean of 95%    753.03294
#          95th %ile    998.45110
# bin/exit -E -C 200 -L -S -W -N exit_100 -B 100 
             prc thr   usecs/call      samples   errors cnt/samp 
exit_100       1   1    505.73474          201        0      100 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    407.89666               407.89666
#                    max    693.12674               636.93474
#                   mean    511.08890               510.18324
#                 median    505.95490               505.73474
#                 stddev     53.48852                52.04626
#         standard error      3.76344                 3.67106
#   99% confidence level      8.75376                 8.53889
#                   skew      0.19329                 0.04992
#               kurtosis     -0.43614                -0.86857
#       time correlation      0.02661                 0.00379
#
#           elasped time     72.25816
#      number of samples          201
#     number of outliers            1
#      getnsecs overhead          350
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    402.00000 |**                                 407.89666
#                  2    408.00000 |*****                              410.79586
#                  1    414.00000 |**                                 419.46786
#                  5    420.00000 |*************                      422.80815
#                  4    426.00000 |**********                         428.71778
#                 10    432.00000 |**************************         433.80668
#                  1    438.00000 |**                                 443.15810
#                  4    444.00000 |**********                         446.78114
#                  7    450.00000 |******************                 452.88610
#                  8    456.00000 |*********************              459.48482
#                  2    462.00000 |*****                              464.75554
#                  9    468.00000 |************************           470.55038
#                  9    474.00000 |************************           476.75554
#                  9    480.00000 |************************           483.00678
#                  6    486.00000 |****************                   488.39245
#                 10    492.00000 |**************************         494.46972
#                 12    498.00000 |********************************   500.67981
#                  3    504.00000 |********                           507.09495
#                  3    510.00000 |********                           514.13666
#                  7    516.00000 |******************                 519.44647
#                  9    522.00000 |************************           526.03639
#                  8    528.00000 |*********************              530.76354
#                  6    534.00000 |****************                   538.40973
#                  9    540.00000 |************************           542.15927
#                  4    546.00000 |**********                         548.76130
#                  7    552.00000 |******************                 556.29364
#                  8    558.00000 |*********************              560.63362
#                  6    564.00000 |****************                   566.93282
#                  9    570.00000 |************************           573.44646
#                  9    576.00000 |************************           578.67597
#                  2    582.00000 |*****                              582.83682
#
#                 11        > 95% |*****************************      606.20985
#
#        mean of 95%    504.62381
#          95th %ile    584.29602
# bin/exit -E -C 200 -L -S -W -N exit_1000 -B 1000 -C 50 
             prc thr   usecs/call      samples   errors cnt/samp 
exit_1000      1   1    435.44639           52        0     1000 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    410.34150               410.34150
#                    max    477.71762               477.71762
#                   mean    436.63130               436.63130
#                 median    435.44639               435.44639
#                 stddev     15.19443                15.19443
#         standard error      2.10709                 2.10709
#   99% confidence level      4.90109                 4.90109
#                   skew      0.59204                 0.59204
#               kurtosis     -0.10049                -0.10049
#       time correlation      0.06735                 0.06735
#
#           elasped time    186.68672
#      number of samples           52
#     number of outliers            0
#      getnsecs overhead          392
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    410.00000 |******                             410.34150
#                  1    412.00000 |******                             412.88946
#                  0    414.00000 |                                           -
#                  2    416.00000 |************                       416.61810
#                  4    418.00000 |*************************          418.94930
#                  1    420.00000 |******                             421.56966
#                  2    422.00000 |************                       423.01926
#                  3    424.00000 |*******************                425.42467
#                  3    426.00000 |*******************                426.84530
#                  3    428.00000 |*******************                428.65864
#                  2    430.00000 |************                       431.04511
#                  3    432.00000 |*******************                432.60761
#                  2    434.00000 |************                       435.35052
#                  1    436.00000 |******                             437.27065
#                  3    438.00000 |*******************                438.58589
#                  5    440.00000 |********************************   441.02376
#                  1    442.00000 |******                             443.80377
#                  2    444.00000 |************                       444.36518
#                  3    446.00000 |*******************                447.00863
#                  1    448.00000 |******                             449.65874
#                  2    450.00000 |************                       450.55513
#                  0    452.00000 |                                           -
#                  1    454.00000 |******                             454.36172
#                  2    456.00000 |************                       457.54508
#                  0    458.00000 |                                           -
#                  0    460.00000 |                                           -
#                  1    462.00000 |******                             463.31353
#
#                  3        > 95% |*******************                472.10457
#
#        mean of 95%    434.45947
#          95th %ile    467.36652
 
# bin/exit -E -C 200 -L -S -W -N exit_10_nolibc -e -B 10 
             prc thr   usecs/call      samples   errors cnt/samp 
exit_10_nolibc   1   1    624.45020          193        0       10 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    487.56700               487.56700
#                    max   1354.94620               882.06300
#                   mean    658.23003               637.96024
#                 median    628.85340               624.45020
#                 stddev    126.83665                81.64257
#         standard error      8.92420                 5.87676
#   99% confidence level     20.75768                13.66935
#                   skew      2.33206                 0.58237
#               kurtosis      7.95123                -0.12401
#       time correlation     -0.16040                -0.04448
#
#           elasped time      7.70300
#      number of samples          193
#     number of outliers            9
#      getnsecs overhead          362
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    480.00000 |**                                 487.56700
#                  0    490.00000 |                                           -
#                  3    500.00000 |*******                            508.00433
#                  6    510.00000 |**************                     512.51420
#                  1    520.00000 |**                                 524.17500
#                  6    530.00000 |**************                     533.54033
#                 10    540.00000 |************************           544.45276
#                  6    550.00000 |**************                     554.66887
#                 10    560.00000 |************************           564.87644
#                 10    570.00000 |************************           574.46364
#                  8    580.00000 |*******************                583.85820
#                  6    590.00000 |**************                     592.34780
#                 13    600.00000 |********************************   606.60109
#                  9    610.00000 |**********************             614.45767
#                 13    620.00000 |********************************   624.32220
#                 11    630.00000 |***************************        636.56133
#                  6    640.00000 |**************                     644.48220
#                  6    650.00000 |**************                     655.51580
#                  6    660.00000 |**************                     663.41340
#                  6    670.00000 |**************                     674.34887
#                  8    680.00000 |*******************                686.78620
#                  4    690.00000 |*********                          697.90940
#                  6    700.00000 |**************                     704.24967
#                  6    710.00000 |**************                     715.30033
#                  2    720.00000 |****                               723.97020
#                  4    730.00000 |*********                          735.68220
#                  4    740.00000 |*********                          745.33340
#                  5    750.00000 |************                       755.09724
#                  4    760.00000 |*********                          765.43580
#                  3    770.00000 |*******                            772.93873
#
#                 10        > 95% |************************           823.12156
#
#        mean of 95%    627.84213
#          95th %ile    783.06780
 
# bin/exec -E -C 200 -L -S -W -N exec -B 10 
             prc thr   usecs/call      samples   errors cnt/samp 
exec           1   1   8353.67810          199        0       10 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   6552.87170              6552.87170
#                    max  13089.34530             11312.47490
#                   mean   8476.79319              8419.56002
#                 median   8371.87970              8353.67810
#                 stddev   1146.71747              1052.65641
#         standard error     80.68276                74.62083
#   99% confidence level    187.66810               173.56806
#                   skew      0.85399                 0.52440
#               kurtosis      0.97853                -0.15240
#       time correlation      3.97425                 3.54522
#
#           elasped time     17.24438
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          371
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2   6400.00000 |***                               6568.76930
#                  6   6600.00000 |*********                         6710.62317
#                  9   6800.00000 |*************                     6892.32770
#                  9   7000.00000 |*************                     7137.67810
#                  6   7200.00000 |*********                         7302.69570
#                 10   7400.00000 |***************                   7486.40130
#                 20   7600.00000 |******************************    7683.27170
#                 14   7800.00000 |*********************             7905.81341
#                 12   8000.00000 |******************                8107.28023
#                 15   8200.00000 |**********************            8288.74626
#                 21   8400.00000 |********************************  8475.29395
#                  9   8600.00000 |*************                     8697.58566
#                 12   8800.00000 |******************                8906.79383
#                 14   9000.00000 |*********************             9075.79376
#                  5   9200.00000 |*******                           9354.78146
#                 10   9400.00000 |***************                   9471.19490
#                  2   9600.00000 |***                               9628.95490
#                  5   9800.00000 |*******                           9930.20802
#                  3  10000.00000 |****                             10067.22263
#                  5  10200.00000 |*******                          10304.32642
#
#                 10        > 95% |***************                  10885.53602
#
#        mean of 95%   8289.08510
#          95th %ile  10596.05890
 
# bin/system -E -C 200 -L -S -W -N system -I 1000000 
             prc thr   usecs/call      samples   errors cnt/samp  command
system         1   1  30297.31800          202        0        1     A=$$
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min  16340.19800             16340.19800
#                    max  39981.28600             39981.28600
#                   mean  28315.00861             28315.00861
#                 median  30297.31800             30297.31800
#                 stddev   6666.12458              6666.12458
#         standard error    469.02689               469.02689
#   99% confidence level   1090.95654              1090.95654
#                   skew     -0.33834                -0.33834
#               kurtosis     -1.25066                -1.25066
#       time correlation    -31.15983               -31.15983
#
#           elasped time      5.75996
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          794
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  5  16100.00000 |**********                       16433.68920
#                 12  16800.00000 |*************************        17159.39800
#                  3  17500.00000 |******                           17756.81667
#                  7  18200.00000 |**************                   18594.57057
#                  1  18900.00000 |**                               19256.29400
#                  8  19600.00000 |*****************                20039.97400
#                  5  20300.00000 |**********                       20766.95000
#                  8  21000.00000 |*****************                21213.54200
#                  2  21700.00000 |****                             22037.60600
#                  6  22400.00000 |************                     22597.77667
#                  2  23100.00000 |****                             23365.73400
#                  6  23800.00000 |************                     24184.03800
#                  6  24500.00000 |************                     24895.50467
#                  4  25200.00000 |********                         25412.96600
#                  5  25900.00000 |**********                       26268.18520
#                  6  26600.00000 |************                     26966.67267
#                  3  27300.00000 |******                           27723.49400
#                  3  28000.00000 |******                           28337.21133
#                  3  28700.00000 |******                           29179.87800
#                  6  29400.00000 |************                     29791.33400
#                  6  30100.00000 |************                     30609.72333
#                  5  30800.00000 |**********                       31235.96760
#                 12  31500.00000 |*************************        31872.65667
#                  6  32200.00000 |************                     32471.01400
#                 14  32900.00000 |*****************************    33303.05057
#                 12  33600.00000 |*************************        33937.29667
#                 15  34300.00000 |******************************** 34559.85453
#                  8  35000.00000 |*****************                35415.07800
#                  7  35700.00000 |**************                   35972.47229
#                  5  36400.00000 |**********                       36593.79160
#
#                 11        > 95% |***********************          37976.78273
#
#        mean of 95%  27758.57136
#          95th %ile  37017.31800
 
# bin/recurse -E -C 200 -L -S -W -N recurse -B 512 
             prc thr   usecs/call      samples   errors cnt/samp 
recurse        1   1      3.72482          190        0      512 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      3.58632                 3.58632
#                    max      5.59582                 4.01182
#                   mean      3.80167                 3.72075
#                 median      3.73682                 3.72482
#                 stddev      0.35714                 0.09747
#         standard error      0.02513                 0.00707
#   99% confidence level      0.05845                 0.01645
#                   skew      3.74103                 0.62231
#               kurtosis     13.73453                -0.44193
#       time correlation      0.00117                -0.00009
#
#           elasped time      0.40845
#      number of samples          190
#     number of outliers           12
#      getnsecs overhead          862
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                180      3.00000 |********************************     3.70870
#
#                 10        > 95% |*                                    3.93767
#
#        mean of 95%      3.70870
#          95th %ile      3.89682
 
# bin/read -E -C 200 -L -S -W -N read_t1k -s 1k -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
read_t1k       1   1     12.28600          171        0        1     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      6.14200                10.23800
#                    max    172.28600                15.35800
#                   mean     15.40869                12.67075
#                 median     12.28600                12.28600
#                 stddev     17.26108                 0.98890
#         standard error      1.21449                 0.07562
#   99% confidence level      2.82489                 0.17590
#                   skew      7.65480                 0.90930
#               kurtosis     64.40937                 0.83349
#       time correlation     -0.03555                -0.00034
#
#           elasped time      0.02932
#      number of samples          171
#     number of outliers           31
#      getnsecs overhead          770
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     10.00000 |*                                   10.23800
#                 17     11.00000 |*****                               11.23188
#                 95     12.00000 |********************************    12.25905
#                 36     13.00000 |************                        13.27444
#                 12     14.00000 |****                                14.22733
#                  1     15.00000 |*                                   15.10200
#
#                  9        > 95% |***                                 15.24422
#
#        mean of 95%     12.52778
#          95th %ile     15.10200
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 9X to avoid.
# bin/read -E -C 200 -L -S -W -N read_t10k -s 10k -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
read_t10k      1   1     12.67900          189        0        1    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     11.39900                11.39900
#                    max    220.55100                13.70300
#                   mean     13.86268                12.33631
#                 median     12.67900                12.67900
#                 stddev     14.82921                 0.55334
#         standard error      1.04338                 0.04025
#   99% confidence level      2.42690                 0.09362
#                   skew     13.42349                -0.14062
#               kurtosis    183.84866                -0.55615
#       time correlation     -0.03198                 0.00022
#
#           elasped time      0.01720
#      number of samples          189
#     number of outliers           13
#      getnsecs overhead          377
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 62     11.00000 |****************                    11.60958
#                117     12.00000 |********************************    12.63305
#
#                 10        > 95% |**                                  13.37020
#
#        mean of 95%     12.27855
#          95th %ile     12.67900
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 8X to avoid.
# bin/read -E -C 200 -L -S -W -N read_t100k -s 100k -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
read_t100k     1   1     88.05500          178        0        1   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     86.00700                86.00700
#                    max   1084.40700               117.23900
#                   mean    109.65912                92.69464
#                 median     88.31100                88.05500
#                 stddev     80.24400                 8.44033
#         standard error      5.64595                 0.63263
#   99% confidence level     13.13248                 1.47150
#                   skew      9.39126                 1.26450
#               kurtosis    106.44692                 0.03152
#       time correlation     -0.47142                -0.09784
#
#           elasped time      0.03635
#      number of samples          178
#     number of outliers           24
#      getnsecs overhead          777
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 15     86.00000 |*******                             86.22887
#                 62     87.00000 |********************************    87.23745
#                 27     88.00000 |*************                       88.18774
#                 14     89.00000 |*******                             89.24357
#                  7     90.00000 |***                                 90.32243
#                  4     91.00000 |**                                  91.25500
#                  0     92.00000 |                                           -
#                  1     93.00000 |*                                   93.17500
#                  0     94.00000 |                                           -
#                  0     95.00000 |                                           -
#                  0     96.00000 |                                           -
#                  0     97.00000 |                                           -
#                  6     98.00000 |***                                 98.25233
#                  6     99.00000 |***                                 99.14833
#                  1    100.00000 |*                                  100.34300
#                  1    101.00000 |*                                  101.11100
#                  0    102.00000 |                                           -
#                  0    103.00000 |                                           -
#                  0    104.00000 |                                           -
#                  1    105.00000 |*                                  105.97500
#                 10    106.00000 |*****                              106.38460
#                  9    107.00000 |****                               107.25500
#                  2    108.00000 |*                                  108.15100
#                  3    109.00000 |*                                  109.30300
#
#                  9        > 95% |****                               112.37500
#
#        mean of 95%     91.64657
#          95th %ile    110.07100
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 2X to avoid.
 
# bin/read -E -C 200 -L -S -W -N read_u1k -s 1k -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
read_u1k       1   1     12.30700          198        0        1     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      5.13900                 5.13900
#                    max    236.30700                21.26700
#                   mean     13.33353                11.11233
#                 median     12.30700                12.30700
#                 stddev     20.73143                 3.39906
#         standard error      1.45866                 0.24156
#   99% confidence level      3.39284                 0.56187
#                   skew      9.45098                 0.12346
#               kurtosis     92.01024                -1.14480
#       time correlation     -0.05762                -0.01571
#
#           elasped time      0.02105
#      number of samples          198
#     number of outliers            4
#      getnsecs overhead          749
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2      5.00000 |*                                    5.13900
#                  4      6.00000 |**                                   6.29100
#                 52      7.00000 |********************************     7.24608
#                 19      8.00000 |***********                          8.23795
#                 10      9.00000 |******                               9.26060
#                  2     10.00000 |*                                   10.25900
#                  2     11.00000 |*                                   11.28300
#                 20     12.00000 |************                        12.23020
#                 46     13.00000 |****************************        13.26422
#                  5     14.00000 |***                                 14.25260
#                 23     15.00000 |**************                      15.25657
#                  3     16.00000 |*                                   16.14700
#
#                 10        > 95% |******                              17.04300
#
#        mean of 95%     10.79687
#          95th %ile     16.14700
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 9X to avoid.
# bin/read -E -C 200 -L -S -W -N read_u10k -s 10k -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
read_u10k      1   1     20.32100          183        0        1    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     11.10500                11.10500
#                    max    472.16100                32.35300
#                   mean     25.79205                19.85237
#                 median     21.34500                20.32100
#                 stddev     35.17680                 4.99569
#         standard error      2.47503                 0.36929
#   99% confidence level      5.75692                 0.85897
#                   skew     10.55074                -0.29763
#               kurtosis    127.07799                -0.59092
#       time correlation     -0.17960                -0.05220
#
#           elasped time      0.02981
#      number of samples          183
#     number of outliers           19
#      getnsecs overhead          671
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  6     11.00000 |****                                11.31833
#                 36     12.00000 |************************            12.29256
#                  3     13.00000 |**                                  13.32367
#                  1     14.00000 |*                                   14.43300
#                  1     15.00000 |*                                   15.45700
#                  0     16.00000 |                                           -
#                  0     17.00000 |                                           -
#                  1     18.00000 |*                                   18.27300
#                  0     19.00000 |                                           -
#                 47     20.00000 |********************************    20.32645
#                 36     21.00000 |************************            21.33078
#                  7     22.00000 |****                                22.36900
#                  5     23.00000 |***                                 23.34180
#                 17     24.00000 |***********                         24.38688
#                 11     25.00000 |*******                             25.37118
#                  2     26.00000 |*                                   26.33700
#
#                 10        > 95% |******                              29.15300
#
#        mean of 95%     19.31476
#          95th %ile     26.46500
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 5X to avoid.
# bin/read -E -C 200 -L -S -W -N read_u100k -s 100k -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
read_u100k     1   1    133.51200          195        0        1   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     64.39200                64.39200
#                    max   1256.32800               190.34400
#                   mean    131.73141               118.27803
#                 median    133.51200               133.51200
#                 stddev     98.54460                35.41567
#         standard error      6.93357                 2.53617
#   99% confidence level     16.12749                 5.89913
#                   skew      7.91990                -0.33702
#               kurtosis     83.09015                -1.26586
#       time correlation     -0.54172                -0.33636
#
#           elasped time      0.04607
#      number of samples          195
#     number of outliers            7
#      getnsecs overhead          632
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 34     64.00000 |********************************    65.90541
#                  7     68.00000 |******                              69.03657
#                  1     72.00000 |*                                   72.32800
#                  2     76.00000 |*                                   77.32000
#                 17     80.00000 |****************                    81.37835
#                  3     84.00000 |**                                  86.06667
#                  0     88.00000 |                                           -
#                  1     92.00000 |*                                   95.36800
#                  1     96.00000 |*                                   96.39200
#                  1    100.00000 |*                                  101.51200
#                  1    104.00000 |*                                  107.40000
#                  0    108.00000 |                                           -
#                  1    112.00000 |*                                  115.33600
#                  1    116.00000 |*                                  119.43200
#                 12    120.00000 |***********                        121.99200
#                  5    124.00000 |****                               125.93440
#                  3    128.00000 |**                                 130.01333
#                 20    132.00000 |******************                 133.92160
#                 24    136.00000 |**********************             138.01333
#                 16    140.00000 |***************                    141.60800
#                 12    144.00000 |***********                        145.52267
#                  4    148.00000 |***                                149.12800
#                  5    152.00000 |****                               154.14560
#                  9    156.00000 |********                           157.51911
#                  5    160.00000 |****                               161.72320
#
#                 10        > 95% |*********                          175.62400
#
#        mean of 95%    115.17825
#          95th %ile    164.23200
 
# bin/read -E -C 200 -L -S -W -N read_z1k -s 1k -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size
read_z1k       1   1      5.50100          193        0        1     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      4.47700                 4.47700
#                    max     81.53300                11.64500
#                   mean      7.63518                 6.58336
#                 median      5.75700                 5.50100
#                 stddev      6.71630                 2.04566
#         standard error      0.47256                 0.14725
#   99% confidence level      1.09917                 0.34250
#                   skew      7.52524                 0.83333
#               kurtosis     72.96708                -0.67038
#       time correlation     -0.00514                 0.00267
#
#           elasped time      0.02280
#      number of samples          193
#     number of outliers            9
#      getnsecs overhead          387
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 52      4.00000 |***********************              4.62469
#                 71      5.00000 |********************************     5.59475
#                  8      6.00000 |***                                  6.62100
#                  0      7.00000 |                                           -
#                 34      8.00000 |***************                      8.61065
#                 15      9.00000 |******                               9.64820
#                  3     10.00000 |*                                   10.53567
#
#                 10        > 95% |****                                11.08180
#
#        mean of 95%      6.33755
#          95th %ile     10.62100
# bin/read -E -C 200 -L -S -W -N read_z10k -s 10k -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size
read_z10k      1   1     10.46700          198        0        1    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      7.39500                 7.39500
#                    max    117.47500                24.29100
#                   mean     14.12957                13.28429
#                 median     10.46700                10.46700
#                 stddev      8.82755                 4.10901
#         standard error      0.62110                 0.29201
#   99% confidence level      1.44469                 0.67923
#                   skew      8.21265                 0.54826
#               kurtosis     90.90689                -1.02045
#       time correlation     -0.02148                -0.00893
#
#           elasped time      0.02100
#      number of samples          198
#     number of outliers            4
#      getnsecs overhead          541
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  3      7.00000 |*                                    7.48033
#                 14      8.00000 |*******                              8.45557
#                 26      9.00000 |*************                        9.45285
#                 61     10.00000 |********************************    10.46280
#                  7     11.00000 |***                                 11.45443
#                  5     12.00000 |**                                  12.41260
#                  1     13.00000 |*                                   13.53900
#                  1     14.00000 |*                                   14.56300
#                  4     15.00000 |**                                  15.52300
#                 17     16.00000 |********                            16.44535
#                 40     17.00000 |********************                17.46860
#                  2     18.00000 |*                                   18.65900
#                  3     19.00000 |*                                   19.42700
#                  4     20.00000 |**                                  20.45100
#
#                 10        > 95% |*****                               21.73100
#
#        mean of 95%     12.83500
#          95th %ile     20.45100
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 10X to avoid.
# bin/read -E -C 200 -L -S -W -N read_z100k -s 100k -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size
read_z100k     1   1     48.41300          184        0        1   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     46.36500                46.36500
#                    max    698.65300                51.74100
#                   mean     57.23106                48.66483
#                 median     48.66900                48.41300
#                 stddev     54.12883                 1.03426
#         standard error      3.80849                 0.07625
#   99% confidence level      8.85855                 0.17735
#                   skew      9.25362                 0.67838
#               kurtosis     98.62328                 0.07204
#       time correlation     -0.12047                -0.00399
#
#           elasped time      0.02378
#      number of samples          184
#     number of outliers           18
#      getnsecs overhead          483
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     46.00000 |*                                   46.36500
#                 51     47.00000 |********************                47.50445
#                 78     48.00000 |********************************    48.53444
#                 33     49.00000 |*************                       49.51458
#                 11     50.00000 |****                                50.46100
#
#                 10        > 95% |****                                51.04980
#
#        mean of 95%     48.52776
#          95th %ile     50.71700
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 3X to avoid.
# bin/read -E -C 200 -L -S -W -N read_zw100k -s 100k -w -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size
read_zw100k    1   1     49.03800          178        0        1   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     46.99000                46.99000
#                    max   1100.17400                57.23000
#                   mean     58.76220                50.19144
#                 median     49.29400                49.03800
#                 stddev     75.57041                 2.49900
#         standard error      5.31712                 0.18731
#   99% confidence level     12.36761                 0.43568
#                   skew     13.03299                 1.46330
#               kurtosis    175.69675                 0.79303
#       time correlation     -0.14037                 0.01433
#
#           elasped time      0.02693
#      number of samples          178
#     number of outliers           24
#      getnsecs overhead          882
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     46.00000 |*                                   46.99000
#                  0     47.00000 |                                           -
#                 38     48.00000 |***************                     48.12853
#                 78     49.00000 |********************************    49.11677
#                 21     50.00000 |********                            50.09857
#                  7     51.00000 |**                                  51.12257
#                  2     52.00000 |*                                   52.11000
#                  3     53.00000 |*                                   53.13400
#                  9     54.00000 |***                                 54.75533
#                 10     55.00000 |****                                55.25880
#
#                  9        > 95% |***                                 56.46200
#
#        mean of 95%     49.85750
#          95th %ile     55.95000
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 3X to avoid.
 
# bin/write -E -C 200 -L -S -W -N write_t1k -s 1k -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
write_t1k      1   1      7.47300          189        0        1     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      6.44900                 6.44900
#                    max    142.64100                 8.49700
#                   mean      8.60219                 7.47435
#                 median      7.47300                 7.47300
#                 stddev      9.80340                 0.39208
#         standard error      0.68977                 0.02852
#   99% confidence level      1.60439                 0.06634
#                   skew     12.74548                -0.91015
#               kurtosis    170.18146                 2.95221
#       time correlation     -0.02178                -0.00092
#
#           elasped time      0.01642
#      number of samples          189
#     number of outliers           13
#      getnsecs overhead          463
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 19      6.00000 |***                                  6.48942
#                160      7.00000 |********************************     7.54180
#
#                 10        > 95% |**                                   8.26660
#
#        mean of 95%      7.43009
#          95th %ile      7.72900
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 14X to avoid.
# bin/write -E -C 200 -L -S -W -N write_t10k -s 10k -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
write_t10k     1   1     17.14500          175        0        1    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     16.88900                16.88900
#                    max    157.94500                19.19300
#                   mean     20.29177                17.45805
#                 median     17.91300                17.14500
#                 stddev     14.71470                 0.60640
#         standard error      1.03532                 0.04584
#   99% confidence level      2.40816                 0.10662
#                   skew      7.63849                 0.72588
#               kurtosis     63.12364                -0.42471
#       time correlation      0.00287                 0.00026
#
#           elasped time      0.01948
#      number of samples          175
#     number of outliers           27
#      getnsecs overhead         1031
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 67     16.00000 |*************************           16.88900
#                 83     17.00000 |********************************    17.61690
#                 16     18.00000 |******                              18.16900
#
#                  9        > 95% |***                                 18.96544
#
#        mean of 95%     17.37633
#          95th %ile     18.93700
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 6X to avoid.
# bin/write -E -C 200 -L -S -W -N write_t100k -s 100k -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
write_t100k    1   1     93.21000          195        0        1   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     88.09000                88.09000
#                    max    845.33800               217.37000
#                   mean    134.63638               124.14136
#                 median     94.23400                93.21000
#                 stddev     78.24788                41.38979
#         standard error      5.50550                 2.96398
#   99% confidence level     12.80580                 6.89423
#                   skew      4.96929                 0.58570
#               kurtosis     36.99149                -1.41029
#       time correlation     -0.52872                -0.46059
#
#           elasped time      0.04913
#      number of samples          195
#     number of outliers            7
#      getnsecs overhead          742
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 88     88.00000 |********************************    89.90818
#                 14     92.00000 |*****                               92.73457
#                  4     96.00000 |*                                   98.01000
#                  7    100.00000 |**                                 101.87743
#                  1    104.00000 |*                                  107.29000
#                  1    108.00000 |*                                  111.13000
#                  5    112.00000 |*                                  113.28040
#                  0    116.00000 |                                           -
#                  1    120.00000 |*                                  123.16200
#                  0    124.00000 |                                           -
#                  0    128.00000 |                                           -
#                  0    132.00000 |                                           -
#                  0    136.00000 |                                           -
#                  0    140.00000 |                                           -
#                  0    144.00000 |                                           -
#                  0    148.00000 |                                           -
#                  0    152.00000 |                                           -
#                  0    156.00000 |                                           -
#                  2    160.00000 |*                                  163.22600
#                 34    164.00000 |************                       165.51494
#                 10    168.00000 |***                                169.03720
#                  1    172.00000 |*                                  173.33800
#                  1    176.00000 |*                                  177.17800
#                  1    180.00000 |*                                  182.29800
#                  9    184.00000 |***                                185.51222
#                  6    188.00000 |**                                 188.78333
#
#                 10        > 95% |***                                200.47400
#
#        mean of 95%    120.01528
#          95th %ile    191.25800
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 2X to avoid.
 
# bin/write -E -C 200 -L -S -W -N write_u1k -s 1k -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
write_u1k      1   1     11.59700          188        0        1     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      8.52500                 8.52500
#                    max    891.72500                21.58100
#                   mean     22.86100                12.47530
#                 median     11.59700                11.59700
#                 stddev     73.78142                 3.15118
#         standard error      5.19124                 0.22982
#   99% confidence level     12.07483                 0.53457
#                   skew      9.70023                 1.59469
#               kurtosis    102.43821                 1.57226
#       time correlation     -0.13349                -0.00473
#
#           elasped time      0.02014
#      number of samples          188
#     number of outliers           14
#      getnsecs overhead          435
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  6      8.00000 |**                                   8.56767
#                 31      9.00000 |**********                           9.55726
#                  2     10.00000 |*                                   10.57300
#                 92     11.00000 |********************************    11.56361
#                 24     12.00000 |********                            12.55700
#                  2     13.00000 |*                                   13.51700
#                  6     14.00000 |**                                  14.58367
#                  0     15.00000 |                                           -
#                  1     16.00000 |*                                   16.71700
#                  0     17.00000 |                                           -
#                  0     18.00000 |                                           -
#                 14     19.00000 |****                                19.56957
#
#                 10        > 95% |***                                 20.60820
#
#        mean of 95%     12.01839
#          95th %ile     19.78900
# bin/write -E -C 200 -L -S -W -N write_u10k -s 10k -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
write_u10k     1   1     16.43600          179        0        1    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     15.41200                15.41200
#                    max    266.54800                17.71600
#                   mean     19.48265                16.32588
#                 median     16.43600                16.43600
#                 stddev     20.98269                 0.52122
#         standard error      1.47634                 0.03896
#   99% confidence level      3.43396                 0.09062
#                   skew      9.57779                -0.22937
#               kurtosis    100.84546                 0.04210
#       time correlation     -0.03001                -0.00096
#
#           elasped time      0.01965
#      number of samples          179
#     number of outliers           23
#      getnsecs overhead          460
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 46     15.00000 |***********                         15.54557
#                124     16.00000 |********************************    16.53303
#
#                  9        > 95% |**                                  17.46000
#
#        mean of 95%     16.26584
#          95th %ile     16.69200
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 7X to avoid.
# bin/write -E -C 200 -L -S -W -N write_u100k -s 100k -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
write_u100k    1   1     58.22500          182        0        1   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     47.21700                47.21700
#                    max    454.51300                72.30500
#                   mean     63.03450                55.46386
#                 median     58.48100                58.22500
#                 stddev     35.58482                 6.00767
#         standard error      2.50374                 0.44532
#   99% confidence level      5.82370                 1.03581
#                   skew      7.63796                -0.12372
#               kurtosis     73.74605                -1.16864
#       time correlation     -0.16673                -0.08755
#
#           elasped time      0.02864
#      number of samples          182
#     number of outliers           20
#      getnsecs overhead          655
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 25     47.00000 |********************                47.30916
#                 33     48.00000 |**************************          48.34961
#                  5     49.00000 |****                                49.26500
#                  4     50.00000 |***                                 50.41700
#                  0     51.00000 |                                           -
#                  2     52.00000 |*                                   52.33700
#                  2     53.00000 |*                                   53.36100
#                  0     54.00000 |                                           -
#                  0     55.00000 |                                           -
#                  0     56.00000 |                                           -
#                  1     57.00000 |*                                   57.45700
#                 38     58.00000 |******************************      58.33953
#                 40     59.00000 |********************************    59.36420
#                  8     60.00000 |******                              60.36900
#                 10     61.00000 |********                            61.32260
#                  3     62.00000 |**                                  62.32100
#                  1     63.00000 |*                                   63.34500
#
#                 10        > 95% |********                            66.13540
#
#        mean of 95%     54.84342
#          95th %ile     63.34500
 
# bin/write -E -C 200 -L -S -W -N write_n1k -s 1k -I 100 -B 0 -f /dev/null 
             prc thr   usecs/call      samples   errors cnt/samp     size
write_n1k      1   1      2.64077          194        0     1000     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.50765                 2.50765
#                    max      8.21363                 2.91750
#                   mean      2.69800                 2.65184
#                 median      2.64461                 2.64077
#                 stddev      0.41335                 0.09055
#         standard error      0.02908                 0.00650
#   99% confidence level      0.06765                 0.01512
#                   skew     11.83524                 0.78273
#               kurtosis    154.08460                 0.39585
#       time correlation      0.00003                -0.00017
#
#           elasped time      0.55905
#      number of samples          194
#     number of outliers            8
#      getnsecs overhead          385
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                184      2.00000 |********************************     2.63950
#
#                 10        > 95% |*                                    2.87892
#
#        mean of 95%      2.63950
#          95th %ile      2.85274
# bin/write -E -C 200 -L -S -W -N write_n10k -s 10k -I 100 -B 0 -f /dev/null 
             prc thr   usecs/call      samples   errors cnt/samp     size
write_n10k     1   1      2.62564          182        0     1000    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.50353                 2.50353
#                    max      8.48138                 2.76157
#                   mean      2.75940                 2.61496
#                 median      2.63153                 2.62564
#                 stddev      0.64836                 0.05522
#         standard error      0.04562                 0.00409
#   99% confidence level      0.10611                 0.00952
#                   skew      5.78738                 0.12292
#               kurtosis     38.37613                -0.58906
#       time correlation     -0.00197                -0.00010
#
#           elasped time      0.57148
#      number of samples          182
#     number of outliers           20
#      getnsecs overhead          410
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                172      2.00000 |********************************     2.60822
#
#                 10        > 95% |*                                    2.73106
#
#        mean of 95%      2.60822
#          95th %ile      2.70961
# bin/write -E -C 200 -L -S -W -N write_n100k -s 100k -I 100 -B 0 -f /dev/null 
             prc thr   usecs/call      samples   errors cnt/samp     size
write_n100k    1   1      4.46800          198        0        1   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      3.44400                 3.44400
#                    max    373.62000                 8.56400
#                   mean      7.25105                 5.16360
#                 median      4.46800                 4.46800
#                 stddev     26.09478                 1.62362
#         standard error      1.83602                 0.11539
#   99% confidence level      4.27059                 0.26839
#                   skew     13.71084                 0.36348
#               kurtosis    189.37240                -1.44537
#       time correlation     -0.02476                 0.00473
#
#           elasped time      0.02037
#      number of samples          198
#     number of outliers            4
#      getnsecs overhead          396
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 88      3.00000 |********************************     3.60691
#                 23      4.00000 |********                             4.55704
#                  4      5.00000 |*                                    5.68400
#                 60      6.00000 |*********************                6.63120
#                 13      7.00000 |****                                 7.54000
#
#                 10        > 95% |***                                  8.15440
#
#        mean of 95%      5.00451
#          95th %ile      7.54000
 
# bin/writev -E -C 200 -L -S -W -N writev_t1k -s 1k -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size  vec
writev_t1k     1   1     58.10900          198        0        1     1024   10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     31.22900                31.22900
#                    max   1713.14900               108.28500
#                   mean     62.34314                52.61922
#                 median     58.10900                58.10900
#                 stddev    119.04358                19.28287
#         standard error      8.37588                 1.37037
#   99% confidence level     19.48229                 3.18749
#                   skew     13.20902                 0.53532
#               kurtosis    180.08346                -0.35363
#       time correlation     -0.50632                -0.26489
#
#           elasped time      0.03853
#      number of samples          198
#     number of outliers            4
#      getnsecs overhead          771
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 21     30.00000 |**************                      31.33871
#                 45     32.00000 |******************************      32.34402
#                 10     34.00000 |******                              34.50580
#                  3     36.00000 |**                                  36.43433
#                  2     38.00000 |*                                   38.14100
#                  0     40.00000 |                                           -
#                  0     42.00000 |                                           -
#                  2     44.00000 |*                                   45.18100
#                  1     46.00000 |*                                   46.33300
#                  1     48.00000 |*                                   49.14900
#                  0     50.00000 |                                           -
#                  1     52.00000 |*                                   52.98900
#                  0     54.00000 |                                           -
#                  3     56.00000 |**                                  57.25567
#                 48     58.00000 |********************************    58.66900
#                  3     60.00000 |**                                  60.49833
#                  8     62.00000 |*****                               62.84500
#                  4     64.00000 |**                                  65.27700
#                  4     66.00000 |**                                  66.17300
#                 12     68.00000 |********                            68.92500
#                  6     70.00000 |****                                70.52500
#                  1     72.00000 |*                                   72.18900
#                  2     74.00000 |*                                   74.74900
#                  3     76.00000 |**                                  76.88233
#                  4     78.00000 |**                                  79.22900
#                  1     80.00000 |*                                   80.38100
#                  1     82.00000 |*                                   82.17300
#                  1     84.00000 |*                                   85.24500
#                  1     86.00000 |*                                   86.01300
#
#                 10        > 95% |******                              98.42900
#
#        mean of 95%     50.18253
#          95th %ile     89.08500
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 2X to avoid.
# bin/writev -E -C 200 -L -S -W -N writev_t10k -s 10k -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size  vec
writev_t10k    1   1    145.76000          189        0        1    10240   10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    140.38400               140.38400
#                    max    685.66400               172.64000
#                   mean    159.89450               149.15572
#                 median    146.52800               145.76000
#                 stddev     51.39801                 7.87406
#         standard error      3.61635                 0.57275
#   99% confidence level      8.41163                 1.33222
#                   skew      6.61582                 1.37363
#               kurtosis     55.90125                 0.77994
#       time correlation     -0.10836                -0.00044
#
#           elasped time      0.04809
#      number of samples          189
#     number of outliers           13
#      getnsecs overhead          416
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  3    140.00000 |***                                140.55467
#                  8    141.00000 |*********                          141.56800
#                 17    142.00000 |*******************                142.61271
#                 22    143.00000 |*************************          143.58400
#                 28    144.00000 |********************************   144.57143
#                 19    145.00000 |*********************              145.58484
#                 15    146.00000 |*****************                  146.59627
#                 10    147.00000 |***********                        147.55200
#                 14    148.00000 |****************                   148.57600
#                  5    149.00000 |*****                              149.60000
#                  4    150.00000 |****                               150.62400
#                  0    151.00000 |                                           -
#                  0    152.00000 |                                           -
#                  1    153.00000 |*                                  153.69600
#                  3    154.00000 |***                                154.54933
#                  1    155.00000 |*                                  155.74400
#                  2    156.00000 |**                                 156.64000
#                  1    157.00000 |*                                  157.53600
#                  8    158.00000 |*********                          158.56000
#                  5    159.00000 |*****                              159.53280
#                  2    160.00000 |**                                 160.60800
#                  0    161.00000 |                                           -
#                  3    162.00000 |***                                162.57067
#                  3    163.00000 |***                                163.59467
#                  2    164.00000 |**                                 164.57600
#                  2    165.00000 |**                                 165.60000
#                  1    166.00000 |*                                  166.49600
#
#                 10        > 95% |***********                        169.72160
#
#        mean of 95%    148.00679
#          95th %ile    166.75200
# bin/writev -E -C 200 -L -S -W -N writev_t100k -s 100k -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size  vec
writev_t100k   1   1   1070.68400          176        0        1   102400   10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min   1048.66800              1048.66800
#                    max  12890.46000              1223.77200
#                   mean   1225.60962              1092.87018
#                 median   1077.59600              1070.68400
#                 stddev    863.43927                46.22509
#         standard error     60.75137                 3.48435
#   99% confidence level    141.30770                 8.10459
#                   skew     12.28726                 1.24281
#               kurtosis    162.02469                 0.33117
#       time correlation     -3.58335                -0.12303
#
#           elasped time      0.26675
#      number of samples          176
#     number of outliers           26
#      getnsecs overhead          420
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2   1045.00000 |*                                 1049.05200
#                 13   1050.00000 |************                      1052.29138
#                 34   1055.00000 |********************************  1058.00447
#                 24   1060.00000 |**********************            1062.35333
#                 12   1065.00000 |***********                       1068.52933
#                 13   1070.00000 |************                      1071.88523
#                  6   1075.00000 |*****                             1077.76667
#                  7   1080.00000 |******                            1082.13086
#                  8   1085.00000 |*******                           1087.70800
#                  5   1090.00000 |****                              1091.67600
#                  3   1095.00000 |**                                1097.56400
#                  1   1100.00000 |*                                 1102.42800
#                  0   1105.00000 |                                           -
#                  2   1110.00000 |*                                 1111.90000
#                  1   1115.00000 |*                                 1119.58000
#                  4   1120.00000 |***                               1123.67600
#                  2   1125.00000 |*                                 1128.15600
#                  1   1130.00000 |*                                 1134.68400
#                  2   1135.00000 |*                                 1138.01200
#                  1   1140.00000 |*                                 1140.57200
#                  5   1145.00000 |****                              1146.71600
#                  5   1150.00000 |****                              1152.39920
#                  5   1155.00000 |****                              1157.87760
#                  4   1160.00000 |***                               1162.33200
#                  2   1165.00000 |*                                 1167.06800
#                  0   1170.00000 |                                           -
#                  0   1175.00000 |                                           -
#                  1   1180.00000 |*                                 1182.55600
#                  3   1185.00000 |**                                1186.90800
#                  1   1190.00000 |*                                 1191.51600
#
#                  9        > 95% |********                          1210.68756
#
#        mean of 95%   1086.52074
#          95th %ile   1193.56400
 
# bin/writev -E -C 200 -L -S -W -N writev_u1k -s 1k -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size  vec
writev_u1k     1   1     87.22200          192        0        1     1024   10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     41.14200                41.14200
#                    max    668.08600               155.31800
#                   mean     97.65083                84.15000
#                 median     87.99000                87.22200
#                 stddev     73.02103                23.94198
#         standard error      5.13774                 1.72786
#   99% confidence level     11.95039                 4.01901
#                   skew      5.19831                -0.39083
#               kurtosis     33.28319                -0.22359
#       time correlation     -0.35628                -0.28164
#
#           elasped time      0.04387
#      number of samples          192
#     number of outliers           10
#      getnsecs overhead          842
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  6     39.00000 |****                                41.14200
#                 25     42.00000 |******************                  42.51416
#                  5     45.00000 |***                                 45.95480
#                  0     48.00000 |                                           -
#                  0     51.00000 |                                           -
#                  1     54.00000 |*                                   55.99000
#                  1     57.00000 |*                                   57.27000
#                  0     60.00000 |                                           -
#                  0     63.00000 |                                           -
#                  1     66.00000 |*                                   66.23000
#                  1     69.00000 |*                                   70.32600
#                  1     72.00000 |*                                   74.93400
#                 13     75.00000 |*********                           76.03677
#                  2     78.00000 |*                                   79.15800
#                  0     81.00000 |                                           -
#                 24     84.00000 |*****************                   86.00600
#                 43     87.00000 |********************************    87.81140
#                 11     90.00000 |********                            90.78273
#                 10     93.00000 |*******                             94.13400
#                  5     96.00000 |***                                 96.38680
#                  4     99.00000 |**                                 100.66200
#                  5    102.00000 |***                                103.35000
#                  7    105.00000 |*****                              106.12943
#                  3    108.00000 |**                                 109.15267
#                  4    111.00000 |**                                 112.43800
#                  4    114.00000 |**                                 115.70200
#                  5    117.00000 |***                                118.35160
#                  1    120.00000 |*                                  120.24600
#
#                 10        > 95% |*******                            126.95320
#
#        mean of 95%     81.79818
#          95th %ile    120.24600
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 2X to avoid.
# bin/writev -E -C 200 -L -S -W -N writev_u10k -s 10k -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size  vec
writev_u10k    1   1    173.37900          189        0        1    10240   10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     82.49900                82.49900
#                    max   7377.47500               304.70700
#                   mean    205.97338               151.05147
#                 median    173.63500               173.37900
#                 stddev    516.73410                54.91506
#         standard error     36.35728                 3.99448
#   99% confidence level     84.56704                 9.29117
#                   skew     13.24514                 0.09422
#               kurtosis    180.67713                -0.74087
#       time correlation     -0.89061                -0.80010
#
#           elasped time      0.06376
#      number of samples          189
#     number of outliers           13
#      getnsecs overhead          445
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 52     80.00000 |********************************    83.64115
#                  8     85.00000 |****                                87.07500
#                  5     90.00000 |***                                 90.94700
#                  4     95.00000 |**                                  97.66700
#                  0    100.00000 |                                           -
#                  1    105.00000 |*                                  108.35500
#                  0    110.00000 |                                           -
#                  0    115.00000 |                                           -
#                  0    120.00000 |                                           -
#                  0    125.00000 |                                           -
#                  0    130.00000 |                                           -
#                  0    135.00000 |                                           -
#                  0    140.00000 |                                           -
#                  0    145.00000 |                                           -
#                  7    150.00000 |****                               153.00871
#                  3    155.00000 |*                                  158.61633
#                  1    160.00000 |*                                  160.32300
#                  1    165.00000 |*                                  169.79500
#                 26    170.00000 |****************                   173.31008
#                 20    175.00000 |************                       178.08940
#                 10    180.00000 |******                             182.21100
#                  8    185.00000 |****                               187.90700
#                  6    190.00000 |***                                191.89633
#                  5    195.00000 |***                                197.80140
#                  8    200.00000 |****                               203.45900
#                  7    205.00000 |****                               207.06129
#                  5    210.00000 |***                                212.75180
#                  2    215.00000 |*                                  215.49100
#
#                 10        > 95% |******                             256.65580
#
#        mean of 95%    145.15178
#          95th %ile    215.61900
#
# WARNINGS
#     Quantization error likely;increase batch size (-B option) 1X to avoid.
# bin/writev -E -C 200 -L -S -W -N writev_u100k -s 100k -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size  vec
writev_u100k   1   1    542.55200          171        0        1   102400   10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    521.56000               521.56000
#                    max   4723.54400               674.64800
#                   mean    659.68721               560.61422
#                 median    547.41600               542.55200
#                 stddev    362.82633                39.55286
#         standard error     25.52837                 3.02468
#   99% confidence level     59.37899                 7.03541
#                   skew      7.49172                 1.23296
#               kurtosis     76.01036                 0.32365
#       time correlation     -2.41888                 0.03260
#
#           elasped time      0.15352
#      number of samples          171
#     number of outliers           31
#      getnsecs overhead          424
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 13    520.00000 |************                       523.56862
#                 17    525.00000 |****************                   527.20706
#                 15    530.00000 |**************                     533.04587
#                 33    535.00000 |********************************   537.24582
#                 17    540.00000 |****************                   542.56706
#                 12    545.00000 |***********                        547.82133
#                  7    550.00000 |******                             552.35314
#                  3    555.00000 |**                                 558.59467
#                  2    560.00000 |*                                  561.11200
#                  5    565.00000 |****                               567.02560
#                  3    570.00000 |**                                 572.58933
#                  2    575.00000 |*                                  577.49600
#                  0    580.00000 |                                           -
#                  1    585.00000 |*                                  586.58400
#                  1    590.00000 |*                                  591.70400
#                  1    595.00000 |*                                  598.61600
#                  6    600.00000 |*****                              602.11467
#                  6    605.00000 |*****                              606.59467
#                  5    610.00000 |****                               612.54240
#                  3    615.00000 |**                                 616.19467
#                  2    620.00000 |*                                  622.04000
#                  3    625.00000 |**                                 627.54400
#                  0    630.00000 |                                           -
#                  3    635.00000 |**                                 636.16267
#                  1    640.00000 |*                                  643.41600
#                  1    645.00000 |*                                  647.51200
#
#                  9        > 95% |********                           659.43022
#
#        mean of 95%    555.12444
#          95th %ile    647.51200
 
# bin/writev -E -C 200 -L -S -W -N writev_n1k -s 1k -I 100 -B 0 -f /dev/null 
             prc thr   usecs/call      samples   errors cnt/samp     size  vec
writev_n1k     1   1     17.17464          176        0     1000     1024   10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     16.21669                16.21669
#                    max     36.29553                18.90161
#                   mean     18.33858                17.27162
#                 median     17.28241                17.17464
#                 stddev      3.26186                 0.54658
#         standard error      0.22950                 0.04120
#   99% confidence level      0.53383                 0.09583
#                   skew      3.26425                 0.68685
#               kurtosis     11.22426                 0.25150
#       time correlation     -0.00425                 0.00052
#
#           elasped time      3.72623
#      number of samples          176
#     number of outliers           26
#      getnsecs overhead          402
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 59     16.00000 |*******************                 16.73046
#                 97     17.00000 |********************************    17.38003
#                 11     18.00000 |***                                 18.12789
#
#                  9        > 95% |**                                  18.60414
#
#        mean of 95%     17.19980
#          95th %ile     18.28363
# bin/writev -E -C 200 -L -S -W -N writev_n10k -s 10k -I 100 -B 0 -f /dev/null 
             prc thr   usecs/call      samples   errors cnt/samp     size  vec
writev_n10k    1   1     30.34000          186        0        1    10240   10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     16.26000                16.26000
#                    max    220.29200                47.23600
#                   mean     34.24844                30.31798
#                 median     31.10800                30.34000
#                 stddev     19.93605                 5.89112
#         standard error      1.40270                 0.43196
#   99% confidence level      3.26267                 1.00473
#                   skew      6.34099                 0.41805
#               kurtosis     49.84187                 0.37098
#       time correlation     -0.11427                -0.05343
#
#           elasped time      0.03292
#      number of samples          186
#     number of outliers           16
#      getnsecs overhead          636
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  4     16.00000 |***                                 16.32400
#                  1     17.00000 |*                                   17.28400
#                  1     18.00000 |*                                   18.30800
#                  1     19.00000 |*                                   19.33200
#                  1     20.00000 |*                                   20.35600
#                  0     21.00000 |                                           -
#                  0     22.00000 |                                           -
#                  1     23.00000 |*                                   23.42800
#                  4     24.00000 |***                                 24.32400
#                 34     25.00000 |********************************    25.37059
#                 20     26.00000 |******************                  26.35920
#                  8     27.00000 |*******                             27.46000
#                 10     28.00000 |*********                           28.36880
#                  6     29.00000 |*****                               29.35867
#                 10     30.00000 |*********                           30.34000
#                 19     31.00000 |*****************                   31.35053
#                 18     32.00000 |****************                    32.33111
#                  6     33.00000 |*****                               33.32667
#                  5     34.00000 |****                                34.38480
#                  7     35.00000 |******                              35.38686
#                  4     36.00000 |***                                 36.35600
#                  3     37.00000 |**                                  37.25200
#                  4     38.00000 |***                                 38.40400
#                  6     39.00000 |*****                               39.38533
#                  2     40.00000 |*                                   40.32400
#                  1     41.00000 |*                                   41.34800
#
#                 10        > 95% |*********                           43.88240
#
#        mean of 95%     29.54727
#          95th %ile     41.34800
# bin/writev -E -C 200 -L -S -W -N writev_n100k -s 100k -I 100 -B 0 -f /dev/null 
             prc thr   usecs/call      samples   errors cnt/samp     size  vec
writev_n100k   1   1     17.38252          192        0     1000   102400   10
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     16.03545                16.03545
#                    max     49.22355                29.54867
#                   mean     19.86766                19.04266
#                 median     17.42758                17.38252
#                 stddev      5.15986                 3.52403
#         standard error      0.36305                 0.25432
#   99% confidence level      0.84445                 0.59156
#                   skew      2.34513                 1.53596
#               kurtosis      6.80615                 0.86589
#       time correlation     -0.00315                -0.00498
#
#           elasped time      4.03351
#      number of samples          192
#     number of outliers           10
#      getnsecs overhead          389
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 59     16.00000 |*************************           16.74800
#                 73     17.00000 |********************************    17.38365
#                 14     18.00000 |******                              18.36445
#                  3     19.00000 |*                                   19.73064
#                  0     20.00000 |                                           -
#                  3     21.00000 |*                                   21.47502
#                  9     22.00000 |***                                 22.52821
#                  4     23.00000 |*                                   23.34982
#                  2     24.00000 |*                                   24.37759
#                  4     25.00000 |*                                   25.58310
#                 10     26.00000 |****                                26.51212
#                  1     27.00000 |*                                   27.05267
#
#                 10        > 95% |****                                27.89191
#
#        mean of 95%     18.55644
#          95th %ile     27.16070
 
# bin/pread -E -C 200 -L -S -W -N pread_t1k -s 1k -I 300 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pread_t1k      1   1      5.26050          185        0      333     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      5.00757                 5.00757
#                    max     10.73413                 5.96008
#                   mean      5.53502                 5.32670
#                 median      5.32046                 5.26050
#                 stddev      0.83535                 0.21905
#         standard error      0.05877                 0.01610
#   99% confidence level      0.13671                 0.03746
#                   skew      4.04707                 0.91154
#               kurtosis     18.31822                 0.13559
#       time correlation     -0.00405                -0.00026
#
#           elasped time      0.38672
#      number of samples          185
#     number of outliers           17
#      getnsecs overhead          318
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                175      5.00000 |********************************     5.29532
#
#                 10        > 95% |*                                    5.87582
#
#        mean of 95%      5.29532
#          95th %ile      5.79787
# bin/pread -E -C 200 -L -S -W -N pread_t10k -s 10k -I 1000 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pread_t10k     1   1     12.49269          174        0      100    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     12.22133                12.22133
#                    max     79.15253                14.25397
#                   mean     14.34820                12.73099
#                 median     12.57205                12.49269
#                 stddev      6.16960                 0.53716
#         standard error      0.43409                 0.04072
#   99% confidence level      1.00970                 0.09472
#                   skew      6.87019                 1.23420
#               kurtosis     61.50486                 0.39519
#       time correlation     -0.02374                -0.00051
#
#           elasped time      0.30623
#      number of samples          174
#     number of outliers           28
#      getnsecs overhead          779
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                125     12.00000 |********************************    12.43293
#                 40     13.00000 |**********                          13.35509
#
#                  9        > 95% |**                                  14.09696
#
#        mean of 95%     12.65648
#          95th %ile     13.85205
# bin/pread -E -C 200 -L -S -W -N pread_t100k -s 100k -I 10000 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pread_t100k    1   1     90.75490          178        0       10   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     88.45090                88.45090
#                    max    311.14530               104.86050
#                   mean     97.93139                92.76536
#                 median     90.93410                90.75490
#                 stddev     21.79848                 4.29214
#         standard error      1.53374                 0.32171
#   99% confidence level      3.56747                 0.74830
#                   skew      6.52781                 1.49959
#               kurtosis     52.89606                 0.86837
#       time correlation     -0.08599                -0.00893
#
#           elasped time      0.21103
#      number of samples          178
#     number of outliers           24
#      getnsecs overhead          483
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  9     88.00000 |***                                 88.72397
#                 15     89.00000 |*****                               89.83159
#                 82     90.00000 |********************************    90.46456
#                 22     91.00000 |********                            91.47519
#                  6     92.00000 |**                                  92.77303
#                  5     93.00000 |*                                   93.55554
#                  1     94.00000 |*                                   94.05730
#                  2     95.00000 |*                                   95.95170
#                  2     96.00000 |*                                   96.55330
#                  2     97.00000 |*                                   97.50050
#                  6     98.00000 |**                                  98.43490
#                  6     99.00000 |**                                  99.36930
#                  5    100.00000 |*                                  100.49826
#                  3    101.00000 |*                                  101.36183
#                  3    102.00000 |*                                  102.64183
#
#                  9        > 95% |***                                103.98726
#
#        mean of 95%     92.16775
#          95th %ile    102.86370
 
# bin/pread -E -C 200 -L -S -W -N pread_u1k -s 1k -I 300 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pread_u1k      1   1      5.95074          191        0      333     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      5.54252                 5.54252
#                    max     22.73142                 7.10696
#                   mean      6.23452                 6.04477
#                 median      6.00532                 5.95074
#                 stddev      1.33859                 0.40648
#         standard error      0.09418                 0.02941
#   99% confidence level      0.21907                 0.06841
#                   skew      9.55473                 0.52463
#               kurtosis    112.02653                -0.90091
#       time correlation      0.00217                 0.00082
#
#           elasped time      0.43498
#      number of samples          191
#     number of outliers           11
#      getnsecs overhead          357
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                101      5.00000 |********************************     5.71184
#                 80      6.00000 |*************************            6.35888
#
#                 10        > 95% |***                                  6.89455
#
#        mean of 95%      5.99782
#          95th %ile      6.77947
# bin/pread -E -C 200 -L -S -W -N pread_u10k -s 10k -I 1000 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pread_u10k     1   1      9.48485          188        0      100    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      9.31589                 9.31589
#                    max     17.53605                11.18469
#                   mean     10.10684                 9.75300
#                 median      9.51557                 9.48485
#                 stddev      1.46806                 0.49996
#         standard error      0.10329                 0.03646
#   99% confidence level      0.24026                 0.08481
#                   skew      3.34854                 1.29564
#               kurtosis     11.66265                 0.31502
#       time correlation      0.00063                -0.00112
#
#           elasped time      0.21686
#      number of samples          188
#     number of outliers           14
#      getnsecs overhead          507
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                140      9.00000 |********************************     9.48258
#                 38     10.00000 |********                            10.41918
#
#                 10        > 95% |**                                  11.00728
#
#        mean of 95%      9.68253
#          95th %ile     10.89285
# bin/pread -E -C 200 -L -S -W -N pread_u100k -s 100k -I 10000 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pread_u100k    1   1     65.78200          177        0       10   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     63.45240                63.45240
#                    max    264.97560                84.85400
#                   mean     74.57459                68.37888
#                 median     66.26840                65.78200
#                 stddev     22.00321                 5.58184
#         standard error      1.54814                 0.41956
#   99% confidence level      3.60097                 0.97589
#                   skew      4.65435                 1.65003
#               kurtosis     29.67220                 1.64456
#       time correlation     -0.16043                -0.04740
#
#           elasped time      0.16364
#      number of samples          177
#     number of outliers           25
#      getnsecs overhead          356
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 19     63.00000 |**********                          63.80945
#                 19     64.00000 |**********                          64.47236
#                 57     65.00000 |********************************    65.46896
#                 22     66.00000 |************                        66.47785
#                  7     67.00000 |***                                 67.59960
#                  8     68.00000 |****                                68.31640
#                  1     69.00000 |*                                   69.05880
#                  3     70.00000 |*                                   70.56920
#                  6     71.00000 |***                                 71.52493
#                  4     72.00000 |**                                  72.34200
#                  3     73.00000 |*                                   73.49613
#                  4     74.00000 |**                                  74.56920
#                  4     75.00000 |**                                  75.30520
#                  1     76.00000 |*                                   76.35480
#                  3     77.00000 |*                                   77.35320
#                  1     78.00000 |*                                   78.07000
#                  0     79.00000 |                                           -
#                  2     80.00000 |*                                   80.63000
#                  1     81.00000 |*                                   81.85880
#                  2     82.00000 |*                                   82.06360
#                  1     83.00000 |*                                   83.16440
#
#                  9        > 95% |*****                               83.95231
#
#        mean of 95%     67.54459
#          95th %ile     83.16440
 
# bin/pread -E -C 200 -L -S -W -N pread_z1k -s 1k -I 300 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size
pread_z1k      1   1      3.62369          181        0      333     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      3.53067                 3.53067
#                    max      8.52998                 4.18797
#                   mean      3.94930                 3.70972
#                 median      3.64445                 3.62369
#                 stddev      0.83267                 0.16783
#         standard error      0.05859                 0.01247
#   99% confidence level      0.13627                 0.02902
#                   skew      3.52492                 1.14235
#               kurtosis     12.82824                 0.14242
#       time correlation     -0.00553                -0.00011
#
#           elasped time      0.27769
#      number of samples          181
#     number of outliers           21
#      getnsecs overhead          350
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                166      3.00000 |********************************     3.67517
#                  5      4.00000 |*                                    4.02453
#
#                 10        > 95% |*                                    4.12578
#
#        mean of 95%      3.68538
#          95th %ile      4.06189
# bin/pread -E -C 200 -L -S -W -N pread_z10k -s 10k -I 1000 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size
pread_z10k     1   1      7.90228          186        0      100    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      7.69236                 7.69236
#                    max     15.06004                 9.68404
#                   mean      8.32464                 8.11892
#                 median      7.94324                 7.90228
#                 stddev      0.93101                 0.53250
#         standard error      0.06551                 0.03904
#   99% confidence level      0.15237                 0.09082
#                   skew      2.91697                 1.78401
#               kurtosis     13.18389                 1.66810
#       time correlation     -0.00074                -0.00021
#
#           elasped time      0.18063
#      number of samples          186
#     number of outliers           16
#      getnsecs overhead          812
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                125      7.00000 |********************************     7.84918
#                 36      8.00000 |*********                            8.19419
#                 15      9.00000 |***                                  9.23672
#
#                 10        > 95% |**                                   9.54298
#
#        mean of 95%      8.03800
#          95th %ile      9.36148
# bin/pread -E -C 200 -L -S -W -N pread_z100k -s 100k -I 2000 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size
pread_z100k    1   1     99.58800          196        0        1   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     47.36400                47.36400
#                    max   3057.41200               145.41200
#                   mean    113.09010                91.88971
#                 median     99.58800                99.58800
#                 stddev    214.16271                22.43586
#         standard error     15.06844                 1.60256
#   99% confidence level     35.04918                 3.72756
#                   skew     12.92038                -0.65863
#               kurtosis    173.95802                 0.36196
#       time correlation     -0.76972                -0.27152
#
#           elasped time      0.04352
#      number of samples          196
#     number of outliers            6
#      getnsecs overhead          508
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 11     45.00000 |****                                47.45709
#                 20     48.00000 |*******                             48.56720
#                  0     51.00000 |                                           -
#                  0     54.00000 |                                           -
#                  0     57.00000 |                                           -
#                  2     60.00000 |*                                   60.42000
#                  1     63.00000 |*                                   63.49200
#                  0     66.00000 |                                           -
#                  0     69.00000 |                                           -
#                  0     72.00000 |                                           -
#                  0     75.00000 |                                           -
#                  0     78.00000 |                                           -
#                  0     81.00000 |                                           -
#                  4     84.00000 |*                                   86.21200
#                 34     87.00000 |*************                       88.36165
#                  4     90.00000 |*                                   91.46000
#                  0     93.00000 |                                           -
#                  7     96.00000 |**                                  98.52743
#                 82     99.00000 |********************************   100.43093
#                  8    102.00000 |***                                103.20400
#                  4    105.00000 |*                                  107.01200
#                  1    108.00000 |*                                  109.57200
#                  1    111.00000 |*                                  113.41200
#                  0    114.00000 |                                           -
#                  2    117.00000 |*                                  119.04400
#                  2    120.00000 |*                                  120.83600
#                  3    123.00000 |*                                  124.42000
#
#                 10        > 95% |***                                136.29840
#
#        mean of 95%     89.50215
#          95th %ile    125.44400
# bin/pread -E -C 200 -L -S -W -N pread_zw100k -s 100k -w -I 10000 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size
pread_zw100k   1   1     49.71920          158        0       10   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     48.13200                48.13200
#                    max    286.51920                52.22800
#                   mean     56.34440                49.71466
#                 median     49.92400                49.71920
#                 stddev     22.93225                 0.98777
#         standard error      1.61351                 0.07858
#   99% confidence level      3.75302                 0.18278
#                   skew      6.18774                 0.53627
#               kurtosis     50.96023                -0.40978
#       time correlation     -0.15736                 0.00110
#
#           elasped time      0.12876
#      number of samples          158
#     number of outliers           44
#      getnsecs overhead          728
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 45     48.00000 |************************            48.58028
#                 59     49.00000 |********************************    49.57775
#                 36     50.00000 |*******************                 50.39831
#                 10     51.00000 |*****                               51.42672
#
#                  8        > 95% |****                                51.88880
#
#        mean of 95%     49.59871
#          95th %ile     51.74160
 
# bin/pwrite -E -C 200 -L -S -W -N pwrite_t1k -s 1k -I 500 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pwrite_t1k     1   1      8.57792          169        0      200     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      8.30272                 8.30272
#                    max     34.89728                 9.64416
#                   mean      9.73560                 8.71412
#                 median      8.83263                 8.57792
#                 stddev      2.85004                 0.31803
#         standard error      0.20053                 0.02446
#   99% confidence level      0.46643                 0.05690
#                   skew      4.34693                 0.70066
#               kurtosis     29.14640                -0.51201
#       time correlation     -0.01287                -0.00006
#
#           elasped time      0.41333
#      number of samples          169
#     number of outliers           33
#      getnsecs overhead          385
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                133      8.00000 |********************************     8.58555
#                 27      9.00000 |******                               9.11153
#
#                  9        > 95% |**                                   9.42186
#
#        mean of 95%      8.67431
#          95th %ile      9.29856
# bin/pwrite -E -C 200 -L -S -W -N pwrite_t10k -s 10k -I 1000 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pwrite_t10k    1   1     13.80706          178        0      100    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     13.43586                13.43586
#                    max     42.19490                15.70658
#                   mean     14.92323                14.06325
#                 median     13.90690                13.80706
#                 stddev      3.52015                 0.54942
#         standard error      0.24768                 0.04118
#   99% confidence level      0.57610                 0.09579
#                   skew      5.08923                 0.97182
#               kurtosis     28.48129                -0.08537
#       time correlation     -0.02031                 0.00075
#
#           elasped time      0.31701
#      number of samples          178
#     number of outliers           24
#      getnsecs overhead          414
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                109     13.00000 |********************************    13.68134
#                 57     14.00000 |****************                    14.52988
#                  3     15.00000 |*                                   15.06573
#
#                  9        > 95% |**                                  15.39910
#
#        mean of 95%     13.99211
#          95th %ile     15.10498
# bin/pwrite -E -C 200 -L -S -W -N pwrite_t100k -s 100k -I 10000 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pwrite_t100k   1   1     93.72170          172        0       10   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     91.92970                91.92970
#                    max    378.00970               104.42250
#                   mean    108.71772                95.33882
#                 median     94.31050                93.72170
#                 stddev     40.27602                 3.31674
#         standard error      2.83381                 0.25290
#   99% confidence level      6.59144                 0.58824
#                   skew      3.43109                 1.32986
#               kurtosis     13.14704                 0.33148
#       time correlation     -0.33303                -0.00537
#
#           elasped time      0.23573
#      number of samples          172
#     number of outliers           30
#      getnsecs overhead          767
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     91.00000 |*                                   91.92970
#                 27     92.00000 |*************                       92.68537
#                 65     93.00000 |********************************    93.40229
#                 28     94.00000 |*************                       94.42479
#                 11     95.00000 |*****                               95.52301
#                  2     96.00000 |*                                   96.26890
#                  0     97.00000 |                                           -
#                  4     98.00000 |*                                   98.77130
#                  4     99.00000 |*                                   99.60970
#                 10    100.00000 |****                               100.32906
#                  9    101.00000 |****                               101.39032
#                  2    102.00000 |*                                  102.32330
#
#                  9        > 95% |****                               103.50374
#
#        mean of 95%     94.88799
#          95th %ile    102.63050
 
# bin/pwrite -E -C 200 -L -S -W -N pwrite_u1k -s 1k -I 500 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pwrite_u1k     1   1      8.62673          190        0      200     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      8.34641                 8.34641
#                    max     36.25681                10.46609
#                   mean      9.39622                 8.96070
#                 median      8.82641                 8.62673
#                 stddev      2.43033                 0.55491
#         standard error      0.17100                 0.04026
#   99% confidence level      0.39774                 0.09364
#                   skew      7.64392                 0.76181
#               kurtosis     74.19098                -0.48031
#       time correlation     -0.00081                 0.00057
#
#           elasped time      0.39332
#      number of samples          190
#     number of outliers           12
#      getnsecs overhead          606
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                104      8.00000 |********************************     8.50944
#                 74      9.00000 |**********************               9.39046
#                  2     10.00000 |*                                   10.06929
#
#                 10        > 95% |***                                 10.25195
#
#        mean of 95%      8.88897
#          95th %ile     10.10129
# bin/pwrite -E -C 200 -L -S -W -N pwrite_u10k -s 10k -I 1000 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pwrite_u10k    1   1     14.03647          171        0      100    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     13.71391                13.71391
#                    max     70.67647                16.56319
#                   mean     16.08560                14.52628
#                 median     14.18495                14.03647
#                 stddev      5.23616                 0.82408
#         standard error      0.36842                 0.06302
#   99% confidence level      0.85693                 0.14658
#                   skew      6.33198                 0.76047
#               kurtosis     57.28687                -0.97890
#       time correlation     -0.00456                 0.00024
#
#           elasped time      0.33905
#      number of samples          171
#     number of outliers           31
#      getnsecs overhead          513
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 79     13.00000 |********************************    13.86427
#                 32     14.00000 |************                        14.16743
#                 51     15.00000 |********************                15.46997
#
#                  9        > 95% |***                                 16.26566
#
#        mean of 95%     14.42965
#          95th %ile     15.96415
# bin/pwrite -E -C 200 -L -S -W -N pwrite_u100k -s 100k -I 20000 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size
pwrite_u100k   1   1     51.30480          192        0        5   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     47.26000                47.26000
#                    max    200.70640               141.72400
#                   mean     73.72001                67.96613
#                 median     52.32880                51.30480
#                 stddev     35.58773                25.54004
#         standard error      2.50394                 1.84319
#   99% confidence level      5.82417                 4.28727
#                   skew      1.63049                 0.94665
#               kurtosis      2.47777                -0.37228
#       time correlation     -0.39975                -0.32250
#
#           elasped time      0.09055
#      number of samples          192
#     number of outliers           10
#      getnsecs overhead          500
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 60     45.00000 |********************************    47.59109
#                 29     48.00000 |***************                     49.00257
#                 16     51.00000 |********                            51.75280
#                  6     54.00000 |***                                 54.35973
#                  3     57.00000 |*                                   58.76293
#                  2     60.00000 |*                                   62.67120
#                  3     63.00000 |*                                   64.58267
#                  3     66.00000 |*                                   66.88667
#                  0     69.00000 |                                           -
#                  2     72.00000 |*                                   73.62800
#                  2     75.00000 |*                                   76.26480
#                  4     78.00000 |**                                  79.40080
#                  2     81.00000 |*                                   81.97360
#                  3     84.00000 |*                                   86.71813
#                  9     87.00000 |****                                88.23707
#                  5     90.00000 |**                                  91.75280
#                  7     93.00000 |***                                 93.93246
#                  5     96.00000 |**                                  97.58960
#                  4     99.00000 |**                                 100.57200
#                  8    102.00000 |****                               103.80400
#                  5    105.00000 |**                                 106.05808
#                  3    108.00000 |*                                  109.87760
#                  1    111.00000 |*                                  111.51600
#
#                 10        > 95% |*****                              127.86928
#
#        mean of 95%     64.67475
#          95th %ile    112.48880
 
# bin/pwrite -E -C 200 -L -S -W -N pwrite_n1k -s 1k -I 100 -f /dev/null 
             prc thr   usecs/call      samples   errors cnt/samp     size
pwrite_n1k     1   1      2.51343          173        0     1000     1024
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.40258                 2.40258
#                    max      7.86664                 2.67548
#                   mean      2.65700                 2.50279
#                 median      2.51957                 2.51343
#                 stddev      0.52019                 0.05885
#         standard error      0.03660                 0.00447
#   99% confidence level      0.08513                 0.01041
#                   skew      5.83048                 0.43153
#               kurtosis     48.77763                -0.31130
#       time correlation     -0.00085                -0.00022
#
#           elasped time      0.55085
#      number of samples          173
#     number of outliers           29
#      getnsecs overhead          492
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                164      2.00000 |********************************     2.49544
#
#                  9        > 95% |*                                    2.63682
#
#        mean of 95%      2.49544
#          95th %ile      2.61045
# bin/pwrite -E -C 200 -L -S -W -N pwrite_n10k -s 10k -I 100 -f /dev/null 
             prc thr   usecs/call      samples   errors cnt/samp     size
pwrite_n10k    1   1      2.57856          173        0     1000    10240
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.47565                 2.47565
#                    max      8.03546                 2.74957
#                   mean      2.77073                 2.57593
#                 median      2.58854                 2.57856
#                 stddev      0.60755                 0.06307
#         standard error      0.04275                 0.00480
#   99% confidence level      0.09943                 0.01115
#                   skew      4.52491                 0.33384
#               kurtosis     28.65297                -0.45649
#       time correlation     -0.00232                -0.00017
#
#           elasped time      0.57316
#      number of samples          173
#     number of outliers           29
#      getnsecs overhead          385
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                164      2.00000 |********************************     2.56834
#
#                  9        > 95% |*                                    2.71415
#
#        mean of 95%      2.56834
#          95th %ile      2.69555
# bin/pwrite -E -C 200 -L -S -W -N pwrite_n100k -s 100k -I 100 -f /dev/null 
             prc thr   usecs/call      samples   errors cnt/samp     size
pwrite_n100k   1   1      2.64732          178        0     1000   102400
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      2.54338                 2.54338
#                    max      8.04559                 2.81756
#                   mean      2.81842                 2.64336
#                 median      2.65167                 2.64732
#                 stddev      0.59736                 0.06415
#         standard error      0.04203                 0.00481
#   99% confidence level      0.09776                 0.01118
#                   skew      4.76653                 0.46366
#               kurtosis     30.51567                -0.15781
#       time correlation     -0.00232                -0.00012
#
#           elasped time      0.58349
#      number of samples          178
#     number of outliers           24
#      getnsecs overhead          492
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                169      2.00000 |********************************     2.63534
#
#                  9        > 95% |*                                    2.79398
#
#        mean of 95%      2.63534
#          95th %ile      2.76968
 
# bin/mmap -E -C 200 -L -S -W -N mmap_z8k -l 8k -I 1000 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_z8k       1   1     78.98643          196        0      100     8192  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     57.49523                57.49523
#                    max    165.49651               123.28467
#                   mean     83.46948                81.25126
#                 median     79.44467                78.98643
#                 stddev     20.20174                15.86653
#         standard error      1.42139                 1.13332
#   99% confidence level      3.30615                 2.63611
#                   skew      1.50554                 0.57910
#               kurtosis      3.20485                -0.44703
#       time correlation     -0.02401                -0.03447
#
#           elasped time      2.96242
#      number of samples          196
#     number of outliers            6
#      getnsecs overhead          493
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     56.00000 |**                                  57.49523
#                  6     58.00000 |************                        59.46344
#                 15     60.00000 |********************************    60.99748
#                  9     62.00000 |*******************                 63.33317
#                 10     64.00000 |*********************               65.02137
#                  9     66.00000 |*******************                 66.71521
#                  6     68.00000 |************                        69.21448
#                 12     70.00000 |*************************           71.18867
#                  7     72.00000 |**************                      73.17084
#                 11     74.00000 |***********************             75.47341
#                  6     76.00000 |************                        76.68712
#                 12     78.00000 |*************************           78.98728
#                  6     80.00000 |************                        80.85992
#                 10     82.00000 |*********************               83.32102
#                  9     84.00000 |*******************                 85.37534
#                  6     86.00000 |************                        87.20616
#                  6     88.00000 |************                        89.44190
#                  2     90.00000 |****                                91.02995
#                 11     92.00000 |***********************             92.86861
#                  7     94.00000 |**************                      95.01898
#                  6     96.00000 |************                        96.92776
#                  4     98.00000 |********                            99.09011
#                  3    100.00000 |******                             101.22430
#                  3    102.00000 |******                             102.82771
#                  1    104.00000 |**                                 105.98419
#                  1    106.00000 |**                                 107.95539
#                  2    108.00000 |****                               109.02035
#                  5    110.00000 |**********                         110.21280
#
#                 10        > 95% |*********************              116.69241
#
#        mean of 95%     79.34582
#          95th %ile    111.33715
# bin/mmap -E -C 200 -L -S -W -N mmap_z128k -l 128k -I 2000 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_z128k     1   1     82.01026          199        0       50   131072  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     56.47170                56.47170
#                    max    194.16898               164.97474
#                   mean     91.58261                90.17445
#                 median     82.45570                82.01026
#                 stddev     27.83551                25.52293
#         standard error      1.95850                 1.80927
#   99% confidence level      4.55547                 4.20837
#                   skew      1.21731                 1.01302
#               kurtosis      1.11031                 0.28853
#       time correlation      0.03504                 0.00121
#
#           elasped time      1.62495
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          351
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     54.00000 |*                                   56.47170
#                 10     57.00000 |******************                  59.06344
#                 12     60.00000 |**********************              61.46157
#                  2     63.00000 |***                                 65.21410
#                 11     66.00000 |********************                67.90187
#                 17     69.00000 |********************************    70.50954
#                 14     72.00000 |**************************          73.06928
#                 13     75.00000 |************************            76.01986
#                 13     78.00000 |************************            79.46680
#                 13     81.00000 |************************            82.32731
#                  8     84.00000 |***************                     84.96258
#                  9     87.00000 |****************                    88.66797
#                  5     90.00000 |*********                           90.79618
#                  8     93.00000 |***************                     94.63362
#                  3     96.00000 |*****                               97.86690
#                  5     99.00000 |*********                          100.48527
#                  6    102.00000 |***********                        103.54583
#                  3    105.00000 |*****                              107.15117
#                  7    108.00000 |*************                      109.82795
#                  3    111.00000 |*****                              111.88546
#                  6    114.00000 |***********                        115.21005
#                  4    117.00000 |*******                            118.16770
#                  1    120.00000 |*                                  121.19362
#                  0    123.00000 |                                           -
#                  2    126.00000 |***                                128.06210
#                  5    129.00000 |*********                          129.76552
#                  2    132.00000 |***                                133.84002
#                  3    135.00000 |*****                              137.06050
#                  2    138.00000 |***                                138.78338
#                  1    141.00000 |*                                  141.81698
#
#                 10        > 95% |******************                 154.92162
#
#        mean of 95%     86.74867
#          95th %ile    142.81538
# bin/mmap -E -C 200 -L -S -W -N mmap_t8k -l 8k -I 1000 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_t8k       1   1     45.39000          178        0        1     8192  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     41.55000                41.55000
#                    max   4122.44600                51.53400
#                   mean     76.23166                45.56834
#                 median     45.64600                45.39000
#                 stddev    291.29104                 2.17203
#         standard error     20.49517                 0.16280
#   99% confidence level     47.67176                 0.37867
#                   skew     13.30598                 0.83261
#               kurtosis    181.36063                 0.48367
#       time correlation     -0.20576                -0.00975
#
#           elasped time      0.03222
#      number of samples          178
#     number of outliers           24
#      getnsecs overhead          434
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  4     41.00000 |**                                  41.55000
#                 11     42.00000 |********                            42.57400
#                 26     43.00000 |******************                  43.58815
#                 44     44.00000 |********************************    44.56382
#                 39     45.00000 |****************************        45.60005
#                 18     46.00000 |*************                       46.58467
#                 12     47.00000 |********                            47.58733
#                  8     48.00000 |*****                               48.49400
#                  7     49.00000 |*****                               49.55914
#
#                  9        > 95% |******                              51.07889
#
#        mean of 95%     45.27488
#          95th %ile     49.74200
# bin/mmap -E -C 200 -L -S -W -N mmap_t128k -l 128k -I 1000 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_t128k     1   1     63.66200          187        0        1   131072  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     56.49400                56.49400
#                    max    623.79000                87.72600
#                   mean     73.81836                65.96737
#                 median     64.43000                63.66200
#                 stddev     44.52139                 7.34179
#         standard error      3.13251                 0.53689
#   99% confidence level      7.28623                 1.24879
#                   skew      9.71137                 1.03743
#               kurtosis    113.21117                 0.07785
#       time correlation     -0.18920                -0.03707
#
#           elasped time      0.03721
#      number of samples          187
#     number of outliers           15
#      getnsecs overhead          338
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  3     56.00000 |*****                               56.66467
#                  8     57.00000 |***************                     57.71000
#                 14     58.00000 |**************************          58.70657
#                 17     59.00000 |********************************    59.70153
#                 16     60.00000 |******************************      60.62200
#                 17     61.00000 |********************************    61.70435
#                 16     62.00000 |******************************      62.68600
#                  9     63.00000 |****************                    63.66200
#                 11     64.00000 |********************                64.63945
#                 11     65.00000 |********************                65.68673
#                  6     66.00000 |***********                         66.64867
#                  8     67.00000 |***************                     67.66200
#                  1     68.00000 |*                                   68.78200
#                  6     69.00000 |***********                         69.63533
#                  1     70.00000 |*                                   70.57400
#                  2     71.00000 |***                                 71.59800
#                  6     72.00000 |***********                         72.62200
#                  5     73.00000 |*********                           73.64600
#                  2     74.00000 |***                                 74.54200
#                  3     75.00000 |*****                               75.60867
#                  1     76.00000 |*                                   76.71800
#                  4     77.00000 |*******                             77.74200
#                  6     78.00000 |***********                         78.63800
#                  1     79.00000 |*                                   79.79000
#                  3     80.00000 |*****                               80.72867
#
#                 10        > 95% |******************                  83.60440
#
#        mean of 95%     64.97093
#          95th %ile     81.58200
# bin/mmap -E -C 200 -L -S -W -N mmap_u8k -l 8k -I 1000 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_u8k       1   1     86.79583          195        0      100     8192  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     61.27775                61.27775
#                    max    213.85631               158.78815
#                   mean     93.61752                90.47668
#                 median     87.80703                86.79583
#                 stddev     28.20256                23.02631
#         standard error      1.98433                 1.64895
#   99% confidence level      4.61554                 3.83545
#                   skew      1.30621                 0.74899
#               kurtosis      1.88889                -0.25097
#       time correlation     -0.06964                -0.04723
#
#           elasped time      3.22734
#      number of samples          195
#     number of outliers            7
#      getnsecs overhead          353
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  6     60.00000 |********                            61.52223
#                 23     63.00000 |********************************    64.73330
#                 18     66.00000 |*************************           67.00717
#                 11     69.00000 |***************                     70.41346
#                  3     72.00000 |****                                73.19284
#                 10     75.00000 |*************                       76.99692
#                  8     78.00000 |***********                         79.75135
#                  7     81.00000 |*********                           82.45956
#                 12     84.00000 |****************                    85.41471
#                 13     87.00000 |******************                  88.13806
#                  9     90.00000 |************                        92.00315
#                  7     93.00000 |*********                           94.29078
#                  6     96.00000 |********                            97.70655
#                 11     99.00000 |***************                    100.47275
#                  7    102.00000 |*********                          103.41791
#                  2    105.00000 |**                                 106.45151
#                  3    108.00000 |****                               108.78367
#                  1    111.00000 |*                                  113.54783
#                  6    114.00000 |********                           115.67092
#                  6    117.00000 |********                           118.21471
#                  3    120.00000 |****                               121.16298
#                  1    123.00000 |*                                  123.95679
#                  9    126.00000 |************                       127.62015
#                  3    129.00000 |****                               131.01386
#
#                 10        > 95% |*************                      144.01157
#
#        mean of 95%     87.58290
#          95th %ile    134.22751
# bin/mmap -E -C 200 -L -S -W -N mmap_u128k -l 128k -I 1000 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_u128k     1   1     80.20335          189        0      100   131072  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     58.93487                58.93487
#                    max    172.78319               126.68271
#                   mean     86.56287                82.04953
#                 median     81.02511                80.20335
#                 stddev     23.83041                16.69206
#         standard error      1.67670                 1.21417
#   99% confidence level      3.90001                 2.82416
#                   skew      1.40594                 0.58092
#               kurtosis      1.98122                -0.65374
#       time correlation      0.03204                 0.00292
#
#           elasped time      3.06457
#      number of samples          189
#     number of outliers           13
#      getnsecs overhead          657
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2     58.00000 |****                                59.38415
#                 10     60.00000 |*********************               60.90095
#                 15     62.00000 |********************************    62.92608
#                 13     64.00000 |***************************         65.16433
#                 12     66.00000 |*************************           67.14756
#                 12     68.00000 |*************************           69.11748
#                  5     70.00000 |**********                          70.70882
#                  6     72.00000 |************                        72.88346
#                  8     74.00000 |*****************                   74.97839
#                  4     76.00000 |********                            76.54063
#                  6     78.00000 |************                        79.09828
#                 14     80.00000 |*****************************       80.92966
#                  8     82.00000 |*****************                   82.78191
#                  8     84.00000 |*****************                   85.07375
#                  3     86.00000 |******                              86.98394
#                  4     88.00000 |********                            89.17167
#                  4     90.00000 |********                            90.68847
#                  3     92.00000 |******                              93.19876
#                  7     94.00000 |**************                      95.10438
#                  4     96.00000 |********                            97.44943
#                  7     98.00000 |**************                      99.12431
#                  6    100.00000 |************                       101.06052
#                  5    102.00000 |**********                         102.91669
#                  4    104.00000 |********                           105.04111
#                  6    106.00000 |************                       106.69551
#                  3    108.00000 |******                             109.18084
#
#                 10        > 95% |*********************              118.78767
#
#        mean of 95%     79.99712
#          95th %ile    111.28175
# bin/mmap -E -C 200 -L -S -W -N mmap_a8k -l 8k -I 200 -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_a8k       1   1     14.21340          193        0      500     8192  a---
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     11.55919                11.55919
#                    max     45.01737                25.15535
#                   mean     16.06176                15.35501
#                 median     15.00342                14.21340
#                 stddev      4.97371                 3.63697
#         standard error      0.34995                 0.26179
#   99% confidence level      0.81398                 0.60893
#                   skew      1.95343                 0.86337
#               kurtosis      5.94074                -0.33113
#       time correlation     -0.00358                 0.00049
#
#           elasped time      9.35025
#      number of samples          193
#     number of outliers            9
#      getnsecs overhead          371
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 36     11.00000 |**************************          11.85421
#                 44     12.00000 |********************************    12.35447
#                 15     13.00000 |**********                          13.41106
#                  6     14.00000 |****                                14.34908
#                 20     15.00000 |**************                      15.47372
#                 16     16.00000 |***********                         16.52111
#                 14     17.00000 |**********                          17.55047
#                  6     18.00000 |****                                18.40634
#                  9     19.00000 |******                              19.74454
#                  7     20.00000 |*****                               20.53529
#                  9     21.00000 |******                              21.44193
#                  1     22.00000 |*                                   22.26921
#
#                 10        > 95% |*******                             23.92563
#
#        mean of 95%     14.88667
#          95th %ile     22.35113
# bin/mmap -E -C 200 -L -S -W -N mmap_a128k -l 128k -I 200 -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_a128k     1   1     16.08094          193        0      500   131072  a---
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     11.71870                11.71870
#                    max     47.79319                29.67505
#                   mean     17.46634                16.61640
#                 median     16.31287                16.08094
#                 stddev      5.94706                 4.42178
#         standard error      0.41843                 0.31829
#   99% confidence level      0.97328                 0.74033
#                   skew      1.77378                 1.00499
#               kurtosis      4.06064                 0.42558
#       time correlation      0.00159                 0.00443
#
#           elasped time     10.06291
#      number of samples          193
#     number of outliers            9
#      getnsecs overhead          492
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 19     11.00000 |****************                    11.90539
#                 37     12.00000 |********************************    12.31945
#                 15     13.00000 |************                        13.44144
#                 10     14.00000 |********                            14.44699
#                 13     15.00000 |***********                         15.54932
#                 19     16.00000 |****************                    16.39018
#                 22     17.00000 |*******************                 17.51374
#                 11     18.00000 |*********                           18.59932
#                 14     19.00000 |************                        19.42748
#                  6     20.00000 |*****                               20.51844
#                  2     21.00000 |*                                   21.54398
#                  8     22.00000 |******                              22.67332
#                  2     23.00000 |*                                   23.72894
#                  1     24.00000 |*                                   24.26065
#                  2     25.00000 |*                                   25.52273
#                  2     26.00000 |*                                   26.46583
#
#                 10        > 95% |********                            28.01371
#
#        mean of 95%     15.99360
#          95th %ile     26.95070
 
 
# bin/mmap -E -C 200 -L -S -W -N mmap_rz8k -l 8k -I 2000 -r -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_rz8k      1   1     86.38982          184        0       50     8192  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     77.48614                77.48614
#                    max    210.26822               117.84710
#                   mean     95.24866                89.95495
#                 median     88.24838                86.38982
#                 stddev     20.96886                 9.52483
#         standard error      1.47536                 0.70218
#   99% confidence level      3.43170                 1.63327
#                   skew      2.85787                 0.81064
#               kurtosis     10.10612                -0.28449
#       time correlation     -0.02292                -0.00071
#
#           elasped time      3.53286
#      number of samples          184
#     number of outliers           18
#      getnsecs overhead          509
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  4     77.00000 |*******                             77.62950
#                  6     78.00000 |***********                         78.67654
#                  9     79.00000 |****************                    79.47839
#                  7     80.00000 |*************                       80.58301
#                 16     81.00000 |******************************      81.61606
#                 11     82.00000 |********************                82.47023
#                 17     83.00000 |********************************    83.47684
#                 12     84.00000 |**********************              84.50651
#                  8     85.00000 |***************                     85.46758
#                  6     86.00000 |***********                         86.49563
#                  3     87.00000 |*****                               87.44795
#                  7     88.00000 |*************                       88.36248
#                  3     89.00000 |*****                               89.36113
#                  3     90.00000 |*****                               90.46363
#                  4     91.00000 |*******                             91.37670
#                  3     92.00000 |*****                               92.44166
#                  4     93.00000 |*******                             93.76262
#                  3     94.00000 |*****                               94.56817
#                  4     95.00000 |*******                             95.56742
#                 10     96.00000 |******************                  96.40659
#                  4     97.00000 |*******                             97.35046
#                  5     98.00000 |*********                           98.45254
#                  4     99.00000 |*******                             99.28582
#                  4    100.00000 |*******                            100.30982
#                  2    101.00000 |***                                101.08166
#                  2    102.00000 |***                                102.36166
#                  2    103.00000 |***                                103.37286
#                  5    104.00000 |*********                          104.71123
#                  4    105.00000 |*******                            105.43494
#                  2    106.00000 |***                                106.24774
#
#                 10        > 95% |******************                 112.10707
#
#        mean of 95%     88.68184
#          95th %ile    106.91078
# bin/mmap -E -C 200 -L -S -W -N mmap_rz128k -l 128k -I 2000 -r -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_rz128k    1   1    252.91630          176        0       50   131072  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    232.47214               232.47214
#                    max    605.59214               283.75406
#                   mean    266.26523               253.68709
#                 median    255.55310               252.91630
#                 stddev     41.90291                10.40609
#         standard error      2.94828                 0.78439
#   99% confidence level      6.85770                 1.82449
#                   skew      4.11104                 0.52390
#               kurtosis     23.22528                -0.14871
#       time correlation     -0.09672                 0.01863
#
#           elasped time      5.45597
#      number of samples          176
#     number of outliers           26
#      getnsecs overhead          329
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    232.00000 |*                                  232.47214
#                  2    234.00000 |***                                235.03470
#                  3    236.00000 |****                               236.68078
#                  5    238.00000 |********                           239.29403
#                  8    240.00000 |************                       241.26958
#                 11    242.00000 |*****************                  243.00445
#                 20    244.00000 |********************************   244.84769
#                 15    246.00000 |************************           247.03786
#                  8    248.00000 |************                       249.08782
#                  9    250.00000 |**************                     251.01621
#                 16    252.00000 |*************************          253.01966
#                  8    254.00000 |************                       255.38798
#                 12    256.00000 |*******************                256.53273
#                 11    258.00000 |*****************                  258.78242
#                  6    260.00000 |*********                          260.74649
#                 11    262.00000 |*****************                  263.06554
#                  7    264.00000 |***********                        264.74423
#                  9    266.00000 |**************                     266.88138
#                  2    268.00000 |***                                269.53070
#                  3    270.00000 |****                               270.53422
#
#                  9        > 95% |**************                     277.98610
#
#        mean of 95%    252.37757
#          95th %ile    271.11278
# bin/mmap -E -C 200 -L -S -W -N mmap_rt8k -l 8k -I 2000 -r -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_rt8k      1   1     93.43002          188        0       50     8192  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     81.42874                81.42874
#                    max    190.73050               120.44826
#                   mean     99.43416                95.50201
#                 median     94.20826                93.43002
#                 stddev     18.10633                10.06710
#         standard error      1.27396                 0.73422
#   99% confidence level      2.96322                 1.70779
#                   skew      2.33724                 0.69506
#               kurtosis      6.73505                -0.61789
#       time correlation     -0.01821                -0.00166
#
#           elasped time      3.98366
#      number of samples          188
#     number of outliers           14
#      getnsecs overhead          499
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2     80.00000 |**                                  81.70010
#                  5     82.00000 |*****                               82.87463
#                 28     84.00000 |*****************************       85.29178
#                 30     86.00000 |********************************    86.93649
#                 15     88.00000 |****************                    88.83636
#                  7     90.00000 |*******                             90.58915
#                 13     92.00000 |*************                       93.20120
#                  7     94.00000 |*******                             95.05891
#                 12     96.00000 |************                        96.69701
#                 13     98.00000 |*************                       99.07423
#                  6    100.00000 |******                             101.36687
#                  7    102.00000 |*******                            102.92104
#                 10    104.00000 |**********                         104.94951
#                  6    106.00000 |******                             107.40335
#                  6    108.00000 |******                             108.61423
#                  5    110.00000 |*****                              110.95373
#                  5    112.00000 |*****                              113.52602
#                  1    114.00000 |*                                  114.83162
#
#                 10        > 95% |**********                         117.68346
#
#        mean of 95%     94.25586
#          95th %ile    114.84698
# bin/mmap -E -C 200 -L -S -W -N mmap_rt128k -l 128k -I 20000 -r -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_rt128k    1   1    135.71000          153        0        5   131072  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    123.31960               126.34040
#                    max    364.93240               146.92280
#                   mean    155.35306               135.80403
#                 median    137.34840               135.71000
#                 stddev     45.35498                 3.99224
#         standard error      3.19117                 0.32275
#   99% confidence level      7.42265                 0.75072
#                   skew      2.41584                 0.05450
#               kurtosis      4.96232                -0.40088
#       time correlation     -0.09686                -0.00919
#
#           elasped time      0.37308
#      number of samples          153
#     number of outliers           49
#      getnsecs overhead          362
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    126.00000 |*                                  126.34040
#                  1    127.00000 |*                                  127.51800
#                  6    128.00000 |**********                         128.55053
#                  3    129.00000 |*****                              129.66840
#                  9    130.00000 |***************                    130.40227
#                 10    131.00000 |****************                   131.46040
#                  7    132.00000 |***********                        132.69651
#                 11    133.00000 |******************                 133.53633
#                 19    134.00000 |********************************   134.52971
#                 13    135.00000 |*********************              135.48945
#                 16    136.00000 |**************************         136.62520
#                 12    137.00000 |********************               137.51053
#                 10    138.00000 |****************                   138.39800
#                  9    139.00000 |***************                    139.55569
#                 11    140.00000 |******************                 140.30869
#                  7    141.00000 |***********                        141.64920
#
#                  8        > 95% |*************                      143.67160
#
#        mean of 95%    135.36996
#          95th %ile    142.11000
# bin/mmap -E -C 200 -L -S -W -N mmap_ru8k -l 8k -I 2000 -r -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_ru8k      1   1     89.99776          188        0       50     8192  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     79.97280                79.97280
#                    max    263.41216               124.81376
#                   mean     99.61877                94.16980
#                 median     90.73504                89.99776
#                 stddev     24.04390                10.31238
#         standard error      1.69172                 0.75211
#   99% confidence level      3.93495                 1.74940
#                   skew      3.37899                 0.99390
#               kurtosis     14.63920                 0.01853
#       time correlation     -0.02515                -0.00730
#
#           elasped time      3.91867
#      number of samples          188
#     number of outliers           14
#      getnsecs overhead          336
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     78.00000 |*                                   79.97280
#                  0     80.00000 |                                           -
#                 13     82.00000 |************                        83.23070
#                 33     84.00000 |********************************    85.02562
#                 28     86.00000 |***************************         87.00603
#                 20     88.00000 |*******************                 89.14810
#                 13     90.00000 |************                        90.92724
#                  5     92.00000 |****                                93.24179
#                  9     94.00000 |********                            94.88736
#                  5     96.00000 |****                                96.95789
#                 12     98.00000 |***********                         99.03883
#                  7    100.00000 |******                             101.05111
#                  9    102.00000 |********                           103.06002
#                  4    104.00000 |***                                104.79968
#                  6    106.00000 |*****                              107.23680
#                  4    108.00000 |***                                108.49376
#                  2    110.00000 |*                                  110.67744
#                  2    112.00000 |*                                  113.01472
#                  5    114.00000 |****                               114.82976
#
#                 10        > 95% |*********                          118.84435
#
#        mean of 95%     92.78359
#          95th %ile    115.79232
# bin/mmap -E -C 200 -L -S -W -N mmap_ru128k -l 128k -I 20000 -r -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_ru128k    1   1    124.94840          180        0        5   131072  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    110.91960               110.91960
#                    max   1883.71960               173.33240
#                   mean    152.42379               129.55185
#                 median    127.35480               124.94840
#                 stddev    132.06455                15.03792
#         standard error      9.29203                 1.12086
#   99% confidence level     21.61326                 2.60712
#                   skew     11.30125                 1.42150
#               kurtosis    143.48519                 1.21417
#       time correlation      0.11765                -0.06656
#
#           elasped time      0.35592
#      number of samples          180
#     number of outliers           22
#      getnsecs overhead          410
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    110.00000 |**                                 110.91960
#                  6    112.00000 |********                           112.83960
#                 11    114.00000 |****************                   115.47175
#                 12    116.00000 |*****************                  116.82893
#                 22    118.00000 |********************************   119.05807
#                 19    120.00000 |***************************        121.02217
#                 14    122.00000 |********************               123.11617
#                 10    124.00000 |**************                     125.07640
#                 12    126.00000 |*****************                  127.22253
#                  8    128.00000 |***********                        129.02520
#                 13    130.00000 |******************                 130.97818
#                  8    132.00000 |***********                        132.91640
#                  8    134.00000 |***********                        134.99000
#                  3    136.00000 |****                               136.72440
#                  1    138.00000 |*                                  139.33560
#                  2    140.00000 |**                                 141.43480
#                  3    142.00000 |****                               142.78307
#                  1    144.00000 |*                                  145.73560
#                  2    146.00000 |**                                 147.04120
#                  1    148.00000 |*                                  148.29560
#                  2    150.00000 |**                                 151.13720
#                  2    152.00000 |**                                 153.51800
#                  1    154.00000 |*                                  155.31000
#                  0    156.00000 |                                           -
#                  1    158.00000 |*                                  159.71320
#                  1    160.00000 |*                                  160.73720
#                  1    162.00000 |*                                  163.09240
#                  3    164.00000 |****                               165.24280
#                  2    166.00000 |**                                 166.62520
#
#                  9        > 95% |*************                      169.37862
#
#        mean of 95%    127.45570
#          95th %ile    166.93240
# bin/mmap -E -C 200 -L -S -W -N mmap_ra8k -l 8k -I 2000 -r -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_ra8k      1   1    103.61500          171        0        1     8192  ar--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     94.65500                94.65500
#                    max    832.70300               149.69500
#                   mean    133.23496               109.35180
#                 median    106.68700               103.61500
#                 stddev     78.37177                13.49060
#         standard error      5.51422                 1.03165
#   99% confidence level     12.82607                 2.39962
#                   skew      5.06998                 0.99390
#               kurtosis     34.46594                 0.01571
#       time correlation     -0.35967                -0.18850
#
#           elasped time      0.05906
#      number of samples          171
#     number of outliers           31
#      getnsecs overhead          321
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 16     94.00000 |************************            95.42300
#                 19     96.00000 |****************************        97.22847
#                 21     98.00000 |********************************    99.28738
#                 21    100.00000 |********************************   101.20129
#                 16    102.00000 |************************           103.18300
#                  8    104.00000 |************                       105.15100
#                  6    106.00000 |*********                          107.19900
#                  4    108.00000 |******                             109.24700
#                  0    110.00000 |                                           -
#                  4    112.00000 |******                             113.53500
#                  3    114.00000 |****                               115.30567
#                  2    116.00000 |***                                117.18300
#                  9    118.00000 |*************                      119.65767
#                  8    120.00000 |************                       121.24700
#                  5    122.00000 |*******                            123.12220
#                  8    124.00000 |************                       125.34300
#                  4    126.00000 |******                             126.91100
#                  3    128.00000 |****                               129.30033
#                  3    130.00000 |****                               131.34833
#                  1    132.00000 |*                                  133.56700
#                  1    134.00000 |*                                  135.87100
#
#                  9        > 95% |*************                      142.64078
#
#        mean of 95%    107.50241
#          95th %ile    137.66300
# bin/mmap -E -C 200 -L -S -W -N mmap_ra128k -l 128k -I 20000 -r -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_ra128k    1   1    288.71000          157        0        1   131072  ar--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    273.86200               273.86200
#                    max   1099.71800               317.63800
#                   mean    341.80085               291.46730
#                 median    294.59800               288.71000
#                 stddev    137.00001                10.00971
#         standard error      9.63929                 0.79886
#   99% confidence level     22.42098                 1.85815
#                   skew      3.57953                 0.66245
#               kurtosis     13.54306                -0.39005
#       time correlation     -0.65107                -0.01736
#
#           elasped time      0.14650
#      number of samples          157
#     number of outliers           45
#      getnsecs overhead          314
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    272.00000 |*                                  273.86200
#                  0    274.00000 |                                           -
#                  5    276.00000 |*******                            276.88280
#                  9    278.00000 |*************                      279.46556
#                 12    280.00000 |*****************                  281.15800
#                 14    282.00000 |********************               283.13286
#                 22    284.00000 |********************************   285.04455
#                 11    286.00000 |****************                   287.49982
#                 12    288.00000 |*****************                  289.11533
#                  7    290.00000 |**********                         291.27000
#                  6    292.00000 |********                           292.80600
#                  8    294.00000 |***********                        295.17400
#                 10    296.00000 |**************                     297.08120
#                  7    298.00000 |**********                         298.98657
#                  9    300.00000 |*************                      301.11178
#                  5    302.00000 |*******                            302.84120
#                  4    304.00000 |*****                              305.47800
#                  1    306.00000 |*                                  307.65400
#                  4    308.00000 |*****                              309.19000
#                  2    310.00000 |**                                 310.72600
#
#                  8        > 95% |***********                        314.18200
#
#        mean of 95%    290.24772
#          95th %ile    311.49400
 
# bin/mmap -E -C 200 -L -S -W -N mmap_wz8k -l 8k -I 5000 -w -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_wz8k      1   1    154.41915          184        0       20     8192  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    136.60155               136.60155
#                    max    397.75995               215.30875
#                   mean    174.29951               161.42938
#                 median    155.66075               154.41915
#                 stddev     49.03215                18.61548
#         standard error      3.44989                 1.37235
#   99% confidence level      8.02444                 3.19209
#                   skew      2.94770                 0.99606
#               kurtosis      9.07475                 0.05143
#       time correlation     -0.03951                 0.04640
#
#           elasped time      1.83092
#      number of samples          184
#     number of outliers           18
#      getnsecs overhead          769
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    135.00000 |**                                 137.15835
#                  8    138.00000 |***********                        139.43195
#                 12    141.00000 |****************                   142.26022
#                 15    144.00000 |********************               145.36272
#                 23    147.00000 |********************************   148.44099
#                 21    150.00000 |*****************************      151.25450
#                 21    153.00000 |*****************************      154.21862
#                  8    156.00000 |***********                        157.24475
#                 13    159.00000 |******************                 160.29041
#                  4    162.00000 |*****                              163.46235
#                  2    165.00000 |**                                 166.91835
#                  3    168.00000 |****                               169.65968
#                  1    171.00000 |*                                  171.11035
#                  9    174.00000 |************                       175.76813
#                  8    177.00000 |***********                        178.62555
#                  6    180.00000 |********                           181.66395
#                  3    183.00000 |****                               184.32848
#                  5    186.00000 |******                             187.96795
#                  1    189.00000 |*                                  191.80795
#                  7    192.00000 |*********                          193.08429
#                  2    195.00000 |**                                 195.95515
#
#                 10        > 95% |*************                      205.80475
#
#        mean of 95%    158.87907
#          95th %ile    197.20955
# bin/mmap -E -C 200 -L -S -W -N mmap_wz128k -l 128k -I 50000 -w -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_wz128k    1   1    593.36050          137        0        2   131072  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    574.92850               574.92850
#                    max   1448.27250               630.73650
#                   mean    661.65484               596.45959
#                 median    602.32050               593.36050
#                 stddev    128.14087                11.70282
#         standard error      9.01596                 0.99984
#   99% confidence level     20.97112                 2.32563
#                   skew      2.68924                 0.67510
#               kurtosis      9.04116                -0.08428
#       time correlation     -0.01070                -0.03049
#
#           elasped time      0.43899
#      number of samples          137
#     number of outliers           65
#      getnsecs overhead          351
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    574.00000 |****                               575.37650
#                  3    576.00000 |******                             577.65917
#                  1    578.00000 |**                                 579.28050
#                  4    580.00000 |********                           580.94450
#                  7    582.00000 |**************                     583.52279
#                  8    584.00000 |****************                   585.31250
#                  9    586.00000 |******************                 586.87517
#                  7    588.00000 |**************                     589.09993
#                 14    590.00000 |****************************       591.06564
#                 16    592.00000 |********************************   592.84850
#                 10    594.00000 |********************               595.48530
#                  3    596.00000 |******                             596.81650
#                 10    598.00000 |********************               598.96690
#                  7    600.00000 |**************                     601.02221
#                  5    602.00000 |**********                         603.03730
#                  1    604.00000 |**                                 605.26450
#                  8    606.00000 |****************                   607.20050
#                  2    608.00000 |****                               609.36050
#                  2    610.00000 |****                               610.38450
#                  2    612.00000 |****                               612.81650
#                  5    614.00000 |**********                         615.04370
#                  4    616.00000 |********                           616.94450
#
#                  7        > 95% |**************                     623.80621
#
#        mean of 95%    594.98708
#          95th %ile    620.36850
# bin/mmap -E -C 200 -L -S -W -N mmap_wt8k -l 8k -I 5000 -w -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_wt8k      1   1    169.47345          185        0       20     8192  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    146.36945               146.36945
#                    max    453.87665               228.77585
#                   mean    184.48627               174.12262
#                 median    171.17585               169.47345
#                 stddev     41.80891                18.39914
#         standard error      2.94166                 1.35273
#   99% confidence level      6.84231                 3.14645
#                   skew      3.09405                 0.99981
#               kurtosis     12.48813                 0.44658
#       time correlation      0.05706                 0.05490
#
#           elasped time      2.09409
#      number of samples          185
#     number of outliers           17
#      getnsecs overhead          483
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    144.00000 |**                                 146.54865
#                  3    147.00000 |****                               148.99345
#                  8    150.00000 |***********                        151.44785
#                  5    153.00000 |*******                            154.62801
#                 19    156.00000 |***************************        157.41181
#                 22    159.00000 |********************************   160.39883
#                 14    162.00000 |********************               163.95208
#                 15    165.00000 |*********************              166.76412
#                 11    168.00000 |****************                   169.52349
#                 11    171.00000 |****************                   171.93920
#                  6    174.00000 |********                           175.35718
#                 12    177.00000 |*****************                  178.36625
#                 10    180.00000 |**************                     181.29553
#                  4    183.00000 |*****                              184.23505
#                  6    186.00000 |********                           188.13158
#                  9    189.00000 |*************                      190.10421
#                  4    192.00000 |*****                              193.33905
#                  1    195.00000 |*                                  196.77585
#                  4    198.00000 |*****                              198.84945
#                  3    201.00000 |****                               202.89425
#                  3    204.00000 |****                               206.39718
#                  2    207.00000 |**                                 208.82705
#                  0    210.00000 |                                           -
#                  1    213.00000 |*                                  213.17265
#
#                 10        > 95% |**************                     220.90129
#
#        mean of 95%    171.44955
#          95th %ile    213.27505
# bin/mmap -E -C 200 -L -S -W -N mmap_wt128k -l 128k -I 50000 -w -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_wt128k    1   1    739.75800          199        0        2   131072  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    666.28600               666.28600
#                    max   3520.17400              1181.87000
#                   mean    819.33408               800.61010
#                 median    742.83000               739.75800
#                 stddev    237.02797               131.09216
#         standard error     16.67723                 9.29288
#   99% confidence level     38.79124                21.61523
#                   skew      7.52027                 1.00580
#               kurtosis     80.89409                -0.12285
#       time correlation     -0.29568                -0.02363
#
#           elasped time      0.47524
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          420
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  9    660.00000 |*****                              673.39711
#                 54    680.00000 |********************************   691.02556
#                 29    700.00000 |*****************                  708.05372
#                  8    720.00000 |****                               729.19800
#                  8    740.00000 |****                               752.30200
#                  6    760.00000 |***                                766.36067
#                  7    780.00000 |****                               788.43457
#                  6    800.00000 |***                                808.68600
#                  6    820.00000 |***                                831.53400
#                  8    840.00000 |****                               849.07000
#                  5    860.00000 |**                                 865.58200
#                  6    880.00000 |***                                889.24067
#                  9    900.00000 |*****                              906.44244
#                  4    920.00000 |**                                 931.79000
#                  4    940.00000 |**                                 954.15800
#                  1    960.00000 |*                                  962.22200
#                  7    980.00000 |****                               992.48486
#                  4   1000.00000 |**                                1018.79800
#                  4   1020.00000 |**                                1031.40600
#                  4   1040.00000 |**                                1049.03800
#
#                 10        > 95% |*****                             1113.71000
#
#        mean of 95%    784.04397
#          95th %ile   1057.83800
# bin/mmap -E -C 200 -L -S -W -N mmap_wu8k -l 8k -I 5000 -w -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_wu8k      1   1    164.78280          177        0       20     8192  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    142.83080               142.83080
#                    max    482.38920               229.28200
#                   mean    190.41987               173.61878
#                 median    167.38120               164.78280
#                 stddev     53.69149                19.00492
#         standard error      3.77772                 1.42850
#   99% confidence level      8.78698                 3.32269
#                   skew      2.82318                 1.10477
#               kurtosis      9.40696                 0.16172
#       time correlation     -0.07098                -0.06931
#
#           elasped time      1.86024
#      number of samples          177
#     number of outliers           25
#      getnsecs overhead          344
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    141.00000 |*                                  142.83080
#                  0    144.00000 |                                           -
#                  0    147.00000 |                                           -
#                  4    150.00000 |***                                152.09480
#                 12    153.00000 |***********                        154.61107
#                 13    156.00000 |************                       157.78514
#                 26    159.00000 |*************************          160.58342
#                 33    162.00000 |********************************   163.55633
#                 16    165.00000 |***************                    166.28520
#                 11    168.00000 |**********                         169.25349
#                  2    171.00000 |*                                  172.78280
#                  4    174.00000 |***                                175.12520
#                  4    177.00000 |***                                178.88520
#                  2    180.00000 |*                                  182.43400
#                  6    183.00000 |*****                              184.90653
#                  3    186.00000 |**                                 188.51827
#                  4    189.00000 |***                                190.43080
#                  3    192.00000 |**                                 192.85320
#                  8    195.00000 |*******                            196.67560
#                  5    198.00000 |****                               198.67464
#                  1    201.00000 |*                                  203.73320
#                  4    204.00000 |***                                205.16040
#                  2    207.00000 |*                                  208.25800
#                  4    210.00000 |***                                211.87080
#
#                  9        > 95% |********                           220.11009
#
#        mean of 95%    171.12817
#          95th %ile    212.52680
# bin/mmap -E -C 200 -L -S -W -N mmap_wu128k -l 128k -I 500000 -w -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_wu128k    1   1    737.69800          131        0        1   131072  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    691.61800               691.61800
#                    max   5386.65800               796.57800
#                   mean    978.64469               737.41464
#                 median    753.57000               737.69800
#                 stddev    537.22112                19.78743
#         standard error     37.79875                 1.72884
#   99% confidence level     87.91988                 4.02127
#                   skew      4.31352                 0.20121
#               kurtosis     26.70985                -0.11999
#       time correlation      0.52649                 0.00280
#
#           elasped time      0.28393
#      number of samples          131
#     number of outliers           71
#      getnsecs overhead          350
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    690.00000 |**                                 691.61800
#                  1    693.00000 |**                                 695.71400
#                  1    696.00000 |**                                 696.73800
#                  1    699.00000 |**                                 701.60200
#                  0    702.00000 |                                           -
#                  5    705.00000 |************                       707.13160
#                  4    708.00000 |*********                          709.41000
#                  2    711.00000 |****                               713.12200
#                  6    714.00000 |**************                     715.98067
#                  7    717.00000 |*****************                  718.79057
#                  4    720.00000 |*********                          721.18600
#                  7    723.00000 |*****************                  724.93457
#                 10    726.00000 |************************           728.09800
#                  8    729.00000 |*******************                731.07400
#                  3    732.00000 |*******                            733.60200
#                  8    735.00000 |*******************                736.64200
#                  4    738.00000 |*********                          740.19400
#                 13    741.00000 |********************************   742.44385
#                  6    744.00000 |**************                     745.12200
#                  4    747.00000 |*********                          748.89800
#                  6    750.00000 |**************                     751.77800
#                  6    753.00000 |**************                     754.80733
#                  6    756.00000 |**************                     757.79400
#                  5    759.00000 |************                       760.12360
#                  5    762.00000 |************                       763.81000
#                  1    765.00000 |**                                 767.65000
#
#                  7        > 95% |*****************                  779.06029
#
#        mean of 95%    735.06368
#          95th %ile    771.49000
# bin/mmap -E -C 200 -L -S -W -N mmap_wa8k -l 8k -I 3000 -w -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_wa8k      1   1     62.64591          186        0       33     8192  a-w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     55.19088                55.19088
#                    max    217.52591                95.86385
#                   mean     70.91591                66.09303
#                 median     63.31306                62.64591
#                 stddev     21.29934                10.40306
#         standard error      1.49862                 0.76279
#   99% confidence level      3.48578                 1.77425
#                   skew      3.24956                 1.32518
#               kurtosis     14.41593                 0.71648
#       time correlation     -0.05319                -0.00256
#
#           elasped time      2.59632
#      number of samples          186
#     number of outliers           16
#      getnsecs overhead          653
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  6     54.00000 |****                                55.45464
#                 28     56.00000 |*********************               57.33806
#                 41     58.00000 |********************************    58.97828
#                 14     60.00000 |**********                          60.69710
#                 21     62.00000 |****************                    63.09215
#                 15     64.00000 |***********                         64.90336
#                  9     66.00000 |*******                             67.11169
#                  6     68.00000 |****                                68.78991
#                  4     70.00000 |***                                 70.70797
#                  6     72.00000 |****                                72.89367
#                  2     74.00000 |*                                   74.42191
#                  5     76.00000 |***                                 77.35738
#                  2     78.00000 |*                                   79.08421
#                  7     80.00000 |*****                               80.97484
#                  4     82.00000 |***                                 82.97076
#                  2     84.00000 |*                                   85.02652
#                  0     86.00000 |                                           -
#                  3     88.00000 |**                                  89.70433
#                  1     90.00000 |*                                   90.43355
#
#                 10        > 95% |*******                             92.97105
#
#        mean of 95%     64.56587
#          95th %ile     90.52664
# bin/mmap -E -C 200 -L -S -W -N mmap_wa128k -l 128k -I 50000 -w -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp   length flags
mmap_wa128k    1   1    563.92850          172        0        2   131072  a-w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    534.48850               534.48850
#                    max   1498.96850               721.88050
#                   mean    636.91321               583.48348
#                 median    566.87250               563.92850
#                 stddev    161.47588                46.91046
#         standard error     11.36140                 3.57689
#   99% confidence level     26.42662                 8.31984
#                   skew      3.11631                 1.43118
#               kurtosis     10.82348                 1.07283
#       time correlation     -0.78524                 0.00087
#
#           elasped time      0.41876
#      number of samples          172
#     number of outliers           30
#      getnsecs overhead         1103
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 11    534.00000 |*************                      538.44486
#                  6    540.00000 |*******                            543.70450
#                 26    546.00000 |********************************   548.72604
#                 22    552.00000 |***************************        555.58523
#                 23    558.00000 |****************************       560.75076
#                 20    564.00000 |************************           566.76370
#                  6    570.00000 |*******                            573.69917
#                  3    576.00000 |***                                578.13650
#                  5    582.00000 |******                             584.12690
#                  3    588.00000 |***                                591.96050
#                  2    594.00000 |**                                 597.72050
#                  1    600.00000 |*                                  603.48050
#                  3    606.00000 |***                                609.58183
#                  2    612.00000 |**                                 614.68050
#                  5    618.00000 |******                             620.24850
#                  6    624.00000 |*******                            626.28583
#                  4    630.00000 |****                               633.11250
#                  3    636.00000 |***                                638.76583
#                  2    642.00000 |**                                 645.72050
#                  1    648.00000 |*                                  653.40050
#                  1    654.00000 |*                                  655.06450
#                  3    660.00000 |***                                662.91517
#                  0    666.00000 |                                           -
#                  2    672.00000 |**                                 677.72050
#                  0    678.00000 |                                           -
#                  2    684.00000 |**                                 687.38450
#                  0    690.00000 |                                           -
#                  1    696.00000 |*                                  696.40850
#
#                  9        > 95% |***********                        710.95783
#
#        mean of 95%    576.44502
#          95th %ile    698.96850
 
# bin/munmap -E -C 200 -L -S -W -N unmap_z8k -l 8k -I 500 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_z8k      1   1     67.32158          191        0      200     8192  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     51.95646                51.95646
#                    max    165.36574               109.87646
#                   mean     73.78719                70.42390
#                 median     70.04158                67.32158
#                 stddev     19.69001                13.74460
#         standard error      1.38538                 0.99452
#   99% confidence level      3.22240                 2.31326
#                   skew      1.79048                 1.00129
#               kurtosis      3.72383                 0.47268
#       time correlation     -0.03460                -0.01101
#
#           elasped time      6.62199
#      number of samples          191
#     number of outliers           11
#      getnsecs overhead          772
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     50.00000 |*                                   51.95646
#                 13     52.00000 |***********************             53.29524
#                  9     54.00000 |****************                    54.73520
#                 13     56.00000 |***********************             56.87698
#                 12     58.00000 |*********************               59.09331
#                  9     60.00000 |****************                    61.10547
#                 14     62.00000 |************************            62.91481
#                 16     64.00000 |****************************        64.90678
#                 12     66.00000 |*********************               66.97107
#                  2     68.00000 |***                                 68.58366
#                 18     70.00000 |********************************    70.92265
#                 12     72.00000 |*********************               73.03006
#                 12     74.00000 |*********************               74.93566
#                  5     76.00000 |********                            76.85016
#                  6     78.00000 |**********                          79.08521
#                  8     80.00000 |**************                      80.85950
#                  2     82.00000 |***                                 83.24670
#                  2     84.00000 |***                                 84.50366
#                  2     86.00000 |***                                 86.68606
#                  0     88.00000 |                                           -
#                  2     90.00000 |***                                 90.93630
#                  4     92.00000 |*******                             93.62590
#                  3     94.00000 |*****                               95.21790
#                  2     96.00000 |***                                 97.36062
#                  2     98.00000 |***                                 99.37342
#
#                 10        > 95% |*****************                  105.27435
#
#        mean of 95%     68.49847
#          95th %ile    100.37118
# bin/munmap -E -C 200 -L -S -W -N unmap_z128k -l 128k -I 500 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_z128k    1   1     63.24670          179        0      200   131072  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     50.19197                50.19197
#                    max    154.63229                92.92733
#                   mean     70.94993                65.13920
#                 median     64.85693                63.24670
#                 stddev     19.04534                 9.29467
#         standard error      1.34003                 0.69472
#   99% confidence level      3.11690                 1.61591
#                   skew      1.84362                 0.69303
#               kurtosis      3.28693                -0.01886
#       time correlation      0.00160                -0.03193
#
#           elasped time      6.37275
#      number of samples          179
#     number of outliers           23
#      getnsecs overhead          645
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  7     50.00000 |**********                          51.14612
#                 10     52.00000 |**************                      53.03959
#                 14     54.00000 |********************                54.91856
#                 15     56.00000 |*********************               56.96565
#                  8     58.00000 |***********                         59.21149
#                 22     60.00000 |********************************    61.19317
#                 19     62.00000 |***************************         62.86835
#                 12     64.00000 |*****************                   64.80797
#                 11     66.00000 |****************                    66.72550
#                  9     68.00000 |*************                       69.05022
#                 15     70.00000 |*********************               70.90604
#                  7     72.00000 |**********                          72.98749
#                  7     74.00000 |**********                          74.97442
#                  4     76.00000 |*****                               76.78686
#                  4     78.00000 |*****                               79.22942
#                  4     80.00000 |*****                               81.03774
#                  2     82.00000 |**                                  83.51165
#
#                  9        > 95% |*************                       87.33573
#
#        mean of 95%     63.96409
#          95th %ile     84.17213
# bin/munmap -E -C 200 -L -S -W -N unmap_t8k -l 8k -I 500 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_t8k      1   1     65.48239          189        0      200     8192  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     49.75759                49.75759
#                    max    152.66703               103.94767
#                   mean     71.91147                68.34081
#                 median     66.79823                65.48239
#                 stddev     18.19155                12.09510
#         standard error      1.27995                 0.87979
#   99% confidence level      2.97717                 2.04639
#                   skew      1.69220                 0.82805
#               kurtosis      3.11375                -0.00606
#       time correlation      0.01555                 0.00904
#
#           elasped time      6.58610
#      number of samples          189
#     number of outliers           13
#      getnsecs overhead          482
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     48.00000 |*                                   49.75759
#                  6     50.00000 |*********                           51.11375
#                  6     52.00000 |*********                           53.07706
#                 10     54.00000 |****************                    54.96437
#                 14     56.00000 |**********************              57.01300
#                 18     58.00000 |****************************        59.45259
#                 20     60.00000 |********************************    60.91017
#                 11     62.00000 |*****************                   63.17769
#                 11     64.00000 |*****************                   65.06395
#                 11     66.00000 |*****************                   66.99628
#                  8     68.00000 |************                        68.98895
#                 16     70.00000 |*************************           70.98511
#                  3     72.00000 |****                                72.95631
#                  9     74.00000 |**************                      75.15706
#                  8     76.00000 |************                        76.86191
#                  5     78.00000 |********                            78.66818
#                  3     80.00000 |****                                80.80399
#                  5     82.00000 |********                            82.76649
#                  2     84.00000 |***                                 85.10927
#                  5     86.00000 |********                            87.23753
#                  3     88.00000 |****                                88.64655
#                  3     90.00000 |****                                91.21210
#                  1     92.00000 |*                                   92.33679
#
#                 10        > 95% |****************                    97.19618
#
#        mean of 95%     66.72877
#          95th %ile     93.37743
# bin/munmap -E -C 200 -L -S -W -N unmap_t128k -l 128k -I 500 -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_t128k    1   1     64.51188          172        0      200   131072  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     50.24628                50.24628
#                    max    150.70195                92.46068
#                   mean     73.42462                65.53684
#                 median     65.98132                64.51188
#                 stddev     21.76768                 9.16480
#         standard error      1.53157                 0.69881
#   99% confidence level      3.56243                 1.62543
#                   skew      1.77074                 0.70557
#               kurtosis      2.60764                 0.33596
#       time correlation      0.02496                -0.00593
#
#           elasped time      6.89354
#      number of samples          172
#     number of outliers           30
#      getnsecs overhead          793
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 10     50.00000 |*************                       51.26247
#                  8     52.00000 |***********                         52.68051
#                  6     54.00000 |********                            55.13267
#                 13     56.00000 |******************                  56.94865
#                  9     58.00000 |************                        59.24012
#                 12     60.00000 |****************                    61.29374
#                 23     62.00000 |********************************    63.08529
#                 21     64.00000 |*****************************       65.01242
#                 16     66.00000 |**********************              66.83555
#                 11     68.00000 |***************                     69.35225
#                  9     70.00000 |************                        70.67180
#                 10     72.00000 |*************                       72.93709
#                  2     74.00000 |**                                  74.99635
#                  4     76.00000 |*****                               76.78867
#                  1     78.00000 |*                                   78.45620
#                  2     80.00000 |**                                  81.03860
#                  6     82.00000 |********                            82.52254
#
#                  9        > 95% |************                        87.97271
#
#        mean of 95%     64.29805
#          95th %ile     84.96627
# bin/munmap -E -C 200 -L -S -W -N unmap_u8k -l 8k -I 500 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_u8k      1   1     68.64273          199        0      200     8192  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     50.74705                50.74705
#                    max    140.20753               124.30737
#                   mean     74.35053                73.42915
#                 median     68.76305                68.64273
#                 stddev     20.01695                18.68491
#         standard error      1.40839                 1.32454
#   99% confidence level      3.27591                 3.08088
#                   skew      1.30954                 1.24915
#               kurtosis      0.91963                 0.71426
#       time correlation     -0.02507                -0.01395
#
#           elasped time      6.75097
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          478
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     48.00000 |*                                   50.74705
#                 11     51.00000 |*****************                   52.45108
#                 19     54.00000 |******************************      55.48851
#                 17     57.00000 |***************************         58.45446
#                 20     60.00000 |********************************    61.48011
#                 19     63.00000 |******************************      63.93839
#                 15     66.00000 |************************            67.68998
#                 19     69.00000 |******************************      70.92969
#                 16     72.00000 |*************************           73.43873
#                 12     75.00000 |*******************                 76.64945
#                  4     78.00000 |******                              79.32785
#                  5     81.00000 |********                            82.65643
#                  4     84.00000 |******                              85.60593
#                  2     87.00000 |***                                 89.16305
#                  7     90.00000 |***********                         91.54248
#                  2     93.00000 |***                                 95.05041
#                  1     96.00000 |*                                   98.92753
#                  3     99.00000 |****                               100.70886
#                  2    102.00000 |***                                103.44529
#                  1    105.00000 |*                                  105.13297
#                  2    108.00000 |***                                108.65233
#                  2    111.00000 |***                                113.59057
#                  2    114.00000 |***                                115.66033
#                  3    117.00000 |****                               117.32582
#
#                 10        > 95% |****************                   121.13220
#
#        mean of 95%     70.90517
#          95th %ile    117.51825
# bin/munmap -E -C 200 -L -S -W -N unmap_u128k -l 128k -I 500 -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_u128k    1   1     69.50851          192        0      200   131072  ----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     51.29923                51.29923
#                    max    168.51779               115.58851
#                   mean     75.58979                72.29503
#                 median     70.54275                69.50851
#                 stddev     20.51607                14.51902
#         standard error      1.44351                 1.04782
#   99% confidence level      3.35759                 2.43723
#                   skew      1.76402                 0.84029
#               kurtosis      3.89059                 0.17493
#       time correlation     -0.01362                -0.04343
#
#           elasped time      7.04321
#      number of samples          192
#     number of outliers           10
#      getnsecs overhead          378
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  5     50.00000 |*********                           51.69219
#                  6     52.00000 |***********                         53.21240
#                  7     54.00000 |*************                       54.99971
#                 11     56.00000 |********************                56.87619
#                 11     58.00000 |********************                59.16320
#                 17     60.00000 |********************************    61.10734
#                 12     62.00000 |**********************              63.15768
#                  9     64.00000 |****************                    65.11427
#                 11     66.00000 |********************                66.63607
#                 10     68.00000 |******************                  68.94121
#                  8     70.00000 |***************                     70.91427
#                  8     72.00000 |***************                     73.11683
#                 10     74.00000 |******************                  75.29040
#                 11     76.00000 |********************                76.71631
#                  7     78.00000 |*************                       79.17141
#                  7     80.00000 |*************                       81.15322
#                  3     82.00000 |*****                               82.95875
#                  6     84.00000 |***********                         85.07907
#                  4     86.00000 |*******                             87.07075
#                  4     88.00000 |*******                             88.81571
#                  3     90.00000 |*****                               90.69123
#                  3     92.00000 |*****                               92.34030
#                  4     94.00000 |*******                             95.22627
#                  1     96.00000 |*                                   97.11299
#                  4     98.00000 |*******                             99.17123
#
#                 10        > 95% |******************                 107.83261
#
#        mean of 95%     70.34242
#          95th %ile    100.72771
# bin/munmap -E -C 200 -L -S -W -N unmap_a8k -l 8k -I 500 -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_a8k      1   1     74.89807          190        0      200     8192  a---
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     55.15279                55.15279
#                    max    161.01263               125.16751
#                   mean     81.86566                78.04950
#                 median     76.01679                74.89807
#                 stddev     21.78158                15.91669
#         standard error      1.53255                 1.15472
#   99% confidence level      3.56470                 2.68587
#                   skew      1.38401                 0.82222
#               kurtosis      1.67859                -0.00711
#       time correlation      0.01267                 0.00875
#
#           elasped time      4.05556
#      number of samples          190
#     number of outliers           12
#      getnsecs overhead          482
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  4     54.00000 |********                            55.62639
#                  8     56.00000 |*****************                   57.21871
#                  8     58.00000 |*****************                   58.92991
#                  8     60.00000 |*****************                   60.93551
#                  8     62.00000 |*****************                   62.64751
#                 12     64.00000 |*************************           65.09348
#                  4     66.00000 |********                            67.35567
#                 15     68.00000 |********************************    68.87183
#                 14     70.00000 |*****************************       71.03969
#                 11     72.00000 |***********************             72.85298
#                  9     74.00000 |*******************                 75.11923
#                 10     76.00000 |*********************               76.90665
#                 14     78.00000 |*****************************       79.08952
#                  8     80.00000 |*****************                   80.65567
#                  5     82.00000 |**********                          83.05833
#                  2     84.00000 |****                                85.16495
#                  5     86.00000 |**********                          87.19964
#                  5     88.00000 |**********                          88.98575
#                  2     90.00000 |****                                91.91247
#                  2     92.00000 |****                                93.68719
#                  5     94.00000 |**********                          94.81052
#                  2     96.00000 |****                                97.38703
#                  4     98.00000 |********                            99.15887
#                  6    100.00000 |************                       101.17775
#                  5    102.00000 |**********                         103.00303
#                  2    104.00000 |****                               104.98511
#                  0    106.00000 |                                           -
#                  2    108.00000 |****                               108.94991
#
#                 10        > 95% |*********************              115.86869
#
#        mean of 95%     75.94844
#          95th %ile    109.44783
# bin/munmap -E -C 200 -L -S -W -N unmap_a128k -l 128k -I 500 -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_a128k    1   1     74.94270          194        0      200   131072  a---
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     57.24158                57.24158
#                    max    157.05726               125.52190
#                   mean     82.21385                79.64438
#                 median     75.29726                74.94270
#                 stddev     21.12411                17.16817
#         standard error      1.48629                 1.23260
#   99% confidence level      3.45710                 2.86703
#                   skew      1.36050                 1.02812
#               kurtosis      1.39936                 0.16891
#       time correlation      0.01420                 0.01721
#
#           elasped time      4.02397
#      number of samples          194
#     number of outliers            8
#      getnsecs overhead          516
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  9     57.00000 |***********                         58.67305
#                 12     60.00000 |**************                      61.15497
#                 26     63.00000 |********************************    64.45817
#                 13     66.00000 |****************                    67.50157
#                 16     69.00000 |*******************                 70.44694
#                 22     72.00000 |***************************         73.16367
#                 20     75.00000 |************************            76.33502
#                 10     78.00000 |************                        79.56235
#                 11     81.00000 |*************                       82.17098
#                  1     84.00000 |*                                   84.46718
#                  6     87.00000 |*******                             88.26857
#                  8     90.00000 |*********                           91.29438
#                  4     93.00000 |****                                94.15102
#                  7     96.00000 |********                            97.48167
#                  3     99.00000 |***                                100.60755
#                  2    102.00000 |**                                 103.78494
#                  4    105.00000 |****                               106.05726
#                  6    108.00000 |*******                            109.39369
#                  1    111.00000 |*                                  111.14238
#                  3    114.00000 |***                                115.05534
#
#                 10        > 95% |************                       122.30014
#
#        mean of 95%     77.32613
#          95th %ile    118.33214
 
# bin/munmap -E -C 200 -L -S -W -N unmap_rz8k -l 8k -I 1000 -r -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_rz8k     1   1    301.84845          200        0      100     8192  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    123.24749               123.24749
#                    max    589.66669               489.52717
#                   mean    306.77480               304.29029
#                 median    302.13773               301.84845
#                 stddev     68.96938                64.54515
#         standard error      4.85267                 4.56403
#   99% confidence level     11.28731                10.61594
#                   skew      0.38202                -0.01752
#               kurtosis      1.16555                 0.02400
#       time correlation      0.72412                 0.72452
#
#           elasped time      8.12828
#      number of samples          200
#     number of outliers            2
#      getnsecs overhead          371
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    120.00000 |*                                  123.24749
#                  0    130.00000 |                                           -
#                  4    140.00000 |*******                            145.42861
#                  1    150.00000 |*                                  154.11597
#                  0    160.00000 |                                           -
#                  0    170.00000 |                                           -
#                  0    180.00000 |                                           -
#                  1    190.00000 |*                                  198.60621
#                  3    200.00000 |*****                              202.22349
#                  4    210.00000 |*******                            216.02125
#                  5    220.00000 |*********                          224.29120
#                 10    230.00000 |******************                 233.83053
#                 12    240.00000 |**********************             245.18434
#                  9    250.00000 |****************                   255.40180
#                 12    260.00000 |**********************             264.47885
#                  9    270.00000 |****************                   274.26161
#                 11    280.00000 |********************               283.13182
#                 17    290.00000 |********************************   295.19817
#                 14    300.00000 |**************************         304.76082
#                  8    310.00000 |***************                    315.91181
#                 12    320.00000 |**********************             324.71544
#                 13    330.00000 |************************           335.40710
#                  5    340.00000 |*********                          344.27021
#                  5    350.00000 |*********                          354.93824
#                  7    360.00000 |*************                      365.70180
#                  5    370.00000 |*********                          373.82029
#                 15    380.00000 |****************************       385.45464
#                  6    390.00000 |***********                        395.80344
#                  1    400.00000 |*                                  400.41613
#
#                 10        > 95% |******************                 432.11738
#
#        mean of 95%    297.56255
#          95th %ile    401.46573
# bin/munmap -E -C 200 -L -S -W -N unmap_rz128k -l 128k -I 2000 -r -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_rz128k   1   1    264.55324          193        0       50   131072  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    167.85180               167.85180
#                    max    511.73148               376.91676
#                   mean    273.03117               265.25932
#                 median    268.97180               264.55324
#                 stddev     54.39139                40.79772
#         standard error      3.82696                 2.93668
#   99% confidence level      8.90152                 6.83073
#                   skew      1.29787                 0.08280
#               kurtosis      3.29138                 0.07466
#       time correlation      0.52723                 0.45428
#
#           elasped time      5.37887
#      number of samples          193
#     number of outliers            9
#      getnsecs overhead          370
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    162.00000 |**                                 167.85180
#                  2    168.00000 |****                               173.29180
#                  1    174.00000 |**                                 176.09500
#                  3    180.00000 |******                             183.49511
#                  2    186.00000 |****                               188.44444
#                  2    192.00000 |****                               193.92028
#                  1    198.00000 |**                                 201.77180
#                  5    204.00000 |***********                        207.53180
#                  4    210.00000 |*********                          212.13852
#                  6    216.00000 |*************                      217.71121
#                  5    222.00000 |***********                        225.83580
#                 11    228.00000 |*************************          231.02096
#                  8    234.00000 |******************                 237.20284
#                 11    240.00000 |*************************          243.71484
#                 10    246.00000 |**********************             248.25833
#                  9    252.00000 |********************               254.78087
#                 14    258.00000 |********************************   260.66314
#                  9    264.00000 |********************               267.75096
#                 12    270.00000 |***************************        272.54172
#                  6    276.00000 |*************                      278.19377
#                 11    282.00000 |*************************          284.41232
#                 13    288.00000 |*****************************      291.88380
#                 11    294.00000 |*************************          296.44712
#                 13    300.00000 |*****************************      302.58184
#                  6    306.00000 |*************                      309.08700
#                  2    312.00000 |****                               313.41340
#                  4    318.00000 |*********                          322.45276
#                  1    324.00000 |**                                 326.48988
#
#                 10        > 95% |**********************             355.66825
#
#        mean of 95%    260.31894
#          95th %ile    331.05180
# bin/munmap -E -C 200 -L -S -W -N unmap_rt8k -l 8k -I 1000 -r -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_rt8k     1   1    308.34099          199        0      100     8192  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    202.80243               202.80243
#                    max    701.02195               432.80051
#                   mean    313.70557               310.28628
#                 median    309.58259               308.34099
#                 stddev     52.04774                41.97784
#         standard error      3.66207                 2.97573
#   99% confidence level      8.51797                 6.92155
#                   skew      2.28068                 0.27263
#               kurtosis     14.26059                 0.48209
#       time correlation      0.21507                 0.21983
#
#           elasped time      8.49357
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          845
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    196.00000 |*                                  202.80243
#                  1    203.00000 |*                                  206.23027
#                  1    210.00000 |*                                  216.96179
#                  1    217.00000 |*                                  220.12339
#                  3    224.00000 |****                               229.59795
#                  5    231.00000 |******                             235.31085
#                  1    238.00000 |*                                  238.71155
#                  3    245.00000 |****                               249.37139
#                  3    252.00000 |****                               254.98120
#                  4    259.00000 |*****                              262.80435
#                  4    266.00000 |*****                              269.63443
#                  5    273.00000 |******                             274.42560
#                 23    280.00000 |********************************   282.90272
#                 14    287.00000 |*******************                290.50840
#                 18    294.00000 |*************************          297.64574
#                 11    301.00000 |***************                    304.34506
#                 14    308.00000 |*******************                311.39617
#                 21    315.00000 |*****************************      318.99656
#                 10    322.00000 |*************                      325.56928
#                 11    329.00000 |***************                    332.17180
#                  8    336.00000 |***********                        339.53331
#                  8    343.00000 |***********                        345.92499
#                  6    350.00000 |********                           354.70344
#                  3    357.00000 |****                               361.00104
#                  4    364.00000 |*****                              365.58835
#                  4    371.00000 |*****                              373.59923
#                  0    378.00000 |                                           -
#                  2    385.00000 |**                                 388.87219
#
#                 10        > 95% |*************                      410.51110
#
#        mean of 95%    304.98338
#          95th %ile    392.95155
# bin/munmap -E -C 200 -L -S -W -N unmap_rt128k -l 128k -I 3000 -r -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_rt128k   1   1    196.75400          161        0        1   131072  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    182.67400               182.67400
#                    max    831.63400               223.63400
#                   mean    228.35986               198.72409
#                 median    199.82600               196.75400
#                 stddev     88.06434                 9.50645
#         standard error      6.19619                 0.74921
#   99% confidence level     14.41233                 1.74267
#                   skew      4.19204                 0.60699
#               kurtosis     20.48074                -0.43223
#       time correlation     -0.50551                -0.05653
#
#           elasped time      0.12757
#      number of samples          161
#     number of outliers           41
#      getnsecs overhead          366
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  3    182.00000 |****                               183.27133
#                  8    184.00000 |************                       185.13800
#                  8    186.00000 |************                       186.99400
#                 10    188.00000 |****************                   189.04840
#                 13    190.00000 |********************               191.24015
#                 16    192.00000 |*************************          193.50600
#                 17    194.00000 |***************************        195.17282
#                 20    196.00000 |********************************   197.26600
#                  7    198.00000 |***********                        198.76543
#                 10    200.00000 |****************                   201.33640
#                  8    202.00000 |************                       203.25000
#                  9    204.00000 |**************                     205.31578
#                  4    206.00000 |******                             207.57000
#                  3    208.00000 |****                               209.29800
#                  3    210.00000 |****                               211.68733
#                  6    212.00000 |*********                          213.47933
#                  4    214.00000 |******                             214.93000
#                  3    216.00000 |****                               216.55133
#
#                  9        > 95% |**************                     218.85533
#
#        mean of 95%    197.53211
#          95th %ile    216.72200
# bin/munmap -E -C 200 -L -S -W -N unmap_ru8k -l 8k -I 1000 -r -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_ru8k     1   1    282.84701          192        0      100     8192  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    127.64445               190.29533
#                    max    465.70525               397.02557
#                   mean    282.68275               283.53964
#                 median    282.84445               282.84701
#                 stddev     50.15001                38.43902
#         standard error      3.52854                 2.77410
#   99% confidence level      8.20739                 6.45255
#                   skew      0.33556                 0.48569
#               kurtosis      2.41459                 0.89914
#       time correlation      0.49047                 0.37126
#
#           elasped time      7.73729
#      number of samples          192
#     number of outliers           10
#      getnsecs overhead          483
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    186.00000 |***                                191.03005
#                  0    192.00000 |                                           -
#                  1    198.00000 |*                                  203.90429
#                  4    204.00000 |******                             206.53085
#                  4    210.00000 |******                             213.60797
#                  2    216.00000 |***                                217.95997
#                  0    222.00000 |                                           -
#                  1    228.00000 |*                                  229.97533
#                  4    234.00000 |******                             238.00093
#                  3    240.00000 |****                               242.37512
#                  4    246.00000 |******                             248.40221
#                 15    252.00000 |**********************             255.04882
#                 16    258.00000 |************************           261.02541
#                 12    264.00000 |******************                 267.45245
#                 13    270.00000 |*******************                272.57550
#                 13    276.00000 |*******************                278.98299
#                 21    282.00000 |********************************   285.33240
#                 15    288.00000 |**********************             291.14107
#                 14    294.00000 |*********************              295.91928
#                 15    300.00000 |**********************             302.62113
#                  3    306.00000 |****                               308.61170
#                  4    312.00000 |******                             315.39549
#                  3    318.00000 |****                               322.50824
#                  3    324.00000 |****                               326.00861
#                  1    330.00000 |*                                  335.58557
#                  2    336.00000 |***                                340.00029
#                  1    342.00000 |*                                  344.50461
#                  3    348.00000 |****                               350.22706
#                  2    354.00000 |***                                357.13949
#                  1    360.00000 |*                                  361.06525
#
#                 10        > 95% |***************                    379.22615
#
#        mean of 95%    278.28214
#          95th %ile    366.36445
# bin/munmap -E -C 200 -L -S -W -N unmap_ru128k -l 128k -I 3000 -r -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_ru128k   1   1    285.89412          192        0       33   131072  -r--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    221.35885               221.35885
#                    max    584.98745               378.20152
#                   mean    297.44742               288.37509
#                 median    288.80321               285.89412
#                 stddev     51.82182                30.82518
#         standard error      3.64617                 2.22462
#   99% confidence level      8.48099                 5.17446
#                   skew      2.53681                 0.31129
#               kurtosis      9.43921                -0.18447
#       time correlation      0.21652                 0.21779
#
#           elasped time      2.88282
#      number of samples          192
#     number of outliers           10
#      getnsecs overhead          374
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    220.00000 |*                                  221.35885
#                  1    225.00000 |*                                  227.92176
#                  4    230.00000 |******                             232.71400
#                  2    235.00000 |***                                236.87012
#                  5    240.00000 |********                           241.95521
#                  7    245.00000 |***********                        246.63303
#                  8    250.00000 |************                       252.89048
#                 13    255.00000 |********************               257.72815
#                  8    260.00000 |************                       262.51764
#                  6    265.00000 |*********                          267.11044
#                  8    270.00000 |************                       272.85752
#                 12    275.00000 |*******************                278.06091
#                 20    280.00000 |********************************   282.53703
#                 11    285.00000 |*****************                  288.13747
#                 10    290.00000 |****************                   292.01562
#                 11    295.00000 |*****************                  297.57844
#                  6    300.00000 |*********                          301.82818
#                 13    305.00000 |********************               306.87419
#                  4    310.00000 |******                             311.18576
#                 16    315.00000 |*************************          317.59400
#                  5    320.00000 |********                           322.94585
#                  3    325.00000 |****                               329.31069
#                  6    330.00000 |*********                          332.91279
#                  2    335.00000 |***                                337.65655
#
#                 10        > 95% |****************                   356.61451
#
#        mean of 95%    284.62567
#          95th %ile    344.05267
# bin/munmap -E -C 200 -L -S -W -N unmap_ra8k -l 8k -I 1000 -r -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_ra8k     1   1    267.52647          190        0      100     8192  ar--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    145.29415               215.64551
#                    max    461.17511               324.42503
#                   mean    272.16925               269.30731
#                 median    268.02567               267.52647
#                 stddev     33.56269                18.48604
#         standard error      2.36146                 1.34112
#   99% confidence level      5.49276                 3.11944
#                   skew      1.34542                 0.16915
#               kurtosis     10.61423                 1.06154
#       time correlation      0.13753                 0.10413
#
#           elasped time      6.11800
#      number of samples          190
#     number of outliers           12
#      getnsecs overhead          377
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    213.00000 |*                                  215.64551
#                  0    216.00000 |                                           -
#                  1    219.00000 |*                                  219.48551
#                  1    222.00000 |*                                  224.92551
#                  2    225.00000 |***                                227.65703
#                  1    228.00000 |*                                  230.64455
#                  1    231.00000 |*                                  231.19751
#                  1    234.00000 |*                                  235.69543
#                  4    237.00000 |******                             238.44871
#                  4    240.00000 |******                             241.48935
#                  1    243.00000 |*                                  243.53671
#                  3    246.00000 |****                               247.71292
#                  4    249.00000 |******                             250.50375
#                 10    252.00000 |****************                   253.63386
#                  6    255.00000 |*********                          256.56583
#                 11    258.00000 |*****************                  260.07803
#                 17    261.00000 |***************************        262.33449
#                 20    264.00000 |********************************   265.45953
#                 18    267.00000 |****************************       268.13675
#                 10    270.00000 |****************                   271.41818
#                  9    273.00000 |**************                     274.69163
#                 16    276.00000 |*************************          277.01271
#                 12    279.00000 |*******************                280.75186
#                  8    282.00000 |************                       283.14759
#                  6    285.00000 |*********                          286.24818
#                  4    288.00000 |******                             289.34407
#                  3    291.00000 |****                               292.07687
#                  2    294.00000 |***                                294.32711
#                  3    297.00000 |****                               298.69532
#                  1    300.00000 |*                                  300.03591
#
#                 10        > 95% |****************                   312.64237
#
#        mean of 95%    266.89981
#          95th %ile    300.23559
# bin/munmap -E -C 200 -L -S -W -N unmap_ra128k -l 128k -I 2000 -r -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_ra128k   1   1    254.97378          198        0       50   131072  ar--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    186.89314               186.89314
#                    max    479.00962               409.87426
#                   mean    261.58831               257.96417
#                 median    257.94850               254.97378
#                 stddev     58.20404                52.71888
#         standard error      4.09522                 3.74657
#   99% confidence level      9.52549                 8.71452
#                   skew      0.94340                 0.66462
#               kurtosis      0.73763                -0.17339
#       time correlation      0.70592                 0.68301
#
#           elasped time      4.69289
#      number of samples          198
#     number of outliers            4
#      getnsecs overhead          367
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  4    186.00000 |*****                              187.50882
#                  8    192.00000 |***********                        194.72482
#                 22    198.00000 |********************************   200.55237
#                 18    204.00000 |**************************         206.29111
#                 20    210.00000 |*****************************      213.02408
#                  3    216.00000 |****                               217.32642
#                  2    222.00000 |**                                 225.42114
#                  3    228.00000 |****                               231.99863
#                  4    234.00000 |*****                              237.88194
#                  5    240.00000 |*******                            243.88796
#                  8    246.00000 |***********                        248.43042
#                  5    252.00000 |*******                            254.98812
#                  9    258.00000 |*************                      260.80660
#                  2    264.00000 |**                                 265.54146
#                  5    270.00000 |*******                            275.00015
#                 10    276.00000 |**************                     279.47912
#                  7    282.00000 |**********                         284.05392
#                 16    288.00000 |***********************            290.63842
#                  7    294.00000 |**********                         297.06676
#                 11    300.00000 |****************                   302.95935
#                  6    306.00000 |********                           309.20909
#                  5    312.00000 |*******                            314.20501
#                  0    318.00000 |                                           -
#                  1    324.00000 |*                                  325.75266
#                  1    330.00000 |*                                  331.98882
#                  1    336.00000 |*                                  336.39202
#                  1    342.00000 |*                                  347.95298
#                  1    348.00000 |*                                  350.11362
#                  2    354.00000 |**                                 356.12194
#                  1    360.00000 |*                                  361.47490
#
#                 10        > 95% |**************                     386.00840
#
#        mean of 95%    251.15331
#          95th %ile    361.87426
 
# bin/connection -E -C 200 -L -S -W -N conn_connect -B 256 -c 
             prc thr   usecs/call      samples   errors cnt/samp 
conn_connect   1   1    132.19360          187        0      256 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    111.77860               111.77860
#                    max    629.72860               193.66960
#                   mean    152.34061               137.24214
#                 median    133.95860               132.19360
#                 stddev     70.53586                19.94457
#         standard error      4.96289                 1.45849
#   99% confidence level     11.54367                 3.39245
#                   skew      4.61379                 1.05297
#               kurtosis     23.01403                 0.34109
#       time correlation     -0.26580                 0.08412
#
#           elasped time     20.85053
#      number of samples          187
#     number of outliers           15
#      getnsecs overhead          615
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  4    111.00000 |******                             112.60310
#                 16    114.00000 |*************************          115.75016
#                 18    117.00000 |****************************       118.90493
#                 14    120.00000 |**********************             121.33895
#                 20    123.00000 |********************************   124.73700
#                 14    126.00000 |**********************             126.98553
#                  7    129.00000 |***********                        130.22717
#                 15    132.00000 |************************           133.68286
#                  6    135.00000 |*********                          136.06443
#                  7    138.00000 |***********                        139.14917
#                  9    141.00000 |**************                     142.54949
#                  5    144.00000 |********                           144.77360
#                  9    147.00000 |**************                     148.51249
#                 10    150.00000 |****************                   151.20520
#                  2    153.00000 |***                                154.36510
#                  5    156.00000 |********                           157.30220
#                  2    159.00000 |***                                160.69510
#                  2    162.00000 |***                                163.27910
#                  4    165.00000 |******                             166.61560
#                  2    168.00000 |***                                169.51660
#                  1    171.00000 |*                                  173.99360
#                  1    174.00000 |*                                  176.95060
#                  4    177.00000 |******                             178.49285
#
#                 10        > 95% |****************                   187.39520
#
#        mean of 95%    134.40864
#          95th %ile    180.93460
 
# bin/munmap -E -C 200 -L -S -W -N unmap_wz8k -l 8k -I 1000 -w -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_wz8k     1   1    343.89517          199        0      100     8192  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    179.68397               179.68397
#                    max    591.46509               527.43437
#                   mean    355.43056               352.15491
#                 median    345.33389               343.89517
#                 stddev     64.56100                59.11652
#         standard error      4.54250                 4.19066
#   99% confidence level     10.56585                 9.74747
#                   skew      0.49099                 0.03448
#               kurtosis      2.02427                 1.26560
#       time correlation      0.59500                 0.60743
#
#           elasped time     10.39240
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          499
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    171.00000 |*                                  179.68397
#                  2    180.00000 |**                                 183.96941
#                  3    189.00000 |***                                192.98402
#                  1    198.00000 |*                                  198.70477
#                  0    207.00000 |                                           -
#                  0    216.00000 |                                           -
#                  0    225.00000 |                                           -
#                  0    234.00000 |                                           -
#                  0    243.00000 |                                           -
#                  0    252.00000 |                                           -
#                  2    261.00000 |**                                 267.87341
#                  2    270.00000 |**                                 274.70605
#                  6    279.00000 |*******                            284.33165
#                  3    288.00000 |***                                293.35821
#                 11    297.00000 |*************                      300.80409
#                 12    306.00000 |**************                     310.66914
#                  9    315.00000 |**********                         319.84795
#                 19    324.00000 |**********************             328.47157
#                 27    333.00000 |********************************   337.31388
#                 11    342.00000 |*************                      346.08304
#                 21    351.00000 |************************           355.36263
#                  3    360.00000 |***                                362.89805
#                  9    369.00000 |**********                         373.56841
#                  6    378.00000 |*******                            382.67661
#                 10    387.00000 |***********                        391.96608
#                  7    396.00000 |********                           401.87186
#                  9    405.00000 |**********                         410.34196
#                  4    414.00000 |****                               418.73741
#                  5    423.00000 |*****                              428.85082
#                  2    432.00000 |**                                 434.86605
#                  4    441.00000 |****                               447.01517
#
#                 10        > 95% |***********                        489.91475
#
#        mean of 95%    344.86603
#          95th %ile    451.44589
# bin/munmap -E -C 200 -L -S -W -N unmap_wz128k -l 128k -I 8000 -w -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_wz128k   1   1    375.88400          187        0       12   131072  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    351.30800               351.30800
#                    max    925.64400               444.30000
#                   mean    394.99497               382.50600
#                 median    378.89200               375.88400
#                 stddev     63.27618                21.01544
#         standard error      4.45210                 1.53680
#   99% confidence level     10.35558                 3.57460
#                   skew      5.76782                 0.90354
#               kurtosis     41.38858                 0.10396
#       time correlation     -0.16129                -0.01873
#
#           elasped time      2.48124
#      number of samples          187
#     number of outliers           15
#      getnsecs overhead          368
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    351.00000 |*                                  351.30800
#                  3    354.00000 |*****                              355.13378
#                 12    357.00000 |*********************              358.38889
#                 18    360.00000 |********************************   361.89289
#                 18    363.00000 |********************************   364.74207
#                 12    366.00000 |*********************              367.30267
#                 12    369.00000 |*********************              370.88844
#                 11    372.00000 |*******************                373.58000
#                 13    375.00000 |***********************            375.99395
#                  4    378.00000 |*******                            378.86533
#                  8    381.00000 |**************                     382.94000
#                  6    384.00000 |**********                         385.74356
#                  8    387.00000 |**************                     387.80933
#                  7    390.00000 |************                       391.14648
#                 10    393.00000 |*****************                  394.84720
#                  5    396.00000 |********                           397.49040
#                  5    399.00000 |********                           399.97360
#                  4    402.00000 |*******                            403.42533
#                  4    405.00000 |*******                            405.74000
#                  8    408.00000 |**************                     409.78267
#                  2    411.00000 |***                                413.67600
#                  1    414.00000 |*                                  415.71333
#                  2    417.00000 |***                                417.96400
#                  3    420.00000 |*****                              420.94711
#
#                 10        > 95% |*****************                  434.97307
#
#        mean of 95%    379.54176
#          95th %ile    423.13733
# bin/munmap -E -C 200 -L -S -W -N unmap_wt8k -l 8k -I 1000 -w -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_wt8k     1   1    391.35224          202        0      100     8192  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    178.48312               178.48312
#                    max    604.84088               604.84088
#                   mean    382.93543               382.93543
#                 median    391.35224               391.35224
#                 stddev     77.70435                77.70435
#         standard error      5.46726                 5.46726
#   99% confidence level     12.71684                12.71684
#                   skew     -0.48154                -0.48154
#               kurtosis      0.55797                 0.55797
#       time correlation      0.85891                 0.85891
#
#           elasped time     11.18943
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          776
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    160.00000 |*                                  178.48312
#                 10    180.00000 |**********                         188.92971
#                  1    200.00000 |*                                  214.58168
#                  0    220.00000 |                                           -
#                  0    240.00000 |                                           -
#                  7    260.00000 |*******                            273.18959
#                  2    280.00000 |**                                 286.98232
#                  9    300.00000 |*********                          314.29567
#                 21    320.00000 |**********************             332.48711
#                 30    340.00000 |********************************   350.50642
#                 15    360.00000 |****************                   370.76557
#                 16    380.00000 |*****************                  392.47336
#                 29    400.00000 |******************************     408.91269
#                 12    420.00000 |************                       431.32728
#                 13    440.00000 |*************                      451.15581
#                 21    460.00000 |**********************             469.24182
#                  4    480.00000 |****                               483.07000
#
#                 11        > 95% |***********                        521.03486
#
#        mean of 95%    374.98206
#          95th %ile    488.71160
# bin/munmap -E -C 200 -L -S -W -N unmap_wt128k -l 128k -I 10000 -w -f /tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_wt128k   1   1    383.82840          196        0       10   131072  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    304.62200               304.62200
#                    max    982.91960               508.52600
#                   mean    394.04229               380.22598
#                 median    388.23160               383.82840
#                 stddev     92.34065                44.23010
#         standard error      6.49707                 3.15929
#   99% confidence level     15.11217                 7.34851
#                   skew      3.99504                 0.21805
#               kurtosis     19.98560                -0.69338
#       time correlation      0.37807                 0.38305
#
#           elasped time      2.29677
#      number of samples          196
#     number of outliers            6
#      getnsecs overhead          692
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    300.00000 |***                                304.63480
#                  5    305.00000 |*******                            307.95000
#                  1    310.00000 |*                                  312.63480
#                  6    315.00000 |*********                          318.40333
#                 13    320.00000 |*******************                323.11898
#                  8    325.00000 |************                       327.78360
#                 10    330.00000 |***************                    332.30328
#                  3    335.00000 |****                               336.46840
#                  6    340.00000 |*********                          341.68227
#                  3    345.00000 |****                               347.69827
#                  5    350.00000 |*******                            352.51960
#                  7    355.00000 |**********                         356.81309
#                  9    360.00000 |*************                      361.84084
#                  7    365.00000 |**********                         367.60897
#                  7    370.00000 |**********                         372.54977
#                  4    375.00000 |******                             376.91000
#                  3    380.00000 |****                               382.39480
#                  4    385.00000 |******                             387.60440
#                  4    390.00000 |******                             392.19320
#                 21    395.00000 |********************************   397.38665
#                  9    400.00000 |*************                      402.27462
#                  9    405.00000 |*************                      407.11871
#                 10    410.00000 |***************                    411.96792
#                  6    415.00000 |*********                          416.66040
#                  2    420.00000 |***                                420.47480
#                  4    425.00000 |******                             426.80440
#                  4    430.00000 |******                             431.80920
#                  7    435.00000 |**********                         436.82040
#                  2    440.00000 |***                                442.52920
#                  4    445.00000 |******                             448.03960
#                  1    450.00000 |*                                  451.02840
#
#                 10        > 95% |***************                    472.11000
#
#        mean of 95%    375.28598
#          95th %ile    456.43000
# bin/munmap -E -C 200 -L -S -W -N unmap_wu8k -l 8k -I 1000 -w -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_wu8k     1   1    383.41099          199        0      100     8192  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    181.39115               274.40107
#                    max    534.47147               510.73259
#                   mean    381.21981               382.39872
#                 median    383.41099               383.41099
#                 stddev     49.34861                44.40652
#         standard error      3.47216                 3.14790
#   99% confidence level      8.07623                 7.32200
#                   skew     -0.33574                 0.08585
#               kurtosis      2.00851                 0.35189
#       time correlation      0.42265                 0.36949
#
#           elasped time     11.24788
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          789
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    270.00000 |***                                274.80683
#                  0    276.00000 |                                           -
#                  0    282.00000 |                                           -
#                  3    288.00000 |*****                              291.34230
#                  1    294.00000 |*                                  296.52203
#                  5    300.00000 |*********                          303.18264
#                  4    306.00000 |*******                            308.67947
#                  4    312.00000 |*******                            314.54507
#                  6    318.00000 |***********                        321.17995
#                  3    324.00000 |*****                              327.05174
#                  2    330.00000 |***                                333.61771
#                  5    336.00000 |*********                          338.07800
#                  6    342.00000 |***********                        345.33142
#                  5    348.00000 |*********                          349.75825
#                  5    354.00000 |*********                          358.51038
#                  9    360.00000 |****************                   362.85106
#                 13    366.00000 |************************           368.95191
#                 12    372.00000 |**********************             374.31616
#                 17    378.00000 |********************************   380.46006
#                 13    384.00000 |************************           385.89517
#                  7    390.00000 |*************                      392.78388
#                  9    396.00000 |****************                   399.15215
#                 12    402.00000 |**********************             405.09995
#                  9    408.00000 |****************                   410.87922
#                 10    414.00000 |******************                 416.09835
#                 15    420.00000 |****************************       422.60066
#                  7    426.00000 |*************                      428.26658
#                  3    432.00000 |*****                              433.24566
#                  1    438.00000 |*                                  443.49419
#                  1    444.00000 |*                                  445.95179
#
#                 10        > 95% |******************                 486.28817
#
#        mean of 95%    376.90193
#          95th %ile    451.47115
# bin/munmap -E -C 200 -L -S -W -N unmap_wu128k -l 128k -I 50000 -w -f /var/tmp/libmicro.2378/data 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_wu128k   1   1    260.66050          153        0        2   131072  --w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    235.18850               235.18850
#                    max    714.67650               291.76450
#                   mean    300.38296               260.76340
#                 median    265.65250               260.66050
#                 stddev     90.94094                10.55038
#         standard error      6.39858                 0.85295
#   99% confidence level     14.88310                 1.98396
#                   skew      2.71880                 0.15993
#               kurtosis      7.37696                 0.20381
#       time correlation      0.01689                -0.04743
#
#           elasped time      0.47769
#      number of samples          153
#     number of outliers           49
#      getnsecs overhead          663
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    234.00000 |**                                 235.18850
#                  1    236.00000 |**                                 237.62050
#                  2    238.00000 |****                               238.38850
#                  1    240.00000 |**                                 240.18050
#                  3    242.00000 |******                             242.65517
#                  6    244.00000 |************                       245.00183
#                  3    246.00000 |******                             246.28183
#                  4    248.00000 |********                           248.85250
#                  7    250.00000 |**************                     250.73136
#                 12    252.00000 |*************************          253.22583
#                 10    254.00000 |*********************              254.69570
#                  9    256.00000 |*******************                256.94850
#                 12    258.00000 |*************************          259.15650
#                 15    260.00000 |********************************   260.80557
#                  8    262.00000 |*****************                  263.25250
#                 11    264.00000 |***********************            265.05905
#                 12    266.00000 |*************************          266.71917
#                  8    268.00000 |*****************                  269.18850
#                 10    270.00000 |*********************              270.91330
#                  6    272.00000 |************                       272.64983
#                  2    274.00000 |****                               275.18850
#                  2    276.00000 |****                               276.91650
#
#                  8        > 95% |*****************                  284.30850
#
#        mean of 95%    259.46436
#          95th %ile    278.70850
# bin/munmap -E -C 200 -L -S -W -N unmap_wa8k -l 8k -I 1000 -w -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_wa8k     1   1    162.69000          192        0        1     8192  a-w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     92.54600               145.53800
#                    max    745.60200               205.69800
#                   mean    178.25150               166.77000
#                 median    163.45800               162.69000
#                 stddev     70.98198                13.58941
#         standard error      4.99427                 0.98073
#   99% confidence level     11.61668                 2.28118
#                   skew      6.16320                 1.03947
#               kurtosis     39.88921                 0.30169
#       time correlation      0.00380                 0.01891
#
#           elasped time      0.09860
#      number of samples          192
#     number of outliers           10
#      getnsecs overhead          382
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    144.00000 |*                                  145.53800
#                  4    146.00000 |*****                              147.07400
#                  1    148.00000 |*                                  148.61000
#                  4    150.00000 |*****                              151.29800
#                 11    152.00000 |**************                     153.63691
#                 19    154.00000 |*************************          155.27947
#                 24    156.00000 |********************************   157.14333
#                 15    158.00000 |********************               159.02067
#                 13    160.00000 |*****************                  160.87831
#                 14    162.00000 |******************                 163.09229
#                 15    164.00000 |********************               165.04520
#                  6    166.00000 |********                           167.29800
#                  5    168.00000 |******                             168.78280
#                  5    170.00000 |******                             171.39400
#                  7    172.00000 |*********                          172.82029
#                  4    174.00000 |*****                              174.78600
#                  5    176.00000 |******                             177.33320
#                  6    178.00000 |********                           178.98867
#                  3    180.00000 |****                               180.95133
#                  4    182.00000 |*****                              183.17000
#                  4    184.00000 |*****                              184.96200
#                  4    186.00000 |*****                              186.81800
#                  2    188.00000 |**                                 189.57000
#                  2    190.00000 |**                                 191.10600
#                  3    192.00000 |****                               193.66600
#                  1    194.00000 |*                                  194.69000
#
#                 10        > 95% |*************                      201.09000
#
#        mean of 95%    164.88429
#          95th %ile    197.50600
# bin/munmap -E -C 200 -L -S -W -N unmap_wa128k -l 128k -I 10000 -w -f MAP_ANON 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
unmap_wa128k   1   1    398.96470          182        0       10   131072  a-w-
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    369.55030               369.55030
#                    max    746.86870               502.74710
#                   mean    429.18233               409.91165
#                 median    404.46870               398.96470
#                 stddev     68.89280                31.23131
#         standard error      4.84728                 2.31502
#   99% confidence level     11.27477                 5.38473
#                   skew      2.30649                 0.92548
#               kurtosis      5.46114                -0.07320
#       time correlation      0.02466                -0.02421
#
#           elasped time      2.00956
#      number of samples          182
#     number of outliers           20
#      getnsecs overhead          369
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  3    368.00000 |*****                              370.85590
#                  5    372.00000 |********                           374.13270
#                 16    376.00000 |**************************         378.32310
#                 15    380.00000 |*************************          382.01579
#                 19    384.00000 |********************************   385.93026
#                 17    388.00000 |****************************       389.66286
#                  7    392.00000 |***********                        393.19373
#                 12    396.00000 |********************               397.63777
#                  7    400.00000 |***********                        402.01476
#                  6    404.00000 |**********                         405.69750
#                  7    408.00000 |***********                        410.04219
#                  5    412.00000 |********                           413.56694
#                  2    416.00000 |***                                418.11350
#                  7    420.00000 |***********                        421.94619
#                  4    424.00000 |******                             425.79350
#                  4    428.00000 |******                             429.81270
#                  5    432.00000 |********                           433.89334
#                  7    436.00000 |***********                        438.03030
#                  5    440.00000 |********                           442.27990
#                  2    444.00000 |***                                445.10870
#                  4    448.00000 |******                             449.72950
#                  3    452.00000 |*****                              454.14123
#                  5    456.00000 |********                           457.33270
#                  1    460.00000 |*                                  461.45430
#                  4    464.00000 |******                             466.29270
#
#                 10        > 95% |****************                   484.57110
#
#        mean of 95%    405.57099
#          95th %ile    471.36150
 
 
# bin/mprotect -E -C 200 -L -S -W -N mprot_z8k -l 8k -I 300 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
mprot_z8k      1   1     38.45507          181        0      333     8192 -----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     32.13656                32.13656
#                    max     83.55412                49.04101
#                   mean     41.34477                38.66254
#                 median     38.84560                38.45507
#                 stddev      9.06339                 3.53060
#         standard error      0.63770                 0.26243
#   99% confidence level      1.48328                 0.61041
#                   skew      2.49579                 0.58402
#               kurtosis      6.73655                 0.03346
#       time correlation     -0.02122                -0.00933
#
#           elasped time      2.80845
#      number of samples          181
#     number of outliers           21
#      getnsecs overhead          351
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  6     32.00000 |********                            32.50774
#                  4     33.00000 |*****                               33.65372
#                 21     34.00000 |*****************************       34.50711
#                 12     35.00000 |****************                    35.46629
#                 19     36.00000 |**************************          36.52801
#                 21     37.00000 |*****************************       37.58174
#                 23     38.00000 |********************************    38.53515
#                 22     39.00000 |******************************      39.49427
#                 17     40.00000 |***********************             40.60780
#                  5     41.00000 |******                              41.55228
#                  7     42.00000 |*********                           42.59851
#                  7     43.00000 |*********                           43.32818
#                  5     44.00000 |******                              44.32615
#                  2     45.00000 |**                                  45.12029
#
#                 10        > 95% |*************                       46.81304
#
#        mean of 95%     38.18590
#          95th %ile     45.18487
# bin/mprotect -E -C 200 -L -S -W -N mprot_z128k -l 128k -I 500 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
mprot_z128k    1   1     38.20070          174        0      200   131072 -----
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     29.06150                29.06150
#                    max    118.01637                51.45765
#                   mean     42.30618                38.36144
#                 median     39.34629                38.20070
#                 stddev     11.84424                 4.49051
#         standard error      0.83336                 0.34042
#   99% confidence level      1.93839                 0.79183
#                   skew      2.67902                 0.49744
#               kurtosis      9.99396                 0.00854
#       time correlation      0.00430                 0.00982
#
#           elasped time      1.73280
#      number of samples          174
#     number of outliers           28
#      getnsecs overhead          693
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2     29.00000 |**                                  29.39686
#                  2     30.00000 |**                                  30.32165
#                  4     31.00000 |*****                               31.81253
#                 10     32.00000 |*************                       32.48550
#                 14     33.00000 |*******************                 33.47292
#                 11     34.00000 |***************                     34.56270
#                 23     35.00000 |********************************    35.45498
#                  4     36.00000 |*****                               36.54149
#                 11     37.00000 |***************                     37.44433
#                 17     38.00000 |***********************             38.48260
#                 16     39.00000 |**********************              39.55389
#                 11     40.00000 |***************                     40.43988
#                 20     41.00000 |***************************         41.58194
#                  9     42.00000 |************                        42.51074
#                  2     43.00000 |**                                  43.24134
#                  4     44.00000 |*****                               44.46086
#                  3     45.00000 |****                                45.23941
#                  2     46.00000 |**                                  46.49381
#
#                  9        > 95% |************                        49.09406
#
#        mean of 95%     37.77602
#          95th %ile     47.28229
# bin/mprotect -E -C 200 -L -S -W -N mprot_wz8k -l 8k -I 500 -w -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
mprot_wz8k     1   1    169.81122          202        0      200     8192 --w--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     92.08066                92.08066
#                    max    281.06626               281.06626
#                   mean    159.63092               159.63092
#                 median    169.81122               169.81122
#                 stddev     45.46752                45.46752
#         standard error      3.19908                 3.19908
#   99% confidence level      7.44107                 7.44107
#                   skew      0.04712                 0.04712
#               kurtosis     -0.88725                -0.88725
#       time correlation      0.62910                 0.62910
#
#           elasped time      6.47853
#      number of samples          202
#     number of outliers            0
#      getnsecs overhead          764
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  4     90.00000 |***                                 93.27490
#                  4     95.00000 |***                                 96.83906
#                 38    100.00000 |********************************   102.75222
#                 22    105.00000 |******************                 106.84092
#                  0    110.00000 |                                           -
#                  0    115.00000 |                                           -
#                  1    120.00000 |*                                  121.81122
#                  0    125.00000 |                                           -
#                  1    130.00000 |*                                  133.27106
#                  1    135.00000 |*                                  135.95138
#                  0    140.00000 |                                           -
#                  0    145.00000 |                                           -
#                  0    150.00000 |                                           -
#                  0    155.00000 |                                           -
#                  8    160.00000 |******                             162.64530
#                 23    165.00000 |*******************                167.89205
#                  8    170.00000 |******                             172.18434
#                  5    175.00000 |****                               177.86421
#                 24    180.00000 |********************               182.35554
#                 25    185.00000 |*********************              187.10597
#                  8    190.00000 |******                             191.67090
#                  2    195.00000 |*                                  196.14082
#                  1    200.00000 |*                                  203.23074
#                  2    205.00000 |*                                  206.99842
#                  2    210.00000 |*                                  212.81410
#                  7    215.00000 |*****                              216.82141
#                  2    220.00000 |*                                  224.35330
#                  3    225.00000 |**                                 226.62487
#
#                 11        > 95% |*********                          249.12526
#
#        mean of 95%    154.47679
#          95th %ile    228.20610
# bin/mprotect -E -C 200 -L -S -W -N mprot_wz128k -l 128k -I 1000 -w -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
mprot_wz128k   1   1    143.42541          188        0      100   131072 --w--
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    135.55597               135.55597
#                    max    333.92525               154.61517
#                   mean    147.91495               143.88327
#                 median    143.70701               143.42541
#                 stddev     20.05494                 3.94526
#         standard error      1.41106                 0.28774
#   99% confidence level      3.28213                 0.66928
#                   skew      6.40672                 0.44922
#               kurtosis     49.00736                -0.28328
#       time correlation     -0.01846                 0.01338
#
#           elasped time      3.01197
#      number of samples          188
#     number of outliers           14
#      getnsecs overhead          371
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    135.00000 |*                                  135.55597
#                  2    136.00000 |**                                 136.40717
#                  6    137.00000 |********                           137.48834
#                  8    138.00000 |***********                        138.44461
#                 12    139.00000 |*****************                  139.55938
#                 18    140.00000 |**************************         140.62818
#                 18    141.00000 |**************************         141.40628
#                 22    142.00000 |********************************   142.55233
#                 20    143.00000 |*****************************      143.47136
#                 16    144.00000 |***********************            144.50621
#                 13    145.00000 |******************                 145.54548
#                 12    146.00000 |*****************                  146.46456
#                 11    147.00000 |****************                   147.46881
#                  4    148.00000 |*****                              148.53773
#                 10    149.00000 |**************                     149.49159
#                  5    150.00000 |*******                            150.59495
#
#                 10        > 95% |**************                     152.63219
#
#        mean of 95%    143.39176
#          95th %ile    151.38701
# bin/mprotect -E -C 200 -L -S -W -N mprot_twz8k -l 8k -I 1000 -w -t -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
mprot_twz8k    1   1    161.58613          190        0      100     8192 --w-t
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    153.93685               153.93685
#                    max    288.23701               176.51861
#                   mean    166.70841               162.29986
#                 median    161.85749               161.58613
#                 stddev     19.02968                 4.77699
#         standard error      1.33892                 0.34656
#   99% confidence level      3.11434                 0.80610
#                   skew      3.93016                 0.66349
#               kurtosis     16.41386                -0.10948
#       time correlation     -0.07785                -0.01133
#
#           elasped time      3.39592
#      number of samples          190
#     number of outliers           12
#      getnsecs overhead          363
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    153.00000 |*                                  153.93685
#                  4    154.00000 |*****                              154.87317
#                 10    155.00000 |*************                      155.49410
#                  7    156.00000 |*********                          156.65155
#                 15    157.00000 |********************               157.56812
#                 10    158.00000 |*************                      158.52847
#                 18    159.00000 |************************           159.52903
#                 24    160.00000 |********************************   160.49482
#                 18    161.00000 |************************           161.65340
#                 15    162.00000 |********************               162.32836
#                 12    163.00000 |****************                   163.45408
#                  4    164.00000 |*****                              164.30677
#                 11    165.00000 |**************                     165.52830
#                  5    166.00000 |******                             166.69179
#                  9    167.00000 |************                       167.67694
#                  8    168.00000 |**********                         168.56757
#                  4    169.00000 |*****                              169.38581
#                  5    170.00000 |******                             170.50619
#
#                 10        > 95% |*************                      173.44968
#
#        mean of 95%    161.68042
#          95th %ile    170.81749
# bin/mprotect -E -C 200 -L -S -W -N mprot_tw128k -l 128k -I 2000 -w -t -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
mprot_tw128k   1   1    153.75144          173        0       50   131072 --w-t
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    139.03144               139.03144
#                    max    408.67112               169.75656
#                   mean    165.12179               153.66943
#                 median    155.03144               153.75144
#                 stddev     38.12922                 5.47247
#         standard error      2.68276                 0.41606
#   99% confidence level      6.24011                 0.96776
#                   skew      4.15972                 0.32442
#               kurtosis     19.25459                 0.04173
#       time correlation      0.12072                -0.00714
#
#           elasped time      1.69319
#      number of samples          173
#     number of outliers           29
#      getnsecs overhead          364
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    139.00000 |**                                 139.03144
#                  0    140.00000 |                                           -
#                  0    141.00000 |                                           -
#                  0    142.00000 |                                           -
#                  2    143.00000 |****                               143.76488
#                  5    144.00000 |**********                         144.38184
#                  6    145.00000 |************                       145.57309
#                  3    146.00000 |******                             146.48616
#                  4    147.00000 |********                           147.45896
#                 13    148.00000 |**************************         148.38332
#                 14    149.00000 |****************************       149.56511
#                 15    150.00000 |******************************     150.43095
#                 10    151.00000 |********************               151.42491
#                  7    152.00000 |**************                     152.55482
#                 11    153.00000 |**********************             153.64951
#                 10    154.00000 |********************               154.49486
#                 13    155.00000 |**************************         155.52138
#                 16    156.00000 |********************************   156.55080
#                 10    157.00000 |********************               157.54434
#                 10    158.00000 |********************               158.53301
#                  2    159.00000 |****                               159.73160
#                  6    160.00000 |************                       160.55251
#                  5    161.00000 |**********                         161.73250
#                  1    162.00000 |**                                 162.82920
#
#                  9        > 95% |******************                 166.15436
#
#        mean of 95%    152.98428
#          95th %ile    163.53576
# bin/mprotect -E -C 200 -L -S -W -N mprot_tw4m -l 4m -w -t -B 1 -f /dev/zero 
             prc thr   usecs/call      samples   errors cnt/samp     size flags
mprot_tw4m     1   1    349.18600          158        0        1  4194304 --w-t
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    280.06600               280.06600
#                    max   2683.13800               466.17800
#                   mean    443.28248               332.40018
#                 median    351.23400               349.18600
#                 stddev    270.59905                45.31460
#         standard error     19.03928                 3.60504
#   99% confidence level     44.28537                 8.38531
#                   skew      3.88482                 0.46203
#               kurtosis     23.53504                -0.40747
#       time correlation     -2.70571                -0.01398
#
#           elasped time      0.11231
#      number of samples          158
#     number of outliers           44
#      getnsecs overhead          766
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 43    280.00000 |********************************   281.66749
#                  5    284.00000 |***                                284.87880
#                  0    288.00000 |                                           -
#                 10    292.00000 |*******                            293.99240
#                  7    296.00000 |*****                              296.55971
#                  2    300.00000 |*                                  300.80200
#                  0    304.00000 |                                           -
#                  0    308.00000 |                                           -
#                  1    312.00000 |*                                  314.11400
#                  1    316.00000 |*                                  316.16200
#                  0    320.00000 |                                           -
#                  0    324.00000 |                                           -
#                  0    328.00000 |                                           -
#                  0    332.00000 |                                           -
#                  0    336.00000 |                                           -
#                  1    340.00000 |*                                  342.27400
#                  2    344.00000 |*                                  347.26600
#                 31    348.00000 |***********************            350.07787
#                 12    352.00000 |********                           353.36733
#                  0    356.00000 |                                           -
#                  6    360.00000 |****                               362.37000
#                  9    364.00000 |******                             365.34244
#                  6    368.00000 |****                               369.15400
#                  0    372.00000 |                                           -
#                  1    376.00000 |*                                  378.37000
#                  2    380.00000 |*                                  380.67400
#                  2    384.00000 |*                                  385.79400
#                  4    388.00000 |**                                 390.14600
#                  5    392.00000 |***                                393.47400
#
#                  8        > 95% |*****                              436.16200
#
#        mean of 95%    326.86621
#          95th %ile    397.31400
 
# bin/pipe -E -C 200 -L -S -W -N pipe_pst1 -s 1 -I 1000 -x pipe -m st 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_pst1      1   1     12.32599          175        0      100 st pipe
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     12.11351                12.11351
#                    max     54.68375                15.81527
#                   mean     14.40588                12.93859
#                 median     12.38487                12.32599
#                 stddev      4.62813                 1.01493
#         standard error      0.32563                 0.07672
#   99% confidence level      0.75743                 0.17845
#                   skew      4.40213                 1.06011
#               kurtosis     28.63646                -0.27813
#       time correlation      0.00173                -0.00008
#
#           elasped time      0.35750
#      number of samples          175
#     number of outliers           27
#      getnsecs overhead          553
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                116     12.00000 |********************************    12.26579
#                 21     13.00000 |*****                               13.64390
#                 29     14.00000 |********                            14.37964
#
#                  9        > 95% |**                                  15.32119
#
#        mean of 95%     12.80941
#          95th %ile     14.90391
# bin/pipe -E -C 200 -L -S -W -N pipe_pmt1 -s 1 -I 8000 -x pipe -m mt 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_pmt1      1   1    231.03617          196        0       12 mt pipe
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    174.20417               174.20417
#                    max    525.37217               388.68950
#                   mean    250.93066               244.64085
#                 median    232.87083               231.03617
#                 stddev     62.16917                51.03254
#         standard error      4.37421                 3.64518
#   99% confidence level     10.17441                 8.47869
#                   skew      1.44517                 0.86733
#               kurtosis      2.38737                -0.15696
#       time correlation     -0.05800                -0.03981
#
#           elasped time      0.92360
#      number of samples          196
#     number of outliers            6
#      getnsecs overhead          558
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  4    174.00000 |********                           175.45217
#                  8    180.00000 |****************                   183.40950
#                 14    186.00000 |****************************       189.84455
#                 12    192.00000 |************************           194.95617
#                  5    198.00000 |**********                         200.17110
#                 14    204.00000 |****************************       206.72836
#                 16    210.00000 |********************************   212.75617
#                  6    216.00000 |************                       218.96861
#                 12    222.00000 |************************           225.03261
#                 13    228.00000 |**************************         231.21504
#                  9    234.00000 |******************                 236.83883
#                  8    240.00000 |****************                   242.74817
#                  7    246.00000 |**************                     248.34360
#                  8    252.00000 |****************                   255.23350
#                  4    258.00000 |********                           261.32417
#                  5    264.00000 |**********                         266.25323
#                  4    270.00000 |********                           274.98283
#                  5    276.00000 |**********                         279.41163
#                  1    282.00000 |**                                 287.95350
#                  2    288.00000 |****                               292.41217
#                  5    294.00000 |**********                         295.97483
#                  4    300.00000 |********                           302.67883
#                  2    306.00000 |****                               308.74283
#                  5    312.00000 |**********                         314.48790
#                  2    318.00000 |****                               321.87350
#                  2    324.00000 |****                               325.91617
#                  2    330.00000 |****                               333.07350
#                  5    336.00000 |**********                         339.21750
#                  2    342.00000 |****                               342.87617
#
#                 10        > 95% |********************               363.98550
#
#        mean of 95%    238.22447
#          95th %ile    344.20950
# bin/pipe -E -C 200 -L -S -W -N pipe_pmp1 -s 1 -I 8000 -x pipe -m mp 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_pmp1      1   1    324.89633          200        0       12 mp pipe
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    191.22167               191.22167
#                    max    985.05633               605.96300
#                   mean    333.21623               327.31745
#                 median    324.89633               324.89633
#                 stddev    113.29614                96.92484
#         standard error      7.97149                 6.85362
#   99% confidence level     18.54168                15.94152
#                   skew      1.73562                 0.65286
#               kurtosis      6.09568                -0.34110
#       time correlation     -0.09662                -0.04245
#
#           elasped time      2.72253
#      number of samples          200
#     number of outliers            2
#      getnsecs overhead          380
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    180.00000 |*                                  191.22167
#                 24    200.00000 |************************           210.74167
#                 31    220.00000 |********************************   231.53891
#                 12    240.00000 |************                       248.34700
#                  9    260.00000 |*********                          270.03411
#                  9    280.00000 |*********                          289.67026
#                 10    300.00000 |**********                         308.80673
#                 21    320.00000 |*********************              330.17989
#                 19    340.00000 |*******************                348.74251
#                 13    360.00000 |*************                      367.28567
#                  6    380.00000 |******                             387.07944
#                  6    400.00000 |******                             410.63500
#                  6    420.00000 |******                             434.59589
#                  9    440.00000 |*********                          450.62552
#                 10    460.00000 |**********                         468.58700
#                  4    480.00000 |****                               488.75767
#
#                 10        > 95% |**********                         550.62007
#
#        mean of 95%    315.56468
#          95th %ile    501.72833
# bin/pipe -E -C 200 -L -S -W -N pipe_pst4k -s 4k -I 1000 -x pipe -m st 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_pst4k     1   1     13.98667          188        0      100 st pipe
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     13.58475                13.58475
#                    max     31.30507                18.54603
#                   mean     15.54063                14.75003
#                 median     14.07627                13.98667
#                 stddev      3.28094                 1.27137
#         standard error      0.23085                 0.09272
#   99% confidence level      0.53695                 0.21568
#                   skew      2.99375                 1.04848
#               kurtosis      9.15393                -0.00780
#       time correlation     -0.01938                -0.00191
#
#           elasped time      0.38031
#      number of samples          188
#     number of outliers           14
#      getnsecs overhead          373
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 96     13.00000 |********************************    13.78598
#                 24     14.00000 |********                            14.30230
#                 31     15.00000 |**********                          15.59286
#                 25     16.00000 |********                            16.39686
#                  2     17.00000 |*                                   17.09707
#
#                 10        > 95% |***                                 17.88017
#
#        mean of 95%     14.57418
#          95th %ile     17.22507
# bin/pipe -E -C 200 -L -S -W -N pipe_pmt4k -s 4k -I 8000 -x pipe -m mt 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_pmt4k     1   1    245.62292          196        0       12 mt pipe
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    180.81225               180.81225
#                    max    842.80692               488.97225
#                   mean    287.34426               277.38433
#                 median    248.80158               245.62292
#                 stddev     94.52670                73.58831
#         standard error      6.65088                 5.25631
#   99% confidence level     15.46994                12.22617
#                   skew      2.04987                 1.04086
#               kurtosis      6.52209                 0.19966
#       time correlation     -0.19352                -0.20700
#
#           elasped time      1.01111
#      number of samples          196
#     number of outliers            6
#      getnsecs overhead          365
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    180.00000 |*                                  180.81225
#                  9    189.00000 |*********                          193.46766
#                  8    198.00000 |********                           201.06292
#                 14    207.00000 |***************                    211.71815
#                 20    216.00000 |**********************             220.82078
#                 29    225.00000 |********************************   229.17712
#                 17    234.00000 |******************                 238.75484
#                  8    243.00000 |********                           248.68692
#                  5    252.00000 |*****                              255.55145
#                  6    261.00000 |******                             264.91536
#                  5    270.00000 |*****                              274.96905
#                  5    279.00000 |*****                              282.41865
#                  1    288.00000 |*                                  289.63358
#                  5    297.00000 |*****                              303.13332
#                  5    306.00000 |*****                              311.03092
#                  8    315.00000 |********                           319.06558
#                  5    324.00000 |*****                              327.63252
#                  6    333.00000 |******                             339.52514
#                  9    342.00000 |*********                          347.04158
#                  2    351.00000 |**                                 358.51892
#                  3    360.00000 |***                                363.10558
#                  3    369.00000 |***                                372.89047
#                  3    378.00000 |***                                379.24781
#                  3    387.00000 |***                                389.85758
#                  0    396.00000 |                                           -
#                  2    405.00000 |**                                 411.88425
#                  3    414.00000 |***                                419.94469
#                  1    423.00000 |*                                  431.79892
#
#                 10        > 95% |***********                        464.82718
#
#        mean of 95%    267.30676
#          95th %ile    443.53225
# bin/pipe -E -C 200 -L -S -W -N pipe_pmp4k -s 4k -I 8000 -x pipe -m mp 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_pmp4k     1   1    370.59383          198        0       12 mp pipe
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    195.68183               195.68183
#                    max    998.49783               634.84983
#                   mean    363.90351               354.46077
#                 median    371.51117               370.59383
#                 stddev    119.76738                98.76427
#         standard error      8.42680                 7.01887
#   99% confidence level     19.60074                16.32589
#                   skew      1.46467                 0.28905
#               kurtosis      4.90488                -0.69479
#       time correlation     -0.23929                -0.12533
#
#           elasped time      2.90399
#      number of samples          198
#     number of outliers            4
#      getnsecs overhead          874
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    180.00000 |**                                 196.75917
#                 11    200.00000 |***********                        213.99553
#                 18    220.00000 |******************                 231.52539
#                 22    240.00000 |**********************             248.53517
#                 12    260.00000 |************                       269.46850
#                  6    280.00000 |******                             286.55117
#                  3    300.00000 |***                                312.11917
#                  3    320.00000 |***                                334.64717
#                 14    340.00000 |**************                     352.65402
#                 32    360.00000 |********************************   372.57450
#                 18    380.00000 |******************                 389.80213
#                  8    400.00000 |********                           407.30050
#                 10    420.00000 |**********                         431.47063
#                 11    440.00000 |***********                        449.88595
#                  5    460.00000 |*****                              471.27863
#                  6    480.00000 |******                             488.51028
#                  3    500.00000 |***                                508.70583
#                  4    520.00000 |****                               522.25783
#
#                 10        > 95% |**********                         560.68663
#
#        mean of 95%    343.49131
#          95th %ile    525.92183
 
# bin/pipe -E -C 200 -L -S -W -N pipe_sst1 -s 1 -I 1000 -x sock -m st 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_sst1      1   1     51.46099          188        0      100 st sock
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     45.75219                45.75219
#                    max    142.27187                70.91187
#                   mean     56.15305                53.14124
#                 median     51.89107                51.46099
#                 stddev     13.52945                 6.15546
#         standard error      0.95193                 0.44893
#   99% confidence level      2.21419                 1.04422
#                   skew      3.16636                 0.84301
#               kurtosis     12.53550                -0.40417
#       time correlation      0.05548                 0.06482
#
#           elasped time      1.26305
#      number of samples          188
#     number of outliers           14
#      getnsecs overhead          781
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  5     45.00000 |******                              45.82387
#                 24     46.00000 |********************************    46.60040
#                 20     47.00000 |**************************          47.52627
#                 14     48.00000 |******************                  48.50090
#                  4     49.00000 |*****                               49.73235
#                 17     50.00000 |**********************              50.53081
#                 20     51.00000 |**************************          51.43744
#                 17     52.00000 |**********************              52.58784
#                  7     53.00000 |*********                           53.65125
#                  5     54.00000 |******                              54.55347
#                  5     55.00000 |******                              55.45049
#                  4     56.00000 |*****                               56.53683
#                  2     57.00000 |**                                  57.35283
#                  2     58.00000 |**                                  58.08755
#                  6     59.00000 |********                            59.38590
#                  3     60.00000 |****                                60.60019
#                  5     61.00000 |******                              61.50182
#                  7     62.00000 |*********                           62.42840
#                  7     63.00000 |*********                           63.25528
#                  4     64.00000 |*****                               64.20403
#
#                 10        > 95% |*************                       66.79565
#
#        mean of 95%     52.37413
#          95th %ile     64.60147
# bin/pipe -E -C 200 -L -S -W -N pipe_smt1 -s 1 -I 8000 -x sock -m mt 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_smt1      1   1    438.01667          193        0       12 mt sock
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    317.78200               317.78200
#                    max   1571.26467               771.03000
#                   mean    498.65910               471.86382
#                 median    446.61400               438.01667
#                 stddev    172.10470               105.51767
#         standard error     12.10924                 7.59533
#   99% confidence level     28.16610                17.66673
#                   skew      3.02750                 0.93340
#               kurtosis     13.44945                 0.23784
#       time correlation     -0.71346                -0.44472
#
#           elasped time      1.63127
#      number of samples          193
#     number of outliers            9
#      getnsecs overhead          760
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    300.00000 |*                                  317.78200
#                  6    320.00000 |*******                            328.73311
#                 11    340.00000 |*************                      347.02612
#                 18    360.00000 |*********************              370.57489
#                 16    380.00000 |******************                 387.35133
#                 20    400.00000 |***********************            409.32760
#                 27    420.00000 |********************************   429.33084
#                 13    440.00000 |***************                    450.84292
#                  5    460.00000 |*****                              468.80493
#                 11    480.00000 |*************                      491.41206
#                 10    500.00000 |***********                        509.73293
#                  9    520.00000 |**********                         527.76837
#                  8    540.00000 |*********                          548.98733
#                 10    560.00000 |***********                        567.18573
#                  1    580.00000 |*                                  595.03000
#                  4    600.00000 |****                               612.08600
#                  6    620.00000 |*******                            627.26467
#                  3    640.00000 |***                                649.76422
#                  3    660.00000 |***                                663.70911
#                  1    680.00000 |*                                  681.60067
#
#                 10        > 95% |***********                        736.52973
#
#        mean of 95%    457.40121
#          95th %ile    687.68067
# bin/pipe -E -C 200 -L -S -W -N pipe_smp1 -s 1 -I 8000 -x sock -m mp 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_smp1      1   1    564.47183          199        0       12 mp sock
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    367.71450               367.71450
#                    max   1217.03717              1035.55450
#                   mean    602.15569               593.40487
#                 median    566.64783               564.47183
#                 stddev    172.31287               157.90952
#         standard error     12.12389                11.19391
#   99% confidence level     28.20017                26.03703
#                   skew      1.02614                 0.75979
#               kurtosis      0.76426                -0.26024
#       time correlation     -0.27386                -0.30289
#
#           elasped time      3.64785
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          354
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    360.00000 |***                                369.09050
#                 13    380.00000 |************************           393.47860
#                 11    400.00000 |********************               410.90868
#                 15    420.00000 |****************************       431.31343
#                  7    440.00000 |*************                      448.11983
#                  8    460.00000 |***************                    469.38117
#                  5    480.00000 |*********                          486.65637
#                  2    500.00000 |***                                517.13317
#                 17    520.00000 |********************************   529.98336
#                 16    540.00000 |******************************     551.25850
#                 13    560.00000 |************************           567.75717
#                 14    580.00000 |**************************         586.16936
#                 12    600.00000 |**********************             607.45850
#                  7    620.00000 |*************                      628.79793
#                  5    640.00000 |*********                          646.58383
#                  3    660.00000 |*****                              667.38383
#                  5    680.00000 |*********                          687.28357
#                  2    700.00000 |***                                705.92250
#                  4    720.00000 |*******                            729.97050
#                  2    740.00000 |***                                752.01317
#                  1    760.00000 |*                                  768.97317
#                  2    780.00000 |***                                793.64517
#                  8    800.00000 |***************                    809.94383
#                  5    820.00000 |*********                          831.67610
#                  2    840.00000 |***                                852.59983
#                  2    860.00000 |***                                869.81583
#                  6    880.00000 |***********                        887.63628
#
#                 10        > 95% |******************                 950.47930
#
#        mean of 95%    574.51204
#          95th %ile    903.05317
# bin/pipe -E -C 200 -L -S -W -N pipe_sst4k -s 4k -I 1000 -x sock -m st 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_sst4k     1   1     66.43592          189        0      100 st sock
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     55.58664                55.58664
#                    max    131.62632                82.38472
#                   mean     68.82176                66.13059
#                 median     68.37640                66.43592
#                 stddev     12.48391                 6.43978
#         standard error      0.87836                 0.46843
#   99% confidence level      2.04308                 1.08956
#                   skew      2.53542                 0.22435
#               kurtosis      8.04817                -0.74193
#       time correlation      0.07491                 0.07017
#
#           elasped time      1.51979
#      number of samples          189
#     number of outliers           13
#      getnsecs overhead          376
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  3     55.00000 |****                                55.67624
#                 11     56.00000 |****************                    56.47263
#                 10     57.00000 |**************                      57.48053
#                  4     58.00000 |*****                               58.55624
#                 11     59.00000 |****************                    59.40546
#                 12     60.00000 |*****************                   60.72563
#                 16     61.00000 |***********************             61.38568
#                  9     62.00000 |*************                       62.58540
#                  8     63.00000 |***********                         63.51496
#                  5     64.00000 |*******                             64.52258
#                  5     65.00000 |*******                             65.46210
#                  2     66.00000 |**                                  66.48072
#                  3     67.00000 |****                                67.43688
#                  9     68.00000 |*************                       68.55276
#                 14     69.00000 |********************                69.65622
#                 22     70.00000 |********************************    70.46850
#                 14     71.00000 |********************                71.45096
#                  9     72.00000 |*************                       72.39674
#                  7     73.00000 |**********                          73.54394
#                  2     74.00000 |**                                  74.25544
#                  3     75.00000 |****                                75.41896
#
#                 10        > 95% |**************                      79.65730
#
#        mean of 95%     65.37491
#          95th %ile     76.09480
# bin/pipe -E -C 200 -L -S -W -N pipe_smt4k -s 4k -I 8000 -x sock -m mt 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_smt4k     1   1    460.54650          195        0       12 mt sock
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    358.38117               358.38117
#                    max   1402.62650               859.62917
#                   mean    529.13950               512.48190
#                 median    470.06117               460.54650
#                 stddev    148.23650               116.98308
#         standard error     10.42988                 8.37733
#   99% confidence level     24.25991                19.48568
#                   skew      1.85757                 0.99777
#               kurtosis      5.52902                 0.12490
#       time correlation      0.01536                -0.23228
#
#           elasped time      1.68899
#      number of samples          195
#     number of outliers            7
#      getnsecs overhead          482
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    340.00000 |*                                  358.38117
#                  2    360.00000 |**                                 362.79717
#                 16    380.00000 |****************                   393.06117
#                 32    400.00000 |********************************   411.27917
#                 22    420.00000 |**********************             428.31862
#                 24    440.00000 |************************           449.70472
#                 10    460.00000 |**********                         468.43770
#                  5    480.00000 |*****                              490.47717
#                  4    500.00000 |****                               508.51983
#                  8    520.00000 |********                           531.51183
#                  9    540.00000 |*********                          547.26413
#                  8    560.00000 |********                           571.10917
#                 14    580.00000 |**************                     590.11907
#                  8    600.00000 |********                           607.26383
#                  3    620.00000 |***                                630.21050
#                  3    640.00000 |***                                649.82294
#                  4    660.00000 |****                               674.70650
#                  3    680.00000 |***                                690.76872
#                  4    700.00000 |****                               708.99983
#                  3    720.00000 |***                                729.34650
#                  2    740.00000 |**                                 742.65850
#
#                 10        > 95% |**********                         802.66063
#
#        mean of 95%    496.79656
#          95th %ile    749.37850
# bin/pipe -E -C 200 -L -S -W -N pipe_smp4k -s 4k -I 8000 -x sock -m mp 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_smp4k     1   1    464.30983          193        0       12 mp sock
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    376.71517               376.71517
#                    max    972.70450               829.21650
#                   mean    525.43828               507.98348
#                 median    470.53917               464.30983
#                 stddev    134.36285               109.39823
#         standard error      9.45374                 7.87466
#   99% confidence level     21.98939                18.31645
#                   skew      1.39385                 1.26489
#               kurtosis      1.10997                 0.70024
#       time correlation     -0.45362                -0.21682
#
#           elasped time      3.10967
#      number of samples          193
#     number of outliers            9
#      getnsecs overhead          378
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    360.00000 |*                                  376.71517
#                 10    380.00000 |*********                          391.88743
#                 20    400.00000 |******************                 411.58557
#                 35    420.00000 |********************************   429.44080
#                 22    440.00000 |********************               449.72656
#                 23    460.00000 |*********************              469.38624
#                 11    480.00000 |**********                         488.30208
#                 10    500.00000 |*********                          508.34823
#                  4    520.00000 |***                                527.94717
#                  5    540.00000 |****                               546.65223
#                 10    560.00000 |*********                          569.07783
#                  6    580.00000 |*****                              592.09294
#                  6    600.00000 |*****                              609.35517
#                  5    620.00000 |****                               624.74930
#                  4    640.00000 |***                                648.92850
#                  1    660.00000 |*                                  674.89117
#                  1    680.00000 |*                                  695.39250
#                  2    700.00000 |*                                  711.47783
#                  5    720.00000 |****                               734.32157
#                  2    740.00000 |*                                  744.30983
#
#                 10        > 95% |*********                          792.09650
#
#        mean of 95%    492.45818
#          95th %ile    763.14717
 
# bin/pipe -E -C 200 -L -S -W -N pipe_tst1 -s 1 -I 1000 -x tcp -m st 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_tst1      1   1    202.78668          197        0      100 st  tcp
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    169.13804               169.13804
#                    max    459.95660               388.36620
#                   mean    231.20113               226.20982
#                 median    203.24492               202.78668
#                 stddev     63.57170                55.81854
#         standard error      4.47289                 3.97691
#   99% confidence level     10.40394                 9.25028
#                   skew      1.54903                 1.44545
#               kurtosis      1.60064                 1.07515
#       time correlation      0.01681                -0.00280
#
#           elasped time      5.14861
#      number of samples          197
#     number of outliers            5
#      getnsecs overhead          372
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                 16    168.00000 |**************                     172.46156
#                 12    175.00000 |**********                         178.16567
#                 11    182.00000 |*********                          184.24064
#                 25    189.00000 |**********************             192.58580
#                 36    196.00000 |********************************   199.56897
#                 19    203.00000 |****************                   205.60376
#                 13    210.00000 |***********                        212.23722
#                  3    217.00000 |**                                 218.57847
#                  4    224.00000 |***                                228.42636
#                  2    231.00000 |*                                  235.04140
#                  4    238.00000 |***                                241.62508
#                  6    245.00000 |*****                              249.17985
#                  7    252.00000 |******                             255.95825
#                  1    259.00000 |*                                  265.43500
#                  2    266.00000 |*                                  269.54636
#                  4    273.00000 |***                                276.14412
#                  3    280.00000 |**                                 283.02647
#                  1    287.00000 |*                                  289.60396
#                  3    294.00000 |**                                 296.61580
#                  0    301.00000 |                                           -
#                  2    308.00000 |*                                  311.55724
#                  2    315.00000 |*                                  318.43980
#                  4    322.00000 |***                                326.00076
#                  2    329.00000 |*                                  335.74540
#                  2    336.00000 |*                                  340.21132
#                  1    343.00000 |*                                  346.47692
#                  1    350.00000 |*                                  353.11756
#                  1    357.00000 |*                                  357.96620
#
#                 10        > 95% |********                           377.07148
#
#        mean of 95%    218.14235
#          95th %ile    359.74796
# bin/pipe -E -C 200 -L -S -W -N pipe_tmt1 -s 1 -I 8000 -x tcp -m mt 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_tmt1      1   1   1021.84475          199        0       12 mt  tcp
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    479.93542               479.93542
#                    max   1651.94608              1452.50075
#                   mean    973.53943               963.78721
#                 median   1024.70342              1021.84475
#                 stddev    217.74180               204.17032
#         standard error     15.32026                14.47325
#   99% confidence level     35.63492                33.66478
#                   skew     -0.42561                -0.86272
#               kurtosis      0.86972                 0.37164
#       time correlation      0.54843                 0.47438
#
#           elasped time      3.49851
#      number of samples          199
#     number of outliers            3
#      getnsecs overhead          775
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    450.00000 |*                                  479.93542
#                  9    480.00000 |**********                         497.62549
#                  5    510.00000 |*****                              522.68742
#                  4    540.00000 |****                               550.37275
#                  2    570.00000 |**                                 584.42608
#                  1    600.00000 |*                                  618.43142
#                  3    630.00000 |***                                643.55497
#                  1    660.00000 |*                                  686.67675
#                  4    690.00000 |****                               700.97542
#                  4    720.00000 |****                               724.01542
#                  2    750.00000 |**                                 765.43942
#                  3    780.00000 |***                                791.67942
#                  5    810.00000 |*****                              829.70822
#                  3    840.00000 |***                                852.37986
#                  5    870.00000 |*****                              880.35782
#                  3    900.00000 |***                                912.62519
#                  3    930.00000 |***                                949.21186
#                 14    960.00000 |****************                   978.43751
#                 25    990.00000 |*****************************     1006.50523
#                 27   1020.00000 |********************************  1034.61710
#                 24   1050.00000 |****************************      1061.81453
#                 22   1080.00000 |**************************        1092.49493
#                  7   1110.00000 |********                          1123.26951
#                  8   1140.00000 |*********                         1149.34075
#                  4   1170.00000 |****                              1187.89275
#
#                 10        > 95% |***********                       1319.36368
#
#        mean of 95%    944.97364
#          95th %ile   1226.51675
# bin/pipe -E -C 200 -L -S -W -N pipe_tmp1 -s 1 -I 8000 -x tcp -m mp 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_tmp1      1   1    847.03975          201        0       12 mp  tcp
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    444.03175               444.03175
#                    max   1780.09575              1737.85575
#                   mean    871.58840               867.06846
#                 median    848.85308               847.03975
#                 stddev    298.78411               292.52495
#         standard error     21.02238                20.63312
#   99% confidence level     48.89805                47.99263
#                   skew      0.31493                 0.23434
#               kurtosis     -0.80922                -1.05356
#       time correlation      2.23183                 2.16700
#
#           elasped time      4.90132
#      number of samples          201
#     number of outliers            1
#      getnsecs overhead          771
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    420.00000 |*                                  444.03175
#                  6    450.00000 |**********                         468.22375
#                 14    480.00000 |***********************            492.22375
#                 19    510.00000 |********************************   524.96929
#                  8    540.00000 |*************                      550.73042
#                  3    570.00000 |*****                              581.46108
#                 10    600.00000 |****************                   613.63602
#                  8    630.00000 |*************                      640.06375
#                  6    660.00000 |**********                         674.61308
#                  6    690.00000 |**********                         700.81042
#                 11    720.00000 |******************                 735.73211
#                  2    750.00000 |***                                765.14108
#                  1    780.00000 |*                                  806.44242
#                  5    810.00000 |********                           824.22162
#                  3    840.00000 |*****                              850.49575
#                  2    870.00000 |***                                882.06908
#                  2    900.00000 |***                                902.43175
#                  6    930.00000 |**********                         940.04242
#                  3    960.00000 |*****                              972.99886
#                  6    990.00000 |**********                        1004.37664
#                  2   1020.00000 |***                               1029.43975
#                 13   1050.00000 |*********************             1068.57985
#                  8   1080.00000 |*************                     1097.52242
#                 11   1110.00000 |******************                1127.87175
#                  8   1140.00000 |*************                     1155.72775
#                 11   1170.00000 |******************                1183.49939
#                  8   1200.00000 |*************                     1213.62108
#                  5   1230.00000 |********                          1242.33788
#                  2   1260.00000 |***                               1262.17575
#
#                 11        > 95% |******************                1399.89114
#
#        mean of 95%    836.22083
#          95th %ile   1267.86108
# bin/pipe -E -C 200 -L -S -W -N pipe_tst4k -s 4k -I 1000 -x tcp -m st 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_tst4k     1   1    206.25146          198        0      100 st  tcp
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    176.08186               176.08186
#                    max    437.10202               374.42298
#                   mean    230.84017               227.29785
#                 median    206.46138               206.25146
#                 stddev     55.47764                49.93568
#         standard error      3.90339                 3.54877
#   99% confidence level      9.07929                 8.25445
#                   skew      1.41107                 1.26979
#               kurtosis      1.14032                 0.39661
#       time correlation      0.02501                 0.05106
#
#           elasped time      5.12748
#      number of samples          198
#     number of outliers            4
#      getnsecs overhead          774
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  9    174.00000 |***********                        177.28762
#                 16    180.00000 |********************               183.03690
#                 21    186.00000 |**************************         190.33545
#                 25    192.00000 |********************************   194.96954
#                 18    198.00000 |***********************            201.48460
#                 25    204.00000 |********************************   206.61539
#                 13    210.00000 |****************                   212.83184
#                  7    216.00000 |********                           218.92053
#                  4    222.00000 |*****                              223.81306
#                  1    228.00000 |*                                  228.88186
#                  3    234.00000 |***                                236.88527
#                  2    240.00000 |**                                 242.14266
#                  6    246.00000 |*******                            249.54362
#                  4    252.00000 |*****                              253.64218
#                  3    258.00000 |***                                261.27610
#                  2    264.00000 |**                                 268.12794
#                  2    270.00000 |**                                 271.37146
#                  5    276.00000 |******                             278.30317
#                  2    282.00000 |**                                 285.27738
#                  0    288.00000 |                                           -
#                  1    294.00000 |*                                  295.44442
#                  1    300.00000 |*                                  304.62458
#                  5    306.00000 |******                             310.84896
#                  3    312.00000 |***                                314.97295
#                  2    318.00000 |**                                 319.72218
#                  5    324.00000 |******                             327.70196
#                  3    330.00000 |***                                330.10938
#
#                 10        > 95% |************                       349.48295
#
#        mean of 95%    220.79865
#          95th %ile    330.88250
# bin/pipe -E -C 200 -L -S -W -N pipe_tmt4k -s 4k -I 8000 -x tcp -m mt 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_tmt4k     1   1    651.52042          200        0       12 mt  tcp
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    441.94175               441.94175
#                    max   1682.60308              1382.76308
#                   mean    749.29541               740.92735
#                 median    654.86975               651.52042
#                 stddev    244.82807               230.95800
#         standard error     17.22604                16.33120
#   99% confidence level     40.06778                37.98636
#                   skew      0.98234                 0.79545
#               kurtosis      0.39445                -0.42454
#       time correlation     -0.14991                -0.18477
#
#           elasped time      2.66482
#      number of samples          200
#     number of outliers            2
#      getnsecs overhead          763
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1    420.00000 |*                                  441.94175
#                  6    450.00000 |********                           465.29819
#                 15    480.00000 |*********************              496.77695
#                 19    510.00000 |***************************        525.33375
#                 22    540.00000 |********************************   555.45642
#                 17    570.00000 |************************           581.30740
#                 15    600.00000 |*********************              610.34708
#                 10    630.00000 |**************                     649.58762
#                  4    660.00000 |*****                              672.74708
#                  1    690.00000 |*                                  690.68842
#                  8    720.00000 |***********                        736.11242
#                  2    750.00000 |**                                 773.35508
#                  6    780.00000 |********                           792.49464
#                 12    810.00000 |*****************                  823.93819
#                  6    840.00000 |********                           853.48308
#                  7    870.00000 |**********                         886.98556
#                  3    900.00000 |****                               912.51242
#                  7    930.00000 |**********                         948.36765
#                  4    960.00000 |*****                              971.95775
#                  5    990.00000 |*******                            999.17268
#                  0   1020.00000 |                                           -
#                  8   1050.00000 |***********                       1063.58175
#                  2   1080.00000 |**                                1095.76575
#                  8   1110.00000 |***********                       1124.53908
#                  1   1140.00000 |*                                 1142.93375
#                  1   1170.00000 |*                                 1173.78175
#
#                 10        > 95% |**************                    1270.30655
#
#        mean of 95%    713.06529
#          95th %ile   1178.17642
# bin/pipe -E -C 200 -L -S -W -N pipe_tmp4k -s 4k -I 8000 -x tcp -m mp 
             prc thr   usecs/call      samples   errors cnt/samp md xprt
pipe_tmp4k     1   1    761.37542          200        0       12 mp  tcp
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    469.21542               469.21542
#                    max   1797.81275              1549.04475
#                   mean    848.97726               839.66139
#                 median    762.63408               761.37542
#                 stddev    298.87238               285.32448
#         standard error     21.02859                20.17549
#   99% confidence level     48.91249                46.92818
#                   skew      0.65001                 0.50361
#               kurtosis     -0.57768                -1.13397
#       time correlation     -0.31887                -0.25104
#
#           elasped time      4.84285
#      number of samples          200
#     number of outliers            2
#      getnsecs overhead          391
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  2    450.00000 |**                                 472.42608
#                  5    480.00000 |******                             507.08635
#                 12    510.00000 |****************                   521.93364
#                 24    540.00000 |********************************   553.79497
#                 20    570.00000 |**************************         586.69488
#                 12    600.00000 |****************                   618.67497
#                  7    630.00000 |*********                          644.52361
#                  9    660.00000 |************                       676.51379
#                  6    690.00000 |********                           700.68208
#                  2    720.00000 |**                                 739.09275
#                  8    750.00000 |**********                         767.79942
#                  3    780.00000 |****                               785.97275
#                  3    810.00000 |****                               828.51853
#                  6    840.00000 |********                           853.54964
#                  4    870.00000 |*****                              882.59142
#                  4    900.00000 |*****                              912.46342
#                  2    930.00000 |**                                 948.84208
#                  2    960.00000 |**                                 982.42075
#                  3    990.00000 |****                              1005.24386
#                  2   1020.00000 |**                                1034.47408
#                  6   1050.00000 |********                          1065.62431
#                  6   1080.00000 |********                          1095.56208
#                  6   1110.00000 |********                          1123.52653
#                 10   1140.00000 |*************                     1160.06982
#                  8   1170.00000 |**********                        1185.32742
#                  6   1200.00000 |********                          1214.37097
#                 10   1230.00000 |*************                     1244.57542
#                  1   1260.00000 |*                                 1284.70342
#                  1   1290.00000 |*                                 1311.30608
#
#                 10        > 95% |*************                     1410.29702
#
#        mean of 95%    809.62794
#          95th %ile   1316.63942
 
# bin/connection -E -C 200 -L -S -W -N conn_accept -B 256 -a 
             prc thr   usecs/call      samples   errors cnt/samp 
conn_accept    1   1     90.27916          189        0      256 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min     75.55316                75.55316
#                    max    198.11516               145.19316
#                   mean    101.15698                96.36028
#                 median     93.06916                90.27916
#                 stddev     24.43918                16.41451
#         standard error      1.71953                 1.19398
#   99% confidence level      3.99964                 2.77720
#                   skew      1.64572                 0.95565
#               kurtosis      2.51851                -0.01752
#       time correlation     -0.09683                -0.05211
#
#           elasped time     69.71433
#      number of samples          189
#     number of outliers           13
#      getnsecs overhead          471
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  1     74.00000 |*                                   75.55316
#                  8     76.00000 |*************                       77.26816
#                 10     78.00000 |****************                    79.05476
#                 16     80.00000 |**************************          81.03297
#                 16     82.00000 |**************************          82.98535
#                 19     84.00000 |********************************    84.88195
#                  6     86.00000 |**********                          87.17466
#                 15     88.00000 |*************************           89.01296
#                  8     90.00000 |*************                       90.68991
#                 11     92.00000 |******************                  93.36907
#                  4     94.00000 |******                              94.95441
#                  9     96.00000 |***************                     96.67683
#                  2     98.00000 |***                                 99.76566
#                  7    100.00000 |***********                        101.17773
#                  6    102.00000 |**********                         103.21699
#                  3    104.00000 |*****                              105.13749
#                  1    106.00000 |*                                  106.36116
#                  3    108.00000 |*****                              108.82483
#                  6    110.00000 |**********                         111.12383
#                  6    112.00000 |**********                         112.64316
#                  3    114.00000 |*****                              114.47216
#                  6    116.00000 |**********                         116.68066
#                  2    118.00000 |***                                119.25966
#                  3    120.00000 |*****                              120.54249
#                  3    122.00000 |*****                              122.79883
#                  1    124.00000 |*                                  125.79116
#                  2    126.00000 |***                                127.17566
#                  1    128.00000 |*                                  128.03316
#                  1    130.00000 |*                                  130.77516
#
#                 10        > 95% |****************                   136.11436
#
#        mean of 95%     94.13938
#          95th %ile    131.35416
 
# bin/close_tcp -E -C 200 -L -S -W -N close_tcp -B 32 
             prc thr   usecs/call      samples   errors cnt/samp 
close_tcp      1   1    186.02034          192        0       32 
#
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min    100.23634               100.23634
#                    max    583.39634               413.42834
#                   mean    213.58474               199.30593
#                 median    188.52434               186.02034
#                 stddev     94.53989                71.73849
#         standard error      6.65180                 5.17728
#   99% confidence level     15.47209                12.04235
#                   skew      1.38824                 0.76655
#               kurtosis      2.03864                 0.10337
#       time correlation      0.11611                 0.09194
#
#           elasped time      9.61122
#      number of samples          192
#     number of outliers           10
#      getnsecs overhead          373
#
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                  8     99.00000 |*****************                  103.18234
#                 15    108.00000 |********************************   111.73501
#                  8    117.00000 |*****************                  122.07434
#                 10    126.00000 |*********************              130.88354
#                 10    135.00000 |*********************              140.63074
#                 11    144.00000 |***********************            148.22107
#                  6    153.00000 |************                       157.44168
#                 14    162.00000 |*****************************      166.14263
#                  7    171.00000 |**************                     176.12206
#                 13    180.00000 |***************************        184.88804
#                 13    189.00000 |***************************        193.85481
#                  4    198.00000 |********                           201.28434
#                  0    207.00000 |                                           -
#                  2    216.00000 |****                               218.20434
#                  7    225.00000 |**************                     228.74492
#                  9    234.00000 |*******************                238.11190
#                  2    243.00000 |****                               248.99234
#                 11    252.00000 |***********************            256.93234
#                 14    261.00000 |*****************************      264.85177
#                  7    270.00000 |**************                     274.67977
#                  4    279.00000 |********                           283.63034
#                  3    288.00000 |******                             289.01234
#                  0    297.00000 |                                           -
#                  1    306.00000 |**                                 312.33234
#                  3    315.00000 |******                             318.85768
#
#                 10        > 95% |*********************              380.47714
#
#        mean of 95%    189.35146
#          95th %ile    347.51634
````

测试结果解释：

1）开头信息段（环境说明）

````
!Libmicro_#:                            0.4.1
!Options:                  -E -C 200 -L -S -W
!Machine_name:          localhost.localdomain
!OS_name:                               Linux
!OS_release:   6.6.0-138.0.0.121.oe2403sp3.riscv64
!OS_build:                 #1 SMP Fri Feb  6 
!Processor:                           riscv64
!#CPUs:                                     8
!CPU_MHz:                                    
!CPU_NAME:                                   
!IP_address:                              ::1
!Run_by:                                 root
!Date:	                       04/28/26 09:37
!Compiler:                                gcc
!Compiler Ver.:                            12
!sizeof(long):                              8
````

测试工具版本：libMicro 0.4.1

内核：6.6.0

架构：RISC-V 64 位

CPU：8 核

编译器：GCC 12

运行时间：2026-04-28

````
!Options:                  -E -C 200 -L -S -W
````

运行参数：

- `-E`：输出详细统计
- `-C 200`：每组测试循环 200 次取稳定值
- `-L`：循环测试
- `-S`：单线程模式
- `-W`：输出警告

2）测试块

每个测试块的输出包含以下几个部分：

- 命令回显：以 `# bin/...` 开头，显示运行的命令和参数。

- 测试名和基本结果：一行表格，给出 `prc`（进程数）、`thr`（线程数）、`usecs/call`（每次调用的平均微秒数，已去除异常值）、`samples`（有效样本数）等。

- 详细统计表：包含原始数据（raw）和去除异常值后（outliers removed）的统计量。

- 分布直方图：以 ASCII 字符画的形式展示调用耗时的分布。

- 可能的警告：如 “Quantization error likely”。

下面以文件开头的 `getpid` 测试为例，逐行解释其含义

````
# bin/getpid -E -C 200 -L -S -W -N getpid -I 5
````

- `#` 注释行，记录了执行的命令。
- `bin/getpid`：测量 `getpid()` 系统调用的性能。
- `-E`：启用高精度计时。
- `-C 200`：每个 CPU 进行 200 次采样。
- `-L`：锁定进程到单个 CPU。
- `-S`：输出统计信息。
- `-W`：输出直方图。
- `-N getpid`：指定测试名称。
- `-I 5`：最小迭代时间 5 秒（即至少运行 5 秒收集数据）。

````
             prc thr   usecs/call      samples   errors cnt/samp 
getpid         1   1      1.44063          177        0    20000 
````

这是基本结果表格，各列含义：

- `prc`：进程数 = 1。
- `thr`：每进程线程数 = 1。
- `usecs/call`：**去除异常值后**的平均每次调用耗时，这里是 **1.44063 微秒**。（核心指标，越小越快）
- `samples`：有效样本数 = 177。
- `errors`：错误数 = 0。
- `cnt/samp`：每次采样调用次数 = 20000（即每次采样连续调用 20000 次 `getpid` 取平均）。

接着是统计部分：

````
# STATISTICS         usecs/call (raw)          usecs/call (outliers removed)
#                    min      1.38417                 1.38417
#                    max      3.15788                 1.59198
#                   mean      1.53754                 1.45203
#                 median      1.44743                 1.44063
#                 stddev      0.31364                 0.04870
#         standard error      0.02207                 0.00366
#   99% confidence level      0.05133                 0.00851
#                   skew      4.04627                 1.20003
#               kurtosis     16.12777                 1.02731
#       time correlation     -0.00140                 0.00005
````

- 左侧 `(raw)` 是包含所有原始数据的统计量，右侧 `(outliers removed)` 是去除统计异常值后的结果。
- `min` / `max`：最小 / 最大单次调用耗时（微秒）。
- `mean`：算术平均值（平均耗时）。
- `median`：中位数。
- `stddev`：标准差，反映数据波动大小（越小越稳定）。
- `standard error`：均值的标准误差。
- `99% confidence level`：99% 置信区间半宽（即均值 ± 该值）。
- `skew`：偏度，正偏表示长尾在右侧。
- `kurtosis`：峰度，>3 表示分布比正态分布更尖。
- `time correlation`：耗时与采样顺序的相关性，接近 0 表示无趋势。

再下面是辅助信息：

````
#           elasped time      6.23400
#      number of samples          177
#     number of outliers           25
#      getnsecs overhead          412
````

- `elapsed time`：测试实际运行时间（秒）。
- `number of samples`：有效样本数（与上表一致）。
- `number of outliers`：被剔除的异常值个数 = 25。
- `getnsecs overhead`：计时开销（纳秒）。

然后是分布直方图：

````
# DISTRIBUTION
#	      counts   usecs/call                                         means
#                168      1.00000 |********************************     1.44490
#
#                  9        > 95% |*                                    1.58523
````

- `counts`：位于该区间的观测次数。
- `usecs/call`：区间的中心值（这里 1.00000 表示 [0.5, 1.5) 微秒区间）。
- 星号 `*` 表示相对频度。
- `means`：该区间内所有观测值的平均耗时。
- `> 95%`：表示超过 95% 分位数的异常值（实际上是去除异常值后，最后 5% 的数据单独列出）。
- 最后两行：

````
#        mean of 95%      1.44490
#          95th %ile      1.57458
````

- `mean of 95%`：前 95% 数据的平均值（即去除最大的 5% 后的均值）。
- `95th %ile`：95% 分位数，即 95% 的调用耗时 ≤ 1.57458 微秒。

其他测试块的格式与上述示例完全一致，只是测试的操作不同，例如：

- `getenv`：获取环境变量
- `gettimeofday`：获取当前时间
- `memset` / `memcpy`：内存操作，会带 `-s` 参数表示大小
- `malloc` / `free`：动态内存分配
- `open` / `close`：文件操作
- `socket` / `bind`：网络操作
- `pthread_create`：线程创建
- `fork` / `exec`：进程创建
- `pipe`：管道通信（支持 pipe、socket、tcp 等传输方式）
- `mmap` / `munmap`：内存映射
- `mprotect`：修改内存保护属性




构建平台能看见这个包，https://build.tarsier-infra.isrc.ac.cn/package/show/openEuler:25.03:Epol/wrk

```bash
[root@localhost apache-jmeter-5.6.3]# yum list wrk
Last metadata expiration check: 0:55:56 ago on Thu 05 Jun 2025 09:39:44 AM CST.
Available Packages
wrk.riscv64                         4.2.0-2.oe2503                          oerv
wrk.riscv64                         4.2.0-2.oe2503                          EPOL
wrk.src                             4.2.0-2.oe2503                          oerv
[root@localhost apache-jmeter-5.6.3]# dnf install -y wrk.riscv64
Last metadata expiration check: 0:57:24 ago on Thu 05 Jun 2025 09:39:44 AM CST.
Dependencies resolved.
Installed:
  wrk-4.2.0-2.oe2503.riscv64                                                    

Complete!
[root@localhost wrk]# wrk -v
wrk 4.2.0 [epoll] Copyright (C) 2012 Will Glozer
Usage: wrk <options> <url>                            
  Options:                                            
    -c, --connections <N>  Connections to keep open   
    -d, --duration    <T>  Duration of test           
    -t, --threads     <N>  Number of threads to use   
                                                      
    -s, --script      <S>  Load Lua script file       
    -H, --header      <H>  Add header to request      
        --latency          Print latency statistics   
        --timeout     <T>  Socket/request timeout     
    -v, --version          Print version details      
                                                      
  Numeric arguments may include a SI unit (1k, 1M, 1G)
  Time arguments may include a time unit (2s, 2m, 2h)

#使用脚本执行命令进行测试,脚本测试了wrk支持的子命令
./run_wrk_test.sh
```


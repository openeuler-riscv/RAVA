## 在 openEuler RISC-V 镜像中执行 Apache JMeter 测试

### 1. Apache JMeter 介绍

#### 1.1 定义

Apache JMeter 是 Apache 基金会**纯 Java 开源**负载 / 性能测试工具，最初用于 Web 压测，现已支持全场景接口、服务性能验证。

#### 1.2 核心能力

协议覆盖：HTTP/HTTPS、JDBC 数据库、JMS 消息、FTP、TCP、MQTT、Shell 脚本等；

测试类型：并发负载、压力测试、稳定性测试、接口功能自动化；

两种运行模式：

- GUI 图形界面：本地编写、调试`.jmx`测试脚本（RISC-V 服务器无显示器一般不用）；

- Headless 无 GUI 命令行：服务器压测标准执行方式，资源占用低、适合自动化、CI/LAVA 测试；

输出：原始结果日志 + 自动生成可视化 HTML 性能报告（吞吐量、95% 响应时间、错误率等）。

### 2. 执行测试

安装 java

````
$ dnf install -y java-17-openjdk-devel wget tar
$ java -version
$ file $(which java)
````

配置 JAVA_HOME

````
# 写入全局环境变量
$ echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk' | tee -a /etc/profile
$ echo 'export PATH=$JAVA_HOME/bin:$PATH' | tee -a /etc/profile

# 生效配置
source /etc/profile

# 校验
echo $JAVA_HOME
````

下载并解压 JMeter

````
$ wget https://archive.apache.org/dist/jmeter/binaries/apache-jmeter-5.6.3.tgz
$ tar -zxvf apache-jmeter-5.6.3.tgz -C /opt/
$ chown -R $USER:$USER /opt/apache-jmeter-5.6.3

# 配置全局JMETER_HOME环境变量
$ echo 'export JMETER_HOME=/opt/apache-jmeter-5.6.3' | tee -a /etc/profile
$ echo 'export PATH=$JMETER_HOME/bin:$PATH' | tee -a /etc/profile
$ source /etc/profile

# 验证JMeter命令
$ jmeter -v
````

执行压测命令

50并发，持续60s压测内网服务

````
$ jmeter \
-Jthreads=50 \
-Jduration=60 \
-Jhost=10.30.190.110 \
-Jport=80 \
-Jscheme=http \
-Jpath=/ \
-Jmethod=GET \
-n -t base.jmx -l result.jtl -e -o report_out
````

参数说明

| 参数          | 含义                                                     | 本次取值      |
| ------------- | -------------------------------------------------------- | ------------- |
| -Jhost        | IP / 域名                                                | 10.30.190.110 |
| -Jport        | 端口                                                     | 80            |
| -Jscheme      | 协议                                                     | http / https  |
| -Jpath        | 接口路径                                                 | /             |
| -Jmethod      | 请求方式                                                 | GET / POST    |
| -Jthreads     | 并发用户数                                               | 50            |
| -Jduration    | 压测时长 (秒)                                            | 60            |
| -n            | 启用无 GUI 模式（必须）                                  |               |
| -t test.jmx   | 指定测试脚本（Windows/GUI 提前编辑好上传到 RISC-V 机器） | base.jmx      |
| -l result.jtl | 输出原始性能日志文件                                     | result.jtl    |
| -e            | 测试结束自动生成 HTML 报告                               |               |
| -o report_dir | HTML 报告输出目录（目录必须为空 / 不存在）               | report_out    |

jmx 测试脚本内容

````
<?xml version="1.0" encoding="UTF-8"?>
<jmeterTestPlan version="1.2" properties="5.0" jmeter="5.6.3">
  <hashTree>
    <TestPlan guiclass="TestPlanGui" testclass="TestPlan" testname="内网通用压测模板" enabled="true">
      <stringProp name="TestPlan.comments">IP、端口、协议、路径全部命令行传参，无硬编码</stringProp>
      <boolProp name="TestPlan.functional_mode">false</boolProp>
      <boolProp name="TestPlan.tearDown_on_shutdown">true</boolProp>
      <boolProp name="TestPlan.serialize_threadgroups">false</boolProp>
      <elementProp name="TestPlan.user_defined_variables" elementType="Arguments" guiclass="ArgumentsPanel" testclass="Arguments" testname="全局变量" enabled="true"/>
      <stringProp name="TestPlan.user_define_classpath"></stringProp>
    </TestPlan>
    <hashTree>
      <!-- 线程组：并发、时长传参 -->
      <ThreadGroup guiclass="ThreadGroupGui" testclass="ThreadGroup" testname="压测线程组" enabled="true">
        <stringProp name="ThreadGroup.on_sample_error">continue</stringProp>
        <elementProp name="ThreadGroup.main_controller" elementType="LoopController" guiclass="LoopControlPanel" testclass="LoopController" testname="永久循环控制器" enabled="true">
          <boolProp name="LoopController.continue_forever">true</boolProp>
          <stringProp name="LoopController.loops">1</stringProp>
        </elementProp>
        <stringProp name="ThreadGroup.num_threads">${__P(threads,10)}</stringProp>
        <stringProp name="ThreadGroup.ramp_time">3</stringProp>
        <longProp name="ThreadGroup.start_time">1700000000000</longProp>
        <longProp name="ThreadGroup.end_time">1700000000000</longProp>
        <boolProp name="ThreadGroup.scheduler">true</boolProp>
        <stringProp name="ThreadGroup.duration">${__P(duration,30)}</stringProp>
        <stringProp name="ThreadGroup.delay">0</stringProp>
        <boolProp name="ThreadGroup.same_user_on_next_iteration">true</boolProp>
      </ThreadGroup>
      <hashTree>
        <!-- HTTP请求 全部使用参数占位符 -->
        <HTTPSamplerProxy guiclass="HttpTestSampleGui" testclass="HTTPSamplerProxy" testname="动态目标请求" enabled="true">
          <elementProp name="HTTPsampler.Arguments" elementType="Arguments" guiclass="HTTPArgumentsPanel" testclass="Arguments" testname="URL参数" enabled="true">
            <collectionProp name="Arguments.arguments"/>
          </elementProp>
          <stringProp name="HTTPSampler.domain">${__P(host,127.0.0.1)}</stringProp>
          <stringProp name="HTTPSampler.port">${__P(port,80)}</stringProp>
          <stringProp name="HTTPSampler.protocol">${__P(scheme,http)}</stringProp>
          <stringProp name="HTTPSampler.path">${__P(path,/)}</stringProp>
          <stringProp name="HTTPSampler.method">${__P(method,GET)}</stringProp>
          <boolProp name="HTTPSampler.follow_redirects">true</boolProp>
          <boolProp name="HTTPSampler.use_keepalive">true</boolProp>
          <boolProp name="HTTPSampler.DO_MULTIPART_POST">false</boolProp>
          <stringProp name="HTTPSampler.connect_timeout">5000</stringProp>
          <stringProp name="HTTPSampler.response_timeout">10000</stringProp>
        </HTTPSamplerProxy>
        <hashTree>
          <HeaderManager guiclass="HeaderPanel" testclass="HeaderPanel" testname="请求头管理器" enabled="true">
            <collectionProp name="HeaderManager.headers">
              <elementProp name="" elementType="Header">
                <stringProp name="Header.name">User-Agent</stringProp>
                <stringProp name="Header.value">JMeter-Internal-PerfTest</stringProp>
              </elementProp>
            </collectionProp>
          </HeaderManager>
        </hashTree>
      </hashTree>
    </hashTree>
  </hashTree>
</jmeterTestPlan>
````

测试结果

````
$ jmeter \
-Jthreads=50 \
-Jduration=60 \
-Jhost=10.30.190.110 \
-Jport=80 \
-Jscheme=http \
-Jpath=/ \
-Jmethod=GET \
-n -t base.jmx -l result.jtl -e -o report_out
WARN StatusConsoleListener The use of package scanning to locate plugins is deprecated and will be removed in a future release
WARN StatusConsoleListener The use of package scanning to locate plugins is deprecated and will be removed in a future release
WARN StatusConsoleListener The use of package scanning to locate plugins is deprecated and will be removed in a future release
WARN StatusConsoleListener The use of package scanning to locate plugins is deprecated and will be removed in a future release
Creating summariser <summary>
Created the tree successfully using base.jmx
Starting standalone test @ 2026 Jun 17 13:32:35 UTC (1781703155531)
Waiting for possible Shutdown/StopTestNow/HeapDump/ThreadDump message on port 4445
summary +  22609 in 00:00:23 =  971.7/s Avg:    18 Min:     2 Max:   791 Err:     0 (0.00%) Active: 50 Started: 50 Finished: 0
summary +  70788 in 00:00:30 = 2361.7/s Avg:    13 Min:     1 Max:   477 Err:     0 (0.00%) Active: 50 Started: 50 Finished: 0
summary =  93397 in 00:00:53 = 1752.5/s Avg:    14 Min:     1 Max:   791 Err:     0 (0.00%)
summary +  19770 in 00:00:08 = 2492.7/s Avg:    13 Min:     1 Max:   193 Err:     0 (0.00%) Active: 0 Started: 50 Finished: 50
summary = 113167 in 00:01:01 = 1848.2/s Avg:    14 Min:     1 Max:   791 Err:     0 (0.00%)
Tidying up ...    @ 2026 Jun 17 13:33:37 UTC (1781703217968)
... end of run
````

**summary 日志字段通用含义**

````
summary +  22609 in 00:00:23 =  971.7/s Avg:    18 Min:     2 Max:   791 Err:     0 (0.00%) Active: 50 Started: 50 Finished: 0
````

字段释义：

`summary +`：本次周期新增请求数

`summary =`：**累计总请求**

`971.7/s`：当前吞吐量 QPS（每秒完成请求）

`Avg`：平均响应时间（单位：毫秒 ms）

`Min`：最小响应时间

`Max`：最大响应时间

`Err`：失败请求总数 + 错误率

`Active`：当前活跃并发线程

`Started/Finished`：已启动 / 已结束虚拟用户

**分段日志解读**

前 23 秒：完成 22609 次请求，瞬时 QPS 971，平均耗时 18ms，50 用户全部在线；

累计 53 秒：总 93397 请求，平均 QPS 1752，平均响应 14ms；

最后 8 秒收尾：新增 19770 请求，瞬时 QPS 拉高至 2492，平均仅 13ms；

全部跑完汇总：

````
summary = 113167 in 00:01:01 = 1848.2/s Avg:    14 Min:     1 Max:   791 Err:     0 (0.00%)
````

总请求量：113167 次

总运行时长：61 秒

整体平均 QPS：1848.2

平均响应时间：14ms

最快 1ms，最慢单次 791ms（存在少量毛刺延迟）

错误请求：0，错误率 0%






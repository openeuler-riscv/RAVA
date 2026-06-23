## 在 openEuler RISC-V 镜像中执行 pgbench 测试

### 1. pgbench 介绍

`pgbench` 是 **PostgreSQL 官方自带的轻量级基准测试工具**，它通过在多个并发数据库会话中反复执行相同的 SQL 命令序列，计算每秒事务数（TPS，Transactions Per Second）来评估数据库性能。

### 核心特点

- **简单易用**：作为 PostgreSQL 核心工具的一部分，安装后即可使用，无需额外部署
- **默认场景**：默认执行基于 TPC-B 标准的事务测试，每个事务包含 5 条 SQL 命令（SELECT、UPDATE、INSERT）
- **高度可定制**：支持编写自定义事务脚本，可灵活模拟特定业务场景
- **多线程并发**：通过 `-j` 参数利用多 CPU 核心提升压测能力

### 2. 执行测试

#### 2.1 server 端安装和配置

````
# 安装 PostgreSQL 服务器
$ dnf install -y postgresql-server postgresql-contrib

# 初始化数据库目录
$ postgresql-setup --initdb

# 启动 PostgreSQL 服务
$ systemctl start postgresql

# 修改配置放开远程访问
$ PG_DATA=/var/lib/pgsql/data
$ sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" ${PG_DATA}/postgresql.conf
$ sed -i '/host    all             all             127.0.0.1\/32/a host    all             all             10.0.0.0\/24            md5' ${PG_DATA}/pg_hba.conf
$ sed -i 's/ ident$/ md5/' ${PG_DATA}/pg_hba.conf
$ systemctl restart postgresql

# 切换postgres建库+pgbench初始化数据 SCALE=30适配RISC-V板卡内存
$ SCALE=30    #设置 pgbench 的缩放因子为 30。这意味着测试数据量是默认值的 30 倍（默认约 10 万行/因子，30 倍约 300 万行数据）
$ PG_DBNAME="pgbenchdb"    #指定要创建的测试数据库名称
$ PG_USER="postgres"       #指定执行操作的操作系统用户（PostgreSQL 的超级用户）
$ su - ${PG_USER} -c "psql -c \"ALTER USER ${PG_USER} WITH PASSWORD '123456';\""    # 设置postgres密码123456
$ su - ${PG_USER} -c "createdb ${PG_DBNAME}"    #切换到 postgres 系统用户执行 createdb 命令，创建名为 pgbenchdb 的空数据库，用于存放测试表
$ su - ${PG_USER} -c "pgbench -i -s ${SCALE} ${PG_DBNAME}"   #初始化测试数据，在已创建的数据库中生成测试表和数据，数据量约为 300 万行，执行后会在数据库中创建 4 张表：pgbench_accounts、pgbench_branches、pgbench_tellers、pgbench_history
````

#### 2.2 client 安装和是配置

安装 pgbench

````
$ dnf install -y postgresql-contrib
````

查看 pgbench 支持选项

````
$ pgbench --help
pgbench is a benchmarking tool for PostgreSQL.

Usage:
  pgbench [OPTION]... [DBNAME]

Initialization options:
  -i, --initialize         invokes initialization mode
  -I, --init-steps=[dtgGvpf]+ (default "dtgvp")
                           run selected initialization steps
  -F, --fillfactor=NUM     set fill factor
  -n, --no-vacuum          do not run VACUUM during initialization
  -q, --quiet              quiet logging (one message each 5 seconds)
  -s, --scale=NUM          scaling factor
  --foreign-keys           create foreign key constraints between tables
  --index-tablespace=TABLESPACE
                           create indexes in the specified tablespace
  --partition-method=(range|hash)
                           partition pgbench_accounts with this method (default: range)
  --partitions=NUM         partition pgbench_accounts into NUM parts (default: 0)
  --tablespace=TABLESPACE  create tables in the specified tablespace
  --unlogged-tables        create tables as unlogged tables

Options to select what to run:
  -b, --builtin=NAME[@W]   add builtin script NAME weighted at W (default: 1)
                           (use "-b list" to list available scripts)
  -f, --file=FILENAME[@W]  add script FILENAME weighted at W (default: 1)
  -N, --skip-some-updates  skip updates of pgbench_tellers and pgbench_branches
                           (same as "-b simple-update")
  -S, --select-only        perform SELECT-only transactions
                           (same as "-b select-only")

Benchmarking options:
  -c, --client=NUM         number of concurrent database clients (default: 1)
  -C, --connect            establish new connection for each transaction
  -D, --define=VARNAME=VALUE
                           define variable for use by custom script
  -j, --jobs=NUM           number of threads (default: 1)
  -l, --log                write transaction times to log file
  -L, --latency-limit=NUM  count transactions lasting more than NUM ms as late
  -M, --protocol=simple|extended|prepared
                           protocol for submitting queries (default: simple)
  -n, --no-vacuum          do not run VACUUM before tests
  -P, --progress=NUM       show thread progress report every NUM seconds
  -r, --report-per-command report latencies, failures, and retries per command
  -R, --rate=NUM           target rate in transactions per second
  -s, --scale=NUM          report this scale factor in output
  -t, --transactions=NUM   number of transactions each client runs (default: 10)
  -T, --time=NUM           duration of benchmark test in seconds
  -v, --vacuum-all         vacuum all four standard tables before tests
  --aggregate-interval=NUM aggregate data over NUM seconds
  --failures-detailed      report the failures grouped by basic types
  --log-prefix=PREFIX      prefix for transaction time log file
                           (default: "pgbench_log")
  --max-tries=NUM          max number of tries to run transaction (default: 1)
  --progress-timestamp     use Unix epoch timestamps for progress
  --random-seed=SEED       set random seed ("time", "rand", integer)
  --sampling-rate=NUM      fraction of transactions to log (e.g., 0.01 for 1%)
  --show-script=NAME       show builtin script code, then exit
  --verbose-errors         print messages of all errors

Common options:
  -d, --debug              print debugging output
  -h, --host=HOSTNAME      database server host or socket directory
  -p, --port=PORT          database server port number
  -U, --username=USERNAME  connect as specified database user
  -V, --version            output version information, then exit
  -?, --help               show this help, then exit

Report bugs to <pgsql-bugs@lists.postgresql.org>.
PostgreSQL home page: <https://www.postgresql.org/>
````

基本用法：

````
$ pgbench [选项]... [数据库名]
````

如果不指定数据库名，默认使用当前用户名的数据库。

1）初始化参数（-i 初始化模式专用，建测试表：pgbench_accounts/branches/tellers/history，首次使用必须执行）

使用格式：`pgbench -i -s 100 testdb` 初始化 100 倍数据量

| 参数                                | 说明                                                         |
| ----------------------------------- | ------------------------------------------------------------ |
| -i --initialize                     | 开启初始化模式，创建 4 张基准测试表                          |
| -I --init-steps                     | 自定义初始化步骤，默认`dtgvp`：d = 删旧表、t = 建表、g = 填充数据、v = 真空、p = 建主键索引 |
| -F --fillfactor=NUM                 | 表填充因子，默认 100，压测常用 80，预留更新空间              |
| -n --no-vacuum                      | 初始化完不执行 VACUUM（大数据量初始化提速）                  |
| -q --quiet                          | 静默初始化，每 5s 打印一条日志                               |
| -s --scale=NUM                      | **数据缩放系数（最关键）**，scale=1 约 10 万条账户数据，s=10=100 万 |
| --foreign-keys                      | 表之间创建外键约束，贴近真实业务、增加开销                   |
| --unlogged-tables                   | 建非日志表，跳过 WAL，初始化更快、宕机丢数据                 |
| --partition-method / --partitions=N | 对 pgbench_account 做分区，range/hash 分区，N 个分区         |
| --tablespace/--index-tablespace     | 指定表 / 索引落地表空间，用来测不同存储性能                  |

2）压测脚本选择（指定跑什么 SQL）

内置 4 种压测脚本（-b）

````
-b list 查看全部内置脚本
````

| 参数                     | 含义                                                         |
| ------------------------ | ------------------------------------------------------------ |
| `-b builtin[@权重]`      | 选用内置脚本，权重控制混合负载占比：1. `tpcb-like`：默认全量 TPCC（查 + 改 + 事务）2. `simple-update`：精简更新3. `select-only`：纯查询只读4. `read-write`：读写混合 |
| `-f file[@W]`            | 加载**自定义 SQL 脚本文件**，@W 为权重，多脚本混合压测       |
| `-N --skip-some-updates` | 等价 `-b simple-update`，减少 update 更新                    |
| `-S --select-only`       | 等价 `-b select-only`，**只读压测（只 select）**，测读性能   |

3）压测运行核心参数（最常用，并发、时长、线程、TPS、延迟）

示例

````
$ pgbench -c 100 -j4 -T30 testdb   #100 并发、4 线程、跑 30 秒
````

| 参数                    | 释义                                                         |
| ----------------------- | ------------------------------------------------------------ |
| -c --client=NUM         | **并发客户端数**（数据库并发连接数），压测核心，-c 200=200 并发 |
| -j --jobs=NUM           | 压测进程 / 线程数，建议等于 CPU 核数                         |
| -t --transactions=N     | 每个客户端执行 N 笔事务，跑完结束；**和 - T 二选一**         |
| -T --time=N             | **压测持续 N 秒（常用）**，固定时长压测                      |
| -P --progress=N         | 每 N 秒输出一次实时压测进度（例：-P5 每 5s 打印一次 tps）    |
| -r --report-per-command | 输出每条 SQL 单独平均耗时                                    |
| -L --latency-limit=ms   | 超过该毫秒的事务标记为慢事务、统计失败                       |
| -R --rate=N             | 限流：目标每秒总事务数，限速压测                             |
| -C --connect            | **每条事务新建数据库连接**（模拟短连接场景，开销大），默认长连接复用 |
| -M protocol             | 协议：simple (默认)/extended/prepared，prepared 预编译 SQL 减少解析开销 |
| -l --log                | 把每条事务耗时写入本地日志，配合`--log-prefix`自定义日志名   |
| -D VAR=VAL              | 给自定义脚本传变量                                           |
| -n --no-vacuum          | 压测前不做 vacuum（压测提速）                                |
| -v --vacuum-all         | 压测前全表 vacuum，清理碎片                                  |

4）通用连接参数（连接 PG 库必备）

| 参数            | 作用                |
| --------------- | ------------------- |
| `-h --host`     | PG 数据库 IP / 主机 |
| `-p --port`     | PG 端口，默认 5432  |
| `-U --username` | 连接用户名          |
| `-d debug`      | 打开调试日志        |
| `-V/-?`         | 版本 / 帮助         |

5）其他实用选项

| 选项                       | 说明                       |
| :------------------------- | :------------------------- |
| `-d, --debug`              | 打印调试信息               |
| `-V, --version`            | 显示版本信息               |
| `--random-seed=SEED`       | 设置随机种子（可重复测试） |
| `--verbose-errors`         | 显示所有错误详情           |
| `--aggregate-interval=NUM` | 每N秒聚合输出结果          |

命令实例：

初始化 10 倍数据

````
$ pgbench -i -s 10 postgres
````

只读压测：200 并发、8 线程、跑 60 秒，每 5 秒输出进度，使用数据库超级用户 `postgres` 身份连接本地数据库 `postgres`，对其进行测试

````
$ pgbench -S -c200 -j8 -T60 -P5 -h127.0.0.1 -Upostgres postgres
````

混合读写 TPCC 压测

````
$ pgbench -c100 -j4 -T120 -h127.0.0.1 postgres
````

备注：**TPCC (TPC-C)** 是由 **TPC (Transaction Processing Performance Council)** 组织制定的一个**行业标准基准测试**，专门用于衡量数据库在**在线事务处理（OLTP）**场景下的性能。

````
$ export PGPASSWORD=123456
$ pgbench -h 10.0.0.2 -U postgres -c 50 -j 4 -T 60 -r pgbenchdb
pgbench (15.15)
starting vacuum...end.
transaction type: <builtin: TPC-B (sort of)>
scaling factor: 30
query mode: simple
number of clients: 50
number of threads: 4
maximum number of tries: 1
duration: 60 s
number of transactions actually processed: 11905
number of failed transactions: 0 (0.000%)
latency average = 234.371 ms
initial connection time = 4975.075 ms
tps = 213.336573 (without initial connection time)
statement latencies in milliseconds and failures:
         0.028           0  \set aid random(1, 100000 * :scale)
         0.011           0  \set bid random(1, 1 * :scale)
         0.010           0  \set tid random(1, 10 * :scale)
         0.008           0  \set delta random(-5000, 5000)
        10.581           0  BEGIN;
        27.548           0  UPDATE pgbench_accounts SET abalance = abalance + :delta WHERE aid = :aid;
        17.697           0  SELECT abalance FROM pgbench_accounts WHERE aid = :aid;
        32.748           0  UPDATE pgbench_tellers SET tbalance = tbalance + :delta WHERE tid = :tid;
        73.285           0  UPDATE pgbench_branches SET bbalance = bbalance + :delta WHERE bid = :bid;
        17.104           0  INSERT INTO pgbench_history (tid, bid, aid, delta, mtime) VALUES (:tid, :bid, :aid, :delta, CURRENT_TIMESTAMP);
        53.106           0  END;
````

测试结果：

基础压测配置

````
transaction type: <builtin: TPC-B (sort of)>  # 默认内置TPC-B银行混合事务：2UPDATE+1SELECT+1INSERT+事务开闭
scaling factor: 30                            # -s=30，主表pgbench_accounts=300万行(10w×30)
query mode: simple                            # 普通简单SQL协议，非预编译prepared
number of clients: 50                         # 并发数据库连接50个
number of threads: 4                          # 4个工作线程
duration: 60 s                                # 稳定压测60秒
````

核心性能指标

````
number of transactions actually processed: 11905  # 60s总共完成11905笔完整事务
number of failed transactions: 0 (0.000%)        # 事务失败0，SQL、锁、连接无报错
latency average = 234.371 ms                    # **单笔事务平均耗时234.37ms**
initial connection time = 4975.075 ms            # 客户端批量建立50个连接总耗时
tps = 213.336573 (without initial connection time) # **有效TPS≈213.34，每秒完成213个事务**
````

TPS 释义：剔除初始化建连耗时，业务稳态吞吐 `213 TPS`

单条 SQL 平均耗时（单位 ms，`-r`参数输出）

| SQL 语句                | 平均耗时 ms | 说明                                           |
| ----------------------- | ----------- | ---------------------------------------------- |
| 变量 \set               | 0.01 左右   | 客户端本地随机生成参数，无数据库交互，耗时忽略 |
| BEGIN                   | 10.58       | 开启事务                                       |
| UPDATE pgbench_accounts | 27.55       | 更新账户表，数据量最大                         |
| SELECT abalance         | 17.70       | 查询账户余额                                   |
| UPDATE pgbench_tellers  | 32.75       | 柜员表更新                                     |
| UPDATE pgbench_branches | 73.29       | **分支表更新耗时最高，瓶颈点**                 |
| INSERT history          | 17.10       | 插入流水历史表                                 |
| END(COMMIT)             | 53.11       | 事务提交落盘，刷磁盘 IO 耗时高                 |




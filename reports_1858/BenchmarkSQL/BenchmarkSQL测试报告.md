# BenchmarkSQL v5.0 on PostgreSQL 简短性能测试报告

**参考文档：[BenchmarkSQL](https://github.com/meiq4096/benchmarksql-5.0)  `HOW-TO-RUN.txt`**

---

## 一、测试环境

| 项目   | 配置                       |
| ---- | ------------------------ |
| 环境 | openEuler 25.03 RISC-V64 |
| 数据库  | PostgreSQL 15.10         |
| 测试工具 | BenchmarkSQL v5.0（源码编译）  |
| Java | openjdk version "1.8.0_432"            |
| 编译工具 | Ant                      |


---

## 二、测试准备过程（依照官方 `HOW-TO-RUN.txt` 步骤）

### 1. 安装依赖（JDK、Ant、PostgreSQL）

```bash
dnf install -y java-1.8.0-openjdk-devel ant postgresql postgresql-server
```

### 2. 初始化数据库并启动

```bash
postgresql-setup --initdb
systemctl enable --now postgresql
```

### 3. 创建数据库用户和数据库

```bash
sudo -u postgres psql <<EOF
DROP DATABASE IF EXISTS benchmarksql;
DROP ROLE IF EXISTS benchmarksql;
CREATE USER benchmarksql WITH ENCRYPTED PASSWORD 'changeme';
CREATE DATABASE benchmarksql OWNER benchmarksql;
EOF
```

验证连接，正常：

```bash
psql -U benchmarksql -h 127.0.0.1 -d benchmarksql -c '\conninfo'
```

### 4. 编译 BenchmarkSQL 源码

```bash
cd benchmarksql-5.0
ant
```

成功生成 `dist/BenchmarkSQL-5.0.jar`。

### 5. 编辑配置文件 `my_postgres.properties`

```ini
db=postgres
driver=org.postgresql.Driver
conn=jdbc:postgresql://127.0.0.1:5432/benchmarksql
user=benchmarksql
password=changeme

warehouses=1
loadWorkers=1

terminals=1
runTxnsPerTerminal=10
runMins=0
limitTxnsPerMin=0

terminalWarehouseFixed=true

newOrderWeight=45
paymentWeight=43
orderStatusWeight=4
deliveryWeight=4
stockLevelWeight=4
```

> 因性能限制，配置为小负载。

---


## 三、测试执行过程

### 1. 构建数据库与加载数据

参考官方文档 `HOW-TO-RUN.txt`，运行：

```bash
cd run
./runDatabaseBuild.sh my_postgres.properties
```

输出如下（节选）：

```
Starting BenchmarkSQL LoadData

driver=org.postgresql.Driver
conn=jdbc:postgresql://127.0.0.1:5432/benchmarksql
user=benchmarksql
password=***********
warehouses=1
loadWorkers=1

Worker 000: Loading ITEM
Worker 000: Loading ITEM done
Worker 000: Loading Warehouse      1
Worker 000: Loading Warehouse      1 done
```

数据加载成功完成，未出现异常。

---

### 2. 运行基准测试

继续运行基准测试：

```bash
./runBenchmark.sh my_postgres.properties
```

输出如下（节选）：

```
Term-00, Running Average tpmTOTAL: 471.99    Current tpmTOTAL: 2904
Term-00, Running Average tpmTOTAL: 473.49    Current tpmTOTAL: 2976
...
Term-00, Measured tpmC (NewOrders) = 212.56
Term-00, Measured tpmTOTAL = 471.03
Term-00, Session Start     = 2025-05-23 14:04:01
Term-00, Session End       = 2025-05-23 14:05:01
Term-00, Transaction Count = 471
```

测试用例按配置运行 60 秒，完成全部事务处理与性能统计。

---

## 四、部分测试结果示例

| 指标名称           | 值      | 说明                    |
| -------------- | ------ | --------------------- |
| tpmC（NewOrder） | 212.56 | 每分钟处理的 NewOrder 类型事务数 |
| tpmTOTAL       | 471.03 | 每分钟处理的全部事务数           |
| 事务总数           | 471    | 60 秒内完成的事务数           |

---

## 五、结论

BenchmarkSQL 成功在 PostgreSQL 上完成测试，运行正常。
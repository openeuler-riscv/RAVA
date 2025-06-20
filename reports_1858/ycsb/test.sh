#!/bin/bash

echo "开始 YCSB 测试..."

# 默认线程，workloada（混合读写）
echo "[1/8] load_a..."
./bin/ycsb load redis -s -P workloads/workloada -p "redis.host=localhost" > ../load_a.log

echo "[2/8] run_a..."
./bin/ycsb run  redis -s -P workloads/workloada -p "redis.host=localhost" > ../run_a.log

# 4线程，workloada
echo "[3/8] load_a_4t..."
./bin/ycsb load redis -s -P workloads/workloada -p "redis.host=localhost" -threads 4 > ../load_a_4t.log

echo "[4/8] run_a_4t..."
./bin/ycsb run  redis -s -P workloads/workloada -p "redis.host=localhost" -threads 4 > ../run_a_4t.log

# 默认线程，workloadc（纯读）
echo "[5/8] load_c..."
./bin/ycsb load redis -s -P workloads/workloadc -p "redis.host=localhost" > ../load_c.log

echo "[6/8] run_c..."
./bin/ycsb run  redis -s -P workloads/workloadc -p "redis.host=localhost" > ../run_c.log

# 4线程，workloadc
echo "[7/8] load_c_4t..."
./bin/ycsb load redis -s -P workloads/workloadc -p "redis.host=localhost" -threads 4 > ../load_c_4t.log

echo "[8/8] run_c_4t..."
./bin/ycsb run  redis -s -P workloads/workloadc -p "redis.host=localhost" -threads 4 > ../run_c_4t.log

echo "测试完成"

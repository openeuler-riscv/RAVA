#!/bin/bash
# stress-ng 自动化测试脚本

TEST_DATE=$(date +%Y-%m-%d)
RESULT_DIR="test_results/$TEST_DATE"
MONITOR_DIR="$RESULT_DIR/system_monitor"

echo "stress-ng 测试开始 [$(date '+%H:%M:%S')]"

# 准备环境
sync; echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null 2>&1
mkdir -p "$MONITOR_DIR"

# 简化的测试函数
run_test() {
    local test_name=$1
    local test_cmd=$2
    local log_file="$RESULT_DIR/${test_name}_test.log"
    
    echo "执行 $test_name 测试..."
    
    # 启动监控
    sar -u 1 > "$MONITOR_DIR/${test_name}_cpu.log" &
    local cpu_pid=$!
    sar -r 1 > "$MONITOR_DIR/${test_name}_mem.log" &
    local mem_pid=$!
    iostat -dx 1 > "$MONITOR_DIR/${test_name}_io.log" &
    local io_pid=$!
    
    # 执行测试
    echo "开始时间: $(date '+%H:%M:%S')"
    eval "$test_cmd" 2>&1 | tee "$log_file"
    local test_result=$?
    echo "结束时间: $(date '+%H:%M:%S')"

    sleep 1 
    
    # 停止监控
    kill $cpu_pid $mem_pid $io_pid 2>/dev/null
    wait $cpu_pid $mem_pid $io_pid 2>/dev/null
    echo "✓ 系统监控已停止"
    
    # 检查测试结果
    if [ $test_result -eq 0 ] && grep -q "successful run completed" "$log_file"; then
        echo "✓ $test_name 测试完成"
        return 0
    else
        echo "✗ $test_name 测试失败"
        return 1
    fi
}

# 执行测试用例
echo "=== 2. 执行测试用例 ==="

# CPU 压力测试
run_test "cpu" "stress-ng --cpu 4 --cpu-method matrixprod --timeout 60s --metrics"
sleep 5

# 内存带宽测试
run_test "memory" "stress-ng --vm 2 --vm-bytes 2G --vm-method all --timeout 60s --metrics"
sleep 5

# 磁盘 I/O 测试
run_test "disk" "stress-ng --hdd 1 --hdd-bytes 5G --timeout 60s --metrics --hdd-opts sync"
sleep 5

# 混合测试
run_test "mixed" "stress-ng --cpu 2 --vm 1 --vm-bytes 1G --vm-method all --hdd 1 --hdd-bytes 2G --timeout 60s --metrics"

echo ""
echo "=== 3. 生成测试报告 ==="

# 调用指标提取脚本
./extract_metrics.sh "$RESULT_DIR"



echo ""
echo "========== 测试完成 =========="
echo "所有结果保存在: $RESULT_DIR"
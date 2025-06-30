#!/bin/bash
# 文件名: extract_metrics.sh
# 性能指标提取和分析脚本

RESULT_DIR=${1:-"test_results/$(date +%Y-%m-%d)"}
REPORT_FILE="$RESULT_DIR/performance_report.txt"

> "$REPORT_FILE"

if [ ! -d "$RESULT_DIR" ]; then
    echo "错误: 测试结果目录不存在: $RESULT_DIR"
    exit 1
fi

echo "========== stress-ng 性能测试报告 ==========" > "$REPORT_FILE"
echo "生成时间: $(date '+%Y-%m-%d %H:%M:%S')" >> "$REPORT_FILE"
echo "测试目录: $RESULT_DIR" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 添加系统信息
if [ -f "$RESULT_DIR/system_info.txt" ]; then
    echo "=== 测试环境信息 ===" >> "$REPORT_FILE"
    cat "$RESULT_DIR/system_info.txt" >> "$REPORT_FILE"
    echo "" >> "$REPORT_FILE"
fi

# 函数：检查测试完成状态
check_test_status() {
    echo "=== 测试完成状态 ===" >> "$REPORT_FILE"
    for test in cpu memory disk mixed; do
        LOG_FILE=$(find "$RESULT_DIR" -name "${test}_test.log" 2>/dev/null | head -1)
        if [ -f "$LOG_FILE" ] && grep -q "successful run completed" "$LOG_FILE"; then
            echo "✓ $test 测试完成" >> "$REPORT_FILE"
        else
            echo "✗ $test 测试未完成" >> "$REPORT_FILE"
        fi
    done
    echo "" >> "$REPORT_FILE"
}



# 函数：提取系统监控数据
extract_monitor_metrics() {
    echo "=== 系统监控指标 ===" >> "$REPORT_FILE"
    
    for test in cpu memory disk mixed; do
        MONITOR_DIR="$RESULT_DIR/system_monitor"
        
        if [ -f "$MONITOR_DIR/${test}_cpu.log" ]; then
            echo "--- $test 测试监控数据 ---" >> "$REPORT_FILE"
            
            # CPU 使用率
            CPU_AVG=$(awk 'NR>3 && /^[0-9]/ {total+=100-$8; count++} END {if(count>0) printf "%.2f", total/count}' "$MONITOR_DIR/${test}_cpu.log")
            CPU_MAX=$(awk 'NR>3 && /^[0-9]/ {cpu_usage=100-$8; if(cpu_usage>max) max=cpu_usage} END {printf "%.2f", max}' "$MONITOR_DIR/${test}_cpu.log")
            echo "  CPU使用率: 平均 ${CPU_AVG}%, 峰值 ${CPU_MAX}%" >> "$REPORT_FILE"
            
            # 内存使用率
            if [ -f "$MONITOR_DIR/${test}_mem.log" ]; then
                MEM_AVG=$(awk 'NR>3 && /^[0-9]/ {total+=$5; count++} END {if(count>0) printf "%.2f", total/count}' "$MONITOR_DIR/${test}_mem.log")
                MEM_MAX=$(awk 'NR>3 && /^[0-9]/ {if($5>max) max=$5} END {printf "%.2f", max}' "$MONITOR_DIR/${test}_mem.log")
                echo "  内存使用率: 平均 ${MEM_AVG}%, 峰值 ${MEM_MAX}%" >> "$REPORT_FILE"
            fi
            
            # 磁盘 I/O
            if [ -f "$MONITOR_DIR/${test}_io.log" ]; then
                IO_STATS=$(LC_ALL=C awk '
                /^Device/ {next} # 跳过 Device 头
                /^$/ {next}      # 跳过空行
                /^vda/ { # 只处理以 "vda" 开头的行
                    read_total+=$3; # rkB/s
                    write_total+=$9; # wkB/s
                    count++;
                    if($3 > max_read) max_read = $3;
                    if($9 > max_write) max_write = $9;
                }
                END {
                    if(count>0) {
                        printf "平均 读取%.2fMB/s, 写入%.2fMB/s; 峰值 读取%.2fMB/s, 写入%.2fMB/s", 
                               read_total/count/1024, write_total/count/1024, 
                               max_read/1024, max_write/1024
                    } else {
                        printf "无有效I/O数据 (未处理任何vda数据行)" # 更明确的提示
                    }
                }' "$MONITOR_DIR/${test}_io.log")
                echo "  磁盘I/O: $IO_STATS" >> "$REPORT_FILE"
            fi
            echo "" >> "$REPORT_FILE"
        fi
    done
}



# 函数：提取 stress-ng 性能数据
extract_stress_metrics() {
    echo "=== stress-ng 性能指标 ===" >> "$REPORT_FILE"
    
    for test in cpu memory disk mixed; do
        LOG_FILE=$(find "$RESULT_DIR" -name "${test}_test*.log" 2>/dev/null | head -1)
        if [ -f "$LOG_FILE" ]; then
            echo "--- $test 测试性能 ---" >> "$REPORT_FILE"
            
            # 提取 bogo ops 数据
            grep "metrc:.*bogo ops" "$LOG_FILE" | grep -v "stressor.*bogo ops" | while read line; do
                echo "  $line" >> "$REPORT_FILE"
            done
            
            # 特别提取磁盘和内存的带宽数据
            if [ "$test" = "disk" ] || [ "$test" = "mixed" ]; then
                grep -i "MB/sec.*rate" "$LOG_FILE" | while read line; do
                    echo "  $line" >> "$REPORT_FILE"
                done
            fi
            
            echo "" >> "$REPORT_FILE"
        fi
    done
}



# 执行所有分析
check_test_status
extract_stress_metrics
extract_monitor_metrics

echo "============================================" >> "$REPORT_FILE"

# 显示报告内容
cat "$REPORT_FILE"

echo ""
echo "性能报告已保存到: $REPORT_FILE"
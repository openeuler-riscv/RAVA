#!/bin/bash

# 输出文件名
TS=$(date +%Y%m%d_%H%M%S)
LOG_FILE="openssl_test_${TS}.txt"

# 算法分类
CIPHERS=("aes-128-cbc" "aes-192-cbc" "aes-256-cbc" "aes-128-gcm" "aes-256-gcm" "des-ede3" "rc4" "chacha20" "sm4")
DIGESTS=("md5" "sha1" "sha256" "sha512" "blake2b512" "sm3")
PUBLICS=("rsa1024" "rsa2048" "rsa4096" "dsa1024" "ecdsap256" "ecdsap384" "eddsa")
RAND=("rand") # 随机数生成
BLOCK_SIZES=(16 1024 16384) # 测试不同数据块大小
THREADS=$(nproc) # 获取 CPU 核心数用于多线程测试

# 检查 OpenSSL 是否可用
if ! command -v openssl &> /dev/null; then
  echo "错误：未找到 OpenSSL 命令"
  exit 1
fi

# 将所有输出重定向到日志文件
exec > "$LOG_FILE" 2>&1

# 写入系统信息
echo "==========================================="
echo "OpenSSL Performance Test"
echo "==========================================="
echo "Date: $(date)"
echo "System: $(uname -a)"
echo "OpenSSL Version: $(openssl version)"
echo "CPU Cores: $THREADS"
echo "Hardware Acceleration: $(openssl engine 2>/dev/null | grep -i 'available' || echo 'Not supported')"
echo ""
echo "测试算法列表:"
echo "Ciphers: ${CIPHERS[*]}"
echo "Digests: ${DIGESTS[*]}"
echo "Public Keys: ${PUBLICS[*]}"
echo "Block Sizes: ${BLOCK_SIZES[*]}"
echo ""

# 测试函数：支持单线程、多线程和硬件加速
run_speed_test() {
  local category="$1"
  local algo="$2"
  local extra_args="$3"
  local accel="$4"
  local threads="${5:-1}"

  echo "==========================================="
  echo "Testing $category: $algo (Threads: $threads, Accel: $accel)"
  echo "Command: openssl speed $extra_args $algo"
  echo "-------------------------------------------"
  
  # 使用 timeout 防止某些测试卡住，并捕获所有错误
  if timeout 60s openssl speed $extra_args "$algo" 2>&1; then
    echo "✅ Test completed successfully"
  else
    local exit_code=$?
    if [ $exit_code -eq 124 ]; then
      echo "⚠️  Test timed out (60 seconds)"
    else
      echo "❌ Test failed or unsupported (exit code: $exit_code)"
    fi
  fi
  echo ""
}

# 测试对称加密算法
echo "########################################### "
echo "测试对称加密算法 (${#CIPHERS[@]} 个算法)"
echo "###########################################"
echo ""

for algo in "${CIPHERS[@]}"; do
  echo "--- 开始测试算法: $algo ---"
  
  # 单线程
  run_speed_test "Cipher" "$algo" "" "none" "1"
  
  # 多线程
  run_speed_test "Cipher" "$algo" "-multi $THREADS" "none" "$THREADS"
  
  # 硬件加速 (使用 EVP 接口)
  run_speed_test "Cipher" "$algo" "-evp" "evp" "1"
  
  # 不同块大小
  for size in "${BLOCK_SIZES[@]}"; do
    run_speed_test "Cipher" "$algo" "-bytes $size" "none" "1"
  done
  
  echo "--- 完成算法: $algo ---"
  echo ""
done

# 测试哈希算法
echo "########################################### "
echo "测试哈希算法 (${#DIGESTS[@]} 个算法)"
echo "###########################################"
echo ""

for algo in "${DIGESTS[@]}"; do
  echo "--- 开始测试算法: $algo ---"
  
  # 单线程
  run_speed_test "Digest" "$algo" "" "none" "1"
  
  # 多线程
  run_speed_test "Digest" "$algo" "-multi $THREADS" "none" "$THREADS"
  
  # 不同块大小
  for size in "${BLOCK_SIZES[@]}"; do
    run_speed_test "Digest" "$algo" "-bytes $size" "none" "1"
  done
  
  echo "--- 完成算法: $algo ---"
  echo ""
done

# 测试非对称算法
echo "########################################### "
echo "测试非对称算法 (${#PUBLICS[@]} 个算法)"
echo "###########################################"
echo ""

for algo in "${PUBLICS[@]}"; do
  echo "--- 开始测试算法: $algo ---"
  
  # 单线程
  run_speed_test "PublicKey" "$algo" "" "none" "1"
  
  # 多线程
  run_speed_test "PublicKey" "$algo" "-multi $THREADS" "none" "$THREADS"
  
  echo "--- 完成算法: $algo ---"
  echo ""
done

# 测试随机数生成
echo "########################################### "
echo "测试随机数生成"
echo "###########################################"
echo ""

for algo in "${RAND[@]}"; do
  echo "--- 开始测试: $algo ---"
  
  # 基础随机数测试
  run_speed_test "Random" "$algo" "" "none" "1"
  
  # 多线程随机数测试
  run_speed_test "Random" "$algo" "-multi $THREADS" "none" "$THREADS"
  
  # 不同输出大小
  for size in "${BLOCK_SIZES[@]}"; do
    run_speed_test "Random" "$algo" "-rand $size" "none" "1"
  done
  
  echo "--- 完成测试: $algo ---"
  echo ""
done

# 综合测试
echo "########################################### "
echo "综合性能测试"
echo "###########################################"
echo ""

echo "==========================================="
echo "运行默认 openssl speed 测试"
echo "-------------------------------------------"
timeout 120s openssl speed 2>&1 || echo "默认测试完成或超时"
echo ""

echo "==========================================="
echo "运行多线程综合测试"
echo "-------------------------------------------"
timeout 120s openssl speed -multi $THREADS 2>&1 || echo "多线程测试完成或超时"
echo ""

# 完成信息
echo "########################################### "
echo "测试完成总结"
echo "###########################################"
echo "完成时间: $(date)"
echo "测试的算法类别:"
echo "  - 对称加密算法: ${#CIPHERS[@]} 个"
echo "  - 哈希算法: ${#DIGESTS[@]} 个" 
echo "  - 非对称算法: ${#PUBLICS[@]} 个"
echo "  - 随机数测试: ${#RAND[@]} 个"
echo "总测试数量: $((${#CIPHERS[@]} * 6 + ${#DIGESTS[@]} * 5 + ${#PUBLICS[@]} * 2 + ${#RAND[@]} * 5 + 2))"
echo "所有结果已保存到此文件"
echo "########################################### "

# 恢复输出到终端显示完成信息
exec > /dev/tty 2>&1
echo "✅ OpenSSL 性能测试完成！"
echo "   结果文件: $LOG_FILE"
echo "   文件大小: $(du -h "$LOG_FILE" 2>/dev/null | cut -f1 || echo "未知")"
echo "   总测试数: $((${#CIPHERS[@]} * 6 + ${#DIGESTS[@]} * 5 + ${#PUBLICS[@]} * 2 + ${#RAND[@]} * 5 + 2))"

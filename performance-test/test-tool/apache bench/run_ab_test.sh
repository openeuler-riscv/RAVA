#!/bin/bash

TARGET="http://192.168.0.100/api/test"
POST_DATA="ab_post_data.json"
HEADERS_FILE="ab_headers.txt"
OUTPUT="ab_output.txt"

# GET 测试
echo "[*] Running GET test..." > "$OUTPUT"
ab -n 100 -c 10 "$TARGET" >> "$OUTPUT" 2>&1

# 逐个 header 添加参数（ab 不支持直接指定 header 文件）
echo "[*] Running POST test with headers..." >> "$OUTPUT"
ab -n 100 -c 10 -p "$POST_DATA" -T application/json \
  -H "X-Custom-Header: ab-test" \
  -H "User-Agent: ab-benchmark" \
  "$TARGET" >> "$OUTPUT" 2>&1

echo "[*] ab test complete. Output saved to $OUTPUT"


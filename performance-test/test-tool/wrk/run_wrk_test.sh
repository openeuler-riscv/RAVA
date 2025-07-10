#!/bin/bash

TARGET="http://192.168.0.100"
SCRIPT="wrk_get_post.lua"
OUTPUT="wrk_output.txt"

echo "[*] Starting wrk test on $TARGET ..."
wrk -t8 -c20 -d15s --latency -s "$SCRIPT" "$TARGET" > "$OUTPUT" 2>&1

echo "[*] Test complete. Output saved to $OUTPUT"


#!/bin/bash

# 输出文件名
TS=$(date +%Y%m%d_%H%M%S)
LOG_FILE="openssl_run_${TS}.log"

# 将所有输出重定向到日志文件
exec > "$LOG_FILE" 2>&1

echo "==========================================="
echo "OpenSSL 功能测试开始"
echo "==========================================="
echo "开始时间: $(date)"
echo "系统信息: $(uname -a)"
echo "OpenSSL 版本: $(openssl version 2>/dev/null || echo '未安装或不可用')"
echo ""

# 移除 set -e，改为手动处理错误
mkdir -p openssl_test
cd openssl_test

echo "[*] 创建测试文件"
echo "hello openssl" > plain.txt
echo "测试文件内容: $(cat plain.txt)"
echo ""

######################################
# 对称加密/解密（AES）
######################################
echo "==========================================="
echo "对称加密/解密（AES）测试"
echo "==========================================="
echo "[*] 对称加密 (AES-256-CBC)"
if openssl enc -aes-256-cbc -pbkdf2 -salt -in plain.txt -out encrypted_aes.bin -k secret123 2>&1; then
    echo "✅ AES 加密成功"
    ls -la encrypted_aes.bin
else
    echo "❌ AES 加密失败，尝试其他参数"
    # 尝试不使用 pbkdf2
    if openssl enc -aes-256-cbc -salt -in plain.txt -out encrypted_aes.bin -k secret123 2>&1; then
        echo "✅ AES 加密成功（不使用 pbkdf2）"
    else
        echo "❌ AES 加密完全失败"
    fi
fi

echo "[*] 对称解密"
if [ -f encrypted_aes.bin ]; then
    if openssl enc -d -aes-256-cbc -pbkdf2 -in encrypted_aes.bin -out decrypted_aes.txt -k secret123 2>&1; then
        echo "✅ AES 解密成功"
        echo "解密结果: $(cat decrypted_aes.txt)"
    else
        echo "尝试不使用 pbkdf2 解密"
        if openssl enc -d -aes-256-cbc -in encrypted_aes.bin -out decrypted_aes.txt -k secret123 2>&1; then
            echo "✅ AES 解密成功（不使用 pbkdf2）"
            echo "解密结果: $(cat decrypted_aes.txt)"
        else
            echo "❌ AES 解密失败"
        fi
    fi
else
    echo "❌ 加密文件不存在，跳过解密"
fi
echo ""

######################################
# 哈希摘要（MD5, SHA1, SHA256）
######################################
echo "==========================================="
echo "哈希摘要测试"
echo "==========================================="
echo "[*] 生成哈希"
if openssl dgst -md5 plain.txt > hash_md5.txt 2>&1; then
    echo "✅ MD5 哈希: $(cat hash_md5.txt)"
else
    echo "❌ MD5 哈希失败"
fi

if openssl dgst -sha1 plain.txt > hash_sha1.txt 2>&1; then
    echo "✅ SHA1 哈希: $(cat hash_sha1.txt)"
else
    echo "❌ SHA1 哈希失败"
fi

if openssl dgst -sha256 plain.txt > hash_sha256.txt 2>&1; then
    echo "✅ SHA256 哈希: $(cat hash_sha256.txt)"
else
    echo "❌ SHA256 哈希失败"
fi
echo ""

######################################
# RSA 密钥生成与公钥提取
######################################
echo "==========================================="
echo "RSA 密钥生成测试"
echo "==========================================="
echo "[*] 生成 RSA 私钥 (2048 位)"
if openssl genpkey -algorithm RSA -out rsa_private.pem -pkeyopt rsa_keygen_bits:2048 2>&1; then
    echo "✅ RSA 私钥生成成功"
    ls -la rsa_private.pem
else
    echo "❌ RSA 私钥生成失败，尝试传统方法"
    if openssl genrsa -out rsa_private.pem 2048 2>&1; then
        echo "✅ RSA 私钥生成成功（传统方法）"
    else
        echo "❌ RSA 私钥生成完全失败"
    fi
fi

echo "[*] 提取 RSA 公钥"
if [ -f rsa_private.pem ]; then
    if openssl rsa -in rsa_private.pem -pubout -out rsa_public.pem 2>&1; then
        echo "✅ RSA 公钥提取成功"
        ls -la rsa_public.pem
    else
        echo "❌ RSA 公钥提取失败"
    fi
else
    echo "❌ 私钥文件不存在，跳过公钥提取"
fi
echo ""

######################################
# 非对称加密/解密（RSA）
######################################
echo "==========================================="
echo "RSA 非对称加密测试"
echo "==========================================="
if [ -f rsa_public.pem ] && [ -f rsa_private.pem ]; then
    echo "[*] 非对称加密（使用公钥）"
    echo "secret message" > secret.txt
    echo "原始消息: $(cat secret.txt)"
    
    if openssl rsautl -encrypt -inkey rsa_public.pem -pubin -in secret.txt -out secret_encrypted.bin 2>&1; then
        echo "✅ RSA 加密成功"
        ls -la secret_encrypted.bin
    else
        echo "❌ RSA 加密失败，尝试 pkeyutl"
        if openssl pkeyutl -encrypt -inkey rsa_public.pem -pubin -in secret.txt -out secret_encrypted.bin 2>&1; then
            echo "✅ RSA 加密成功（pkeyutl）"
        else
            echo "❌ RSA 加密完全失败"
        fi
    fi

    echo "[*] 非对称解密（使用私钥）"
    if [ -f secret_encrypted.bin ]; then
        if openssl rsautl -decrypt -inkey rsa_private.pem -in secret_encrypted.bin -out secret_decrypted.txt 2>&1; then
            echo "✅ RSA 解密成功"
            echo "解密结果: $(cat secret_decrypted.txt)"
        else
            echo "尝试 pkeyutl 解密"
            if openssl pkeyutl -decrypt -inkey rsa_private.pem -in secret_encrypted.bin -out secret_decrypted.txt 2>&1; then
                echo "✅ RSA 解密成功（pkeyutl）"
                echo "解密结果: $(cat secret_decrypted.txt)"
            else
                echo "❌ RSA 解密失败"
            fi
        fi
    else
        echo "❌ 加密文件不存在，跳过解密"
    fi
else
    echo "❌ RSA 密钥文件不存在，跳过非对称加密测试"
fi
echo ""

######################################
# 算法列表
######################################
echo "==========================================="
echo "支持的算法列表"
echo "==========================================="
echo "[*] 导出 OpenSSL 支持的算法列表"

echo "对称加密算法:"
if openssl list -cipher-algorithms > supported_ciphers.txt 2>&1; then
    head -10 supported_ciphers.txt
    echo "... (完整列表保存在 supported_ciphers.txt)"
else
    echo "❌ 无法获取对称加密算法列表"
fi

echo ""
echo "哈希算法:"
if openssl list -digest-algorithms > supported_digests.txt 2>&1; then
    head -10 supported_digests.txt
    echo "... (完整列表保存在 supported_digests.txt)"
else
    echo "❌ 无法获取哈希算法列表"
fi
echo ""

######################################
# 文件总结
######################################
echo "==========================================="
echo "生成的文件列表"
echo "==========================================="
echo "当前目录: $(pwd)"
echo "文件列表:"
ls -la 2>/dev/null || echo "无法列出文件"

echo ""
echo "==========================================="
echo "测试完成"
echo "==========================================="
echo "完成时间: $(date)"
echo "[✔] 测试结果已保存"

# 恢复输出到终端
exec > /dev/tty 2>&1
echo "✅ OpenSSL 测试完成！"
echo "   日志文件: $LOG_FILE"
echo "   测试目录: openssl_test/"
cd ..
if [ -f "$LOG_FILE" ]; then
    echo "   日志大小: $(du -h "$LOG_FILE" | cut -f1)"
    echo "   预览最后几行:"
    tail -5 "$LOG_FILE"
else
    echo "   ⚠️  日志文件未找到"
fi

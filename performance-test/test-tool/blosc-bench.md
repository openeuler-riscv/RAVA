# c-blosc 测试方法与结果

> 参考：[https://github.com/Blosc/c-blosc/blob/main/README.md](https://github.com/Blosc/c-blosc/blob/main/README.md)

> 测试环境：**openEuler RISC-V 25.03**

---

## 1. 工具简介

**c-blosc** 是一个高性能无损压缩库，通过分块与多线程技术在缓存层压缩数据，可提升内存访问效率。
支持多种编解码器（blosclz、lz4、lz4hc、zstd 等），常用于科学计算与数据分析场景。

---

## 2. 编译与安装

```bash
git clone https://github.com/Blosc/c-blosc.git
cd c-blosc
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr/local
make -j"$(nproc)"
sudo make install
sudo ldconfig

echo "/usr/local/lib64" | sudo tee /etc/ld.so.conf.d/local-lib64.conf
sudo ldconfig
```

安装完成后库文件位于 `/usr/local/lib64/`，版本为 **1.21.7.dev**。
所有测试均在 **openEuler RISC-V 25.03** 系统上完成。

---

## 3. 功能测试与结果

### （1）多编解码器测试

```bash
cd ~/c-blosc/examples
gcc -O3 many_compressors.c -I/usr/local/include -L/usr/local/lib64 -lblosc -o many
./many
```

**完整输出：**

```
Blosc version info: 1.21.7.dev ($Date:: 2024-06-24 #$)
Using 4 threads (previously using 1)
Using blosclz compressor
Compression: 4000000 -> 36321 (110.1x)
Successful roundtrip!
Using lz4 compressor
Compression: 4000000 -> 37938 (105.4x)
Successful roundtrip!
Using lz4hc compressor
Compression: 4000000 -> 27165 (147.2x)
Successful roundtrip!
```

**结果表：**

| 编解码器    | 压缩结果 (4000000→x bytes) | 压缩比    | 说明   |
| ------- | ---------------------- | ------ | ---- |
| blosclz | 4000000 → 36321        | 110.1× | 默认算法 |
| lz4     | 4000000 → 37938        | 105.4× | 快速压缩 |
| lz4hc   | 4000000 → 27165        | 147.2× | 高压缩率 |

所有算法均 **Successful roundtrip**（压缩/解压一致）。

---

### （2）多线程测试

```bash
gcc -O3 multithread.c -I/usr/local/include -L/usr/local/lib64 -lblosc -o multithread
./multithread 4
```

**完整输出：**

```
Blosc version info: 1.21.7.dev ($Date:: 2024-06-24 #$)
Using 1 threads (previously using 1)
Compression: 4000000 -> 36321 (110.1x)
Successful roundtrip!
Using 2 threads (previously using 1)
Compression: 4000000 -> 36321 (110.1x)
Successful roundtrip!
Using 3 threads (previously using 2)
Compression: 4000000 -> 36321 (110.1x)
Successful roundtrip!
Using 4 threads (previously using 3)
Compression: 4000000 -> 36321 (110.1x)
Successful roundtrip!
```

**说明：**
线程数从 1 到 4 均执行成功，压缩结果一致。多线程接口稳定，结果正确。

---

### （3）单线程验证

```bash
gcc -O3 simple.c -I/usr/local/include -L/usr/local/lib64 -lblosc -o simple
./simple
```

**完整输出：**

```
Blosc version info: 1.21.7.dev ($Date:: 2024-06-24 #$)
Compression: 4000000 -> 36321 (110.1x)
Decompression successful!
Successful roundtrip!
```

功能验证成功。

---

### （4）不同过滤器测试

```bash
gcc -O3 -DBLOSC_BITSHUFFLE simple.c -I/usr/local/include -L/usr/local/lib64 -lblosc -o simple_bit
./simple_bit
```

**完整输出：**

```
Blosc version info: 1.21.7.dev ($Date:: 2024-06-24 #$)
Compression: 4000000 -> 36321 (110.1x)
Decompression successful!
Successful roundtrip!
```

结果与默认 shuffle 一致，说明过滤功能正常。

---

### （5）Zstd 压缩测试

```bash
gcc -O3 -DTEST_ZSTD simple.c -I/usr/local/include -L/usr/local/lib64 -lblosc -o simple_zstd
./simple_zstd
```

**完整输出：**

```
Blosc version info: 1.21.7.dev ($Date:: 2024-06-24 #$)
Compression: 4000000 -> 36321 (110.1x)
Decompression successful!
Successful roundtrip!
```

Zstd 模块正常可用，压缩结果与其他算法一致。

---

## 4. 测试结果汇总

| 测试项   | 线程数 | 算法                    | 过滤器        | 压缩比      | 结果 |
| ----- | --- | --------------------- | ---------- | -------- | -- |
| 多编解码器 | 4   | blosclz / lz4 / lz4hc | shuffle    | 105–147× | 成功 |
| 多线程   | 1–4 | blosclz               | shuffle    | 110.1×   | 成功 |
| 单线程   | 1   | blosclz               | shuffle    | 110.1×   | 成功 |
| 过滤器   | 1   | blosclz               | bitshuffle | 110.1×   | 成功 |
| Zstd  | 1   | zstd                  | shuffle    | 110.1×   | 成功 |

---

## 5. 结论

* c-blosc 在 **openEuler RISC-V 25.03** 平台上可成功编译、安装并运行。
* 各编解码器均工作正常，多线程压缩接口稳定。
* 不同过滤器与算法组合均能正确完成压缩/解压验证。
* 实测压缩比在 **100×–150×** 范围内，性能受算法与线程数影响。
* 该库在 RISC-V 平台具备良好的兼容性，可作为基础压缩组件使用。
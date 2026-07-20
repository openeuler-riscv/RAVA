# toolchain-smoke 测试方法与结果

> 测试环境：**openEuler RISC-V**

> 测试类型：**工具链基础兼容性冒烟测试**

---

## 1. 工具简介

**toolchain-smoke** 是一个面向 openEuler RISC-V 环境的轻量级工具链兼容性测试套，用于快速验证系统中基础 C/C++ 构建工具链是否可用。

该测试套覆盖 `gcc`、`g++`、`make`、`readelf`、`objdump` 等基础工具，验证系统能否完成 C/C++ 程序的编译、链接、运行，并检查生成的 ELF 文件是否符合 RISC-V 64 位目标架构预期。

该测试属于 smoke 级别测试，目标是快速发现基础环境问题，不替代完整 GCC/binutils testsuite 或 DejaGNU 等重型工具链回归测试。

---

## 2. 测试目的

验证 openEuler RISC-V 环境是否具备基础本地构建能力，主要包括：

* `gcc`、`g++`、`make`、`readelf`、`objdump` 命令是否可用；
* `gcc` 是否能编译并运行 C 程序；
* `g++` 是否能编译并运行 C++ 程序；
* `make` 是否能驱动 C/C++ 构建流程；
* `readelf` 是否能识别生成程序的 ELF64 类型和 RISC-V machine 信息；
* `objdump` 是否能读取生成的 ELF 产物。

如果该测试失败，通常说明 rootfs 中的基础工具链、开发包、运行库或 binutils 存在配置缺失或兼容性问题。

---

## 3. 测试内容

### （1）依赖安装

测试开始时会安装基础工具链依赖：

```bash
yum install -y gcc gcc-c++ make binutils glibc-devel
```

安装依赖属于测试准备步骤，不作为独立 LAVA result case 上报。

### （2）工具版本检查

测试会检查以下工具是否存在，并输出版本首行到 LAVA job log：

```text
gcc
g++
make
readelf
objdump
```

### （3）C 程序编译与运行

测试源码文件为 `hello.c`：

```c
#include <stdio.h>

int main(void)
{
    puts("Hello from C");
    return 0;
}
```

执行编译：

```bash
gcc -Wall -Wextra -o output/build/hello_c hello.c
```

运行后预期输出：

```text
Hello from C
```

### （4）C++ 程序编译与运行

测试源码文件为 `hello.cpp`：

```cpp
#include <iostream>

int main()
{
    std::cout << "Hello from C++" << std::endl;
    return 0;
}
```

执行编译：

```bash
g++ -Wall -Wextra -o output/build/hello_cpp hello.cpp
```

运行后预期输出：

```text
Hello from C++
```

### （5）Makefile 构建验证

测试通过 `Makefile` 再执行一次 C/C++ 构建：

```bash
make CC=gcc CXX=g++ BUILD_DIR=output/build/make
```

其中 Makefile 会生成：

```text
output/build/make/hello_c_make
output/build/make/hello_cpp_make
```

测试会运行 `hello_cpp_make`，预期输出：

```text
Hello from C++
```

### （6）ELF 产物检查

使用 `readelf` 检查 C 程序的 ELF header：

```bash
readelf -h output/build/hello_c
```

重点检查：

```text
Class:   ELF64
Machine: RISC-V
```

使用 `objdump` 检查 ELF 文件是否可被 binutils 正常读取：

```bash
objdump -f output/build/hello_c
```

---

## 4. LAVA 执行方式

测试定义文件位于：

```text
lava-testcases/compatibility-test/toolchain-smoke/toolchain-smoke.yaml
```

LAVA job 中的 test block 可配置为：

```yaml
- test:
    timeout:
      minutes: 20
    definitions:
    - repository: https://gitee.com/zhtianyu/lava-repo_1.git
      from: git
      name: toolchain-smoke
      path: lava-testcases/compatibility-test/toolchain-smoke/toolchain-smoke.yaml
```

`toolchain-smoke.yaml` 会执行：

```bash
cd lava-testcases/compatibility-test/toolchain-smoke/
chmod +x toolchain-smoke.sh
./toolchain-smoke.sh
chmod +x ../../utils/send-to-lava.sh
../../utils/send-to-lava.sh ./output/result.txt
```

---

## 5. 测试结果示例

LAVA job log 中会输出工具版本、程序运行结果、`readelf` 和 `objdump` 信息。例如：

```text
gcc (GCC) 12.3.1
g++ (GCC) 12.3.1
GNU Make 4.4
GNU readelf (GNU Binutils) 2.40
GNU objdump (GNU Binutils) 2.40
Hello from C
Hello from C++
Hello from C++
ELF Header:
  Class:                             ELF64
  Machine:                           RISC-V
```

生成的 LAVA result 示例：

```text
toolchain-gcc-version pass
toolchain-gxx-version pass
toolchain-make-version pass
toolchain-readelf-version pass
toolchain-objdump-version pass
toolchain-gcc-build-c pass
toolchain-run-c pass
toolchain-gxx-build-cpp pass
toolchain-run-cpp pass
toolchain-make-build pass
toolchain-run-make pass
toolchain-elf-class-64 pass
toolchain-elf-machine pass
toolchain-objdump-readable pass
```

---

## 6. 测试结果汇总

| 测试项 | 验证内容 | 通过条件 |
| ------ | -------- | -------- |
| toolchain-gcc-version | `gcc` 命令可用 | 能找到 `gcc` 并输出版本 |
| toolchain-gxx-version | `g++` 命令可用 | 能找到 `g++` 并输出版本 |
| toolchain-make-version | `make` 命令可用 | 能找到 `make` 并输出版本 |
| toolchain-readelf-version | `readelf` 命令可用 | 能找到 `readelf` 并输出版本 |
| toolchain-objdump-version | `objdump` 命令可用 | 能找到 `objdump` 并输出版本 |
| toolchain-gcc-build-c | C 程序编译 | `gcc` 编译 `hello.c` 成功 |
| toolchain-run-c | C 程序运行 | 输出 `Hello from C` |
| toolchain-gxx-build-cpp | C++ 程序编译 | `g++` 编译 `hello.cpp` 成功 |
| toolchain-run-cpp | C++ 程序运行 | 输出 `Hello from C++` |
| toolchain-make-build | Makefile 构建 | `make` 构建成功 |
| toolchain-run-make | Makefile 产物运行 | 输出 `Hello from C++` |
| toolchain-elf-class-64 | ELF 位宽检查 | `readelf` 显示 `ELF64` |
| toolchain-elf-machine | ELF 架构检查 | `readelf` 显示 `RISC-V` |
| toolchain-objdump-readable | binutils 读取检查 | `objdump -f` 执行成功 |

---

## 7. 结论

* `toolchain-smoke` 可用于 openEuler RISC-V rootfs 的基础工具链兼容性冒烟测试。
* 该测试能快速验证 `gcc`、`g++`、`make`、`readelf`、`objdump` 是否可用，以及 C/C++ 编译、链接、运行链路是否正常。
* `readelf` 和 `objdump` 检查可确认生成的 ELF 产物为 RISC-V 64 位目标文件，并可被 binutils 正常解析。
* 该测试执行时间短、依赖明确、失败定位直接，适合作为更完整工具链兼容性测试前的基础检查项。
* 若需要进一步覆盖 C/C++ 标准、libstdc++ ABI、binutils 子工具或 GCC/binutils testsuite，应单独设计更重的专项测试套。

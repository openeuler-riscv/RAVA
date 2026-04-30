riscv-arch-test 项目地址: https://github.com/riscv-non-isa/riscv-arch-test

riscv-arch-test (简称 ACT) 是一个指令集兼容性验证工具，主要用于在处理器设计初期或移植过程中，通过编写测试集来验证设计是否正确实现了 RISC-V 规范

ACT 分为 ACT3 和 ACT4 两个版本，建议使用 ACT4，更容易跑起来

| 版本 | 分支 | 依赖                      | 测试用例        | 状态         |
|------|------|---------------------------|-----------------|--------------|
| act3 | dev  | 依赖关系较复杂，互相有冲突 | 借用 riscof     | 当前版本     |
| act4 | act4 | 清晰，仅依赖 udb           | 由 act 本身实现 | 活跃开发分支 |

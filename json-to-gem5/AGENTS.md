# AGENTS.md - Verilog 转 gem5 代码生成项目

本文件是为 AI 代理（也就是你），提供的工作指南。

## 项目概述

将 自然语言描述的硬件功能文件转换为 gem5 模拟器兼容代码(在这里只是简单概括，流程在documents/workflow.md中有具体展开，请严格执行)：
- **Sconscript 文件**：src下的Sconscript会遍历每一级目录查找该sconscript文件用于scons构建
- **Python 文件**：gem5 配置脚本
- **.cc 文件**：C++ 实现
- **.hh 文件**：C++ 头文件


注意：从始至终都要多多阅读documents的文档，你的工作流程也在该文件夹中

## 构建/测试命令

### 语法检查

#### C++ 代码格式化 (clang-format)
```bash
cd gem5
clang-format -i gem5/src/generators/xxx/xxx.cc gem5/src/generators/xxx/xxx.hh
# 或使用 git-clang-format (检查改动)
util/run-git-clang-format.py --diff
```

#### Python 代码格式化
```bash
# black 格式化
black gem5/src/generators/xxx/xxx.py

# isort 排序 import
isort gem5/src/generators/xxx/xxx.py
```

#### pre-commit 检查
```bash
pre-commit run --all-files
```

### 构建 gem5(不允许子agent使用！！建议并行线程数为10,不可以清除缓存，因为重新构建时间会很久，默认就是增量构建）
```bash
cd gem5
scons build/X86/gem5.opt  -j10
```
---

## 代码风格指南

### 项目结构

```
当前目录/
├── input/           
│   ├── verilog1
│   │   ├── verilog1.txt
│   │   └── ...
│   └── ...       
├── config/           #配置文件 
├── gem5/                 #gem5项目
│   └── ...
└── documents/          # 最重要，工作时尽可能多阅读，存放了提供给你的流程、语法规范等必要信息
    ├── gem5/  
    │   └── ...    #gem5的语法规范
    ├── 模块规格描述文件规范.md 
    ├── description编写规范.md
    ├── workflow.md
    └── ...
```



---

## 全局回复规则（中文习惯）

### 沟通风格
- **简洁直接**：用最少的文字回答问题
- **避免废话**：不添加不必要的开场白或总结
- **专业准确**：使用正确的技术术语

### 回复格式
```好的，我来实现这个功能。```
```完成。```
```需要更多信息：...```

### 代码相关
- 解释你做了什么（简短，1-2句话）
- 直接展示关键代码或结果
- 如果需要用户确认，先问问题

### 任务流程
1. 理解需求后再动手
2. 小步迭代，及时验证
3. 遇到问题先尝试解决，无法解决时询问用户
4. 完成后简单说明
5. 多参考gem5文档与gem5源码
6. 按照/documents/workflow.md流程进行任务，不宜缺漏

### 禁止行为
- 不要添加 emoji（除非用户明确要求）
- 不要说"您好"、"谢谢"等客套话
- 不要在代码中添加解释性注释（除非用户要求）
- 不要主动创建文档文件（README 等）

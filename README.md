# R Beginner Training | 环境健康数据清理与统计分析

**R × Posit Cloud × Claude辅助学习** | 面向零基础本科生/研究生的可实操R训练。

当前版本包含 **M01–M06**；M07–M17属于后续课程计划，尚未编写。以一份**1000人、14变量**的人工模拟成人尿液双酚数据为统一示例（BPA、BPB、BPS、BPF、尿液比重、BMI所需身高体重及其他变量）。

> ⚠️ 仅用于教学，不是真实队列数据。数据中设置了缺失值、相关性和偏态浓度，不能用于真实科研结论。简单中位数/众数填补与LOD/√2只是入门演示，不是推荐的通用主分析方案。

## 最快开始（本地RStudio与Posit Cloud通用）

1. 打开项目 `R_Beginner_Training.Rproj`，让工作目录位于项目根目录。
2. 在Console中检查：`file.exists("data/bisphenols_adults_1000.csv")`，应返回 `TRUE`。
3. 若尚未安装包：`install.packages(c("readr", "dplyr"))`（仅首次需要）；之后每次运行脚本会执行`library()`。
4. 按以下顺序**逐行运行**模块脚本（Windows快捷键：Ctrl + Enter）。
5. M02–M06会在 `data/processed/` 生成输出。每模块均可从头运行，但必须确保依赖的前置输出已生成。

## 教学模块与依赖

| 顺序 | 脚本 | 从哪里读取 | 生成的主要输出 |
|---|---|---|---|
| M01 | [读取数据与认识数据集](M01_读取数据与认识数据集.R) | 原始CSV n1000 | 检查结果（不保存CSV） |
| M02 | [提取分析变量与建立分析数据集](M02_提取分析变量与建立分析数据集.R) | 原始CSV n1000 | `female_datasetn541.csv`（演示子集） |
| M03 | [缺失值检查填补与删除](M03_缺失值的检查填补与删除.R) | 原始CSV n1000 | `imputed_datasetn1000.csv`、`deleted_datasetn801.csv` |
| M04 | [定义变量类型](M04_定义变量类型.R) | M03的`deleted_datasetn801.csv` | `variable_datasetn801.csv` / `.rds` |
| M05 | [新变量计算与重新分组](M05_新变量计算与重新分组.R) | M04的`variable_datasetn801.rds` | `modified_datasetn801.csv` / `.rds` |
| M06 | [数据质量检查](M06_数据质量检查.R) | M05的`modified_datasetn801.rds` | `qc_datasetn801.csv` / `.rds` |

**重要：** M02只做子集教学，M03按原定教学流程从完整1000人原始数据重新开始，**不依赖M02输出**。M03删除BPA、BPB、BPS、BPF、SBP缺失后保留801人。M04–M06依次使用该801人样本。

## 文件结构

```text
R_Beginner_Training/
├── R_Beginner_Training.Rproj
├── README.md
├── M01_读取数据与认识数据集.R
├── M02_提取分析变量与建立分析数据集.R
├── M03_缺失值的检查填补与删除.R
├── M04_定义变量类型.R
├── M05_新变量计算与重新分组.R
├── M06_数据质量检查.R
├── data/
│   ├── bisphenols_adults_1000.csv
│   └── processed/                 # R脚本运行时自动生成结果
├── docs/                          # 教学计划、数据字典、部署说明、Claude使用指南
└── scripts/check_pipeline.R      # 可选：教师端完整流程检查
```

## Posit Cloud在线运行

在 [Posit Cloud](https://posit.cloud/) 选择 **New Project → New Project from Git Repo**，填入本仓库HTTPS链接。项目导入后用在线RStudio运行脚本。详见 [GitHub与Posit Cloud部署指南](docs/GITHUB_POSIT_CLOUD_GUIDE.md)。

**Claude辅助学习**是可选的独立辅助环节，不代表Posit Cloud自动内置Claude；参见 [Claude提问模板](docs/CLAUDE_LEARNING_PROMPTS.md)。

## 教学与项目资料

- [M01–M17课程总体计划](docs/COURSE_ROADMAP.md)
- [数据字典](docs/DATA_DICTIONARY.md)
- [GitHub/Posit Cloud部署与排错](docs/GITHUB_POSIT_CLOUD_GUIDE.md)
- [Claude辅助学习模板](docs/CLAUDE_LEARNING_PROMPTS.md)
- [针对上传原版脚本的修改清单](docs/CHANGES_FROM_ORIGINAL.md)

## 环境及版本管理

当前模块仅依赖CRAN包 `readr` 和 `dplyr`（外加R内置函数）。由于未在此环境中运行R，本仓库未伪造`renv.lock`，也没有锁定R包版本。教师在本地/Posit Cloud核对安装后可以再建立版本锁定文件。

## 上传与使用注意

- **GitHub**托管教学代码与模拟数据；**Posit Cloud**负责在线运行，二者不是同一服务。
- 所有输入统一使用相对路径，不包含本地的`C:/Users/...`。
- 输出CSV命名以`n总人数`结尾；初始原始文件沿用上传文件名的`_1000`结尾。
- M06只标记潜在异常值，不自动删除高暴露者。
- 如要公开共享、授权复用，请在发布前自行决定代码与文档的使用许可；当前未擅自指定开源许可证。

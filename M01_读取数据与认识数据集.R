# ============================================================
# R Beginner Training | M01 读取数据与认识数据集
# 操作方式：在 RStudio 中打开此脚本，逐行运行（Ctrl + Enter）
# 学习重点：Package -> 文件路径 -> 读取 CSV -> 认识数据 -> 初步检查
# ============================================================

# 【第 1 步】准备 Package -----------------------------------------
# Package（程序包）就像给 R 安装额外的工具。
# 第一次使用且尚未安装时，在下方 Console 中运行以下两行：
# install.packages("readr")
# install.packages("dplyr")
# 注意：安装通常只需要一次；每次开启新的 R 会话需要 library() 加载。

library(readr)  # 读取 CSV
library(dplyr)  # 检查和整理数据

help("readr")

# 【第 2 步】确认 Project 和数据位置 -------------------------------
# getwd() 显示目前的工作目录。打开 Project 后通常是项目主目录。
getwd()

# 确认数据文件所在位置；如果文件名/文件夹不同，只修改这一行。
data_path <- "data/bisphenols_adults_1000.csv"


# 检查文件是否存在：TRUE = 找到了；FALSE = 没有找到。
file.exists(data_path)

# 如果得到 FALSE，看看指定文件夹中实际有哪些文件：
list.files("data")

# 【第 3 步】读取 CSV --------------------------------------------
# <- 表示把右边的结果存入左边的对象。
# read_csv() 读取 CSV；导入后命名为 raw_data。
raw_data <- read_csv(data_path)

# 【第 4 步】查看数据规模与变量名称 -------------------------------
# dim() 返回：行数、列数。
dim(raw_data)

# 单独查看参与记录数（行）和变量数（列）。
nrow(raw_data)
ncol(raw_data)

# 查看全部变量名。
names(raw_data)

# 【第 5 步】浏览原始数据 ----------------------------------------
# 在 Console 中显示前 6 行。
head(raw_data)

# 在 Posit / RStudio 中打开表格查看器。
View(raw_data)

# 【第 6 步】认识变量类型 ----------------------------------------
# glimpse() 将变量名称、存储类型和部分值放在一起展示。
glimpse(raw_data)

# 查看单一变量类型：本例有 age_years 和 sex 两列。
class(raw_data$age_years)
class(raw_data$sex)

# 【第 7 步】初步检查参与者 ID ----------------------------------。
# 缺失 ID 数量：
sum(is.na(raw_data$participant_id))

# 列出重复 ID 及其出现次数（返回0行表示未发现重复ID）
raw_data %>%
  count(participant_id) %>%
  filter(n > 1)

# 【第 8 步】检查 CSV 解析问题 ------------------------------------
# 解析问题：比如本应读为数字的某个数据值无法转成数值。
# 0 行通常意味着 readr 没有记录到解析错误；不代表所有值都合理。
problems(raw_data)
nrow(problems(raw_data))

# ======================== M01 结束 =============================
# 1. 为什么 install.packages() 和 library() 不是同一回事？
# 2. CSV 文件是否存在？
# 3. 数据有几行、几列？
# 4. age 和 sex 分别是什么数据类型？
# 5. 有多少缺失 ID、重复 ID？
# 6. readr 报告了多少个解析问题？
# 后续模块 M02 会选择分析变量并建立 analysis_dataset。

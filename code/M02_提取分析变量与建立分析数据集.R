# =============================================================
# R Beginner Training | M02 提取分析变量与建立分析数据集
# 学习重点：选择变量、筛选研究对象、变量重命名、保存
# =============================================================

# 【第 0 步】准备Package和数据。重新启动R会话，这份脚本需从头独立运行。否则直接进入第1步 -------------------------------
# install.packages("readr")
# install.packages("dplyr")
library(readr)
library(dplyr)

# 即使重新启动R会话，这份脚本也可以从头独立运行。
data_path <- "data/bisphenols_adults_1000.csv"
raw_data <- read_csv(data_path)

# 【第 1 步】选择研究需要的变量（select：选列）---------------------
# 研究例题：四种双酚暴露与收缩压是否相关？
# 暂时选择10个变量，建立专门用于血压研究的子数据集。
# %>% 表示：把左侧数据交给右侧函数继续处理。
# 重要：select() 选择列，不会因为某些列存在NA而自动删除参与者
sbp_dataset <- raw_data %>%
  select(participant_id, age_years, sex, smoking_status, sbp_mmhg, bpa_ng_ml, bpb_ng_ml, bps_ng_ml, bpf_ng_ml, urine_sg)

dim(sbp_dataset)    # 预期：1000 行，10 列
names(sbp_dataset)
head(sbp_dataset)

# 【第 2 步】筛选指定研究对象（filter：选行）-------------------------
# 例：只保留女性参与者。
# 请注意：这里不覆盖 sbp_dataset，男女数据仍保留在原对象中。
female_dataset <- sbp_dataset %>%
  filter(sex == "female")

dim(female_dataset)    # 预期：541 行，10 列
head(female_dataset)

# 【第 3 步】重命名变量（rename：新名 = 旧名）----------------------
# 演示重命名。仅为课堂演示，不修改后续课程使用的正式变量名。
female_renamed <- female_dataset %>%
  rename(sbp = sbp_mmhg, sg = urine_sg)

names(female_renamed)  # 现在可以看到 sbp 和 sg
names(female_dataset)  # 原来的变量名保持不变

# 【第 4 步】保存分析数据集 --------------------------------------
# 原始CSV保持不变；处理后的文件写入新的 processed 文件夹。
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)

output_path <- "data/processed/female_datasetn541.csv"
write_csv(female_dataset, output_path, na = "")

file.exists(output_path)  # 预期：TRUE
list.files("data/processed")

# ======================== M02 结束 =============================
# 1. sbp_dataset 有多少行、多少列？
# 2. female_dataset 有多少行、多少列？
# 3. select() 与 filter() 有什么不同？
# 4. rename() 中谁是新名字，谁是旧名字？
# 5. female_dataset 的CSV保存在哪里？
# 后续模块 M03：检查、删除和填补指定变量的缺失值。

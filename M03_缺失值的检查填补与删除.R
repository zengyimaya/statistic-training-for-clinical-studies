# =============================================================
# R Beginner Training | M03 缺失值的检查、填补与删除
# 学习重点：检查NA -> 填补指定NA -> 保存填补CSV -> 删除指定NA -> 保存删除CSV
# =============================================================

# 【第 0 步】准备Package和数据。重新启动R会话，这份脚本需从头独立运行。否则直接进入第1步 -------------------------------
# 从原始1000人数据开始，不使用M02筛选的女性子集。
# install.packages("readr")
# install.packages("dplyr")
library(readr)
library(dplyr)
data_path <- "data/bisphenols_adults_1000.csv"
raw_data <- read_csv(data_path)

# 【第 1 步】检查缺失值数量与比例 -------------------------------
# is.na()：判断是否缺失；sum()：统计TRUE的数量。
sum(is.na(raw_data$age_years))    # 预期：5人
sum(is.na(raw_data$bpa_ng_ml))   # 预期：33人
sum(is.na(raw_data$sbp_mmhg))   # 预期：30人
sum(is.na(raw_data))            # 预期：323个缺失单元格（不是323人）

# 查看每个变量的缺失数量和比例（%）。
colSums(is.na(raw_data))
round(colMeans(is.na(raw_data)) * 100, 1)

# 【第 2 步】查看指定变量缺失的参与者 ---------------------------
# 例：只显示BPA缺失者的ID和BPA，不修改原数据。
raw_data %>%
  filter(is.na(bpa_ng_ml)) %>%
  select(participant_id, bpa_ng_ml)

# 【第 3 步】先填补指定变量的NA --------------------------------
# 设置imputed_dataset
# 例：用非缺失年龄的中位数填补age_years中的NA。教育水平的众数填补education_level中的NA。
# median()求中位数；na.rm = TRUE表示计算时忽略NA。
# if_else(条件, 满足条件时的值, 其他情况的值)。
# 注意：连续变量的简单中位数填补和分类变量的众数填补只用于教学演示，实际研究时需结合具体数据和参考文献选择合适的方法，比如说MICE多重插补。
imputed_dataset <- raw_data
age_median <- median(imputed_dataset$age_years, na.rm = TRUE)
age_median  # 预期：44
imputed_dataset <- imputed_dataset %>%
  mutate(age_years = if_else(is.na(age_years), age_median, age_years))
imputed_dataset <- imputed_dataset %>%
  mutate(urine_sg = if_else(is.na(urine_sg), median(urine_sg, na.rm = TRUE), urine_sg))

sum(is.na(imputed_dataset$age_years))  # 预期：0
sum(is.na(imputed_dataset$urine_sg))  # 预期：0
sum(is.na(imputed_dataset))            # 预期：298（其他变量仍有NA）
nrow(imputed_dataset)                  # 预期：1000人

# 按性别填补中位数
imputed_dataset <- imputed_dataset %>%
  group_by(sex) %>%
  mutate(
    height_cm = if_else(is.na(height_cm), median(height_cm, na.rm = TRUE), height_cm),
    weight_kg = if_else(is.na(weight_kg), median(weight_kg, na.rm = TRUE), weight_kg)
  ) %>%
  ungroup()

sum(is.na(imputed_dataset$height_cm))  # 预期：0
sum(is.na(imputed_dataset$weight_kg))  # 预期：0

# 用各分类变量的众数（出现次数最多的类别）填补其它指定NA
imputed_dataset <- imputed_dataset %>%
  mutate(education_level = if_else(is.na(education_level), names(sort(table(education_level), decreasing = TRUE))[1], education_level),
         smoking_status = if_else(is.na(smoking_status), names(sort(table(smoking_status), decreasing = TRUE))[1], smoking_status),
         physical_activity = if_else(is.na(physical_activity), names(sort(table(physical_activity), decreasing = TRUE))[1], physical_activity)
  )

colSums(is.na(imputed_dataset))

# 【第 4 步】保存填补后的CSV -------------------------------------
# 文件名末尾的n1000表示保存了1000名参与者。
# 本示例固定使用1000人数据；如果替换数据，需按实际nrow()修改文件名。
dir.create("data/processed", recursive = TRUE, showWarnings = FALSE)
output_path <- "data/processed/imputed_datasetn1000.csv"
write_csv(imputed_dataset, output_path, na = "")

# 【第 5 步】删除指定变量缺失的记录 ---------------------------
# 以刚才填补后的imputed_dataset为基础，而不是重新从raw_data开始。
# 例：研究BPs与收缩压，删除BPs或SBP缺失的参与者。
# !is.na()表示“不是缺失”；其他变量即使还有NA，也暂时保留。
deleted_dataset <- imputed_dataset %>%
  filter(!is.na(bpa_ng_ml),!is.na(bpb_ng_ml),!is.na(bps_ng_ml),!is.na(bpf_ng_ml), !is.na(sbp_mmhg))

nrow(deleted_dataset)                    # 预期：801人
nrow(imputed_dataset) - nrow(deleted_dataset) # 预期：删除199人
sum(is.na(deleted_dataset$age_years))    # 预期：0（保留了前面的年龄填补）
sum(is.na(deleted_dataset$bpa_ng_ml))    # 预期：0
sum(is.na(deleted_dataset$sbp_mmhg))     # 预期：0
sum(is.na(deleted_dataset))              # 预期：0
colSums(is.na(deleted_dataset))          # 所有项目缺失都为：0

# 【第 6 步】保存删除后的CSV -------------------------------------
# 文件名末尾的n801表示保存了n801名参与者。
write_csv(deleted_dataset, "data/processed/deleted_datasetn801.csv", na = "")


# ======================== M03 结束 =============================
# 1. 原始数据有多少个缺失单元格？是否等于有缺失的参与者人数？
# 2. 为什么填补年龄和尿比重后仍然有298个NA？
# 3. 填补年龄后为什么仍是1000人？
# 4. 为什么删除BPs和SBP缺失后剩下801人？
# 5. 两个保存的CSV分别有多少人？文件名如何体现人数？
# 6. 为什么最后的deleted_dataset中年龄已经没有NA？
# 后续模块 M04：定义变量类型（连续变量与分类变量）。

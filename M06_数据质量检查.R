# =============================================================
# R Beginner Training | M06 数据质量检查与最终分析数据集
# 学习重点：缺失与重复ID -> 合理范围 -> 衍生变量核查 -> 异常值 -> 标记 -> 保存
# =============================================================

# 【第 0 步】准备Package和数据 ------------------------------------
# 使用M05保存的801人RDS，保留之前设置的Factor类型及类别顺序。
# 本脚本可从头运行，无需保留上一次R会话。
# install.packages("readr")
# install.packages("dplyr")
library(readr)
library(dplyr)

input_path <- "data/processed/modified_datasetn801.rds"
file.exists(input_path)  # 预期：TRUE；若为FALSE，请先运行M05。
modified_dataset <- readRDS(input_path)
dim(modified_dataset)     # 预期：801行，30列

# 【第 1 步】检查人数、缺失值和变量类型 -----------------------------
# M03已经填补和删除指定变量缺失；M06再次确认是否有遗漏。
nrow(modified_dataset)                 # 预期：801人
ncol(modified_dataset)                 # 预期：30列
sum(is.na(modified_dataset))          # 预期：0
colSums(is.na(modified_dataset))
glimpse(modified_dataset)

# 【第 2 步】检查重复参与者ID ------------------------------------
# count()：统计每个ID出现的次数；n>1表示该ID出现两次或以上。
sum(is.na(modified_dataset$participant_id))  # 预期：0
modified_dataset %>%
  count(participant_id) %>%
  filter(n > 1)                 # 预期：0行，没有重复ID

# 【第 3 步】检查连续变量的合理范围 -------------------------------
# summary()：查看最小值、四分位数、中位数、均值和最大值。
summary(modified_dataset %>% select(age_years, height_cm, weight_kg, bmi, sbp_mmhg, urine_sg))

# 以下范围仅为本模拟成人数据的课堂筛查规则，不是通用临床诊断标准。
# 例：找出年龄不在18–70岁、身高不在120–220 cm、体重不在25–250 kg的记录。
modified_dataset %>%
  filter(age_years < 18 | age_years > 70 | height_cm < 120 | height_cm > 220 |
           weight_kg < 25 | weight_kg > 250) %>%
  select(participant_id, age_years, height_cm, weight_kg)  # 预期：0行

# 再检查收缩压、BMI、尿比重（SG）是否超出教学设定的筛查范围。
modified_dataset %>%
  filter(sbp_mmhg < 70 | sbp_mmhg > 250 | bmi < 12 | bmi > 60 |
           urine_sg <= 1 | urine_sg > 1.04) %>%
  select(participant_id, sbp_mmhg, bmi, urine_sg)          # 预期：0行

# 【第 4 步】核查BMI计算和分组 ------------------------------------
# 检查BMI是否与身高、体重计算结果一致。
# abs()：取绝对值；这里允许0.01的数值误差。
sum(abs(modified_dataset$bmi - modified_dataset$weight_kg / (modified_dataset$height_cm / 100)^2) > 0.01)  # 预期：0

# 检查BMI四分类和二分类的人数。
table(modified_dataset$bmi_group)  # 预期：49、338、304、110
table(modified_dataset$bmi_ge24)   # 预期：0为387人；1为414人

# 检查BMI>=24的实际情况与bmi_ge24（0/1）是否一致。
sum(if_else(modified_dataset$bmi >= 24, 1, 0) != modified_dataset$bmi_ge24)  # 预期：0

# 【第 5 步】检查双酚浓度及对数转换结果 -----------------------------
# 不允许出现负浓度；0值可能涉及未检出或数据编码，需要回到检测资料核实。
# 如果需要用LOD/sqrt(2)处理未检出值，应在M05按预先规定的方法处理。
modified_dataset %>%
  filter(bpa_ng_ml < 0 | bpb_ng_ml < 0 | bps_ng_ml < 0 | bpf_ng_ml < 0) %>%
  select(participant_id, bpa_ng_ml, bpb_ng_ml, bps_ng_ml, bpf_ng_ml)  # 预期：0行

# 检查0值的数量。当前模拟数据的四种BPs均没有0值。
sum(modified_dataset$bpa_ng_ml == 0)  # 预期：0
sum(modified_dataset$bpb_ng_ml == 0)  # 预期：0
sum(modified_dataset$bps_ng_ml == 0)  # 预期：0
sum(modified_dataset$bpf_ng_ml == 0)  # 预期：0

# is.finite()：检查结果是否为有限数值；log(0)产生的-Inf不属于有限值。
sum(!is.finite(modified_dataset$ln_bpa_sg))  # 预期：0
sum(!is.finite(modified_dataset$ln_bpb_sg))  # 预期：0
sum(!is.finite(modified_dataset$ln_bps_sg))  # 预期：0
sum(!is.finite(modified_dataset$ln_bpf_sg))  # 预期：0

# 【第 6 步】识别潜在异常值（以SG校正后的BPA为例）---------------------
# 箱线图有助于观察偏态分布和特别高的值；高值不一定是错误。
boxplot(modified_dataset$bpa_sg_ng_ml, main = "SG-adjusted BPA", ylab = "ng/mL")

# IQR：四分位距，即第75百分位数减去第25百分位数。
# 本例用Q3 + 1.5*IQR查找偏高值；它只是筛查界限，不是剔除标准。
bpa_q1 <- quantile(modified_dataset$bpa_sg_ng_ml, 0.25)
bpa_q3 <- quantile(modified_dataset$bpa_sg_ng_ml, 0.75)
bpa_iqr <- IQR(modified_dataset$bpa_sg_ng_ml)
bpa_upper <- bpa_q3 + 1.5 * bpa_iqr
bpa_upper  # 预期：约5.78 ng/mL

sum(modified_dataset$bpa_sg_ng_ml > bpa_upper)  # 预期：49人，仅供复核，不自动删除。
modified_dataset %>%
  filter(bpa_sg_ng_ml > bpa_upper) %>%
  select(participant_id, bpa_sg_ng_ml) %>%
  head(10)

# 【第 7 步】标记数据质量问题，不自动删除 ---------------------------
# qc_开头的变量用于质量检查：0=未发现该类问题；1=需要复核。
# qc_range：教学筛查范围；qc_bmi：BMI计算或二分类错误。
# qc_exposure：负浓度、校正浓度<=0或对数结果不是有限值。
# qc_id：重复ID（同一ID的所有相关记录都标记）。
qc_dataset <- modified_dataset %>%
  mutate(
    qc_range = if_else(age_years < 18 | age_years > 70 | height_cm < 120 | height_cm > 220 |
                         weight_kg < 25 | weight_kg > 250 | sbp_mmhg < 70 | sbp_mmhg > 250 |
                         bmi < 12 | bmi > 60 | urine_sg <= 1 | urine_sg > 1.04, 1, 0),
    qc_bmi = if_else(abs(bmi - weight_kg / (height_cm / 100)^2) > 0.01 |
                       (bmi >= 24 & bmi_ge24 != 1) | (bmi < 24 & bmi_ge24 != 0), 1, 0),
    qc_exposure = if_else(bpa_ng_ml < 0 | bpb_ng_ml < 0 | bps_ng_ml < 0 | bpf_ng_ml < 0 |
                            bpa_sg_ng_ml <= 0 | bpb_sg_ng_ml <= 0 |
                            bps_sg_ng_ml <= 0 | bpf_sg_ng_ml <= 0 |
                            !is.finite(ln_bpa_sg) | !is.finite(ln_bpb_sg) |
                            !is.finite(ln_bps_sg) | !is.finite(ln_bpf_sg), 1, 0),
    qc_id = if_else(duplicated(participant_id) |
                      duplicated(participant_id, fromLast = TRUE) |
                      is.na(participant_id), 1, 0),
    qc_review = if_else(qc_range == 1 | qc_bmi == 1 |
                          qc_exposure == 1 | qc_id == 1, 1, 0)
  )

# 检查需要复核的记录数。IQR高值不自动定义为质量错误，因此不计入qc_review。
table(qc_dataset$qc_review)  # 预期：0为801人；1为0人
qc_dataset %>%
  filter(qc_review == 1) %>%
  select(participant_id, qc_range, qc_bmi, qc_exposure, qc_id)  # 预期：0行

# 【第 8 步】保存检查后的分析数据集 -------------------------------
# 不覆盖M05文件；保留全部801名参与者和新增的质量检查标记。
# 如果真实数据出现qc_review=1，应核对原始记录并记录处理原因，再决定是否修正。
# 文件名末尾标注实际参与者人数。
write_csv(qc_dataset, "data/processed/qc_datasetn801.csv", na = "")
saveRDS(qc_dataset, "data/processed/qc_datasetn801.rds")

file.exists("data/processed/qc_datasetn801.csv")  # 预期：TRUE
file.exists("data/processed/qc_datasetn801.rds")  # 预期：TRUE

# ======================== M06 结束 =============================
# 1. 为什么M03已经处理过NA，M06还要再次检查？
# 2. count(participant_id)与filter(n > 1)各有什么作用？
# 3. 哪些数值应被视为需要复核？筛查范围能否直接作为剔除标准？
# 4. 为什么BMI需要重新核查？BMI>=24的人数应该是多少？
# 5. log(0)为什么可能导致-Inf？is.finite()检查什么？
# 6. 箱线图识别的高BPA值是否应该全部删除？为什么？
# 7. qc_review为0说明什么？它能否证明所有数据都绝对正确？
# 8. 最终CSV和RDS分别保存在哪里？总人数有无变化？
# 后续模块 M07：描述性统计与研究对象基本特征表（Table 1）。

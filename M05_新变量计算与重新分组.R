# =============================================================
# R Beginner Training | M05 新变量计算、重新分组
# 学习重点：计算BMI -> BMI和年龄分组 -> 尿比重校正 -> 对数转换 -> 暴露四分位 -> 保存
# =============================================================

# 【第 0 步】准备Package和数据 ------------------------------------
# 本脚本从M04保存的801人RDS开始，可独立运行（无需保留上次R会话）。
# 使用RDS是为了保留M04设置好的Factor类型和参考组。
# install.packages("readr")
# install.packages("dplyr")
library(readr)
library(dplyr)

input_path <- "data/processed/variable_datasetn801.rds"
file.exists(input_path)  # 预期：TRUE；如果FALSE，请先运行M04并检查路径。
variable_dataset <- readRDS(input_path)
dim(variable_dataset)     # 预期：801行，14列

# 【第 1 步】计算BMI ----------------------------------------------
# BMI = 体重(kg) / 身高(m)^2；身高原始单位为cm，要先除以100。
# mutate()：在原数据集上新增变量，或修改已有变量。
# 注意：保留BMI计算的原始精度，暂时不要用round()覆盖BMI，以免影响Cutoff分组。
modified_dataset <- variable_dataset %>%
  mutate(bmi = weight_kg / (height_cm / 100)^2)

head(modified_dataset)
head(modified_dataset %>% select(participant_id, height_cm, weight_kg, bmi))
summary(modified_dataset$bmi)
round(mean(modified_dataset$bmi), 2)  # 预期：约24.16 kg/m²

# 【第 2 步】按Cutoff给BMI分组 -------------------------------------
# 参考：中国成人BMI标准（18岁及以上）。
# BMI <18.5：体重过低；18.5–<24：正常；24–<28：超重；>=28：肥胖。
# cut()：按照指定分界值把连续变量分组。
# right = FALSE：左边界包含，右边界不包含，如 [24, 28)。
# 同时建立一个二分类结局：bmi_ge24（0：BMI<24；1：BMI>=24）。满足条件，赋值为1L（整数1）。
modified_dataset <- modified_dataset %>%
  mutate(bmi_group = cut(bmi, breaks = c(-Inf, 18.5, 24, 28, Inf),
                         labels = c("underweight", "normal", "overweight", "obesity"), right = FALSE),
         bmi_ge24 = if_else(bmi >= 24, 1L, 0L))   

table(modified_dataset$bmi_group)  # 预期：underweight 49；normal 338；overweight 304；obesity 110
table(modified_dataset$bmi_ge24)   # 预期：0为387人；1为414人

# 【第 3 步】把年龄重新分为3组 -------------------------------------
modified_dataset <- modified_dataset %>%
  mutate(age_group = cut(age_years, breaks = c(18, 40, 60, Inf),
                         labels = c("18-39", "40-59", "60+"), right = FALSE))

table(modified_dataset$age_group)  # 预期：18-39为317人；40-59为322人；60+为162人

# 【第 4 步】演示处理BPA的0值（按LOD方案）------------------------
# 仅当0代表低于检出限时：将BPA的0值替换为LOD/sqrt(2)。
bpa_lod <- 0.01  # 教学假设值（ng/mL），正式研究必须使用实际LOD
modified_dataset <- modified_dataset %>%
  mutate(bpa_ng_ml = if_else(bpa_ng_ml == 0, bpa_lod / sqrt(2), bpa_ng_ml))

# 【第 5 步】根据尿液比重（SG）校正BPs浓度 ----------------------------
# 尿液稀释程度不同，可能影响测得的化学物浓度。
# SG校正公式：校正浓度 = 原始浓度 × (人群SG中位数-1) / (个人SG-1)。
# 本例使用当前801人的SG中位数；校正后浓度单位仍为ng/mL。
# 注意：先检查SG是否大于1，否则分母可能为0或出现无意义结果。
sum(modified_dataset$urine_sg <= 1)  # 预期：0
sg_median <- median(modified_dataset$urine_sg, na.rm = TRUE)
sg_median  # 预期：1.01635

modified_dataset <- modified_dataset %>%
  mutate(bpa_sg_ng_ml = bpa_ng_ml * (sg_median - 1) / (urine_sg - 1),
         bpb_sg_ng_ml = bpb_ng_ml * (sg_median - 1) / (urine_sg - 1),
         bps_sg_ng_ml = bps_ng_ml * (sg_median - 1) / (urine_sg - 1),
         bpf_sg_ng_ml = bpf_ng_ml * (sg_median - 1) / (urine_sg - 1))

head(modified_dataset %>% select(bpa_ng_ml, urine_sg, bpa_sg_ng_ml))

# 【第 6 步】将BPs浓度进行自然对数转换 -------------------------------
# 双酚浓度通常右偏，log()可做自然对数（ln）转换。
# 注意：log()要求浓度>0；本教学数据的4种校正浓度均大于0。
# 如果真实数据有0或低于检出限的值，需要先按研究方案处理。
modified_dataset <- modified_dataset %>%
  mutate(ln_bpa_sg = log(bpa_sg_ng_ml),
         ln_bpb_sg = log(bpb_sg_ng_ml),
         ln_bps_sg = log(bps_sg_ng_ml),
         ln_bpf_sg = log(bpf_sg_ng_ml))

head(modified_dataset %>% select(bpa_sg_ng_ml, ln_bpa_sg))

# 【第 7 步】将BPs暴露水平分为四分位组 ------------------------------
# ntile(x, 4)：按x的大小尽量平均分成4组，Q1最低、Q4最高。
# factor()：将组号设置为分类变量；Q1可作为后续回归的参考组。
modified_dataset <- modified_dataset %>%
  mutate(bpa_q = factor(ntile(bpa_sg_ng_ml, 4), levels = 1:4,
                        labels = c("Q1", "Q2", "Q3", "Q4")),
         bpb_q = factor(ntile(bpb_sg_ng_ml, 4), levels = 1:4,
                        labels = c("Q1", "Q2", "Q3", "Q4")),
         bpf_q = factor(ntile(bpf_sg_ng_ml, 4), levels = 1:4,
                        labels = c("Q1", "Q2", "Q3", "Q4")),
         bps_q = factor(ntile(bps_sg_ng_ml, 4), levels = 1:4,
                        labels = c("Q1", "Q2", "Q3", "Q4")))

table(modified_dataset$bpa_q)  # 预期：Q1为201人，其余每组200人
levels(modified_dataset$bpa_q)

# 【第 8 步】检查新增变量 ----------------------------------------
nrow(modified_dataset)             # 预期：801人（本模块没有删除参与者）
ncol(modified_dataset)             # 预期：30列（原有14列，新增16列）
sum(is.na(modified_dataset))       # 预期：0
class(modified_dataset$bmi)       # 预期：numeric
class(modified_dataset$bmi_group) # 预期：factor
class(modified_dataset$bpa_q)     # 预期：factor



# 【第 9 步】保存新数据集 ----------------------------------------
# 保存CSV和RDS；文件名中的n801表示实际总人数801人。
# CSV用于分享；RDS保留Factor及类别顺序，方便下一个模块使用。
write_csv(modified_dataset, "data/processed/modified_datasetn801.csv", na = "")
saveRDS(modified_dataset, "data/processed/modified_datasetn801.rds")

# ======================== M05 结束 =============================
# 1. 计算BMI时，为什么身高需要除以100？为什么不直接四舍五入后再分组？
# 2. cut()里的breaks和right = FALSE分别是什么意思？
# 3. bmi_group（四分类）与bmi_ge24（二分类）有什么不同？
# 4. 尿液SG校正时，为什么要先检查SG是否大于1？
# 5. log()和ntile()分别对暴露变量做了什么处理？
# 6. 为什么新增变量后还是801人？CSV和RDS有什么区别？
# 后续模块 M06：数据质量检查与最终分析数据集。

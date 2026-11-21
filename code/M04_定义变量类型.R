# =============================================================
# R Beginner Training | M04 定义变量类型（连续变量与分类变量）
# 学习重点：查看变量类型 -> 定义连续变量 -> 转换Factor -> 设置参考组 -> 保存
# =============================================================

# 【第 0 步】准备Package和数据 -----------------------------------
# 使用M03最后保存的801人数据。重新启动R后，也能从这里开始运行。
# install.packages("readr")
# install.packages("dplyr")
library(readr)
library(dplyr)

# 如果文件不在这个位置，请根据实际保存位置修改路径。
data_path <- "data/processed/deleted_datasetn801.csv"
file.exists(data_path)    # 预期：TRUE
deleted_dataset <- read_csv(data_path)
dim(deleted_dataset)       # 预期：801行，14列

# 【第 1 步】查看R识别的变量类型 ----------------------------------
# character（chr）：字符型；numeric/double（dbl）：数值型。
# factor：分类变量常用的R数据类型，CSV读取后通常先显示为character。
glimpse(deleted_dataset)
class(deleted_dataset$age_years)       # 预期：numeric
typeof(deleted_dataset$age_years)     # 预期：double
class(deleted_dataset$sex)             # 预期：character
class(deleted_dataset$education_level) # 预期：character
class(deleted_dataset$participant_id)  # 预期：character（ID不当作连续变量）

# 【第 2 步】确认连续变量 ----------------------------------------
# age_years、height_cm、weight_kg、sbp_mmhg、BPs浓度、urine_sg都按连续变量处理。
# is.numeric()：检查变量是不是数值型，TRUE=是；FALSE=不是。
is.numeric(deleted_dataset$age_years)  # 预期：TRUE
is.numeric(deleted_dataset$bpa_ng_ml)  # 预期：TRUE
is.numeric(deleted_dataset$urine_sg)   # 预期：TRUE

# as.numeric()可把适合转换的数据转成数值型；本例年龄已经是数值型。
# 这里只演示转换方法，不覆盖原始数据。
variable_dataset <- deleted_dataset %>%
  mutate(age_years = as.numeric(age_years))

# 【第 3 步】将分类变量转换为Factor -------------------------------
# factor()：把变量定义为分类变量。
# levels：指定类别及其顺序；对于普通Factor，第一类通常是回归分析的参考组。
# 注意：levels中的拼写必须与CSV中的实际取值一致，否则可能产生新的NA。
variable_dataset <- variable_dataset %>%
  mutate(
    sex = factor(sex, levels = c("female", "male")),
    education_level = factor(education_level, levels = c("high_school_or_less", "college", "university_or_above")),
    smoking_status = factor(smoking_status, levels = c("never", "former", "current")),
    physical_activity = factor(physical_activity, levels = c("low", "moderate", "high"))
  )

# 【第 4 步】查看分类水平与参考组 ----------------------------------
# levels()显示Factor的类别顺序；table()统计每个类别的人数。
class(variable_dataset$sex)           # 预期：factor
levels(variable_dataset$sex)          # 预期：female、male
table(variable_dataset$sex)
levels(variable_dataset$education_level)
levels(variable_dataset$smoking_status)
levels(variable_dataset$physical_activity)

# relevel()可以重新指定普通Factor的参考组。
# 这里仅演示：将male设为参考组，不修改正式数据集。
sex_male_ref <- relevel(variable_dataset$sex, ref = "male")
levels(sex_male_ref)                  # 预期：male、female
sex_male_ref <- relevel(variable_dataset$sex, ref = "female")
levels(sex_male_ref)                  # 预期：female，male

# 【第 5 步】认识有序分类变量（ordered Factor）---------------------
# 例如教育程度有低、中、高的顺序，可用ordered = TRUE定义。
# 注意：有序Factor用于回归时，R默认的对比编码可能不同于普通Factor。
education_ordered <- factor(variable_dataset$education_level,
                            levels = c("high_school_or_less", "college", "university_or_above"),
                            ordered = TRUE)
class(education_ordered)             # 预期：ordered、factor
is.ordered(education_ordered)        # 预期：TRUE

# 【第 6 步】检查转换结果 ----------------------------------------
glimpse(variable_dataset)             # 4个分类变量应显示为fct
nrow(variable_dataset)                # 预期：801人
ncol(variable_dataset)                # 预期：14列
colSums(is.na(variable_dataset))      # 预期：所有变量缺失值均为0

# 【第 7 步】保存结果 --------------------------------------------
# 保存CSV：方便其他软件读取，但CSV不保存Factor类型及参考组信息。
# 保存RDS：可保留Factor类型和类别顺序，供后续R课程直接使用。
# 文件名中的n801表示参与者总人数。
write_csv(variable_dataset, "data/processed/variable_datasetn801.csv")
saveRDS(variable_dataset, "data/processed/variable_datasetn801.rds")


# 重新读取RDS，检查Factor是否保留。
check_dataset <- readRDS("data/processed/variable_datasetn801.rds")
class(check_dataset$sex)              # 预期：factor
levels(check_dataset$sex)             # 预期：female、male

# ======================== M04 结束 =============================
# 1. Character和Factor有什么区别？
# 2. 为什么age_years是numeric，而sex适合转换为Factor？
# 3. levels()的顺序有什么作用？普通Factor的第一类通常代表什么？
# 4. relevel()会不会改变参与者的实际性别？
# 5. 有序Factor与普通Factor有什么区别？
# 6. 为什么保存CSV和RDS？哪种格式能够保留Factor类型？
# 7. 变量类型转换后，样本量和缺失值数量是否改变？
# 后续模块 M05：重新分组、计算BMI与定义cutoff。

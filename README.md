# Statistical Training for Clinical Studies
**R Beginner Training | From raw data to tables and figures**

## 1. Introduction

This project is designed for students and researchers who are new to **R** and want to use it for **clinical data analysis**. Starting with the absolute basics of R, the lessons guide beginners step by step through data import, data cleaning, variable management, descriptive statistics, statistical testing, and regression analysis. Later modules introduce mixture-exposure models and the presentation of results in tables and figures.

Our goal is to help learners understand the **complete workflow from raw data to interpretable results**, rather than simply copy and run R code. Each module focuses on a small set of practical tasks, with clear explanations and scripts that learners can run line by line in RStudio or Posit Cloud.

The introductory lessons use a **simulated dataset of 1,000 adults**, including urinary BPA, BPB, BPS, BPF, urine specific gravity, and basic demographic and health variables. The data are for **teaching only** and must not be interpreted as real clinical or epidemiological findings.

Zeng Yi 2026 11 22

## 2. Contents of the project

### `code/` — Step-by-step R lessons (M01–M17)
The learning modules follow the order of a typical data-analysis project. **M01–M06 are currently available**; M07–M17 are planned and will be linked as their scripts are added.

| Module | Topic | Main learning objectives | Status |
| --- | --- | --- | --- |
| [M01](code/M01_读取数据与认识数据集.R) | Importing and exploring data | Packages, file paths, CSV import, variables, data types, and IDs | Available |
| [M02](code/M02_提取分析变量与建立分析数据集.R) | Selecting variables and participants | `select()`, `filter()`, `rename()`, and exporting subsets | Available |
| [M03](code/M03_缺失值的检查填补与删除.R) | Handling missing data | Check missingness, simple imputation, complete-case filtering, and save datasets | Available |
| [M04](code/M04_定义变量类型.R) | Defining variable types | Numeric and character variables, factors, levels, and reference groups | Available |
| [M05](code/M05_新变量计算与重新分组.R) | Creating and recoding variables | BMI, cutoffs, age groups, specific-gravity correction, log transformation, and exposure quartiles | Available |
| [M06](code/M06_数据质量检查.R) | Data quality control | Range checks, duplicate IDs, derived-variable validation, and outlier review | Available |
| M07 | Descriptive statistics | Summaries of continuous and categorical variables; Table 1 | Planned |
| M08 | Distributions and statistical assumptions | Histograms, Q–Q plots, normality, and assumptions for statistical tests | Planned |
| M09 | t-tests | Independent, paired, and Welch t-tests | Planned |
| M10 | ANOVA | Comparing multiple groups and post-hoc comparisons | Planned |
| M11 | Nonparametric tests | Wilcoxon and Kruskal–Wallis tests | Planned |
| M12 | Correlation analysis | Pearson and Spearman correlation | Planned |
| M13 | Simple linear regression | Regression coefficients, confidence intervals, and model interpretation | Planned |
| M14 | Multiple linear regression | Covariate adjustment, confounding, and model diagnostics | Planned |
| M15 | Logistic regression | Binary outcomes, odds ratios, and interpretation | Planned |
| M16 | Mixture-exposure analysis | Introduction to qg-computation, WQS, and BKMR | Planned |
| M17 | Reporting results | Reproducible tables, figures, and concise interpretation | Planned |

### `exercises/`
This folder will contain **independent exercises based on publicly available NHANES data**, allowing learners to apply the skills from M01 through M17 to a real-world public-health dataset. Exercises will progress from downloading and combining data files, to cleaning variables, selecting appropriate statistical analyses, and producing tables and figures.

When population-representative estimates are required, the exercises will also explain the relevant NHANES survey design and weights.

### `data/` — Example dataset

- [bisphenols_adults_1000.csv](data/bisphenols_adults_1000.csv): simulated adult dataset for M01–M17.
- `data/processed/`: output datasets generated as learners run the scripts; files are named with the participant count (for example, `deleted_datasetn801.csv`).


### Getting started (RStudio or Posit Cloud)

1. Open or import this GitHub repository as an RStudio project or a Posit Cloud project, and work from the **repository root folder**.
2. If needed, install the introductory packages once: `install.packages(c("readr", "dplyr"))`.
3. Check the relative data path: `file.exists("data/bisphenols_adults_1000.csv")` should return `TRUE`.
4. Open [M01](code/M01_读取数据与认识数据集.R) and run the script line by line; continue in module order.
5. For modules M04–M06, run the preceding module(s) first to create the required processed files.

The lessons can be used with **RStudio locally** or **Posit Cloud online**. Claude can be used as an optional learning assistant for understanding code and interpreting errors; it is not required to run the analyses.

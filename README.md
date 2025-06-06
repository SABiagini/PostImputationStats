# Post Imputation Stats
---

## 🧬 Imputation Concordance Analysis

To evaluate imputation performance, you will need:

* A VCF file containing imputed data for each sample.
* A corresponding high-coverage VCF file for the same sample.

> ⚠️ **Important**: Sample names must match **exactly** in the headers of both files.

We worked with **one VCF per individual**.

---

### 🔹 Step 1 – Run SnpSift Concordance

For each sample, run:

```bash
SnpSift concordance SAMPLE_NAME_HIGH.COVERAGE.vcf SAMPLE_NAME_IMPUTED.vcf > comparison_SAMPLE_NAME.txt
```

This will generate **three output files**:

* `comparison_SAMPLE_NAME.txt`: Concordance by variant
* `*.by_sample.txt`: Concordance by sample
* `*.summary.txt`: Summary

---

### 🔹 Step 2 – Generate Concordance Matrix

Run the following script on the `*.by_sample.txt` file:

```bash
perl SnpSiftStats.pl *.by_sample.txt
```

This will generate, for each sample, a summary file like `SAMPLE_NAME.matrix`, showing genotype concordance between imputed and high-coverage data:

```
Sample ID: SAMPLE_NAME
h/i    0/0       0/1       1/1       ./.
0/0    31572015  7329      10        1160372
0/1    22344     1121895   2636      738005
1/1    206       9016      786197    344940
./.    0         0         0         0
```

This matrix reports the number of concordant and discordant genotype calls.
For example:

* `10` sites were expected as `0/0` in the high-coverage data but imputed as `1/1` → discordant.
* `1,121,895` sites were correctly imputed as `0/1`.

In this example, no missing sites are present. However, missingness might appear if, for example, the imputed file is filtered based on genotype probability (GP), resulting in missing calls (`./.`).
We recommend repeating this step after different post-imputation filtering strategies to compare their impact.

---

### 🔹 Step 3 – Add Allele Frequencies and Bin Variants

Run:

```bash
perl addfreq_summarybin.pl comparison_SAMPLE_NAME.txt freqfile
```

You’ll need:

* The `comparison_SAMPLE_NAME.txt` file from step 1.
* A **frequency file** for each variant, computed with **PLINK** on the reference panel used for imputation (calculate per chromosome, then merge into a single file).

Example format of the frequency file:

```
CHR  SNP              A1  A2  MAF       NCHROBS
1    1_13380_C_G      G   C   0.0001102 45382
1    1_16071_G_A      A   G   0.0001763 45382
1    1_16141_C_T      T   C   0.0001542 45382
```

This step:

* Adds a **frequency column** to each variant.
* Splits the variants into **6 frequency bins**:

| Output File                      | Frequency Range     |
| -------------------------------- | ------------------- |
| comparison.with.freq\_lt0.001    | freq ≤ 0.001        |
| comparison.with.freq\_0.001-0.01 | 0.001 < freq ≤ 0.01 |
| comparison.with.freq\_0.01-0.05  | 0.01 < freq ≤ 0.05  |
| comparison.with.freq\_0.05-0.1   | 0.05 < freq ≤ 0.1   |
| comparison.with.freq\_0.1-0.3    | 0.1 < freq ≤ 0.3    |
| comparison.with.freq\_gt0.3      | freq > 0.3          |

Additionally, a **cumulative file** is generated for all variants with freq > 0.05:

* `comparison.with.freq_gt0.05` → union of bins 0.05–0.1, 0.1–0.3, and >0.3

Each bin also has a corresponding **summary file**:
e.g. `freq_0.001-0.01_summary`, which aggregates concordance statistics for that bin.

---

### 🔹 Step 4 – Generate Matrices for Each Frequency Bin

Run:

```bash
for i in *_summary; do perl SnpSiftStats.pl $i; done
```

Each bin will now have a `.matrix` file. For example, `gt0.05.matrix`:

```
Sample ID: gt0.05
h/i    0/0      0/1      1/1      ./.
0/0    2066128  7033     5        674900
0/1    10655    1070164  2459     651781
1/1    8        8933     580247   333651
./.    0        0        0        0
```

These matrices summarize concordance/discordance between imputed and high-coverage genotypes **within specific frequency ranges**.

---

### 🔹 Step 5 – Compute Post-Imputation Summary Statistics

Use the `.matrix` files generated in Step 4 as input:

```bash
for m in *.matrix; do perl PostImputationStats.pl $m; done
```

This will generate a **summary file for each frequency bin**, containing a set of statistics on concordance and accuracy of imputed genotypes.

#### 📊 Output Columns Explained

| Column                         | Description                                                      |
| ------------------------------ | ---------------------------------------------------------------- |
| `MAF.bin`                      | Minor Allele Frequency bin name                                  |
| `#Het`                         | Correctly imputed heterozygous sites (count and percentage)      |
| `#Ref`                         | Correctly imputed homozygous reference sites                     |
| `#Alt`                         | Correctly imputed homozygous alternate sites                     |
| `Total`                        | Total number of correctly imputed sites (Het + Ref + Alt)        |
| `MisHet(%)`                    | Percentage of missing heterozygous genotypes                     |
| `MisRef(%)`                    | Percentage of missing homozygous reference genotypes             |
| `MisAlt(%)`                    | Percentage of missing homozygous alternate genotypes             |
| `MisTot(%)`                    | Total missing genotype percentage                                |
| `Het.Precision(%)`             | Precision for heterozygous calls                                 |
| `Ref.Precision(%)`             | Precision for reference calls                                    |
| `Alt.Precision(%)`             | Precision for alternate calls                                    |
| `Tot.Precision(%)`             | Overall precision                                                |
| `Het.Sensitivity(%)`           | Sensitivity for heterozygous calls                               |
| `Ref.Sensitivity(%)`           | Sensitivity for reference calls                                  |
| `Alt.Sensitivity(%)`           | Sensitivity for alternate calls                                  |
| `Tot.Sensitivity(%)`           | Overall sensitivity                                              |
| `Het.Specificity(%)`           | Specificity for heterozygous calls                               |
| `Ref.Specificity(%)`           | Specificity for reference calls                                  |
| `Alt.Specificity(%)`           | Specificity for alternate calls                                  |
| `Tot.Specificity(%)`           | Overall specificity                                              |
| `Het.Accuracy(%)`              | Accuracy of heterozygous calls                                   |
| `Ref.Accuracy(%)`              | Accuracy of reference calls                                      |
| `Alt.Accuracy(%)`              | Accuracy of alternate calls                                      |
| `Tot.Accuracy(%)`              | Overall accuracy                                                 |
| `Het.FPR(%)`                   | False Positive Rate for heterozygous calls                       |
| `Ref.FPR(%)`                   | False Positive Rate for reference calls                          |
| `Alt.FPR(%)`                   | False Positive Rate for alternate calls                          |
| `Tot.FPR(%)`                   | Overall False Positive Rate                                      |
| `Het.FNR(%)`                   | False Negative Rate for heterozygous calls                       |
| `Ref.FNR(%)`                   | False Negative Rate for reference calls                          |
| `Alt.FNR(%)`                   | False Negative Rate for alternate calls                          |
| `Tot.FNR(%)`                   | Overall False Negative Rate                                      |
| `Non-reference.discordance(%)` | Discordance rate for non-reference genotypes                     |
| `Non-reference.concordance(%)` | Concordance rate for non-reference genotypes (100 - discordance) |

---

### 🔹 Step 6 – Merge Statistics from All Bins

Once the individual bin files have been generated, merge them into a single summary using:

```bash
bash makeSummary.sh
```

This will produce a single `SummaryStats` file aggregating statistics across all MAF bins for the sample.

---

### 🔹 Step 7 – Calculate R² Statistics Per Frequency Bin

Before running this step, make sure you have [BCFtools](https://github.com/samtools/bcftools?tab=readme-ov-file) installed, and prepare a set of variant list files, one for each frequency bin. Name them as follows:

```
0_0.001
0.001_0.01
0.01_0.05
0.05_0.1
0.1_0.3
gt0.3
gt0.05
```

Each file should contain **two columns**: chromosome and position, extracted from the frequency file used in Step 3:

```
chr1    598812
chr1    758351
chr1    794299
```

Now run:

```bash
bash makeR2.sh path/to/folder/with/frequency_files/ SAMPLE_NAME_IMPUTED.vcf SAMPLE_NAME_HIGH.COVERAGE.vcf
```

#### ✅ Purpose of This Step

* Extract variants for each MAF bin from the imputed VCF.
* Create compressed and indexed VCFs for each bin.
* Compare each bin to the high-coverage reference VCF.
* Compute **Pearson correlation (R²)** between imputed and true genotypes for each bin.
* Append the R² values to the corresponding summary.

Final output will be a file named `SummaryStatsR2`, which is identical to the `SummaryStats` file from Step 6, but includes an additional column with R² values for each frequency bin.

---

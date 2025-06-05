# Post Imputation Stats

🧬 Imputation Concordance Analysis (Steps 1–4)
To evaluate imputation performance, you will need:

A VCF file containing imputed data for each sample.

A corresponding high-coverage VCF file for the same sample.

⚠️ Important: Sample names must match exactly in the headers of both files.

We worked with one VCF per individual.

🔹 Step 1 – Run SnpSift Concordance
For each sample, run:

bash
Copy
Edit
SnpSift concordance SAMPLE_NAME_HIGH.COVERAGE.vcf SAMPLE_NAME_IMPUTED.vcf > comparison_SAMPLE_NAME.txt
This will generate three output files:

comparison_SAMPLE_NAME.txt: Concordance by variant

*.by_sample.txt: Concordance by sample

*.summary.txt: Summary

🔹 Step 2 – Generate Concordance Matrix
Run the following script on the *.by_sample.txt file:

bash
Copy
Edit
perl SnpSiftStats.pl *.by_sample.txt
This will generate, for each sample, a summary file like SAMPLE_NAME.matrix, showing genotype concordance between imputed and high-coverage data:

yaml
Copy
Edit
Sample ID: SAMPLE_NAME
h/i    0/0       0/1       1/1       ./.
0/0    31572015  7329      10        1160372
0/1    22344     1121895   2636      738005
1/1    206       9016      786197    344940
./.    0         0         0         0
This matrix reports the number of concordant and discordant genotype calls.
For example:

10 sites were expected as 0/0 in the high-coverage data but imputed as 1/1 → discordant.

1,121,895 sites were correctly imputed as 0/1.

In this example, no missing sites are present. However, missingness might appear if, for example, the imputed file is filtered based on genotype probability (GP), resulting in missing calls (./.).
We recommend repeating this step after different post-imputation filtering strategies to compare their impact.

🔹 Step 3 – Add Allele Frequencies and Bin Variants
Run:

bash
Copy
Edit
perl addfreq_summarybin.pl comparison_SAMPLE_NAME.txt freqfile
You’ll need:

The comparison_SAMPLE_NAME.txt file from step 1.

A frequency file for each variant, computed with PLINK on the reference panel used for imputation (calculate per chromosome, then merge into a single file).

Example format of the frequency file:

mathematica
Copy
Edit
CHR  SNP              A1  A2  MAF       NCHROBS
1    1_13380_C_G      G   C   0.0001102 45382
1    1_16071_G_A      A   G   0.0001763 45382
1    1_16141_C_T      T   C   0.0001542 45382
This step:

Adds a frequency column to each variant.

Splits the variants into 6 frequency bins:

Output File	Frequency Range
comparison.with.freq_lt0.001	freq ≤ 0.001
comparison.with.freq_0.001-0.01	0.001 < freq ≤ 0.01
comparison.with.freq_0.01-0.05	0.01 < freq ≤ 0.05
comparison.with.freq_0.05-0.1	0.05 < freq ≤ 0.1
comparison.with.freq_0.1-0.3	0.1 < freq ≤ 0.3
comparison.with.freq_gt0.3	freq > 0.3

Additionally, a cumulative file is generated for all variants with freq > 0.05:

comparison.with.freq_gt0.05 → union of bins 0.05–0.1, 0.1–0.3, and >0.3

Each bin also has a corresponding summary file:
e.g. freq_0.001-0.01_summary, which aggregates concordance statistics for that bin.

🔹 Step 4 – Generate Matrices for Each Frequency Bin
Run:

bash
Copy
Edit
for i in *_summary; do perl SnpSiftStats.pl $i; done
Each bin will now have a .matrix file. For example, gt0.05.matrix:

yaml
Copy
Edit
Sample ID: gt0.05
h/i    0/0      0/1      1/1      ./.
0/0    2066128  7033     5        674900
0/1    10655    1070164  2459     651781
1/1    8        8933     580247   333651
./.    0        0        0        0
These matrices summarize concordance/discordance between imputed and high-coverage genotypes within specific frequency ranges.

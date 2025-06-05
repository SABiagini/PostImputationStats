#!/usr/bin/bash

freq=$1 # path to folder with frequency bin files
lc=$2 # imputed vcf file
hc=$3 # high coverage file

mkdir ${pwd}/MAFbinsForR2 &&

bcftools view -T ${freq}/0.1_0.3 $lc -Oz -o ${pwd}/MAFbinsForR2/bin_0.1_0.3.vcf.gz &&
bcftools index ${pwd}/MAFbinsForR2/bin_0.1_0.3.vcf.gz &&

bcftools view -T ${freq}/0.05_0.1 $lc -Oz -o ${pwd}/MAFbinsForR2/bin_0.05_0.1.vcf.gz &&
bcftools index ${pwd}/MAFbinsForR2/bin_0.05_0.1.vcf.gz &&

bcftools view -T ${freq}/0.01_0.05 $lc -Oz -o ${pwd}/MAFbinsForR2/bin_0.01_0.05.vcf.gz &&
bcftools index ${pwd}/MAFbinsForR2/bin_0.01_0.05.vcf.gz &&

bcftools view -T ${freq}/0.001_0.01 $lc -Oz -o ${pwd}/MAFbinsForR2/bin_0.001_0.01.vcf.gz &&
bcftools index ${pwd}/MAFbinsForR2/bin_0.001_0.01.vcf.gz &&

bcftools view -T ${freq}/gt0.3 $lc -Oz -o ${pwd}/MAFbinsForR2/bin_gt0.3.vcf.gz &&
bcftools index ${pwd}/MAFbinsForR2/bin_gt0.3.vcf.gz &&

bcftools view -T ${freq}/gt0.05 $lc -Oz -o ${pwd}/MAFbinsForR2/bin_gt0.05.vcf.gz &&
bcftools index ${pwd}/MAFbinsForR2/bin_gt0.05.vcf.gz &&

bcftools view -T ${freq}/0_0.001 $lc -Oz -o ${pwd}/MAFbinsForR2/bin_0_0.001.vcf.gz &&
bcftools index ${pwd}/MAFbinsForR2/bin_0_0.001.vcf.gz &&

for f in ${pwd}/MAFbinsForR2/*.vcf.gz  
do
name=$(basename $f .vcf.gz) &&
sample=$(bcftools query -l $hc) &&
bcftools stats -s $sample $f $hc/${name}.vcf.gz > ${pwd}/MAFbinsForR2/bcftools_stats_$name &&
bin=$(echo $name | sed 's/bin\_//g') &&
r=$(grep GCsS ${pwd}/MAFbinsForR2/bcftools_stats_$name | cut -f11 | tail -n +3) &&
printf "$bin\t$r\t$file\n" >> ${pwd}/MAFbinsForR2/PearsonsCorrelationCoefR2 &&
sed -i 's/\_/\-/g' ${pwd}/MAFbinsForR2/PearsonsCorrelationCoefR2 &
done &&
wait

join -t $'\t' -1 1 -2 1 -o 1.1 1.2 1.3 1.4 1.5 1.6 1.7 1.8 1.9 1.10 1.11 1.12 1.13 1.14 1.15 1.16 1.17 1.18 1.19 1.20 1.21 1.22 1.23 1.24 1.25 1.26 1.27 1.28 1.29 1.30 1.31 1.32 1.33 1.34 1.35 1.36 2.2 <(sort -t, -k1 ${pwd}/SummaryStats) <(sort -t, -k1 ${pwd}/MAFbinsForR2/PearsonsCorrelationCoefR2) > ${pwd}/MAFbinsForR2/SummaryStats2 &&

head -n1 ${pwd}/SummaryStats > ${pwd}/MAFbinsForR2/header &&

sed -i 's/$/\tR2/' ${pwd}/MAFbinsForR2/header &&

cat ${pwd}/MAFbinsForR2/header ${pwd}/MAFbinsForR2/SummaryStats2 | sed 's/gt/\> /' > ${pwd}/MAFbinsForR2/SummaryStatsR2 &&

awk -v var="$HC" 'BEGIN {OFS=FS="\t"} {if (NR==1) {print $0} else {$36=var; print $0}}' SummaryStatsR2 > SummaryStatsR2_2 &&

mv SummaryStatsR2_2 SummaryStatsR2 &&

rm ${pwd}/MAFbinsForR2/SummaryStats2 ${pwd}/MAFbinsForR2/header 


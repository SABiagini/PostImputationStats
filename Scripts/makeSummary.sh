#!/usr/bin/bash

grep MAF 0.05-0.1.stats > header &&

for y in *.stats; do tail -n +2 $y >> tmp; done &&

cat header tmp > SummaryStats &&

rm header tmp &&

awk 'NR==1' SummaryStats > SummaryStats2 &&
awk 'NR==9' SummaryStats >> SummaryStats2 &&
awk 'NR==2' SummaryStats >> SummaryStats2 &&
awk 'NR==3' SummaryStats >> SummaryStats2 &&
awk 'NR==4' SummaryStats >> SummaryStats2 &&
awk 'NR==5' SummaryStats >> SummaryStats2 &&
awk 'NR==8' SummaryStats >> SummaryStats2 &&
awk 'NR==7' SummaryStats >> SummaryStats2 &&
awk 'NR==6' SummaryStats >> SummaryStats2 &&

awk 'NR==9{sub($1, "ALL")}1' SummaryStats2 > SummaryStats3 &&

rm SummaryStats2 &&

head -n 1 SummaryStats3 > header &&
awk '{print $_,"\t","Sample"}' header > header2 &&
tail -n +2 SummaryStats3 > body &&
awk -v r=$file '{print $_,"\t",r}' body > body2 &&
cat header2 body2 > SummaryStats3 &&

rm header header2 body body2 &&

mv SummaryStats3 SummaryStats &&

sed -i 's/\_/\-/g' SummaryStats &&

sed -i 's/lt0\.001/0\-0\.001/g' SummaryStats &&

echo "done!"

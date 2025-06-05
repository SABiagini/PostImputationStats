#!/usr/bin/perl

# HOW2RUN: 

use warnings;
use strict;

my $input = $ARGV[0]; # each table .matrix coming out of SnpSiftStats.pl

my $outname = `echo $input | sed 's/\.matrix//' `;
chomp $outname;

my $bin=`grep Sample $input | cut -d' ' -f3`; # Extract maf bin name
chomp $bin; # Remove new line from maf bin name string

open(IN, $input) or die "Could not open file: $input!";
open (OUT,"> $outname.stats") or die "Could not write file: stats!";

my @picks=();

while(my $line=<IN>){
	if ($line=~ m/^S/ || $line=~ m/^M/ || $line=~ m/^H/ || $line =~ /^\s*($|#)/){
		next;
	}
	else {
		my @values = split(/\t/, $line); # array of values is created
		push @picks, \@values; # push a reference to the @values array, onto the
	}
}
close IN;

# Header
print OUT "MAF.bin\t#Het\t#Ref\t#Alt\tTotal\tMisHet(%)\tMisRef(%)\tMisAlt(%)\tMisTot(%)\tHet.Precision(%)\tRef.Precision(%)\tAlt.Precision(%)\tTot.Precision(%)\tHet.Sensitivity(%)\tRef.Sensitivity(%)\tAlt.Sensitivity(%)\tTot.Sensitivity(%)\tHet.Specificity(%)\tRef.Specificity(%)\tAlt.Specificity(%)\tTot.Specificity(%)\tHet.Accuracy(%)\tRef.Accuracy(%)\tAlt.Accuracy(%)\tTot.Accuracy(%)\tHet.FPR(%)\tRef.FPR(%)\tAlt.FPR(%)\tTot.FPR(%)\tHet.FNR(%)\tRef.FNR(%)\tAlt.FNR(%)\tTot.FNR(%)\tNon-reference.discordance(%)\tNon-reference.concordance(%)\n";

#########
## Het ##
#########

my $hetnum=$picks[2][2]; # N° correctly imputed sites
my $hetden2=($picks[2][1]+$picks[2][2]+$picks[2][3]+$picks[2][4]); # N° imputed variants (missing included)
my $hnvar=($hetnum/$hetden2)*100; # % correctly imputed sites
my $hetn=sprintf("%.2f",$hnvar); # Round % correctly imputed sites
# Missingness 
my $mishet=($picks[2][4]/($picks[2][1]+$picks[2][2]+$picks[2][3]+$picks[2][4]))*100; # % missing sites
my $mish=sprintf("%.2f",$mishet); # Round % missing sites
# Precision (Che ce sta a dì???)
my $hetpre=($picks[2][2]/($picks[2][2]+$picks[1][2]+$picks[3][2]))*100; # Precision %
my $hetp=sprintf("%.2f",$hetpre); # Round % Precision
#Sensitivity (aka true positive rate. Ci dice quanto l'imputazione sia stata efficace nell'identificare siti true positive)
my $hetden=($picks[2][1]+$picks[2][2]+$picks[2][3]); # N° imputed sites (missing not included)
my $hetsen=($hetnum/$hetden)*100; # Sensitivity
my $hsen=sprintf("%.2f",$hetsen); # Round % Sensitivity
# Specificity (aka true negative rate. Ci dice quanto l'imputazione sia stata efficace nell'identificare siti falsi negativi)
my $hetspe=(($picks[1][1]+$picks[1][3]+$picks[3][1]+$picks[3][3])/($picks[1][1]+$picks[1][3]+$picks[3][1]+$picks[3][3]+$picks[1][2]+$picks[3][2]))*100;
my $hspe=sprintf("%.2f",$hetspe); # Round % Specificity
# Accuracy (Accuracy is how close you are to the true value)
my $hetacc=(($picks[2][2]+($picks[1][1]+$picks[1][3]+$picks[3][1]+$picks[3][3]))/($picks[2][2]+($picks[1][1]+$picks[1][3]+$picks[3][1]+$picks[3][3])+($picks[1][2]+$picks[3][2])+($picks[2][1]+$picks[2][3])))*100;
my $heta=sprintf("%.2f",$hetacc); # Round % Accuracy
# False Positive Rate (the probability of falsely rejecting the null hypothesis)
my $hetfpr=(1-($hetspe/100))*100;
my $hfpr=sprintf("%.2f",$hetfpr); # Round % FPR;
# False Negative Rate (proportion of significance tests that failed to reject the null hypothesis when the null hypothesis is indeed false)
my $hetfnr=(1-($hetsen/100))*100;
my $hfnr=sprintf("%.2f",$hetfnr); # Round % FNR;

#########
## Ref ##
#########

my $refnum=$picks[1][1]; # N° correctly imputed sites
my $refden2=($picks[1][1]+$picks[1][2]+$picks[1][3]+$picks[1][4]); # N° imputed sites (missing included)
my $rnvar=($refnum/$refden2)*100; # % correctly imputed sites
my $refn=sprintf("%.2f",$rnvar); # Round % correctly imputed sites
# Missingness 
my $misref=($picks[1][4]/($picks[1][1]+$picks[1][2]+$picks[1][3]+$picks[1][4]))*100; # % missing sites
my $misr=sprintf("%.2f",$misref); # Round % missing sites
# Precision (Che ce sta a dì???)
my $refpre=($picks[1][1]/($picks[1][1]+$picks[2][1]+$picks[3][1]))*100; # Precision %
my $refp=sprintf("%.2f",$refpre); # Round % Precision
#Sensitivity (aka true positive rate. Ci dice quanto l'imputazione sia stata efficace nell'identificare siti true positive)
my $refden=($picks[1][1]+$picks[1][2]+$picks[1][3]); # N° imputed sites (missing not included)
my $refsen=($refnum/$refden)*100; # Sensitivity
my $rsen=sprintf("%.2f",$refsen); # Round % Sensitivity
# Specificity (aka true negative rate. Ci dice quanto l'imputazione sia stata efficace nell'identificare falsi negativi)
my $refspe=(($picks[2][2]+$picks[2][3]+$picks[3][2]+$picks[3][3])/($picks[2][2]+$picks[2][3]+$picks[3][2]+$picks[3][3]+$picks[2][1]+$picks[3][1]))*100;
my $rspe=sprintf("%.2f",$refspe); # Round % Specificity
# Accuracy (Accuracy is how close you are to the true value)
my $refacc=(($picks[1][1]+($picks[2][2]+$picks[2][3]+$picks[3][2]+$picks[3][3]))/($picks[1][1]+($picks[2][2]+$picks[2][3]+$picks[3][2]+$picks[3][3])+($picks[1][2]+$picks[1][3])+($picks[2][1]+$picks[3][1])))*100;
my $refa=sprintf("%.2f",$refacc); # Round % Accuracy
# False Positive Rate (the probability of falsely rejecting the null hypothesis)
my $reffpr=(1-($refspe/100))*100;
my $rfpr=sprintf("%.2f",$reffpr); # Round % FPR;
# False Negative Rate
my $reffnr=(1-($refsen/100))*100;
my $rfnr=sprintf("%.2f",$reffnr); # Round % FNR;

#########
## Alt ##
#########

my $altnum=$picks[3][3]; # N° correctly imputed sites
my $altden2=($picks[3][1]+$picks[3][2]+$picks[3][3]+$picks[3][4]); # N° imputed sites (missing included)
my $anvar=($altnum/$altden2)*100; # % correctly imputed sites
my $altn=sprintf("%.2f",$anvar); # Round % correctly imputed sites
# Missingness
my $misalt=($picks[3][4]/($picks[3][1]+$picks[3][2]+$picks[3][3]+$picks[3][4]))*100; # % missing sites
my $misa=sprintf("%.2f",$misalt); # Round % missing sites
# Precision (Che ce sta a dì???)
my $altpre=($picks[3][3]/($picks[3][3]+$picks[2][3]+$picks[1][3]))*100; # Precision %
my $altp=sprintf("%.2f",$altpre); # Round % Precision
#Sensitivity (aka true positive rate. Ci dice quanto l'imputazione sia stata efficace nell'identificare siti true positive)
my $altden=($picks[3][1]+$picks[3][2]+$picks[3][3]); # N° imputed sites (missing not included)
my $altsen=($altnum/$altden)*100; # Sensitivity
my $asen=sprintf("%.2f",$altsen); # Round % Sensitivity
# Specificity (aka true negative rate. Ci dice quanto l'imputazione sia stata efficace nell'identificare falsi negativi)
my $altspe=(($picks[1][1]+$picks[1][2]+$picks[2][1]+$picks[2][2])/($picks[1][1]+$picks[1][2]+$picks[2][1]+$picks[2][2]+$picks[1][3]+$picks[2][3]))*100;
my $aspe=sprintf("%.2f",$altspe); # Round % Specificity
# Accuracy (Accuracy is how close you are to the true value)
my $altacc=(($picks[3][3]+($picks[1][1]+$picks[1][2]+$picks[2][1]+$picks[2][2]))/($picks[3][3]+($picks[1][1]+$picks[1][2]+$picks[2][1]+$picks[2][2])+($picks[1][3]+$picks[2][3])+($picks[3][1]+$picks[3][2])))*100;
my $alta=sprintf("%.2f",$altacc); # Round % Accuracy
# False Positive Rate (the probability of falsely rejecting the null hypothesis)
my $altfpr=(1-($altspe/100))*100;
my $afpr=sprintf("%.2f",$altfpr); # Round % FPR;
# False Negative Rate
my $altfnr=(1-($altsen/100))*100;
my $afnr=sprintf("%.2f",$altfnr); # Round % FNR;

#########
## Tot ##
#########

my $totnum=($hetnum+$refnum+$altnum); # N° correctly imputed sites
my $tperc=($totnum/($hetden2+$refden2+$altden2))*100; # % correctly imputed sites
my $totn=sprintf("%.2f",$tperc); # Round % correctly imputed sites
# Missingness
my $mistot=(($picks[1][4]+$picks[2][4]+$picks[3][4])/($picks[2][1]+$picks[2][2]+$picks[2][3]+$picks[2][4]+$picks[1][1]+$picks[1][2]+$picks[1][3]+$picks[1][4]+$picks[3][1]+$picks[3][2]+$picks[3][3]+$picks[3][4]))*100; # % missing sites
my $mist=sprintf("%.2f",$mistot); # Round % missing sites
# Precision
my $totpre=(($picks[1][1]+$picks[2][2]+$picks[3][3])/($picks[1][1]+$picks[2][2]+$picks[3][3]+$picks[1][2]+$picks[3][2]+$picks[2][1]+$picks[3][1]+$picks[2][3]+$picks[1][3]))*100; # Precision %
my $totp=sprintf("%.2f",$totpre); # Round % Precision
#Sensitivity (aka true positive rate. Ci dice quanto l'imputazione sia stata efficace nell'identificare siti true positive)
my $totsen=(($hetnum+$refnum+$altnum)/($hetden+$refden+$altden))*100; # Sensitivity
my $tsen=sprintf("%.2f",$totsen); # Round % Sensitivity
# Specificity (aka true negative rate. Ci dice quanto l'imputazione sia stata efficace nell'identificare falsi negativi)
my $totspe=(($picks[1][1]+$picks[1][3]+$picks[3][1]+$picks[3][3]+$picks[2][2]+$picks[2][3]+$picks[3][2]+$picks[3][3]+$picks[1][1]+$picks[1][2]+$picks[2][1]+$picks[2][2])/($picks[1][1]+$picks[1][3]+$picks[3][1]+$picks[3][3]+$picks[1][2]+$picks[3][2]+$picks[2][2]+$picks[2][3]+$picks[3][2]+$picks[3][3]+$picks[2][1]+$picks[3][1]+$picks[1][1]+$picks[1][2]+$picks[2][1]+$picks[2][2]+$picks[1][3]+$picks[2][3]))*100;
my $tspe=sprintf("%.2f",$totspe); # Round % Specificity
# Accuracy (Accuracy is how close you are to the true value)
my $totacc=(($picks[3][3]+($picks[1][1]+$picks[1][2]+$picks[2][1]+$picks[2][2])+$picks[1][1]+$picks[2][2]+$picks[2][3]+$picks[3][2]+$picks[3][3]+$picks[2][2]+$picks[1][1]+$picks[1][3]+$picks[3][1]+$picks[3][3])/($picks[3][3]+($picks[1][1]+$picks[1][2]+$picks[2][1]+$picks[2][2])+($picks[1][3]+$picks[2][3])+$picks[3][1]+$picks[3][2]+$picks[1][1]+($picks[2][2]+$picks[2][3]+$picks[3][2]+$picks[3][3])+$picks[1][2]+$picks[1][3]+$picks[2][1]+$picks[3][1]+$picks[2][2]+($picks[1][1]+$picks[1][3]+$picks[3][1]+$picks[3][3])+($picks[1][2]+$picks[3][2])+($picks[2][1]+$picks[2][3])))*100;
my $ta=sprintf("%.2f",$totacc); # Round % Accuracy
# False Positive Rate (the probability of falsely rejecting the null hypothesis)
my $totfpr=(1-($totspe/100))*100;
my $tfpr=sprintf("%.2f",$totfpr); # Round % FPR;
# False Negative Rate
my $totfnr=(1-($totsen/100))*100;
my $tfnr=sprintf("%.2f",$totfnr); # Round % FNR;

################################
# Stats non-genotype dependent #
###############################
# Non-reference discordance
my $nrd=((($picks[1][2]+$picks[1][3])+($picks[2][1]+$picks[2][3])+($picks[3][1]+$picks[3][2]))/(($picks[1][2]+$picks[1][3])+($picks[2][1]+$picks[2][3])+($picks[3][1]+$picks[3][2])+($picks[2][2]+$picks[3][3])))*100;
# Non-reference concordance	
my $nrc=(100-$nrd);
# R²

# Print results
print OUT "$bin\t$hetnum ($hetn%)\t$refnum ($refn%)\t$altnum ($altn%)\t$totnum ($totn%)\t$mish\t$misr\t$misa\t$mist\t$hetp\t$refp\t$altp\t$totp\t$hsen\t$rsen\t$asen\t$tsen\t$hspe\t$rspe\t$aspe\t$tspe\t$heta\t$refa\t$alta\t$ta\t$hfpr\t$rfpr\t$afpr\t$tfpr\t$hfnr\t$rfnr\t$afnr\t$tfnr\t$nrd\t$nrc\n";

close OUT;
exit;

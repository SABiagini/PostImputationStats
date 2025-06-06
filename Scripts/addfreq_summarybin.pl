#!/usr/bin/perl

# HOW2RUN: perl addfreq_summarybin.pl comparison.txt freqfile

my $input = $ARGV[0]; # File comparison.txt (output from SnpSift)
my $freq = $ARGV[1]; # Run PLINK to calculate the frequencies from each ref chromosome, then merge all freq files into one single file. That file is this second input here

open (IN, "$input") or die ("ERROR input file $input\n");
open (FREQ, "$freq") or die ("ERROR input file $freq\n");
open (OUT, ">comparison.with.freq_0.001-0.01") or die ("ERROR output file generation\n");
open (OUT2, ">comparison.with.freq_0.01-0.05") or die ("ERROR output file generation\n");
open (OUT3, ">comparison.with.freq_0.05-0.1") or die ("ERROR output file generation\n");
open (OUT4, ">comparison.with.freq_0.1-0.3") or die ("ERROR output file generation\n");
open (OUT5, ">comparison.with.freq_gt0.3") or die ("ERROR output file generation\n");
open (OUT6, ">comparison.with.freq_lt0.001") or die ("ERROR output file generation\n");
open (COMM, ">comparison.with.freq_gt0.05") or die ("ERROR output file generation\n");

my %freq;

while (my $line =<FREQ>) {
  chomp $line;
  my @split = split (/\t/,$line);
  $freq{$split[1]} = $split[4];
}
close FREQ;

while (my $line = <IN>) {
	chomp $line;
	if ($line=~ /^chr/){
		my @header=split(/\t/,$line,5);
		my $head="$header[0]\_$header[1]\_$header[2]\_$header[3]";
		print OUT "$head\tfreq\t$header[4]\n";
		print OUT2 "$head\tfreq\t$header[4]\n";
		print OUT3 "$head\tfreq\t$header[4]\n";
		print OUT4 "$head\tfreq\t$header[4]\n";
		print OUT5 "$head\tfreq\t$header[4]\n";
		print OUT6 "$head\tfreq\t$header[4]\n";
		print COMM "$head\tfreq\t$header[4]\n";
	}
	else {
		my @split=split(/\t/,$line,5);
		my $pos="$split[0]\_$split[1]\_$split[2]\_$split[3]";
		  if (exists $freq{$pos}){
		  	my $val=($freq{$pos} + 0);
		  	if ($val> 0.001 && $val <= 0.01){
  				print OUT "$pos\t$val\t$split[4]\n";
  			}
  			elsif($val> 0.01 && $val <= 0.05){
  				print OUT2 "$pos\t$val\t$split[4]\n";
  			}
  			elsif($val> 0.05 && $val <= 0.1){
  				print OUT3 "$pos\t$val\t$split[4]\n";
  				print COMM "$pos\t$val\t$split[4]\n";
  			}
  			elsif($val> 0.1 && $val <= 0.3){
  				print OUT4 "$pos\t$val\t$split[4]\n";
  				print COMM "$pos\t$val\t$split[4]\n";
  			}
  			elsif($val> 0.3){
  				print OUT5 "$pos\t$val\t$split[4]\n";
  				print COMM "$pos\t$val\t$split[4]\n";
  			}
  			elsif ($val<= 0.001){
  				print OUT6 "$pos\t$val\t$split[4]\n";
  			}
		}
		else {
			next;
		}
	}
}
close IN;
close OUT;
close OUT2;
close OUT3;
close OUT4;
close OUT5;
close OUT6;
close COMM;

my @files = glob('comparison.with.freq_*');

foreach my $f (@files){

open (BIN, "$f") or die ("ERROR input file $input\n");

my $bin=substr $f, 21;

open (OUT, ">${bin}_summary") or die ("ERROR output file generation\n");

my @sums;

while(my $line= <BIN> ) {
	chomp $line;
	if ($line=~ /^chr_pos_ref_alt/){
		my @header=split(/\t/,$line,3);
		print OUT "Maf_bin\t\t\t\t$header[2]\n";
		next;
	}
	else {
		my @summands = split(/\t/,$line);
		foreach my $i (2..$#summands) {
		$sums[$i] += $summands[$i];
		}
	}
}
$" = "\t";
print OUT "$bin\t\t@sums\n";

}
close BIN;
close OUT;

exit;

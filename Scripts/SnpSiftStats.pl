#!/usr/bin/perl

# Usage: perl SnpSiftStats.pl file.by_sample.txt

use strict;
use warnings;

# Check input
die "Usage: $0 file.by_sample.txt\n" unless @ARGV == 1;

my $input = $ARGV[0];

open(my $in_fh, '<', $input) or die "Could not open file: $input!\n";

my @picks;
my $count = 0;

while (my $line = <$in_fh>) {
    chomp $line;
    my @values = split(/\t/, $line);
    push @picks, \@values;
    $count++;
}
close $in_fh;

my $last = $count - 1;

for my $row (1 .. $last) {
    my $sample_id = $picks[$row][0];
    open(my $out_fh, '>', "$sample_id.matrix") or die "Could not write file: $sample_id.matrix\n";

    print $out_fh "Sample ID: $sample_id\n";
    print $out_fh "h/i\t0/0\t0/1\t1/1\t./.\n";
    print $out_fh "0/0\t$picks[$row][16]\t$picks[$row][17]\t$picks[$row][18]\t$picks[$row][15]\n";
    print $out_fh "0/1\t$picks[$row][21]\t$picks[$row][22]\t$picks[$row][23]\t$picks[$row][20]\n";
    print $out_fh "1/1\t$picks[$row][26]\t$picks[$row][27]\t$picks[$row][28]\t$picks[$row][25]\n";
    print $out_fh "./.\t$picks[$row][11]\t$picks[$row][12]\t$picks[$row][13]\t$picks[$row][10]\n";

    close $out_fh;
}
exit;

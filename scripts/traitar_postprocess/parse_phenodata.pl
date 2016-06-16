#!/usr/bin/perl -w
# Aroon Chande
# Parse traitar phenotype data into TSV for ML
use strict;
my (%table,@type,@genomes);
open PHENO, $ARGV[0] or die "Cannot open $ARGV[0]: $!";
my @pheno = <PHENO>;
close PHENO;
foreach (@pheno){
	my @cols = split(/\t/,$_);
	push(@type, $cols[1]) unless (grep(/$cols[1]/, @type));
	push(@genomes, $cols[0]) unless (grep(/$cols[0]/, @genomes));
	if (defined $table{$cols[0]}{$cols[1]}){next;}
	else{$table{$cols[0]}{$cols[1]} = 1;}
}
foreach my $type (@type){
	foreach (@genomes){
		if (defined $table{$_}{$type}){next;}
		else {$table{$_}{$type} =0 ;}
	}
	
	
}
open MAT, ">phenotypes.tsv" or die "Cannot open phenotypes.tsv: $!";
my $i = 0;
foreach my $key1 (keys %table){
	$i++;
	if ($i >1){next;}
foreach my $key2 (keys %{$table{$key1}}){
        print MAT "\t$key2";
}}
foreach my $key1 (keys %table){
	my $label = $key1;
	$label =~ s/\.fasta//g;
	print MAT "\n$label";
                foreach my $key2 (keys %{$table{$key1}}){
                print MAT "\t$table{$key1}{$key2}";
        }
}
close MAT;
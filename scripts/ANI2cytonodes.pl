#!/usr/bin/perl -w
# Aroon Chande 
# ANI matrix -> cytoscape nodes file
# ANI2cytonodes.pl input_matrix.tsv > output_nodes.tsv
use strict;
open TSV, $ARGV[0] or warn "Cannot open $ARGV[0]: $!";
my %values;
my @tsv = <TSV>;
close TSV;
my @cols = split(/\t/, shift @tsv);
foreach (@tsv){
	my @index = split(/\t/,$_);
	for (my $i = 1; $i < @cols; $i++){
		chomp $index[$i];
		$values{$index[0]}{$cols[$i]} = $index[$i];
		}
}
print "node1\tani\tnode2\n";
foreach my $key1 (keys %values){
	foreach my $key2 (keys %{$values{$key1}}){
		print "$key1\t$values{$key1}{$key2}\t$key2\n" unless ($values{$key1}{$key2} < 0.91);
	}
	
}


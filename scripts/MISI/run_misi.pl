#!/usr/bin/perl -w
# Aroon Chande
# Run MISI
## Microbial species delineation using whole genome sequences. Neha J. Varghese; 
## Supratim Mukherjee; Natalia Ivanova; Konstantinos T. Konstantinidis; Kostas 
## Mavrommatis; Nikos C. Kyrpides; Amrita Pati.Nucleic Acids Research 2015;doi: 
## 10.1093/nar/gkv657
use strict;
use List::Util qw( min );
my (%ani,%AF,%probref,%probreal);
open PROB, "ProbabilityTable.txt" or warn "Cannot open ProbabilityTable.txt: $!";
my @prob = <PROB>;
close PROB;
for (my $i = 7; $i < @prob; $i++){
	my @cols = split(/\t/, $prob[$i]);
	$probref{$cols[0]} = $cols[1];
}
my @files = glob("$ARGV[0]/*.fna");
for(my $i =0; $i < @files; $i++){
	for (my $j = $i +1; $j< @files; $j++){
		my ($ibase) = $files[$i] =~ m/(M\d*)/;
		my ($jbase) = $files[$j] =~ m/(M\d*)/;
		my $out = join(".",$ibase,$jbase,"out");
		if($ibase eq $jbase){next;}
		system("ANIcalculator -genome1fna $files[$i] -genome2fna $files[$j] -outfile ./outfiles/$out -outdir ./outfiles 2&> /dev/null") if ($ARGV[1] eq "calc");
		open ANI, "./outfiles/$out"  or warn "Cannot open $out: $!";
		my @values = <ANI>;
		close ANI;
		my @val = split(/\t/, $values[1]);
		chomp $val[5];
		# See paper, they're taking the min of the two ANIs and AFs
		$ani{$ibase}{$jbase} = min $val[2],$val[3];
		$ani{$jbase}{$ibase} = min $val[2],$val[3];
		$AF{$ibase}{$jbase} = min $val[4],$val[5];
		$AF{$jbase}{$ibase} = min $val[4],$val[5];

	}
}
open OUTANI, ">ani_values.out";
open OUTAF, ">af_values.out";
foreach my $key1 (keys %ani){
	foreach my $key2 (keys %{$ani{$key1}}){
		print OUTANI "$key1\t$ani{$key1}{$key2}\t$key2\n";
		print OUTAF "$key1\t$AF{$key1}{$key2}\t$key2\n";
	}
	
}
close OUTANI;close OUTAF;


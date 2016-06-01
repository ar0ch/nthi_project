#!/usr/bin/perl -w
# Aroon Chande
# Run MISI
## Microbial species delineation using whole genome sequences. Neha J. Varghese; 
## Supratim Mukherjee; Natalia Ivanova; Konstantinos T. Konstantinidis; Kostas 
## Mavrommatis; Nikos C. Kyrpides; Amrita Pati.Nucleic Acids Research 2015;doi: 
## 10.1093/nar/gkv657
my %ani1;my %ani2;my %AF1; my %AF2;
my @files = glob("$ARGV[0]/*.fna");
foreach my $i (@files){
	foreach my $j (@files){
		my ($ibase) = $i =~ m/(M\d*)/;
		my ($jbase) = $j =~ m/(M\d*)/;
		my $out = join(".",$ibase,$jbase,"out");
		if($ibase eq $jbase){$ani1{$ibase}{$jbase} = 1; $ani1{$jbase}{$ibase} = 1; next;}
		system("ANIcalculator -genome1fna $i -genome2fna $j -outfile $out");
		open ANI, $out  or warn "Cannot open $out: $!";
		my @values = <ANI>;
		close ANI;
		my ($no,$way,$val1,$val2,$val3,$val4) = split(/\t/, $values[1]);
		$ani1{$ibase}{$jbase} = (($val1+$val2)/2);
		$AF1{$ibase}{$jbase} = (($val2+$val4)/2);

	}
}
open OUTANI, ">ani_values.out";
foreach my $key1 (keys %ani1){
	foreach my $key2 (keys %{$ani1{$key1}}){
		print OUTANI "$key1\t$ani1{$key1}{$key2}\t$key2\n";
	}
	
}
close OUTANI;
open OUTAF, ">af_values.out";
foreach my $key1 (keys %AF1){
	foreach my $key2 (keys %{$AF1{$key1}}){
		print OUTAF "$key1\t$AF1{$key1}{$key2}\t$key2\n";
	}
	
}
close OUTAF;

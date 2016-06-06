#!/usr/bin/perl -w
# Aroon Chande
# Run MISI
## Microbial species delineation using whole genome sequences. Neha J. Varghese;
## Supratim Mukherjee; Natalia Ivanova; Konstantinos T. Konstantinidis; Kostas
## Mavrommatis; Nikos C. Kyrpides; Amrita Pati.Nucleic Acids Research 2015;doi:
## 10.1093/nar/gkv657
## run_misi.scaled.pl ./contigs calc
use strict;
use List::Util qw( min );
no warnings 'uninitialized';
my (%ani,%AF,%probreal);
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
                $ani{$ibase}{$jbase} = min $val[2],$val[3];
                $ani{$jbase}{$ibase} = min $val[2],$val[3];
                $AF{$ibase}{$jbase} = min $val[4],$val[5];
                $AF{$jbase}{$ibase} = min $val[4],$val[5];
                $probreal{$ibase}{$jbase} =  $ani{$ibase}{$jbase} * $AF{$ibase}{$jbase};
                $probreal{$jbase}{$ibase} =  ($ani{$ibase}{$jbase} * $AF{$ibase}{$jbase})/100;
        }
}
foreach my $key1 (keys %ani){
        foreach my $key2 (keys %{$ani{$key1}}){
                print "$key1\t$key2\t$ani{$key1}{$key2}\t$AF{$key1}{$key2}\t$probreal{$key1}{$key2}\n";
        }

}
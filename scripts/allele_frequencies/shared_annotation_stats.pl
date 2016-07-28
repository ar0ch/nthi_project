#!/usr/bin/perl -w
# Aroon Chande
# Compare two GFF files, return PEGs IDs for matched annotation
# ./shared_annotation.pl -gff $PWD/GFF -faa $VCHODATA/proteins -o $PWD/shared_stats
###############################################################################
### Compare GFF files in pairwise (no self), fine PEGs with same annotation ###
### Assumes RAST formated GFF and FAA files									###
### Example GFF																###
##gff-version 3
#NODE_100_length_699_cov_481.222_ID_199  FIG     CDS     107     352     .       +       2       ID=fig|666.1887.peg.1;Name=CcdA protein (antitoxin to CcdB)
#NODE_100_length_699_cov_481.222_ID_199  FIG     CDS     352     669     .       +       1       ID=fig|666.1887.peg.2;Name=CcdB toxin protein
#NODE_105_length_679_cov_396.17_ID_209   FIG     CDS     52      534     .       -       1       ID=fig|666.1887.peg.3;Name=spermidine N1-acetyltransferase
#NODE_107_length_668_cov_2.72757_ID_213  FIG     CDS     189     566     .       -       0       ID=fig|666.1887.peg.4;Name=Arylsulfatase (EC3.1.6.1);Ontology_term=KEGG_ENZYME:3.1.6.1
### With matching FAA file headers											###
#>fig|666.1887.peg.1														###
#>fig|666.1887.peg.2														###	
#>fig|666.1887.peg.3														###
#>fig|666.1887.peg.4														###
###############################################################################
use strict;
use File::Basename;
use File::Temp;
use Getopt::Long;
use Parallel::ForkManager;
# Setting some shell ENV variables and a placeholder var for the GNUplot commands later
$ENV{1} = '\$1';
my $rep = '$1';
my $threads = 12;
my (@gff1,%gff1,@gff2,%gff2,$gffDir,$outDir,$faaDir,$help,%records,$prots,@prots,%prots,%stats);
GetOptions ('h' => \$help, 'o=s' => \$outDir, 'gff=s' => \$gffDir, 'faa=s' => \$faaDir, 't=i' => \$threads);
my @gffFiles= glob ( "$gffDir/*.gff" );
my @faaFiles = glob("$faaDir/*.faa");
# Var checking
die "Missing stuff\nOut directory:\t$outDir\nGFF directory:\t$gffDir\nFAA directory:\t$faaDir\n" unless ((defined $outDir) && (defined $gffDir) && (defined $faaDir));
if (scalar @gffFiles gt scalar @faaFiles){
	print "The number of GFF is greater than faa files, cannot continue\n";exit 1;
}
foreach (@gffFiles){
	my $base = basename($_);
	$base =~ s/\.gff//g;
	my $fasta = join("",$faaDir,"/",$base,".faa");
	die "$_ does not have a matching fasta file\n" unless -f $fasta;
}
system("mkdir -p $outDir $outDir/shared $outDir/stats $outDir/tmp");
my $manager = Parallel::ForkManager -> new ( $threads );

print STDERR "Finding shared annotations from GFF files\n";
for(my $i =0; $i < @gffFiles; $i++){
	for(my $j =$i+1; $j < @gffFiles; $j++){
	my $outFile = join(".",basename($gffFiles[$i]),basename($gffFiles[$j]),"out");
		$outFile =~ s/\.gff//g;
		open GFF1, $gffFiles[$i];
		open GFF2, $gffFiles[$j];
		@gff1 = <GFF1>;
		@gff2 = <GFF2>;
		close GFF1;
		close GFF2;
		shift @gff1; # pesky headers
		shift @gff2; # pesky headers
		foreach (@gff1){
			my @cols = split(/\t/,$_);
			my ($value,$key) = split(/;/,$cols[8]);
			$value =~ s/ID\=//g;
			$key =~ s/Name\=//g;
			if ($key eq 'hypothetical protein'){next;}
			elsif($key eq 'conserved hypothetical protein'){next;}
			$gff1{$key} = $value;
		}
		foreach (@gff2){
			my @cols = split(/\t/,$_);
			my ($value,$key) = split(/;/,$cols[8]);
			$value =~ s/ID\=//g;
			$key =~ s/Name\=//g;
			chomp $key;
			$gff2{$key} = $value;
		}
		open OUT, ">$outDir/shared/$outFile";
		foreach my $keys1(keys %gff1){
			if (exists $gff2{$keys1}){
				print OUT "$gff1{$keys1}\t$gff2{$keys1}\n";
			}
		}
	}
}

###############################################################################
# Read shared PEGs from FASTA file and run water alignment for identity calc
# Load protein file
print STDERR "Loading protein sequences\n[";
foreach (@gffFiles){
	my $key = basename($_);
	$key =~ s/\.gff//g;
	open PROT, "<$faaDir/$key.faa" or die "Cannot open $faaDir/$key.faa: $!\n";
	foreach (<PROT>){
		$prots .= $_;
	}
	close PROT;
	@prots = split(/\>/,$prots);
	shift @prots;
	foreach (@prots){
		my($desc, $seq) = split(/\r?\n/,$_,2);
		$seq =~ s/\*[^ACDEFGHIJKLMNPQRSTVWY]//g; # Lazy sequence finding 
		$prots{$key}{$desc} = $seq;
	}
	print STDERR ".";
}
open OUT, ">$outDir/stats.txt";
# Prase through shared annotation files generated above
print STDERR "]\nComputing identities between shared annotations\n[";
my @toParse = glob("$outDir/shared/*");
no warnings 'uninitialized'; # Because checking each fasta file is more effort than its worth
foreach my $file (@toParse){
	my $key = basename($file);
	$key =~ s/\.out//g;
	open SHARED, $file or die "Cannot open $file: $!\n";
# key1a/2a are the strain/file name	
	my($key1a,$key2a,undef) = split(/\./,basename($file));
	my $out = basename($file);
	my $i = 0;
	print STDERR ".";
	foreach my $shared (<SHARED>){
		$manager->start and next;
		chomp $shared;
# key1b/2b is the shared annotation	
		my ($key1b,$key2b) = split(/\t/,$shared);
		my $temp1 = temp_filename();
		my $temp2 = temp_filename();
		my $water = temp_filename();
		open T1, ">$temp1" or die "Cannot open $temp1: $!\n";
		open T2, ">$temp2" or die "Cannot open $temp2: $!\n";
		print T1 "$prots{$key1a}{$key1b}";
		print T2 "$prots{$key2a}{$key2b}";
		close T1;
		close T2;
		system(`water -asequence $temp1 -bsequence $temp2 -datafile EBLOSUM60 -gapopen 10 -gapextend 0.5 -outfile  $water -nobrief > /dev/null 2>&1`);
		my $id = `head -26 $water | tail -1`;
		chomp $id;
		$id =~ s/.*\(//;
		$id =~ s/%.*//;
		$stats{$key}{$i} = $id;
		print OUT "$id\n";
		$i++;
		$manager->finish;
}
$manager->wait_all_children;
}
close OUT;
print STDERR "]\nPlotting identities\n[";
foreach my $key1 (keys %stats){
	my @data = ( );
	open OUT, ">$outDir/stats/$key1.stats.txt" or die "Cannot open $outDir/stats/$key1.stats.txt: $!\n";
	foreach my $key2 (keys %{$stats{$key1}}){
    	print OUT "$stats{$key1}{$key2}\n";
		push(@data,$stats{$key1}{$key2})
	}
	system(`echo "set terminal png\nset output '$outDir/stats/$key1.png'\nbinwidth = 5\nset boxwidth binwidth\nbin(x,width)=width*floor(x/width)\nplot '$outDir/stats/$key1.stats.txt' using (bin(\\$rep,binwidth)):(1.0) smooth freq with boxes notitle" > $outDir/stats/plot.plt`);
	system(`gnuplot $outDir/stats/plot_skel.plt`);
	close OUT;
	print STDERR ".";
}
print "]\n";
system("rm -rf $outDir/tmp");
###############################################################################
sub temp_filename{
            my $file = File::Temp->new(
                TEMPLATE => 'tempXXXXX',
                DIR      => "$outDir/tmp/",
            );
}






#!/usr/bin/perl -w
# Aroon Chande
# RAST GFF3 to gbrowse compat GFF3
# Replace ID with fig ID from Dbxref ID
use strict;
my $file = $ARGV[0];
open GFF, $file;
my @gff = <GFF>;
close GFF;
print shift @gff;
$file =~ s/\.gff\.sorted//g;
foreach my $line (@gff){
	my @cols = split(/\t/, $line);
	if ($cols[2] eq 'region'){ $,="\t";print @cols;next;}
	elsif ($cols[2] eq 'exon'){next;}
	elsif ($cols[2] eq 'CDS'){	
	my @meta = split(/;/, $cols[8]);
	my $xref = $meta[1];
	if($meta[1] =~ 'Alias'){$xref = $meta[2];}
	($xref) = $xref =~ m/(peg.\d*)/;
	$xref = join(".",$file,$xref);
	$meta[0] = join("","ID=",$xref);
	if($meta[1] =~ 'Alias'){$meta[3] = join("",'Name="',$xref,'"');}
	else{$meta[2] = join("",'Name="',$xref,'"');}
	$cols[0] = $xref;
	$cols[8] = join(";",@meta);
	$, = "\t";
	print @cols;}
	elsif ($cols[2] =~ 'RNA'){	
	my @meta = split(/;/, $cols[8]);
	my $xref = $meta[1];
	if($meta[1] =~ 'Alias'){$xref = $meta[2];}
	($xref) = $xref =~ m/(rna.\d*)/;
	$xref = join(".",$file,$xref);
	$meta[0] = join("","ID=",$xref);
	if($meta[1] =~ 'Alias'){$meta[3] = join("",'Name="',$xref,'"');}
	else{$meta[2] = join("",'Name="',$xref,'"');}
	$cols[0] = $xref;
	$cols[8] = join(";",@meta);
	$, = "\t";
	print @cols;}
}


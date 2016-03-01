#! /usr/bin/perl

#*--<<Definision>>-----------------------------------------*
#PGID        call_snp_from_pileup.pl
#Kind of PG   Main PG
#Create Date  2010/07/28
#
#	Detect SNPs 
#		
#   Comandline  pileup file
#               Consensus quality
#               SNP quality
#               Maximum mapping quality
#               read coverage
#               Select hets, homs or both
#		output text file
#*---------------------------------------------------------*
#***********************************************************
# use
#***********************************************************
use strict;
#***********************************************************
# constant
#***********************************************************
#***********************************************************
# variable
#***********************************************************
my $line;
my $pileup;
my $output;
my @data;
my $consensus;
my $snp;
my $map;
my $coverage;
my $hets_homs_both;
#***********************************************************
# Main Coading
#***********************************************************
$pileup	   = $ARGV[0];
$consensus = $ARGV[1];
$snp       = $ARGV[2];
$map       = $ARGV[3];
$coverage  = $ARGV[4];
$hets_homs_both = $ARGV[5];
$output	        = $ARGV[6];

print "$pileup\n";
print "$consensus\n";
print "$snp\n";
print "$map\n";
print "$coverage\n";
print "$hets_homs_both\n";
print "$output\n";



open (OUTPUT,    ">$output");

open (PILEUP,    "<$pileup")      or die "$pileup : No such file or directory\n";
while($line = <PILEUP>){
	@data = split /\t/, $line;
	if( $data[2] ne "*"
	and $data[2] ne "n"
	and $data[2] ne "N"
	and $data[3] ne "n"
	and $data[3] ne "N"
	and $data[2] ne $data[3]){
		if( $data[4] >= $consensus
		and $data[5] >= $snp
		and $data[6] >= $map
		and $data[7] >= $coverage){
			if($hets_homs_both eq "both"){  
				print OUTPUT "$line";
			}else{
				if($hets_homs_both eq "homs"){
					if($data[3] =~ /A|T|G|C|a|t|g|c/){
						print OUTPUT "$line";
					}					
				}else{
					if($data[3] !~ /A|T|G|C|a|t|g|c/){
						print OUTPUT "$line";
					}
				}
			}
		}
	}
}
close PILEUP;
close OUTPUT;

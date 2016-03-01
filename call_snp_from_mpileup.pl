#!/usr/bin/perl

#use warnings;
#use strict;

my $input_file      = $ARGV[0];
my $depth           = $ARGV[1];
my $mq              = $ARGV[2];
my $het_hom_both    = $ARGV[3];
my $gq              = $ARGV[4];
my $output_file     = $ARGV[5];

#print "$input_file\n";
#print "$depth\n";
#print "$mq\n";
#print "$het_hom_both\n";
#print "$gq\n";
#print "$output_file\n";

### call other accessions
open (IN, "< $input_file") or "die cannot open $input_file\n";
open (OUT, "> $output_file") or "die cannot open $output_file\n";

my $homo_snp_cnt = 0;
my $hetero_snp_cnt = 0;

while (my $l = <IN>) {
	chomp $l;

	if($l =~ /^#/){
		print OUT "$l\n";
		next;
	}
	my @ls = split /\t/, $l;
	my $genotype_ref    = $ls[3];
	my $genotype_target = $ls[4];
#	if( length($genotype_ref) > 1 or length($genotype_target) > 1){
#		next;
#	}

	my $chr      = $ls[0];
	my $position = $ls[1];
	my $filter   = $ls[7];

	if ($genotype_ref eq "n"
	or  $genotype_ref eq "N"
	or  $genotype_target eq "N"
	or  $genotype_target eq "n"){
		if($genotype_japonica eq "N" or $genotype_target eq "n"){
#			print "$position:$genotype_japonica:$genotype_target\n";
		}
		next;
	}

	if ( $genotype_ref ne $genotype_target
	and  $filter !~ /^INDEL/ ){
		my @tag = split /;/, $filter;

		my $data_depth;
		my $data_mq;
		my $data_fq;
		foreach my $tag_data (@tag){
			my @tag_data_tmp = split /=/, $tag_data;
			if( $tag_data_tmp[0] eq "DP"){
				$data_depth = $tag_data_tmp[1];
			}
			if( $tag_data_tmp[0] eq "MQ"){
				$data_mq    = $tag_data_tmp[1];
			}
#			if( $tag_data_tmp[0] eq "FQ"){
#				$data_fq    = $tag_data_tmp[1];
#			}
		}
		if($data_depth < $depth
		or $data_mq    < $mq ){
			next;
		}


		my @gt = split /:/, $ls[9];
		if($gt[2] < $gq){
			next;
		}

		if($gt[0] eq "1\/1"
		and $ls[4] !~ /,/){
			if($het_hom_both eq "both"
			or $het_hom_both eq "homs"){
				print OUT "$l\n";
			}
			$homo_snp_cnt++;
			$total_snp_cnt++;
		}elsif($gt[0] eq "0\/1"){
			if($het_hom_both eq "both"
			or $het_hom_both eq "hets"){
				print OUT "$l\n";
			}
			$hetero_snp_cnt++;
			$total_snp_cnt++;
		}elsif($gt[0] eq "1\/1"
		and $ls[4] =~ /,/){
			if($het_hom_both eq "both"
			or $het_hom_both eq "hets"){
				print OUT "$l\n";
			}
			$hetero_snp_cnt++;
			$hetero_snp_cnt++;
			$total_snp_cnt++;
			$total_snp_cnt++;
		}

#		if($data_fq < 0){
#			my $data_fq_tmp = $data_fq * -1;
#			if($data_fq_tmp < $fq){
#				next;
#			}
#		}else{
#			if($data_fq < $fq){
#				next;
#			}
#		}

#		if($het_hom_both eq "both"){
#			print OUT "$l\n";
#		}elsif($het_hom_both eq "homs"){
#			if($data_fq < 0){
#				print OUT "$l\n";
#			}
#		}else{
#			if($data_fq > 0){
#				print OUT "$l\n";
#			}
#		}


#		if( $data_fq < 0){
#			$homo_snp_cnt++;
#		}elsif($data_fq > 0){
#			$hetero_snp_cnt++;
#		}


	}
}
close IN;
close OUT;

if($het_hom_both eq "homs"){
	print "homoSNPs:$homo_snp_cnt\n";
}

if($het_hom_both eq "hets"){
	print "heteroSNPs:$hetero_snp_cnt\n";
}

if($het_hom_both eq "both"){
	print "homoSNPs:$homo_snp_cnt\n";
	print "heteroSNPs:$hetero_snp_cnt\n";
	print "totalSNPs:$total_snp_cnt\n";
	my $hetero_rate = $hetero_snp_cnt / ($hetero_snp_cnt + $homo_snp_cnt) * 100;
	print "hetero rate:$hetero_rate";
}


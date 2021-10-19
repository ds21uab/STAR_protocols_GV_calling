#!/bin/bash
date +"%d %B %Y %H:%M:%S"

## what this script will do: remove header section from the VCF file
## where to run this script: run this script where indexed_pass_filtered_variants are located

# processing each VCF file using for loop
for myfile in *.vcf
do
	echo "processing" $myfile
	samplename="${myfile%.*}.no_header.vcf"
	awk '! /\##/' $myfile > $samplename
done

date +"%d %B %Y %H:%M:%S"


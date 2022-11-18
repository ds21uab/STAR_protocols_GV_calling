#!/bin/bash
date +"%d %B %Y %H:%M:%S"

#############################################################################################################################################
## #Copywrite Divya Sahu, 2021

## NOTE:
## what this script will do: index VCF files and then extract PASS varients from the indexed VCF files
## where to run this script: run this script from the folder where VCFs are located
## this script requires: output path for PASS_variants. The default output for this step is within the following directory: /STAR_protocols_GV_calling/analysis/PASS_variants/
## create separate directory for wxs-normal samples, wxs-tumor samples and rnaseq-tumor samples within PASS_variants directory; set the output path accordingly.
## bcftools should be loaded to the system path
# the path for out_VCF is set for wxs-normal. User needs to set path accordingly.
#############################################################################################################################################


# load modules
#module load bcftools


# set output path
out_VCF="$protocol_dir/STAR_protocols_GV_calling/analysis/PASS_variants/wxs-normal"

# processing each VCF file
for myfile in *.vcf
do
	echo "processing" $myfile
	indexedVCF="${myfile%.*}.tbi_index.vcf.gz"
	samplename="${indexedVCF%%_*}.pass.vcf"
	bgzip -c $myfile > $indexedVCF
	tabix -fp vcf $indexedVCF
	bcftools view -f PASS $indexedVCF > $out_VCF/$samplename
done

#module purge
date +"%d %B %Y %H:%M:%S"

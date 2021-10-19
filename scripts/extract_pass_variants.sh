#!/bin/bash
date +"%d %B %Y %H:%M:%S"

## what this script will do: index VCF files and then extract PASS varients from the indexed VCF files
## where to run this script: run this script in the folder where VCF files from VarDict are located
## this script requires: output directory where indexed_pass_filtered_variants will be stored and bcftools should be loaded to the system path

# load modules
module load bcftools



# output directory 
# create separate directory for normal-WXS, tumor-WXS and tumor-RNAseq
out_VCF="/pathToSave/filtered_variants/normal-WXS/"

# processing each VCF files using for loop
for myfile in *.vcf
do
	echo "processing" $myfile
	indexedVCF="${myfile%.*}.tbi_index.vcf.gz"
	samplename="${indexedVCF%%.*}.pass.vcf"
	bgzip -c $myfile > $indexedVCF
	tabix -fp vcf $indexedVCF
	bcftools view -f PASS $indexedVCF > $out_VCF/$samplename
done

module purge
date +"%d %B %Y %H:%M:%S"

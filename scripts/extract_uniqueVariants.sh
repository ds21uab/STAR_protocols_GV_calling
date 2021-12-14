#!/bin/bash

#Copywrite Divya Sahu, 2021

## what this script will do: extract variants from all the passed variants VCF files, and then remove duplicated variants
## where to run this script: from the folder where VCF files without header are located
## this script requires: R should be loaded in the system path
## output files: unique_variants.txt # rename the file when processing data types: ex: unique_variants_wxs-normal.txt; unique_variants_wxs-tumor.txt; unique_variants_tumor-rnaseq.txt

date +"%d %B %Y %H:%M:%S"

# total variants from all VCFs
awk -F ' ' '{print $1"\t"$2"\t"$4"\t"$5}' *.no_header.vcf > allVCF_variants.txt
cat allVCF_variants.txt | sed "s/#CHROM//g" | sed "s/POS//g" | sed "s/REF//g"| sed "s/ALT//g"| sed -r '/^\s*$/d' > variant_chr_pos_ref_alt.txt

# load modules
#module load goolf/7.1.0_3.1.4  R/4.0.0

#source STAR_protocols_GV_calling directory
source ~/.bash_profile

# run R script
Rscript $protocol_dir/STAR_protocols_GV_calling/scripts/extract_uniqueVariants.R

#module purge
date +"%d %B %Y %H:%M:%S"

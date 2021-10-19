#!/bin/bash



## what this script will do: extract variants from all VCF files and then remove duplicated variants
## where to run this script: in the folder where VCF files without header are loacted
## this script requires: R should be loaded in the system path
## output files: unique_variants.txt # rename the file when processing data types: ex: unique_variants_normal.txt; unique_variants_tumor.txt; unique_variants_rnaseq.txt

date +"%d %B %Y %H:%M:%S"

awk -F ' ' '{print $1"\t"$2}' *.no_header.vcf > allVCF_variants.txt
cat allVCF_variants.txt | sed "s/#CHROM//g" | sed "s/POS//g" | sed -r '/^\s*$/d' > variants_chromosome_position.txt

# load modules
module load goolf/7.1.0_3.1.4  R/4.0.0

# run R script
Rscript extract_uniqueVariants.R

module purge
date +"%d %B %Y %H:%M:%S"

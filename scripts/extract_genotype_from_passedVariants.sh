#!/bin/bash

## what this script will do:extract mutation status, depth, variant depth and other info of each variant for each sample
## where to run this script: run this script in the folder where PAAS variants VCFs are located
## this script requires: create a directory mutation_status in the PASS variants folder and bcftools should be loaded to the system path 

date +"%d %B %Y %H:%M:%S"

# load modules
module load bcftools

# processing each VCF files using for loop
for myfile in *pass.vcf
do
  	echo "processing" $myfile
        samplename="${myfile%.*}.genotype.txt"
        bcftools query -f '%SAMPLE %CHROM %POS %REF %ALT %TYPE %DP %VD %AF %MQ [\t%GT] \n' $myfile  >  mutation_status/$samplename
        cd mutation_status
        sed -i '1i SAMPLE CHROM POS REF ALT TYPE DP VD AF MQ GT' $samplename
        cd ..
done

module purge
date +"%d %B %Y %H:%M:%S"

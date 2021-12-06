#!/bin/bash

##Copywrite Divya Sahu, 2021

## what this script will do:extract mutation status, depth, variant depth and other info of each variant for each sample
## where to run this script: run this script in the folder where PAAS variants VCFs are located
## this script requires: The path for out_VCF is set for wxs-normal. User needs to set path accordingly.
#  bcftools should be loaded to the system path 

date +"%d %B %Y %H:%M:%S"

# load modules
module load bcftools

#source STAR_protocols_GV_calling directory
source ~/.bash_profile

# output path to store genotype_status. Set path for each data type accordingly
out_VCF="$protocol_dir/STAR_protocols_GV_calling/analysis/genotype_status/wxs-normal/"

# processing each VCF files using for loop
for myfile in *pass.vcf
do
  	echo "processing" $myfile
        samplename="${myfile%.*}.genotype.txt"
        bcftools query -f '%SAMPLE %CHROM %POS %REF %ALT %TYPE %DP %VD %AF %MQ [\t%GT] \n' $myfile  >  $out_VCF/$samplename
done

#add column names
cd $out_VCF
sed -i '1i SAMPLE CHROM POS REF ALT TYPE DP VD AF MQ GT' *.pass.genotype.txt

#unload modules
module purge
date +"%d %B %Y %H:%M:%S"

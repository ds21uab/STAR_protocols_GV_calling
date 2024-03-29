#!/bin/bash

####################################################################################################################################################################################################################################
#Copywrite Divya Sahu, 2021
## Clone the github repository: uncomment the code and paste it in the command line 
# git clone https://github.com/ds21uab/STAR_protocols_GV_calling.git
## Save path for the ‘STAR_protocols_GV_calling’ directory in a local or online Linux cluster. For example, 
## if the ‘STAR_protocols_GV_calling’ directory is in the current working directory then save its path using the following command
# nano ~/.bash_profile
# export protocol_dir="/path_to_current_working_directory"
# source ~/.bash_profile
####################################################################################################################################################################################################################################


#############################################################################################################################################
## what this script will do: variant calling on BAM file. 
## requirements: output directory path; VarDictJava, R and samtools should be loaded in the system path
## input files: reference genome in FASTA format, gene annotation BED file, input.list with location of folders that contain BAM files
## output directory: create directory wxs-normal, wxs-tumor and rnaseq-tumor inside the VCFs_from_VarDict directory
## output files: VCF file
## the path for input.list and out_VCFs in this script is set for wxs-normal. User need to set the path accordingly.
## User needs to load relevant modules and its version number available on their online linux cluster.
#############################################################################################################################################

date +"%d %B %Y %H:%M:%S"

# number of CPUs per task
#export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# load modules
#module load goolf/7.1.0_3.1.4 R
#module load samtools/1.12

#source STAR_protocols_GV_calling directory
#source ~/.bash_profile

# need input list
input_list="$protocol_dir/STAR_protocols_GV_calling/data/BAM/wxs-normal/wxs-normal_input.list"
OPTS=$(sed -n "$SLURM_ARRAY_TASK_ID"p "$input_list")

# path for reference genome fasta and bed files
hg_fasta="$protocol_dir/STAR_protocols_GV_calling/data/reference_data/HSapiens/hg38/GRCh38.d1.vd1.fa"
exome_bed="$protocol_dir/STAR_protocols_GV_calling/data/reference_data/HSapiens/hg38/gencode.v37.gene.annotation.bed"

# set output directory
out_VCF="$protocol_dir/STAR_protocols_GV_calling/analysis/VCFs_from_VarDict/wxs-normal"

# processing BAM file
echo "reading BAM files in: $OPTS"
cd $(echo $OPTS | tr -d '\r')
bam=$(find . -type f -name *.bam)
echo "processing" $bam
samplename="${bam%.*}"

# run VarDict
VarDict -G $hg_fasta \
-f 0.05 \
-b $bam \
-r 3 -Q 30 -q 25 -t \
--nosv \
-N $samplename -c 1 -S 2 -E 3 -g 4 $exome_bed | teststrandbias.R | var2vcf_valid.pl -N $samplename -E -f 0.05 -d 10 -v 3 > $out_VCF/$samplename.vcf

# message when task is completed
echo "processed" $bam

# unload modules
#module purge
date +"%d %B %Y %H:%M:%S"

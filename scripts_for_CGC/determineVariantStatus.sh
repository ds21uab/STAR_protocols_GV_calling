#!/bin/bash


#############################################################################################################################################
# Copywrite Divya Sahu, 2021
## what this script will do: merge sequencing coverage file and genotype status file of each sample
## where to run this script: create separate folder for wxs-normal, wxs-tumor and rnaseq-tumor inside variant_status; run script separately for each data type
## requirements: R should be loaded in the system path, R package tidyverse and readr should be installed
## input files: tab separated file with information of each Sample_barcode and its corresponding genotype_file, samdepth_file and out_filename
## output files: mutation status for union variants for each sample
##
#############################################################################################################################################

date +"%d %B %Y %H:%M:%S"

# number of cpus per task
#export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# unload modules
#module purge

# load modules
#module load goolf/7.1.0_3.1.4  R/4.0.0

# source STAR_protocols_GV_calling directory
#source ~/.bash_profile

# R script
Rscript $protocol_dir/STAR_protocols_GV_calling/scripts/determineVariantStatus.R $SLURM_ARRAY_TASK_ID

# unload modules
#module purge
date +"%d %B %Y %H:%M:%S"

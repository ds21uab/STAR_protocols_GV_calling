#!/bin/bash
#SBATCH -N 1      
#SBATCH -n 1
#SBATCH --mem=375Gb # memory to run the job
#SBATCH -t 5:00:00  # time to finish the job
#SBATCH --partition=partition # cluster partition we will use run the job; change this with your cluster env
#SBATCH -A account             #the account/ allocation to use
#SBATCH -e slurm-%j.err 
#SBATCH --output slurm-%j.out

#Copywrite Divya Sahu, 2021

## what this script will do: merge GT_samdepth_merged.txt file for each sample to create a large .txt file, which store mutation status from all samples
## this script requires: R should be loaded in the system path; need input path and output path.
## output files: combined_variants.txt # you can also rename the file for each data types: ex: combined_variants_wxs-normal.txt; combined_variants_wxs-tumor.txt; combined_variants_rnaseq-tumor.txt

date +"%d %B %Y %H:%M:%S"

# unload modules
module purge

# load modules
module load goolf/7.1.0_3.1.4  R/4.0.0

#source STAR_protocols_GV_calling directory
source ~/.bash_profile

# R script
Rscript $protocol_dir/STAR_protocols_GV_calling/scripts/combineAllSamplesVariantStatus.R $SLURM_ARRAY_TASK_ID

# unload modules
module purge

date +"%d %B %Y %H:%M:%S"


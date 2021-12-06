#!/bin/bash
#SBATCH -N 1
#SBATCH -n 1
#SBATCH --cpus-per-task=2 # number of CPUS per task  
#SBATCH --mem=500Gb # memory to run the job
#SBATCH -t 1:00:00  # time to finish the job
#SBATCH --partition=partition # cluster partition we will use run the job; change this with your cluster env
#SBATCH -A account             #the account/ allocation to use
#SBATCH -e slurm-%j.err 
#SBATCH --output slurm-%j.out
#SBATCH --array=1-10 #submit a job array with index values betwen 1 and 10 #change with number of files to be processed 

#Copywrite Divya Sahu, 2021

## what this script will do: process combined variants table for all samples and give a clean table with sample and mutation status of each variant
## where to run this script: from the folder where input.list is stored
## this script requires: R should be loaded in the system path; need combinedVariantsFromAllSamples.txt and output path. See processCombinedVariants.R for details
## output files: processed_CombinedVariantsAllSamples.txt # you can also rename the file for each data types: ex: processed_CombinedVariantsAllSamples_wxs-normal.txt; processed_CombinedVariantsAllSamples_wxs-tumor.txt; processed_CombinedVariantsAllSamples_rnaseq-tumor.txt

##########################################################################################################################

date +"%d %B %Y %H:%M:%S"

# number of cpus per task
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# unload modules
module purge

# load modules
module load goolf/7.1.0_3.1.4  R/4.0.0
#module load R # use the latest version of R

# source STAR_protocols_GV_calling directory
source ~/.bash_profile

# need input list
input_list="input.list"
OPTS=$(sed -n "$SLURM_ARRAY_TASK_ID"p "$input_list")

# run R script
Rscript $protocol_dir/STAR_protocols_GV_calling/scripts/processCombinedVariants.R $OPTS

# unload modules
module purge

date +"%d %B %Y %H:%M:%S"

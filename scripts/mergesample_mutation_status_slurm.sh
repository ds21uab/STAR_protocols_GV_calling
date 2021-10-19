#!/bin/bash
#SBATCH -N 1      
#SBATCH -n 1
#SBATCH --mem=375Gb # memory to run the job
#SBATCH -t 5:00:00  # time to finish the job
#SBATCH --partition=largemem # cluster partition we will use run the job; change this with your cluster env
#SBATCH -e slurm-%j.err 
#SBATCH --output slurm-%j.out

## what this script will do: merge GT_samdepth_merged.txt file for each sample to create a large .txt file, which store mutation status from all samples
## where to run this script: the folder where all script are stored
## this script requires: R should be loaded in the system path; need input path and output path. See mergesample_mutation_status.R for details
## output files: combined_variants.txt # you can also rename the file for each data types: ex: combined_variants_normal.txt; combined_variants_tumor.txt; combined_variants_rnaseq.txt

date +"%d %B %Y %H:%M:%S"

# unload modules
module purge

# load modules
module load R # use the latest version of R

# run R script
Rscript mergesample_mutation_status.R

# unload modules
module purge

date +"%d %B %Y %H:%M:%S"


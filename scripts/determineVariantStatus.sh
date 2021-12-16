#!/bin/bash
#SBATCH -N 1                    #total number of nodes for the job
#SBATCH --cpus-per-task=5       #number of CPUS per task       
#SBATCH --mem=100Gb            #total memory per node in MB
#SBATCH -t 00:05:00             #amount of time for the whole job
#SBATCH --partition=partition    #the queue /partition to run on
#SBATCH -A account             #the account/ allocation to use
#SBATCH -e slurm-%j.err
#SBATCH --output slurm-%j.out
#SBATCH --array=1-5 #submit a job array with index values betwen 1 and 5 #Replace 5 with the number number of jobs to be processed. For example: user can check the total jobs in the input.list


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
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# unload modules
#module purge

# load modules
#module load goolf/7.1.0_3.1.4  R/4.0.0

# source STAR_protocols_GV_calling directory
source ~/.bash_profile

# R script
Rscript $protocol_dir/STAR_protocols_GV_calling/scripts/determineVariantStatus.R $SLURM_ARRAY_TASK_ID

# unload modules
#module purge
date +"%d %B %Y %H:%M:%S"

#!/bin/bash
#SBATCH -N 1                    #total number of nodes for the job
#SBATCH --cpus-per-task=5       #number of CPUS per task       
#SBATCH --mem=100000            #total memory per node in MB
#SBATCH -t 3:00:00             #amount of time for the whole job
#SBATCH --partition=short    #the queue /partition to run on
#SBATCH -e slurm-%j.err
#SBATCH --output slurm-%j.out
#SBATCH --array=1-5 #submit a job array with index values betwen 1 and 512 # change with number of files to be processed

# modify the above slurm commands with the cluster environment you are running
# change partition type and account information

#############################################################################################################################################
##
## what this script will do: merge samdepth and genotype status
## where to run this script: create separate folder for wxs-normal, wxs-tumor and rnaseq-tumor; run script separately for each data type
## requirements: R should be loaded in the system path, R package tidyverse and readr should be installed
## input files: tab separated file with information of each Sample_barcode and its corresponding genotype_file, samdepth_file and out_filename
## output files: mutation status for union variants for each sample
##
#############################################################################################################################################

date +"%d %B %Y %H:%M:%S"

# number of cpus per task
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# unload modules
module purge

# load modules
module load shared rc-base
module load R/4.1.0-foss-2018a-X11-20180131-bare

# R script should be in the same folder
Rscript calculateMutStatusAndMergeSamdepth.R $SLURM_ARRAY_TASK_ID

# unload modules
module purge
date +"%d %B %Y %H:%M:%S"

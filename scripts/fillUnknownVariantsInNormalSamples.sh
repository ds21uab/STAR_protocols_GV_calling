#!/bin/bash
#SBATCH -N 1                    # total number of nodes for the job
#SBATCH --cpus-per-task=5       # number of CPUS per task       
#SBATCH --mem=300000            # total memory per node in MB
#SBATCH -t 12:00:00             # time for the finish the job
#SBATCH --partition=partition    # cluster partition we will use run the job; change this with your cluster env
#SBATCH -e slurm-%j.err
#SBATCH --output slurm-%j.out


##Copywrite Divya Sahu, 2021

date +"%d %B %Y %H:%M:%S"

# number of cpus per task
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# unload modules
module purge

# load modules
module load goolf/7.1.0_3.1.4  R/4.0.0

# source STAR_protocols_GV_calling directory
source ~/.bash_profile

# run Rscript
Rscript $protocol_dir/STAR_protocols_GV_calling/scripts/fillUnknownVariantsInNormalSamples.R

# unload modules
module purge

date +"%d %B %Y %H:%M:%S"

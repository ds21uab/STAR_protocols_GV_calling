#!/bin/bash
#SBATCH -N 1                    # total number of nodes for the job
#SBATCH --cpus-per-task=5       # number of CPUS per task       
#SBATCH --mem=300000            # total memory per node in MB
#SBATCH -t 12:00:00             # time for the finish the job
#SBATCH --partition=largemem    # cluster partition we will use run the job; change this with your cluster env
#SBATCH -e slurm-%j.err
#SBATCH --output slurm-%j.out


date +"%d %B %Y %H:%M:%S"

# number of cpus per task
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# unload modules
module purge

# load modules
module load R

# here change the Rscript accordingly for normal-wxs, tumor-wxs, tumor-rnaseq
Rscript fillUnknownVariantInNormal_mapply.R

date +"%d %B %Y %H:%M:%S"

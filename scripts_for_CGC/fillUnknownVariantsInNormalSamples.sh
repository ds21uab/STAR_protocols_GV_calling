#!/bin/bash


##Copywrite Divya Sahu, 2021

date +"%d %B %Y %H:%M:%S"

# number of cpus per task
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# unload modules
#module purge

# load modules
#module load goolf/7.1.0_3.1.4  R/4.0.0

# source STAR_protocols_GV_calling directory
#source ~/.bash_profile

# run Rscript
Rscript $protocol_dir/STAR_protocols_GV_calling/scripts/fillUnknownVariantsInNormalSamples.R

# unload modules
#module purge

date +"%d %B %Y %H:%M:%S"

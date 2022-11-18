#!/bin/bash

#Copywrite Divya Sahu, 2021

## what this script will do: process combined variants table for all samples and give a clean table with sample and mutation status of each variant
## where to run this script: from the folder where input.list is stored
## this script requires: R should be loaded in the system path; need combinedVariantsFromAllSamples.txt and output path. See processCombinedVariants.R for details
## output files: processed_CombinedVariantsAllSamples.txt # you can also rename the file for each data types: ex: processed_CombinedVariantsAllSamples_wxs-normal.txt; processed_CombinedVariantsAllSamples_wxs-tumor.txt; processed_CombinedVariantsAllSamples_rnaseq-tumor.txt

##########################################################################################################################

date +"%d %B %Y %H:%M:%S"


# unload modules
#module purge

# load modules
#module load goolf/7.1.0_3.1.4  R/4.0.0
#module load R # use the latest version of R


# need input list
input_list="input.list"
OPTS=$(sed -n "$SLURM_ARRAY_TASK_ID"p "$input_list")

# run R script
Rscript $protocol_dir/STAR_protocols_GV_calling/scripts/processCombinedVariants.R $OPTS

# unload modules
#module purge

date +"%d %B %Y %H:%M:%S"

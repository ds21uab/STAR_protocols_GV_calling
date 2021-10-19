#!/bin/bash
#SBATCH -N 1      
#SBATCH -n 1
#SBATCH --cpus-per-task=2 # number of CPUS per task  
#SBATCH --mem=500Gb # memory to run the job
#SBATCH -t 5:00:00  # time to finish the job
#SBATCH --partition=largemem # cluster partition we will use run the job; change this with your cluster env
#SBATCH -e slurm-%j.err 
#SBATCH --output slurm-%j.out
#SBATCH --array=1-95 #submit a job array with index values betwen 1 and 512 #change with number of files to be processed 

## what this script will do: process combined variants table for all samples and give a clean table with sample and mutation status of each variant
## where to run this script: the folder where all script are stored
## this script requires: R should be loaded in the system path; need combinedVariantsFromAllSamples.txt and output path. See processCombinedVariants.R for details
## output files: processed_CombinedVariantsAllSamples.txt # you can also rename the file for each data types: ex: processed_CombinedVariantsAllSamples_normal.txt; processed_CombinedVariantsAllSamples_tumor.txt; processed_CombinedVariantsAllSamples_rnaseq.txt

##########################################################################################################################
## The combined variants file contain millions of variants, and so this script will take too much of memory to 
## preprocess the file. Therefore we need to do bit of legwork of get the job done. 
## Here first split the large combined_variants file into chunks of small dataframe keeping same number of columns 
## but divided based on rows. Peform the splitting step in linux.

#FILE=combinedVariantsFromAllSamples.txt
#head -1 $FILE > header.txt
#sed '1d' $FILE > combined_variants_withoutheader.txt
#split -d -l 50000 combined_variants_withoutheader.txt -a 4 --additional-suffix=.txt segment_

## so for the splitting command we did the following
## -d add number suffix
## -l length of rows in each dataframe
## -a separation of 4 digit
## --additional suffix added
## segment_; suffix

## prepare input list
#find $(pwd) -type f -name "segment*" > input.txt
#sort -V input.txt > input.list
#rm combined_variants_withoutheader.txt input.txt

####################################################################################################

date +"%d %B %Y %H:%M:%S"

# number of cpus per task
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# unload modules
module purge

# load modules
module load R # use the latest version of R

# need input list
input_list="/pathToDir/input.list"
OPTS=$(sed -n "$SLURM_ARRAY_TASK_ID"p "$input_list"

# run R script
Rscript processCombinedVariants.R $OPTS

# unload modules
module purge

date +"%d %B %Y %H:%M:%S"

######################################################################################################
## once you finished the array jobs, next step is to merge all processed segments
## run this linux command to merge all processed segments

# awk 'NR == 1 || FNR > 1' processed_CombinedVariantsSegment_*.txt > /pathToSave/processed_CombinedVariants.txt
# cat mergedAllsegments_tumor_rnaseq.txt | wc -l

#####################################################################################################





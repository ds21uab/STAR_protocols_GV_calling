#!/bin/bash
#SBATCH -N 1                    #total number of nodes for the job
#SBATCH --cpus-per-task=10       #number of CPUS per task       
#SBATCH --mem=120Gb                  #total memory per node in MB
#SBATCH -t 05:00:00                    #amount of time for the whole job
#SBATCH --partition=short           #the queue /partition to run on
#SBATCH -e slurm-%j.err
#SBATCH --output slurm-%j.out
#SBATCH --array=1-2 # change # with number of files in the input.list


#############################################################################################################################################
##
## what this script will do: calculate sequencing coverage of union variants from the three data types
## where to run this script: create separate folder for wxs-normal, wxs-tumor and rnaseq-tumor; run script separately for each data type
## requirements: output directory path. R and samtools should be loaded in the system path
## input files: union variants BED file, input.list with location of folders for every BAM files
## output files: samdepth for every BAM file
##
#############################################################################################################################################

date +"%d %B %Y %H:%M:%S"

# number of CPUs per task
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# load modules
# this script was run with samtools 1.12 version
module load  SAMtools/1.12-GCC-9.3.0

# need input list
input_list="/pathToDir/WXStumorInput.list"
OPTS=$(sed -n "$SLURM_ARRAY_TASK_ID"p "$input_list")

# path to bed files
union_variants_bed="/pathToDir/union_wxs_rnaseq_variantsForSamdepth.bed"

# set output directory
out_depth="/pathToOutputDir/"

# processing BAM file
echo "reading BAM files in: $OPTS"
cd $(echo $OPTS | tr -d '\r')

bam=$(find . -type f -name "*.bam")
echo "processing" $bam
samplename="${bam%.*}.samdepth.txt" #remove string after last dash
samtools depth -a -b $union_variants_bed $bam -H -Q 30 -o $out_depth/$samplename
echo "processed" $bam

module purge
date +"%d %B %Y %H:%M:%S"

#!/bin/bash
#SBATCH -N 1                    #total number of nodes for the job
#SBATCH --cpus-per-task=5       #number of CPUS per task       
#SBATCH --mem=120Gb                  #total memory per node in MB
#SBATCH -t 02:00:00                    #amount of time for the whole job
#SBATCH --partition=partition           #the queue /partition to run on
#SBATCH -A account            #the account/ allocation to use
#SBATCH -e slurm-%j.err
#SBATCH --output slurm-%j.out
#SBATCH --array=1-5 #submit a job array with index values betwen 1 and 5. #Replace 5 with the number number of jobs to be processed. For example: user can check the total jobs in the input.list


#############################################################################################################################################
#Copywrite Divya Sahu, 2021

## what this script will do: calculate sequencing coverage of union variants obtained from wxs and rnaseq samples
## where to run this script: create separate directory wxs-normal, wxs-tumor and rnaseq-tumor inside variant_coverage directory; run script separately for each data type
## requirements: samtools should be loaded in the system path
## input files: union variants BED file, input.list with location of folders for every BAM files
## the path for input.list, bed file and out_depth in this script is set for wxs-normal. User need to set the path accordingly.
## output files: coverage of union variants for each BAM file
##
#############################################################################################################################################

date +"%d %B %Y %H:%M:%S"

# number of CPUs per task
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# load modules
# this script was run with samtools 1.12 version
module load samtools/1.12

#source STAR_protocols_GV_calling directory
source ~/.bash_profile

# need input list
input_list="$protocol_dir/STAR_protocols_GV_calling/data/BAM/wxs-normal/wxs-normal_input.list"
OPTS=$(sed -n "$SLURM_ARRAY_TASK_ID"p "$input_list")

# path to bed files
union_variants_bed="$protocol_dir/STAR_protocols_GV_calling/analysis/union_wxs_rnaseq_variants.bed"

# set output directory
out_depth="$protocol_dir/STAR_protocols_GV_calling/analysis/variant_coverage/wxs-normal/"

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

#!/bin/bash
#SBATCH -N 1                    #number of nodes for the job
#SBATCH --cpus-per-task=10      #number of cpus per task
#SBATCH --mem=120Gb    		#total memory per node in GB
#SBATCH -t 05:00:00     	#amount of time for the whole job
#SBATCH -p short             #cluster partition
#SBATCH -e slurm-%j.err		#standard error
#SBATCH --output slurm-%j.out  	#standard output
#SBATCH --array=1-469           #submit a job array with index values betwen 1 and 512

#############################################################################################################################################
##
## what this script will do: call variants on single BAM file
## where to run this script: create separate folder for wxs-normal, wxs-tumor and rnaseq-tumor; run script separately for each data type
## requirements: output directory path (create sub-diretory VCFs_from_VarDict in the working folder); R and samtools should be loaded in the system path
## input files: reference genome in FASTA format, BED file, input.list with location of folders for every BAM files
## output files: VCF file for every BAM file
##
#############################################################################################################################################

date +"%d %B %Y %H:%M:%S"

# number of CPUs per task
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# load modules
module load R/4.1.0-foss-2018a-X11-20180131-bare
module load  SAMtools/1.12-GCC-9.3.0

# need input list
input_list="/pathToDir/WXStumorInput.list"
OPTS=$(sed -n "$SLURM_ARRAY_TASK_ID"p "$input_list")

# path for reference genome fasta and bed files
hg_fasta="/pathToDir/GRCh38.d1.vd1.fa"
exome_bed="/pathToDir/gencode.v37.gene.annotation.bed"

# set output directory
out_VCF="/pathToDir/output/"

# processing BAM file
echo "reading BAM files in: $OPTS"
cd $(echo $OPTS | tr -d '\r')

bam=$(find . -type f -name *.bam)
echo "processing" $bam
samplename="${bam%.*}"

# run VarDict
VarDict -G $hg_fasta \
-f 0.05 \
-b $bam \
-r 3 -Q 30 -q 25 -t \
--nosv \
-N $samplename -c 1 -S 2 -E 3 -g 4 $exome_bed | teststrandbias.R | var2vcf_valid.pl -N $samplename -E -f 0.05 -v 10 > $out_VCF/$samplename.vcf

# message when task is completed
echo "processed" $bam

# unload modules
module purge
date +"%d %B %Y %H:%M:%S"

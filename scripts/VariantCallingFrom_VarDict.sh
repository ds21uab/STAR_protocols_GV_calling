#!/bin/bash
#SBATCH -N 1                    #number of nodes
#SBATCH --cpus-per-task=10      #number of cpus per task
#SBATCH --mem=120Gb    		#total memory per node in GB
#SBATCH -t 05:00:00     	#time limit hrs:min:sec
#SBATCH -p Partition             #cluster partition in your linux cluster
#SBATCH -A Account             #the account/ allocation to use
#SBATCH -e slurm-%j.err		#standard error
#SBATCH --output slurm-%j.out  	#standard output
#SBATCH --array=1-5             #submit a job array with index values betwen 1 and 5

#############################################################################################################################################
##
## what this script will do: variant calling on BAM file
## where to run this script: create a folder VCFs_from_VarDict and inside it create three separate folder. Rename the folder as wxs-normal, wxs-tumor and rnaseq-tumor; run the scri$
## requirements: output directory path; VarDictJava, R and samtools should be loaded in the system path
## input files: reference genome in FASTA format, gene annotation BED file, input.list with location of folders that contain BAM files
## output files: VCF file
##
#############################################################################################################################################

date +"%d %B %Y %H:%M:%S"

# number of CPUs per task
export OMP_NUM_THREADS=$SLURM_CPUS_PER_TASK

# load modules
module load goolf/7.1.0_3.1.4 R
module load samtools/1.12

# need input list
input_list="/STAR_protocols_GermlineVariants_identification/wxs-normal-input.list"
OPTS=$(sed -n "$SLURM_ARRAY_TASK_ID"p "$input_list")

# path for reference genome fasta and bed files
hg_fasta="/STAR_protocols_GermlineVariants_identification/data/reference_data/HSapiens/hg38/GRCh38.d1.vd1.fa"
exome_bed="/STAR_protocols_GermlineVariants_identification/data/reference_data/HSapiens/hg38/gencode.v37.gene.annotation.bed"

# set output directory
out_VCF="/STAR_protocols_GermlineVariants_identification/analysis/VCFs_from_VarDict/wxs-normal/"

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

#!/usr/bin/Rscript

# Copywrite Divya Sahu, 2021
# This code require the tab separated .txt file with information of each sample its corresponding genotype_file, samdepth_file and out_filename

###############################################################
# code chunk:1
################################################################

# load library
library(tidyverse)
library(readr) #this function is for calling write_lines

# arguments from the shell script
cmdArgs <- commandArgs(trailingOnly=TRUE)
slurm_arrayid <- cmdArgs[1]
n <- as.numeric(slurm_arrayid)
print(n)

###############################################################
# code chunk:2
################################################################

# provide tab separated .txt file with information of each Sample_barcode and its corresponding genotype_file, samdepth_file and out_filename
myfile <- read.table("input_genotype_samdepth.txt", header=TRUE, check.names=FALSE, sep="\t")

# preprocessing file
print(myfile[n,])
genotype_file <- myfile[n, "genotype_file"]
samdepth_file <- myfile[n, "samdepth_file"]
out_filename <- myfile[n, "out_filename"]


###############################################################
# code chunk:3
################################################################

# read genotype and samdepth files
genotype <- read.table(genotype_file, header=TRUE, check.names = FALSE, strip.white=TRUE)
sam_depth <- read.table(samdepth_file, header=FALSE, check.names = FALSE, strip.white=TRUE)
print(dim(genotype))
print(dim(sam_depth))

# change colnames of sam_depth file
colnames(sam_depth) <- c("CHROM", "POS", "samdepth")
genotype_GT <- print(table(genotype$GT))


###############################################################
# code chunk:4
################################################################

#calculate the mutation status
genotype$mutation_status <- NULL
for (i in 1:nrow(genotype))
{
	if(genotype[i, "GT"] == "1/0"){
		genotype[i, "mutation_status"] ="Heterozygous"
	}
	else if (genotype[i, "GT"] == "0/1"){
		genotype[i, "mutation_status"] ="Heterozygous"
	}
	else if (genotype[i, "GT"] == "1/1"){
		genotype[i, "mutation_status"] ="Homozygous_alt"
	}
	else if (genotype[i, "GT"] == "0/0"){
		genotype[i, "mutation_status"] ="Homozygous_ref"
	}
	else {
		genotype[i, "mutation_status"] = "nd"
	}
 }

genotype_mutation_status <- print(table(genotype$mutation_status))


###############################################################
# code chunk:5
################################################################

#merge samtools depth and vcf
mergeVCFandSamdepth <- merge(sam_depth, genotype, by.x = c("CHROM", "POS"), by.y = c("CHROM", "POS"), all.x = TRUE, all.y = TRUE)
logfile <- cbind(paste0(out_filename, dim(genotype)[1], dim(sam_depth)[1], dim(mergeVCFandSamdepth)[1], rbind(names(table(genotype$mutation_status)))))
#write_lines(logfile, "logfile.txt", append=TRUE)


###############################################################
# code chunk:6
################################################################

###change the mutation status to unknown if the sequencing coverage is less than 10
mymat <- mergeVCFandSamdepth[1:nrow(mergeVCFandSamdepth),]
mymat <- as.matrix(mymat)
mymat <- apply(mymat,2,function(x)gsub('\\s+', '',x))


mergeSamdepthAndGenotype = function(df) {
    tryCatch({
        val = ifelse(as.numeric(df["samdepth"]) >= 10 & !is.na(df["mutation_status"]), df["mutation_status"],
                     ifelse(as.numeric(df["samdepth"]) < 10, "unknown", "Homozygous_ref"))
    }, error=function(e){cat("ERROR :", conditionMessage(e), "\n")})
    return(val)
}     

mutation_status_mod <- apply(mymat, MARGIN=1, FUN=mergeSamdepthAndGenotype)
dummy <- as.data.frame(mymat)
dummy$mutation_status_mod <- mutation_status_mod
print(table(dummy$mutation_status_mod))
print(table(dummy$mutation_status))
print(dim(dummy))
write.table(dummy, paste0(out_filename,".txt"), quote=FALSE, sep="\t", row.names=FALSE)

#!/usr/bin/Rscript

# this script will take GT_samdepth_merged.txt file for each sample and merge them to create a large .txt file with mutation status from all samples
# repeat this step for each data types separately
# this script requires: need input path and output path.


##########################################################################################################
# code chunk:1
##########################################################################################################

# load library
library(data.table)
library(readr)
library(dplyr) 

##########################################################################################################
# code chunk:2
##########################################################################################################


# set the input path to read GT_samdepth_merged.txt
input_path <- "/pathTo_Genotype_samdepth_mergedFile/"

# set the output path where combined_variants_AllSamples to be located
output_path <- "/pathTo_combined_variants_AllSamples/"


# find all .txt files in the path and list them
filelist = list.files(input_path, pattern = "*.txt", full.names=TRUE)
print(paste0("total files to be merged", ":", " ", length(filelist)))


##########################################################################################################
# code chunk:3
##########################################################################################################


# read files as list
datalist = lapply(filelist, function(x)fread(x, stringsAsFactors=F, strip.white=T, check.names=F, header=TRUE))
mylist = lapply(datalist, function(x) setDF(x)) #convert data.table into data.frame
#print(str(mylist))
rm(filelist, datalist)


##########################################################################################################
# code chunk:4
##########################################################################################################


#check equality of columns before dropping columns
print(paste("dimension_before_dropColumns",":",lapply(mylist, function(x) dim(x)), sep=" "))

print(paste("allchromosome_before_dropColumns", ":", 
	names(table(unlist(lapply(mylist, function(x) all(mylist[[1]]$CHROM == x$CHROM))))),
	table(unlist(lapply(mylist, function(x) all(mylist[[1]]$CHROM == x$CHROM)))),
	sep=" ")) 

print(paste("allposition_before_dropColumns", ":",
	names(table(unlist(lapply(mylist, function(x) all(mylist[[1]]$POS == x$POS))))), 
	table(unlist(lapply(mylist, function(x) all(mylist[[1]]$POS == x$POS)))), 
	sep=" ")) 

print(paste("samdepth_before_dropColumns", ":",
	names(table(unlist(lapply(mylist, function(x) all(mylist[[1]]$samdepth == x$samdepth))))), 
	table(unlist(lapply(mylist, function(x) all(mylist[[1]]$samdepth == x$samdepth)))), 
	sep= " ")) 


##########################################################################################################
# code chunk:5
##########################################################################################################


# drop columns from each list of dataframe
drop <- c("samdepth", "TYPE", "DP", "VD", "AF", "MQ", "GT", "mutation_status")
mylist <- lapply(mylist, function(x) x[, !colnames(x) %in% drop])


##########################################################################################################
# code chunk:6
##########################################################################################################


#check equality of columns after dropping columns
print(paste("dimension_after_dropColumns",":",lapply(mylist, function(x) dim(x)),
	sep=" "))


##########################################################################################################
# code chunk:7
##########################################################################################################


# bind columns of dataframe
combined_variants <- bind_cols(mylist)
print(dim(combined_variants))


##########################################################################################################
# code chunk:8
##########################################################################################################

# output combined variants file
fwrite(combined_variants, paste0(output_path, "combined_variants.txt"), sep="\t", quote=FALSE)


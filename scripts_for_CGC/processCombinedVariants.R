#!/usr/bin/Rscript

##Copywrite Divya Sahu, 2021

# this script will perform processing of the combined variants from all samples
# repeat this step for each data types separately
# this script requires: combinedVariantsFromAllSamples.txt file as input, header.txt

##########################################################################################################
# code chunk:1
##########################################################################################################

# load libraries
library(data.table)
library(readr)
library(dplyr)

##########################################################################################################
# code chunk:2
##########################################################################################################

args = commandArgs(trailingOnly=TRUE)
print(paste0('Hello! processing segment number: ', args[1]) )
x <- strsplit(args[1],"/")
output_name <- x[[1]][length(x[[1]])]
print(output_name)

# read file
combined_variants <- fread(args[1],
   stringsAsFactors=FALSE,
   strip.white=TRUE,
   check.names=FALSE,
   header=FALSE,
   fill=TRUE)
print(paste0("loaded combined_variants", " ", dim(combined_variants)))

# convert data.table to dataframe
combined_variants <- setDF(combined_variants)
print(class(combined_variants))

# change colnames
segment_header <- fread(paste0("header.txt"),
  stringsAsFactors=FALSE,
  strip.white=TRUE,
  check.names=FALSE,
  header=FALSE)
colnames(combined_variants) <- segment_header[1,]

##########################################################################################################
# code chunk:3
##########################################################################################################

# extract first two columns
CHROM_POS <- combined_variants[, 1:2]
colnames(CHROM_POS) <- c("CHROM","POS")

# remove columns
toMatch <- c("CHROM", "POS")
drop <- grep(paste(toMatch,collapse="|"), names(combined_variants), value=TRUE)
combined_variants_drop <- combined_variants[, !colnames(combined_variants) %in% drop]
print(dim(combined_variants_drop))
rm(combined_variants)

# add CHROM and POS in the dataframe
combined_variants_drop$CHROM <- CHROM_POS$CHROM
combined_variants_drop$POS <- CHROM_POS$POS

##########################################################################################################
# code chunk:4
##########################################################################################################

#apply function
result <- apply(combined_variants_drop, 1, function(row){
   tryCatch({

      location <- as.character(row[c("CHROM", "POS")])

      variant <- row[grep("REF", names(row), value=TRUE)]
      ref_allele <- unique(as.character(t(variant[which(is.na(variant) == FALSE)])))
      ref_allele <- ifelse(length(ref_allele) >= 1, ref_allele[!(ref_allele == "")], 0)
      mod_ref_allele <- ifelse(length(ref_allele) > 1, paste(shQuote(ref_allele), collapse=", "), ref_allele)

      variant <- row[grep("ALT", names(row), value=TRUE)]
      alt_allele <- unique(as.character(t(variant[which(is.na(variant) == FALSE)])))
      alt_allele <- ifelse(length(alt_allele) >= 1, alt_allele[!(alt_allele == "")], 0)
      mod_alt_allele <- ifelse(length(alt_allele) > 1, paste(shQuote(alt_allele), collapse=", "), alt_allele)

      toMatch <- c("SAMPLE", "mutation_status_mod")
      patient_and_mutstatus <- as.character(row[grep(paste(toMatch, collapse="|"), names(row), value=TRUE)])

      c(location, mod_ref_allele, mod_alt_allele, patient_and_mutstatus)

   }, error=function(e){message("ERROR :", conditionMessage(e), "\n")})   
})

result <- t(result)
merged_variants <- apply(result,2,function(x)gsub('\\s+', '',x))
columnID <- which(apply(merged_variants, 2, function(x) all(is.na(x))) == TRUE)
merged_variants[, columnID] <- "SampleNameNotFound"

##########################################################################################################
# code chunk:5
##########################################################################################################

# extract mutation_status of each sample
merged_samples <- merged_variants
numcols <- ncol(merged_samples)
column_names <- paste0("V", 1:numcols)
colnames(merged_samples) <- column_names
   

##########################################################################################################
# code chunk:6
##########################################################################################################

# change the colnames of merged_samples which is converted to data.frame
for (i in 1:ncol(merged_samples)){
   #toMatch <- c("TCGA", "./", "./TCGA")
   toMatch <- c("TCGA", "./", "./TCGA", "SampleNameNotFound")
   TCGA_samplename <- unique(grep(paste(toMatch, collapse="|"), x = merged_samples[, i], value= TRUE ))
   colnames(merged_samples)[i] <- ifelse(length(TCGA_samplename) == 1, TCGA_samplename, colnames(merged_samples)[i])
}
colnames(merged_samples)[1:4] <- c("CHROM", "POS", "REF", "ALT")

# extract all names with TCGA and V
name1 <-grep(paste(toMatch, collapse="|"), colnames(merged_samples), value=TRUE)
name2 <-grep(pattern="^V", colnames(merged_samples), value=TRUE)
name3 <- as.data.frame(cbind(name1, name2))
print(dim(name3))
colnames(name3) <- c("TCGA_samplename", "mutation_status_mod")
merged_samples_with_mutstatus <- merged_samples[, c("CHROM", "POS", "REF", "ALT", grep(pattern="^V", colnames(merged_samples), value = TRUE))]
colnames(merged_samples_with_mutstatus) <- c("CHROM", "POS", "REF", "ALT", name3$TCGA_samplename)
merged_samples_with_mutstatus <- as.data.frame(merged_samples_with_mutstatus)

# out the merged table
fwrite(merged_samples_with_mutstatus, paste0("processed_CombinedVariants_", output_name), sep="\t", quote=FALSE, row.names=FALSE, col.names=TRUE)


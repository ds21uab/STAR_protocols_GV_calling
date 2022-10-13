#!/usr/bin/Rscript

##Copywrite Divya Sahu, 2021

# this script will fill the unknown mutation status of variants in normal samples by taking mutation status of that variant from tumor samples, and if its still unknown then from the corresponding rnaseq samples
# this script requires: processed_CombinedVariants_filtered.txt files for each data type; patient list with Case_ID and sampleBarcode.
# please keep the column names of the patient list as suggested:
# WXS_normal: Case_ID and normal
# WXS_tumor: Case_ID and tumor
# rnaseq_tumor: Case_ID and rnaseq  
# result will be saved in the current working directory. You can change the location by providing the outpath
# four output files will be generated. 
# 1. combined_normal_unknown_filled.txt
# 2. combined_normal_unknown_filled_arranged.txt
# 3. final_merged_wxs_rnaseq_variants.txt # this file store the final variants from the the three data types
# 4. final_variantsForAnnovar.txt # this file stores final variants structered for variant annotation using Annovar

###########################################################################################################
# code chunk:1
###########################################################################################################

# load libraries
library(data.table)
library(tidyr)


###########################################################################################################
# code chunk:2
###########################################################################################################

# read file
normal_wxs <- fread("/STAR_protocols_GV_calling/analysis/combined_variant_status/wxs-normal/processed_CombinedPotentialSNPs.txt",
                    stringsAsFactors=FALSE, strip.white=TRUE, check.names=FALSE, header=TRUE, fill=TRUE)
tumor_wxs <-  fread("/STAR_protocols_GV_calling/analysis/combined_variant_status/wxs-tumor/processed_CombinedPotentialSNPs.txt",
                    stringsAsFactors=FALSE, strip.white=TRUE, check.names=FALSE, header=TRUE, fill=TRUE)
tumor_rnaseq <- fread("/STAR_protocols_GV_calling/analysis/combined_variant_status/rnaseq-tumor/processed_CombinedPotentialSNPs.txt",
                    stringsAsFactors=FALSE, strip.white=TRUE, check.names=FALSE, header=TRUE, fill=TRUE)                    

# merge all files into a list
datalist = list(normal_wxs, tumor_wxs, tumor_rnaseq)
mylist = lapply(datalist, function(x) setDF(x)) #convert data.table into data.frame

# reduce and merge all variants from normal_wxs, tumor_wxs and tumor_rnaseq based on chromosome, position, reference allele, alternate allele
combined_variants= Reduce(function(x, y) merge(x, y, by.x = c("CHROM", "POS", "REF", "ALT"),
        by.y = c("CHROM", "POS", "REF", "ALT"), all.x = TRUE, all.y = TRUE), mylist)
print(paste0("total variants in combined wxs and rnaseq", " ", nrow(combined_variants)))


###########################################################################################################
# code chunk:3
###########################################################################################################

# merge patients info 
normal_sample <- fread("/STAR_protocols_GV_calling/data/samples/wxs-normal-samples.txt", 
			stringsAsFactors=FALSE, strip.white=TRUE, check.names=FALSE, header=TRUE, fill=TRUE)  
normal_sample <- as.data.frame(normal_sample)

tumor_sample <- fread("/STAR_protocols_GV_calling/data/samples/wxs-tumor-samples.txt", 
			stringsAsFactors=FALSE, strip.white=TRUE, check.names=FALSE, header=TRUE, fill=TRUE)  
tumor_sample <- as.data.frame(tumor_sample)

rnaseq_sample <- fread("/STAR_protocols_GV_calling/data/samples/rnaseq-tumor-samples.txt", 
			stringsAsFactors=FALSE, strip.white=TRUE, check.names=FALSE, header=TRUE, fill=TRUE)  
rnaseq_sample <- as.data.frame(rnaseq_sample)

patient_list <- list(normal_sample, tumor_sample, rnaseq_sample)

combined_patient = Reduce(function(x, y) merge(x, y, by.x = "Case_ID", by.y = "Case_ID", all.x = TRUE, all.y = TRUE), patient_list)
combined_patient <- combined_patient %>% drop_na(normal)
print(dim(combined_patient))


###########################################################################################################
# code chunk:4
###########################################################################################################

# function to cbind filled dataframe to an empty dataframe
cbind.fill <- function(...){
  nm <- list(...) 
  nm <- lapply(nm, as.matrix)
  n <- max(sapply(nm, nrow)) 
  do.call(cbind, lapply(nm, function (x) 
  as.data.frame(rbind(x, matrix(, n-nrow(x), ncol(x)))))) 
}

# function to fill unknown in normal (n), first take value from tumor (t) and if not present then value from rnaseq (r)
fillUnknownInNormal <- function(n,t,r){
  #print(c(n, t, r))
  if ( is.na(n) | n == "unknown") {
    if( !is.na(t) & ! t %in% c("unknown", "")) {
      n = t
    }
    else {
      n = r
    }
  }
  return(n)
} 

# function to fill unknown in normal (n) from tumor (t)
fillUnknownInNormalByTumor <- function(n,t){
  #print(c(n, t))
  if ( is.na(n) | n == "unknown") {
    if( !is.na(t) & ! t %in% c("unknown", "")) {
      n = t
    }
    else {
      n = n
    }
  }
  return(n)
}

###########################################################################################################
# code chunk:6
###########################################################################################################

final_table = data.frame()
for (patient in 1:nrow(combined_patient)){
  tryCatch({
    print(patient)
    id <- combined_patient[patient, 2:ncol(combined_patient)]

    #if the corresponding rnaseq sample not available
    if(is.na(id$rnaseq)) {
      print("Fill the unknown with corresponding wxs-tumor sample")
      normal_variants <- combined_variants[, id$normal]
      matched_tumor_variants <- combined_variants[, id$tumor]
      dummy <- cbind(normal_variants, matched_tumor_variants)
      dummy <- as.data.frame(dummy)
      z <-  mapply(fillUnknownInNormalByTumor,  dummy$normal_variants, dummy$matched_tumor_variants)
      final_table <- cbind.fill(final_table, z)
      rm(normal_variants, matched_tumor_variants, dummy, id, z)
    }
    
    else if (is.na(id$rnaseq) & is.na(id$tumor)) { #if the corresponding rnaseq and wxs-tumor sample not available
      print("corresponding wxs-tumor and rnaseq not available")
      normal_variants <- as.data.frame(combined_variants[, id$normal])
      final_table <- cbind.fill(final_table, normal_variants)
      rm(normal_variants)  
    }

    else { #if both corresponding wxs-tumor and rnaseq are available
      print("Fill the unknown with corresponding wxs-tumor and rnaseq sample")
      normal_variants <- combined_variants[, id$normal]
      matched_tumor_variants <- combined_variants[, id$tumor]
      matched_rnaseq_variants <- combined_variants[, id$rnaseq]
      dummy <- cbind(normal_variants, matched_tumor_variants, matched_rnaseq_variants)
      dummy <- as.data.frame(dummy)
      z <-  mapply(fillUnknownInNormal,  dummy$normal_variants, dummy$matched_tumor_variants, dummy$matched_rnaseq_variants)
      final_table <- cbind.fill(final_table, z)
      rm(normal_variants, matched_tumor_variants, matched_rnaseq_variants, dummy, z)
    }
  }, error=function(e){cat("ERROR :", conditionMessage(e), "\n")})
}
print(dim(final_table))

colnames(final_table) <- combined_patient$normal
rownames(final_table) <- seq(1:nrow(combined_variants))
print(dim(final_table))
final_table$CHROM <- combined_variants$CHROM
final_table$POS <- combined_variants$POS
final_table$REF <- combined_variants$REF
final_table$ALT <- combined_variants$ALT

fwrite(final_table, "combined_normal_unknown_filled.txt", sep="\t", quote=FALSE, row.names=FALSE, col.names=TRUE)  

# arrange final table
toMatch <- c("TCGA", "./", "./TCGA")
normal_patient <- colnames(final_table)[grepl(paste(toMatch, collapse="|"), x=names(final_table))]
final_table_colarrange <- final_table[, c("CHROM", "POS", "REF", "ALT", normal_patient)]
final_table_colarrange$POS <- as.numeric(final_table_colarrange$POS)
print(str(final_table_colarrange))
fwrite(final_table_colarrange, "combined_normal_unknown_filled_arranged.txt", sep="\t", quote=FALSE, row.names=FALSE, col.names=TRUE)  


###########################################################################################################
# code chunk:7
###########################################################################################################

# keep only unique normal samples
mynames <- unique(normal_patient[which(duplicated(normal_patient) == TRUE)])

# get only unique columns value because duplicated columns separated by .1, .2
final_table_colarrange <- final_table_colarrange[, colnames(unique(as.matrix(final_table_colarrange), MARGIN=2))]

# drop samples
tumor_wxs_dropsamples <- tumor_wxs[, !(colnames(tumor_wxs) %in% combined_patient$tumor)]
print(paste0("number of tumor samples added"," ", dim(tumor_wxs_dropsamples)[[2]]))
rnaseq_dropsamples <- tumor_rnaseq[, !(colnames(tumor_rnaseq) %in% combined_patient$rnaseq)]
print(paste0("number of rnaseq samples added", " ", dim(rnaseq_dropsamples)[[2]]))
mylist = list(final_table_colarrange, tumor_wxs_dropsamples, rnaseq_dropsamples)

# merge samples and variants for WXS_normal, WXS_tumor, rnaseq_tumor
merged_wxs_rnaseq_variants= Reduce(function(x, y) merge(x, y, by.x = c("CHROM", "POS", "REF", "ALT"),
         by.y = c("CHROM", "POS", "REF", "ALT"), all.x = TRUE, all.y = TRUE), mylist)
dim(merged_wxs_rnaseq_variants)

# write table
fwrite(merged_wxs_rnaseq_variants, "final_merged_wxs_rnaseq_variants.txt", sep="\t", quote=FALSE, row.names=FALSE, col.names=TRUE)
				   


###########################################################################################################
# code chunk:8
###########################################################################################################

# # extract variant for annovar annotation # run table_annovar.pl on final variants
variantsForAnnovar <- merged_wxs_rnaseq_variants[, 1:4]
print(str(variantsForAnnovar))
colnames(variantsForAnnovar) <- c("CHROM", "START", "REF", "ALT")
variantsForAnnovar$END <- variantsForAnnovar$START
variantsForAnnovar <- variantsForAnnovar[, c("CHROM", "START", "END", "REF", "ALT")]
fwrite(variantsForAnnovar, "final_variantsForAnnovar.txt", sep="\t", quote=FALSE, row.names=FALSE, col.names=FALSE)



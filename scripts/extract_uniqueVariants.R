#!/usr/bin/env Rscript

##Copywrite Divya Sahu, 2021

library(data.table)
library(dplyr)

# read file
df <- fread("variant_chr_pos_ref_alt.txt",
   stringsAsFactors=FALSE,
   strip.white=TRUE,
   check.names=FALSE,
   header=FALSE)

# check the class of the dataframe
df <- setDF(df)
print(class(df))
colnames(df) <- c("CHROM", "POS", "REF", "ALT")

# remove duplicate rows with dplyr
df2 <- df %>% 
  # Base the removal on the "CHROM" and "POS" column
  distinct(CHROM, POS, REF, ALT, .keep_all = TRUE)

write.table(df2, "unique_variants.txt", row.names=FALSE, quote=FALSE, sep="\t")
print(paste0("unique variants from all samples:", nrow(df2)))




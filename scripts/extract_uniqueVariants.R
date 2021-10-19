#!/usr/bin/env Rscript
library(data.table)
library(dplyr)

# read file
df <- fread("variants_chromosome_position.txt",
   stringsAsFactors=FALSE,
   strip.white=TRUE,
   check.names=FALSE,
   header=FALSE)

# check the class of the dataframe
df <- setDF(df)
print(class(df))
colnames(df) <- c("CHROM", "POS")


# remove duplicate rows with dplyr
df2 <- df %>% 
  # Base the removal on the "CHROM" and "POS" column
  distinct(CHROM, POS, .keep_all = TRUE)

#df2 <- df[!duplicated(df[c(1,2)]),]
#print(paste0("total variants:", dim(df)))
write.table(df2, "unique_variants.txt", row.names=FALSE, quote=FALSE, sep="\t")
print(paste0("unique variants from all samples:", dim(df2)))




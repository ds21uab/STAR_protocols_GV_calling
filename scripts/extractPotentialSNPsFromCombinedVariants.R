#extractPotentialSNPsFromCombinedVariants.R

# #######################################################################################
# ## this script is to remove variants which are either unknown or Homozygous ref across all samples from the processed_CombinedVariants.txt
# ## load R

## load library
library(data.table)

## read file
data <- fread("processed_CombinedVariants.txt",stringsAsFactors=FALSE, 
	strip.white=TRUE,
	check.names=FALSE,
	header=TRUE,
	fill=TRUE)

## convert to dataframe
data <- setDF(data)

## check dimension
print(dim(data)) 

## keep the location as potential SNP as long as one sample has the alternate allele
row_sub = apply(data[, 5:ncol(data)], 1, function(row) all(!(row %in% c("Homozygous_alt", "Heterozygous"))))
data_filtered <- data[!row_sub,]
dim(data_filtered)

## out file
fwrite(data_filtered, "processed_CombinedVariants_filtered.txt", 
	sep="\t", 
	quote=FALSE, 
	row.names=FALSE, 
	col.names=TRUE)


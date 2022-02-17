For questions about the scripts in this project please contact Divya Sahu (dsahu@uab.edu or sahu.divya786@gmail.com)

# STAR_protocols_GermlineVariant_calling

[![DOI](https://zenodo.org/badge/419077939.svg)](https://zenodo.org/badge/latestdoi/419077939)


Germline variants are positions at which an individual’s normal genome differs from the reference genome. These genetic changes are present in all cells of the body and are inherited. Germline variants are effective in predicting drug sensitivity and efficacy, however their potential in predicting patient outcome in cancers was largely unknown. Here we provide a bioinformatic pipeline to screen germline variants from the Genomics Data Commons (GDC) data portal. This pipeline integrates paired whole exome sequences (wxs) from normal (wxs-normal) and tumor samples (wxs-tumor), and RNA sequences (rnaseq) from tumor samples (rnaseq-tumor) to determine a patient’s germline variant status. Our pipeline then identifies the small subset of germline variants that are predictive of patient cancer outcome. We demonstrate the use of the pipeline on 5 wxs-normal samples, 7 wxs-tumor samples and 7 rnaseq-tumor samples on a Linux cluster which uses Simple Linux Utility for Resource Management (SLURM).

**Initially this method was described in the following articles**

Chatrath A, Kiran M, Kumar P, Ratan A, Dutta A. The Germline Variants rs61757955 and rs34988193 Are Predictive of Survival in Lower Grade Glioma Patients. Molecular Cancer Research. 2019 May; 17 (5): 1075-1086. doi: 10.1158/1541-7786.MCR-18-0996. Epub 2019 Jan 16.

Chatrath A, Przanowska R, Kiran S, Su Z, Saha S, Wilson B, Tsunematsu T, Ahn JH, Lee KY, Paulsen T, Sobierajska E, Kiran M, Tang X, Li T, Kumar P, Ratan A, Dutta A. The pan-cancer landscape of prognostic germline variants in 10,582 patients. Genome Medicine. 2020 Feb 17; 12 (1); 15. doi: 10.1186/s13073-020-0718-7





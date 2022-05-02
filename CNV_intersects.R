# This script parses the CNV interval refGene annotations to find genes intersecting with curated lists pertaining to CP.



library(dplyr)

infile <- readline(prompt = "Please enter your CNV calls file: ")
df <- read.delim(infile, header = F)
# colnames(df)[which(grepl('chr', df))] <- 'chr'
# colnames(df)[which(grepl('-', df))] <- 'sampleID'
# colnames(df)[which(grepl(';', df))] <- 'refGene'
# if (grepl('dup', df) || grepl('del', df)) { print('fine')}
# 
# for (x in 1:ncol(df)) {
#   print(colnames(df)[x])
#   if (any(df[x] == 'del') || any(df[x == 'dup'])) {
#     colnames(df)[x] <- 'state'
#   }
#   }

colnames(df) <- c('sampleID', 'state', 'chr', 'start', 'stop', 'refGene')
df <-  mutate(df, length = stop - start)

# From the table of all proband CNV calls, extract a list of gene names

genelist <- unlist(strsplit(df$refGene, ';'))
genelist <- unique(genelist)

# Importing a few lists of genes we're looking out for:

# These are genes related to spastic paraplegia
sp <- scan('SPgenes.txt', character())

# These were noted in Jin, 2020 to be CP-associated
ng_genes <- scan('ng_cp_assoc_geneset.txt', character())

# This function subsets a dataframe of CNVs to only those containing genes from
# a particular list

CNVs_by_geneSet <- function(data = probands, mySet = sp, querySet = genelist) {
  df2 <- data.frame()
  gs <- intersect(mySet, querySet)
  for (x in 1:length(gs)) {
    df2 <- rbind(df2, data[grepl(gs[x],data$refGene),])
  }
  return(df2)
}

# Here we can see only the 6 CNV results containing genes from our set
NG_results_table <- CNVs_by_geneSet(ng_genes)
SP_results_table <- CNVs_by_geneSet(sp)
OMIM_results_table <- CNVs_by_geneSet(omim$Gen.Symbols)
known_CP_table <- CNVs_by_geneSet(known_cp)

require(dplyr)
require(magrittr)

args = commandArgs()

# read text file with all miRge3.0 files
file_list = scan(args[6], what = character())

# create table with first miRNA file as column
mir_counts = read.csv(file_list[1], header = T)

# append other miRNA files recursively
for (i in seq(2, length(file_list))) {
	file_sample = read.csv(file_list[i], header = T)
	
	mir_counts = full_join(mir_counts, file_sample, by = 'miRNA')
}

mir_counts %<>% tibble::column_to_rownames(., 'miRNA')

# save table
write.table(mir_counts, file = args[7], quote = F, sep = '\t')

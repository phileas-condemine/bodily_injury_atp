library(data.table)
path_to_data="data/"
path_to_tempdata="temp_data/"
load(paste0(path_to_data,"CAPP_1ST_2ND_INSTANCES/CAPP_text_extraction.RData"))

##### extract UNIQUE words from all document
# CAPP_tokens <- strsplit(CAPP_docs,split = " ") #notice it turns automatically vec into list of vec, no need to use sapply if you don't want to add unique function on top.
system.time(CAPP_tokens <- pbapply::pbsapply(CAPP_docs,function(x)strsplit(x = x,split = " ")))
system.time(CAPP_tokens_uniques <- pbapply::pblapply(CAPP_tokens,unique))
rm("CAPP_tokens")
#pool all the words together (remember each word can only be present once for a given doc)
# CAREFUL, THE NAMES ARE USING 95% OF THE SPACE BECAUSE THEY ARE VERY LONG (based on XML full PATH)
# I also remove the small words (less than 4 letters) which don't make sense in french
# I split the db in 200 so that each subset can hold in RAM, if the dataset is bigger, for instance when using other data than CAPP, use 2000.
index_split <- split(1:length(CAPP_tokens_uniques),f = 1:200)
unlist_rm_name<- function(sub_index){
CAPP_tokens_vec <- unlist(unname(CAPP_tokens_uniques[sub_index]))
# CAPP_tokens_vec <- unname(CAPP_tokens_vec)
CAPP_tokens_vec <- CAPP_tokens_vec[stringr::str_length(CAPP_tokens_vec)>3]
return(CAPP_tokens_vec)
}
CAPP_tokens_unlist <- pbapply::pblapply(index_split,unlist_rm_name)
CAPP_tokens_unlist <- unlist(unname(CAPP_tokens_unlist))

save(list="CAPP_tokens_unlist",file=paste0(path_to_tempdata,"CAPP_tokens_unique_per_doc_3moreletters.RData"))
CAPP_freq_table <- data.table(docs=CAPP_tokens_unlist)[,.N,by=docs]
save(list="CAPP_freq_table",file=paste0(path_to_tempdata,"CAPP_term_freq_table_3moreletters.RData"))
rm(list = c("CAPP_tokens_uniques","CAPP_docs","CAPP_tokens_unlist"))

CAPP_freq_table <- CAPP_freq_table[order(CAPP_freq_table$N,decreasing=T)]
head(CAPP_freq_table,20)
head(CAPP_freq_table[CAPP_freq_table$N<5000])


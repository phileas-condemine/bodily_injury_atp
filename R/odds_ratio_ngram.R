# load("Documents/bodily_injury_atp/data/CAPP_1ST_2ND_INSTANCES/CAPP_ngrams.RData")
# library(text2vec)
# library(magrittr)
# library(dplyr)
# library(broom)
# library(data.table)
# tidy_matrix_ngram<-matrix_ngrams%>%tidy()%>%data.table()


# careful, need underscore instead of space.
# key_word="tierce_personne"
odd_ratio_wordwise<-function(key_word="corporel",nb_to_keep=10,threshold_ratio=50,threshold_volume=100,useNB=TRUE,useTHRESHOLD=FALSE){
  gc()
sub_key_words<-c(unlist(strsplit(key_word,"_")))
# key_word%in%levels(factor(tidy_matrix_ngram$column))
tidy_matrix_ngram[,has_key_word:=1*(key_word%in%column),by=row]
nb_w_keyword=sum(tidy_matrix_ngram[has_key_word==1][,list(count=1),by=row]$count)
nb_no_keyword=sum(tidy_matrix_ngram[has_key_word==0][,list(count=1),by=row]$count)
#print(system.time(
  odd_ratios<-tidy_matrix_ngram[,list("nb_docs"=.N),by=c("column","has_key_word")][,list("odd_ratio"=nb_no_keyword/nb_w_keyword*sum(nb_docs*(has_key_word))/sum(nb_docs*(1-has_key_word)),"volume"=sum(nb_docs)),by="column"]
#  ))
  
odd_ratios%>%arrange(odd_ratio)%>%
  filter(volume>threshold_volume)%>%
  mutate(has_key_word=rowSums(sapply(sub_key_words,function(x)grepl(pattern=x,x=.$column)))>0)%>%#I don't want the ngram with the keyword inside of course !
  filter(has_key_word==FALSE)%>%
  select(column,odd_ratio,volume)%>%
  arrange(-odd_ratio)%>%
  .[1:nb_to_keep,]%>%
  rename(target=column,link=odd_ratio,node_size=volume)%>%
  mutate(source=key_word)%>%
  return()


  }

# odd_ratio_wordwise(key_word)

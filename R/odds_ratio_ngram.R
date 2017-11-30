load("Documents/bodily_injury_atp/data/CAPP_1ST_2ND_INSTANCES/CAPP_ngrams.RData")
library(text2vec)
library(magrittr)
library(dplyr)
library(broom)
tidy_matrix_ngram<-matrix_ngrams%>%tidy()%>%data.table()


# careful, need underscore instead of space.
key_word="tierce_personne"
#this only handles 1 and 2 grams, not 3 grams !
sub_key_words<-c(key_word,unlist(strsplit(key_word,"_")))
ngram=3L
n_cores=28
# key_word%in%levels(factor(tidy_matrix_ngram$column))
tidy_matrix_ngram[,has_key_word:=1*(key_word%in%column),by=row]
dim(tidy_matrix_ngram)
system.time(odd_ratios<-tidy_matrix_ngram[,list("nb_docs"=.N),by=c("column","has_key_word")][,list("odd_ratio"=sum(nb_docs*(has_key_word))/sum(nb_docs*(1-has_key_word)),"volume"=sum(nb_docs)),by="column"])
odd_ratios%>%arrange(odd_ratio)%>%
  filter(volume>100)%>%
  mutate(has_key_word=rowSums(sapply(sub_key_words,function(x)grepl(pattern=x,x=.$column)))>0)%>%#I don't want the ngram with the keyword inside of course !
  filter(has_key_word==FALSE)%>%
  select(column,odd_ratio,volume)%>%
  tail(20)

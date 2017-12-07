library(text2vec)#install.packages("text2vec")
library(magrittr)
library(dplyr)
library(broom)
library(data.table)#install.packages("data.table")
library(parallel)
load("Documents/bodily_injury_atp/data/CAPP_1ST_2ND_INSTANCES/CAPP_ngrams.RData")
n_cores=10

tidy_matrix_ngram<-matrix_ngrams%>%tidy()%>%data.table()

source("Documents/bodily_injury_atp/R/odds_ratio_ngram.R")

key_word="corporel"
layer1to4<-function(key_word){
network_nearest_neighbors_50_layer1<-odd_ratio_wordwise(key_word=key_word,nb_to_keep=10)
network_nearest_neighbors_50_layer2<-network_nearest_neighbors_50_layer1$target%>%
  mclapply(FUN=function(x)odd_ratio_wordwise(key_word=x,nb_to_keep=5),mc.cores=n_cores)%>%do.call(what="rbind",args=.)
network_nearest_neighbors_50_layer3<-network_nearest_neighbors_50_layer2$target%>%unique()%>%
  mclapply(FUN=function(x)odd_ratio_wordwise(key_word=x,nb_to_keep=3),mc.cores=n_cores)%>%do.call(what="rbind",args=.)
network_nearest_neighbors_50_layer4<-network_nearest_neighbors_50_layer3$target%>%unique()%>%
  mclapply(FUN=function(x)odd_ratio_wordwise(key_word=x,nb_to_keep=2),mc.cores=n_cores)%>%do.call(what="rbind",args=.)


save(list=c("network_nearest_neighbors_50_layer1",
            "network_nearest_neighbors_50_layer2",
            "network_nearest_neighbors_50_layer3",
            "network_nearest_neighbors_50_layer4"),file=sprintf("Documents/bodily_injury_atp/temp_data/network_nearest_neighbors_layers1234_%s.RData",key_word))
}

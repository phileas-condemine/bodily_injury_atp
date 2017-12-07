# library(dplyr)
# library(magrittr)
# load("network_nearest_neighbors_layers1_many_words.RData")
# network=layer1
prune_layers<-function(network){
  lapply(as.character(levels(factor(network$source))),function(x){
    network[network$source==x,]%>%mutate(redudancy_score=sapply(target,function(x)length(grep(pattern=x,x=.$target))))%>%return()
  })%>%do.call("rbind",.)%>%return()
}

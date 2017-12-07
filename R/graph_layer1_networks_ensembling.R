library(networkD3)
library(dplyr)
library(magrittr)
load("network_nearest_neighbors_layers1_many_words.RData")
# data(MisLinks)
# data(MisNodes)
layer1$layer=1
layer1=layer1[!is.nan(layer1$link),]
layer1=layer1[!is.na(layer1$link),]

source("R/networks_prune_redudant_ngram.R")
layer1=prune_layers(layer1)
node_group=data.table(layer1)[,list(group=layer[1]),by=source]


quantile(layer1$link,1:99/100)

threshold <-  50

layer1 <- layer1%>%filter(link>threshold)%>%mutate(link=link/threshold)%>%arrange(-link)

# cap link at 10*threshold
# layer1[layer1$link>10*threshold,]$link<-10*threshold
# OR FLATTEN LINK with log transformation and scale at 1.
layer1$log_link<-log(layer1$link)/log(threshold)

words <- levels(factor(c(layer1$source,layer1$target)))
name <- (1:length(words))-1
names(name)<-words
name_df <- data.frame(names=words,id=unname(name))
MisNodes <- data.frame(name=factor(x=name_df$id,labels=name_df$names),size=1)
MisNodes<- merge(MisNodes,node_group,by.x="name",by.y="source",all.x=T)
MisNodes[is.na(MisNodes$group),]$group=2
network_with_id <- merge(layer1,name_df,by.x="source",by.y="names")
network_with_id <- network_with_id%>%rename(source_id=id)
network_with_id <- merge(network_with_id,name_df,by.x="target",by.y="names")
network_with_id <- network_with_id%>%rename(target_id=id)

# use node_size of target,
# check sd to make sure it is always the same,
# scale to 1 (/100),
# set not computed node_size to 1 (and check why it's unknown).

forceNetwork(Links = network_with_id, Nodes = MisNodes, Source = "source_id",
             Target = "target_id", Value = "link", NodeID = "name",
             Group = "group", opacity = 0.9, zoom = TRUE,legend = paste0("layer", 1:5))

# layer1_layer3


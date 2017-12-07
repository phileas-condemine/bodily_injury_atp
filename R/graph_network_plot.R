library(networkD3)
library(dplyr)
library(magrittr)
load("temp_data/network_layers1234/network_nearest_neighbors_layers1234_ipp.RData")
# data(MisLinks)
# data(MisNodes)
network_nearest_neighbors_50 <- rbind(cbind(network_nearest_neighbors_50_layer1,layer=1),
                                      cbind(network_nearest_neighbors_50_layer2,layer=2),
                                      cbind(network_nearest_neighbors_50_layer3,layer=3),
                                      cbind(network_nearest_neighbors_50_layer4,layer=4))
quantile(network_nearest_neighbors_50$link,1:99/100)

threshold <-  50

network_nearest_neighbors_50 <- network_nearest_neighbors_50%>%filter(link>threshold)%>%mutate(link=link/threshold)%>%arrange(-link)

# cap link at 10*threshold
# network_nearest_neighbors_50[network_nearest_neighbors_50$link>10*threshold,]$link<-10*threshold
# OR FLATTEN LINK with log transformation and scale at 1.
network_nearest_neighbors_50$log_link<-log(network_nearest_neighbors_50$link)/log(threshold)

words <- levels(factor(c(network_nearest_neighbors_50$source,network_nearest_neighbors_50$target)))
name <- (1:length(words))-1
names(name)<-words
name_df <- data.frame(names=words,id=unname(name))
MisNodes <- data.frame(name=factor(x=name_df$id,labels=name_df$names),group=1,size=1)
network_with_id <- merge(network_nearest_neighbors_50,name_df,by.x="source",by.y="names")
network_with_id <- network_with_id%>%rename(source_id=id)
network_with_id <- merge(network_with_id,name_df,by.x="target",by.y="names")
network_with_id <- network_with_id%>%rename(target_id=id)

# use node_size of target,
# check sd to make sure it is always the same,
# scale to 1 (/100),
# set not computed node_size to 1 (and check why it's unknown).

forceNetwork(Links = network_with_id, Nodes = MisNodes, Source = "source_id",
             Target = "target_id", Value = "link", NodeID = "name",
             Group = "group", opacity = 0.9, zoom = TRUE)

# network_nearest_neighbors_50_layer3


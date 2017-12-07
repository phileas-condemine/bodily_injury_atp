# find articles quoted
load("Documents/bodily_injury_atp/data/CAPP_1ST_2ND_INSTANCES/CAPP_text_extraction.RData")
n_cores=28
splits <- split(1:length(CAPP_docs),1:(10*n_cores))
articles_found<-parallel::mclapply(splits,FUN=function(x){
  # x=splits[[1]]
  articles_indices <- regexpr(text = CAPP_docs[x],pattern = "(article|articles|art\\.)((( )|[A-z]|( )){0,})([0-9]+)")
  to_be_extracted <- data.frame(docs=CAPP_docs[x],index=articles_indices,len=attr(articles_indices,"match.length"))
  to_be_extracted <- to_be_extracted[to_be_extracted$index>0,]
  articles_extracted <- apply(to_be_extracted,1,FUN = function(x){
    return(substr(x = x[1],start = as.numeric(x[2]),stop = as.numeric(x[2])+as.numeric(x[3])-1))
  })
  articles_extracted <- unname(c(articles_extracted))
  return(articles_extracted)
  # table(articles_extracted)
})

freq_articles<-table(unname(unlist(articles_found)))

freq_articles<-freq_articles[order(freq_articles,decreasing=T)]
head(freq_articles,20)

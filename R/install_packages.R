packages_list=c("knitr","codetools","devtools","data.table",
"tm","SnowballC","xml2","rvest","tidyverse","stringr",
"magrittr","hexView","httr","jsonlite","pbapply","wordcloud",
"text2vec","xgboost","LDAvis","topicmodels")


for (pkg in packages_list){
  print(paste0("check: ",pkg))
if(!require(pkg,character.only = T)){
  print(paste0("need to install: ",pkg))
  install.packages(pkg)
}
library(pkg,character.only = T)
}

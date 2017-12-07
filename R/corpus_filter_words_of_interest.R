load("data/CAPP_1ST_2ND_INSTANCES/CAPP_text_extraction.RData")
#careful mma & gmf & gan & axa can't be found and sequences of words need to be adapted in 
# the files that were processed to remove token of length <=3
words_of_interest <- c("corporel","dommage corporel","reparation dommage corporel", "prejudice", 
                       "tierce", "tierce personne","assistance","assistance tierce personne","domicile",
                        "soin","infirmier","qualifie","invalidite","invalidite physique","incapacite","incapacite physique",
                       "incapacite totale travail",#ITT, noter que j'ai supprimer le "de" parce que les mots de moins de 3 lettres sont omis
                       "frais medicaux","sequelles","stabilisation sequelle","arret travail",
                       "recours indemnite", "litige","gravite", #source de mots clefs https://justice.ooreka.fr/astuce/voir/472289/dommage-corporel
                       "pretium doloris","prejudice esthetique","prejudice agrement","prejudice morphologique",
                       "reparation integrale prejudice",#https://www.dictionnaire-juridique.com/definition/dommage.php
                       "mutuelle","assurance",
                       "allianz","generali","zurich","matmut","pacifica","credit agricole","axa","gan","gmf",
                       "maif","macif","maaf","groupama","mutuelle generale","covea","aviva","eurofil",
                       "amaguiz","banque postale","olivier","direct assurance","assurpeople","allsecur","april","par ces motifs la cour")#https://www.index-assurance.fr/assureurs


grep_docs <- function(nm,docs){
  docs_with_word <- grep(pattern = nm,x = docs)
  len <- length(docs_with_word)
  if (len>0){
    return(sprintf("there are %s docs with the word %s, here is a sample of docs to check %s",len,toupper(nm),paste(head(docs_with_word,5),collapse = " ")))
  }
}
#no need to specify .packages because grep is part of base functions.
library(foreach)
library(doParallel)
cl <- makePSOCKcluster(25)
registerDoParallel(cl)
system.time(CAPP_docs_word_search<-foreach::foreach(nm = words_of_interest,.combine=c) %dopar% grep_docs(nm,CAPP_docs))
system.time(CASS_docs_word_search<-foreach::foreach(nm = words_of_interest,.combine=c) %dopar% grep_docs(nm,CASS_docs))
system.time(INCA_docs_word_search<-foreach::foreach(nm = words_of_interest,.combine=c) %dopar% grep_docs(nm,INCA_docs))
system.time(JADE_docs_word_search<-foreach::foreach(nm = words_of_interest,.combine=c) %dopar% grep_docs(nm,JADE_docs))
save(list=c("CAPP_docs_word_search","CASS_docs_word_search","INCA_docs_word_search","JADE_docs_word_search"),file="Documents/bodily_injury_atp/temp_data/all_docs_word_search.RData")
stopCluster(cl)

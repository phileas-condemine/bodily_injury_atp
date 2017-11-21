load("data/CAPP_1ST_2ND_INSTANCES/CAPP_text_extraction.RData")
#mma & gmf & gan & axa can't be found because I removed token of length <=3
words_of_interest <- c("corporel","dommage corporel","reparation dommage corporel", "prejudice", 
                       "tierce", "tierce personne","assistance","assistance tierce personne","domicile",
                        "soin","infirmier","qualifie","invalidite","invalidite physique","incapacite","incapacite physique",
                       "incapacite totale travail",#ITT, noter que j'ai supprimer le "de" parce que les mots de moins de 3 lettres sont omis
                       "frais medicaux","sequelles","stabilisation sequelle","arret travail",
                       "recours indemnite", "litige","gravite", #source de mots clefs https://justice.ooreka.fr/astuce/voir/472289/dommage-corporel
                       "pretium doloris","prejudice esthetique","prejudice agrement","prejudice morphologique",
                       "reparation integrale prejudice",#https://www.dictionnaire-juridique.com/definition/dommage.php
                       "mutuelle","assurance",
                       "allianz","generali","zurich","matmut","pacifica","credit agricole",
                       "maif","macif","maaf","groupama","mutuelle generale","covea","aviva","eurofil",
                       "amaguiz","banque postale","olivier","direct assurance","assurpeople","allsecur","april")#https://www.index-assurance.fr/assureurs
for (nm in words_of_interest){
  docs_with_word <- grep(pattern = nm,x = CAPP_docs)
  len <- length(docs_with_word)
  if (len>0){
    print(sprintf("there are %s docs with the word %s, here is a sample of docs to check %s",len,toupper(nm),paste(head(docs_with_word,5),collapse = " ")))
  }
}

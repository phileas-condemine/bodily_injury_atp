load("bodily_injury/temp_data/list_all_files.RData")

set.seed(1337)
doc_name1=CAPP_names[sample(1:length(CAPP_names),1)]
prepare_doc <- function(doc_name){
  one_doc <- xml2::read_xml(doc_name)
  one_doc <- xml2::xml_text(one_doc)
  one_doc <- tolower(one_doc)
  names_patterns <- c("é","è","ê","ë","à","â","ä","î","ï","ù","û","ü","\n","\t")
  patterns <- c("e","e","e","e","a","a","a","i","i","u","u","u"," "," ")
  names(patterns) <- names_patterns
  one_doc <- stringr::str_replace_all(one_doc,patterns)
  return(one_doc)
}
one_doc <- prepare_doc(doc_name1)

time_to_read_CAPP <- system.time(CAPP_docs <- pbapply::pbsapply(CAPP_names,prepare_doc))
print(time_to_read_CAPP)
save(list=c("CAPP_docs","time_to_read_CAPP"),file="bodily_injury/data/CAPP_1ST_2ND_INSTANCES/CAPP_text_extraction.RData")


words_of_interest <- c("corporel", "prejudice", "atp", "assistance", "tierce personne","assurance","axa", "tierce","soin","infirmier")
for (nm in words_of_interest){
  docs_with_word <- grep(pattern = nm,x = CAPP_docs)
  len <- length(docs_with_word)
  if (len>0){
    print(sprintf("there are %s docs with the word %s, here is a sample of docs to check %s",len,toupper(nm),paste(head(docs_with_word,5),collapse = " ")))
  }
}

# Next steps : 
# convert tolower and remove accents to ease search
# check the consistency of the schema to parse the data and extract the main content <CONTENU>
# check the docs with the words : corporel, préjudice, atp, assistance, personne, tierce

load("temp_data/list_all_files.RData")

set.seed(1337)
# doc_name1=CAPP_names[sample(1:length(CAPP_names),1)]
prepare_doc <- function(doc_name){
  one_doc <- xml2::read_xml(doc_name)
  one_doc <- xml2::xml_text(one_doc)
  one_doc <- tolower(one_doc)
  names_patterns <- c("é","è","ê","ë","à","â","ä","î","ï","ù","û","ü","\n","\t",",","'")
  patterns <- c("e","e","e","e","a","a","a","i","i","u","u","u"," "," ",""," ")
  names(patterns) <- names_patterns
  one_doc <- stringr::str_replace_all(one_doc,patterns)
  return(one_doc)
}
# one_doc <- prepare_doc(doc_name1)

# careful with the path, need to check if the root bodily-injury-ATP or smthg else
CAPP_names <- gsub(pattern = "/home/rstudio/bodily_injury/data",replacement = "data",x = CAPP_names)
time_to_read_CAPP <- system.time(CAPP_docs <- pbapply::pbsapply(CAPP_names,prepare_doc))
print(time_to_read_CAPP)
save(list=c("CAPP_docs","time_to_read_CAPP"),file="data/CAPP_1ST_2ND_INSTANCES/CAPP_text_extraction.RData")

CASS_names <- gsub(pattern = "/home/rstudio/bodily_injury/data",replacement = "data",x = CASS_names)
time_to_read_CASS <- system.time(CASS_docs <- pbapply::pbsapply(CASS_names,prepare_doc))
print(time_to_read_CASS)
save(list=c("CASS_docs","time_to_read_CASS"),file="data/CASSATION_BREAKING/RELEASED/CASS_text_extraction.RData")

INCA_names <- gsub(pattern = "/home/rstudio/bodily_injury/data",replacement = "data",x = INCA_names)
time_to_read_INCA <- system.time(INCA_docs <- pbapply::pbsapply(INCA_names,prepare_doc))
print(time_to_read_INCA)
save(list=c("INCA_docs","time_to_read_INCA"),file="data/CASSATION_BREAKING/UNRELEASED/INCA_text_extraction.RData")

JADE_names <- gsub(pattern = "/home/rstudio/bodily_injury/data",replacement = "data",x = JADE_names)
time_to_read_JADE <- system.time(JADE_docs <- pbapply::pbsapply(JADE_names,prepare_doc))
print(time_to_read_JADE)
save(list=c("JADE_docs","time_to_read_JADE"),file="data/JADE_ADMIN_COURT/JADE_text_extraction.RData")


# Next steps : 
# rerun and remove punctuation , . ; '
# check the consistency of the schema to parse the data and extract the main content <CONTENU>

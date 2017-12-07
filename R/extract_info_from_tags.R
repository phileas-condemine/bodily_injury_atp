library(parallel)
load("Documents/bodily_injury_atp/temp_data/list_all_files.RData")

n_cores=28
CAPP_tags <- c("DEMANDEUR","DEFENDEUR","PRESIDENT","AVOCAT_GL","AVOCATS","RAPPORTEUR","NUMERO_AFFAIRE","SOMMAIRE","SCT","CITATION_JP","LIENS","ORIGINE","JURIDICTION",
               "FORM_DEC_ATT","DATE_DEC","DATE_DEC_ATT","NATURE","SOLUTION","TITRE","FORMATION")

CASS_tags <- c("DEMANDEUR","DEFENDEUR","PRESIDENT","AVOCAT_GL","AVOCATS","RAPPORTEUR","NUMERO_AFFAIRE","SOMMAIRE","SCT","CITATION_JP","LIENS","ORIGINE","JURIDICTION",
               "FORM_DEC_ATT","DATE_DEC","DATE_DEC_ATT","NATURE","SOLUTION","PUBLI_BULL","TITRE","FORMATION")

INCA_tags <- c("DEMANDEUR","DEFENDEUR","PRESIDENT","AVOCAT_GL","AVOCATS","RAPPORTEUR","NUMERO_AFFAIRE","SOMMAIRE","SCT","CITATION_JP","LIENS","ORIGINE","JURIDICTION",
               "FORM_DEC_ATT","DATE_DEC","DATE_DEC_ATT","NATURE","SOLUTION","PUBLI_BULL","TITRE","FORMATION")

JADE_tags <- c("DEMANDEUR","DEFENDEUR","PRESIDENT","AVOCATS","RAPPORTEUR","COMMISSAIRE_GVT","NUMERO","SOMMAIRE","SCT","CITATION_JP","LIENS","ORIGINE","JURIDICTION",
               "FORM_DEC_ATT","DATE_DEC","DATE_DEC_ATT","NATURE","SOLUTION","PUBLI_BULL","TITRE","FORMATION")


tags_extracted <- tolower(CAPP_tags)
# set.seed(1337)
# doc_name=CAPP_names[sample(1:length(CAPP_names),1)]
extract_features_from_tags <- function(doc_name,tags_to_extract){
  one_doc <- xml2::read_xml(doc_name)
  tags_to_extract <- paste0(".//",tags_to_extract)
  features <- sapply(tags_to_extract,function(tag){
    return(paste0("",xml2::xml_text(xml2::xml_find_all(x=one_doc,xpath=tag)),collapse = ""))
  })
  return(c(doc_name,unname(features)))
}
extract_features_from_tags(doc_name,CAPP_tags)

############## CAPP ###############

# CAPP_names <- gsub(pattern = "/home/rstudio/bodily_injury/data",replacement = "data",x = CAPP_names)
# time_to_extract_features_CAPP <- system.time(CAPP_features <- pbapply::pbsapply(CAPP_names,extract_features_from_tags))
time_to_extract_features_CAPP <- system.time(CAPP_features <- parallel::mcmapply(CAPP_names,
                                                                                 FUN = function(x)extract_features_from_tags(x,CAPP_tags),mc.cores = n_cores))
time_to_extract_features_CAPP
CAPP_features <- data.frame(t(CAPP_features))
names(CAPP_features) <- c("doc_name",tags_extracted)
paste0(c("doc_name",tags_extracted)," ",round(100*apply(CAPP_features,2,function(x)sum(x==""))/length(CAPP_names)),"% missing")

############## CASS ###############



time_to_extract_features_CASS <- system.time(CASS_features <- parallel::mcmapply(CASS_names,
                                                                                 FUN = function(x)extract_features_from_tags(x,CASS_tags),mc.cores = n_cores))
time_to_extract_features_CASS
CASS_features <- data.frame(t(CASS_features))
names(CASS_features) <- c("doc_name",tags_extracted)
paste0(c("doc_name",tags_extracted)," ",round(100*apply(CASS_features,2,function(x)sum(x==""))/length(CASS_names)),"% missing")


############## INCA ###############


time_to_extract_features_INCA <- system.time(INCA_features <- parallel::mcmapply(INCA_names,
                                                                                 FUN = function(x)extract_features_from_tags(x,INCA_tags),mc.cores = n_cores))
time_to_extract_features_INCA
INCA_features <- data.frame(t(INCA_features))
names(INCA_features) <- c("doc_name",tags_extracted)
paste0(c("doc_name",tags_extracted)," ",round(100*apply(INCA_features,2,function(x)sum(x==""))/length(INCA_names)),"% missing")

############## JADE ###############


time_to_extract_features_JADE <- system.time(JADE_features <- parallel::mcmapply(JADE_names,
                                                                                 FUN = function(x)extract_features_from_tags(x,JADE_tags),mc.cores = n_cores))
time_to_extract_features_JADE
JADE_features <- data.frame(t(JADE_features))
names(JADE_features) <- c("doc_name",tags_extracted)
paste0(c("doc_name",tags_extracted)," ",round(100*apply(JADE_features,2,function(x)sum(x==""))/length(JADE_names)),"% missing")


save(list=c("CAPP_features","CASS_features","INCA_features","JADE_features"),file="Documents/bodily_injury_atp/temp_data/extracted_features.RData")

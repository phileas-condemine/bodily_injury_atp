load("temp_data/list_all_files.RData")

set.seed(1337)
# doc_name=CAPP_names[sample(1:length(CAPP_names),1)]
extract_features_from_tags <- function(doc_name){
  one_doc <- xml2::read_xml(doc_name)
  jurisdiction_second_trial <- xml2::xml_text(xml2::xml_find_all(x=one_doc,xpath=".//JURIDICTION"))
  jurisdiction_first_trial <- xml2::xml_text(xml2::xml_find_all(x=one_doc,xpath=".//FORM_DEC_ATT"))
  date_of_second_trial <- xml2::xml_text(xml2::xml_find_all(x=one_doc,xpath=".//DATE_DEC"))
  data_of_first_trial <- xml2::xml_text(xml2::xml_find_all(x=one_doc,xpath=".//DATE_DEC_ATT"))
  type_of_decision <- xml2::xml_text(xml2::xml_find_all(x=one_doc,xpath=".//NATURE"))
  output <- xml2::xml_text(xml2::xml_find_all(x=one_doc,xpath=".//SOLUTION"))
  features <- c(jurisdiction_second_trial,
                jurisdiction_first_trial,
                date_of_second_trial,
                data_of_first_trial,
                type_of_decision,
                output)
  return(features)}


CAPP_names <- gsub(pattern = "/home/rstudio/bodily_injury/data",replacement = "data",x = CAPP_names)
time_to_extract_features_CAPP <- system.time(CAPP_features <- pbapply::pbsapply(CAPP_names,extract_features_from_tags))
CAPP_features <- t(matrix(CAPP_features,nrow = 6))
names(CAPP_features) <- c("jurisdiction_second_trial",
                          "jurisdiction_first_trial",
                          "date_of_second_trial",
                          "data_of_first_trial",
                          "type_of_decision",
                          "output")
apply(CAPP_features,2,function(x)sum(x==""))

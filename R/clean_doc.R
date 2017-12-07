clean_doc <- function(docs){
  docs <- tolower(docs)
  names_patterns <- c("x\\.\\.\\.","y\\.\\.\\.","z\\.\\.\\.","É","é","è","ê","ë","à","â","ä","î","ï","ù","û","ü","\n","\t",",","'",":",";","-","\\.","/")
  patterns <- c("anonymat","anonymat","anonymat","E","e","e","e","e","a","a","a","i","i","u","u","u"," "," ",""," ","",""," ","","")
  names(patterns) <- names_patterns
  docs <- stringr::str_replace_all(docs,patterns)
  docs <- tm::stripWhitespace(docs)# alternative is gsub on pattern "[:space:]+"
  return(docs)
}
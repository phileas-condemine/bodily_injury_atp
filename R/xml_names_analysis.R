
##### CAPP

### Are there non xml files ?
not_xml_CAPP <- system("find /home/rstudio/bodily_injury/data/CAPP_1ST_2ND_INSTANCES -not -name *.xml -type f",intern = TRUE)
# I used -type f argument to select only files ie no directory paths
# Only docs, no other files

### xml files
CAPP_names <- system("find /home/rstudio/bodily_injury/data/CAPP_1ST_2ND_INSTANCES/ -name *.xml -type f",intern = TRUE)

JURITEXT_position <- regexpr(pattern = "JURITEXT",text = CAPP_names)

CAPP_names_nopath <- apply(data.frame(names = CAPP_names,position=JURITEXT_position+8),1,
       function(x){
         substr(x[1],x[2],stringr::str_length(x[1]))
         })
CAPP_names_nopath <- as.numeric(gsub(pattern = ".xml",replacement = "",x = CAPP_names_nopath))
#no warnings, it means everything went well and all names have this pattern JURITEXT + ID
head(CAPP_names_nopath)
plot(CAPP_names_nopath)



##### BREAKING - RELEASED

### Are there non xml files ?
not_xml_CASS <- system("find /home/rstudio/bodily_injury/data/CASSATION_BREAKING/RELEASED/ -not -name *.xml -type f",intern = TRUE)
# Only docs, no other files

### xml files
CASS_names <- system("find /home/rstudio/bodily_injury/data/CASSATION_BREAKING/RELEASED/ -name *.xml -type f",intern = TRUE)

JURITEXT_position <- regexpr(pattern = "JURITEXT",text = CASS_names)

CASS_names_nopath <- apply(data.frame(names = CASS_names,position=JURITEXT_position+8),1,
                           function(x){
                             substr(x[1],x[2],stringr::str_length(x[1]))
                           })
CASS_names_nopath <- as.numeric(gsub(pattern = ".xml",replacement = "",x = CASS_names_nopath))
#no warnings, it means everything went well and all names have this pattern JURITEXT + ID
head(CASS_names_nopath)
plot(CASS_names_nopath)



##### BREAKING - UNRELEASED

### Are there non xml files ?
not_xml_INCA <- system("find /home/rstudio/bodily_injury/data/CASSATION_BREAKING/UNRELEASED/ -not -name *.xml -type f",intern = TRUE)
# Only docs, no other files

### xml files
INCA_names <- system("find /home/rstudio/bodily_injury/data/CASSATION_BREAKING/UNRELEASED/ -name *.xml -type f",intern = TRUE)

JURITEXT_position <- regexpr(pattern = "JURITEXT",text = INCA_names)

INCA_names_nopath <- apply(data.frame(names = INCA_names,position=JURITEXT_position+8),1,
                           function(x){
                             substr(x[1],x[2],stringr::str_length(x[1]))
                           })
INCA_names_nopath <- as.numeric(gsub(pattern = ".xml",replacement = "",x = INCA_names_nopath))
#no warnings, it means everything went well and all names have this pattern JURITEXT + ID
head(INCA_names_nopath)
plot(INCA_names_nopath)

##### ADMIN - JADE

### Are there non xml files ?
not_xml_JADE <- system("find /home/rstudio/bodily_injury/data/JADE_ADMIN_COURT/ -not -name *.xml -type f",intern = TRUE)
# Only docs, no other files

### xml files
JADE_names <- system("find /home/rstudio/bodily_injury/data/JADE_ADMIN_COURT/ -name *.xml -type f",intern = TRUE)

JURITEXT_position <- regexpr(pattern = "CETATEXT",text = JADE_names)
sum(JURITEXT_position<0)
# 0 indicated the pattern is always found.

JADE_names_nopath <- apply(data.frame(names = JADE_names,position=JURITEXT_position+8),1,
                           function(x){
                             substr(x[1],x[2],stringr::str_length(x[1]))
                           })
JADE_names_nopath <- as.numeric(gsub(pattern = ".xml",replacement = "",x = JADE_names_nopath))
#no warnings, it means everything went well and all names have this pattern CETATEXT + ID
head(JADE_names_nopath)
plot(JADE_names_nopath)

save(list=c("CAPP_names","CASS_names","INCA_names","JADE_names"),file = "bodily_injury/temp_data/list_all_files.RData")

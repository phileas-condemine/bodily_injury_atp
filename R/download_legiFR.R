library(xml2)
library(magrittr)
library(rvest)
data_path <- "data/CASSATION_BREAKING/RELEASED/"
temp_data_path <- "temp_data/"
url_https_cass_list <- "https://echanges.dila.gouv.fr/OPENDATA/CASS/"
url_ftp_cass_list <- "ftp://echanges.dila.gouv.fr/CASS/"
# save(list="data_cass_list",file=paste0(temp_data_path,"data_cass_list.RData"))
data_cass_list <- xml2::read_html(url_https_cass_list)
table_of_downloads <- data_cass_list%>%
  rvest::html_node("table")%>%
  rvest::html_table(fill = T)
files_to_download <- table_of_downloads[,1]
files_to_download <- files_to_download[grep("*.tar.gz",files_to_download)]
# one_file_name=files_to_download[2]
download_files <- function(one_file_name){
dest <- paste0(data_path,one_file_name)
date_indices <- regexpr("_[0-9]{8}-[0-9]{6}",one_file_name)
one_file_date <- substr(x = one_file_name,start = date_indices[1]+1,stop = date_indices[1]+15)
if(length(grep(one_file_date,list.files(data_path)))==0){
download.file(url = paste0(url_https_cass_list,one_file_name),
              method = "libcurl",
              quiet = FALSE,
              destfile = dest)
}
system(sprintf("cd %s; tar -xvf %s;rm %s",data_path,one_file_name,one_file_name))
#then untar
# then remove
}

"ftp://echanges.dila.gouv.fr/CAPP/capp_20170227-213624.tar.gz"

# download.file(url = "ftp://echanges.dila.gouv.fr/CAPP/capp_20170227-213624.tar.gz",
#               method = "libcurl",
#               quiet = FALSE,
#               destfile = paste0(data_path,one_file))



### Need to find a way to extract the file in the folder where it is !
# system("find data -name *.tar.gz -exec tar xzvvf -C  {} \;")
# system("for file in `find data -name *.tar.gz`; do tar -xvf '${file}' ; done")

### read XML with R
# CAPP <- xml2::read_xml("data/CAPP_1ST_2ND_INSTANCES/Freemium_capp_global_20170227-083558.tar.gz")

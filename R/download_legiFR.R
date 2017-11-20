data_path <- "/home/rstudio/bodily_injury/data/"
temp_data_path <- "/home/rstudio/bodily_injury/temp_data/"
url_https_cass_list <- "https://echanges.dila.gouv.fr/OPENDATA/CAPP/"
url_ftp_cass_list <- "ftp://echanges.dila.gouv.fr/CAPP/"
# data_cass_list <- xml2::read_html(url_cass_list)
data_cass_list <- RCurl::getURLContent(url_cass_list)
save(list="data_cass_list",file=paste0(temp_data_path,"data_cass_list.RData"))
one_file="capp_20170227-213624.tar.gz"
download.file(url = paste0(url_cass_list,one_file),
              method = "libcurl",
              quiet = FALSE,
              destfile = paste0(data_path,one_file))


"ftp://echanges.dila.gouv.fr/CAPP/capp_20170227-213624.tar.gz"

download.file(url = "ftp://echanges.dila.gouv.fr/CAPP/capp_20170227-213624.tar.gz",
              method = "libcurl",
              quiet = FALSE,
              destfile = paste0(data_path,one_file))

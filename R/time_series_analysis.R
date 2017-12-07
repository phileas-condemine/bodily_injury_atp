load("Documents/bodily_injury_atp/temp_data/extracted_features.RData")
library(magrittr)
CAPP_dates<-as.Date(unname(CAPP_features$date_dec))
table(substr(CAPP_dates,1,4))%>%.[names(.)>2010]%>%.[names(.)<2018]

CASS_dates<-as.Date(unname(CASS_features$date_dec))
table(substr(CASS_dates,1,4))%>%.[names(.)>2010]%>%.[names(.)<2018]


INCA_dates<-as.Date(unname(INCA_features$date_dec))
table(substr(INCA_dates,1,4))%>%.[names(.)>2010]%>%.[names(.)<2018]


JADE_dates<-as.Date(unname(JADE_features$date_dec))
table(substr(JADE_dates,1,4))%>%.[names(.)>2010]%>%.[names(.)<2018]

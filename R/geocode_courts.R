load("Documents/bodily_injury_atp/temp_data/extracted_features.RData")
library(ggmap)

courts<-c()
courts=levels(factor(CAPP_features$juridiction))
courts=c(courts,levels(factor(CAPP_features$form_dec_att)))
courts=c(courts,levels(factor(INCA_features$form_dec_att)))
courts=c(courts,levels(factor(JADE_features$juridiction)))
source("Documents/bodily_injury_atp/R/clean_doc.R")
courts<-clean_doc(courts)
courts <- gsub("[0-9]{4} [0-9]{2} [0-9]{2}","",courts)
courts<-clean_doc(courts)
courts=unique(courts)
head(sample(courts),100)


grep(pattern="\\(",x=courts)
rgxpr<-regexpr(pattern="([a-z]|( ))*\\(",text=courts)

courts_without_chamber=apply(data.frame(text=courts,index=rgxpr,length=attr(rgxpr,"match.length"))[rgxpr>0,],1,function(x)substr(x[1],as.numeric(x[2]),as.numeric(x[2])+as.numeric(x[3])-2))
courts_without_chamber<-clean_doc(courts_without_chamber)
courts_without_chamber=unique(courts_without_chamber)
head(sample(courts_without_chamber),100)



geocoded_courts<-geocode(courts_without_chamber,output=c("latlon"))
save(list="geocoded_courts",file="Documents/bodily_injury_atp/temp_data/geocoded_courts.RData")
map<-get_map(location=na.omit(geocoded_courts)[1,],zoom=6)
ggmap(map)+geom_point(data=na.omit(geocoded_courts),aes(x=lon,y=lat))

mis_geocoded<-courts_without_chamber[is.na(geocoded_courts$lon)]
pattern=c("tribunal des affaires de securite sociale de ","tribunal des affaires de securite sociale d ",
          "tribunal mixte de commerce de ","tribunal mixte de commerce d ",
          "tribunal superieur d appel de ","tribunal superieur d appel d ",
          "tribunal du contentieux de l incapacite de ","tribunal du contentieux de l incapacite d ",
          "tribunal de grande instance de ","tribunal de grande instance d ",
          "tribunal de commerce de ","tribunal de commerce d ",
          "tribunal d instance de ","tribunal d instance du ","tribunal d instance d ",
          "conseil de prud hommes de ","conseil de prud hommes d ",
          "cour d appel de ","cour d appel du ","cour d appel d ",
          "commission d indemnisation des victimes d infraction du ","commission d indemnisation des victimes d infraction de ","commission d indemnisation des victimes d infraction d ")
to_replace=rep(times=length(pattern),"")
names(to_replace)<-pattern
fix_misgeocoded<-stringr::str_replace_all(mis_geocoded,to_replace)
fix_misgeocoded<-unique(fix_misgeocoded)
fix_misgeocoded<-paste0(fix_misgeocoded,", France")
head(sample(fix_misgeocoded),20)


geocoded_courts_batch2<-geocode(fix_misgeocoded,output=c("latlon"))
mis_geocoded_again<-fix_misgeocoded[is.na(geocoded_courts_batch2$lon)]

############ alternative, use adresse.data.gouv.fr/csv

# courts_without_chamber_France<-paste0(courts_without_chamber,", France")
# write.csv(courts_without_chamber_France,file="Documents/bodily_injury_atp/temp_data/courts_to_geocode.csv")

geocoded<-read.csv2("Documents/bodily_injury_atp/temp_data/courts_to_geocode.geocoded.csv")
sum(geocoded$latitude=="")
geocoded$latitude=as.numeric(as.character(geocoded$latitude))
geocoded$longitude=as.numeric(as.character(geocoded$longitude))

############ alternative, use galichon.com/codesgeo
ville<-readxl::read_xls("Documents/bodily_injury_atp/temp_data/ville.xls")
ville$MAJ<-tolower(ville$MAJ)
mis_geocoded_datagouv<-geocoded[is.na(geocoded$longitude),]$x
mis_geocoded_datagouv<-gsub(" , France","",mis_geocoded_datagouv)
mis_geocoded_datagouv<-stringr::str_replace_all(mis_geocoded_datagouv,to_replace)
ville_names<-ville$MAJ
ville_names<-ville_names[order(stringr::str_length(ville_names),decreasing=T)]
ville_patterns<-c(paste0(" ",ville_names," "),paste0("^",ville_names," "),paste0(" ",ville_names,"$"),paste0("^",ville_names,"$"))

has_matched<-unlist(sapply(ville_patterns,function(x){
  matched=grep(pattern=x,mis_geocoded_datagouv)
  if (length(matched)>0){
    return(mis_geocoded_datagouv[matched])
  }
}
))
has_matched<-has_matched[!is.na(has_matched)]
has_matched<-data.frame(misgeocoded=has_matched,ville_galichon=names(has_matched))
has_matched$ville_galichon=gsub("\\^"," ",has_matched$ville_galichon)
has_matched$ville_galichon=gsub("\\$"," ",has_matched$ville_galichon)
has_matched$ville_galichon=gsub("^ ","",has_matched$ville_galichon)
has_matched$ville_galichon=gsub(" $","",has_matched$ville_galichon)
has_matched$ville_galichon=gsub("[0-9]","",has_matched$ville_galichon)
has_matched_enriched=merge(has_matched,ville,by.x="ville_galichon",by.y="MAJ",all.x=F,all.y=F)
original_name=data.frame(origin=geocoded[is.na(geocoded$longitude),]$x,transform=mis_geocoded_datagouv)
has_matched_enriched=merge(has_matched_enriched,original_name,by.x="misgeocoded",by.y="transform")
setnames(has_matched_enriched,c("Longitude","Latitude","origin"),c("longitude","latitude","x"))
has_matched_enriched=has_matched_enriched%>%select(longitude,latitude,x)
geocoded_fixed=merge(geocoded,has_matched_enriched,by="x")
geocoded_fixed[is.na(geocoded_fixed$longitude.x),]$longitude.x=geocoded_fixed$longitude.y
geocoded_fixed[is.na(geocoded_fixed$latitude.x),]$latitude.x=geocoded_fixed$latitude.y

geocoded_fixed$latitude.y=NULL
geocoded_fixed$longitude.y=NULL
head(geocoded_fixed)

sum(is.na(geocoded_fixed$latitude.x))

leaflet()%>%addTiles()%>%addMarkers(lng=geocoded$longitude,lat=geocoded$latitude,clusterOptions = markerClusterOptions())


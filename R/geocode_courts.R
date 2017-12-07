load("temp_data/extracted_features.RData")
library(ggmap)
library(leaflet)
library(dplyr)
library(data.table)

courts=levels(factor(CAPP_features$juridiction))
courts=c(courts,levels(factor(CAPP_features$form_dec_att)))
courts=c(courts,levels(factor(INCA_features$form_dec_att)))
courts=c(courts,levels(factor(JADE_features$juridiction)))
courts1=courts
source("R/clean_doc.R")
courts<-clean_doc(courts)
courts <- gsub("[0-9]{4} [0-9]{2} [0-9]{2}","",courts)
courts<-clean_doc(courts)
court_origin=data.frame(origin=courts1,transform=courts)
courts=unique(courts)
head(sample(courts),100)

# grep(pattern="\\(",x=courts)
rgxpr<-regexpr(pattern="([a-z]|( ))*\\(",text=courts)
courts_without_chamber=apply(data.frame(text=courts,index=rgxpr,length=attr(rgxpr,"match.length"))[rgxpr>0,],1,function(x)substr(x[1],as.numeric(x[2]),as.numeric(x[2])+as.numeric(x[3])-2))
courts_without_chamber1=courts_without_chamber
courts_without_chamber=clean_doc(courts_without_chamber)
courts_without_chamber_origin=data.frame(origin=courts_without_chamber1,transform=courts_without_chamber)
courts_without_chamber=unique(courts_without_chamber)
head(sample(courts_without_chamber),100)



# geocoded_courts<-geocode(courts_without_chamber,output=c("latlon"))
# save(list="geocoded_courts",file="Documents/bodily_injury_atp/temp_data/geocoded_courts.RData")
load("Documents/bodily_injury_atp/temp_data/geocoded_courts.RData")
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


# geocoded_courts_batch2<-geocode(fix_misgeocoded,output=c("latlon"))
# mis_geocoded_again<-fix_misgeocoded[is.na(geocoded_courts_batch2$lon)]
# Still 208 not geocoded


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
ville<-ville%>%select(Latitude,Longitude,MAJ)
ville$Latitude=as.numeric(ville$Latitude)
ville$Longitude=as.numeric(ville$Longitude)
ville<-na.omit(ville)
ville<-data.table(ville)[,list("longitude"=Longitude[1],"latitude"=Latitude[1]),by=MAJ]
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
# has_matched$ville_galichon=gsub("\\^"," ",has_matched$ville_galichon)
# has_matched$ville_galichon=gsub("\\$"," ",has_matched$ville_galichon)
# has_matched$ville_galichon=gsub("^ ","",has_matched$ville_galichon)
# has_matched$ville_galichon=gsub(" $","",has_matched$ville_galichon)
# has_matched$ville_galichon=gsub("[0-9]","",has_matched$ville_galichon)
to_replace=c(" "," ", "","","")
names(to_replace)<-c("\\^","\\$","^ "," $","[0-9]")
has_matched$ville_galichon=stringr::str_replace_all(has_matched$ville_galichon,to_replace)
has_matched<-data.table(has_matched)
has_matched[,len:=stringr::str_length(ville_galichon)]
has_matched<-has_matched[order(has_matched$len,decreasing=T)]
has_matched<-has_matched[,.SD[1],by=misgeocoded]
# I don't really know why but this doesn't always work the first time so let's re-run the string normalization
has_matched$ville_galichon=stringr::str_replace_all(has_matched$ville_galichon,to_replace)
has_matched$ville_galichon=stringr::str_replace_all(has_matched$ville_galichon,to_replace)

head(has_matched$ville_galichon)
head(ville$MAJ)
has_matched_enriched=merge(has_matched,ville,by.x="ville_galichon",by.y="MAJ",all.x=F,all.y=F)
original_name=data.frame(origin=geocoded[is.na(geocoded$longitude),]$x,transform=mis_geocoded_datagouv)
has_matched_enriched=merge(has_matched_enriched,original_name,by.x="misgeocoded",by.y="transform")
setnames(has_matched_enriched,c("origin"),c("x"))
has_matched_enriched=has_matched_enriched%>%select(longitude,latitude,x)
geocoded_fixed=merge(geocoded,has_matched_enriched,by="x",all.x=T)
geocoded_fixed[is.na(geocoded_fixed$longitude.x),]$longitude.x=geocoded_fixed[is.na(geocoded_fixed$longitude.x),]$longitude.y
geocoded_fixed[is.na(geocoded_fixed$latitude.x),]$latitude.x=geocoded_fixed[is.na(geocoded_fixed$latitude.x),]$latitude.y

geocoded_fixed$latitude.y=NULL
geocoded_fixed$longitude.y=NULL
head(geocoded_fixed)

sum(is.na(geocoded_fixed$latitude.x))

geocoded_fixed$x=gsub(" , France"," ",geocoded_fixed$x)
geocoded_fixed$x=gsub(", France","",geocoded_fixed$x)
courts_without_chamber_origin$transform=as.character(courts_without_chamber_origin$transform)
# head(courts_without_chamber_origin$transform)
# head(geocoded_fixed$x)
# err<-geocoded_fixed$x[!geocoded_fixed$x%in%courts_without_chamber_origin$transform]
# err
geocoded_fixed_temp=merge(geocoded_fixed,courts_without_chamber_origin,by.x="x",by.y="transform")
geocoded_fixed_temp=merge(court_origin,geocoded_fixed_temp,by.y="origin",by.x="transform",all.y=F,all.x=F)
head(geocoded_fixed_temp)

geocoded_and_stats<-data.table(geocoded_fixed_temp)[,list(volume=.N,nb_instances=length(unique(origin)),longitude=longitude.x[1],latitude=latitude.x[1]),by=transform]

save(list="geocoded_and_stats",file="temp_data/geocoded_and_stats.RData")
leaflet()%>%addTiles()%>%addMarkers(lng=as.numeric(geocoded_and_stats$longitude),
                                    lat=as.numeric(geocoded_and_stats$latitude),
                                    popup=paste(geocoded_and_stats$transform,"\n number of cases",geocoded_and_stats$volume,"\n number of different names",geocoded_and_stats$nb_instances),
                                    clusterOptions = markerClusterOptions())




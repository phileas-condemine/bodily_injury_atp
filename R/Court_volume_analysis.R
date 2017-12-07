# Analyse des répartitions par cour / tribunal / chambre
load("temp_data/extracted_features.RData")
names(CAPP_features)
CAPP_court_freq=table(CAPP_features$juridiction)
head(data.frame(CAPP_court_freq[order(CAPP_court_freq,decreasing=T)]),10)

CASS_court_capp_freq=table(CAPP_features$form_dec_att)
head(data.frame(CASS_court_capp_freq[order(CASS_court_capp_freq,decreasing=T)]),10)

INCA_court_capp_freq=table(INCA_features$form_dec_att)
head(data.frame(INCA_court_capp_freq[order(INCA_court_capp_freq,decreasing=T)]),10)

JADE_court_freq=table(JADE_features$juridiction)
head(data.frame(JADE_court_freq[order(JADE_court_freq,decreasing=T)]),10)

The purpose of this study is to identify a specific injury type : (nursing) care service to a third person.

# Data
The data used are all open data from legifrance.
We will investigate the information from different courts
<ul>
<li>
  <a href="https://www.data.gouv.fr/fr/datasets/capp/">
  First (première instance) and Second (appel) degree instances
  </a>
<li>
  <a href="https://www.data.gouv.fr/fr/datasets/cass/">
  Released decisions from breaking (cassation) court
  </a>
<li>
  <a href="https://www.data.gouv.fr/fr/datasets/inca/">
  Unreleased decisions from breaking (cassation) court
  </a>
<li>
  <a href="https://www.data.gouv.fr/fr/datasets/jade/">
  Administrative court instances
  </a>
</ul>

# About the different courts

<ul>
<li>
First (première instance) and second (appel) degree instances are working on the case itself.
<li>
Breaking (cassation) court is higher than first & second degree instances, its role is to judge the decision of the second degree instance (appel).
<br>
If the breaking court breaks the second degree instance decision, then the judgement is <b>sent back</b> to a second degree instance (cour d'appel de renvoi).
<li>Administrative court instances handle trials where <a href="https://www.service-public.fr/particuliers/vosdroits/F2025"> public administration is involved </a>
</ul>

# Work environment :
To make sure anyone can reproduce this work, I used a docker container based on <b>rocker/rstudio</b> image.<br>
One can reproduce it following the step in the readme of <a href="https://github.com/phileas-condemine/text-mining"> this repo.</a> <br>
For basic read/write operations, using docker containers running locally can be much slower than running the operations locally.<br>
For example it's x4 slower (CAPP 5 mins vs 20 mins, JADE 25 mins vs 2 hours) for xml_check_quality.R >> prepare_doc().<br>
Thus most data prep operations were run locally.<br>
Given the amount of data, the RAM gets saturated very fast then even the swaps gets to fill the harddrive. Therefore I tried to use cloud virtual machines.<br>
I have an Azure professional account so I'd rather use Azure even though there are less tutorial and forums that for AWS and GoogleCloud.<br>
First I tried basic ubuntu VM. By default, they can only be accessed through X2GO. It is very slow.<br>
Then I tried to create an Azure Container Service but I needed a <a href="https://docs.microsoft.com/fr-fr/azure/container-service/kubernetes/container-service-kubernetes-service-principal
">subscriptionID</a> to which I don't have access as I am a simple user of the company license.<br>
Then I tried Data Science Virtual Machine on Linux. Unfortunately it also goes with X2GO. Good knews is many things are already installed including R/RStudio. But R is not up to date...<br>
Here you can find more information on how to connect using <a href="http://timmyreilly.azurewebsites.net/generating-an-ssh-key-and-using-in-on-azure/">SSH key pair</a> <br>
There might also be issues with the .ssh folder rights, <a href="https://unix.stackexchange.com/questions/36540/why-am-i-still-getting-a-password-prompt-with-ssh-with-public-key-authentication">here is a fix</a> <br>
More specifically :
<ul>
<li> connect to the VM side with the password and type
<ul>
<li> sudo chmod 700 ~/.ssh
<li> sudo chmod go-w ~
</ul>
<li> log in using the private key, not the .pub !!!
<li> error when trying to open connection between VM & data.gouv "Problem with SSL CA cert (path ? access rights ?)". <br> It's difficult to find similar error amongst R users community because it is specific to the fact we use a VM. <a href="https://serverfault.com/questions/722796/install-ssl-certificate-on-azure-cloud-service-vm"> here </a> are some useful info. We need to install an SSL cert on the VM. <br>
Here is the offered solution with DigiCert ($$$) <a href="https://www.digicert.com/ssl-certificate-installation-apache.htm"> Apache SSL </a> and <a href="https://www.digicert.com/csr-creation-apache.htm"> openSSL </a> also we may need to <a href="https://docs.microsoft.com/en-us/azure/virtual-network/virtual-networks-reserved-public-ip">reserve the IP</a> <br>
An alternative is to use <a href="https://letsencrypt.org/getting-started/">let's encrypt</a>.<br>
<b>Finally I found an alternative to these painful steps, use wget instead of curl !</b>
<li>
</ul>


# data size
Here is the number of XML files in each dataset on 27-02-2017 <br>
<ul>
<li> CAPP (1st & 2nd instances) 63340 (+900 updates) xml documents. 78M tokens of length >3. 1,2M different tokens (not all of them are words).
<li> BREAKING (cassation) - RELEASED 134217 (+4000 updates) xml documents
<li> BREAKING (cassation) - UNRELEASED (inédits) 330923 (+7000 updates) xml documents
<li> JADE (admin) 401514 (+48000 updates) xml documents
</ul>
To get more data, one needs to download the daily releases and merge them to the dataset.<br>
When checking data quality, we also made sure there are no other files than .xml. See xml_names_analysis.R <br>

# data preparation

## main steps
<ul>
<li> data are xml and text should thus be parsed.
<li> data include dates, figures and text that should be treated differently.
<li> text should be standardized in a format easier to handle :
<ul>
<li> remove accents : DONE
<li> remove punctuation : coma, dots, colons, semi-colons, apostrophe... : DONE
<li> set every letters to lower case : DONE
<li> identify stopwords and remove them : TBD based on termFreq
<li> identify and fix misspellings : TBD
</ul>
<li> documents should be filtered based on keywords defined with business back-up
<li> digits tokens should be parsed and formatted whether they are dates/times, money amounts, hours/durations, kilometers/distances, frequency. This can be induced by the context (surrounding words) and is not trivial to handle.
<li> another important feature is the court that handled the case. According to the schema this should be inside JURIDICTION and FORM_DEC_ATT tags. it should be easy to parse.
<li> find out which party won the CASS_text_extraction
<li> extract decisions looking more specifically at the end of the documents and checking the sentences that start with "condamne", "admet", "deboute", "dit", "infirme". Decisions are usually introduced by a
"PAR CES MOTIFS LA COUR". it can be found in 28360 cases out of 63340 for CAPP.
<li> Another pattern to identify is the list of the amounts like in this <a href="https://www.legifrance.gouv.fr/affichJuriJudi.do?oldAction=rechExpJuriJudi&idTexte=JURITEXT000034286659&fastReqId=2093206124&fastPos=20"> doc </a> or this <a href="https://www.legifrance.gouv.fr/affichJuriJudi.do?oldAction=rechExpJuriJudi&idTexte=JURITEXT000031849603&fastReqId=1691567375&fastPos=53"> doc </a>
</ul>

## scripts order
<ol>
<li> use R/download_legiFR.R to get the data from data.gouv.fr
<li> use R/xml_names_analysis.R to make sure there are only xml files with a consistent pattern of naming
<li> use R/xml_check_quality.R to clean the documents and extract the body/main content of the xml documents
<li> use R/corpus_filter_words_of_interest.R to check the number of docs that have a given word or series of words.
<li> use R/word_count.R to tokenize the corpus and check termfreq
</ol>

## frequent words / stop keywords
If the case refers to a person (personne physique) rather than a company or another moral entity, then it is anonymized and the person will be refered as "x...". After I remove punctuation and less than 4 letters tokens, this "x..." disappeared.
<ul>
<li>         dans 61957
<li>        appel 61947
<li>    procedure 61631
<li>         code 61582
<li>         pour 61334
<li>      article 61098
<li>         cour 60811
<li>     decision 60451
<li>       motifs 60441
<li>      parties 59045
<li>     audience 58918
<li>     greffier 58796
<li>        cette 57918
<li>      demande 57754
<li>    president 57532
<li>        arret 57190
<li>         fait 57165
<li>         lors 57078
<li>      chambre 56660
<li> dispositions 56239
</ul>

## documents filtering based on keywords

<ul>
<li> 1st & 2nd instance
<ul>
<li> "there are 2622 docs with the word CORPOREL, here is a sample of docs to check 51 59 128 130 131"                           
<li> "there are 123 docs with the word DOMMAGE CORPOREL, here is a sample of docs to check 59 510 541 1013 1245"                 
<li> "there are 1 docs with the word REPARATION DOMMAGE CORPOREL, here is a sample of docs to check 61626"                       
<li> "there are 29605 docs with the word PREJUDICE, here is a sample of docs to check 1 8 9 11 18"                               
<li> "there are 1474 docs with the word TIERCE, here is a sample of docs to check 23 45 86 187 191"                              
<li> "there are 812 docs with the word TIERCE PERSONNE, here is a sample of docs to check 86 187 191 365 392"                    
<li> "there are 4752 docs with the word ASSISTANCE, here is a sample of docs to check 21 28 30 31 32"                            
<li> "there are 58 docs with the word ASSISTANCE TIERCE PERSONNE, here is a sample of docs to check 7122 14981 16218 20289 20622"
<li> "there are 11641 docs with the word DOMICILE, here is a sample of docs to check 17 26 38 45 63"                             
<li> "there are 18470 docs with the word SOIN, here is a sample of docs to check 1 7 8 15 19"                                    
<li> "there are 673 docs with the word INFIRMIER, here is a sample of docs to check 126 156 258 266 341"                         
<li> "there are 8378 docs with the word QUALIFIE, here is a sample of docs to check 31 51 53 58 95"                              
<li> "there are 1704 docs with the word INVALIDITE, here is a sample of docs to check 154 282 298 301 327"                       
<li> "there are 2 docs with the word INVALIDITE PHYSIQUE, here is a sample of docs to check 458 41144"                           
<li> "there are 4577 docs with the word INCAPACITE, here is a sample of docs to check 86 97 98 135 162"                          
<li> "there are 60 docs with the word INCAPACITE PHYSIQUE, here is a sample of docs to check 972 4150 4492 5430 7102"            
<li> "there are 953 docs with the word FRAIS MEDICAUX, here is a sample of docs to check 97 116 258 326 339"                     
<li> "there are 1180 docs with the word SEQUELLES, here is a sample of docs to check 86 187 258 304 362"                         
<li> "there are 28 docs with the word ARRET TRAVAIL, here is a sample of docs to check 1157 9656 13650 14446 23490"              
<li> "there are 24791 docs with the word LITIGE, here is a sample of docs to check 2 4 8 12 15"                                  
<li> "there are 3532 docs with the word GRAVITE, here is a sample of docs to check 21 35 45 154 182"                             
<li> "there are 969 docs with the word PRETIUM DOLORIS, here is a sample of docs to check 182 258 283 307 312"                   
<li> "there are 1380 docs with the word PREJUDICE ESTHETIQUE, here is a sample of docs to check 86 182 187 258 283"              
<li> "there are 7 docs with the word PREJUDICE AGREMENT, here is a sample of docs to check 8156 16218 37876 38389 40435"         
<li> "there are 5 docs with the word PREJUDICE MORPHOLOGIQUE, here is a sample of docs to check 21091 42481 51508 52699 57553"   
<li> "there are 2908 docs with the word MUTUELLE, here is a sample of docs to check 11 88 103 105 107"                           
<li> "there are 12303 docs with the word ASSURANCE, here is a sample of docs to check 2 3 8 11 32"                               
<li> "there are 352 docs with the word ALLIANZ, here is a sample of docs to check 2 3 825 1030 1159"                             
<li> "there are 1551 docs with the word GENERALI, here is a sample of docs to check 8 101 102 103 104"                           
<li> "there are 96 docs with the word ZURICH, here is a sample of docs to check 1027 1189 1327 2038 2426"                        
<li> "there are 145 docs with the word MATMUT, here is a sample of docs to check 541 548 630 788 966"                            
<li> "there are 57 docs with the word PACIFICA, here is a sample of docs to check 1700 2555 4097 7090 11658"                     
<li> "there are 1500 docs with the word CREDIT AGRICOLE, here is a sample of docs to check 17 19 39 54 101"                      
<li> "there are 2781 docs with the word AXA, here is a sample of docs to check 3 33 101 102 103"                                 
<li> "there are 21407 docs with the word GAN, here is a sample of docs to check 2 3 4 11 28"                                     
<li> "there are 149 docs with the word GMF, here is a sample of docs to check 121 153 1756 1827 1980"                            
<li> "there are 175 docs with the word MAIF, here is a sample of docs to check 314 542 549 630 1793"                             
<li> "there are 259 docs with the word MACIF, here is a sample of docs to check 374 504 894 1246 1318"                           
<li> "there are 283 docs with the word MAAF, here is a sample of docs to check 170 178 302 517 855"                              
<li> "there are 451 docs with the word GROUPAMA, here is a sample of docs to check 3 283 939 948 1058"                           
<li> "there are 81 docs with the word MUTUELLE GENERALE, here is a sample of docs to check 180 630 1161 2136 4324"               
<li> "there are 165 docs with the word COVEA, here is a sample of docs to check 8 11 103 105 107"                                
<li> "there are 301 docs with the word AVIVA, here is a sample of docs to check 162 257 284 314 370"                             
<li> "there are 12 docs with the word EUROFIL, here is a sample of docs to check 7252 10934 14333 18435 19785"                   
<li> "there are 133 docs with the word BANQUE POSTALE, here is a sample of docs to check 924 1378 2895 3242 10628"               
<li> "there are 3644 docs with the word OLIVIER, here is a sample of docs to check 17 22 28 37 45"                               
<li> "there are 18 docs with the word DIRECT ASSURANCE, here is a sample of docs to check 3977 4211 4221 6212 6752"              
<li> "there are 27 docs with the word APRIL, here is a sample of docs to check 1000 5092 12246 27055 27759"                      
<li> "there are 37779 docs with the word PAR CES MOTIFS LA COUR, here is a sample of docs to check 2 3 4 5 6"
</ul>
<li> breaking (cassation) instance released
<ul>
<li> "there are 2016 docs with the word CORPOREL, here is a sample of docs to check 9 62 109 125 127"                                 
<li> "there are 182 docs with the word DOMMAGE CORPOREL, here is a sample of docs to check 137 569 4741 5079 7148"                    
<li> "there are 27540 docs with the word PREJUDICE, here is a sample of docs to check 1 3 4 7 10"                                     
<li> "there are 1730 docs with the word TIERCE, here is a sample of docs to check 103 137 256 257 319"                                
<li> "there are 625 docs with the word TIERCE PERSONNE, here is a sample of docs to check 103 137 256 389 503"                        
<li> "there are 3801 docs with the word ASSISTANCE, here is a sample of docs to check 2 29 32 34 36"                                  
<li> "there are 25 docs with the word ASSISTANCE TIERCE PERSONNE, here is a sample of docs to check 137 256 389 36908 36941"          
<li> "there are 7085 docs with the word DOMICILE, here is a sample of docs to check 2 10 12 34 47"                                    
<li> "there are 15313 docs with the word SOIN, here is a sample of docs to check 2 6 10 12 13"                                        
<li> "there are 442 docs with the word INFIRMIER, here is a sample of docs to check 2 220 431 496 647"                                
<li> "there are 8960 docs with the word QUALIFIE, here is a sample of docs to check 2 3 20 22 34"                                     
<li> "there are 2545 docs with the word INVALIDITE, here is a sample of docs to check 105 155 207 227 243"                            
<li> "there are 1 docs with the word INVALIDITE PHYSIQUE, here is a sample of docs to check 97790"                                    
<li> "there are 4363 docs with the word INCAPACITE, here is a sample of docs to check 17 32 62 66 125"                                
<li> "there are 149 docs with the word INCAPACITE PHYSIQUE, here is a sample of docs to check 141 899 1064 1118 1396"                 
<li> "there are 563 docs with the word FRAIS MEDICAUX, here is a sample of docs to check 256 265 389 562 568"                         
<li> "there are 503 docs with the word SEQUELLES, here is a sample of docs to check 125 155 256 486 503"                              
<li> "there are 6 docs with the word ARRET TRAVAIL, here is a sample of docs to check 20000 20035 21100 21209 23211"                  
<li> "there are 19617 docs with the word LITIGE, here is a sample of docs to check 1 6 8 10 11"                                       
<li> "there are 3985 docs with the word GRAVITE, here is a sample of docs to check 32 35 108 111 113"                                 
<li> "there are 131 docs with the word PRETIUM DOLORIS, here is a sample of docs to check 201 338 562 568 878"                        
<li> "there are 186 docs with the word PREJUDICE ESTHETIQUE, here is a sample of docs to check 503 562 568 1111 1458"                 
<li> "there are 1 docs with the word PREJUDICE MORPHOLOGIQUE, here is a sample of docs to check 85225"                                
<li> "there are 11 docs with the word REPARATION INTEGRALE PREJUDICE, here is a sample of docs to check 37115 45799 52795 82477 84330"
<li> "there are 4439 docs with the word MUTUELLE, here is a sample of docs to check 42 56 61 103 129"                                 
<li> "there are 19056 docs with the word ASSURANCE, here is a sample of docs to check 10 33 34 36 50"                                 
<li> "there are 259 docs with the word ALLIANZ, here is a sample of docs to check 43 143 168 195 275"                                 
<li> "there are 1669 docs with the word GENERALI, here is a sample of docs to check 33 50 62 75 118"                                  
<li> "there are 209 docs with the word ZURICH, here is a sample of docs to check 393 2573 6347 18045 19383"                           
<li> "there are 87 docs with the word MATMUT, here is a sample of docs to check 13315 28942 29204 33130 34353"                        
<li> "there are 27 docs with the word PACIFICA, here is a sample of docs to check 35782 36850 37624 38275 40666"                      
<li> "there are 1238 docs with the word CREDIT AGRICOLE, here is a sample of docs to check 51 56 105 176 177"                         
<li> "there are 1733 docs with the word AXA, here is a sample of docs to check 62 78 80 110 125"                                      
<li> "there are 24695 docs with the word GAN, here is a sample of docs to check 1 3 9 11 14"                                          
<li> "there are 154 docs with the word GMF, here is a sample of docs to check 275 374 446 10305 10754"                                
<li> "there are 148 docs with the word MAIF, here is a sample of docs to check 103 138 451 11224 16816"                               
<li> "there are 182 docs with the word MACIF, here is a sample of docs to check 515 17352 18209 21313 21822"                          
<li> "there are 227 docs with the word MAAF, here is a sample of docs to check 323 451 528 536 3817"                                  
<li> "there are 227 docs with the word GROUPAMA, here is a sample of docs to check 36 354 359 389 16302"                              
<li> "there are 485 docs with the word MUTUELLE GENERALE, here is a sample of docs to check 56 1458 1854 2222 2321"                   
<li> "there are 70 docs with the word COVEA, here is a sample of docs to check 87 171 172 217 387"                                    
<li> "there are 108 docs with the word AVIVA, here is a sample of docs to check 51 160 179 376 404"                                   
<li> "there are 2 docs with the word EUROFIL, here is a sample of docs to check 36599 36855"                                          
<li> "there are 41 docs with the word BANQUE POSTALE, here is a sample of docs to check 15973 16682 17181 17473 35792"                
<li> "there are 714 docs with the word OLIVIER, here is a sample of docs to check 31 114 142 159 191"                                 
<li> "there are 4 docs with the word DIRECT ASSURANCE, here is a sample of docs to check 23529 25843 54438 82142"                     
<li> "there are 12 docs with the word APRIL, here is a sample of docs to check 259 17370 27143 37192 42653"                           
<li> "there are 519 docs with the word PAR CES MOTIFS LA COUR, here is a sample of docs to check 697 1044 1183 1207 1499"
</ul>
<li> breaking (cassation) instance unreleased (inedit)
<ul>
<li> "there are 4395 docs with the word CORPOREL, here is a sample of docs to check 75 116 132 133 134"                                  
<li> "there are 265 docs with the word DOMMAGE CORPOREL, here is a sample of docs to check 116 687 2148 2417 2520"                       
<li> "there are 65647 docs with the word PREJUDICE, here is a sample of docs to check 1 4 5 11 13"                                       
<li> "there are 3606 docs with the word TIERCE, here is a sample of docs to check 2 18 25 38 75"                                         
<li> "there are 1397 docs with the word TIERCE PERSONNE, here is a sample of docs to check 267 661 701 856 1000"                         
<li> "there are 9116 docs with the word ASSISTANCE, here is a sample of docs to check 6 23 41 63 80"                                     
<li> "there are 61 docs with the word ASSISTANCE TIERCE PERSONNE, here is a sample of docs to check 1362 2396 97446 97717 97756"         
<li> "there are 18615 docs with the word DOMICILE, here is a sample of docs to check 2 6 34 38 59"                                       
<li> "there are 30460 docs with the word SOIN, here is a sample of docs to check 4 5 10 15 18"                                           
<li> "there are 1504 docs with the word INFIRMIER, here is a sample of docs to check 108 164 171 174 221"                                
<li> "there are 24353 docs with the word QUALIFIE, here is a sample of docs to check 1 11 18 23 30"                                      
<li> "there are 5075 docs with the word INVALIDITE, here is a sample of docs to check 82 109 194 196 206"                                
<li> "there are 6 docs with the word INVALIDITE PHYSIQUE, here is a sample of docs to check 49823 89530 160802 173472 181611"            
<li> "there are 13158 docs with the word INCAPACITE, here is a sample of docs to check 38 43 47 114 126"                                 
<li> "there are 215 docs with the word INCAPACITE PHYSIQUE, here is a sample of docs to check 3241 4144 4547 4995 5016"                  
<li> "there are 828 docs with the word FRAIS MEDICAUX, here is a sample of docs to check 73 229 235 236 1441"                            
<li> "there are 1495 docs with the word SEQUELLES, here is a sample of docs to check 195 206 222 309 790"                                
<li> "there are 23 docs with the word ARRET TRAVAIL, here is a sample of docs to check 315 1757 5577 21646 24064"                        
<li> "there are 1 docs with the word RECOURS INDEMNITE, here is a sample of docs to check 3801"                                          
<li> "there are 53014 docs with the word LITIGE, here is a sample of docs to check 2 3 4 5 7"                                            
<li> "there are 11340 docs with the word GRAVITE, here is a sample of docs to check 13 26 30 35 37"                                      
<li> "there are 280 docs with the word PRETIUM DOLORIS, here is a sample of docs to check 1979 7561 11499 17272 23781"                   
<li> "there are 502 docs with the word PREJUDICE ESTHETIQUE, here is a sample of docs to check 195 546 1399 1831 1979"                   
<li> "there are 2 docs with the word PREJUDICE AGREMENT, here is a sample of docs to check 128057 145150"                                
<li> "there are 6 docs with the word PREJUDICE MORPHOLOGIQUE, here is a sample of docs to check 108126 165405 165632 173077 195034"      
<li> "there are 9 docs with the word REPARATION INTEGRALE PREJUDICE, here is a sample of docs to check 46018 118847 119173 129294 144128"
<li> "there are 10803 docs with the word MUTUELLE, here is a sample of docs to check 16 81 223 225 226"                                  
<li> "there are 46187 docs with the word ASSURANCE, here is a sample of docs to check 5 16 25 26 33"                                     
<li> "there are 1321 docs with the word ALLIANZ, here is a sample of docs to check 110 401 661 716 897"                                  
<li> "there are 3657 docs with the word GENERALI, here is a sample of docs to check 23 75 94 95 108"                                     
<li> "there are 500 docs with the word ZURICH, here is a sample of docs to check 194 195 196 1582 1942"                                  
<li> "there are 269 docs with the word MATMUT, here is a sample of docs to check 858 4267 4270 9021 23016"                               
<li> "there are 77 docs with the word PACIFICA, here is a sample of docs to check 856 1838 2024 2632 3873"                               
<li> "there are 5034 docs with the word CREDIT AGRICOLE, here is a sample of docs to check 68 96 149 165 294"                            
<li> "there are 6434 docs with the word AXA, here is a sample of docs to check 16 23 41 73 95"                                           
<li> "there are 136492 docs with the word GAN, here is a sample of docs to check 1 2 3 4 8"                                              
<li> "there are 560 docs with the word GMF, here is a sample of docs to check 675 1375 1937 2043 2394"                                   
<li> "there are 486 docs with the word MAIF, here is a sample of docs to check 1056 1866 1967 2520 4395"                                 
<li> "there are 669 docs with the word MACIF, here is a sample of docs to check 1385 1543 1668 1852 2438"                                
<li> "there are 1054 docs with the word MAAF, here is a sample of docs to check 71 435 588 1379 1393"                                    
<li> "there are 1009 docs with the word GROUPAMA, here is a sample of docs to check 60 583 632 1064 1065"                                
<li> "there are 683 docs with the word MUTUELLE GENERALE, here is a sample of docs to check 2327 3623 4991 5383 6173"                    
<li> "there are 241 docs with the word COVEA, here is a sample of docs to check 25 685 711 1241 1392"                                    
<li> "there are 334 docs with the word AVIVA, here is a sample of docs to check 16 1066 1073 1098 1368"                                  
<li> "there are 14 docs with the word EUROFIL, here is a sample of docs to check 109902 131884 132214 158553 162627"                     
<li> "there are 1 docs with the word AMAGUIZ, here is a sample of docs to check 110108"                                                  
<li> "there are 161 docs with the word BANQUE POSTALE, here is a sample of docs to check 89 294 363 890 1659"                            
<li> "there are 2890 docs with the word OLIVIER, here is a sample of docs to check 97 314 328 350 375"                                   
<li> "there are 12 docs with the word DIRECT ASSURANCE, here is a sample of docs to check 709 17592 19757 171701 184896"                 
<li> "there are 69 docs with the word APRIL, here is a sample of docs to check 1370 4768 8478 11373 15614"                               
<li> "there are 489 docs with the word PAR CES MOTIFS LA COUR, here is a sample of docs to check 42 398 571 2518 8499"
</ul>
<li> admin instance (JADE)
<ul>
<li> "there are 4395 docs with the word CORPOREL, here is a sample of docs to check 75 116 132 133 134"                                  
<li> "there are 265 docs with the word DOMMAGE CORPOREL, here is a sample of docs to check 116 687 2148 2417 2520"                       
<li> "there are 65647 docs with the word PREJUDICE, here is a sample of docs to check 1 4 5 11 13"                                       
<li> "there are 3606 docs with the word TIERCE, here is a sample of docs to check 2 18 25 38 75"                                         
<li> "there are 1397 docs with the word TIERCE PERSONNE, here is a sample of docs to check 267 661 701 856 1000"                         
<li> "there are 9116 docs with the word ASSISTANCE, here is a sample of docs to check 6 23 41 63 80"                                     
<li> "there are 61 docs with the word ASSISTANCE TIERCE PERSONNE, here is a sample of docs to check 1362 2396 97446 97717 97756"         
<li> "there are 18615 docs with the word DOMICILE, here is a sample of docs to check 2 6 34 38 59"                                       
<li> "there are 30460 docs with the word SOIN, here is a sample of docs to check 4 5 10 15 18"                                           
<li> "there are 1504 docs with the word INFIRMIER, here is a sample of docs to check 108 164 171 174 221"                                
<li> "there are 24353 docs with the word QUALIFIE, here is a sample of docs to check 1 11 18 23 30"                                      
<li> "there are 5075 docs with the word INVALIDITE, here is a sample of docs to check 82 109 194 196 206"                                
<li> "there are 6 docs with the word INVALIDITE PHYSIQUE, here is a sample of docs to check 49823 89530 160802 173472 181611"            
<li> "there are 13158 docs with the word INCAPACITE, here is a sample of docs to check 38 43 47 114 126"                                 
<li> "there are 215 docs with the word INCAPACITE PHYSIQUE, here is a sample of docs to check 3241 4144 4547 4995 5016"                  
<li> "there are 828 docs with the word FRAIS MEDICAUX, here is a sample of docs to check 73 229 235 236 1441"                            
<li> "there are 1495 docs with the word SEQUELLES, here is a sample of docs to check 195 206 222 309 790"                                
<li> "there are 23 docs with the word ARRET TRAVAIL, here is a sample of docs to check 315 1757 5577 21646 24064"                        
<li> "there are 1 docs with the word RECOURS INDEMNITE, here is a sample of docs to check 3801"                                          
<li> "there are 53014 docs with the word LITIGE, here is a sample of docs to check 2 3 4 5 7"                                            
<li> "there are 11340 docs with the word GRAVITE, here is a sample of docs to check 13 26 30 35 37"                                      
<li> "there are 280 docs with the word PRETIUM DOLORIS, here is a sample of docs to check 1979 7561 11499 17272 23781"                   
<li> "there are 502 docs with the word PREJUDICE ESTHETIQUE, here is a sample of docs to check 195 546 1399 1831 1979"                   
<li> "there are 2 docs with the word PREJUDICE AGREMENT, here is a sample of docs to check 128057 145150"                                
<li> "there are 6 docs with the word PREJUDICE MORPHOLOGIQUE, here is a sample of docs to check 108126 165405 165632 173077 195034"      
<li> "there are 9 docs with the word REPARATION INTEGRALE PREJUDICE, here is a sample of docs to check 46018 118847 119173 129294 144128"
<li> "there are 10803 docs with the word MUTUELLE, here is a sample of docs to check 16 81 223 225 226"                                  
<li> "there are 46187 docs with the word ASSURANCE, here is a sample of docs to check 5 16 25 26 33"                                     
<li> "there are 1321 docs with the word ALLIANZ, here is a sample of docs to check 110 401 661 716 897"                                  
<li> "there are 3657 docs with the word GENERALI, here is a sample of docs to check 23 75 94 95 108"                                     
<li> "there are 500 docs with the word ZURICH, here is a sample of docs to check 194 195 196 1582 1942"                                  
<li> "there are 269 docs with the word MATMUT, here is a sample of docs to check 858 4267 4270 9021 23016"                               
<li> "there are 77 docs with the word PACIFICA, here is a sample of docs to check 856 1838 2024 2632 3873"                               
<li> "there are 5034 docs with the word CREDIT AGRICOLE, here is a sample of docs to check 68 96 149 165 294"                            
<li> "there are 6434 docs with the word AXA, here is a sample of docs to check 16 23 41 73 95"                                           
<li> "there are 136492 docs with the word GAN, here is a sample of docs to check 1 2 3 4 8"                                              
<li> "there are 560 docs with the word GMF, here is a sample of docs to check 675 1375 1937 2043 2394"                                   
<li> "there are 486 docs with the word MAIF, here is a sample of docs to check 1056 1866 1967 2520 4395"                                 
<li> "there are 669 docs with the word MACIF, here is a sample of docs to check 1385 1543 1668 1852 2438"                                
<li> "there are 1054 docs with the word MAAF, here is a sample of docs to check 71 435 588 1379 1393"                                    
<li> "there are 1009 docs with the word GROUPAMA, here is a sample of docs to check 60 583 632 1064 1065"                                
<li> "there are 683 docs with the word MUTUELLE GENERALE, here is a sample of docs to check 2327 3623 4991 5383 6173"                    
<li> "there are 241 docs with the word COVEA, here is a sample of docs to check 25 685 711 1241 1392"                                    
<li> "there are 334 docs with the word AVIVA, here is a sample of docs to check 16 1066 1073 1098 1368"                                  
<li> "there are 14 docs with the word EUROFIL, here is a sample of docs to check 109902 131884 132214 158553 162627"                     
<li> "there are 1 docs with the word AMAGUIZ, here is a sample of docs to check 110108"                                                  
<li> "there are 161 docs with the word BANQUE POSTALE, here is a sample of docs to check 89 294 363 890 1659"                            
<li> "there are 2890 docs with the word OLIVIER, here is a sample of docs to check 97 314 328 350 375"                                   
<li> "there are 12 docs with the word DIRECT ASSURANCE, here is a sample of docs to check 709 17592 19757 171701 184896"                 
<li> "there are 69 docs with the word APRIL, here is a sample of docs to check 1370 4768 8478 11373 15614"                               
<li> "there are 489 docs with the word PAR CES MOTIFS LA COUR, here is a sample of docs to check 42 398 571 2518 8499"
</ul>
</ul>

## odd_ratio
Based on these keywords we defined, we now want to know what sequences of words (ngrams) are more likely to be used when the keyword is present in the document.<br>
We use the concept of odd_ratio to find these influent sequences.
In the following table we show :
<ul>
<li> column : the sequence of keywords
<li> odd_ratio : the ratio of presence in docs <b>with keyword</b> <i>vs</i> docs <b>without keyword</b>.
</ul>
Using the keyword "CORPOREL"
<ul>
<li>                          column odd_ratio volume
<li>           madame_sauvage_madame  4.391304    124
<li>       redactrice_madame_sauvage  4.571429    117
<li>                courante_pendant  4.576923    145
<li>                           ç_ipp  4.578947    106
<li>            vie_courante_pendant  4.916667    142
<li>                      suit_frais  5.000000    138
<li>           recours_tiers_payeurs  5.093023    262
<li>              jour_consolidation  5.600000    132
<li>                tenu_age_victime  6.103448    206
<li>                     pendant_itt  6.562500    121
<li>                  victime_a_date  7.200000    123
<li>            soumis_recours_tiers  8.000000    108
<li>                   age_victime_a  8.428571    132
<li>             suit_frais_medicaux 11.000000    108
<li>                endurees_attendu 11.111111    109
<li>         fonctionnel_sequellaire 12.384615    174
<li>    souffrances_endurees_attendu 13.857143    104
<li> deficit_fonctionnel_sequellaire 14.272727    168
<li>     prejudice_titre_souffrances 19.500000    123
<li>          evaluation_liquidation 35.666667    110
</ul>

## features extraction
The XML schema offers easy extraction of many features. Unfortunately in many cases the data is not filled correctly and almost everything ends up in the content/body of the document.
<ul>
<li> CAPP :
<ul>
[1] "doc_name 0% missing"        "demandeur 100% missing"     "defendeur 100% missing"     "president 96% missing"     
[5] "avocat_gl 100% missing"     "avocats 100% missing"       "rapporteur 100% missing"    "numero_affaire 13% missing"
[9] "sommaire 71% missing"       "sct 73% missing"            "citation_jp 41% missing"    "liens 89% missing"         
[13] "origine 0% missing"         "juridiction 0% missing"     "form_dec_att 73% missing"   "date_dec 0% missing"       
[17] "date_dec_att 73% missing"   "nature 15% missing"         "solution 59% missing"       "titre 0% missing"          
[21] "formation 16% missing"  
</ul>
<li> CASS :
<ul>
[1] "doc_name 0% missing"        "demandeur 100% missing"     "defendeur 100% missing"     "president 21% missing"     
[5] "avocat_gl 25% missing"      "avocats 28% missing"        "rapporteur 24% missing"     "numero_affaire 19% missing"
[9] "sommaire 2% missing"        "sct 2% missing"             "citation_jp 44% missing"    "liens 35% missing"         
[13] "origine 0% missing"         "juridiction 0% missing"     "form_dec_att 23% missing"   "date_dec 0% missing"       
[17] "date_dec_att 23% missing"   "nature 0% missing"          "solution 2% missing"        "titre 5% missing"          
[21] "formation 0% missing"       "doc_name 0% missing"
</ul>
<li> INCA :
<ul>
[1] "doc_name 0% missing"       "demandeur 100% missing"    "defendeur 100% missing"    "president 15% missing"    
[5] "avocat_gl 100% missing"    "avocats 75% missing"       "rapporteur 100% missing"   "numero_affaire 2% missing"
[9] "sommaire 76% missing"      "sct 76% missing"           "citation_jp 69% missing"   "liens 77% missing"        
[13] "origine 0% missing"        "juridiction 0% missing"    "form_dec_att 0% missing"   "date_dec 0% missing"      
[17] "date_dec_att 1% missing"   "nature 0% missing"         "solution 2% missing"       "titre 100% missing"       
[21] "formation 0% missing"      "doc_name 0% missing"
</ul>
<li> JADE
<ul>
[1] "doc_name 0% missing"       "demandeur 100% missing"    "defendeur 100% missing"    "president 34% missing"    
[5] "avocat_gl 43% missing"     "avocats 4% missing"        "rapporteur 3% missing"     "numero_affaire 1% missing"
[9] "sommaire 38% missing"      "sct 38% missing"           "citation_jp 92% missing"   "liens 70% missing"        
[13] "origine 0% missing"        "juridiction 0% missing"    "form_dec_att 100% missing" "date_dec 0% missing"      
[17] "date_dec_att 100% missing" "nature 0% missing"         "solution 80% missing"      "titre 100% missing"       
[21] "formation 0% missing"      "doc_name 6% missing"
</ul>
</ul>

## articles mentioned
results of `find articles mentionned.R`
In CAPP<br>
specific articles
<ul>
<li>    article 700 : 11044
<li>    article 450 : 10412
<li>    article 945 :  6441
<li>   articles 786 :  4878
<li>    article 786 :  4671
<li>    article 785 :  4371
<li>    article 452 :  1130
<li>    article 451 :   965
<li>    article 905 :   531
<li>   articles 945 :   487
<li>   articles 785 :   359
<li>    article 779 :   339
<li> articles l 552 :   312
<li>   articles 149 :   298
<li>    article 191 :   266
<li>  article l 122 :   261
<li>    article 485 :   216
<li>    article 455 :   213
<li>   articles 513 :   178
<li>    article 475 :   174
</ul>
and laws
<ul>
<li>           loi du 25 janvier 1985 :  670
<li>            loi du 9 juillet 1991 :  570
<li>           loi du 10 juillet 1965 :  548
<li>           loi du 10 juillet 1991 :  540
<li>            loi du 6 juillet 1989 :  480
<li>            loi du 5 juillet 1985 :  392
<li>          loi du 31 decembre 1971 :  322
<li>          loi du 21 decembre 2006 :  214
<li>           loi du 29 juillet 1881 :  203
<li>           loi du 26 juillet 2005 :  161
<li>            loi du 2 janvier 1970 :  139
<li>          loi du 31 decembre 1975 :  115
<li>               loi du 26 mai 2004 :  112
<li>               loi du 4 mars 2002 :  107
<li>              loi du 17 juin 2008 :  103
<li>           loi du 24 juillet 1966 :  103
<li>  loi aubry ii du 19 janvier 2000 :   85
<li>           loi du 19 janvier 2000 :   79
<li>           loi du 10 janvier 1978 :   78
<li>          loi du 31 decembre 1989 :   65
</ul>

## court of origin
results of court_volume_analysis.R
<ul>
<li> CAPP
<ul>
<li>          Cour d'appel de Paris 7271
<li>     Cour d'appel de Versailles 5455
<li>           Cour d'appel de Lyon 5310
<li>          Cour d'appel d'Angers 3793
<li>        Cour d'appel de Limoges 3729
<li>         Cour d'appel de Rennes 3417
<li>         Cour d'appel de Bastia 3386
<li>          Cour d'appel de Douai 3053
<li> Cour d'appel d'Aix-en-Provence 2222
<li>    Cour d'appel de Montpellier 2221
</ul>
<li> CASS => what is the CAPP of origin ?
<ul>
<li>                                    inconnu 46707
<li>       Tribunal de grande instance de Paris   542
<li>            Conseil de prud'hommes de Paris   428
<li>   Tribunal de grande instance de Marseille   245
<li> Tribunal de grande instance de Montpellier   230
<li>    Tribunal de grande instance de Toulouse   226
<li>             Conseil de prud'hommes de Lyon   224
<li>        Tribunal de grande instance de Lyon   216
<li>      Tribunal de grande instance de Grasse   194
<li>               Tribunal de commerce de Lyon   187
</ul>
<li> INCA => what is the CAPP of origin ?
<ul>
<li>          Cour d'appel de Paris 14319
<li> Cour d'appel d'Aix-en-Provence  8596
<li>     Cour d'appel de Versailles  5315
<li>          Cour d'appel de Douai  3364
<li>           Cour d'appel de Lyon  3183
<li>         Cour d'appel de Rennes  2852
<li>    Cour d'appel de Montpellier  2798
<li>       Cour d'appel de Bordeaux  2621
<li>          Cour d'appel de Nîmes  2163
<li>       Cour d'appel de Toulouse  2039
</ul>
<li> JADE
<ul>
<li>                           Conseil d'Etat 113089
<li>                           Conseil d'État  45147
<li>  Cour administrative d'appel de Bordeaux  26167
<li>     Cour administrative d'appel de Paris  24726
<li> Cour Administrative d'Appel de Marseille  24329
<li>    Cour Administrative d'Appel de Nantes  15456
<li>    Cour administrative d'appel de Nantes  14952
<li>      COUR ADMINISTRATIVE D'APPEL DE LYON  14502
<li>     Cour administrative d'appel de Nancy  14316
<li>     Cour administrative d'appel de Douai  14155
</ul>
</ul>

## geocoding the court to map the documents
I made 4 attempts to geocode the courts :
<ol>
<li> Prepare the court names for geocoding. There are ~200,000 different court names when mixing CAPP, CASS, INCA, JADE. To reduce the amount I did some data prep :
<ul>
<li> remove dates mentionned in the juridiction or form_dec_att field
<li> remove the name of the chamber, usually inside a pair of parenthesis ()
<li> apply the usual punctuation removal, lowercase, stripwhitespaces, remove accents
</ul>
this yields 1301 unique courts to geocode.
<li> Try Google Maps API on these data => 579 (44%) are not geocoded
<li> Remove standard pattern such as "tribunal de grande instance de", "cour d'appel de" and add ", France" on the string to help Google Maps API find the place. => 208 (35% of the 579) are still not geocoded
<li> Don't use Google Maps API. Instead use the adresse.data.gouv.fr/csv on the 1301 court names. => 80 (6%) are not geocoded.
<li> Improve this using the list of cities (communes) geocoded from galichon.com/codesgeo. Be careful, some cities in France have short names, for instance "us", this may match with "touloUSe" or "chambre d accUSation". Therefore, need to match full word/full name of the city. There is a limitation to this method : for instance Saint-Denis exists in France Metropolitaine and in La Reunion. <b>100% are geocoded but some might be wrong.</b>
</ol>

## year of trial
results of time_series_analysis.R
<ul>
<li> CAPP
<ul>
<li> 2011 2012 2013 2014 2015 2016 2017
<li> 6251 4518 3611 3887 3667 3052 1163
</ul>

<li> CASS
<ul>
<li> 2011 2012 2013 2014 2015 2016 2017
<li> 1529 1622 1504 1500 2049 3397 2520
</ul>

<li> INCA
<ul>
<li> 2011 2012 2013 2014 2015 2016 2017
<li> 9662 9776 9142 9181 8486 8816 7565
</ul>

<li> JADE
<ul>
<li> 2011  2012  2013  2014  2015  2016  2017
<li> 20079 19529 18761 18547 20843 20899 48275
</ul>
</ul>

# references
<ul>
<li>for Grep, here is a very cool <a href="http://www.endmemo.com/program/R/grep.php">cheatsheet</a>
<li>
</ul>

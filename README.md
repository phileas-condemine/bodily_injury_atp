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
For basic read/write operations, using docker containers can be much slower than running the operations locally.<br>
For example it's x4 slower (CAPP 5 mins vs 20 mins, JADE 25 mins vs 2 hours) for xml_check_quality.R >> prepare_doc().<br>
Thus most data prep operations were run locally.

# data size
Here is the number of XML files in each dataset on 27-02-2017 <br>
<ul>
<li> CAPP (1st & 2nd instances) 63340 xml documents. 78M tokens of length >3. 1,2M different tokens (not all of them are words).
<li> BREAKING (cassation) - RELEASED 134217 xml documents
<li> BREAKING (cassation) - UNRELEASED (inédits) 330923 xml documents
<li> JADE (admin) 401514 xml documents
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
<li> extract decisions looking more specifically at the end of the documents and checking the sentences that start with "comdamne", or "admet". Decisions are usually introduced by a
"br - p PAR CES MOTIFS -/p <br>
-p LA COUR -/p"

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
<li> "there are 2595 docs with the word CORPOREL, here is a sample of docs to check 103 199 220 240 243"
<li> "there are 120 docs with the word DOMMAGE CORPOREL, here is a sample of docs to check 1268 1529 1905 2503 3392"
<li> "there are 1 docs with the word REPARATION DOMMAGE CORPOREL, here is a sample of docs to check 54684"
<li> "there are 29242 docs with the word PREJUDICE, here is a sample of docs to check 2 3 5 6 9"
<li> "there are 4694 docs with the word ASSISTANCE, here is a sample of docs to check 7 46 48 56 67"
<li> "there are 799 docs with the word TIERCE PERSONNE, here is a sample of docs to check 60 123 220 394 442"
<li> "there are 54 docs with the word ASSISTANCE TIERCE PERSONNE, here is a sample of docs to check 3160 4763 14335 16802 21502"
<li> "there are 11477 docs with the word DOMICILE, here is a sample of docs to check 1 7 13 18 30"
<li> "there are 1455 docs with the word TIERCE, here is a sample of docs to check 12 18 60 72 85"
<li> "there are 18234 docs with the word SOIN, here is a sample of docs to check 1 7 13 24 25"
<li> "there are 667 docs with the word INFIRMIER, here is a sample of docs to check 220 766 1239 1351 1429"
<li> "there are 8273 docs with the word QUALIFIE, here is a sample of docs to check 1 2 5 8 13"
<li> "there are 1689 docs with the word INVALIDITE, here is a sample of docs to check 60 82 145 200 220"
<li> "there are 2 docs with the word INVALIDITE PHYSIQUE, here is a sample of docs to check 19726 38510"
<li> "there are 4530 docs with the word INCAPACITE, here is a sample of docs to check 11 13 43 60 68"
<li> "there are 60 docs with the word INCAPACITE PHYSIQUE, here is a sample of docs to check 197 1709 2097 2234 3831"
<li> "there are 945 docs with the word FRAIS MEDICAUX, here is a sample of docs to check 82 196 199 220 243"
<li> "there are 1170 docs with the word SEQUELLES, here is a sample of docs to check 60 199 220 244 294"
<li> "there are 26 docs with the word ARRET TRAVAIL, here is a sample of docs to check 8145 20187 43218 43380 43473"
<li> "there are 24443 docs with the word LITIGE, here is a sample of docs to check 2 7 17 18 19"
<li> "there are 3486 docs with the word GRAVITE, here is a sample of docs to check 1 24 25 39 68"
<li> "there are 969 docs with the word PRETIUM DOLORIS, here is a sample of docs to check 60 82 199 244 442"
<li> "there are 1372 docs with the word PREJUDICE ESTHETIQUE, here is a sample of docs to check 13 60 199 220 244"
<li> "there are 7 docs with the word PREJUDICE AGREMENT, here is a sample of docs to check 3160 14115 22293 23345 28717"
<li> "there are 5 docs with the word PREJUDICE MORPHOLOGIQUE, here is a sample of docs to check 22785 25820 58731 61129 62200"
<li> "there are 2864 docs with the word MUTUELLE, here is a sample of docs to check 10 118 136 154 167"
<li> "there are 12147 docs with the word ASSURANCE, here is a sample of docs to check 3 6 10 19 21"
<li> "there are 338 docs with the word ALLIANZ, here is a sample of docs to check 186 316 363 801 889"
<li> "there are 1517 docs with the word GENERALI, here is a sample of docs to check 27 110 115 138 187"
<li> "there are 95 docs with the word ZURICH, here is a sample of docs to check 186 1105 1672 3081 3160"
<li> "there are 141 docs with the word MATMUT, here is a sample of docs to check 124 322 2166 2498 3025"
<li> "there are 57 docs with the word PACIFICA, here is a sample of docs to check 8371 8783 10124 14334 16832"
<li> "there are 1480 docs with the word CREDIT AGRICOLE, here is a sample of docs to check 6 66 103 158 194"
<li> "there are 171 docs with the word MAIF, here is a sample of docs to check 270 1561 1754 1778 3392"
<li> "there are 250 docs with the word MACIF, here is a sample of docs to check 53 375 445 917 1150"
<li> "there are 271 docs with the word MAAF, here is a sample of docs to check 270 1338 1354 1395 1424"
<li> "there are 448 docs with the word GROUPAMA, here is a sample of docs to check 60 418 442 534 1409"
<li> "there are 81 docs with the word MUTUELLE GENERALE, here is a sample of docs to check 118 737 1388 1732 2570"
<li> "there are 154 docs with the word COVEA, here is a sample of docs to check 14564 14800 15586 18414 18568"
<li> "there are 298 docs with the word AVIVA, here is a sample of docs to check 2138 4546 4834 4868 7613"
<li> "there are 12 docs with the word EUROFIL, here is a sample of docs to check 1326 1540 1544 8996 12569"
<li> "there are 130 docs with the word BANQUE POSTALE, here is a sample of docs to check 13837 14670 15171 15976 16036"
<li> "there are 3565 docs with the word OLIVIER, here is a sample of docs to check 259 302 358 425 433"
<li> "there are 18 docs with the word DIRECT ASSURANCE, here is a sample of docs to check 6009 6055 7698 9663 12422"
<li> "there are 26 docs with the word APRIL, here is a sample of docs to check 8015 8351 17597 19348 23779"
</ul>
<li> breaking (cassation) instance released
<li> breaking (cassation) instance unreleased (inedit)
<li> admin instance (JADE)
</ul>

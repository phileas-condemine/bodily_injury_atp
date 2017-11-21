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
One can reproduce it following the step in the readme of <a href="https://github.com/phileas-condemine/text-mining"> this repo.</a>

# data size
Here is the number of XML files in each dataset on 27-02-2017
<ul>
<li> CAPP (1st & 2nd instances) 63340
<li BREAKING (cassation) - RELEASED 134217
<li> BREAKING (cassation) - UNRELEASED (inédits) 330923
<li> JADE (admin) 401514
</ul>
To get more data, one needs to download the daily releases and merge them to the dataset.

# documents filtering based on keywords

<ul>
<li> 1st & 2nd instance
<ul>
<li> "there are 2595 docs with the word CORPOREL, here is a sample of docs to check 103 199 220 240 243"
<li> "there are 29242 docs with the word PREJUDICE, here is a sample of docs to check 2 3 5 6 9"
<li> "there are 132 docs with the word ATP, here is a sample of docs to check 415 1305 1539 2177 2186"
<li> "there are 4694 docs with the word ASSISTANCE, here is a sample of docs to check 7 46 48 56 67"
<li> "there are 799 docs with the word TIERCE PERSONNE, here is a sample of docs to check 60 123 220 394 442"
<li> "there are 12147 docs with the word ASSURANCE, here is a sample of docs to check 3 6 10 19 21"
<li> "there are 2735 docs with the word AXA, here is a sample of docs to check 3 21 26 92 189"
<li> "there are 1455 docs with the word TIERCE, here is a sample of docs to check 12 18 60 72 85"
<li> "there are 18234 docs with the word SOIN, here is a sample of docs to check 1 7 13 24 25"
<li> "there are 667 docs with the word INFIRMIER, here is a sample of docs to check 220 766 1239 1351 1429"
</ul>
<li> breaking (cassation) instance released

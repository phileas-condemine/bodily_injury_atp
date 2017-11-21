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
First and second degree instances are working on the case itself.
<li>
Breaking court is higher than first & second degree instances, its role is to judge the decision of the second degree instance.
<br>
If the breaking court breaks the second degree instance decision, then the judgement is <b>sent back</b> to a second degree instance.
<li>Administrative court instances handle trials where <a href="https://www.service-public.fr/particuliers/vosdroits/F2025"> public administration is involved </a>
</ul>

# Work environment :
To make sure anyone can reproduce this work, I used a docker container based on <b>rocker/rstudio</b> image.<br>
One can reproduce it following the step in the readme of <a href="https://github.com/phileas-condemine/text-mining"> this repo.</a>

# data size
Here is the number of XML files in each dataset on 27-02-2017
<ul>
<li> CAPP 63340
<li BREAKING - RELEASED 134217
<li> BREAKING - UNRELEASED 330923
<li> JADE 401514
</ul>
To get more data, one needs to download the daily releases and merge them to the dataset.

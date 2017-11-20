system("find data -name *.tar.gz -exec tar xzvvf -C  {} \;")

system("for file in `find data -name *.tar.gz`; do tar -xvf '${file}' ; done")


CAPP <- xml2::read_xml("data/CAPP_1ST_2ND_INSTANCES/Freemium_capp_global_20170227-083558.tar.gz")

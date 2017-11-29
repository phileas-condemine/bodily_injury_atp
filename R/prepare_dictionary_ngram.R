load("Documents/bodily_injury_atp/data/CAPP_1ST_2ND_INSTANCES/CAPP_text_extraction.RData")
library(text2vec)
library(magrittr)
pattern="corporel"
ngram=3L
n_cores=28

token <- CAPP_docs %>%word_tokenizer

itokenized <- text2vec::itoken(token,ids = 1:length(CAPP_docs), progressbar = FALSE)

dictionary <- create_vocabulary(itokenized,stopwords = c(tm::stopwords(kind = 'fr')), ngram = c(ngram_min=1L,ngram_max=ngram))
dictionary.pruned <- prune_vocabulary(dictionary,
                                      term_count_min = 100,
                                      doc_proportion_max = 0.5)

vectorizer<-vocab_vectorizer(dictionary.pruned)

matrix_ngrams<-text2vec::create_dtm(itokenized,vectorizer)

save(list="matrix_ngrams",file="Documents/bodily_injury_atp/data/CAPP_1ST_2ND_INSTANCES/CAPP_ngrams.RData")

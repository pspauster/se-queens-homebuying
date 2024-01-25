library(tidyverse)

pluto <- read_csv(URLencode(paste0("https://data.cityofnewyork.us/resource/64uk-42ks.csv?",
                                   "$where=cd=412",
                                   "&$limit=100000")))
##fix 

bbls <- pluto %>% pull(bbl)

bbls_string <- paste0("bbl = '",paste(document_ids, collapse = "' OR bbl = '"),"'")
  
master <- read_csv(URLencode(paste0("https://data.cityofnewyork.us/resource/bnx9-e6tj.csv?",
                          "$where=document_date>='2013-01-01' AND doc_type='DEED'",
                          "&$limit=800000"))) %>% 
#629K of these. make docid a character

document_ids <- master %>% pull(document_id)

document_ids_string <- paste0("document_id = '",paste(document_ids, collapse = "' OR document_id = '"),"'")

legals <- read_csv(URLencode(paste0("https://data.cityofnewyork.us/resource/8h5j-fqxa.csv?",
                                    "$select=document_id,borough,block,lot",
                                    "$&where=document_id=", document_ids_string,
                                    "&$limit=10000000")))%>%
  mutate(bbl = paste0(
    as.character(borough),
    str_pad(block %>% as.character() , width = 5, pad = "0", side = "left"),
    str_pad(lot %>% as.character() , width = 4, pad = "0", side = "left"))
  )
#more than 10M

parties <- read_csv(URLencode(paste0("https://data.cityofnewyork.us/resource/636b-3b5g.csv?",
                                     "$where=", document_ids_string,
                                     "&$limit=10000")))

acris_joined <- inner_join(master, legals, by = "document_id") %>% 
  inner_join(parties, by = "document_id")

pluto <- read_csv(URLencode(paste0("https://data.cityofnewyork.us/resource/64uk-42ks.csv?",
                                   "$where=cd=412",
                                   "&$limit=100000")))


# address 88-58 180 STREET
# bbl 4099150064
# owner RAHMAN, ABDUL

prop <- read_csv(URLencode(paste0("https://data.cityofnewyork.us/resource/8h5j-fqxa.csv?",
                          "$where=borough = 4 AND block = 9915 AND lot = 64",
                          "&$limit=10000")))%>%
  mutate(bbl = paste0(
    as.character(borough),
    str_pad(block %>% as.character() , width = 5, pad = "0", side = "left"),
    str_pad(lot %>% as.character() , width = 4, pad = "0", side = "left"))
  )

prop_docs <- prop %>% pull(document_id)

prop_docs_string <- paste0("document_id = '",paste(prop_docs, collapse = "' OR document_id = '"),"'")

prop_parties <- read_csv(URLencode(paste0("https://data.cityofnewyork.us/resource/636b-3b5g.csv?",
                          "$where=", prop_docs_string,
                          "&$limit=10000")))

prop_master <- read_csv(URLencode(paste0("https://data.cityofnewyork.us/resource/bnx9-e6tj.csv?",
                                         "$where=", prop_docs_string,
                                         "&$limit=10000")))
prop_all <- inner_join(prop_master, prop, by = "document_id") %>% 
  inner_join(prop_parties, by = "document_id")

rahman <- read_csv(URLencode(paste0("https://data.cityofnewyork.us/resource/636b-3b5g.csv?",
                                    "$where=name='RAHMAN, ABDUL'",
                                    "&$limit=10000")))

rahman_all <- left_join(rahman, master %>% mutate(document_id = as.character(document_id)), by = "document_id") %>% 
  left_join

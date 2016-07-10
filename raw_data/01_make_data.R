# read data ----
library(readxl)
library(rvest)

# pour la syntaxe R ----
library(magrittr)

# tidyverse ----
library(dplyr)
library(purrr)
library(stringr)
library(tidyr)
library(ggplot2)
library(fuzzyjoin)


# recupération des données ------
data_url <- "https://www.data.gouv.fr/s/resources/elections-departementales-2015-resultats-tour-2/community/20150511-110358/Dep_15_Resultats_T2_c.xlsx"
download.file(url = data_url, destfile = "demoggiraph/data/dep_2015.xlsx" )




# carte de france ----
france <- map_data("france")
fr_reg <- france %>% select(region) %>% distinct() %>%
  mutate(lidep = str_to_title(region)) %>%
  mutate(lidep = str_replace_all(region, " ", "-"))





# import des donnees elections departementales -----
dep <- read_excel("demoggiraph/data/dep_2015.xlsx", sheet = 3)
corse_sud <- dep[[3]] == "CORSE SUD"
dep[[3]][corse_sud] <- "CORSE DU SUD"


dep_detail <- dep[, -c(1:2, 4:17)]
stupid_column_start_pos <- which( names(dep_detail) == "Code Nuance" )
dep_detail <- map_df(stupid_column_start_pos,
                     function(j, data)
                       data[,c(1, j + 0:2), drop = FALSE],
                     dep_detail )
names(dep_detail) <- c("lidep", "conu", "sieges", "voix")
dep_detail <- dep_detail %>%
  mutate(lidep = str_to_title(lidep)) %>%
  mutate(lidep = str_replace_all(lidep, " ", "-")) %>%
  stringdist_left_join(fr_reg, by = c(lidep = "lidep"), max_dist = 1)
dep_detail$lidep <- dep_detail$region
dep_detail$region <- NULL
dep_detail$lidep.x <- NULL
dep_detail$lidep.y <- NULL
dep_detail <- na.omit(dep_detail)

url <- "http://www.ipolitique.fr/archive/2015/03/22/resultats-departementales-2015.html"
nuances <- url %>%
  read_html() %>%
  xml_find_first(xpath='//table[2]') %>% html_table()
names(nuances) <- c("conu", "nuance politique")

dep_detail$conu <- factor( x = dep_detail$conu, levels = nuances$conu, labels = nuances$`nuance politique`)



dep_overall <- dep[, 2:17]
dep_overall <- dep_overall[, !str_detect( names(x = dep_overall), "%" )]
names(dep_overall) <- c("codep", "lidep", "inscrits", "abstentions", "votants", "blancs", "nuls", "exprimes")
dep_overall$lidep
dep_overall <- dep_overall %>%
  mutate(lidep = str_to_title(lidep)) %>%
  mutate(lidep = str_replace_all(lidep, " ", "-")) %>%
  stringdist_left_join(fr_reg, by = c(lidep = "lidep"), max_dist = 1) %>%
  mutate(abstentions = abstentions/inscrits,
         votants = votants/inscrits,
         blancs = blancs/inscrits,
         nuls = nuls/inscrits,
         exprimes = exprimes/inscrits )

dep_overall$lidep <- dep_overall$region
dep_overall$region <- NULL
dep_overall$lidep.x <- NULL
dep_overall$lidep.y <- NULL
dep_overall <- na.omit(dep_overall)

saveRDS(object = dep_overall, file = "demoggiraph/data/dep_overall.RDS")
saveRDS(object = dep_detail, file = "demoggiraph/data/dep_details.RDS")
unlink("demoggiraph/data/dep_2015.xlsx", force = TRUE)

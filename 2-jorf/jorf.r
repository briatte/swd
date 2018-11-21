# ==============================================================================
# PACKAGE DEPENDENCIES
# ==============================================================================

library(dplyr)   # loads magrittr, tibble
library(rvest)   # loads xml2
library(stringr)

# ==============================================================================
# [1] DOWNLOAD INDEX PAGE
#
# Source: DILA
# https://echanges.dila.gouv.fr/OPENDATA/JORFSIMPLE/
#
# ==============================================================================

u <- "https://echanges.dila.gouv.fr/OPENDATA/JORFSIMPLE/"

f <- "index.html"
if (!file.exists(f)) {
  download.file(u, f, mode = "wb")
}

# find JORF archives
f <- read_html(f) %>% 
  html_nodes(xpath = "//a[starts-with(@href, 'JORFSIMPLE')]") %>% 
  html_attr("href")

# NOTE -- equivalently:
# //a[contains(@href, '.tar.gz')]")

# ==============================================================================
# [2] LIST CONTENTS OF FILES
#
# ==============================================================================

d <- data_frame()

# NOTE -- remove [brackets] to download all files
for (i in f[1:3]) {
  
  if (!file.exists(i)) {
    download.file(paste0(u, i), i, mode = "wb")
  }
  
  cat("[>]", i)
  
  l <- str_subset(untar(i, list = TRUE), "JORFTEXT")
  
  y <- data_frame()
  
  for (j in l) {
    
    untar(i, files = j)
    x <- read_xml(j) %>% 
      data_frame(
        type  = xml_text(xml_node(., "NATURE")),
        num   = xml_text(xml_node(., "NUM")),
        date  = xml_text(xml_node(., "DATE_TEXTE")),
        title = xml_text(xml_node(., "TITREFULL"))
      )
    
    y <- bind_rows(y, x)
    
  }
  
  cat(":", nrow(y), "files\n")
  
  d <- bind_rows(d, select(y, type:title))

}

cat("[>]", nrow(d), "files in total.\n")

# ==============================================================================
# [3] FIX MISSING VALUES
#
# ==============================================================================

# dates
# -----

table(d$date)
d$date[ str_detect(d$date, "2999") ] <- NA_character_

table(d$type, is.na(d$date), exclude = NULL)

# types
# -----

unique(d$type)
d$type[ d$type == "" ] <- NA_character_

# have a nice day

# package dependencies

p <- 
  c(
    "grid", "ggplot2", "ggnetwork", "scales", "wesanderson",
    "httr", "rvest", "xml2", "XML",
    "tidygraph", "network", "sna", "igraph", "ggraph", "rgexf",
    "dplyr", "tibble", "tidyr", "magrittr", "purrr", 
    "microbenchmark", "devtools",
    "stringr", "lubridate",
    "readr", # "jsonlite",
    "pscl", "oc", "anominate",
    "pdftools",
    "tidytext" #, "topicmodels"
  )

# optional

p <- c(p, "genderizeR", "ROAuth")

for (i in p) {
  
  if (!require(i, character.only = TRUE))
    install.packages(i, repos = "http://cran.rstudio.com")
  
}

# kthxbye

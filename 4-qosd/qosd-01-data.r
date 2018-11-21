# ==============================================================================
# A scraper for oral questions asked in the French National Assembly.
# ------------------------------------------------------------------------------
#
# Useful for data not released as part of the open data portal:
# http://data.assemblee-nationale.fr/
#
# Tested on Legislature 13 (2007-2012). Legislature number is hardcoded.
# Worked as of November 15, 2018.
#
# ------------------------------------------------------------------------------

# ==============================================================================
# PACKAGE DEPENDENCIES
# ==============================================================================

library(httr)
library(readr)
library(rvest)
library(tibble)

# ==============================================================================
# HELPER FUNCTION
# ==============================================================================

#' Extract text from table divider that follows divider containing x
#' @param h html document
#' @param x single text string
#' @note supports single quotes in x
#' @import rvest
td_after = function(h, x) {
  
  x <- paste0("//*[contains(text(), \"", x, "\")]/following-sibling::td")
  rvest::html_text(rvest::html_node(h, xpath = x), trim = TRUE)
  
}

# ==============================================================================
# [1] DOWNLOAD ALL ORAL QUESTIONS
#
# (specifically, those without subsequent debate, 'sans débat')
#
# ==============================================================================

dir.create("qosd-raw", showWarnings = FALSE)

d <- data_frame()

i <- 0 # be stupid and assume continuous numbering 1..N, which seems to work
e <- 0 # count consecutive errors produced by download loop

# be stupid (again!) and exit after 3 consecutive errors
while (e < 3) {
  
  i = i + 1
  
  u <- paste0("http://questions.assemblee-nationale.fr/q13/13-", i, "QOSD.htm")
  f <- paste0("qosd-raw/", basename(u))
  
  if (!file.exists(f)) {
    
    h <- httr::GET(u)
    
    if (httr::status_code(h) == 200) {
      
      write(httr::content(h, as = "text", encoding = "iso-8859-1"), f)
      e <- 0 # reset error counter (count only consecutive ones)
      
    } else {
      
      e <- e + 1
      cat("x")
      
    }
    
  }
  
  if (file.exists(f)) {
    
    h <- xml2::read_html(f, encoding = "UTF-8")
    
    h <- tibble::data_frame(
      legislature = 13,
      numero = html_node(h, xpath = "//table/tr/td[1]") %>% 
        html_text(trim = TRUE) %>% 
        gsub("\\D", "", .),
      auteur = html_node(h, xpath = "//table/tr/td[2]/b/aut") %>% 
        html_text(trim = TRUE),
      rubrique = td_after(h, "Rubrique"),
      tete_analyse = td_after(h, "d'analyse"),
      analyse = td_after(h, "Analyse")
    )
    
    d = rbind(d, h)
    cat(".")
    
  }
  
  if (! i %% 50) {
    cat("", i, "\n")
  }
  
}

write_csv(d, "qosd.csv")

# kthxbye

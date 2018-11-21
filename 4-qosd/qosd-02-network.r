# ==============================================================================
# PACKAGE DEPENDENCIES
# ==============================================================================

library(dplyr)
library(igraph)
library(ggraph)
library(readr)
library(stringr)

# ==============================================================================
# [2] EXTRACT KEYWORD CO-OCCURRENCE NETWORK
#
# (...)
#
# ==============================================================================

# table(unlist(str_split(d$analyse, "\\s*\\.\\s*"))) %>% as.data.frame() %>% arrange(-Freq) %>% filter(Freq > 5)

d <- read_csv("qosd.csv")

# NOTE -- limited to first 50 oral questions

e <- apply(head(d, 100), 1, function(x) {
  y <- stringr::str_split(x["analyse"], "\\s*\\.\\s*") %>% 
    lapply(function(x) {
      expand.grid(i = x, j = x, stringsAsFactors = FALSE) %>% 
        dplyr::filter(i != j)
    })
  y[[1]]
})

e <- as.matrix(bind_rows(e))
n <- igraph::graph_from_edgelist(e)

ggraph(n) +
  geom_edge_link() +
  geom_node_label(aes(label = name)) +
  theme_graph()

# have a nice day

# ==============================================================================
# DEPENDENCIES
# ==============================================================================

library(dplyr) # loads magrittr, tibble
library(readr)

# HTML parsing
library(rvest)
library(xml2)  # loaded by rvest

# network objects
library(network)
## library(XML) # not required, shown for reference

# visualization
library(ggplot2)
library(ggraph)
library(wesanderson)

# ==============================================================================
# [1] DOWNLOAD RAW DATA
# 
# Source: Althing (Icelandic parliament)
# http://www.althingi.is/lagasafn/zip-skra-af-lagasafni/
#
# ==============================================================================

u <- "http://www.althingi.is/lagasafn/zip/nuna/allt.zip"
f <- basename(u)

if (!file.exists(f)) {
  download.file(u, f, mode = "wb")
}

l <- unzip(f, list = TRUE)
l <- l[ grepl("^\\d{4}(.*)\\.html$", l$Name), 1 ]

# legislation years
# -----------------

length(l) # 1,566 files

head(l)   # min. year = 1275
tail(l)   # max. year = 2018

# substr(l, 1, 4) %>%
#   .[ . > 1900 ] %>%
#   table %>%
#   barplot

# ==============================================================================
# [2] EXTRACT METADATA AND EDGE LIST
#
# (directed, using local filenames as unique identifiers)
#
# ==============================================================================

d <- data_frame() # to store :: title and year of legislation
e <- data_frame() # to store :: cross-references between entities

# parse HTML files
# ----------------

cat("Parsing", length(l), "files...\n")
p <- txtProgressBar(max = length(l))

for (i in l) {

  setTxtProgressBar(p, which(l == i))
  x <- unz(f, i)
  
  # NOTE -- reading directly from archive.
  #
  # writeLines(readLines(x, encoding = "UTF-8"), "sample-page.html")
  # close(x)

  h <- read_html(x)
  
  # title and date of legislation
  y <- data_frame(
    id = i,
    title = html_node(h, xpath = "//h2[1]") %>% 
      html_text(trim = TRUE),
    date = html_node(h, xpath = "//p[2]") %>% 
      html_text(trim = TRUE)
  )
  
  d <- rbind(d, y)

  # NOTE -- equivalent code for XML package
  #
  # title = XML::xpathSApply(h, "//h2[1]" , xmlValue)
  #  date = XML::xpathSApply(h, "//p[2]"  , xmlValue)

  # links to other articles
  x <- html_nodes(h, xpath = "//a") %>%
    html_attr("href")
  
  # NOTE -- equivalent code for XML package
  #
  # XML::xpathSApply(h, "//a/@href")

  # relevant links start with a year and end with .html
  x <- x[ grepl("^\\d{4}(.*)html$", x) ]

  if (length(x) > 0) {
    
    y <- data_frame(i = i, j = x) # (current law) -> (cited law)
    e <- rbind(e, y)
    
  }

}

cat("\n") # end progress bar

# clean up all columns
# --------------------

# e <- apply(e, 2, function(x) gsub("\\.html$", "", x))
e <- mutate_all(e, function(x) gsub("\\.html$", "", x))

# check node names
# ----------------

# sample_n(e, 10)
# 
# table(nchar(e$i))
# table(nchar(e$j))
# 
# filter(e, nchar(i) > 7)

# ==============================================================================
# [3] EXTRACT BASIC NETWORK STRUCTURE
#
# (degree distributions)
#
# ==============================================================================

# remove self-edges
# -----------------

# filter(e, i == j)
e <- filter(e, i != j)

# remove duplicate edges (WARNING: shown for reference, do not save results)
# ----------------------

# unique(e)
# distinct(e)

## microbenchmark::microbenchmark(distinct(e))
## microbenchmark::microbenchmark(unique(e))

# outdegree (i)
# -------------

table(e$i) %>%
  as.integer %>%
  summary

# table(e$i) %>% 
#   density %>% 
#   plot

# ## as a line plot
#
# x <- group_by(e, i) %>%
#   tally(sort = TRUE) %>%
#   mutate(year = substr(i, 1, 4)) %>%
#   group_by(year) %>%
#   summarise(mu = mean(n), sd = sd(n))
# 
# ggplot(x, aes(year, mu)) +
#   geom_pointrange(aes(ymin = mu - sd, ymax = mu + sd), size = 0.5)

# ## as a line plot, broken by decade
#
# x$decade = 100 * (as.integer(x$year) %/% 100)
# table(x$decade)
# 
# ggplot(x, aes(year, mu)) + 
#   geom_pointrange(aes(ymin = mu - sd, ymax = mu + sd), size = 0.5) +
#   facet_grid(~ decade, scales = "free_x", space = "free_x") +
#   labs(y = "mu ± 1 s.d.") +
#   theme(axis.text.x = element_blank())

# indegree (j)
# ------------

table(e$j) %>%
  as.integer %>%
  summary

# table(e$j) %>%
#   density %>%
#   plot

# both in one pipeline
group_by(e, i) %>% 
  mutate(w_i = n()) %>% 
  group_by(j) %>% 
  mutate(w_j = n())

# ==============================================================================
# [4] COMPUTE SIMPLE EDGE WEIGHTS
#
# (frequency of -undirected- ties)
#
# ==============================================================================

# ensure the connecting character is free
stopifnot(!grepl("_", e$i))
stopifnot(!grepl("_", e$j))

# (older law) -> (newer law)
w <- apply(e, 1, function(x) paste0(sort(x), collapse = "_"))
w <- tibble::as_data_frame(table(w))

arrange(w, -n)
table(w$n)

w <- data_frame(
  i = gsub("(.*)_(.*)", "\\1", w$w), # oldest law
  j = gsub("(.*)_(.*)", "\\2", w$w), # newer law
  w = w$n
)

# ==============================================================================
# [5] CREATE NETWORK OBJECT
#
# (803 nodes, 1,584 edges, undirected)
#
# ==============================================================================

n <- network(w[, 1:2 ], directed = FALSE)
sample(network.vertex.names(n), 5)

set.edge.attribute(n, "crossrefs", w$w) # number of cross-references

n %v% "year" <- substr(network.vertex.names(n), 1, 4) # year of legislation
table(n %v% "year")

# save metadata, (weighted) edges, network
# ----------------------------------------

write_csv(d, "lagasafn-metadata.csv")
write_csv(w, "lagasafn-edges.csv")

saveRDS(n, file = "lagasafn-network.rds")

# ==============================================================================
# [6] VISUALIZE NETWORK
#
# (using Fruchterman-Reingold placement in all layouts)
#
# ==============================================================================

# NOTE -- internally, ggraph will convert to igraph
#
# g <- intergraph::asIgraph(n)

ggraph(n, layout = "fr") +
  geom_node_point() +
  geom_edge_link()

# group node years
x <- cut_number(as.integer(n %v% "year"), 4, dig.lab = 4)
n %v% "group" <- as.character(x)

# color palette
p <- rev(wes_palette("Zissou1", 4))

ggraph(n, layout = "fr") +
  geom_node_point(aes(color = group)) +
  geom_edge_link(aes(alpha = crossrefs)) +
  scale_color_manual("period", values = p, limits = levels(x)) +
  theme_graph()

ggsave("lagasafn-network.png", width = 8, height = 7)

# have a nice day

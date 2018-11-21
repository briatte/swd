# ==============================================================================
# PACKAGE DEPENDENCIES
# ==============================================================================

library(dplyr)    # required by word_count; loads magrittr, tibble
library(pdftools) # required by word_count; https://github.com/ropensci/pdftools
library(tidytext) # required by word_count

# ==============================================================================
# HELPER FUNCTION
#
# word_count
#
# Source: Thomas J. Leeper
# https://gist.github.com/leeper/0d0c1ee2c671e03db21bbc45acf6b351
#
# ==============================================================================

u <- "https://gist.github.com/leeper/0d0c1ee2c671e03db21bbc45acf6b351"
devtools::source_gist(u, sha1 = )

# ==============================================================================
# [1] DOWNLOAD SOURCE PDF
#
# Source: United Nations Framework Convention on Climate Change (UNFCC)
# https://unfccc.int/resource/docs/2015/cop21/eng/l09r01.pdf
#
# See also: full-text online version (Open Knowledge Foundation, OKF)
# http://cop21.okfnlabs.org
#
# ==============================================================================

u <- "https://unfccc.int/resource/docs/2015/cop21/eng/l09r01.pdf"
f <- basename(u)

if (!file.exists(f)) {
  download.file(u, f, mode = "wb")
}

# ==============================================================================
# [1] TEST FILE READABILITY
#
# ==============================================================================

(t <- pdf_text(f))

# ==============================================================================
# [2] WORD COUNT
#
# (using helper function by Thomas J. Leeper)
#
# Source: https://gist.github.com/leeper/0d0c1ee2c671e03db21bbc45acf6b351
#
# ==============================================================================

(p <- word_count(f))

# have a nice day

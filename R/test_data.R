library(readr)
library(usethis)
test_data <- read_delim("test_data/proc_data.tsv",
                        delim = "\t", escape_double = FALSE,
                        trim_ws = TRUE, show_col_types = FALSE)
usethis::use_data(test_data, overwrite = T)

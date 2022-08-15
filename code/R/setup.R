library(tidyverse)
library(readxl)

## PATHS
# sets the relative paths to your data
# adjust these in case you use a different base_structure
data_path <- file.path(base_path, "data")
out_path <- file.path(base_path, "output")
fig_path <- file.path(out_path, "Rimg")
code_path <- file.path(repo_path,"code/R")


#### get the qPCR_utility functions
source(file.path(code_path, "qPCR_utils.R"))
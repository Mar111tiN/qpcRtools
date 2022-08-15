##################################
## PATHS ########################
home <- Sys.getenv("HOME")

## PATHS
# here set the path to the repo root
repo_path <- file.path(home, "Sites/Bio/qpcRtools")
# base_path is the local folder containing 
#   data and 
#   setup/analysis code and
#   output
# for the testdata, it is the same as the repo root
base_path <- repo_path

# load the setup file that sets the relative paths and loads the utility functions from the repo
source(file.path(base_path, "code/R/setup.R"))

plot_qPCR_standard(
  date = 220519,
  data_path = data_path,
  device = "7500",
  protein= "", # HPRT1 / CD8B, CD247
  save_path = fig_path,
  text.size=13
  )
################################
######### DROPLET PCR ##########

plot_ddPCR_standard(
  date=220609,
  protein="CXCR3alt",
  data_path=data_path,
  save_path=fig_path 
)

# Tools for working with quantitative PCR data (ddPCR, real-time PCR)
### used for 
+ visualization of standard curves
+ normalizing based on standard curves

### available as code best used with rstudio
+ #### for jupyter:
   * clone the repository into \<your folder\> and move to into qpcRtools:
      + `cd <your_folder> && git clone git@github.com:Mar111tiN/qpcRtools.git && cd qpcRtools`
   * create conda environment to run the notebooks (for Apple use env/R-env.yml):
      + `conda env create -n R-env -f code/env/R-env.yml`
   * move code/R/setup.R to your working folder under code/R and adjust the paths to fit your structure (best adhere to structure below)
   * move to your working folder and create code/R/script.R and store your data in folder data
      + standard curved under data/std

   * run rstudio and perform analysis


## The Tool kit
### plot_qPCR_standard - visualize real-time PCR standard curves coming from biorad system
+ requires date and device to be found in filename
+ plots either all detected proteins (`protein=""`) or protein selected with protein argument

### plot_ddPCR_standard - visualize ddPCR standard curves coming from ddPCR device
+ requires date and protein to be found in filename

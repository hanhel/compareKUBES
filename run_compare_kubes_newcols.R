## compareKUBES function

# install pacman - a tool for easy installing and loading the other required packages
if (!require("pacman")) install.packages("pacman")

# use pacman to install - if needed, and load packages
pacman::p_load(dplyr, readr, tools, rlang)

# input files, provided as full path and filename. OBS! / not \
# file1 = new file
# file2 = older file
file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/DATERT/csv/LESEFERD_2021-12-17-10-02.csv"
file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/DATERT/csv/LESEFERD_2020-12-04-14-36.csv"


# read files
kube1 <- read_delim(file1, delim = ";")
kube2 <- read_delim(file2, delim = ";")


# source compare kubes script
# needs to be in the current directory
# or specify path like this:
# source("path/to/where/script/is/compare_kubes_newcols.R")
source("compare_kubes_newcols.R")

# run merge and compare
compare <- compare_kube()

# write results table and provide summary
view_write_compare(compare)


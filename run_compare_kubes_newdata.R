## compareKUBES function

# clear workspace
rm(list = ls())

# install pacman - a tool for easy installing and loading the other required packages
if (!require("pacman")) install.packages("pacman")

# use pacman to install - if needed, and load packages
pacman::p_load(dplyr, readr, tools, rlang)

# input files, provided as full path and filename. OBS! / not \
# file1 = new file
# file2 = older file

# KOMMUNEHELSA
file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR/BEFOLK_GK_2022-09-08-13-35.csv"
file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR/BEFOLK_GK_2022-04-21-10-14.csv"

# NORGESHELSA
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/NORGESHELSA/NH2022NESSTAR/Totaldod_NH_LHF_2022-03-29-16-24.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/NORGESHELSA/NH2021NESSTAR/Totaldod_NH_LHF_2021-08-30-16-15.csv"

# TEST
#file1 <- "testdata/TEST_KUBE1_GRUNNSKOLEPOENG_2022_newdata.csv"
#file2 <- "testdata/TEST_KUBE2_GRUNNSKOLEPOENG_2021_multinewcols.csv"

# read files
kube1 <- read_delim(file1, delim = ";")
kube2 <- read_delim(file2, delim = ";")

# TEST EXPIRED COL
# in case om expired columns, cols in kube2 NOT in kube1
#kube1 <- kube1 %>% 
#  filter(SOES == 0) %>% 
#  select(-SOES)

# source compare kubes script
# needs to be in the current directory
# or specify path like this:
# source("path/to/where/script/is/compare_kubes_newcols.R")
source("compare_kubes_newdata.R")
#source("compare_kubes_newcols.R")

# run find and write newdata
write_newdata()

# run merge and compare
compare <- compare_kube()

# write compare results table and provide summary, total and by year
view_write_compare(compare)


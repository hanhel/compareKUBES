## compareKUBES function

# clear workspace
rm(list = ls())

# install pacman - a tool for easy installing and loading the other required packages
if (!require("pacman")) install.packages("pacman")

# use pacman to install - if needed, and load packages
pacman::p_load(dplyr, readr, tools, rlang, purrr)

# input files, provided as full path and filename. OBS! / not \
# file1 = new file
# file2 = older file

# KOMMUNEHELSA
file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2022NESSTAR/STONAD_LIVSOPPHOLD_2021-10-11-09-00.csv"
file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2021NESSTAR/STONAD_LIVSOPPHOLD_2021-01-08-13-45.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR/SESJON1_2023-01-28-21-09.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2022NESSTAR/SESJON1_2022-02-01-15-32.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/DATERT/csv/FORNOYDHET_FORELDRE_UNGDATA_2023-05-12-14-41.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2022NESSTAR/FORNOYDHET_FORELDRE_UNGDATA_2022-02-15-08-50.csv"

# NORGESHELSA
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/NORGESHELSA/NH2023NESSTAR/GJENNOMFORING_VGS_1_UTDANN_2023-01-03-14-47.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/NORGESHELSA/NH2022NESSTAR/GJENNOMFORING_VGS_NH_2022-03-14-12-49.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/NORGESHELSA/DATERT/csv/GJENNOMFORING_VGS_1_UTDANN_2023-03-17-14-58.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/NORGESHELSA/NH2023NESSTAR/GJENNOMFORING_VGS_1_UTDANN_2023-01-03-14-47.csv"


# read files
kube1 <- read_delim(file1, delim = ";")
kube2 <- read_delim(file2, delim = ";")


# Column names
names(kube1)
names(kube2)

#levels(as.factor(kube1$STATUS))
#levels(as.factor(kube2$STATUS))

kube1 %>% 
  select(-c(GEO, TELLER:last_col())) %>% 
  map(~levels(as.factor(.x)))
kube2 %>% 
  select(-c(GEO, TELLER:last_col())) %>% 
  map(~levels(as.factor(.x)))

# remove MEIS as old NH kubes do not have MEIS
#kube1 <- kube1 %>% 
#  select(-MEIS)

# RENAME
#kube2 <- kube2 %>% 
#  rename(BH_NORM = NORM)

# source compare kubes script
# needs to be in the current directory
# or specify path like this:
# source("path/to/where/script/is/compare_kubes_newcols.R")
source("compare_kubes_newcols.R")


# run merge and compare
compare <- compare_kube()

# write results table with flagged rows and provide summary, total and by year
view_write_compare_flagged(compare)

# OR !!

# write results table with all rows and provide summary, total and by year
view_write_compare_all(compare)







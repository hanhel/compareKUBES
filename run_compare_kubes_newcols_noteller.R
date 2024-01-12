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

# TESTING
#file1 <- "C:/Users/HANN/OneDrive - Folkehelseinstituttet/R_local/30_Testing_div/02_GEO/QC_GEO2024/QC_BARNEHAGE_KVALITET_2023-08-29-12-14.csv"
#file2 <- "C:/Users/HANN/OneDrive - Folkehelseinstituttet/R_local/30_Testing_div/02_GEO/QC/QC_BARNEHAGE_KVALITET_2023-08-29-12-14.csv"

# KOMMUNEHELSA
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR_PreAllvis_omkod2024GEO/GEO2024_GRUNNSKOLEPOENG_UTD_2023-03-07-14-01.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_GRUNNSKOLEPOENG_INNV_2023-11-03-16-05.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR_PreAllvis_omkod2024GEO/GEO2024_GRUNNSKOLEPOENG_INNV_2023-02-20-15-40.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_BARNEVERN_UNDERSOKELSE_2023-11-02-13-12.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC_omkod2024GEO/QC_GEO2024_BARNEVERN_UNDERSOKELSE_2023-10-19-13-53.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_BARNEVERN_TILTAK_2023-11-02-13-02.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC_omkod2024GEO/QC_GEO2024_BARNEVERN_TILTAK_2023-10-11-09-38.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR_PreAllvis_omkod2024GEO/GEO2024_GJENNOMFORING_VGS_INNVKAT_2023-01-03-20-18.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR_PreAllvis/BARNEVERN_UNDERSOKELSE_2023-03-07-14-04.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2022NESSTAR/BARNEVERN_TILTAK_2022-01-12-12-27.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_GJENNOMFORING_VGS_UTDANN_2023-09-12-09-25.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR_PreAllvis/BARNEVERN_TILTAK_2022-11-24-15-35.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2021NESSTAR/STONAD_LIVSOPPHOLD_2021-01-08-13-45.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2022NESSTAR/STONAD_LIVSOPPHOLD_2021-10-11-09-00.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_STONAD_LIVSOPPHOLD_2023-11-03-13-58.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_NEET_INNVKAT_2023-11-27-16-40.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR_PreAllvis_omkod2024GEO/GEO2024_NEET_INNVKAT_2023-01-27-12-42.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_LESEFERD_INNVKAT_2023-11-28-08-36.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR_PreAllvis_omkod2024GEO/GEO2024_LESEFERD_INNVKAT_2023-01-17-14-55.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_REGNEFERD_2023-11-28-08-40.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR_PreAllvis_omkod2024GEO/GEO2024_REGNEFERD_2022-12-19-22-01.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_REGNEFERD_2023-11-28-08-40.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR_PreAllvis_omkod2024GEO/GEO2024_REGNEFERD_2022-12-19-22-01.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR_PreAllvis_omkod2024GEO/GEO2024_GRUNNSKOLEPOENG_UTD_2023-03-07-14-01.csv"
#file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_GJENNOMFORING_VGS_INNVKAT_2023-11-02-12-27.csv"
#file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_GJENNOMFORING_VGS_INNVKAT_2023-12-06-12-15.csv"
file2 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/KH2023NESSTAR_PreAllvis_omkod2024GEO/GEO2024_ALKOHOL_UNGD_2022-12-22-11-29.csv"
file1 <- "F:/Forskningsprosjekter/PDB 2455 - Helseprofiler og til_/PRODUKSJON/PRODUKTER/KUBER/KOMMUNEHELSA/QC/QC_ALKOHOL_UNGD_2023-12-19-15-41.csv"

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

#kube1 <- kube1 %>% 
#  select(-TELLER)

# kube1 %>% 
#   select(-c(GEO, RATE:last_col())) %>% 
#   map(~levels(as.factor(.x)))
# kube2 %>% 
#   select(-c(GEO, RATE:last_col())) %>% 
#   map(~levels(as.factor(.x)))

# remove MEIS as old NH kubes do not have MEIS
#kube1 <- kube1 %>% 
#  select(-MEIS)

# RENAME
#kube2 <- kube2 %>% 
#  rename(BH_NORM = NORM)

# RE CLASS  
#kube1$GEO <- as.integer(kube1$GEO)

# source compare kubes script
# needs to be in the current directory
# or specify path like this:
# source("path/to/where/script/is/compare_kubes_newcols.R")
source("compare_kubes_newcols_noteller_diffmeis.R")


# run merge and compare
compare <- compare_kube()

# write results table with flagged rows and provide summary, total and by year
view_write_compare_flagged(compare)

# OR !!

# write results table with all rows and provide summary, total and by year
view_write_compare_all(compare)

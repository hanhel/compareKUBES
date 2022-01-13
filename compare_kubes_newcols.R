## Compare KUBE 
#- for comparing two kubes from different years.
# input = string containing full path and filename of file1 and file2  
#file1 = most recent file
#file2 = older file to compare with 


# install pacman - a tool for easy installing and loading the other required packages
if (!require("pacman")) install.packages("pacman")

# use pacman to install - if needed, and load packages
pacman::p_load(dplyr, tools, rlang)

# compareNA_unequal returns 0 wherever: 
# elements v1 and v2 are identical,
# are both missing,
# OR returns 1 whenever else.
compareNA_unequal <- function(v1,v2) {
    notsame <- case_when(abs(v1-v2) < 0.05 ~ 0,
						is.na(v1) & is.na(v2) ~ 0,
						TRUE ~ 1)
    return(notsame)
}

# compareNA_unequal_strict returns 0 wherever: 
# have less difference than 1
# the difference makes up less than 5% of v1
# are both missing,
# OR returns 1 whenever else.
compareNA_unequal_strict <- function(v1,v2) {
    notsame <- case_when((abs(v1-v2) < 1) ~ 0,
                        is.na(v1) & is.na(v2) ~ 0,
						#abs(v1-v2) / v1 < 0.05 ~ 0,
                        TRUE ~ 1)
    return(notsame)
}
   
   
# Find exlude year

find_excludeyear <- function() {
  
  if (n_distinct(kube1$AAR) > n_distinct(kube2$AAR)) {
  res <- kube1 %>% 
  filter(!AAR %in% kube2$AAR) %>% 
  select(AAR) %>% 
  unique()
  return(as.vector(res$AAR)
)
  
  } else {
  print("no exclude year")
  }

}

exclude_year <- find_excludeyear()



## input
# takes input:
# exclude_year -> wich year is not found in the oldest file,
# and cannot be compared, 
# usually in the form of e.g. "2020_2020"
# kube1, tible containing file1 
# kube2, tible containing file2. 
# (file1/file2 -> character string containing path and filename of file1/2, defined in main script)


# Identify new cols



compare_join_NAs <- function(exclude_year, kube1, kube2) {
  
  # if KUBE contains TELLER column, do
  if (any(colnames(kube1) == "TELLER")) {
    
	newcols <- names(kube1 %>% 
					select(!one_of(as.character(names(kube2)))))
	compare_cols <- names(kube1 %>% 
                            select(TELLER:SPVFLAGG))
    merge_by_cols <- names(kube1 %>% 
                             select(-compare_cols, -newcols))
    mutate_cols <- c("TELLER", "RATE", "SMR", "SPVFLAGG")
	rest_cols <- compare_cols[!compare_cols %in% mutate_cols]
    
	compare <- left_join(kube1 %>% 
                           filter(!AAR == exclude_year) %>%
						   {if(length(newcols) > 0) filter_at(., vars(newcols), any_vars(. == 0)) else .}, 
						   kube2, 
                         by = names(kube1 %>% 
                                      select(merge_by_cols))
    ) %>% 
      mutate(TELLER_diff = round(TELLER.x - TELLER.y, 2),
             RATE_diff = round(RATE.x - RATE.y, 2),
             SPVFLAGG_diff = SPVFLAGG.x - SPVFLAGG.y,
			       SMR_diff = SMR.x - SMR.y,
             TELLER_FLAG = compareNA_unequal_strict(TELLER.x, TELLER.y),
             RATE_FLAG = compareNA_unequal(RATE.x, RATE.y),
             SPVFLAGG_FLAG = compareNA_unequal(SPVFLAGG.x, SPVFLAGG.y),
			       SMR_FLAG = compareNA_unequal_strict(SMR.x, SMR.y),
      ) %>% 
      select(merge_by_cols, starts_with(mutate_cols), starts_with(rest_cols)) #%>%
	  return(compare)
  }
  
  # If KUBE contains antall column, do
  if (any(colnames(kube1) == "antall")) {
    
    compare_cols <- names(kube1 %>% 
                            select(antall:sumnevner)) # obs! new col names
    merge_by_cols <- names(kube1 %>% 
                             select(!compare_cols))
    
    compare <- left_join(kube1 %>% 
                           filter(!AAR == exclude_year) %>%
						   {if(length(newcols) > 0) filter_at(., vars(newcols), any_vars(. == 0)) else .}, 
						   kube2, 
                        by = names(kube1 %>% 
                                      select(merge_by_cols))
    ) %>% 
      mutate(antall_diff = antall.x - antall.y,
             Crude_diff = Crude.x - Crude.y,
             SPVFLAGG_diff = SPVFLAGG.x - SPVFLAGG.y,
             antall_FLAG = compareNA_unequal(antall.x, antall.y),
             Crude_FLAG = compareNA_unequal(Crude.x, Crude.y),
             SPVFLAGG_FLAG = compareNA_unequal(SPVFLAGG.x, SPVFLAGG.y)
      ) %>% 
      select(merge_by_cols, starts_with("antall"), starts_with("Crude"), starts_with("SPVFLAGG"))
    return(compare)
  }
}



sumdiff <- function(compare) {
  
  if (any(colnames(kube1) == "TELLER")) {
    
    res <- compare %>% 
      summarise_at(vars(TELLER_diff, RATE_diff, SMR_diff, SPVFLAGG_diff,
						TELLER_FLAG, RATE_FLAG, SMR_FLAG, SPVFLAGG_FLAG),  sum, na.rm = TRUE)

	return(res)
  }
  
  if (any(colnames(kube1) == "antall")) {
    
    res <- compare %>% 
      summarise(vars(antall_diff, Crude_diff, SPVFLAGG_diff, 
					antall_FLAG, Crude_FLAG, SPVFLAGG_FLAG), sum, na.rm = TRUE)
	return(res)
  }
  
}

sumdiff_aar <- function(compare) {
  
  if (any(colnames(kube1) == "TELLER")) {
    
    res <- compare %>% 
      group_by(AAR) %>% 
      summarise_at(vars(TELLER_diff, RATE_diff, SMR_diff, SPVFLAGG_diff,
                        TELLER_FLAG, RATE_FLAG, SMR_FLAG, SPVFLAGG_FLAG),  sum, na.rm = TRUE)
    
    return(res)
  }
  
  if (any(colnames(kube1) == "antall")) {
    
    res <- compare %>% 
      group_by(AAR) %>% 
      summarise(vars(antall_diff, Crude_diff, SPVFLAGG_diff, 
                     antall_FLAG, Crude_FLAG, SPVFLAGG_FLAG), sum, na.rm = TRUE)
    return(res)
  }
  
}


compare_kube <- function(file1, file2) {
  
  #kube1 <- read_delim(file1, delim = ";")
  #kube2 <- read_delim(file2, delim = ";")
  
  compare <- compare_join_NAs(exclude_year = exclude_year, kube1 = kube1, kube2 = kube2)
  
  return(compare)
}

view_write_compare <- function(compare) {
  
  ID1 <- file_path_sans_ext(basename(file1))
  ID2 <- file_path_sans_ext(basename(file2))
  
  res_dir <- Sys.Date()
  dir.create(paste0("compare_kube_res/", res_dir), recursive = TRUE)
  res_name <- paste0("compare_kube_res/", res_dir, "/", ID1, "vs", ID2, ".csv")
  
  if (any(colnames(kube1) == "TELLER")) {
    
    write <- compare %>% 
      filter(SPVFLAGG_FLAG == 1 | TELLER_FLAG == 1 | RATE_FLAG == 1 | SMR_FLAG == 1) %>% 
      filter(TELLER_FLAG == 1 | SPVFLAGG_FLAG == 1) %>%   # extra filtering step, ensuring either TELLER- or SPVFLAG FLAG
      write_delim(res_name, delim = ";")
  }
  
  if (any(colnames(kube1) == "antall")) {
    
    write <- compare %>% 
      filter(SPVFLAGG_FLAG == 1 | antall_FLAG == 1 | Crude_FLAG == 1) %>% 
      write_delim(res_name, delim = ";")
  }
  
  
  view <- sumdiff(compare)
  view_aar <- sumdiff_aar(compare)
  
  return(list(write, view, view_aar))
  
}

# write compare (whole file) for debugging purposes
write_delim(compare, "compare_kube_res/compare_barnevern.csv", delim = ";")

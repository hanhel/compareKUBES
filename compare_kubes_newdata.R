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
# elements v1 and v2 are identical (within an absolute difference < 0.05),
# are both missing,
# OR returns 1 whenever else.
compareNA_unequal <- function(v1,v2) {
  notsame <- case_when(abs(v1-v2) < 0.05 ~ 0,
                       is.na(v1) & is.na(v2) ~ 0,
                       TRUE ~ 1)
  return(notsame)
}

# compareNA_unequal_lesstrict returns 0 wherever: 
# less strict than compareNA_unequal
# have less difference than 1
# (the difference makes up less than 5% of v1 - NOT IN USE)
# are both missing,
# OR returns 1 whenever else.
compareNA_unequal_lesstrict <- function(v1,v2) {
  notsame <- case_when((abs(v1-v2) < 1) ~ 0,
                       is.na(v1) & is.na(v2) ~ 0,
                       #abs(v1-v2) / v1 < 0.05 ~ 0,
                       TRUE ~ 1)
  return(notsame)
}


# Find exlude year

find_excludeyear <- function() {
  
  if (any(!unique(kube1$AAR) %in% unique(kube2$AAR))) {
    res <- kube1 %>% 
      filter(!AAR %in% kube2$AAR) %>% 
      select(AAR) %>% 
      unique()
    return(as.vector(res$AAR)
    )
    
  } else {
    return("no exclude year")
  }
}

exclude_year <- find_excludeyear()
print(paste0("New year:", exclude_year))

# Print newcols - columns in kube1 (new) that are not found in kube2 (old)
find_newcols <- function(kube1, kube2) {
  
  newcols <- names(kube1 %>% 
                     select(!one_of(as.character(names(kube2)))))
  
  print_newcols <- ifelse(length(newcols) == 0,
                          print("No new columns in kube1, not found in kube2"),
                          print(paste0("Newcol detected: ", newcols)))
  return(print_newcols)
}

print_cols <- find_newcols(kube1 = kube1, kube2 = kube2)

# find and print expired columns
# that are found in kube2, and not in kube1
find_expcols <- function(kube1, kube2) {
  
  expcols <- names(kube2 %>% 
                     select(!one_of(as.character(names(kube1)))))
  
  print_expcols <- ifelse(length(expcols) == 0,
                          print("No expired columns in kube2, not found in kube1"),
                          print(paste0("Expired cols detected: ", expcols)))
  return(print_expcols)
}

print_expcols <- find_expcols(kube1 = kube1, kube2 = kube2)


### NEW DATA
# compare file1 (new file) with file2 (old file)
# add column "newrow" with 1 == newrow, NA (missing) if not newrow
# add column "newcol" if new column in file1, not present in file2 (OBS! maximum 1 newcol)
# , with newcol == 1 if subgroup ">0" of new column, else newcol == 0 if total group "0" of new column
# , hence assuming that the total group "0" is already present.
# write file1, containing columns newrow and newcol (if present)
# write summary file containing (only) new rows and columns

## FIND NEW DATA
find_newdata <- function(kube1, kube2) {
  
  if (any(colnames(kube1) == "TELLER")) {
    compare_cols <- names(kube1 %>% 
                            select(TELLER:last_col()))
  }
  
  if (any(colnames(kube1) == "antall")) {
    compare_cols <- names(kube1 %>% 
                            select(antall:last_col()))
  }
  
  # HACK for DODE
  if (rev(names(kube1))[1] == "ANTALL") {
    compare_cols <- names(kube1 %>% 
                            select(ANTALL))
  }
  
  newcols <- names(kube1 %>% 
                     select(!one_of(as.character(names(kube2)))))
  
  # Add flag newrow
  merge_by_1 <- kube1 %>% 
    select(-all_of(compare_cols))
  merge_by_2 <- kube2 %>% 
    select(-all_of(compare_cols))
  
  newrows <- anti_join(merge_by_1,
                       merge_by_2) %>% 
    mutate(newrow = 1)
  
  kube1_newrows <- left_join(kube1, newrows)
  
  # Add flag newcol
  kube1_newrows_newcols <- kube1_newrows %>% 
    {if(length(newcols) == 1) mutate(., newcol = ifelse(!!as.name(newcols) > 0, 1, 0)) else .} %>% 
    {if(length(newcols) == 2) mutate(., newcol = ifelse(!!as.name(newcols[1]) > 0 |
                                                          !!as.name(newcols[2]) > 0, 1, 0)) else .} %>% 
    {if(length(newcols) == 3) mutate(., newcol = ifelse(!!as.name(newcols[1]) > 0 |
                                                          !!as.name(newcols[2]) > 0 |
                                                          !!as.name(newcols[3]) > 0, 1, 0)) else .}
  
  return(kube1_newrows_newcols) 
}


## WRITE NEW DATA
write_newdata <- function() {
  
  ## FIND NEWDATA
  
  ID1 <- file_path_sans_ext(basename(file1))
  ID2 <- file_path_sans_ext(basename(file2))
  
  res_dir <- Sys.Date()
  dir.create(paste0("compare_kube_res/", res_dir), recursive = TRUE)
  res_name_newdata <- paste0("compare_kube_res/", res_dir, "/", "Newdata_", ID1, "vs", ID2, ".csv")
  
  kube1_newdata <- find_newdata(kube1 = kube1, kube2 = kube2)
  
  write_delim(kube1_newdata, res_name_newdata, delim = ";")
  
  ## SUMMARY NEWDATA
  ## Summery of new rows and columns
  compare_cols <- names(kube1 %>% 
                          select(TELLER:last_col()))
  newcols <- names(kube1 %>% 
                     select(!one_of(as.character(names(kube2)))))
  same_cols <- names(kube1 %>% 
                       select(-all_of(compare_cols), -all_of(newcols)))
  diff_rows <- setdiff(kube1 %>% 
                         select(all_of(same_cols)),
                       kube2 %>% 
                         select(all_of(same_cols)))
  
  # new rows
  diff_df <- data.frame()
  for (i in same_cols){
    colname <- i
    res <- unique(diff_rows[[i]][!diff_rows[[i]] %in% kube2[[i]]])
    
    if (length(res) > 0) {
      diff_i <- data.frame(var = i, diff = res)
      diff_df <- rbind(diff_df, diff_i)
    } else if(length(newcols) > 0) {
      diff_df <- data.frame(var = "newcol", diff = newcols)
    }
  }
  
  # Add new columns
  # if (length(res) > 0) {
  #   diff_df <- rbind(data.frame(var = "newcol", diff = newcols),
  #                    diff_df)
  # } else if(length(newcols) > 0) {
  #   diff_df <- data.frame(var = "newcol", diff = newcols)
  # }
  
  res_name_diff <- paste0("compare_kube_res/", res_dir, "/", "Summary_", ID1, "vs", ID2, ".csv")
  write_delim(diff_df, res_name_diff, delim = ";")
  
  print("new data:")
  diff_df
}


### COMPARE 

## input
# takes input:
# exclude_year = year not found in the oldest file, (detected automatically)
# and cannot be compared, # usually in the form of e.g. "2020_2020"
# kube1, tible containing file1 
# kube2, tible containing file2. 
# (file1/file2 -> character string containing path and filename of file1/2, defined in main script)
# Identify new cols in kube1, and filtering to include total group (0) only

compare_join_NAs <- function(exclude_year, kube1, kube2) {
  
  if (any(colnames(kube1) == "TELLER")) {
    compare_cols <- names(kube1 %>% 
                            select(TELLER:last_col()))
  }
  
  if (any(colnames(kube1) == "antall")) {
    compare_cols <- names(kube1 %>% 
                            select(antall:last_col()))
  }
  
  # HACK for DODE
  if (rev(names(kube1))[1] == "ANTALL") {
    compare_cols <- names(kube1 %>% 
                            select(ANTALL))
  }
  
  newcols <- names(kube1 %>% 
                     select(!one_of(as.character(names(kube2)))))
  expcols <- names(kube2 %>% 
                     select(!one_of(as.character(names(kube1)))))
  merge_by_cols <- names(kube1 %>% 
                           select(-all_of(compare_cols), -all_of(newcols)))
  mutate_cols <- c("TELLER", "MEIS", "RATE", "SMR", "antall", "Adjusted", "Crude", "SPVFLAGG", "ANTALL")
  rest_cols <- compare_cols[!compare_cols %in% mutate_cols]
  
  join <- left_join(kube1 %>% 
                      filter(!AAR %in% c(exclude_year)) %>%
                      {if(length(newcols) > 0) filter_at(., vars(newcols), all_vars(. == 0)) else .}, 
                    kube2 %>% 
                      {if(length(expcols) > 0) filter_at(., vars(expcols), all_vars(. == 0)) else .}, 
                    by = names(kube1 %>% 
                                 select(all_of(merge_by_cols)))) 
  
  # detect and mutate RATE (and similar) cols
  # in prioritized order MEIS > RATE > Adjusted > Crude
  if(any(grepl("MEIS", colnames(join)))){
    join <- join %>% 
      mutate(MEIS_diff = round(MEIS.x - MEIS.y, 2),
             MEIS_FLAG = compareNA_unequal(MEIS.x, MEIS.y))
  } else if(any(grepl("RATE", colnames(join)))){
    join <- join %>% 
      mutate(RATE_diff = round(RATE.x - RATE.y, 2),
             RATE_FLAG = compareNA_unequal(RATE.x, RATE.y))
  } else if(any(grepl("Adjusted", colnames(join)))){
    join <- join %>% 
      mutate(Adjusted_diff = round(Adjusted.x - Adjusted.y, 2),
             Adjusted_FLAG = compareNA_unequal(Adjusted.x, Adjusted.y))
  } else if(any(grepl("Crude", colnames(join)))){
    join <- join %>% 
      mutate(Crude_diff = round(Crude.x - Crude.y, 2),
             Crude_FLAG = compareNA_unequal(Crude.x, Crude.y))
  } else
    print("No MEIS, RATE, Adjusted or Crude cols found")
  
  # detect and mutate TELLER (and similar) ocls
  # in prioritized order TELLER > antall
  if(any(grepl("TELLER", colnames(join)))){
    join <- join %>% 
      mutate(TELLER_diff = round(TELLER.x - TELLER.y, 2),
             TELLER_FLAG = compareNA_unequal_lesstrict(TELLER.x, TELLER.y))
  }	else if(any(grepl("antall", colnames(join)))){
    join <- join %>% 
      mutate(antall_diff = antall.x - antall.y,
             antall_FLAG = compareNA_unequal_lesstrict(antall.x, antall.y))
  }	else if(any(grepl("ANTALL", colnames(join)))){
    join <- join %>% 
      mutate(antall_diff = ANTALL.x - ANTALL.y,
             antall_FLAG = compareNA_unequal_lesstrict(ANTALL.x, ANTALL.y))
  } else
    print("No TELLER, antall or ANTALL cols found")
  
  # detect and mutate SMR col, if present	
  if(any(grepl("SMR", colnames(join)))){
    join <- join %>% 
      mutate(SMR_diff = SMR.x - SMR.y,
             SMR_FLAG = compareNA_unequal_lesstrict(SMR.x, SMR.y))
  }
  
  # detect and mutate SVPFLAG col
  if(any(grepl("SPVFLAGG", colnames(join)))){
    join <- join %>% 
      mutate(SPVFLAGG_diff = SPVFLAGG.x - SPVFLAGG.y,
             SPVFLAGG_FLAG = compareNA_unequal(SPVFLAGG.x, SPVFLAGG.y))
  } else
    print("No SPVFLAGG col found")
  
  
  compare <- join %>% 
    select(any_of(merge_by_cols), starts_with(mutate_cols), starts_with(rest_cols))
  
  return(compare)
}



sumdiff <- function(compare) {
  
  res <- compare %>% 
    summarise_at(vars(matches("_diff|_FLAG")),  sum, na.rm = TRUE)
  
  return(res)
}

sumdiff_aar <- function(compare) {
  
  res <- compare %>% 
    group_by(AAR) %>% 
    summarise_at(vars(matches("_diff|_FLAG")),  sum, na.rm = TRUE)
  
  return(res)
  
}


# main compare cube function
# creating compare table with *_diff and *_FLAG cols
compare_kube <- function() {
  
  compare <- compare_join_NAs(exclude_year = exclude_year, kube1 = kube1, kube2 = kube2)
  
  return(compare)
}

# printing filtered output results from compare
# writing filtered output results from compare to ..
# "compare_kube_res/x_vs_y.csv"
view_write_compare <- function(compare) {
  
  ID1 <- file_path_sans_ext(basename(file1))
  ID2 <- file_path_sans_ext(basename(file2))
  
  res_dir <- Sys.Date()
  dir.create(paste0("compare_kube_res/", res_dir), recursive = TRUE)
  res_name <- paste0("compare_kube_res/", res_dir, "/", ID1, "vs", ID2, ".csv")
  
  flag_cols <- names(compare %>% 
                       select(ends_with("_FLAG")))
  
  flag_cols_strict <- names(compare %>% 
                              select(any_of(c("TELLER_FLAG", "antall_FLAG", "SPVFLAGG_FLAG"))))
  
  write <- compare %>% 
    filter_at(., .vars = flag_cols, any_vars(. == 1)) %>% 
    filter_at(., .vars = flag_cols_strict, any_vars(. == 1)) %>%  # extra filtering step, ensuring TELLER-, antall- or SPVFLAG FLAG
    write_delim(res_name, delim = ";")
  
  view <- sumdiff(compare)
  view_aar <- sumdiff_aar(compare)
  
  return(list(write, view, view_aar))
  
}

# write compare (whole file) for debugging purposes
#write_delim(compare, "compare_kube_res/compare_barnevern.csv", delim = ";")


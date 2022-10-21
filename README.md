# compareKUBES
Compare new KUBE with old KUBE


Takes input:
file1 <- "Path/to/most/recent/kube.csv"  
file2 <- "path/to/older/kube/for/comparing.csv"  

in the output:
file1 = x
file2 = y


Compare files
Use run_compare_kubes_newcols.R for comparing files

choose to write all rows with: view_write_compare_all(compare)
or just the fagged rows containing differenses with: view_write_compare_flagged(compare)


Compare files AND write new data
Use run_compare_kubes_newcols.R for comparing files AND creating
output tables with all new data - new columns or new rows flagged.

choose to write all rows with: view_write_compare_all(compare)
or just the fagged rows containing differenses with: view_write_compare_flagged(compare)


Run all lines in   
run_compare_kubes_newcols.R
or 
run_compare_kubes_newdata.R


Output:   
Inline summery of rows differing between the kubes,  
in total and for each year. 

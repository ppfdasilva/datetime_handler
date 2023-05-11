#######################################################
######## PREPARING THE ENVIROMENT #####################
#######################################################
library(fs)

rm(list=ls()) # deleting all variables in buffer

#######################################################
######## DECLARATION OF PARAMETERS ####################
#######################################################

DATEPATTERN = c('mdy', 'dmy', 'ymd', 'dym', 'myd',
                'mdy_HM', 'dmy_HM', 'ymd_HM', 'mdyHMS', 
                'dmyHMS', 'ymdHMS') # Define all possible date and hour patterns which can be found 

TZ = 'America/Sao_Paulo' # List of time zones: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones

path <- dir_ls("input/JBFO/Acompanhamento/2019-2021/") # Path to the directory where all files are stored

#######################################################
############### CODE BEGINNING ########################
#######################################################

medidores <- list() # Initialize list which stores dataframes in files

# Loop on i (number of the file in directory): Scan all files in the directory
for (i in seq_along(path))  { 
  medidores[[i]] <- read.csv2(path[[i]],header = T)
  maxdatediff <- data.frame() 
  
  # Loop on j (DATEPATTERN index): Access each of the date patterns 
  for (j in 1:length(DATEPATTERN)) {
    # Function transformadata: parse date according to each date pattern in DATEPATTERN  
     transformadata <- function(data) {
      parse_date_time(data, orders = DATEPATTERN[j])
    }
    
    # Function temdata: sum lines that were corrected parsed by transformadata function 
    temdata = function(data){
      funcao = !is.na(transformadata(data))
      sum(funcao, na.rm = T)
    }
    
    contacol = sapply(medidores[[i]] , temdata) # Count lines with identified data per column
    valormax = max(contacol) # Get the column with max parsed date
    indexmax = which(contacol == valormax) # Get index with the max number of parsed date (can be more than one)
    datecol = medidores[[i]][, indexmax] # Extract column with parsed date

    # Comparing the output of each datepattern which reached the threshold of data transformation
    threshold = 2/3 # The parser should at least reach this threshold to be considered correct
    if (valormax > threshold*nrow(medidores[[i]])) {
      datecol= transformadata(datecol)
      datediff = diff(datecol) # Get difference between lines of the date column
      datediffsum = sum(datediff, na.rm = T) # Sum the differences
      
      # maxdatediff: dataframe which stores the results of i, j, j_th DATEPATTERN, and datediffsum.
      maxdatediff = rbind(maxdatediff, data.frame('i' = i, 'j' = j,
                            'DatePattern' = DATEPATTERN[j], 'DiffDate' = datediffsum))
      
    }
  }
  
  # Considering that the smaller datediffsum is the output of the correct dateparser
  minsum = min(maxdatediff$DiffDate) # Get minimun datediffsum in maxdatediff
  minindex = which(maxdatediff$DiffDate == minsum) # Get row index of  minsum
  jidex = maxdatediff$j[minindex] # Correct j index
  
  # With the correct j, we parse the column with the correct datepattern which is DATEPATTERN[j]
  medidores[[i]][, indexmax] = parse_date_time(medidores[[i]][, indexmax], 
                                               orders = DATEPATTERN[jidex]) 
  # Print the result of correct date pattern
  print(paste0("The file number ", i, " has the date pattern as: ", DATEPATTERN[jidex]))
}

#######################################################
############## CODE END ###############################
#######################################################



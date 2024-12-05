# Set the working directory to where your flic files are store for the new FLIC
working_dir <- "C:/Users/perha/OneDrive/Desktop/NewFlic Files for R/FLIC_R_Code-master/FLIC"
setwd(working_dir)
# Define the base directory containing subfolders with DFMs - this is where it will look!!
base_dir <- "C:/Users/perha/OneDrive/Desktop/FLIC Queue"

# Load required libraries and attach FLIC functions
library(ggplot2)
library(stats)
library(gridExtra)
library(reshape2)
library(gtools)
attach("FLICFunctions", pos = 2)
p.choice<-ParametersClass.TwoWell()

# Set parameters (1=a, -1 = b)
p.choice <- SetParameter(p.choice, Feeding.Threshold = 100)
p.choice <- SetParameter(p.choice, Feeding.Minimum = 10)
p.choice <- SetParameter(p.choice, Baseline.Window.Minutes = 3)
p.choice <- SetParameter(p.choice, PI.Multiplier = 1)

# Traverse subfolders
folder_paths <- list.dirs(base_dir, recursive = FALSE)
for (folder_path in folder_paths) {
  # Get the folder name to use for the output file
  folder_name <- basename(folder_path)
  
  # List all files in the folder except those containing "whole"
  dfm_files <- list.files(folder_path, pattern = "DFM[0-9]+_.*\\.csv$", full.names = TRUE)
  dfm_files <- dfm_files[!grepl("whole", dfm_files, ignore.case = TRUE)]
  
  # Create an empty data frame to store all summaries for this folder
  folder_summaries <- data.frame()
  
  # Process each DFM file
  for (dfm_file in dfm_files) {
    # Extract DFM ID from the filename
    dfm_id <- as.numeric(sub("DFM([0-9]+)_.*\\.csv$", "\\1", basename(dfm_file)))
    
    if (is.na(dfm_id)) {
      cat("Skipping invalid file:", dfm_file, "\n")
      next
    }
    
    # Move the file to the working directory
    temp_file <- file.path(working_dir, basename(dfm_file))
    file.rename(dfm_file, temp_file)
    
    # Reset the DFM system
    CleanDFM()
    
    # Process the DFM
    dfm <- tryCatch({
      DFMClass(dfm_id, p.choice)
    }, error = function(e) {
      cat("Error processing DFM ID:", dfm_id, " - ", e$message, "\n")
      NULL
    })
    
    # Skip if DFMClass failed
    if (is.null(dfm)) {
      cat("Invalid DFM object for file:", temp_file, "\n")
      file.rename(temp_file, dfm_file)  # Move the file back
      next
    }
    
    cat("Processed DFM ID:", dfm_id, "in folder:", folder_name, "\n")
    
    # Generate the summary
    summary.choice <- Feeding.Summary.DFM(dfm)
    
    # Extract the first few rows of the summary
    summary_head <- head(summary.choice)
    
    # Add a column to identify the DFM ID
    summary_head$DFM_ID <- dfm_id
    
    # Append to the folder-level summary
    folder_summaries <- rbind(folder_summaries, summary_head)
    
    # Move the file back to its original location
    file.rename(temp_file, dfm_file)
  }
  
  # Save the folder-level summaries to a CSV file if there is data
  if (nrow(folder_summaries) > 0) {
    output_file <- file.path(folder_path, paste0("summaryfor", folder_name, "_.csv"))
    write.csv(folder_summaries, file = output_file, row.names = FALSE)
  } else {
    cat("No valid data found in folder:", folder_name, "\n")
  }
}

# Set the directory containing the subfolders
base_dir <- "C:\\Users\\perha\\OneDrive\\Desktop\\FLIC Queue"

# Load necessary libraries
library(dplyr)
library(tidyr)

# Get the list of subfolders
subfolders <- list.dirs(base_dir, recursive = FALSE)

# Loop through each subfolder
for (subfolder in subfolders) {
  # Identify the target file within the subfolder
  csv_files <- list.files(subfolder, pattern = "^summaryforDFM.*\\.csv$", full.names = TRUE)
  
  # Process each matching file
  for (file_path in csv_files) {
    # Read the CSV file
    data <- read.csv(file_path, stringsAsFactors = FALSE)
    
    # Select the first three columns
    selected_data <- data %>%
      select(DFM, Chamber, PI)
    
    # Reshape the data to wide format
    wide_data <- selected_data %>%
      pivot_wider(names_from = Chamber, values_from = PI) %>%
      arrange(DFM)
    
    # Separate odd and even columns
    odd_columns <- wide_data[, seq(2, ncol(wide_data), by = 2), drop = FALSE]
    even_columns <- wide_data[, seq(3, ncol(wide_data), by = 2), drop = FALSE]
    
    # Add a blank column between odd and even columns
    combined_data <- cbind(
      RowID = 1:nrow(wide_data), 
      odd_columns, 
      Blank = rep("", nrow(wide_data)), 
      even_columns
    )
    
    # Generate the output file name
    file_name <- basename(file_path)
    output_name <- paste0("formatted", file_name)
    output_path <- file.path(subfolder, output_name)
    
    # Write the new formatted CSV file
    write.csv(combined_data, output_path, row.names = FALSE, na = "")
  }
}

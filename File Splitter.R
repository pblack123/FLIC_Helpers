# Load necessary library
library(dplyr)

# Define the folder path
folder_path <- "C:/Users/perha/OneDrive/Desktop/FLIC SPLITTER FOLDER/"
chunk_size <- 54000  # 3 hours in rows

# List all CSV files in the folder
file_list <- list.files(path = folder_path, pattern = "*.csv", full.names = TRUE)
if (length(file_list) == 0) {
  stop("No CSV files found in the folder.")
}

# Process each file in the folder
for (input_file in file_list) {
  # Read the CSV file
  data <- read.csv(input_file, header = TRUE)
  
  # Calculate the total number of chunks
  num_chunks <- ceiling(nrow(data) / chunk_size)
  
  # Get the base filename for output
  base_name <- gsub("\\.csv$", "", basename(input_file))
  
  # Create a directory for the original file and its chunks
  output_folder <- file.path(folder_path, base_name)
  if (!dir.exists(output_folder)) {
    dir.create(output_folder)
  }
  
  # Move the original file to the output folder
  file.copy(input_file, file.path(output_folder, basename(input_file)), overwrite = TRUE)
  file.remove(input_file)  # Remove the original file from the main folder
  
  # Split the data into chunks and save each chunk in the new folder
  for (i in 1:num_chunks) {
    # Determine the row indices for this chunk
    start_row <- ((i - 1) * chunk_size) + 1
    end_row <- min(i * chunk_size, nrow(data))
    
    # Subset the data
    chunk_data <- data[start_row:end_row, ]
    
    # Define the output file name
    output_file <- paste0(output_folder, "/", base_name, "_", i, ".csv")
    
    # Write the chunk to a new CSV file
    write.csv(chunk_data, output_file, row.names = FALSE)
  }
}

cat("All files processed and organized successfully.")

# Define the base directory containing DFM folders
base_dir <- "C:/Users/perha/OneDrive/Desktop/FLIC Queue"

# Traverse subfolders and rename files
folder_paths <- list.dirs(base_dir, recursive = FALSE)
for (folder_path in folder_paths) {
  # List all CSV files in the folder
  dfm_files <- list.files(folder_path, pattern = "\\.csv$", full.names = TRUE)
  
  for (file_path in dfm_files) {
    # Extract the current filename
    current_name <- basename(file_path)
    
    # Determine if the file has one or two underscores
    if (grepl("DFM[0-9]+_[0-9]+\\.csv$", current_name)) {
      # Case with one underscore, rename to "DFMWHOLE_<number after DFM>.csv"
      dfm_number <- sub("DFM([0-9]+)_[0-9]+\\.csv", "\\1", current_name)
      new_name <- paste0("DFMWHOLE_", dfm_number, ".csv")
    } else if (grepl("DFM[0-9]+_[0-9]+_[0-9]+\\.csv$", current_name)) {
      # Case with two underscores, rename to "DFM<second number after last underscore>.csv"
      second_number <- sub(".*_([0-9]+)\\.csv$", "\\1", current_name)
      new_name <- paste0("DFM", second_number,"_", ".csv")
    } else {
      # If neither pattern matches, skip the file
      cat("Skipped invalid file:", current_name, "\n")
      next
    }
    
    # Construct the full path for the new file
    new_file_path <- file.path(folder_path, new_name)
    
    # Rename the file
    file.rename(file_path, new_file_path)
  }
}

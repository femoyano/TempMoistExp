# Init_variables.r

# Function to check if a file for initial values of state variables exists, else set initial values to 0

Init_values <- function(file) {
  ifelse (file.exits(file), load.csv(file), assign(file, 0))
  ifelse(get(file) == 0, print(paste("No initial data found for ", file, ". Initial values set to 0.", sep="")))
}

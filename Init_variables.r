# Init_variables.r

# Function to check if a file for initial values of state variables exists, else set initial values to 0

Init_values <- function(file) {
  return (ifelse (file.exits(file), load.csv(file), assign(file, 0))
}
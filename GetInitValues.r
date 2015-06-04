# GetInitValues.r

# Function to check if a file for initial values of state variables exists, else set initial values to 0

GetInitValues <- function(file) {
  if (file.exists(file)) {
    x <- read.table(file)
  } else {
    print(paste("No file named ", file, " was found. Initial values set to 0.", sep=""))
    x <- 0
  }
}
return(x)
}

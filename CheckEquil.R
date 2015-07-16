# Check.Equil.R

# Documentation  ===============================================================
# Function to check for equilibirum conditions
# Calculates the absolute change in C between the last two years of simulation
CheckEquil <- function(PC, i, eq.md, tsave, year) {
  j <- i * tunit / tsave + 1
  y1 <- PC[(j - (5 * year / tsave) + 1) : j]
  y2 <- PC[(j - (10 * year / tsave) + 1) : (j - (5 * year / tsave))]
  x <- abs(mean(y2) - mean(y1))
  ifelse(x <= (eq.md), TRUE, FALSE)
}

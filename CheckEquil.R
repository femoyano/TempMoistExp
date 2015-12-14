# Check.Equil.R

# Documentation  ===============================================================
# Function to check for equilibirum conditions
# Calculates the absolute change in C between the last five years of simulation
# and the previous 5 years.
# Returns TRUE if the change is smaller than eq.md (equilibrium maximum difference)
CheckEquil <- function(PC, i, eq.md, tsave, tstep, year, depth) {
  j <- i * tstep / tsave
  y1 <- PC[(j - (5 * year / tsave) + 1) : j] / depth
  y2 <- PC[(j - (10 * year / tsave) + 1) : (j - (5 * year / tsave))] / depth
  x <- abs(mean(y2) - mean(y1))
  ifelse(x <= (eq.md), TRUE, FALSE)
}

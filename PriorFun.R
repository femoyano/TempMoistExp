# Function calculating -2*log(parameter prior probability) required for the prior argument in FME mcmcMod

Prior <- function(p) {
  means <- c()
  sigma2 <- c()
  return( sum(((p - means)/sigma2)^2 ))
}

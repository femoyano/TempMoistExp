# analysis.R
# script to compare model and data

optimAnal <- function(data.meas, input.all, Modfit) {
  source("SampleRun.R")
  all.out <- SampleRun(Modfit$par, data.samples, input.all)
  AccumCalc(all.out)
}

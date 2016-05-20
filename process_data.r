require("plyr")
require("reshape2")

## clean
# rm(list = ls())

## Load and process data.
mtdata1 <- read.table("data.csv",header=T,sep=",",quote="\"")
sampledata <- read.table("samples.csv", header=T,sep=",",quote="\"")
# Round moisture to close values
mtdata1$moist_grav <- mtdata1$moist_grav / 100
mtdata1$moist_grav[mtdata1$moist_grav > 0.047 & mtdata1$moist_grav < 0.053] <- 0.05
mtdata1$moist_grav[mtdata1$moist_grav > 0.062 & mtdata1$moist_grav < 0.066] <- 0.065
mtdata1$moist_vol <- mtdata1$moist_grav * 1.8 # 1.8 is the dry soil bulk density
mtdata1$inc_end <- as.POSIXct(strptime(mtdata1$inc_end, format = "%d/%m/%Y %H:%M", tz = ""))
mtdata1$inc_start <- as.POSIXct(strptime(mtdata1$inc_start, format = "%d/%m/%Y %H:%M", tz = ""))
mtdata1$preinc_end <- as.POSIXct(strptime(mtdata1$preinc_end, format = "%d/%m/%Y %H:%M", tz = ""))
mtdata1$preinc_start <- as.POSIXct(strptime(mtdata1$preinc_start, format = "%d/%m/%Y %H:%M", tz = ""))

## ---------------------------------------------------------------------------------------
# End and start times of incubation periods should coincide.
# Differences of more than 1 day are assumed to be errors and are fixed in excel.
# Smaller differences are fixed here.

# First checking for times that differ by more than one day.
if(max(abs(mtdata1$preinc_end - mtdata1$inc_start)) > as.difftime(1, units = "days")) print("Need to correct inc_start and preinc_end dates for mistakes.")
checkdate <- function(df) {
  for (i in 1:(length(df[,1]) - 1)) {
    if (abs(df$inc_end[i] - df$preinc_start[i+1]) > as.difftime(1, units = "days")) print(df$sample[1])
  }
}
print("Samples for which inc_end and preinc_start dates need correction (if any):")
x <- by(mtdata1, mtdata1$sample, checkdate)
rm(x)

# If no more corrections needed, continue by making times equal.
mtdata1$preinc_end <- mtdata1$inc_start

# Calculate times for each incubation step
mtdata1$time_accum <- mtdata1$inc_end - mtdata1$inc_start
mtdata1$time_preinc <- mtdata1$preinc_end - mtdata1$preinc_start

# number the sequence of incubations of each sample
mtdata1 <- mtdata1[order(mtdata1$sample, mtdata1$preinc_start),]
mtdata1 <- ddply(mtdata1, .(sample), function(df) {df$tstage <- seq(1:length(df[,1])); return(df)})

### This entire section should be revised if used. And corrected C respired should come before.
## Calculate respiration rates (accum / time)
units(mtdata1$time_accum) <- "hours"

## ---------------------------------------------------------------------------------------
# Data quality flag
# (data here is flagged but not removed)
mtdata1$qflag <- logical(length = length(mtdata1[,1]))
mtdata1$qflag[mtdata1$site == "maize" & mtdata1$temp == 20 & mtdata1$moist_grav == 0.065 & mtdata1$tstage == 4] <- TRUE
# These below I don't know wher they come from
# mtdata1$qflag[mtdata1$site == "maize" & mtdata1$temp == 35 & mtdata1$moist_grav > 0.2] <- TRUE # remove cycle1-35C (bad measurements) & mtdata1$cycle=="cycle 1"
# mtdata1$qflag[mtdata1$site == "bare fallow" & mtdata1$cycle == "cycle 1" & mtdata1$temp == 5 & mtdata1$moist_grav > 0.14] <- TRUE
# mtdata1$qflag[mtdata1$site == "maize" & mtdata1$moist_grav > 0.24] <- TRUE
# mtdata1$qflag[mtdata1$site == "bare fallow" & mtdata1$moist_grav > 0.20] <- TRUE
mtdata1$CO2[mtdata1$qflag==TRUE] <- NA

## ---------------------------------------------------------------------------------------
# Function to put data in long format
melt_date <- function(df) {
  df <- melt(df, measure.vars = c(5:8), variable.name = "step", na.rm = FALSE,
       value.name = "date", factorsAsStrings = TRUE)
  df$date <- as.POSIXct(df$date, origin = "1970-01-01 00:00.00 CET")
  return(df)
}
mtdata2 <- ddply(mtdata1, .(sample), melt_date)

mtdata2$istep <- rep(0, length(mtdata2[,1]))
mtdata2$istep[mtdata2$step=="preinc_start"] <- 1
mtdata2$istep[mtdata2$step=="preinc_end"] <- 2
mtdata2$istep[mtdata2$step=="inc_start"] <- 3
mtdata2$istep[mtdata2$step=="inc_end"] <- 4

# extract start of first preincubation for each sample
preinc_start <- by(mtdata2, mtdata2$sample, function(df) {min(df$date)}, simplify = TRUE)
preinc_start <- as.POSIXct(as.numeric(preinc_start), origin = "1970-01-01 00:00.00 CET")

# # Remove rows with preincubation times
# mtdata2 <- mtdata2[mtdata2$istep!=1 & mtdata2$istep!=2, ]

# # determine start of first incubation for each sample
# inc_start <- by(mtdata2, mtdata2$sample, function(df) {min(df$date)}, simplify = TRUE)
# inc_start <- as.numeric(inc_start)

# order data
mtdata2 <- mtdata2[order(mtdata2$sample, mtdata2$tstage, mtdata2$istep),]

## ---------------------------------------------------------------------------------------
## simplify, getting rid of unnecessary data ##
fun_normtime <- function(df, preinc_start) {
  sample <- df$sample
  for(i in unique(sample)) {
    df$sec[sample == i] <- df$date[sample == i] - preinc_start[i]
  }
  return(df)
}
mtdata3 <- fun_normtime(mtdata2, preinc_start)

mtdata3$hour <- round(mtdata3$sec / 3600)
mtdata3$day <- mtdata3$hour /  24
mtdata3$date <- NULL
mtdata3$sample_old <- NULL
mtdata3$CO2[mtdata3$istep!=4] <- NA
mtdata3$time_accum[mtdata3$istep!=4] <- NA
mtdata3$time_preinc[mtdata3$istep!=2] <- NA

## ---------------------------------------------------------------------------------------
# Create dataframe selecting only points where measurements where made (for model data comparison)
mtdata4 <- mtdata3[mtdata3$step=="inc_end",]
mtdata4$time_preinc <- NULL
mtdata4$groupid <- NULL
mtdata4$istep <- NULL
mtdata4$step <- NULL
mtdata4$time_accum <- round(as.numeric(mtdata4$time_accum))

# Calculate gC respired per m-3 of soil
bd <- 1.8 # g cm-3
pd <- 2.6 # g cm-3
R <- 8314 # kPa * cm3 / (K * mol)
Cgmol <- 12 # grams of C per mol of CO2
dens_air <- 1.19 / 1000 # g cm-3 at 22.5C
mtdata4$air_vol <- mtdata4$flask_vol - (mtdata4$dry_soil / pd)
mtdata4$air_mol <- mtdata4$air_vol * 100 / (293 * R) # ideal gas law using cm3, kPa and K
mtdata4$C_R <- (mtdata4$CO2 / 1000000) * mtdata4$air_mol * 12 / (mtdata4$dry_soil / 1000) # gC respired per kg soil
mtdata4 <- mtdata4[!is.na(mtdata4$C_R),] # remove missing values

# Calculate the variance in groups of measurements. For this we use respiration rates.
mtdata4$order <- seq(1,nrow(mtdata4),1)
# round_acc_time <- round(mtdata4$time_accum/12) # treat as equal if times are close
meas_rep <- interaction(mtdata4$site, mtdata4$temp, mtdata4$moist_grav)
length(unique(meas_rep))
# Function to calculate variance based on CV of rates. Not exactly correct, but...
mtdata4$C_R_r <- mtdata4$C_R/mtdata4$time_accum * 1000  # convert to mgC/h
fun.calc.sd <- function(df) {
  df$sd.r <- sd(df$C_R_r, na.rm = TRUE)
  df$cv.r <- sd(df$C_R_r, na.rm = TRUE) / mean(df$C_R_r, na.rm = TRUE)
  return (df)
}

mtdata4 <- ddply(mtdata4, .(meas_rep), fun.calc.sd)
mtdata4$cv.r[is.na(mtdata4$cv.r)] <- mean(mtdata4$cv.r, na.rm = TRUE)
mtdata4$sd.r[is.na(mtdata4$sd.r)] <- mean(mtdata4$cv.r, na.rm = TRUE) * mtdata4$C_R_r[is.na(mtdata4$sd.r)]
mtdata4$sd.acc <- mtdata4$cv.r * mtdata4$C_R
mtdata4$meas_rep <- NULL
mtdata4 <- mtdata4[order(mtdata4$order),]
rownames(mtdata4) <- NULL

## ---------------------------------------------------------------------------------------
# Create dataframe for model input data
mtdata5 <- subset(mtdata3, select = c(sample, hour, temp, moist_vol))
mtdata5$moist <- mtdata5$moist_vol
mtdata5$moist_vol <- NULL
rownames(mtdata5) <- NULL
mtdata5$remove <- FALSE

# Define a function that will remove duplicated cases and create an hour of transition
# between temperature changes
cleanInput <- function(df) {
  for (i in 2:(nrow(df)-1)) {
    if (df$hour[i] == df$hour[i-1] & df$temp[i] == df$temp[i-1]) df$remove[i] <- TRUE
    if (df$temp[i] == df$temp[i-1] & df$temp[i] == df$temp[i+1]) df$remove[i] <- TRUE
  }
  df <- df[df$remove == FALSE,]
  for (i in 2:nrow(df)) {
    if (df$hour[i] == df$hour[i-1]) df$hour[i] <- df$hour[i] + 1
  }
  return(df)
}
mtdata5 <- ddply(mtdata5, .(sample), cleanInput)
mtdata5$remove <- NULL
mtdata5$litter_met <- 0
mtdata5$litter_str <- 0
mtdata5$temp <- mtdata5$temp + 273  # convert to Kelvin

## Write out data
write.csv(mtdata4, file = "mtdata_co2.csv", row.names = FALSE)
write.csv(mtdata5, file = "mtdata_model_input.csv", row.names = FALSE)

#### Unused code --------------------------------
# ## Normalize values using maximums of polynomial fits (both cycles combined)
# # define the function
# sitetemp <- interaction(mtdata1$site, mtdata1$temp)
# data_sel <- subset(mtdata1, select = c(site, temp, moist_vol, CO2_rate))
# for (i in unique(sitetemp)) {
#   data_sel <- mtdata1[sitetemp==i,]
#   pol <- lm(CO2_rate ~ poly(moist_vol, 3), data = data_sel)
#   new <- data.frame(moist_vol = seq(0.01, max(data_sel$moist_vol, na.rm = TRUE), 0.01))
#   maxval <- max(predict(pol, newdata = new))
#   mtdata1$CO2r_norm[sitetemp==i] <- mtdata1$CO2_rate[sitetemp==i] / maxval
# }
# rm(new, data_sel, pol, sitetemp, maxval, i)
## ---------------------------------------------------------------------------------------
## Marking outliers
# Note: removing outliers is not a good idea since measurements in each group are from different
# times and could reflect dyfferent DOC dynamics, etc.
# Also: Careful! Don't use accum CO2 since each is for different amounts of time.
# mtdata1$groupid <- interaction(mtdata1$site, mtdata1$temp)  # create group variable
# mtdata1$olflag <- logical(length = length(mtdata1$CO2_rate))  # create outlier flag
# # Function to mark outliers:
# fun.rm.ol <- function(df) {
#   xsd <- 2
#   o <- xsd * sd(df$CO2_rate, na.rm = TRUE) # set here range for outlier detection
#   m <- mean(df$CO2_rate, na.rm = TRUE)
#   df$olflag[df$CO2_rate > (m + o) | df$CO2_rate < (m - o)] <- TRUE # mark outlier
#   return (df)
# }
# mtdata1 <- ddply(mtdata1, .(groupid), fun.rm.ol)
# rm(fun.rm.ol)
# mtdata1 <- mtdata1[order(mtdata1$sample, mtdata1$tstage),]
# rownames(mtdata1) <- NULL


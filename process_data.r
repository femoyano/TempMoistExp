require("plyr")
require("reshape2")

## clean
rm(list = ls())

## Load and process data.
mtdata_1 <- read.table("data.csv",header=T,sep=",",quote="\"")
sampledata <- read.table("samples.csv", header=T,sep=",",quote="\"")
mtdata_1$moist_vol <- mtdata_1$moist_grav * 1.8 # 1.8 is the dry soil bulk density
mtdata_1$moist_grav <- mtdata_1$moist_grav / 100
mtdata_1$moist_vol <- mtdata_1$moist_vol / 100
mtdata_1$inc_end <- as.POSIXct(strptime(mtdata_1$inc_end, format = "%d/%m/%Y %H:%M", tz = ""))
mtdata_1$inc_start <- as.POSIXct(strptime(mtdata_1$inc_start, format = "%d/%m/%Y %H:%M", tz = ""))
mtdata_1$preinc_end <- as.POSIXct(strptime(mtdata_1$preinc_end, format = "%d/%m/%Y %H:%M", tz = ""))
mtdata_1$preinc_start <- as.POSIXct(strptime(mtdata_1$preinc_start, format = "%d/%m/%Y %H:%M", tz = ""))

## ---------------------------------------------------------------------------------------
# End and start times of incubation periods should coincide.
# Differences of more than 1 day are assumed to be errors and are fixed in excel.
# Smaller differences are fixed here.

# First checking for times that differ by more than one day.
if(max(abs(mtdata_1$preinc_end - mtdata_1$inc_start)) > as.difftime(1, units = "days")) print("Need to correct inc_start and preinc_end dates for mistakes.")
checkdate <- function(df) {
  for (i in 1:(length(df[,1]) - 1)) {
    if (abs(df$inc_end[i] - df$preinc_start[i+1]) > as.difftime(1, units = "days")) print(df$sample[1])
  }
}
print("Samples for which inc_end and preinc_start dates need correction (if any):")
x <- by(mtdata_1, mtdata_1$sample, checkdate)
rm(x)

# If no more corrections needed, continue by making times equal.
mtdata_1$preinc_end <- mtdata_1$inc_start

# Calculate times for each incubation step
mtdata_1$time_accum <- mtdata_1$inc_end - mtdata_1$inc_start
mtdata_1$time_preinc <- mtdata_1$preinc_end - mtdata_1$preinc_start

# number the sequence of incubations of each sample
mtdata_1 <- mtdata_1[order(mtdata_1$sample, mtdata_1$preinc_start),]
mtdata_1 <- ddply(mtdata_1, .(sample), function(df) {df$tstage <- seq(1:length(df[,1])); return(df)})

## Calculate respiration rates (accum / time)
units(mtdata_1$time_accum) <- "hours"
mtdata_1$CO2_rate <- mtdata_1$CO2 / as.numeric(mtdata_1$time_accum) # CO2 per hour

## Normalize values using maximums of polynomial fits (both cycles combined)
# define the function
sitetemp <- interaction(mtdata_1$site, mtdata_1$temp)
data_sel <- subset(mtdata_1, select = c(site, temp, moist_vol, CO2_rate))
for (i in unique(sitetemp)) {
  data_sel <- mtdata_1[sitetemp==i,]
  pol <- lm(CO2_rate ~ poly(moist_vol, 3), data = data_sel)
  new <- data.frame(moist_vol = seq(0.01, max(data_sel$moist_vol, na.rm = TRUE), 0.01))
  maxval <- max(predict(pol, newdata = new))
  mtdata_1$CO2r_norm[sitetemp==i] <- mtdata_1$CO2_rate[sitetemp==i] / maxval
}
rm(new, data_sel, pol, sitetemp, maxval, i)

## ---------------------------------------------------------------------------------------
# Data quality flag -  this should be checked, where does this come from?
# (data here is flagged but not removed)
mtdata_1$qflag <- logical(length = length(mtdata_1[,1]))
mtdata_1$qflag[mtdata_1$site == "maize" & mtdata_1$temp == 35 & mtdata_1$moist_grav > 0.2] <- TRUE # remove cycle1-35C (bad measurements) & mtdata_1$cycle=="cycle 1"
mtdata_1$qflag[mtdata_1$site == "bare fallow" & mtdata_1$cycle == "cycle 1" & mtdata_1$temp == 5 & mtdata_1$moist_grav > 0.14] <- TRUE
mtdata_1$qflag[mtdata_1$site == "maize" & mtdata_1$moist_grav > 0.24] <- TRUE
mtdata_1$qflag[mtdata_1$site == "bare fallow" & mtdata_1$moist_grav > 0.20] <- TRUE

## ---------------------------------------------------------------------------------------
## Removing outliers
# Note: removing outliers is not a good idea since measurements in each group are from different
# times and could reflect dyfferent DOC dynamics, etc.
# Also: Careful! Don't use accum CO2 since each is for different amounts of time.
mtdata_1$groupid <- interaction(mtdata_1$site, mtdata_1$temp)  # create group variable
mtdata_1$olflag <- logical(length = length(mtdata_1$CO2_rate))  # create outlier flag
# Function to mark outliers:
fun.rm.ol <- function(df) {
  xsd <- 2
  o <- xsd * sd(df$CO2_rate, na.rm = TRUE) # set here range for outlier detection
  m <- mean(df$CO2_rate, na.rm = TRUE)
  df$olflag[df$CO2_rate > (m + o) | df$CO2_rate < (m - o)] <- TRUE # mark outlier
  return (df)
}
mtdata_1 <- ddply(mtdata_1, .(groupid), fun.rm.ol)
rm(fun.rm.ol)
mtdata_1 <- mtdata_1[order(mtdata_1$sample, mtdata_1$tstage),]
rownames(mtdata_1) <- NULL

## ---------------------------------------------------------------------------------------
# Function to put data in long format
melt_date <- function(df) {
  df <- melt(df, c(1:4, 9:19), c(5:8), variable.name = "step", na.rm = FALSE,
       value.name = "date", factorsAsStrings = TRUE)
  df$date <- as.POSIXct(df$date, origin = "1970-01-01 00:00.00 CET")
  return(df)
}
mtdata_2 <- ddply(mtdata_1, .(sample), melt_date)

mtdata_2$istep <- rep(0, length(mtdata_2[,1]))
mtdata_2$istep[mtdata_2$step=="preinc_start"] <- 1
mtdata_2$istep[mtdata_2$step=="preinc_end"] <- 2
mtdata_2$istep[mtdata_2$step=="inc_start"] <- 3
mtdata_2$istep[mtdata_2$step=="inc_end"] <- 4

# extract start of first preincubation for each sample
preinc_start <- by(mtdata_2, mtdata_2$sample, function(df) {min(df$date)}, simplify = TRUE)
preinc_start <- as.POSIXct(as.numeric(preinc_start), origin = "1970-01-01 00:00.00 CET")

# # Remove rows with preincubation times
# mtdata_2 <- mtdata_2[mtdata_2$istep!=1 & mtdata_2$istep!=2, ]

# # determine start of first incubation for each sample
# inc_start <- by(mtdata_2, mtdata_2$sample, function(df) {min(df$date)}, simplify = TRUE)
# inc_start <- as.numeric(inc_start)

# order data
mtdata_2 <- mtdata_2[order(mtdata_2$sample, mtdata_2$tstage, mtdata_2$istep),]

## ---------------------------------------------------------------------------------------
## simplify, getting rid of unnecessary data ##
fun_normtime <- function(df, preinc_start) {
  sample <- df$sample
  for(i in unique(sample)) {
    df$sec[sample == i] <- df$date[sample == i] - preinc_start[i]
  }
  return(df)
}
mtdata_3 <- fun_normtime(mtdata_2, preinc_start)

mtdata_3$hour <- round(mtdata_3$sec / 3600)
mtdata_3$day <- mtdata_3$hour /  24
mtdata_3$date <- NULL
mtdata_3$sample_old <- NULL
mtdata_3$CO2[mtdata_3$istep!=4] <- NA
mtdata_3$time_accum[mtdata_3$istep!=4] <- NA
mtdata_3$time_preinc[mtdata_3$istep!=2] <- NA
mtdata_3$CO2_rate[mtdata_3$istep!=4] <- NA
mtdata_3$CO2r_norm[mtdata_3$istep!=4] <- NA

## ---------------------------------------------------------------------------------------
# Create dataframe selecting only points where measurements where made (for model data comparison)
mtdata_4 <- mtdata_3[mtdata_3$step=="inc_end",]
mtdata_4$time_preinc <- NULL
mtdata_4$groupid <- NULL
mtdata_4$istep <- NULL
mtdata_4$step <- NULL
mtdata_4$time_accum <- round(as.numeric(mtdata_4$time_accum))

# Calculate gC respired per m-3 of soil
bd <- 1.8 # g cm-3
pd <- 2.6 # g cm-3
R <- 8314 # kPa * cm3 / (K * mol)
Cgmol <- 12 # grams of C per mol of CO2
dens_air <- 1.19 / 1000 # g cm-3 at 22.5C
mtdata_4$air_vol <- mtdata_4$flask_vol - (mtdata_4$dry_soil / pd)
mtdata_4$air_mol <- mtdata_4$air_vol * 100 / (293 * R) # ideal gas law using cm3, kPa and K
mtdata_4$C_R <- (mtdata_4$CO2 / 1000000) * mtdata_4$air_mol * 12 / (mtdata_4$dry_soil / 1000) # gC respired per kg soil
mtdata_4 <- mtdata_4[!is.na(mtdata_4$C_R),] # remove missing values

# Calculate the variance in groups of measurements. For this we use respiration rates.
mtdata_4$order <- seq(1,nrow(mtdata_4),1)
moist_app <- mtdata_4$moist_grav
moist_app[moist_app > 0.047 & moist_app < 0.053] <- 0.05
moist_app[moist_app > 0.062 & moist_app < 0.066] <- 0.065
# round_acc_time <- round(mtdata_4$time_accum/12) # treat as equal if times are close
meas_rep <- interaction(mtdata_4$site, mtdata_4$temp, moist_app)
length(unique(meas_rep))
# Function to calculate variance based on CV of rates. Not exactly correct, but...
fun.calc.sd <- function(df) {
  rate <- df$C_R/df$time_accum
  df$cv <- sd(rate, na.rm = TRUE) / mean(rate, na.rm = TRUE)
  return (df)
}
mtdata_4 <- ddply(mtdata_4, .(meas_rep), fun.calc.sd)
mtdata_4$cv[is.na(mtdata_4$cv)] <- mean(mtdata_4$cv, na.rm = TRUE)
mtdata_4$sd <- mtdata_4$cv * mtdata_4$C_R
mtdata_4$meas_rep <- NULL
mtdata_4 <- mtdata_4[order(mtdata_4$order),]
rownames(mtdata_4) <- NULL


## ---------------------------------------------------------------------------------------
# Create dataframe for model input data
mtdata_5 <- subset(mtdata_3, select = c(sample, hour, temp, moist_vol))
mtdata_5$moist <- mtdata_5$moist_vol
mtdata_5$moist_vol <- NULL
rownames(mtdata_5) <- NULL
mtdata_5$remove <- FALSE

# Define a function that will remove duclicated cases and create an hour of transition
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
mtdata_5 <- ddply(mtdata_5, .(sample), cleanInput)
mtdata_5$remove <- NULL
mtdata_5$litter_met <- 0
mtdata_5$litter_str <- 0
mtdata_5$temp <- mtdata_5$temp + 273  # convert to Kelvin

## Write out data
write.csv(mtdata_4, file = "mtdata_co2.csv", row.names = FALSE)
write.csv(mtdata_5, file = "mtdata_model_input.csv", row.names = FALSE)



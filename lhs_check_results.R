load('runs.out_lh10000_v1.Rdata')
runs.out1 <- runs.out
load('runs.out_lh20000_v1.Rdata')
runs.out <- rbind(runs.out1, runs.out)

pars1 <- read.csv('../parsets/pars_lh10000_bounds1_v1.csv')
pars2 <- read.csv('../parsets/pars_lh20000_bounds1_v1.csv')
lhs_pars <- rbind(pars1, pars2)

rm(runs.out1,  pars1, pars2)

top <- 5

# For each column containing model cost estimates, print the row with the lowest cost
for(i in 1:6) cat(colnames(runs.out)[i], '\n', which(runs.out[,i]==min(runs.out[,i])), '  ', runs.out[runs.out[,i]==min(runs.out[,i]),i], '\n')

# Calculate the sum of costs for SR and TR and print the the row with the lowest value
for (i in c(1,3,5)) {
  t <- c('sd', 'sd', 'm', 'm', 'uw', 'uw')
  file <- paste0('../parsets/pars_lhs30000_v1_top10_sum_',t[i],'.csv')
  sumrank <- rank(rank(runs.out[,i])+rank(runs.out[,i+1]))
  top10 <- match(c(1:10), sumrank)
  pars <- lhs_pars[top10,]
  write.csv(pars, file, row.names = FALSE)
}


for (i in c(1:6)) {
  cost <- runs.out[,i]
  top10 <- match(c(1:10), rank(cost))
  print(runs.out[top10,1:6])
  file <- paste0('../parsets/pars_lhs30000_v1_top10_',colnames(runs.out)[i],'.csv')
  pars <- lhs_pars[top10,]
  write.csv(pars, file, row.names = FALSE)
}


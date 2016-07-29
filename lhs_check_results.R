load('../runs-4f5e64a2-lh10000/runs.lh10000-b1-v1.out.Rdata')
lhs_pars <- read.csv('../parsets/pars_lh10000_bounds1_v1.csv')

# For each column containing model cost estimates, print the row with the lowest cost
for(i in 1:6) cat(colnames(runs.out)[i], '\n', which(runs.out[,i]==min(runs.out[,i])), '  ', runs.out[runs.out[,i]==min(runs.out[,i]),i], '\n')

# # Calculate the sum of costs for SR and TR and print the the row with the lowest value
# for (i in c(1,3,5)) {
#   ranksum <- rank(runs.out[,colnames(runs.out)[i]])+rank(runs.out[,colnames(runs.out)[i+1]])
#   minsum <- which.min(ranksum)
#   print(ranksum[minsum])
#   print(runs.out[minsum,])
# }
# pars <- lhs_pars[7146,]
# pars <- data.frame(par = names(pars), value = as.numeric(pars))
# write.csv(pars, '../parsets/parset17_lhs7146.csv', row.names = FALSE)

for (i in c(1:6)) {
  cost <- runs.out[,i]
  top10 <- match(c(1:10), rank(cost))
  file <- paste0('../parsets/pars_lhs10000_v1_top10_',colnames(runs.out)[i],'.csv')
  pars <- lhs_pars[top10,]
  write.csv(pars, file, row.names = FALSE)
}


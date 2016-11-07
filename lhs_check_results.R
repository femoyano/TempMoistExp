# load('runs.out_lh10000_v1.Rdata')
# runs.out1 <- runs.out
# load('runs.out_lh20000_v1.Rdata')
# runs.out <- rbind(runs.out1, runs.out)
# 
# pars1 <- read.csv('../parsets/pars_lh10000_bounds1_v1.csv')
# pars2 <- read.csv('../parsets/pars_lh20000_bounds1_v1.csv')
# lhs_pars <- rbind(pars1, pars2)
# 
# rm(runs.out1,  pars1, pars2)
# 
# top <- 5
# 
# # For each column containing model cost estimates, print the row with the lowest cost
# for(i in 1:6) cat(colnames(runs.out)[i], '\n', which(runs.out[,i]==min(runs.out[,i])), '  ', runs.out[runs.out[,i]==min(runs.out[,i]),i], '\n')
# 
# # Calculate the sum of costs for SR and TR and print the the row with the lowest value
# for (i in c(1,3,5)) {
#   t <- c('sd', 'sd', 'm', 'm', 'uw', 'uw')
#   file <- paste0('../parsets/pars_lhs30000_v1_top10_sum_',t[i],'.csv')
#   sumrank <- rank(rank(runs.out[,i])+rank(runs.out[,i+1]))
#   top10 <- match(c(1:10), sumrank)
#   pars <- lhs_pars[top10,]
#   write.csv(pars, file, row.names = FALSE)
# }
# 
# 
# for (i in c(1:6)) {
#   cost <- runs.out[,i]
#   top10 <- match(c(1:10), rank(cost))
#   print(runs.out[top10,1:6])
#   file <- paste0('../parsets/pars_lhs30000_v1_top10_',colnames(runs.out)[i],'.csv')
#   pars <- lhs_pars[top10,]
#   write.csv(pars, file, row.names = FALSE)
# }

plotdens <- function(pars, id) {
  library(RColorBrewer)
  col_palette<-c(brewer.pal(9,"Set1"), brewer.pal(9,"Set3"))
  densities<-list()
  for(i in 1:dim(pars)[2]){
    densities[[i]]<-density(pars[,i])
  }
  png(paste0(id, "_18pars.png"), height=800, width=1000)
  par(mfrow=c(5,4))
  for(i in 1:dim(pars)[2]){
    plot(densities[[i]], main=colnames(pars)[i])
    polygon(densities[[i]], col=col_palette[i])
  }
  dev.off()  
}

lhs_pars <- read.csv('../parsets/pars_lh100000_bounds1_v1.csv')

# For each column containing model cost estimates, print the row with the lowest cost
# for(i in 1:2) cat(colnames(runs.out)[i], '\n', which(runs.out[,i]==min(runs.out[,i])), '  ', runs.out[runs.out[,i]==min(runs.out[,i]),i], '\n')

# Calculate the sum of costs for SR and TR and print the the row with the lowest value

topnum <- 100
file <- paste0('parsets/pars_lhs100000_top', topnum,'.csv')
sumrank <- rank(runs.out[,1])+rank(runs.out[,2])
top <- match(sort(sumrank)[1:topnum], sumrank)
pars <- lhs_pars[top,]
write.csv(pars, file, row.names = FALSE)
plotdens(pars, 'sumrank')

for (i in c(1:2)) {
  cost <- runs.out[,i]
  top <- match(sort(cost)[1:topnum], cost)
  # print(runs.out[top,1:2])
  file <- paste0('parsets/pars_lhs100000_top', topnum, colnames(runs.out)[i],'.csv')
  pars <- lhs_pars[top,]
  write.csv(pars, file, row.names = FALSE)
  plotdens(pars,colnames(runs.out)[i])
}



load('../runs/runs-4f5e64a2-lh10000/runs.lh10000-b1-v1.out.Rdata')

colnames(runs.out)

for(i in 1:6) cat(colnames(runs.out)[i], '\n', which(runs.out[,i]==min(runs.out[,i])), '  ', runs.out[runs.out[,i]==min(runs.out[,i]),i], '\n')

for (i in c(1,3,5)) {
  ranksum <- rank(runs.out[,colnames(runs.out)[i]])+rank(runs.out[,colnames(runs.out)[i+1]])
  minsum <- which.min(ranksum)
  print(ranksum[minsum])
  print(runs.out[minsum,])
}

lhs_pars <- read.csv('pars_lh10000_bounds1_v1.csv')
pars <- lhs_pars[7146,]
write.csv(pars, 'parset17_lhs7146.csv', row.names = FALSE)

colnames(runs.out)

for(i in 1:6) cat(colnames(runs.out)[i], '\n', min(runs.out[,i]), '\n')

for(i in 1:6) cat(colnames(runs.out)[i], '\n', which(runs.out[,i]==min(runs.out[,i])), '  ', runs.out[which(runs.out[,i]==min(runs.out[,i])),i], '\n')

for (i in c(1,3,5)) {
  ranksum <- rank(runs.out[,colnames(runs.out)[i]])+rank(runs.out[,colnames(runs.out)[i+1]])
  minsum <- which.min(ranksum)
  print(ranksum[minsum])
  print(runs.out[minsum,])
}

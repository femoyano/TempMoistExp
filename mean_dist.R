# formula for distance in 2 planes: d = sqrt((x2-x1)^2 + (y2-y1)^2 + (z2-z1)^2)

n <- 100

avg.nn.dist <- rep(NA, n) # average nearest neihgbor distance

for (i in 2:n) {
  #   browser()
  d <- runif(i*3, 0, 1)
  a <- matrix(d, nrow=i, ncol=3)
  c <- combn(length(a[,1]), 2)
  dvec <- rep(NA, dim(c)[2])
  for (j in 1:dim(c)[2]) {
    x <- a[c[1,j], ]
    y <- a[c[2,j], ]
    d <- sqrt((x[1]-y[1])^2 + (x[2]-y[2])^2 + (x[3]-y[3])^2)
    dvec[j] <- d
  }
  avg.nn.dist[i] <- mean(tapply(dvec, c[1,], min)) 
}

num <- seq(1, n)
fit1 <- nls(avg.nn.dist ~ x*num^(-1/3), start=list(x=0.5))
summary(fit1)
plot(avg.nn.dist ~ num)
lines(predict(fit1))

# best fit seems to be: 0.9 * n^(-1/3)
NND <- function(x) {0.9 * x^(-1/3)}
curve(NND, 0, 100)

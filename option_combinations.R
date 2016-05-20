# Possible combinations to run model

f.ads <- c(0,1)
f.dce <- c(0,1)
f.dte <- c(0,1)
f.fcs <- c(0,1)
f.mic <- c(0,1)
f.sew <- c(0,1)
dce.f <- c("exp", "lin")
diff.f <- c("cubic", "hama")
cost.t <- c("rate.sd", "rate.mean")

combinations <- expand.grid(f.dce=f.dce, f.dte=f.dte, f.fcs=f.fcs, f.sew=f.sew, f.mic=f.mic)

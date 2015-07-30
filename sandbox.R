# 
V <- 2.5 # [gC gC^-1 d^-1]
K <- 0.05 # [gC cm_H2O^-3]
x <- 0.02 # [gC cm_H2O^-3]
E <- 0.0001 # [gC cm_H2O^-3]
theta_s <- 0.3 # [m^3 m^-3]
theta <- theta_s * 0.3 # [m_H2O^3]
cm3 <- 1000000

MM <- function(x) {V*x*E/(K+x+E) * 90000} # * (theta*cm3)}

curve(MM, from=0, to=1)

0.00672 * exp(-47000/8.3144*(1/290-1/293.15))

out.month <- aggregate(model.out, by=list(x=ceiling(model.out[,1]/30)), FUN=mean)


##### Sorption kinetics
# Mayes 2012
# Ultisols
Qmax <- 1800 # mg kg-1
k    <- 0.091 # L mg-1
DOC  <- seq(0 ,100, 1)
DOCs <-  k * Qmax * DOC / (1 + k * DOC)
plot(DOCs ~ DOC)

K <- 1/k
DOCs2 <- Qmax * DOC / (K + DOC)

DOCt <- DOC / 1000 * 1000  # from mg L-1 to g m-3 (divide for g, multiply for m-3, multiple by water content)
Kt   <- (1/k) / 1000 * 1000
DOCst <-  Qmax * DOCt / (Kt + DOCt)
plot(DOCst ~ DOCt)

2077 * 325 / (11 + 325)

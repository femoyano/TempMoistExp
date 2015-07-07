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

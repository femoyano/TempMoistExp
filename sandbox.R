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

### Diffussion
moist<- seq(0,0.5,0.01)
clay <- 0.3
sand <- 0.3
ps <- 0.5
psi_Rth  <- 15000    # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
psi_fc   <- 33       # [kPa] Water potential at field capacity
D_0     <- 8.1e-10 * 60 * 60 * 24   # [m s^-1] Diffusivity in water for amino acids after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
dist     <- 10^-4     # [m] characteristic distance between substrate and microbes (Manzoni manus)
b       <- 2.91 + 15.9 * clay # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
psi_sat <- exp(6.5 - 1.3 * sand) / 1000  # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
Rth     <- ps * (psi_sat / psi_Rth)^(1 / b) # Volumetric moisture threshold for respiration 
D <- D_0 * (ps - Rth)^1.5 * ((moist - Rth)/(ps - Rth))^2.5 # Diffusivity 
h <- D * 6 / dist^2
plot(h~moist)

moist<- seq(0,0.5,0.01)
ps <- 0.5
D_0 <- 8.1e-10 * 60 * 60 * 24   # [m s^-1] Diffusivity in water for amino acids after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
dist <- 10^-4     # [m] characteristic distance between substrate and microbes (Manzoni manus)
Rth <- 0.1 # Volumetric moisture threshold for respiration
D <- D_0 * (ps - Rth)^1.5 * ((moist - Rth)/(ps - Rth))^2.5 # Diffusivity
h <- D * 6 / dist^2
plot(h~moist)

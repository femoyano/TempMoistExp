# Diffusion of SC to microbes
F_scw.scm <- function (SCw, SCm, D_S0, theta, delta, phi, theta_Rth) {
  D_S <- D_S0 * (phi-theta_Rth)^1.5 * ((theta-theta_Rth)/(phi-theta_Rth))^2.5
  D_S * (SCw / theta - SCm / theta) / delta
}

D_S0 * (phi-theta_Rth)^1.5 * ((theta-theta_Rth)/(phi-theta_Rth))^2.5

theta_Rth <- phi * (psi_sat / psi_Rth)^(1 / b)

b  <- 2.91 + 15.9 * 1                  
psi_sat   <- exp(6.5 - 1.3 * 0) / 1000        
theta_Rth <- phi * (psi_sat / psi_Rth)^(1 / b) 
theta_fc  <- phi * (psi_sat / psi_fc)^(1 / b)

phi * (psi_sat / psi_Rth)^(1 / b) 
phi * (psi_sat / psi_fc)^(1 / b)

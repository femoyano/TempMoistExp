#### main.R

### Documentation ==============================================================
# Main program file.
# Soil model: SCM

# Simulation of soil C dynamics. This is the main R script that runs the model.

# Processes simulated:
# - enzymatic decomposition
# - DOC and enzyme diffusion
# - microbial uptake and respiration
# - enzymatic production and breakdown
# - DOC and enzyme sorption to mineral surfaces
# - DOC flux to and from immobile zones

### Setup ======================================================================
# Libraries
require(deSolve)
# Sourced files

source("flux_functions.r")

# Tmime parameters

day <- 86400 # seconds in a day
hour <- 3600 # seconds in an hour
tstep <- hour/2

# set.time.resol <- 48 # Use to change time dependent variables and parameters to the desired time resolution (default = daily?)
  
### Inputs =====================================================================

# Load spatial input data (texture data matrix)
clay   <-  # [g g^-1] clay fraction values (array: point x layer)
sand   <-  # [g g^-1] sand fraction values (array: point x layer)
silt   <-  # [g g^-1] silt fraction values (array: point x layer)
depth  <-  # [m] soil depth (array: point x layer)
  
# Load spatio_temporal input data
input_litter_m  <-  # [gC m^2] metabolic litter (array: point x layer x time)
input_litter_s  <-  # [gC m^2] structural litter (array: point x layer x time)
input_temp      <-  # [k] soil temperatrue (array: point x layer x time)
input_moist     <-  # [m^3 m^-3] soil volumetric water content (array: point x layer x time)
input_dmoist    <-  # [m^3 m^-3] change in soil volumetric water (array: point x layer x time)
input_times     <-  # time points for input values
  
# Load initial state variable values
LC_0  <- 0 # GetInitValues("InitVal_LC_0.csv")   # [g] labile carbon (array: point x layer)
RC_0  <- 0 # GetInitValues("InitVal_RC_0.csv")   # [g] recalcitrant carbon (array: point x layer)
SCw_0 <- 0 # GetInitValues("InitVal_SC_w_0.csv") # [g] soluble carbon in bulk water (array: point x layer)
SCs_0 <- 0 # GetInitValues("InitVal_SC_s_0.csv") # [g] soluble carbon sorbed to minerals (array: point x layer)
SCd_0 <- 0 # GetInitValues("InitVal_SC_m_0.csv") # [g] soluble carbon in disconnected zones (array: point x layer)
SCm_0 <- 0 # GetInitValues("InitVal_SC_m_0.csv") # [g] soluble carbon local to microbes (array: point x layer)
ECw_0 <- 0 # GetInitValues("InitVal_SC_m_0.csv") # [g] enzymes in bulk water (array: point x layer)
ECs_0 <- 0 # GetInitValues("InitVal_SC_s_0.csv") # [g] enzymes sorbed to minerals (array: point x layer)
ECm_0 <- 0 # GetInitValues("InitVal_SC_m_0.csv") # [g] enzymes local to microbes (array: point x layer)
MC_0  <- 0 # GetInitValues("InitVal_SC_m_0.csv") # [g] microbial carbon (array: point x layer)

### Model parmeters ====

# Constants
phi      <- 0.5      # [m^3 m^-3] Assumed pore space - Alternatively: obtain from land model.
psi_Rth  <- 15000    # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
psi_fc   <- 33      # [kPa] Water potential at field capacity
Em       <- 0.004 / hour * tstep   # [h-1] Approx. for 0.1 d-1 (Schimel & Weintraub 2003, Allison 2006, Manzoni et al. ...)
K_LC     <- 
K_RC     <- 
K_SC     <-
kf_LC    <- 
kf_RC    <- 
kf_SC    <-
D_S0     <- 8.1e-10 * tstep # [m s^-1] For amino acids, after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
D_E0     <- 8.1e-11 * tstep # [m s^-1] Vetter et al., 1998
ECm_f    <- ? # constant fraction of MC representing amount of ECm
delta    <- ? # characteristic distance between substrate and microbes
mcrc_f   <- 1 # fraction of dead microbes going to the recalcitrant carbon pool
t_MC     <- 0.05 # scalar for transporter fraction of MC (Tang and Riley 2014)

# Spatially variable parameters


### Simulation =================================================================

# Loop through horizontal spatial dimension ====

# Spatially variable parameters
b          <- 2.91 + 15.9 * clay[i, j] # [] Cosby  et al. 1984 calculation of b parameter (Campbell 1974) - Alternatively: obtain from land model.
psi_sat    <- exp(6.5-1.3 * sand[i, j]) * 1000 # [kPa] Cosby et al. 1984 after converting their data from cm H2O to Pa - Alternatively: obtain from land model.
theta_Rth  <- phi * (psi_sat / psi_Rth)^(1 / b) # [kPa] Campbell 1984
theta_fc   <- phi * (psi_sat / psi_fc)^(1 / b) # [kPa] Campbell 1984 - Alternatively: obtain from land model.
params     <- c(b = b, psi_sat = psi_sat, theta_Rth = theta_Rth, theta_fc = theta_fc)

state <- (LC = LC_0, RC = RC_0, SCw = SCw_0, SCs = SCs_0, SCd = SCd_0, SCm = SCm_0, ECw = ECw_0, ECs = ECs_0, ECm = ECm_0, MC = MC_0)

model1 <- function(times, state, parameters) {
  with(as.list(c(state,parameters)),{
    
    litter_m <- approx(input_times, input_litter_m, xout=times)$y
    litter_s <- approx(input_times, input_litter_s, xout=times)$y
    temp   <- approx(input_times, input_temp_s, xout=times)$y
    theta  <- approx(input_times, input_moist_s, xout=times)$y    
    
    dLC  <- FluxLC()
    dRC  <- FluxRC()
    dSCw <- FluxSCw()
    dSCs <- FluxSCs()
    dSCd <- FluxSCm()
    dSCm <- FluxSCm()
    dECm <- FluxECm()
    dECw <- FluxECw()
    dECs <- FluxECs()
    dMC  <- FluxMC()
    
    list(c(dLC, dRC, dSCw, dSCs, dSCd, dSCm, dECm, dECw, dECs, dMC))
    
  }) # end of with...
} # end of model1

times <- seq(0, 100, 1)

out <- as.data.frame(ode(state,times,model1,params))

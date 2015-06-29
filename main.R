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
source("temperature_functions.r")

# Tmime parameters

day <- 86400 # seconds in a day
hour <- 3600 # seconds in an hour
tstep <- hour

# set.time.resol <- 48 # Use to change time dependent variables and parameters to the desired time resolution (default = daily?)
  
### Inputs =====================================================================

# Load spatial input data (texture data matrix)
# clay   <-  # [g g^-1] clay fraction values (array: point x layer)
# sand   <-  # [g g^-1] sand fraction values (array: point x layer)
# silt   <-  # [g g^-1] silt fraction values (array: point x layer)
# depth  <-  # [m] soil depth (array: point x layer)
soil.prop <- read.csv("soil_prop.csv")
  
# Load spatio_temporal input data
# input_litter_m  <-  # [gC m^2] metabolic litter (array: point x layer x time)
# input_litter_s  <-  # [gC m^2] structural litter (array: point x layer x time)
# input_temp      <-  # [k] soil temperatrue (array: point x layer x time)
# input_moist     <-  # [m^3 m^-3] soil volumetric water content (array: point x layer x time)
# input_dmoist    <-  # [m^3 m^-3] change in soil volumetric water (array: point x layer x time)
# input_times     <-  # time points for input values
forcing.data <- read.csv("forcing_data.csv")
litter.data <- read.csv("litter_input.csv")
  
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

### Known Constants
R   <- 8.3144  # [J K-1 mol-1] gas constant

### Model parmeters ====
phi      <- 0.5     # [m3 m^-3] Assumed pore space - Alternatively: obtain from land model.
psi_Rth  <- 15000   # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
psi_fc   <- 33      # [kPa] Water potential at field capacity
Em       <- 0.1 / day * tstep  # [d-1] Enzyme mortality rate (Schimel & Weintraub 2003, Allison 2006, Manzoni manus ...)
K_LD     <- 200     # [gC] Affinity parameter for LC decomp. (k_ES in Tang and Riley 2014)
K_RD     <- 200     # [gC] Affinity parameter for RC decomp. (k_ES in Tang and Riley 2014)
K_SU     <- 1       # [gC] Affinity parameter for microbial SC uptake (k_BC in Tang and Riley 2014)
K_SS     <- 25      # [gC] Affinity parameter for SC sorption (k_MC in Tang and Riley 2014)
K_ES     <- 50      # [gC] Affinity parameter for EC sorption (k_ME in Tang and Riley 2014)
V_LD     <- 0.0058 / day * tstep   # [d^-1] Based on the two pool litter model of Adair et al. 2008. Similar magnitude as in Zhang et al. 2008, Cotrufo et al. in Soil Carbon Dynamics 2009
V_RD     <- 0.000768 / day * tstep # [d^-1] Based on the two pool litter model of Adair et al. 2008. Similar magnitude as in Zhang et al. 2008, Cotrufo et al. in Soil Carbon Dynamics 2009
V_SU     <- 10.93 / day * tstep    # [d^-1] Maximum speed of microbial uptake of SC
D_S0     <- 8.1e-10 * tstep        # [m s^-1] Diffusivity in water for amino acids, after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
D_E0     <- 8.1e-11 * tstep        # [m s^-1] Diffusivity in water for enzymes. Vetter et al., 1998
P_E      <- 0.01    # [d^-1] Fraction of MC converted to EC. Intermediate value between Schimel & Weintraub 2003 and Allison et al. 2010 (!uncertain!)
delta    <- 10^-4   # [m] characteristic distance between substrate and microbes (Manzoni manus)
mcsc_f   <- 0.5     # [g g^-1] fraction of dead microbes going to SC (rest goes to LC)
t_MC     <- 0.05    # [g g^-1] scalar for transporter fraction of MC (Tang and Riley 2014)
T0       <- 290     # [K] reference temperature
E_V.SU   <- 45      # [degC]  Gibbs energy for V_SU (Tang and Riley 2014)
E_V.LD   <- 37      # [degC]  Gibbs energy for V_LD (Wang et al. 2013)
E_V.RD   <- 53      # [degC]  Gibbs energy for V_RD (Wang et al. 2013)
E_K.SU   <- 15      # [degC]  Gibbs energy for K_SU (Tang and Riley 2014)
E_K.LD   <- 15      # [degC]  Gibbs energy for K_LD (Tang and Riley 2014)
E_K.RD   <- 15      # [degC]  Gibbs energy for K_RD (Tang and Riley 2014)
E_K.EM   <- 10      # [degC]  Gibbs energy for K_EM (Tang and Riley 2014)
E_K.SM   <- 10      # [degC]  Gibbs energy for K_SM (Tang and Riley 2014)
M        <- 0.0017  # [gC gSoil^-1] Maximum mineral surface capacity for sorption (Mayes et al. 2012)

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
    temp     <- approx(input_times, input_temp_s, xout=times)$y
    theta    <- approx(input_times, input_moist_s, xout=times)$y
    K_LD     <- Temp.Resp.Eq(K_LD, temp, T0, E_K.LD, R)
    K_RD     <- Temp.Resp.Eq(K_RD, temp, T0, E_K.RD, R)
    K_SM     <- Temp.Resp.Eq(K_SM, temp, T0, E_K.SM, R)
    K_EM     <- Temp.Resp.Eq(K_EM, temp, T0, E_K.EM, R)
    K_SU     <- Temp.Resp.Eq(K_SU, temp, T0, E_K.SU, R)
    V_LD     <- Temp.Resp.NonEq(V_LD, temp, T0, E_V.LD, R)
    V_RD     <- Temp.Resp.NonEq(V_RD, temp, T0, E_V.RD, R)
    V_DU     <- Temp.Resp.NonEq(V_SU, temp, T0, E_V.SU, R)
    
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

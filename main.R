#### main.R
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Documentation ==============================================================
# Main program file.
# Soil model: SCM-daily
# Time step: daily
# Note: C inputs have to be in the same time units as the model step

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

# Time parameters

day <- 86400 # seconds in a day
hour <- 3600 # seconds in an hour
tstep <- day

# set.time.resol <- 48 # Use to change time dependent variables and parameters to the desired time resolution (default = daily?)
  
### Inputs =====================================================================

# Load spatial input data (texture data matrix)
clay   <-  30 # [g g^-1] clay fraction values (array: point x layer)
sand   <-  30 # [g g^-1] sand fraction values (array: point x layer)
silt   <-  40 # [g g^-1] silt fraction values (array: point x layer)
depth  <-  0.30 # [m] soil depth (array: point x layer)
# soil.prop <- read.csv("soil_prop.csv")
  
# Load spatio_temporal input data
# input_litter_m  <-  # [gC m^2] metabolic litter (array: point x layer x time)
# input_litter_s  <-  # [gC m^2] structural litter (array: point x layer x time)
# input_temp      <-  # [K] soil temperatrue (array: point x layer x time)
# input_moist     <-  # [m^3 m^-3] soil volumetric water content (array: point x layer x time)
# input_dmoist    <-  # [m^3 m^-3] change in soil volumetric water (array: point x layer x time)
# input_times     <-  # time points for input values

forcing.data  <- read.csv("forcing_data_daily.csv")
input_temp    <- forcing.data$temp # [K] soil temperature
input_moist   <- forcing.data$moist # [m^3 m^-3] soil volumetric water content
input_dmoist  <- c(0, for(i in 2:length(input_moist)) input_moist)
times_forcing <- forcing.data$day

litter.data    <- read.csv("litter_input_daily.csv")
input_litter_m <- litter.data$litter_m # [gC m^2] metabolic litter
input_litter_s <- litter.data$litter_s # [gC m^2] structural litter
times_litter   <- litter.data$day

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

### Known Constants ====
R   <- 8.3144  # [J K-1 mol-1] gas constant

### Fixed Parameters ====
psi_Rth  <- 15000   # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
psi_fc   <- 33      # [kPa] Water potential at field capacity
Em       <- 0.1 / day * tstep  # [d-1] Enzyme mortality rate (Schimel & Weintraub 2003, Allison 2006, Manzoni manus ...)
K_LD_T0  <- 200     # [gC] Affinity parameter for LC decomp. (k_ES in Tang and Riley 2014)
K_RD_T0  <- 200     # [gC] Affinity parameter for RC decomp. (k_ES in Tang and Riley 2014)
K_SU_T0  <- 1       # [gC] Affinity parameter for microbial SC uptake (k_BC in Tang and Riley 2014)
K_SS_T0  <- 25      # [gC] Affinity parameter for SC sorption (k_MC in Tang and Riley 2014)
K_ES_T0  <- 50      # [gC] Affinity parameter for EC sorption (k_ME in Tang and Riley 2014)
V_LD_T0  <- 0.0058 / day * tstep   # [d^-1] Based on the two pool litter model of Adair et al. 2008. Similar magnitude as in Zhang et al. 2008, Cotrufo et al. in Soil Carbon Dynamics 2009
V_RD_T0  <- 0.000768 / day * tstep # [d^-1] Based on the two pool litter model of Adair et al. 2008. Similar magnitude as in Zhang et al. 2008, Cotrufo et al. in Soil Carbon Dynamics 2009
V_SU_T0  <- 10.93 / day * tstep    # [d^-1] Maximum speed of microbial uptake of SC
D_S0     <- 8.1e-10 * tstep        # [m s^-1] Diffusivity in water for amino acids, after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
D_E0     <- 8.1e-11 * tstep        # [m s^-1] Diffusivity in water for enzymes. Vetter et al., 1998
P_E      <- 0.01    # [d^-1] Fraction of MC converted to EC. Intermediate value between Schimel & Weintraub 2003 and Allison et al. 2010 (!uncertain!)
delta    <- 10^-4   # [m] characteristic distance between substrate and microbes (Manzoni manus)
mcsc_f   <- 0.5     # [g g^-1] fraction of dead microbes going to SC (rest goes to LC)
t_MC     <- 0.05    # [g g^-1] scalar for transporter fraction of MC (Tang and Riley 2014)
T0       <- 290     # [K] reference temperature
E_V.SU   <- 45000   # [J mol^-1]  Gibbs energy for V_SU (Tang and Riley 2014)
E_V.LD   <- 37000   # [J mol^-1]  Gibbs energy for V_LD (Wang et al. 2013)
E_V.RD   <- 53000   # [J mol^-1]  Gibbs energy for V_RD (Wang et al. 2013)
E_K.SU   <- 15000   # [J mol^-1]  Gibbs energy for K_SU (Tang and Riley 2014)
E_K.LD   <- 15000   # [J mol^-1]  Gibbs energy for K_LD (Tang and Riley 2014)
E_K.RD   <- 15000   # [J mol^-1]  Gibbs energy for K_RD (Tang and Riley 2014)
E_K.EM   <- 10000   # [J mol^-1]  Gibbs energy for K_EM (Tang and Riley 2014)
E_K.SM   <- 10000   # [J mol^-1]  Gibbs energy for K_SM (Tang and Riley 2014)
M_spec   <- 0.0017  # [gC gSoil^-1] Specific maximum mineral surface capacity for sorption (Mayes et al. 2012)

# Spatially variable parameters ====
phi        <- 0.5                        # [m3 m^-3] Assumed pore space - Alternatively: obtain from land model
dens_min   <- 1600000                    # [g m^-3] assumed mineral density
M          <- M_spec * depth * dens_min * (1 - phi) # [gC] Total C-equivalent mineral surface for sorption
b          <- 2.91 + 15.9 * clay         # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
psi_sat    <- exp(6.5-1.3 * sand) * 1000 # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
theta_Rth  <- phi * (psi_sat / psi_Rth)^(1 / b) # [kPa] Threshold water content for mic. respiration (water retention formula from Campbell 1984)
theta_fc   <- phi * (psi_sat / psi_fc)^(1 / b)  # [kPa] Field capacity water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.

# Lists of all parameters and state variables
param.list <- c(b = b, psi_sat = psi_sat, theta_Rth = theta_Rth, theta_fc = theta_fc)
state <- (LC = LC_0, RC = RC_0, SCw = SCw_0, SCs = SCs_0, SCd = SCd_0, SCm = SCm_0, ECw = ECw_0, ECs = ECs_0, ECm = ECm_0, MC = MC_0)

# Define model time step vector
times <- seq(1,times_forcing[length(times_forcing)])

# Model run
model1 <- function(times, state, parameters) {
  with(as.list(c(state,parameters)),{
        
    # Interpolation of input variables
    litter_m <- approx(times_litter, input_litter_m, xout=times, rule=2)$y
    litter_s <- approx(times_litter, input_litter_s, xout=times, rule=2)$y
    temp     <- approx(times_forcing, input_temp, xout=times, rule=2)$y
    theta    <- approx(times_forcing, input_moist, xout=times, rule=2)$y
    
    # Temperature effects on parameters
    K_LD <- Temp.Resp.Eq(K_LD_T0, temp, T0, E_K.LD, R)
    K_RD <- Temp.Resp.Eq(K_RD_T0, temp, T0, E_K.RD, R)
    K_SU <- Temp.Resp.Eq(K_SU_T0, temp, T0, E_K.SU, R)
    K_SS <- Temp.Resp.Eq(K_SS_T0, temp, T0, E_K.SS, R)
    K_ES <- Temp.Resp.Eq(K_ES_T0, temp, T0, E_K.ES, R)
    V_LD <- Temp.Resp.NonEq(V_LD_T0, temp, T0, E_V.LD, R)
    V_RD <- Temp.Resp.NonEq(V_RD_T0, temp, T0, E_V.RD, R)
    V_SU <- Temp.Resp.NonEq(V_SU_T0, temp, T0, E_V.SU, R)
    
    
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

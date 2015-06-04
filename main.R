#### main.R

#### Main program file for soil C Model-1

### Documentation ==============================================================
# Simulation of soil C dynamics. This is the main R script that runs the model.

### Setup ======================================================================
# Libraries

# Sourced files

source("GetInitValues.r")
source("FluxDryzone.r")

# Define dimensions

n.time        <-
n.grid.points <-
n.horizons    <-
time.step     <-
depths        <-

### Inputs =====================================================================

# Load spatial input data (texture data matrix)
clay   <-  # [g g^-1] clay fraction values (array: point x layer)
sand   <-  # [g g^-1] sand fraction values (array: point x layer)
silt   <-  # [g g^-1] silt fraction values (array: point x layer)
depth  <-  # [m] soil depth (array: point x layer)
  
# Load spatio_temporal input data
litter_m  <-  # [gC m^2] metabolic litter (array: point x layer x time)
litter_s  <-  # [gC m^2] structural litter (array: point x layer x time)
temp_s    <-  # [k] soil temperatrue (array: point x layer x time)
wc_s      <-  # [m^3 m^-3] soil volumetric water content (array: point x layer x time)

# Load initial state variable values
LC_0    <- GetInitValues("InitVal_LC_0.csv")   # [g] labile carbon (array: point x layer)
RC_0    <- GetInitValues("InitVal_RC_0.csv")   # [g] recalcitrant carbon (array: point x layer)
SC_w_0  <- GetInitValues("InitVal_SC_w_0.csv") # [g] soluble carbon in bulk water (array: point x layer)
SC_s_0  <- GetInitValues("InitVal_SC_s_0.csv") # [g] soluble water sorbed to minerals (array: point x layer)
SC_m_0  <- GetInitValues("InitVal_SC_m_0.csv") # [g] soluble water local to microbes (array: point x layer)
  
### Constant parameters
phi       <- 0.5    # [m^3 m^-3] assumed pore space - Else obtain from land model
psi_Rth   <- 15000  # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
psi_fc    <- 33     # [kPa] Water potential at field capacity

### Simulation =================================================================

## Define state variable array



## Loop through horizontal spatial dimension ====

## Loop through vertical spatial dimension ====

# Spatially variable parameters
sand_f     <- sand[i, j] # [g g^-1] sand fraction
clay_f     <- clay[i, j] # [g g^-1] clay fraction
b          <- 2.91 + 15.9 * clay_f # [] Cosby  et al. 1984 calculation of b parameter (Campbell 1974).
psi_sat    <- exp(6.5-1.3 * sand_f) * 1000 # [kPa] Cosby et al. 1984 after converting their data from cm H2O to Pa - Else obtain from land model.
theta_Rth  <- phi * (psi_sat / psi_Rth)^(1 / b) # [kPa] Campbell 1984
theta_fc   <- phi * (psi_sat / psi_fc)^(1 / b) # [kPa] Campbell 1984


## Loop through temporal dimension ====

# Spatio-temporally variable parameters


# Calculate flux to dry zones

F_dryzone


# model_parameters.r

# Documentation ====
# All fixed parameters and constants should be listed here.
# Variables calculated from input data (e.g. theta_fc, ..) are in main.
# Warning: time variables and tunit have to be defined before sourcing this file.

parameters <- c(
    
  ### Known Constants ====
  R   = 8.3144,  # [J K-1 mol-1] gas constant
  
  ### Time Dependent Parameters
  Em_0    = 0.005 / day * tunit     , # [d-1] Enzyme turnover rate (Li et al. 2014) (!uncertain!). Value for 290K.
  Mm_0    = 0.024 / day * tunit     , # [d-1] Microbe turnover rate (Li et al. 2014) (!uncertain!). Value for 290K.
  V_D_0  = 2.5 / day * tunit       , # [d^-1] Maximum speed ofRC decomposition of PC (Tang and Riley 2014) !uncertain!
  V_U_0  = 10.93 / day * tunit     , # [d^-1] Maximum speed of microbial uptake of SC (Tang and Riley 2014) !uncertain!
  D_S0     = 8.1e-10 / sec * tunit  , # [m s^-1] Diffusivity in water for amino acids, after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
  D_E0     = 8.1e-11 / sec * tunit  , # [m s^-1] Diffusivity in water for enzymes. Vetter et al., 1998
  
  ### Fixed Parameters ====
  psi_Rth  = 15000   , # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  psi_fc   = 33      , # [kPa] Water potential at field capacity
  K_D_0    = 0.05    , # [gC cmH2O^-3] Affinity parameter for LC decomp. (approx. Allison et al. 2010, Li at al. 2014)
  K_U_0    = 0.0001  , # [gC cmH2O^-3] Affinity parameter for microbial SC uptake (approx. Allison et al. 2010, Li at al. 2014)
  K_SM_0   = 0.05    , # [gC cmH2O^-3] Affinity parameter for SC sorption 
  K_EM_0   = 0.05    , # [gC cmH2O^-3] Affinity parameter for EC sorption 
  E_P      = 0.01    , # [d^-1] Fraction of MC converted to EC. Intermediate value between Schimel & Weintraub 2003 and Allison et al. 2010 (!uncertain!)
  dist     = 10^-4   , # [m] characteristic distance between substrate and microbes (Manzoni manus)
  mcsc_f   = 0.5     , # [g g^-1] fraction of dead microbes going to SC (rest goes to LC)
  t_MC     = 0.05    , # [g g^-1] scalar for transporter fraction of MC (Tang and Riley 2014)
  T0       = 290     , # [K] reference temperature
  E_V.SU   = 45000   , # [J mol^-1]  Gibbs energy for V_SU (Tang and Riley 2014)
  E_V.LD   = 37000   , # [J mol^-1]  Gibbs energy for V_LD (Wang et al. 2013)
  E_V.RD   = 53000   , # [J mol^-1]  Gibbs energy for V_RD (Wang et al. 2013)
  E_K.SU   = 15000   , # [J mol^-1]  Gibbs energy for K_SU (Tang and Riley 2014)
  E_K.LD   = 15000   , # [J mol^-1]  Gibbs energy for K_LD (Tang and Riley 2014)
  E_K.RD   = 15000   , # [J mol^-1]  Gibbs energy for K_RD (Tang and Riley 2014)
  E_K.EM   = 10000   , # [J mol^-1]  Gibbs energy for K_EM (Tang and Riley 2014)
  E_K.SM   = 10000   , # [J mol^-1]  Gibbs energy for K_SM (Tang and Riley 2014)
  CUE      = 0.7     , # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al. 2014)
  E_m      = 47000   , # [J mol^-1]  Gibbs energy for Mm and Em (Haggerty et al. 2014 supplementary info)
  M_spec   = 0.0017  , # [gC gSoil^-1] Specific maximum mineral surface capacity for sorption (Mayes et al. 2012)
  phi      = 0.5     , # [cm3 cm^-3] Assumed pore space - Alternatively: obtain from land model
  dens_min = 1.6     , # [g cm^-3] Assumed mineral density
  cm3      = 1000000   # [] cubic cm in 1 cubic meter
)


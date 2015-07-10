# model_parameters.r

# Documentation ====
# All fixed parameters and constants should be listed here.
# Variables calculated from input data (e.g. theta_fc, ..) are in main.
# Warning: time variables and tunit have to be defined before sourcing this file.

parameters <- c(
    
  ### Known Constants ====
  R   = 0.008314,  # [kJ K-1 mol-1] gas constant
  
  ### Time Dependent Parameters
  Em_0   = 0.001 / hour * tunit   , # [h-1] Enzyme turnover rate (Allison at al. 2010). Value for 290K.
  Mm_0   = 0.00028 / hour * tunit , # [h-1] Microbe turnover rate (Allison at al. 2010). Value for 290K.
  V_D_0  = 1 / hour * tunit       , # [h-1] Maximum speed of PC decomposition (Allison at al. 2010)
  V_U_0  = 0.01 / hour * tunit     , # [h-1] Maximum speed of microbial uptake of SC (Allison at al. 2010) Use without t_M scaling!!!
  
  ### Fixed Parameters ====
  K_D_0    = 0.250   , # [mgC gSoil-1] Affinity parameter for PC decomp. (approx. Allison et al. 2010, Li at al. 2014)
  K_U_0    = 0.26    , # [mgC gSoil-1] Affinity parameter for microbial SC uptake (approx. Allison et al. 2010, Li at al. 2014)
  E_P      = 0.0000056  , # [h^-1] Fraction of MC converted to EC. Intermediate value between Schimel & Weintraub 2003 and Allison et al. 2010 (!uncertain!)
  mcsc_f   = 0.5     , # [g g^-1] fraction of dead microbes going to SC (rest goes to PC)
  T0       = 293.15     , # [K] reference temperature
  E_V.U    = 47   , # [kJ mol^-1]  Gibbs energy for V_U (Tang and Riley 2014)
  E_V.D    = 47   , # [kJ mol^-1]  Gibbs energy for V_D (average of lignin and cellulose in Wang et al. 2013)
  E_K.U    = 30   , # [kJ mol^-1]  Gibbs energy for K_U (Tang and Riley 2014)
  E_K.D    = 30   , # [kJ mol^-1]  Gibbs energy for K_D (Tang and Riley 2014)
  CUE      = 0.31     , # Carbon use efficieny (= microbial growth efficiency) (Allison et al. 2010)
  E_m      = 47      , # [kJ mol^-1]  Gibbs energy for Mm and Em (Haggerty et al. 2014 supplementary info)
  phi      = 0.5     , # [cm3 cm^-3] Assumed pore space - Alternatively: obtain from land model
  dens_min = 1.6     , # [g cm^-3] Assumed mineral density
  cm3      = 1000000   # [] cubic cm in 1 cubic meter
)


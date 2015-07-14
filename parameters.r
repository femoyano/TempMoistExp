# model_parameters.r

# Documentation ====
# All fixed parameters and constants should be listed here.
# Variables calculated from input data (e.g. theta_fc, ..) are in main.
# Warning: time variables and tunit have to be defined before sourcing this file.

parameters <- c(
    
  ### Known Constants ====
  R   = 0.008314                  ,  # [kJ K-1 mol-1] gas constant
  
  ### Time Dependent Parameters
  Em_0   = 0.001 / hour * tunit    , # [h-1] Enzyme turnover rate (Allison at al. 2010).
  Mm_0   = 0.0002 / hour * tunit   , # [h-1] Microbe turnover rate (Allison at al. 2010).
  E_P    = 0.000005 / hour * tunit , # [h-1] Fraction of MC converted to EC. Intermediate value between Schimel & Weintraub 2003 and Allison et al. 2010 (!uncertain!)
  V_D_0  = 1 / hour * tunit        , # [h-1] Maximum speed of PC decomposition (Allison at al. 2010)
  V_U_0  = 0.01 / hour * tunit     , # [h-1] Maximum speed of microbial uptake of SC (Allison at al. 2010) Use without t_M scaling!!!
  
  ### Fixed Parameters ====
  K_D_0    = 500      , # [mgC gSoil-1] Affinity parameter for PC decomp. (approx. Allison et al. 2010, Li at al. 2014)
  K_D_s    = 5        , # T linear response of K_D
  K_U_0    = 0.1      , # [mgC gSoil-1] Affinity parameter for microbial SC uptake (approx. Allison et al. 2010, Li at al. 2014)
  K_U_s    = 0.01     , # T linear response of K_U
  mcsc_f   = 0.5      , # [g g^-1] fraction of dead microbes going to SC (rest goes to PC)
  T0       = 293.15   , # [K] reference temperature
  E_V.U    = 47       , # [kJ mol^-1]  Gibbs energy for V_U (Tang and Riley 2014)
  E_V.D    = 47       , # [kJ mol^-1]  Gibbs energy for V_D (average of lignin and cellulose in Wang et al. 2013)
  E_K.U    = 30       , # [kJ mol^-1]  Gibbs energy for K_U (Tang and Riley 2014)
  E_K.D    = 30       , # [kJ mol^-1]  Gibbs energy for K_D (Tang and Riley 2014)
  CUE      = 0.31     , # Carbon use efficieny (= microbial growth efficiency) (Allison et al. 2010)
  E_m      = 47       , # [kJ mol^-1]  Gibbs energy for Mm and Em (Haggerty et al. 2014 supplementary info)
  CUE_0    = 0.63     , # CUE at 0 C
  CUEs     = -0.016     # CUE slope with temperature
)


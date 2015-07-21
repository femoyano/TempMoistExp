# model_parameters.r

# Documentation ====
# All fixed parameters and constants should be listed here.
# Variables calculated from input data (e.g. theta_fc, ..) are in main.
# Warning: time variables and tunit have to be defined before sourcing this file.

parameters <- c(
    
  ### Known Constants ====
  R   = 0.008314                  ,  # [kJ K-1 mol-1] gas constant
  
  ### Time Dependent Parameters
  Em_ref  = 0.001 / hour * tunit    , # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  Mm_ref  = 0.00028 / hour * tunit   , # [h-1] Microbe turnover rate (Li at al. 2014, AWB model).
  E_p     = 0.0000056 / hour * tunit , # [h-1] Fraction of MC converted to EC. (Li at al. 2014, AWB model)
  V_D_ref = 1 / hour * tunit        , # [h-1] Maximum speed of PC decomposition (Li at al. 2014, AWB model)
  V_U_ref = 0.01 / hour * tunit     , # [h-1] Maximum speed of microbial uptake of SC (Li at al. 2014, AWB model) Use without t_M scaling!!!
  
  ### Fixed Parameters ====
  K_D_ref  = 250      , # [mgC gSoil-1] Affinity parameter for PC decomp. (Li at al. 2014, AWB model)
  K_U_ref  = 0.26     , # [mgC gSoil-1] Affinity parameter for microbial SC uptake (approx. Allison et al. 2010, Li at al. 2014)
  mcpc_f   = 0.5      , # [g g^-1] fraction of dead microbes going to SC (rest goes to PC)
  T_ref    = 293.15   , # [K] reference temperature
  E_V.U    = 47       , # [kJ mol^-1] Gibbs energy for V_U (Tang and Riley 2014)
  E_V.D    = 47       , # [kJ mol^-1] Gibbs energy for V_D (average of lignin and cellulose in Wang et al. 2013)
  E_K.U    = 30       , # [kJ mol^-1] Gibbs energy for K_U (Tang and Riley 2014)
  E_K.D    = 30       , # [kJ mol^-1] Gibbs energy for K_D (Tang and Riley 2014)
  E_Mm     = 47       , # [kJ mol^-1] Gibbs energy for Mm (Hagerty et al. 2014)
  E_Em     = 47       , # [kJ mol^-1] Gibbs energy for Em (Hagerty et al. 2014)
  CUE_ref  = 0.31     , # Carbon use efficieny (= microbial growth efficiency) (Allison et al. 2010)
  E_m      = 47       , # [kJ mol^-1]  Gibbs energy for Mm and Em (Haggerty et al. 2014 supplementary info)
  CUE_s    = -0.016     # CUE slope with temperature
)


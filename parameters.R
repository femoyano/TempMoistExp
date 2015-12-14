# model_parameters.r

# Documentation ====
# All fixed parameters and constants should be listed here.
# Variables calculated from input data (e.g. theta_fc, ..) are in main.
# Warning: time variables and tstep have to be defined before sourcing this file.

pars <- c(
    
  ### Known Constants ====
  R   = 0.008314                  ,  # [kJ K-1 mol-1] gas constant
  
  ### Time Dependent Parameters
  Mm_ref   = 0.00028 / hour * tstep , # [h-1] Microbe turnover rate (Li at al. 2014, AWB model).
  Em_ref   = 0.001   / hour * tstep , # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  Ep       = 5.6e-06 / hour * tstep , # [gC g-1 MC h-1] Fraction of SC taken up that is converted to EC. (assumed).
  V_D_ref  = 1       / hour * tstep , # [h-1] Maximum speed of PC decomposition (Li at al. 2014, AWB model)
  D_S0     = 8.1e-10 / sec  * tstep , # [m^2 s^-1] Diffusivity in water for amino acids, after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
  D_E0     = 8.1e-11 / sec  * tstep , # [m^2 s^-1] Diffusivity in water for enzymes. Vetter et al., 1998
  # Adsorptino/desorption rates (ka/kd ratio follows Mayes et al. 2012 (alfisols) -> Tang and Riley 2014, but values must be researched)
  ka.s.ref = 0.01    / hour * tstep , # [h-1] Adsorption rate constant of soluble C into free mineral adsorption sites
  ka.e.ref = 0.01    / hour * tstep , # [h-1] Adsorption rate constant of enzymes into free mineral adsorption sites
  kd.s.ref = 0.25    / hour * tstep , # [h-1] Desorption rate constant of soluble C into free mineral adsorption sites
  kd.e.ref = 0.50    / hour * tstep , # [h-1] Desorption rate constant of enzymes into free mineral adsorption sites
  
  ### Fixed Parameters ====
  # K values in gC m-3 calculated assuming a ps 0.5 and pd of 2.7
  K_D_ref  = 300000   , # [gC m-3] Affinity parameter for PC decomp. (Adjusted. As ref: Li at al. 2014, AWB model => 250 mg gSoil-1)
#   K_SM_ref = 25       , # [gC m-3] Affinity parameter for SC sorption (Tang and Riley 2014, Mayes et al. 2012) # using ka.s and kd.s instead.
#   K_EM_ref = 11       , # [gC m-3] Affinity parameter for EC sorption (Tang and Riley 2014, Mayes et al. 2012) # using ka.e and kd.e instead.
  mcpc_f   = 0.5      , # [g g^-1] fraction of dead microbes going to SC (rest goes to PC)
  T_ref    = 293.15   , # [K] reference temperature
  E_V.U    = 47       , # [kJ mol^-1] Gibbs energy for V_U (Tang and Riley 2014)
  E_V.D    = 47       , # [kJ mol^-1] Gibbs energy for V_D (average of lignin and cellulose in Wang et al. 2013)
  E_K.U    = 30       , # [kJ mol^-1] Gibbs energy for K_U (Tang and Riley 2014)
  E_K.D    = 30       , # [kJ mol^-1] Gibbs energy for K_D (Tang and Riley 2014)
  E_ka     = 10       , # [kJ mol^-1] Gibbs energy for SC adsorption/desorption fluxes (Tang and Riley 2014)
  E_kd     = 10       , # [kJ mol^-1] Gibbs energy for EC adsorption/desorption fluxes (Tang and Riley 2014)
  E_Mm     = 30       , # [kJ mol^-1] Gibbs energy for Mm (Hagerty et al. 2014)
  E_Em     = 30       , # [kJ mol^-1] Gibbs energy for Em (Hagerty et al. 2014)
  CUE_ref  = 0.7     , # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  E_m      = 47       , # [kJ mol^-1]  Gibbs energy for Mm and Em (Haggerty et al. 2014 supplementary info)
  CUE_s    = -0.016   , # CUE slope with temperature
  pd       = 2.7      , # [g cm^-3] Soil particle density
  Ef       = 0.01     , # [g g-1] Fraction of SC taken up that is converted to EC. (fitted).
  psi_Rth  = 15000   , # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  psi_fc   = 33      , # [kPa] Water potential at field capacity
  dist     = 10^-7   # [m] characteristic distance between substrate and microbes (Manzoni manus)
)


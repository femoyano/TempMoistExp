#### model_parameters.r

#### Documentation ============================================================
# All fixed parameters and constants should be listed here.
# Variables calculated from input data (e.g. theta_fc, ..) are in main.
# Warning: time variables and tstep have to be defined before sourcing this file.
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ==========================================================================

pars <- c(
  
  ### Fixed Constants ====
  R = 0.008314  ,  # [kJ K-1 mol-1] gas constant
  T_ref = 293.15   , # [K] reference temperature
  C_ref = 10000  ,  # [gC m-3] reference amount of C_P (used for effect on diffusion)
  
  ### Time Dependent Parameters
  r_md_ref = 0.00028 / hour * tstep , # [h-1] Microbe turnover rate (Li at al. 2014, AWB model).
  r_ed_ref = 0.001   / hour * tstep , # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  f_me     = 5.6e-06 / hour * tstep , # [gC g-1 C_M h-1] Fraction of C_M converted to C_E (assumed).
  V_D_ref  = 1       / hour * tstep , # [h-1] Maximum speed of C_P decomposition (Li at al. 2014, AWB model)
#   D_d0     = 8.1e-10 / sec  * tstep , # [m2 s-1] Diffusivity in water for amino acids, after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
#   D_e0     = 8.1e-11 / sec  * tstep , # [m2 s-1] Diffusivity in water for enzymes. Vetter et al., 1998
  D_0      =  1e-5 / sec  * tstep , # [m s-1] reference diffusion conductance for dissolved C (and /10 for enzymes), representing diffusivity/distance.

  # Adsorptino/desorption rates (ka/kd ratio follows Mayes et al. 2012 (alfisols) -> Tang and Riley 2014, but values must be researched)
  k_ads_ref = 1.08e-6  / sec * tstep , # [m3 gC-1 s-1] Adsorption rate constant of C_D. (Ahrens 2015, units converted for gC)
  k_des_ref = 1.19e-10 / sec * tstep , # [s-1] Desorption rate constant of C_A. (Ahrens 2015)
  
  ### Fixed Parameters ====
  # K values in gC m-3 calculated assuming a ps 0.5 and pd of 2.7
  # Note that the K_D value below is very high (over 20% C) so decompostion will be linear in most soils.
  K_D_ref  = 300000   , # [gC m-3] Affinity parameter for C_P decomp. (Adjusted. As ref: Li at al. 2014, AWB model => 250 mg gSoil-1)
  f_mp     = 0.5      , # [g g^-1] fraction of dead microbes going to C_P (rest goes to C_D)
  E_VD     = 47       , # [kJ mol^-1] Gibbs energy for V_D (average of lignin and cellulose in Wang et al. 2013)
  E_KD     = 30       , # [kJ mol^-1] Gibbs energy for K_D (Tang and Riley 2014)
  E_ka     = 10       , # [kJ mol^-1] Gibbs energy for C_D adsorption/desorption fluxes (Tang and Riley 2014)
  E_kd     = 10       , # [kJ mol^-1] Gibbs energy for C_E adsorption/desorption fluxes (Tang and Riley 2014)
  E_r_md   = 47       , # [kJ mol^-1] Gibbs energy for r_md (Hagerty et al. 2014 supplementary info)
  E_r_ed   = 47       , # [kJ mol^-1] Gibbs energy for r_ed (assumed equal to E_r_md)
  f_gr_ref = 0.7      , # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  f_gr_s   = -0.016   , # f_gr slope with temperature
  pd       = 2.7      , # [g cm^-3] Soil particle density
  f_de     = 0.01     , # [g g-1] Fraction of C_D taken up that is converted to C_E (fitted).
  psi_Rth  = 15000   , # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  psi_fc   = 33      , # [kPa] Water potential at field capacity
  C_max    = 500000   # some max value of C_P that should not be reached (used for linear effect on diffusion)
)


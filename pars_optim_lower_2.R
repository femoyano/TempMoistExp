#### Documentation ============================================================
# Initial estimate values for parameters to optimize.
# Time variables and tstep have to be defined before sourcing this file.
#### ==========================================================================

pars_optim_lower <- c(
  TOC_bf    = 0.005  , # gC gSoil-1
  TOC_mz    = 0.011  , # gC gSoil-1
  f_CA      = 0.01    , # both soils (bare fallow and maize(Closeaux)) has the same fraction of clay+silt to total C
#   f_CD      = 0.0001 , #
#   f_CEm     = 0.0001 , #
#   f_CEw     = 0.0001 , #
  r_ed_ref  = 0.0001 / hour * tstep , # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  V_D_ref   = 0.01   / hour * tstep , # [h-1] Maximum speed of C_P decomposition (Li at al. 2014, AWB model)
  K_D_ref   = 10000  , # [gC m-3] Affinity parameter for C_P decomp. (Adjusted. As ref: Li at al. 2014, AWB model => 250 mg gSoil-1)
  E_V       = 30     , # [kJ mol^-1] Gibbs energy for decomposition and turnover times
  E_K       = 20     , # [kJ mol^-1] Gibbs energy for K_D
  f_gr_ref  = 0.5    , # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  f_de      = 0.001  , # [g g-1] Fraction of C_D taken up that is converted to C_E (fitted).
  psi_Rth   = 13000  , # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  D_0      =  1e-7 / sec  * tstep # [m s-1] reference diffusion conductance for dissolved C (and /10 for enzymes), representing diffusivity/distance.
  
#   # Only used if adsorption/desorption is on
#   k_ads_ref = 1e-8   / sec * tstep , # [m3 gC-1 s-1] Adsorption rate constant of C_D. (Ahrens 2015, units converted for gC)
#   k_des_ref = 1.2e-12 / sec * tstep , # [s-1] Desorption rate constant of C_A. (Ahrens 2015)
#   E_k       = 5     , # [kJ mol^-1] Gibbs energy for adsorption/desorption fluxes
#   
#   # Only used if microbes are on
#   f_CM      = 0.001  , #
#   r_md_ref  = 0.00001 / hour * tstep , # [h-1] Microbe turnover rate (Li at al. 2014, AWB model).
#   f_me      = 1e-08   / hour * tstep , # [gC g-1 C_M h-1] Fraction of C_M converted to C_E (assumed).
#   f_mp      = 0.1                      # [g g^-1] fraction of dead microbes going to C_P (rest goes to C_D)
)

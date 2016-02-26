#### Documentation ============================================================
# Initial estimate values for parameters to optimize.
# Time variables and tstep have to be defined before sourcing this file.
#### ==========================================================================

pars_optim <- c(
  TOC_bf    = 0.006  , # gC gSoil-1
  TOC_mz    = 0.012  , # gC gSoil-1
  f_CA_bf   = 0.2    , # fraction of C_A in TOC for bare fallow
  f_CA_mz   = 0.2    , # fraction of C_A in TOC for maize soil 
  f_CD      = 0.001  , #
  f_CEm     = 0.001  , #
  f_CEw     = 0.001  , #
  r_ed_ref  = 0.001  / hour * tstep , # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  V_D_ref   = 1      / hour * tstep , # [h-1] Maximum speed of C_P decomposition (Li at al. 2014, AWB model)
  K_D_ref   = 200000 , # [gC m-3] Affinity parameter for C_P decomp. Gueesed starting value.
  E_V       = 47     , # [kJ mol^-1] Gibbs energy for decomposition and turnover times
  E_K       = 30     , # [kJ mol^-1] Gibbs energy for K_D
  f_gr_ref  = 0.7    , # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  f_de      = 0.01   , # [g g-1] Fraction of C_D taken up that is converted to C_E (fitted).
  psi_Rth   = 15000  , # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  D_0      =  1e-4 / sec  * tstep , # [m s-1] reference diffusion conductance for dissolved C (and /10 for enzymes), representing diffusivity/distance.
  
  # Only used if adsorption/desorption is on
  k_ads_ref = 1e-6   / sec * tstep , # [m3 gC-1 s-1] Adsorption rate constant of C_D. (Ahrens 2015, units converted for gC)
  k_des_ref = 1.2e-10 / sec * tstep , # [s-1] Desorption rate constant of C_A. (Ahrens 2015)
  E_k       = 10     , # [kJ mol^-1] Gibbs energy for adsorption/desorption fluxes
  
  # Only used if microbes are on
  f_CM      = 0.01   , #
  r_md_ref  = 0.00028 / hour * tstep , # [h-1] Microbe turnover rate (Li at al. 2014, AWB model).
  f_me      = 5.6e-06 / hour * tstep , # [gC g-1 C_M h-1] Fraction of C_M converted to C_E (assumed).
  f_mp      = 0.5                      # [g g^-1] fraction of dead microbes going to C_P (rest goes to C_D)
  
)

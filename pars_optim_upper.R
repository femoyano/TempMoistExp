#### Documentation ============================================================
# Initial estimate values for parameters to optimize.
# Time variables and tstep have to be defined before sourcing this file.
#### ==========================================================================

pars_optim_upper <- c(
  TOC_bf    = 0.007  , # gC gSoil-1
  TOC_mz    = 0.013  , # gC gSoil-1
  f_CA      = 0.8    , # both soils (bare fallow and maize(Closeaux)) has the same fraction of clay+silt to total C
  f_CD      = 0.005  , #
  f_CEm     = 0.005  , #
  f_CEw     = 0.005  , #
  f_CM      = 0.05   , #
  r_ed_ref  = 0.01   / hour * tstep , # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  V_D_ref   = 10     / hour * tstep , # [h-1] Maximum speed of C_P decomposition (Li at al. 2014, AWB model)
  K_D_ref   = 500000 , # [gC m-3] Affinity parameter for C_P decomp. (Adjusted. As ref: Li at al. 2014, AWB model => 250 mg gSoil-1)
  k_ads_ref = 1e-5   / sec * tstep , # [m3 gC-1 s-1] Adsorption rate constant of C_D. (Ahrens 2015, units converted for gC)
  k_des_ref = 1e-8   / sec * tstep , # [s-1] Desorption rate constant of C_A. (Ahrens 2015)
  E_V       = 70     , # [kJ mol^-1] Gibbs energy for decomposition
  E_K       = 40     , # [kJ mol^-1] Gibbs energy for K_D
  E_k       = 30     , # [kJ mol^-1] Gibbs energy for adsorption/desorption fluxes
  f_gr_ref  = 0.8    , # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  f_de      = 0.1    , # [g g-1] Fraction of C_D taken up that is converted to C_E (fitted).
  psi_Rth   = 20000  , # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  d_pm      = 1e-2   , # [m] characteristic distance between substrate and microbes (Manzoni manus)
  
  D_d0      = 8.1e-9  / sec  * tstep , # [m2 s-1] Diffusivity in water for amino acids, after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
  D_e0      = 8.1e-10 / sec  * tstep , # [m2 s-1] Diffusivity in water for enzymes. Vetter et al., 1998
  
  # Only used if microbes are on
  r_md_ref  = 0.001   / hour * tstep , # [h-1] Microbe turnover rate (Li at al. 2014, AWB model).
  f_me      = 1e-04   / hour * tstep , # [gC g-1 C_M h-1] Fraction of C_M converted to C_E (assumed).
  f_mp      = 0.9                      # [g g^-1] fraction of dead microbes going to C_P (rest goes to C_D)
)

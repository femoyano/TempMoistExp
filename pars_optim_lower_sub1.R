#### Documentation ============================================================
# Initial estimate values for parameters to optimize.
# Time variables and tstep have to be defined before sourcing this file.
#### ==========================================================================

pars_optim_lower <- c(
  TOC_bf    = 0.005  , # gC gSoil-1
  TOC_mz    = 0.011  , # gC gSoil-1
  f_CA      = 0.3    , # both soils (bare fallow and maize(Closeaux)) has the same fraction of clay+silt to total C
  r_ed_ref  = 0.0001 / hour * tstep , # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  V_D_ref   = 0.01   / hour * tstep , # [h-1] Maximum speed of C_P decomposition (Li at al. 2014, AWB model)
  E_V       = 30     , # [kJ mol^-1] Gibbs energy for decomposition
  E_K       = 20     , # [kJ mol^-1] Gibbs energy for K_D
  f_gr_ref  = 0.5    , # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  f_de      = 0.001  , # [g g-1] Fraction of C_D taken up that is converted to C_E (fitted).
  d_pm      = 1e-7   , # [m] characteristic distance between substrate and microbes (Manzoni manus)
  D_d0      = 8.1e-11 / sec  * tstep # [m2 s-1] Diffusivity in water for amino acids, after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
)

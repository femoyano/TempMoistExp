#### Documentation ============================================================
# Initial estimate values for parameters to optimize.
# Time variables and tstep have to be defined before sourcing this file.
#### ==========================================================================

### Parameter Set 3 for initial and bounds values
### Subset of calibratable model parameters (noMic, noAds) with large bounds.

pars_optim_init <- c(
  f_CA_bf   = 0.2    ,                # fraction of C_A in TOC for bare fallow
  f_CA_mz   = 0.2    ,                # fraction of C_A in TOC for maize soil 
  f_CD      = 0.001  ,                # fraction of CD in toc
  f_CEm     = 0.001  ,                # fraction of CEm in toc
  f_CEw     = 0.001  ,                # fraction of CEw in toc
  r_ed_ref  = 0.001  / hour * tstep , # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  V_D_ref   = 1      / hour * tstep , # [h-1] Maximum speed of C_P decomposition (Li at al. 2014, AWB model)
  K_D_ref   = 2000 ,                # [gC m-3] Affinity parameter for C_P decomp. Gueesed starting value.
  E_V       = 47     ,                # [kJ mol^-1] Gibbs energy for decomposition and turnover times
  E_K       = 30     ,                # [kJ mol^-1] Gibbs energy for K_D
  f_gr_ref  = 0.7    ,                # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  f_de      = 0.01   ,                # [g g-1] Fraction of C_D taken up that is converted to C_E (fitted).
  psi_Rth   = 15000  ,                # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  D_0      =  1e-4 / sec  * tstep     # [m s-1] reference diffusion conductance for dissolved C (and /10 for enzymes), representing diffusivity/distance.
)

pars_optim_lower <- c(
  f_CA_bf   = 0   , # fraction of C_A in TOC for bare fallow
  f_CA_mz   = 0   , # fraction of C_A in TOC for maize soil 
  f_CD      = 0.0001 , #
  f_CEm     = 0.0001 , #
  f_CEw     = 0.0001 , #
  r_ed_ref  = 0.00001 / hour * tstep , # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  V_D_ref   = 0.01   / hour * tstep , # [h-1] Maximum speed of C_P decomposition (Li at al. 2014, AWB model)
  K_D_ref   = 100   , # [gC m-3] Affinity parameter for C_P decomp. (Adjusted. As ref: Li at al. 2014, AWB model => 250 mg gSoil-1)
  E_V       = 10     , # [kJ mol^-1] Gibbs energy for decomposition and turnover times
  E_K       = 10     , # [kJ mol^-1] Gibbs energy for K_D
  f_gr_ref  = 0.01    , # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  f_de      = 0.0001  , # [g g-1] Fraction of C_D taken up that is converted to C_E (fitted).
  psi_Rth   = 10000  , # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  D_0      =  1e-10 / sec  * tstep # [m s-1] reference diffusion conductance for dissolved C (and /10 for enzymes), representing diffusivity/distance.
)

pars_optim_upper <- c(
  f_CA_bf   = 0.9    , # fraction of C_A in TOC for bare fallow
  f_CA_mz   = 0.9    , # fraction of C_A in TOC for maize soil 
  f_CD      = 0.005  , #
  f_CEm     = 0.005  , #
  f_CEw     = 0.005  , #
  r_ed_ref  = 0.01   / hour * tstep , # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  V_D_ref   = 10     / hour * tstep , # [h-1] Maximum speed of C_P decomposition (Li at al. 2014, AWB model)
  K_D_ref   = 500000 , # [gC m-3] Affinity parameter for C_P decomp. (Adjusted. As ref: Li at al. 2014, AWB model => 250 mg gSoil-1)
  E_V       = 100     , # [kJ mol^-1] Gibbs energy for decomposition and turnover times
  E_K       = 50     , # [kJ mol^-1] Gibbs energy for K_D
  f_gr_ref  = 0.9    , # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  f_de      = 0.5    , # [g g-1] Fraction of C_D taken up that is converted to C_E
  psi_Rth   = 20000  , # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  D_0       = 1  / sec  * tstep # [m2 s-1] Diffusivity in water for amino acids, after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
)


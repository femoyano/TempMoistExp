#### Documentation ============================================================
# Initial estimate values for parameters to optimize.
# Time variables and tstep have to be defined before sourcing this file.
#### ==========================================================================

### Parameter Set 2 for initial and bounds values
### Subset of full model parameters (noMic, noAds) with conservative bounds.

pars_optim_init <- c(
  f_CA_bf   = 0.2    ,                # fraction of C_A in TOC for bare fallow
  f_CA_mz   = 0.2    ,                # fraction of C_A in TOC for maize soil 
  f_CD      = 0.001  ,                # fraction of CD in toc
  f_CEm     = 0.001  ,                # fraction of CEm in toc
  f_CEw     = 0.001  ,                # fraction of CEw in toc
  r_ed_ref  = 0.001  / hour * tstep , # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  V_D_ref   = 1      / hour * tstep , # [h-1] Maximum speed of C_P decomposition (Li at al. 2014, AWB model)
  K_D_ref   = 200000 ,                # [gC m-3] Affinity parameter for C_P decomp. Gueesed starting value.
  E_V       = 47     ,                # [kJ mol^-1] Gibbs energy for decomposition and turnover times
  E_K       = 30     ,                # [kJ mol^-1] Gibbs energy for K_D
  f_gr_ref  = 0.7    ,                # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  f_de      = 0.01   ,                # [g g-1] Fraction of C_D taken up that is converted to C_E (fitted).
  psi_Rth   = 15000  ,                # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  D_0      =  1e-4 / sec  * tstep     # [m s-1] reference diffusion conductance for dissolved C (and /10 for enzymes), representing diffusivity/distance.
)

pars_optim_lower <- c(
  f_CA_bf   = 0.01   , 
  f_CA_mz   = 0.01   , 
  f_CD      = 0.0001 , 
  f_CEm     = 0.0001 , 
  f_CEw     = 0.0001 , 
  r_ed_ref  = 0.0001 / hour * tstep , 
  V_D_ref   = 0.01   / hour * tstep , 
  K_D_ref   = 10000  , 
  E_V       = 30     , 
  E_K       = 20     , 
  f_gr_ref  = 0.5    , 
  f_de      = 0.001  , 
  psi_Rth   = 13000  , 
  D_0      =  1e-7 / sec  * tstep 
)

pars_optim_upper <- c(
  f_CA_bf   = 0.9    , 
  f_CA_mz   = 0.9    , 
  f_CD      = 0.005  ,
  f_CEm     = 0.005  ,
  f_CEw     = 0.005  ,
  r_ed_ref  = 0.01   / hour * tstep , 
  V_D_ref   = 10     / hour * tstep , 
  K_D_ref   = 500000 , 
  E_V       = 100     , 
  E_K       = 40     , 
  f_gr_ref  = 0.8    , 
  f_de      = 0.1    , 
  psi_Rth   = 17000  , 
  D_0       = 1e-2  / sec  * tstep 
)


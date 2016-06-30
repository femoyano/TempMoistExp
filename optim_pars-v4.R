#### Documentation ============================================================
# Initial estimate values for parameters to optimize.
# Time variables and tstep have to be defined before sourcing this file.
#### ==========================================================================

### Parameter Set for initial and bounds values
### Parameters with large bounds.

pars_optim_init <- c(
  
  # # Only used if microbes are on
  r_md_ref  = 0.001   ,  # [h-1] Microbe turnover rate (Li at al. 2014, AWB model).
  f_mr      = 0.9     ,  # [] fraction of microbial turnover going to maintenance respiration

  # For all cases
  # f_gr_ref  = 0.53    ,  # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  # f_ep      = 0.002   ,  # fraction of uptaken C converted to C_E (assumed)
  V_U_ref   = 1      ,  # [h-1] max rate of microbial C uptake (assumed
  # K_D_ref   = 73000  ,  # [gC m-3] Affinity parameter for C_P decomp. Guessed starting value.
  K_U_ref   = 10     ,  # [gC m-3] Affinity parameter for C_D uptake.
  # r_ed_ref  = 0.00024  ,  # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  E_V       = 98     ,  # [kJ mol^-1] Gibbs energy for decomposition and turnover times
  E_K       = 35       # [kJ mol^-1] Gibbs energy for K_D
)

pars_optim_lower <- c(
  
  # # Only used if microbes are on
  r_md_ref  = 0.0001   ,  # [h-1] Microbe turnover rate (Li at al. 2014, AWB model).
  f_mr      = 0.01     ,  # [] fraction of microbial turnover going to maintenance respiration
  
  # For all cases
  # f_gr_ref  = 0.53    ,  # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  # f_ep      = 0.002   ,  # fraction of uptaken C converted to C_E (assumed)
  V_U_ref   = 0.01      ,  # [h-1] max rate of microbial C uptake (assumed
  # K_D_ref   = 73000  ,  # [gC m-3] Affinity parameter for C_P decomp. Guessed starting value.
  K_U_ref   = 1     ,  # [gC m-3] Affinity parameter for C_D uptake.
  # r_ed_ref  = 0.00024  ,  # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  E_V       = 40     ,  # [kJ mol^-1] Gibbs energy for decomposition and turnover times
  E_K       = 10       # [kJ mol^-1] Gibbs energy for K_D
)

pars_optim_upper <- c(
  
  # # Only used if microbes are on
  r_md_ref  = 0.01   ,  # [h-1] Microbe turnover rate (Li at al. 2014, AWB model).
  f_mr      = 0.99     ,  # [] fraction of microbial turnover going to maintenance respiration
  
  # For all cases
  # f_gr_ref  = 0.53    ,  # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  # f_ep      = 0.002   ,  # fraction of uptaken C converted to C_E (assumed)
  V_U_ref   = 100      ,  # [h-1] max rate of microbial C uptake (assumed
  # K_D_ref   = 73000  ,  # [gC m-3] Affinity parameter for C_P decomp. Guessed starting value.
  K_U_ref   = 100000     ,  # [gC m-3] Affinity parameter for C_D uptake.
  # r_ed_ref  = 0.00024  ,  # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  E_V       = 110     ,  # [kJ mol^-1] Gibbs energy for decomposition and turnover times
  E_K       = 110      # [kJ mol^-1] Gibbs energy for K_D
)

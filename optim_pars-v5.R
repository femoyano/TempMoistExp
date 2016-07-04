####################################################
### Start and bounds for parameters to optimize. ###
####################################################

# Modified opt RUN15

pars_optim_init <- c(

  # Only used if adsorption/desorption is on
  # k_ads_ref = 0.0039  , # [m3 gC-1 h-1] Adsorption rate constant of C_D. (Ahrens 2015, units converted for gC)
  # k_des_ref = 4.3e-7  , # [h-1] Desorption rate constant of C_A. (Ahrens 2015)
  # E_k       = 10      , # [kJ mol^-1] Gibbs energy for adsorption/desorption fluxes
  
  # # Only used if microbes are on
  # r_md_ref  = 0.001   ,  # [h-1] Microbe turnover rate (Li at al. 2014, AWB model).
  # f_mr      = 0.9     ,  # [] fraction of microbial turnover going to maintenance respiration
  # f_CM      = 0.01    ,  # fraction of C_M in toc
  
  # For all cases
  f_CA_bf   = 0.035    ,  # fraction of C_A in TOC for bare fallow
  f_CA_mz   = 0.35    ,  # fraction of C_A in TOC for maize soil 
  f_CD      = 0.0001  ,  # fraction of CD in toc
  f_CE      = 0.0001  ,  # fraction of CEm in toc
  f_CM      = 0.01   ,  # fraction of CD in toc
  f_gr_ref  = 0.53    ,  # Carbon use efficieny (= microbial growth efficiency) (Hagerty et al.)
  f_ep      = 0.002   ,  # fraction of uptaken C converted to C_E (assumed)
  V_D_ref   = 0.3      ,  # [h-1] max rate of C_P decomposition (Li at al. 2014, AWB model)
  # V_U_ref   = 0.3      ,  # [h-1] max rate of microbial C uptake (assumed
  K_D_ref   = 73000  ,  # [gC m-3] Affinity parameter for C_P decomp. Guessed starting value.
  # K_U_ref   = 10     ,  # [gC m-3] Affinity parameter for C_D uptake.
  r_ed_ref  = 0.00024  ,  # [h-1] Enzyme turnover rate (Li at al. 2014, AWB model).
  E_V       = 98     ,  # [kJ mol^-1] Gibbs energy for decomposition and turnover times
  E_K       = 35     ,  # [kJ mol^-1] Gibbs energy for K_D
  psi_Rth   = 16900  ,  # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  D_0       = 5.2      # [m s-1] reference diffusion conductance for dissolved C (and /10 for enzymes), representing diffusivity/distance.  
)

pars_optim_lower <- c(
  
  # Only used if adsorption/desorption is on
  # k_ads_ref = 0.00039 , 
  # k_des_ref = 4.3e-8  ,
  # E_k       = 5       ,
  
  # Only used if microbes are on
  # r_md_ref  = 0.00001  ,
  # f_mr      = 0.8    ,
  # f_CM      = 0.005   , 
  
  # For all cases
  f_CA_bf   = 0.0   ,
  f_CA_mz   = 0.0   ,
  f_CD      = 0.00001 ,
  f_CE      = 0.00001 ,
  f_CM      = 0.001   ,
  f_gr_ref  = 0.5    ,
  f_ep      = 0.0001  ,
  V_D_ref   = 0.01   ,
  # V_U_ref   = 0.01   ,
  K_D_ref   = 100    ,
  # K_U_ref   = 1      ,
  r_ed_ref  = 0.0001 ,
  E_V       = 80     ,
  E_K       = 20     ,
  psi_Rth   = 14000  ,
  D_0       = 0.1
)

pars_optim_upper <- c(
  
  # Only used if adsorption/desorption is on
  # k_ads_ref = 0.039  ,
  # k_des_ref = 4.3e-6 ,
  # E_k       = 50     ,
  
  # Only used if microbes are on
  # r_md_ref  = 0.01 ,
  # f_mr      = 0.99   ,
  # f_CM      = 0.015   , 
  
  # For all cases
  f_CA_bf   = 0.99    ,
  f_CA_mz   = 0.99    ,
  f_CD      = 0.001  ,
  f_CE      = 0.0005  ,
  f_CM      = 0.05   ,
  f_gr_ref  = 0.9   ,
  f_ep      = 0.5    ,
  V_D_ref   = 50     ,
  # V_U_ref   = 50     ,
  K_D_ref   = 500000 ,
  # K_U_ref   = 500000 ,
  r_ed_ref  = 0.1    ,
  E_V       = 110    ,
  E_K       = 110    ,
  psi_Rth   = 18000  ,
  D_0       = 10
)

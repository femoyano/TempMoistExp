################################################
###    Set bounds for optimized parameters   ###
################################################

# version 1: par_bounds_v1

# min and max value of each parameter
pars_bounds <- cbind(
  f_CA_bf  = c(0.0, 0.9) ,
  f_CA_mz  = c(0.0, 1) ,
  f_gr_ref = c(0.5, 0.85) ,
  f_ep     = c(0.001, 0.5) ,
  V_D_ref  = c(0.01, 2) ,
  V_U_ref  = c(0.01, 2) ,
  K_D_ref  = c(10000, 300000) ,
  K_U_ref  = c(0.1, 1000) ,
  r_ed_ref = c(0.00001, 0.01) ,
  E_V      = c(50, 120) ,
  E_K      = c(20, 120) ,
  psi_Rth  = c(10000, 20000) ,
  D_0      = c(0.1, 10) ,
  r_md_ref = c(0.00001, 0.01) ,
  f_mr     = c(0.01, 0.99)
)
rownames(pars_bounds) <- c("min","max")
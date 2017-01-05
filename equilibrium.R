### Equilibrium solutions

# Get pars
pars <- read.csv('parsets/pars_all_test_equil.csv', row.names = 1)
pars <- setNames(pars[[1]], row.names(pars))
list2env(as.list(pars), envir = globalenv())

# Set options:
diff_fun  = "hama" # Options: 'hama', 'cubic'
dec_fun   = "MM" # One of: 'MM', '2nd', '1st'
upt_fun   = "1st" # One of: 'MM', '2nd', '1st'

# Temp function
Temp.Resp.Eq <- function(k_ref, temp, T_ref, E, R) {
  k_ref*exp(-E/R*(1/temp - 1/T_ref))
}

# Preprocessing
# Site data
moist = 0.3
temp = 288
clay = 0.15
sand = 0.28
silt = 0.57
ps = 0.45
I_sl = 0.00005
I_ml = 0.000005
z = 0.3

# Calculate intermediate variables
b = 2.91 + 15.9*clay
# k_ads = Temp.Resp.Eq(k_ads_ref, temp, T_ref, E_V, R)
# k_des = Temp.Resp.Eq(k_des_ref, temp, T_ref, E_V, R)
psi_sat = exp(6.5 - 1.3*sand) / 1000
Rth = ps*(psi_sat / psi_Rth)^(1 / b)
fc = ps*(psi_sat / psi_fc)^(1 / b)
D_sm = (ps - Rth)^1.5*((moist - Rth)/(ps - Rth))^2.5

# Calculate end variables
K_D = Temp.Resp.Eq(K_D_ref, temp, T_ref, E_K, R)
V_D = Temp.Resp.Eq(V_D_ref, temp, T_ref, E_V, R)
K_U = Temp.Resp.Eq(K_U_ref, temp, T_ref, E_K, R)
V_U = Temp.Resp.Eq(V_U_ref, temp, T_ref, E_V, R)
r_md = Temp.Resp.Eq(r_md_ref, temp, T_ref, E_d, R)
r_ed = Temp.Resp.Eq(r_ed_ref, temp, T_ref, E_d, R)
D_d = D_0*D_sm
D_e = D_0 / 10*D_sm
MD = 200*(100*clay)^0.6*pd*(1 - ps) / 1000000 #from mg kg-1 to kg m-3
M_fc = 1 #sy.Min(1, M / fc)
mc = mc_0 * pd * (1 - ps) * z  # [kgC m-3] basal microbial carbon
# Ka = k_ads/k_des


# For all:
# flag.mmr = 1 , # microbial maintenance respiration
# flag.mic = 1 , # simulate microbial pool explicitly
# flag.fcs = 0 , # scale C_P and M to field capacity (with max at fc)
# flag.sew = 0 , # calculate C_E and C_D concentration in water
# flag.dte = 0 , # diffusivity temperature effect on/off
# flag.dce = 0 , # diffusivity carbon effect on/off

# ---------------------
# Options:
# dec_fun   = "MM"
# upt_fun   = "1st"
if(dec_fun == "MM" & upt_fun == "1st") {
  C_P <- K_D*r_ed*z*(I_ml*f_gr*f_mr*f_ue - I_ml*f_gr*f_mr - I_ml*f_gr*f_ue +
          I_ml*f_gr - I_sl*f_gr*f_ue + I_sl)/(I_ml*V_D*f_gr*f_ue -
          I_ml*f_gr*f_mr*f_ue*r_ed + I_ml*f_gr*f_mr*r_ed +
          I_ml*f_gr*f_ue*r_ed - I_ml*f_gr*r_ed + I_sl*V_D*f_gr*f_ue +
          I_sl*f_gr*f_ue*r_ed - I_sl*r_ed)
  C_D <- -(I_ml + I_sl)/(V_D*(f_gr*f_mr*f_ue - f_gr*f_mr + f_gr - 1))
  C_M <- f_gr*(I_ml + I_sl)*(f_ue - 1)/(r_md*(f_gr*f_mr*f_ue -
          f_gr*f_mr + f_gr - 1))
  C_E <- -f_gr*f_ue*(I_ml + I_sl)/(r_ed*(f_gr*f_mr*f_ue - f_gr*f_mr + f_gr - 1))
}

### Equilibrium solutions

# Get pars

pars <- read.csv('parsets/pars_all_test1_170203.csv', row.names = 1)
pars <- setNames(pars[[1]], row.names(pars))
list2env(as.list(pars), envir = globalenv())

# Set options:
diff_fun  = "power" # Options: 'hama', 'cubic'
dec_fun   = "MM" # One of: 'MM', '2nd', '1st'
upt_fun   = "1st" # One of: 'MM', '2nd', '1st'

# Temp function
TempRespEq <- function(k_ref, temp, T_ref, E, R) {
  k_ref*exp(-E/R*(1/temp - 1/T_ref))
}

# Preprocessing
# Site data
moist = 0.3
temp = 298
clay = 0.15
sand = 0.28
silt = 0.57
ps = 0.45
I_sl = 0.00005
I_ml = 0.000005
z = 0.3

# Calculate intermediate variables
b = 2.91 + 15.9*clay
# k_ads = TempRespEq(k_ads_ref, temp, T_ref, E_V, R)
# k_des = TempRespEq(k_des_ref, temp, T_ref, E_V, R)
psi_sat = exp(6.5 - 1.3*sand) / 1000
Rth = ps*(psi_sat / psi_Rth)^(1 / b)
fc = ps*(psi_sat / psi_fc)^(1 / b)
D_sm = (ps - Rth)^1.5*((moist - Rth)/(ps - Rth))^2.5

# Calculate end variables
K_D = TempRespEq(K_D_ref, temp, T_ref, E_K, R)
V_D = TempRespEq(V_D_ref, temp, T_ref, E_V, R)
V_U = TempRespEq(V_U_ref, temp, T_ref, E_V, R)
r_md = TempRespEq(r_md_ref, temp, T_ref, E_m, R)
r_ed = TempRespEq(r_ed_ref, temp, T_ref, E_e, R)
r_mr = TempRespEq(r_mr_ref, temp, T_ref, E_r, R)
D_d = D_d0 * D_sm
D_e = D_d0 / 10 * D_sm
MD = 200*(100*clay)^0.6*pd*(1 - ps) / 1000000 #from mg kg-1 to kg m-3
M_fc = 1 #sy.Min(1, M / fc)
# Ka = k_ads/k_des


# For all:
# flag_mmr = 1 , # microbial maintenance respiration
# flag_mic = 1 , # simulate microbial pool explicitly
# flag_fcs = 0 , # scale C_P and M to field capacity (with max at fc)
# flag_sew = 0 , # calculate C_E and C_D concentration in water
# flag_dte = 0 , # diffusivity temperature effect on/off
# flag_dce = 0 , # diffusivity carbon effect on/off

# ---------------------
# Options:

# dec_fun   = "MM"
# upt_fun   = "1st"
if(dec_fun == "MM" & upt_fun == "1st") {
C_P <- -K_D*r_ed*z*(2*D_e + r_ed)*(I_ml*f_gr*f_mp*f_ue*r_md - 
I_ml*f_gr*f_mp*r_md + I_sl*f_gr*f_mp*f_ue*r_md - I_sl*f_gr*f_mp*r_md +
 I_sl*f_gr*f_ue*r_mr + I_sl*f_gr*r_md - I_sl*r_md - I_sl*r_mr)/
 (D_e*I_ml*V_D*f_gr*f_ue*r_md + D_e*I_ml*V_D*f_gr*f_ue*r_mr + 
 2*D_e*I_ml*f_gr*f_mp*f_ue*r_ed*r_md - 2*D_e*I_ml*f_gr*f_mp*r_ed*r_md + 
 D_e*I_sl*V_D*f_gr*f_ue*r_md + D_e*I_sl*V_D*f_gr*f_ue*r_mr + 
 2*D_e*I_sl*f_gr*f_mp*f_ue*r_ed*r_md - 2*D_e*I_sl*f_gr*f_mp*r_ed*r_md +
 2*D_e*I_sl*f_gr*f_ue*r_ed*r_mr + 2*D_e*I_sl*f_gr*r_ed*r_md - 
 2*D_e*I_sl*r_ed*r_md - 2*D_e*I_sl*r_ed*r_mr + 
 I_ml*f_gr*f_mp*f_ue*r_ed**2*r_md - I_ml*f_gr*f_mp*r_ed**2*r_md +
 I_sl*f_gr*f_mp*f_ue*r_ed**2*r_md - I_sl*f_gr*f_mp*r_ed**2*r_md +
 I_sl*f_gr*f_ue*r_ed**2*r_mr + I_sl*f_gr*r_ed**2*r_md -
 I_sl*r_ed**2*r_md - I_sl*r_ed**2*r_mr)

C_D <- -(I_ml + I_sl)*(r_md + r_mr)/
(D_d*V_U*(f_gr*f_ue*r_mr + f_gr*r_md - r_md - r_mr))

C_M <- f_gr*(I_ml + I_sl)*(f_ue - 1)/
(f_gr*f_ue*r_mr + f_gr*r_md - r_md - r_mr)

C_E <- -D_e*f_gr*f_ue*(I_ml + I_sl)*(r_md + r_mr)/
(r_ed*(2*D_e + r_ed)*(f_gr*f_ue*r_mr + f_gr*r_md - r_md - r_mr))

C_Em <- -f_gr*f_ue*(D_e + r_ed)*(I_ml + I_sl)*(r_md + r_mr)/
(r_ed*(2*D_e + r_ed)*(f_gr*f_ue*r_mr + f_gr*r_md - r_md - r_mr))
}

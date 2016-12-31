### Equilibrium solutions

# Get pars
pars_default <- read.csv('parsets/pars_test.csv', row.names = 1)
pars_default <- setNames(pars_default[[1]], row.names(pars_default))
list2env(as.list(pars_default), envir = globalenv())

# Set options:
flag.mmu = 1
flag.mmd = 1

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
I_sl = 0.000005 # 0.00005
I_ml = 0.0000005 # 0.000005
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
# flag.mmu = 0
# flag.mmd = 0
if(flag.mmu == 0 & flag.mmd == 0) {
  C_P <- -r_ed*z*(2*D_e + r_ed)*(I_ml*f_gr*f_me + I_ml*f_gr*f_mr - I_ml*f_gr + I_sl*f_gr*f_me - I_sl)/(D_e*V_D*f_gr*f_me*(I_ml + I_sl))
  C_D <- r_md*z*(I_ml + I_sl)/(D_d*V_U*(I_ml*f_gr + I_sl*f_gr + f_gr*f_mr*mc*r_md - f_gr*mc*r_md + mc*r_md))
  C_M <- f_gr*(I_ml + I_sl)/(r_md*(f_gr*f_mr - f_gr + 1))
  C_E <- D_e*f_gr*f_me*(I_ml + I_sl)/(r_ed*(2*D_e + r_ed)*(f_gr*f_mr - f_gr + 1))
  C_Em <- f_gr*f_me*(D_e + r_ed)*(I_ml + I_sl)/(r_ed*(2*D_e + r_ed)*(f_gr*f_mr - f_gr + 1))
}

# ---------------------
# Options:
# flag.mmu = 1
# flag.mmd = 0
if(flag.mmu == 1 & flag.mmd == 0) {
C_P <- -r_ed*z*(2*D_e + r_ed)*(I_ml*f_gr*f_me + I_ml*f_gr*f_mr - I_ml*f_gr + I_sl*f_gr*f_me - I_sl)/(D_e*V_D*f_gr*f_me*(I_ml + I_sl))
C_D <- K_U*r_md*z*(I_ml + I_sl)/(D_d*(I_ml*V_U*f_gr - I_ml*r_md + I_sl*V_U*f_gr - I_sl*r_md + V_U*f_gr*f_mr*mc*r_md - V_U*f_gr*mc*r_md + V_U*mc*r_md))
C_M <- f_gr*(I_ml + I_sl)/(r_md*(f_gr*f_mr - f_gr + 1))
C_E <- D_e*f_gr*f_me*(I_ml + I_sl)/(r_ed*(2*D_e + r_ed)*(f_gr*f_mr - f_gr + 1))
C_Em <- f_gr*f_me*(D_e*I_ml + D_e*I_sl + I_ml*r_ed + I_sl*r_ed)/(r_ed*(2*D_e*f_gr*f_mr - 2*D_e*f_gr + 2*D_e + f_gr*f_mr*r_ed - f_gr*r_ed + r_ed))
}

# ---------------------
# Options:
# flag.mmu = 0
# flag.mmd = 1
if(flag.mmu == 0 & flag.mmd == 1) {
C_P <- -K_D*r_ed*z*(2*D_e + r_ed)*(I_ml*f_gr*f_me + I_ml*f_gr*f_mr - I_ml*f_gr + I_sl*f_gr*f_me - I_sl)/(D_e*I_ml*V_D*f_gr*f_me + 2*D_e*I_ml*f_gr*f_me*r_ed + 2*D_e*I_ml*f_gr*f_mr*r_ed - 2*D_e*I_ml*f_gr*r_ed + D_e*I_sl*V_D*f_gr*f_me + 2*D_e*I_sl*f_gr*f_me*r_ed - 2*D_e*I_sl*r_ed + I_ml*f_gr*f_me*r_ed**2 + I_ml*f_gr*f_mr*r_ed**2 - I_ml*f_gr*r_ed**2 + I_sl*f_gr*f_me*r_ed**2 - I_sl*r_ed**2)
C_D <- r_md*z*(I_ml + I_sl)/(D_d*V_U*(I_ml*f_gr + I_sl*f_gr + f_gr*f_mr*mc*r_md - f_gr*mc*r_md + mc*r_md))
C_M <- f_gr*(I_ml + I_sl)/(r_md*(f_gr*f_mr - f_gr + 1))
C_E <- D_e*f_gr*f_me*(I_ml + I_sl)/(r_ed*(2*D_e + r_ed)*(f_gr*f_mr - f_gr + 1))
C_Em <- f_gr*f_me*(D_e + r_ed)*(I_ml + I_sl)/(r_ed*(2*D_e + r_ed)*(f_gr*f_mr - f_gr + 1))
}

# ---------------------
# Options:
# flag.mmu = 1
# flag.mmd = 1
if(flag.mmu == 1 & flag.mmd == 1) {
C_P <- K_D*r_ed*z*(-2*D_e*I_ml*f_gr*f_me - 2*D_e*I_ml*f_gr*f_mr + 2*D_e*I_ml*f_gr - 2*D_e*I_sl*f_gr*f_me + 2*D_e*I_sl - I_ml*f_gr*f_me*r_ed - I_ml*f_gr*f_mr*r_ed + I_ml*f_gr*r_ed - I_sl*f_gr*f_me*r_ed + I_sl*r_ed)/(D_e*I_ml*V_D*f_gr*f_me + 2*D_e*I_ml*f_gr*f_me*r_ed + 2*D_e*I_ml*f_gr*f_mr*r_ed - 2*D_e*I_ml*f_gr*r_ed + D_e*I_sl*V_D*f_gr*f_me + 2*D_e*I_sl*f_gr*f_me*r_ed - 2*D_e*I_sl*r_ed + I_ml*f_gr*f_me*r_ed**2 + I_ml*f_gr*f_mr*r_ed**2 - I_ml*f_gr*r_ed**2 + I_sl*f_gr*f_me*r_ed**2 - I_sl*r_ed**2)
C_D <- K_U*r_md*z/(D_d*(V_U*f_gr - r_md))
C_M <- f_gr*(I_ml + I_sl)/(r_md*(f_gr*f_mr - f_gr + 1))
C_E <- D_e*f_gr*f_me*(I_ml + I_sl)/(r_ed*(2*D_e*f_gr*f_mr - 2*D_e*f_gr + 2*D_e + f_gr*f_mr*r_ed - f_gr*r_ed + r_ed))
C_Em <- f_gr*f_me*(D_e*I_ml + D_e*I_sl + I_ml*r_ed + I_sl*r_ed)/(r_ed*(2*D_e*f_gr*f_mr - 2*D_e*f_gr + 2*D_e + f_gr*f_mr*r_ed - f_gr*r_ed + r_ed))
}


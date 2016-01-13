# -*- coding: utf-8 -*-
from __future__ import division
import sympy as sy
from math import exp

"""
Created on Tue Dec 29 11:56:58 2015

@author: nano

Script for sovling the steady state equations

Equations are simplified
"""

# Define varialbes
year = 31104000       # seconds in a year
month = 2592000       # seconds in a month
day = 86400           # seconds in a day
hour = 3600           # seconds in an hour
sec = 1               # seconds in a second!
tstep = hour

# Define functions


def T_resp_eq(k_ref, T, T_ref, E, R):
    # calculates the T response
    return k_ref * sy.exp(-E/R * (1/T-1/T_ref))


# Define symbols
C_P, C_D, C_A, C_Em, C_Ew, C_M, C_R = \
    sy.symbols('C_P C_D C_A C_Em C_Ew C_M C_R')

r_md_S, r_ed_S, f_gr_S, f_de_S = (sy.symbols('r_md_S r_ed_S f_gr_S f_de_S'))
V_D_S, K_D_S, D_dc_S, D_ec_S = (sy.symbols('V_D_S  K_D_S D_dc_S D_ec_S'))
k_ads_S, k_des_S, M_fc_S, Md_S = (sy.symbols('k_ads_S k_des_S M_fc_S Md_S'))

M_S, I_sl_S, I_ml_S, z_S = sy.symbols('M_S I_sl_S I_ml_S z_S')

# Define fluxes

# Set flags
f_ads = 0  # adsorption desorption flag
f_mic = 0  # simulate microbial pool explicitly
f_fcs = 1  # scale C_P, C_A, ECs, M_S to field capacity (with max at fc)
f_sew = 1  # calculate EC and SC concentration in water

# F_dcac = ((C_D / (z_S * M_S)) * ((Md_S - (C_A / z_S)) * M_fc_S) *
#           k_ads_S * z_S)
# F_acdc = C_A * M_fc_S * k_des_S

F_slpc = I_sl_S
F_mldc = I_ml_S
F_pcdc = ((V_D_S * (C_Ew / (M_S * z_S)) * (C_P / z_S * M_fc_S)) /
          (K_D_S + (C_P / z_S * M_fc_S)) * z_S)
F_dcrc = D_dc_S * (C_D - 0) * (1 - f_gr_S)
F_dcpc = D_dc_S * (C_D - 0) * f_gr_S * (1 - f_de_S)
F_dcem = D_dc_S * (C_D - 0) * f_gr_S * f_de_S
F_emew = D_ec_S * (C_Em - C_Ew)
F_ewdc = C_Ew * r_ed_S
F_emdc = C_Em * r_ed_S

dC_P = F_slpc + F_dcpc - F_pcdc
dC_D = F_mldc + F_pcdc + F_ewdc + F_emdc - F_dcrc - F_dcpc - F_dcem
# dC_A = F_dcac - F_acdc
dC_Ew = F_emew - F_ewdc
dC_Em = F_dcem - F_emew - F_emdc

sol = sy.solve([dC_P, dC_D, dC_Ew, dC_Em],
               [C_P, C_D, C_Ew, C_Em], dict=True)
sol = sol[0]
sol_C_P = sol[C_P]
sol_C_D = sol[C_D]
sol_C_Em = sol[C_Em]
sol_C_Ew = sol[C_Ew]


# Define parameter values
R = 0.008314
r_md_ref = 0.00028 / hour * tstep
r_ed_ref = 0.001 / hour * tstep
f_me = 5.6e-06 / hour * tstep
V_D_ref = 1.0 / hour * tstep
D_S0 = 8.1e-10 / sec * tstep
D_E0 = 8.1e-11 / sec * tstep
k_ads_ref = 1.08e-6 / sec * tstep
k_des_ref = 1.19e-10 / sec * tstep
K_D_ref = 300000
f_mp = 0.5
T_ref = 293.15
E_VU = 47
E_VD = 47
E_KU = 30
E_KD = 30
E_ka = 10
E_kd = 10
E_md = 47
E_ed = 47
f_gr_ref = 0.7
f_gr_s = -0.016
pd = 2.7
psi_Rth = 15000
psi_fc = 33
d_pm = 10**-7
T = 280
clay = 0.1
silt = 0.2
sand = 0.7
ps = 0.45
z = 0.3
f_de = 0.01
M = 0.2
I_sl = 0.0848
I_ml = 0.00898

# Calculate some intermediate variables
b = 2.91 + 15.9 * clay
psi_sat = exp(6.5 - 1.3 * sand) / 1000
Rth = ps * (psi_sat / psi_Rth)**(1 / b)
fc = ps * (psi_sat / psi_fc)**(1 / b)
MD = 200 * (100 * clay)**0.6 * pd * (1 - ps)
K_D = T_resp_eq(K_D_ref, T, T_ref, E_KD, R)
k_ads = T_resp_eq(k_ads_ref, T, T_ref, E_ka, R)
k_des = T_resp_eq(k_des_ref, T, T_ref, E_kd, R)
V_D = T_resp_eq(V_D_ref, T, T_ref, E_VD, R)
r_md = T_resp_eq(r_md_ref, T, T_ref, E_md, R)
r_ed = T_resp_eq(r_ed_ref, T, T_ref, E_ed, R)
f_gr = f_gr_ref
diff_mod = (ps - Rth)**1.5 * ((M - Rth)/(ps - Rth))**2.5
D_dc = D_S0 * diff_mod / d_pm
D_ec = D_E0 * diff_mod / d_pm
M_fc = sy.Min(1, M / fc)

# Substitute variables (parameters) with values

v_C_P = sol_C_P.subs([
    (r_md_S, r_md), (r_ed_S, r_ed), (V_D_S, V_D), (D_dc_S, D_dc),
    (D_ec_S, D_ec), (k_ads_S, k_ads), (k_des_S, k_des), (K_D_S, K_D),
    (f_gr_S, f_gr), (f_de_S, f_de), (M_fc_S, M_fc), (Md_S, MD), (M_S, M),
    (I_sl_S, I_sl), (I_ml_S, I_ml), (z_S, z)
    ])

v_C_D = sol_C_D.subs([
    (r_md_S, r_md), (r_ed_S, r_ed), (V_D_S, V_D), (D_dc_S, D_dc),
    (D_ec_S, D_ec), (k_ads_S, k_ads), (k_des_S, k_des), (K_D_S, K_D),
    (f_gr_S, f_gr), (f_de_S, f_de), (M_fc_S, M_fc), (Md_S, MD), (M_S, M),
    (I_sl_S, I_sl), (I_ml_S, I_ml), (z_S, z)
    ])

v_C_Ew = sol_C_Ew.subs([
    (r_md_S, r_md), (r_ed_S, r_ed), (V_D_S, V_D), (D_dc_S, D_dc),
    (D_ec_S, D_ec), (k_ads_S, k_ads), (k_des_S, k_des), (K_D_S, K_D),
    (f_gr_S, f_gr), (f_de_S, f_de), (M_fc_S, M_fc), (Md_S, MD), (M_S, M),
    (I_sl_S, I_sl), (I_ml_S, I_ml), (z_S, z)
    ])

v_C_Em = sol_C_Em.subs([
    (r_md_S, r_md), (r_ed_S, r_ed), (V_D_S, V_D), (D_dc_S, D_dc),
    (D_ec_S, D_ec), (k_ads_S, k_ads), (k_des_S, k_des), (K_D_S, K_D),
    (f_gr_S, f_gr), (f_de_S, f_de), (M_fc_S, M_fc), (Md_S, MD), (M_S, M),
    (I_sl_S, I_sl), (I_ml_S, I_ml), (z_S, z)
    ])

# Calculate equilibrium value for adsorbed C
Min = MD * z * M_fc   # amount of available mineral reaction sites
K = k_ads/k_des    # binding constant
eq1 = sy.Eq(K, C_A / (v_C_D * (Min - C_A)))   # K = LR / (L * R)
v_C_A = sy.solve(eq1, C_A)[0]

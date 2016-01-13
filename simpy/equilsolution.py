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
C_p, C_d, C_a, C_em, C_ew, C_m, C_r = \
    sy.symbols('C_p C_d C_a C_em C_ew C_m C_r')

Mm_S, Em_S, R_gr_S, E_f_S = (sy.symbols('Mm_S Em_S R_gr_S E_f_S'))
V_D_S, K_D_S, D_dc_S, D_ec_S = (sy.symbols('V_D_S  K_D_S D_dc_S D_ec_S'))
k_as_S, k_ds_S, M_fc_S, Md_S = (sy.symbols('k_as_S k_ds_S M_fc_S Md_S'))

M_S, I_sl_S, I_ml_S, z_S = sy.symbols('M_S I_sl_S I_ml_S z_S')

# Define fluxes

# Set flags
f_ads = 0  # adsorption desorption flag
f_mic = 0  # simulate microbial pool explicitly
f_fcs = 1  # scale C_p, C_a, ECs, M_S to field capacity (with max at fc)
f_sew = 1  # calculate EC and SC concentration in water

# F_dcac = ((C_d / (z_S * M_S)) * ((Md_S - (C_a / z_S)) * M_fc_S) *
#           k_as_S * z_S)
# F_acdc = C_a * M_fc_S * k_ds_S

F_slpc = I_sl_S
F_mldc = I_ml_S
F_pcdc = ((V_D_S * (C_ew / (M_S * z_S)) * (C_p / z_S * M_fc_S)) /
          (K_D_S + (C_p / z_S * M_fc_S)) * z_S)
F_dcrc = D_dc_S * (C_d - 0) * (1 - R_gr_S)
F_dcpc = D_dc_S * (C_d - 0) * R_gr_S * (1 - E_f_S)
F_dcem = D_dc_S * (C_d - 0) * R_gr_S * E_f_S
F_emew = D_ec_S * (C_em - C_ew)
F_ewdc = C_ew * Em_S
F_emdc = C_em * Em_S

dC_p = F_slpc + F_dcpc - F_pcdc
dC_d = F_mldc + F_pcdc + F_ewdc + F_emdc - F_dcrc - F_dcpc - F_dcem
# dC_a = F_dcac - F_acdc
dC_ew = F_emew - F_ewdc
dC_em = F_dcem - F_emew - F_emdc

sol = sy.solve([dC_p, dC_d, dC_ew, dC_em],
               [C_p, C_d, C_ew, C_em], dict=True)
sol = sol[0]
sol_C_p = sol[C_p]
sol_C_d = sol[C_d]
sol_C_em = sol[C_em]
sol_C_ew = sol[C_ew]


# Define parameter values
R = 0.008314
Mm_ref = 0.00028 / hour * tstep
Em_ref = 0.001 / hour * tstep
Ep = 5.6e-06 / hour * tstep
V_D_ref = 1.0 / hour * tstep
D_S0 = 8.1e-10 / sec * tstep
D_E0 = 8.1e-11 / sec * tstep
k_a_ref = 1.08e-6 / sec * tstep
k_dsref = 1.19e-10 / sec * tstep
K_Dref = 300000
mcpc_f = 0.5
T_ref = 293.15
E_VU = 47
E_VD = 47
E_KU = 30
E_KD = 30
E_ka = 10
E_kd = 10
E_mm = 47
E_em = 47
R_gr_ref = 0.7
R_gr_s = -0.016
pd = 2.7
psi_Rth = 15000
psi_fc = 33
dist = 10**-7
T = 280
clay = 0.1
silt = 0.2
sand = 0.7
ps = 0.45
z = 0.3
E_f = 0.01
M = 0.2
I_sl = 0.0848
I_ml = 0.00898

# Calculate some intermediate variables
b = 2.91 + 15.9 * clay
psi_sat = exp(6.5 - 1.3 * sand) / 1000
Rth = ps * (psi_sat / psi_Rth)**(1 / b)
fc = ps * (psi_sat / psi_fc)**(1 / b)
MD = 200 * (100 * clay)**0.6 * pd * (1 - ps)
K_D = T_resp_eq(K_Dref, T, T_ref, E_KD, R)
k_as = T_resp_eq(k_asref, T, T_ref, E_ka, R)
k_ds = T_resp_eq(k_dsref, T, T_ref, E_kd, R)
V_D = T_resp_eq(V_D_ref, T, T_ref, E_VD, R)
Mm = T_resp_eq(Mm_ref, T, T_ref, E_mm, R)
Em = T_resp_eq(Em_ref, T, T_ref, E_em, R)
R_gr = R_gr_ref
diff_mod = (ps - Rth)**1.5 * ((M - Rth)/(ps - Rth))**2.5
D_dc = D_S0 * diff_mod / dist
D_ec = D_E0 * diff_mod / dist
M_fc = sy.Min(1, M / fc)

# Substitute variables (parameters) with values

v_C_p = sol_C_p.subs([
    (Mm_S, Mm), (Em_S, Em), (V_D_S, V_D), (D_dc_S, D_dc), (D_ec_S, D_ec),
    (k_as_S, k_as), (k_ds_S, k_ds), (K_D_S, K_D), (R_gr_S, R_gr),
    (E_f_S, E_f), (M_fc_S, M_fc), (Md_S, MD), (M_S, M), (I_sl_S, I_sl),
    (I_ml_S, I_ml), (z_S, z)
    ])

v_C_d = sol_C_d.subs([
    (Mm_S, Mm), (Em_S, Em), (V_D_S, V_D), (D_dc_S, D_dc), (D_ec_S, D_ec),
    (k_as_S, k_as), (k_ds_S, k_ds), (K_D_S, K_D), (R_gr_S, R_gr),
    (E_f_S, E_f), (M_fc_S, M_fc), (Md_S, MD), (M_S, M), (I_sl_S, I_sl),
    (I_ml_S, I_ml), (z_S, z)
    ])

v_C_ew = sol_C_ew.subs([
    (Mm_S, Mm), (Em_S, Em), (V_D_S, V_D), (D_dc_S, D_dc), (D_ec_S, D_ec),
    (k_as_S, k_as), (k_ds_S, k_ds), (K_D_S, K_D), (R_gr_S, R_gr),
    (E_f_S, E_f), (M_fc_S, M_fc), (Md_S, MD), (M_S, M), (I_sl_S, I_sl),
    (I_ml_S, I_ml), (z_S, z)
    ])

v_C_em = sol_C_em.subs([
    (Mm_S, Mm), (Em_S, Em), (V_D_S, V_D), (D_dc_S, D_dc), (D_ec_S, D_ec),
    (k_as_S, k_as), (k_ds_S, k_ds), (K_D_S, K_D), (R_gr_S, R_gr),
    (E_f_S, E_f), (M_fc_S, M_fc), (Md_S, MD), (M_S, M), (I_sl_S, I_sl),
    (I_ml_S, I_ml), (z_S, z)
    ])

# Calculate equilibrium value for adsorbed C
Min = MD * z * M_fc   # amount of available mineral reaction sites
K = k_as/k_ds    # binding constant
eq1 = sy.Eq(K, C_a / (v_C_d * (Min - C_a)))   # K = LR / (L * R)
v_C_a = sy.solve(eq1, C_a)[0]

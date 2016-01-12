# -*- coding: utf-8 -*-
from __future__ import division
import sympy as sy
from math import exp

"""
Created on Tue Dec 29 11:56:58 2015
@author: nano
Script for solving the steady state equations

This version has adsorbtion fluxes included, but is not working.
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

Mm, Em, V_D, D_dc, D_ec, k_AS, k_DS, K_D, R_gr, E_f, M_fc, Md = (
    sy.symbols('Mm Em V_D D_dc D_ec k_AS k_DS K_D R_gr E_f M_fc Md'))

M, I_sl, I_ml, z = sy.symbols('M I_sl I_ml z')

# Define fluxes

# Set flags
f_ads = 0  # adsorption desorption flag
f_mic = 0  # simulate microbial pool explicitly
f_fcs = 1  # scale C_p, C_a, ECs, M to field capacity (with max at fc)
f_sew = 1  # calculate EC and SC concentration in water


F_slpc = I_sl
F_mldc = I_ml
F_pcdc = ((V_D * (C_ew / (M * z)) * (C_p / z * M_fc)) /
          (K_D + (C_p / z * M_fc)) * z)

if f_ads:
    F_dcac = ((C_d / (z * M)) * ((Md - (C_a / z)) * M_fc) *
              k_AS * z)
    F_acdc = C_a * M_fc * k_DS
else:
    F_dcac = 0 * C_a
    F_acdc = 0 * C_a

F_dcrc = D_dc * (C_d - 0) * (1 - R_gr)
F_dcpc = D_dc * (C_d - 0) * R_gr * (1 - E_f)
F_dcem = D_dc * (C_d - 0) * R_gr * E_f
F_emew = D_ec * (C_em - C_ew)
F_ewdc = C_ew * Em
F_emdc = C_em * Em


dC_p = F_slpc + F_dcpc - F_pcdc
dC_d = (F_mldc + F_pcdc + F_ewdc + F_emdc + F_acdc -
        F_dcac - F_dcrc - F_dcpc - F_dcem)
dC_a = F_dcac - F_acdc
dC_ew = F_emew - F_ewdc
dC_em = F_dcem - F_emew - F_emdc

sol = sy.solve([dC_p, dC_d, dC_a, dC_ew, dC_em],
                        [C_p, C_d, C_a, C_ew, C_em], dict=True)
sol = sol[0]
sol_C_p = sol[C_p]
sol_C_d = sol[C_d]
sol_C_a = sol[C_a]
sol_C_em = sol[C_em]
sol_C_ew = sol[C_ew]


# Define parameter values
R = 0.008314
Mm_ref = 0.00028 / hour * tstep
Em_ref = 0.001 / hour * tstep
Ep = 5.6e-06 / hour * tstep
V_Dref = 1.0 / hour * tstep
D_dc0 = 8.1e-10 / sec * tstep
D_ec0 = 8.1e-11 / sec * tstep
k_ASref = 1.08e-6 / sec * tstep
k_DSref = 1.19e-10 / sec * tstep
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
z_v = 0.3
E_f_v = 0.01
M_v = 0.2
I_sl_v = 0.0848
I_ml_v = 0.00898

# Calculate some intermediate variables
b = 2.91 + 15.9 * clay
psi_sat = exp(6.5 - 1.3 * sand) / 1000
Rth = ps * (psi_sat / psi_Rth)**(1 / b)
fc = ps * (psi_sat / psi_fc)**(1 / b)
Md_v = 200 * (100 * clay)**0.6 * pd * (1 - ps)
K_D_v = T_resp_eq(K_Dref, T, T_ref, E_KD, R)
k_AS_v = T_resp_eq(k_ASref, T, T_ref, E_ka, R)
k_DS_v = T_resp_eq(k_DSref, T, T_ref, E_kd, R)
V_D_v = T_resp_eq(V_Dref, T, T_ref, E_VD, R)
Mm_v = T_resp_eq(Mm_ref, T, T_ref, E_mm, R)
Em_v = T_resp_eq(Em_ref, T, T_ref, E_em, R)
R_gr_v = R_gr_ref
diff_mod = (ps - Rth)**1.5 * ((M_v - Rth)/(ps - Rth))**2.5
D_dc_v = D_dc0 * diff_mod / dist
D_ec_v = D_ec0 * diff_mod / dist
M_fc_v = sy.Min(1, M_v / fc)

# Substitute variables (parameters) with values

v_dC_p = sol_C_p.subs([
    (Mm, Mm_v), (Em, Em_v), (V_D, V_D_v), (D_dc, D_dc_v), (D_ec, D_ec_v),
    (k_AS, k_AS_v), (k_DS, k_DS_v), (K_D, K_D_v), (R_gr, R_gr_v),
    (E_f, E_f_v), (M_fc, M_fc_v), (Md, Md_v), (M, M_v), (I_sl, I_sl_v),
    (I_ml, I_ml_v), (z, z_v)
    ])

v_dC_d = sol_C_d.subs([
    (Mm, Mm_v), (Em, Em_v), (V_D, V_D_v), (D_dc, D_dc_v), (D_ec, D_ec_v),
    (k_AS, k_AS_v), (k_DS, k_DS_v), (K_D, K_D_v), (R_gr, R_gr_v),
    (E_f, E_f_v), (M_fc, M_fc_v), (Md, Md_v), (M, M_v), (I_sl, I_sl_v),
    (I_ml, I_ml_v), (z, z_v)
    ])

v_dC_a = sol_C_a.subs([
    (Mm, Mm_v), (Em, Em_v), (V_D, V_D_v), (D_dc, D_dc_v), (D_ec, D_ec_v),
    (k_AS, k_AS_v), (k_DS, k_DS_v), (K_D, K_D_v), (R_gr, R_gr_v),
    (E_f, E_f_v), (M_fc, M_fc_v), (Md, Md_v), (M, M_v), (I_sl, I_sl_v),
    (I_ml, I_ml_v), (z, z_v)
    ])

v_dC_ew = sol_C_ew.subs([
    (Mm, Mm_v), (Em, Em_v), (V_D, V_D_v), (D_dc, D_dc_v), (D_ec, D_ec_v),
    (k_AS, k_AS_v), (k_DS, k_DS_v), (K_D, K_D_v), (R_gr, R_gr_v),
    (E_f, E_f_v), (M_fc, M_fc_v), (Md, Md_v), (M, M_v), (I_sl, I_sl_v),
    (I_ml, I_ml_v), (z, z_v)
    ])

v_dC_em = sol_C_em.subs([
    (Mm, Mm_v), (Em, Em_v), (V_D, V_D_v), (D_dc, D_dc_v), (D_ec, D_ec_v),
    (k_AS, k_AS_v), (k_DS, k_DS_v), (K_D, K_D_v), (R_gr, R_gr_v),
    (E_f, E_f_v), (M_fc, M_fc_v), (Md, Md_v), (M, M_v), (I_sl, I_sl_v),
    (I_ml, I_ml_v), (z, z_v)
    ])

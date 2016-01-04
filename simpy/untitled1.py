# -*- coding: utf-8 -*-
"""
Created on Tue Dec 29 11:56:58 2015

@author: nano

Script for sovling the steady state equations
"""

#from math import *
from sympy import *

# Model: SoilC

year = 31104000       # seconds in a year
month = 2592000       # seconds in a month
day = 86400           # seconds in a day
hour = 3600           # seconds in an hour
sec = 1               # seconds in a second!

'''
# Parameters
R = 0.008314             # [kJ K-1 mol-1] gas constant
Mm_ref = 0.00028 / hour * tstep  # [h-1] Microbe turnover rate
                                 # (Li at al. 2014, AWB model).
Em_ref = 0.001 / hour * tstep   # [h-1] Enzyme turnover rate
                                # (Li at al. 2014, AWB model).
Ep = 5.6e-06 / hour * tstep     # [gC g-1 MC h-1] Fraction of SC taken up
                                # that is converted to EC. (assumed).
V_D_ref = 1 / hour * tstep      # [h-1] Maximum speed of PC decomposition
                                # (Li at al. 2014, AWB model)
diff_D0 = 8.1e-10 / sec  * tstep   # [m2 s-1] Diffusivity in water for amino
                                # acids, after Jones et al. (2005); see also
                                # Poll et al. (2006). (Manzoni paper)
diff_EC0 = 8.1e-11 / sec  * tstep   # [m2 s-1] Diffusivity in water for enzymes.
                                # Vetter et al., 1998
ka.s.ref = 1.08e-6  / sec * tstep  # [m3 gC-1 s-1] Adsorption rate constant of
                                   # SCw. (Ahrens 2015, units converted for gC)
kd.s.ref = 1.19e-10 / sec * tstep   # [s-1] Desorption rate constant of SCs.
                                    # (Ahrens 2015)
K_D_ref = 300000        # [gC m-3] Affinity parameter for PC decomp. (Adjusted.
                        # As ref: Li at al. 2014, AWB model => 250 mg gSoil-1)
mcpc_f = 0.5            # [g g^-1] fraction of dead microbes going to SC
                        # (rest goes to PC)
T_ref = 293.15          # [K] reference temperature
E_V.U = 47             # [kJ mol^-1] Gibbs energy for V_U (Tang and Riley 2014)
E_V.D = 47              # [kJ mol^-1] Gibbs energy for V_D (average of
                        # lignin and cellulose in Wang et al. 2013)
E_K.U = 30             # [kJ mol^-1] Gibbs energy for K_U (Tang and Riley 2014)
E_K.D = 30             # [kJ mol^-1] Gibbs energy for K_D (Tang and Riley 2014)
E_ka = 10              # [kJ mol^-1] Gibbs energy for SC adsorption/desorption
                       # fluxes (Tang and Riley 2014)
E_kd = 10              # [kJ mol^-1] Gibbs energy for EC adsorption/desorption
                       # fluxes (Tang and Riley 2014)
E_mm = 47              # [kJ mol^-1] Gibbs energy for Mm (Hagerty et al. 2014)
E_em = 47              # [kJ mol^-1] Gibbs energy for Em (Hagerty et al. 2014)
CUE_ref = 0.7          # Carbon use efficieny (= microbial growth efficiency)
                       # (Hagerty et al.)
CUE_s = -0.016         # CUE slope with temperature
pd = 2.7               # [g cm^-3] Soil particle density
E_frac = 0.01              # [g g-1] Fraction of SC taken up that is
                       # converted to EC. (fitted).
psi_Rth = 15000        # [kPa] Threshold water potential for microbial
                       # respiration (Manzoni and Katul 2014)
psi_fc = 33            # [kPa] Water potential at field capacity
dist = 10^-7           # [m] characteristic distance between substrate and
                       # microbes (Manzoni manus)
'''

C_P, C_D, C_A, C_Em, C_Ew, CO2 = symbols('C_P C_D C_A C_Em C_Ew CO2')

R, Mm_ref, Em_ref, Ep, V_Dref, diff_D0, diff_EC0, k_ASref, k_DSref, K_Dref, \
    mcpc_f, T_ref, E_VU, E_VD, E_KU, E_KD, E_ka, E_kd, E_mm, E_em, CUE_ref, \
    CUE_s, pd, E_frac, psi_Rth, psi_fc, dist = symbols('R Mm_ref Em_ref Ep \
    V_Dref diff_D0 diff_EC0 k_ASref k_DSref K_Dref mcpc_f T_ref E_VU E_VD E_KU \
    E_KD E_ka E_kd E_mm  E_em CUE_ref CUE_s pd E_frac psi_Rth psi_fc dist')

T, M, lit_str, lit_met, clay, silt, sand, ps, depth = \
    symbols('T M lit_str lit_met clay silt sand ps depth')

b = 2.91 + 15.9 * clay
psi_sat = exp(6.5 - 1.3 * sand) / 1000
Rth = ps * (psi_sat / psi_Rth)**(1 / b)
fc = ps * (psi_sat / psi_fc)**(1 / b)
Md = 200 * (100 * clay)**0.6 * pd * (1 - ps)


def T_resp_eq(k_ref, T, T_ref, E, R):
    return k_ref * exp(-E/R * (1/T-1/T_ref))

K_D = T_resp_eq(K_Dref, T, T_ref, E_KD, R)
k_AS = T_resp_eq(k_ASref, T, T_ref, E_ka, R)
k_DS = T_resp_eq(k_DSref, T, T_ref, E_kd, R)
V_D = T_resp_eq(V_Dref, T, T_ref, E_VD, R)
Mm = T_resp_eq(Mm_ref, T, T_ref, E_mm, R)
Em = T_resp_eq(Em_ref, T, T_ref, E_em, R)
CUE = CUE_ref

diff_mod = (ps - Rth)**1.5 * ((M - Rth)/(ps - Rth))**2.5
diff_DC = diff_D0 * (C_D - 0) * diff_mod / dist
diff_EC = diff_EC0 * (C_Em - C_Ew) * diff_mod / dist

F_slpc = lit_str
F_mldc = lit_met
F_pcdc = (V_D * (C_Ew / (M * depth)) * (C_P / depth * Min(1, M / fc))) / (K_D +
         (C_P / depth * Min(1, M / fc))) * depth
F_dcac = (C_D / (depth * m)) * (Md - C_A) * Min(1, M / fc) * k_AS * depth
F_acdc = C_A * Min(1, M / fc) * k_DS
F_dcco2 = diff_DC * (1 - CUE)
F_dcpc = diff_DC * CUE * (1 - E_frac)
F_dcecm = diff_DC * CUE * E_frac
F_ecmecw = diff_EC
F_ecwdc = C_Ew * Em
F_ecmdc = C_Em * Em


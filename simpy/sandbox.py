# -*- coding: utf-8 -*-
from __future__ import division
import sympy as sy
# from math import exp

RL, R = sy.symbols('RL, R')

F_dcac = ((C_d / (z * M)) * ((Md - (C_a / z)) * M_fc) *
          k_AS * z)
F_acdc = C_a * M_fc * k_DS

ka = 1.08e-6
kd = 1.19e-10
K = ka/kd

L = v_dC_d

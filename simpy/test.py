# -*- coding: utf-8 -*-
"""
Created on Mon Feb 22 14:52:39 2016

@author: nano
"""

# -*- coding: utf-8 -*-
from __future__ import division
import sympy as sy
# from math import exp

# Define symbols
kb, T1, T2, pi, rad = sy.symbols('kb T1 T2 pi rad')

# Define constants
k_B = 1.38064852 * 10**(-23)
p = 3.14159265359
r = 0.00000001


exp1 = kb*T1/(6 * pi * 1.95 * 10**14 * T1**(-7) * r)
exp2 = kb*T2/(6 * pi * 1.95 * 10**14 * T2**(-7) * r)
exp3 = exp2 / exp1
exp3.subs([(T1, 283), (T2, 293)])
exp1.subs(T1, 293)

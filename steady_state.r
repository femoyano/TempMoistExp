# steady state calculation

PC_ss = -Em_ref * K_D_ref * (litter_pc[1] * (Mm_ref * (1 + CUE_ref * (mcpc_f - 1)) + E_p * (1 - CUE_ref)) + CUE_ref * litter_sc * mcpc_f * Mm_ref) / 
  (litter_pc[1] * (Mm_ref * (Em_ref * (1 + CUE_ref * (mcpc_f - 1))) + E_p * (Em_ref * (1 - CUE_ref) - CUE_ref * V_D_ref)) + CUE_ref * litter_sc[1] * (mcpc_f * Mm_ref * Em_ref - E_p * V_D_ref))
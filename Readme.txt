Test_2

3 Options for decomposition:
- 1st: first order: V * C_P
- 2nd: second order: V * C_P * C_E
- MM: Michaelis-Menten: V * C_P * C_E / (K + C_P)

3 Options for uptake:
- 1st: equal to diffusion: diff
- 2nd: second order: V * diff * C_M
- MM: Michaelis-Menten: V * diff * C_M / (K + diff)

submit with:
bsub -a openmp -q fat -W 10:00 -o RUN-%J.out -n 30 -R span[hosts=1] Rscript --slave run_optim_smp.R
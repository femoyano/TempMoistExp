load("../NadiaTempMoist/parsets/pars_test1.Rdata")
pars_test <- pars_test1

# changes based on run4	09f1dc61:
pars_test["D_0"] <- 0.4 # 0.36
pars_test["E_K"] <- 90 # 50
pars_test["E_V"] <- 90
pars_test["f_CA_bf"] <- 0.3 # 0.96
pars_test["f_CA_mz"] <- 0.3 # 0.96
pars_test["f_CD"] <- 0.001
pars_test["f_CE"] <- 0.00001
pars_test["f_CM"] <- 0.001
pars_test["f_ep"] <- 0.2 # 0.2
pars_test["f_gr_ref"] <- 0.8
pars_test["f_mr"] <- 0.9 # 0.9
pars_test["K_D_ref"] <- 40000 # 500000
pars_test["K_U_ref"] <- 10 # 10
pars_test["r_ed_ref"] <- 0.001
pars_test["r_md_ref"] <- 0.001
pars_test["V_D_ref"] <- 0.1 # 19.5
pars_test["V_U_ref"] <- 3 # 19.5
pars_test["psi_Rth"] <- 17000 # 16900

prefix <- "0"

source("run_smp.R")

# parset5 <- pars_new
# save(parset5, file = "../NadiaTempMoist/parsets/parset5.Rdata")
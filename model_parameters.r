# model_parameters.r

# Documentation ====
# All fixed parameters and constants should be listed here.
# Variables calculated from input data (e.g. theta_fc, ..) are in main.
# Warning: time variables and tstep have to be defined before sourcing this file.

parameters <- c(
    
  ### Known Constants ====
  R   = 8.3144,  # [J K-1 mol-1] gas constant
  
  ### Spatial Variables
  clay   <-  0.30   # [g g^-1] clay fraction values 
  sand   <-  0.30   # [g g^-1] sand fraction values 
  silt   <-  0.40   # [g g^-1] silt fraction values 
  depth  <-  0.30 # [m] soil depth
  
  ### Time Dependent Parameters
  Em       = 0.006 / day * tstep    , # [d-1] Enzyme turnover rate (Hagerty et al. 2014, value for mineral soils at 0C; 0.04 at 10-15C as in Allison 2006)
  Mm       = 0.006 / day * tstep    , # [d-1] Microbe turnover rate (Hagerty et al. 2014, value for mineral soils at 0C)
  V_LD_T0  = 0.0058 / day * tstep   , # [d^-1] Maximum speed of LD decomposition. Based on the two pool litter model of Adair et al. 2008. Similar magnitude as in Zhang et al. 2008, Cotrufo et al. in Soil Carbon Dynamics 2009
  V_RD_T0  = 0.000768 / day * tstep , # [d^-1] Maximum speed ofRC decomposition. Based on the two pool litter model of Adair et al. 2008. Similar magnitude as in Zhang et al. 2008, Cotrufo et al. in Soil Carbon Dynamics 2009
  V_SU_T0  = 10.93 / day * tstep    , # [d^-1] Maximum speed of microbial uptake of SC
  
  ### Fixed Parameters ====
  psi_Rth  = 15000   , # [kPa] Threshold water potential for microbial respiration (Manzoni and Katul 2014)
  psi_fc   = 33      , # [kPa] Water potential at field capacity
  K_LD_T0  = 200     , # [gC] Affinity parameter for LC decomp. (k_ES in Tang and Riley 2014)
  K_RD_T0  = 200     , # [gC] Affinity parameter for RC decomp. (k_ES in Tang and Riley 2014)
  K_SU_T0  = 1       , # [gC] Affinity parameter for microbial SC uptake (k_BC in Tang and Riley 2014)
  K_SS_T0  = 25      , # [gC] Affinity parameter for SC sorption (k_MC in Tang and Riley 2014)
  K_ES_T0  = 50      , # [gC] Affinity parameter for EC sorption (k_ME in Tang and Riley 2014)
  D_S0     = 8.1e-10 / sec * tstep  , # [m s^-1] Diffusivity in water for amino acids, after Jones et al. (2005); see also Poll et al. (2006). (Manzoni paper)
  D_E0     = 8.1e-11 / sec * tstep  , # [m s^-1] Diffusivity in water for enzymes. Vetter et al., 1998
  P_E      = 0.01    , # [d^-1] Fraction of MC converted to EC. Intermediate value between Schimel & Weintraub 2003 and Allison et al. 2010 (!uncertain!)
  delta    = 10^-4   , # [m] characteristic distance between substrate and microbes (Manzoni manus)
  mcsc_f   = 0.5     , # [g g^-1] fraction of dead microbes going to SC (rest goes to LC)
  t_MC     = 0.05    , # [g g^-1] scalar for transporter fraction of MC (Tang and Riley 2014)
  T0       = 290     , # [K] reference temperature
  E_V.SU   = 45000   , # [J mol^-1]  Gibbs energy for V_SU (Tang and Riley 2014)
  E_V.LD   = 37000   , # [J mol^-1]  Gibbs energy for V_LD (Wang et al. 2013)
  E_V.RD   = 53000   , # [J mol^-1]  Gibbs energy for V_RD (Wang et al. 2013)
  E_K.SU   = 15000   , # [J mol^-1]  Gibbs energy for K_SU (Tang and Riley 2014)
  E_K.LD   = 15000   , # [J mol^-1]  Gibbs energy for K_LD (Tang and Riley 2014)
  E_K.RD   = 15000   , # [J mol^-1]  Gibbs energy for K_RD (Tang and Riley 2014)
  E_K.EM   = 10000   , # [J mol^-1]  Gibbs energy for K_EM (Tang and Riley 2014)
  E_K.SM   = 10000   , # [J mol^-1]  Gibbs energy for K_SM (Tang and Riley 2014)
  M_spec   = 0.0017    # [gC gSoil^-1] Specific maximum mineral surface capacity for sorption (Mayes et al. 2012)
  
  # Calculate spatial variables ====
  phi        <- 0.5                        , # [m3 m^-3] Assumed pore space - Alternatively: obtain from land model
  dens_min   <- 1600000                    , # [g m^-3] assumed mineral density
  M          <- M_spec * depth * dens_min * (1 - phi) , # [gC] Total C-equivalent mineral surface for sorption
  b          <- 2.91 + 15.9 * clay         , # [] b parameter (Campbell 1974) as in Cosby  et al. 1984 - Alternatively: obtain from land model.
  psi_sat    <- exp(6.5-1.3 * sand) * 1000 , # [kPa] saturation water potential (Cosby et al. 1984 after converting their data from cm H2O to Pa) - Alternatively: obtain from land model.
  theta_Rth  <- phi * (psi_sat / psi_Rth)^(1 / b) , # [kPa] Threshold water content for mic. respiration (water retention formula from Campbell 1984)
  theta_fc   <- phi * (psi_sat / psi_fc)^(1 / b)    # [kPa] Field capacity water content (water retention formula from Campbell 1984) - Alternatively: obtain from land model.
)
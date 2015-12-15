#### GetInitial

#### Documentation ==========================================================
# Function to extract initial values from a dataframe for model runs
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ========================================================================

GetInitial <- function(init) {
  c(
    PC  = init$PC[1]  ,
    SCw = init$SCw[1] ,
    SCs = init$SCs[1] ,
    ECw = init$ECw[1] ,
    ECm = init$ECm[1] ,
    MC = init$MC[1] ,
    CO2 = 0
  )
}
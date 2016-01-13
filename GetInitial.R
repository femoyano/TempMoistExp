#### GetInitial

#### Documentation ==========================================================
# Function to extract initial values from a dataframe for model runs
# author(s):
# Fernando Moyano (fmoyano #at# uni-goettingen.de)
#### ========================================================================

GetInitial <- function(init) {
  c(
    C_P  = init$C_P[1]  ,
    C_D = init$C_D[1] ,
    C_A = init$C_A[1] ,
    C_Ew = init$C_Ew[1] ,
    C_Em = init$C_Em[1] ,
    C_M = init$C_M[1] ,
    C_R = 0
  )
}
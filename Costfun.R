Costfun <- function(params) 
  {with(as.list(params),
      {
        init_values <- # obtain initial values
        outtimes <- as.vector(data$time) # define output times to be data times
        outmodel <- # get model results by calling ode(init_values, outtimes, Model_desolve, params)
        costt       <- sum((outmodel[,var1] - data$var1)^2)
        return(costt)
      })
}


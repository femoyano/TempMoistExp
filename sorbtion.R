# Script for a numerical solution to a second order reaction.
# Dissolved C (DOC) concentrations are kept constant for a simulation
# Surface reaction sites are taken up as C is sorbed
# Equilibrium values (assymptote) depend on the reaction rate constants,
# the [DOC], and the total mineral surface.

rm(list=ls())
minsf <- 100
free.minsf <- 100
doc.sor <- 0
doc.dis <- 10
ks <- 0.001
kd <- 0.001

F <- 1
i <- 1
while (F > 0.0001) {
  Fs <- doc.dis * free.minsf * ks
  Fd <- doc.sor[i] * kd
  if (Fs > doc.dis) Fs <- doc.dis
  F <- Fs - Fd
  if (F > free.minsf) F <- free.minsf
  doc.sor[i + 1] <- doc.sor[i] + F
  free.minsf <- minsf - doc.sor[i + 1]
  i <- i + 1
}

plot(doc.sor, ylim=c(0,minsf))
tail(doc.sor)
doc.sor[i]/minsf # = surface coverage
ks*doc.dis/(ks*doc.dis + kd) # = surface coverage; from wikipedia 'Reactions on surfaces' term to calculate equilibrium assuming steady state

---
output: html_document
---
General Notes on Coding and Model Development

#### How to implement effects of diffusion, concentrations and disconnection in order to reflect realistic processes and effects such as priming?

One thing to consider are mechanisms that lead to changes in the ratio of decomposition and uptake/respiration rates as soil dries (the term decoupling is probably not correct since they remain coupled but the rates ratio changes).

The change in rate ratios of decomposition and respiration may result from:
- a disconnection effect, either by increasing the diffusion distance or simply through a factor reducing the uptake of the diffused SC. For example using the uptake limitation from the Manzoni paper.
- If uptake is assumed not to be affectred by concentrations (no positive effect with low water), is is the current case.

Decomposition and uptake are affected by water changes in two ways: concentration changes and diffusion limitation. Uptake may be additionally affected as described above (uptake modifier), representating a physiological effect.


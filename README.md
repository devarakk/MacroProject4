# MacroProject4
**Part 1**

The Dynare implementation for a Real Business Cycle (RBC) DSGE model featuring monopolistic competition, capital accumulation, and productivity shocks. The model simulates the impact of a temporary anticipated technology shock (Z=0.1) occurring in periods 1–5 over a 100-period horizon. It uses a foresight solver in Dynare to trace impulse response functions (IRFs) for key macroeconomic variables, including consumption, output, capital, and labor. The model includes standard equilibrium conditions such as the Euler equation, labor-leisure tradeoff, capital accumulation, and firm pricing under monopolistic competition.

**Part 2**

Data sources were taken from IPUMS-CPS, from the Basic Monthly Survey for 2015 - 2025 and primarily on the emp-stat variable. Data was extracted through dat and ddi files. Instructions from https://cps.ipums.org/cps/extract_instructions.shtml were followed to pull the data through R. Follow the R code to create categories for employment, non-employment, and unemployment. A data panel was created to calculate monthly transition rates, unemployment, and non-employment rates. This was used to create monthly line plots.

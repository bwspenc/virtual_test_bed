# Subchannel model for the Toshiba 37-pin benchmark

*Contact: Mauricio Tano, mauricio.tanoretamales.at.inl.gov*

## Benchmark Description

The Toshiba 37-pin benchmark is based on liquid sodium experiments conducted by the Toshiba Corporation Nuclear Engineering Laboratory in Japan [!citep](namekawa1984buoyancy).
Its assembly consists of four outer rings of electrically heated rods.
However, the resistances in the electrically heated rods are adapted to reproduce a chopped cosine power distribution in the axial direction.
All heating rods are assumed to have the same power distribution.
The cross section of the fuel assembly is presented in [configuration].
In this figure the numbering of the rods and the subchannels are described.
The analyzed quantity of interest is the temperature distribution at the outlet of the assembly.
Due to symmetry, it is enough to analyze the temperature distributions over a symmetry line.
In this case, following experiment reported results, we take a south-to-north line in the fuel assembly.
This one involves, in south to north ordering, subchannels 72, 49, 32, 20, 10, 4, 3, 2, 1, 7, 14, 26, 39, and 58.

!media subchannel/toshiba_37_config.png
       style=width:80%
       id=configuration
       caption= Rod and subchannel positions and numbering adopted for the Toshiba 37-pin benchmark. (a) Position and numbering of the heated rods with the subchannel center indicated with red dots. (b) Center position and numbering of the suchannels.

The characteristics of Toshiba's benchmark are provided in [parameters].

!table id=parameters caption=Design and operational parameters for Toshiba's 37-pin benchmark.
| Experiment Parameter (unit) | Value  |
| :- | :- |
| Number of pins (-) | 37 |
| Rod Pitch (cm) | 0.787 |
| Rod Diameter (cm) | 0.650 |
| Wire wrap diameter (cm) | 0.132 |
| Wire wrap axial pitch (cm) | 30.70 |
| Flat-to-flat duct distance (cm) | 5.04 |
| Inlet length (cm) | - |
| Heated length (cm) | 93.00 |
| Outlet length (cm) | - |
| Outlet pressure (Pa) | 1.01E5 |
| Inlet Temperature (K) | Experiment dependent |
| Power profile (-) | Chopped cosine (peaking factor 1.21) |



Three flow configurations with reducing axial mass flow rate are selected for the validation exercise. These configurations are presented in [cases].

!table id=cases caption=Validation cases selected in the Toshiba benchmark
| Naming | Run ID | Rod Power (W/cm) | Inlet temperature ($K$) | Flow rate (m$^3$/s) | Reynolds number |
| :- | :- | :- | :- | :- | :- |
| High flow rate | B37P02 | 15.57 | 484.3 | 1.48E-03 | 1.12E4 |
| Medium flow rate | 0C37P06 | 11.92 | 476.5 | 3.34E-04 | 2.81E3 |
| Low flow rate | E37P13 | 3.89 | 479.4 | 1.07E-04 | 7.39E2 |

## Subchannel Input

### General Parameters

The general parameters on the experimental conditions are described here below.
They set up the boundary conditions for the high-flow-rate test case.

```language=bash

 T_in = 660
# [1e+6 kg/m^2-hour] turns into kg/m^2-sec
mass_flux_in = ${fparse 1e+6 * 37.00 / 36000.*0.5}
P_out = 2.0e5 # Pa

```

### Mesh

The meshing in subchannel uses a custom *TriSubChannelMeshGenerator*.
This generates a mesh of 1D channel segments connected in 3D.
The subchannel positions are automatically generated by specifying the number of radial rings, the flat to flat distance of the duct, and the rod pitch.
The number of axial cells in which the domain is discretized is specified by *n_cells*.
For more information about the mesh generator, please consult the website documentation on subchannel.

!listing sfr/subchannel/toshiba_37_pin/toshiba_37_pin.i block=TriSubChannelMesh language=cpp

### Variables

This block defines the subchannel variables for the subchannel solve.
All variables must be present at every input for the subchannel solver to run.

!listing sfr/subchannel/toshiba_37_pin/toshiba_37_pin.i block=AuxVariables language=cpp

### Fluid Properties

The fluid properties block specifies the thermophysical properties used in the subchannel solve.
Sodium properties are used in this case.

!listing sfr/subchannel/toshiba_37_pin/toshiba_37_pin.i block=FluidProperties language=cpp

### Problem

The problem type specifies the solver to be used in the subchannel solve.
The type of problem used in this case is a liquid metal subchannel problem that uses sodium fluid properties.
The parameters *beta* and *C_T* are used to model the crossflow and cross enthalpy-fluxes.
Different solve procedures can be applied.
In this case, we use an implicit, monolithic solve.

!listing sfr/subchannel/toshiba_37_pin/toshiba_37_pin.i block=Problem language=cpp

### Initial Conditions

This block specifies the initial conditions for the *AuxVariables* utilized in the subchannel solve.
The linear heat flux initialization requires an external file that defines the relative power per fuel pin.
In this case, this file is named "pin_power_profile_37.txt"

!listing sfr/subchannel/toshiba_37_pin/toshiba_37_pin.i block=ICs language=cpp

### Auxiliary Kernels

Auxiliary kernels are used to apply the boundary conditions on pressure, temperature, and mass flow rate.

!listing sfr/subchannel/toshiba_37_pin/toshiba_37_pin.i block=AuxKernels language=cpp

### Executioner

The executioner can be *Steady* or *Transient*.
The tolerances which are set in the `[Executioner]` block are not used in the subchannel problem.

!listing sfr/subchannel/toshiba_37_pin/toshiba_37_pin.i block=Executioner language=cpp

### MultiApp system

A *MultiApp* is used for transferring the subchannel solution into a detailed mesh for visualization.

!listing sfr/subchannel/toshiba_37_pin/toshiba_37_pin.i block=MultiApps language=cpp

A custom transfer, *MultiAppDetailedSolutionTransfer*, is used for this purpose.

!listing sfr/subchannel/toshiba_37_pin/toshiba_37_pin.i block=Transfers language=cpp

The detailed mesh uses a *DetailedTriSubChannelMeshGenerator* and the solution variables are populated by the transfer.

!listing sfr/subchannel/toshiba_37_pin/toshiba_37_pin.i block=viz language=cpp

## Results

An example flow distribution for the high flow-rate case is depicted in [3Dres].
The figures have been scaled by 0.25 in the axial direction.
As graphically observed, a flat temperature profile is obtained in the bulk of the fuel assembly.
In this experiment, the ratio of gap-distance to pitch produces a significantly larger mass flow in the outer subchannels as observed in Figure 2a.
This causes the outer subchannnels to be significantly colder than the center ones.
Thus, the expected temperature distribution is flat in the central region of the assembly with sharp drops next to the wrapper.
Finally, it can be observed in Figures 2a and 2b that due to the significant difference between flow rates at the outer and center subchannel, there is a considerable flow development length in the entry to the fuel assembly.
Inlet velocity conditions were unclear in the experiment report [!citep](namekawa1984buoyancy) and, hence, uniform mass flow at the inlet was assumed.
If the assumption of uniform inlet flow rates turns out to be incorrect, a small deterioration of accuracy of the predicted outlet temperature can be expected.
However, we observe that the flow rates fully develop before the outlet of the assembly, which suggests that this initial condition will have little effect over the analyzed temperature distribution at the outlet of the fuel assembly.

!media subchannel/toshiba_37_results_3D.png
       style=width:85%
       id=3Dres
       caption=  Example of simulation results for the high-flow test case in the Toshiba 37-pin benchmark. (a) Distribution of axial mass flow. (b) Distribution of lateral mass flow. (c) Distribution of temperature. (d) Distribution of dynamic viscosity due to heating.

The results obtained for the high-, medium-, and low- flow-rate validation cases are presented in [plots].
We compare the results obtained with the present code with the ones obtained in the experiments and the SUBAC code [!citep](sun2018development).
We have selected SUBAC for the code-to-code comparison since it is to our knowledge the subchannel code for wire-wrapped SFRs, with openly available results, that presented the best agreements between the code predictions and the experiment measurements for the current benchmark.


!media subchannel/toshiba_37_results_plots.png
       style=width:65%
       id=plots
       caption=  Comparison of results obtained for Toshiba 37-pin case between experimental measurements, the SUBAC code, and the current code. (a) High mass flow case. (b) Medium mass flow case. (c) Low mass flow case.

As observed in [plots], for the high mass flow rate case, the present model predicts results closer to the experimental results than SUBAC. This is expected, since the turbulent cross-flow calibration should still improve the prediction for the present case.
However, when comparing the results predicted for the medium- and low-flow-rate cases in Figures 3b and 3c, respectively, we observe that our models over-predict the temperature distributions when compared to SUBAC.
Further analysis determined that the more peaked distribution of temperatures predicted by `Pronghorn-subchannel` towards the center of the assembly may be
produced by an over-prediction of the mixing rates, which yields larger than expected flows in the outer channels.

!alert note
Sample output for this model, in the gold folder, is hosted on LFS.
Please refer to [LFS instructions](resources/how_to_use_vtb.md#lfs) to download it.
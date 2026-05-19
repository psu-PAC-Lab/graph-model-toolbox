# Quick Start

## Installation

Add the toolbox folder to your MATLAB path:

```matlab
addpath('path/to/gmt-toolbox')
```

## Build Your First Model

A single hydraulic tank with a supply flow input and a passive drain.

```matlab
%% 1. Define vertices
V1 = gmt_Vertex("Tank Pressure", "C*x_dot", "Units", "Pa");

%% 2. Define edges
E1 = gmt_Edge("Supply Flow",   "u",                "External", true);
E2 = gmt_Edge("Drain Orifice", "Cd*A*sqrt(xh)");

%% 3. Edge matrix: each row is [tail, head]. Index 0 = ground node.
EM = [0, 1;   % supply → tank
      1, 0];  % tank → drain

%% 4. Define parameters and inputs
params = [gmt_Parameter("Capacitance", "C",  1e-10, "Units", "m^3/Pa"), ...
          gmt_Parameter("Cd",          "Cd", 0.62), ...
          gmt_Parameter("Area",        "A",  1e-4,  "Units", "m^2")];

inputs = gmt_Input("u", "Supply mass flow rate", "Units", "kg/s");

%% 5. Build the graph model
model = gmt_Graph("Tank", EM, [E1, E2], [V1], params, [inputs], []);
```

## Inspect

```matlab
model.gmt_ReportFull        % print all tables
gmt_Plotting(model)         % interactive graph plot
```

## Simulate

```matlab
model = model.gmt_InitCon([101325]);            % initial pressure (Pa)
model = model.gmt_BuildSim("./generated/tank"); % write ODE files to disk
```

See [Simulating Systems](Simulating-Systems) for how to run the generated files, and [Core Concepts](Core-Concepts) for the theory behind the model structure.

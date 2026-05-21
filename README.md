# GMT — Graph-Based Modeling Toolbox

A MATLAB toolbox for energy component and system modeling using a directed graph formalism. The toolbox represents energy systems as directed graphs, automatically derives symbolic system equations, and generates simulation-ready MATLAB code. An optional Simulink block is provided for users who prefer a graphical modeling interface.

## Overview

GMT models dynamical energy systems using a graph formalism where **vertices** represent energy storage elements (states) and **edges** represent power flows between them. From the graph topology, edge, vertex, parameter, input, and port defintions the toolbox automatically derives symbolic expressions for the system equations. Component models can be created individually and then combined into full system models through port connections.

Key capabilities:
- Construct component models from directed graph topology, edge, and vertex defintions
- Construct system models by combining component models together via port connections
- Visualize graph topology with interactive digraph plots
- Analyze model data through built-in reporting features
- Auto-generate symbolic system equations from component and system models
- Auto-generate MATLAB simulation functions and scripts
- Auto-generate linearized state-space matrices (`A`, `B`, `Z`) via first-order Taylor expansion
- Available simulink block for graphical modeling interface
- Support analytical and numerical (lookup table / neural network) parameterization

## Requirements

- MATLAB R2025b. Backwards compatibility is handled by the toolbox package.
- Symbolic Math Toolbox
- Simulink Stateflow
- Verified on macOS and Windows.

## Installation

1. Download the `gmt.mltbx` toolbox file.
2. Double-click the file in MATLAB or run:

```matlab
matlab.addons.install('gmt.mltbx')
```

The toolbox will be added to your MATLAB Add-Ons automatically. To verify installation, check **Home → Add-Ons → Manage Add-Ons**.

## Core Classes

| Class | Constructor | Description |
|-------|-------------|-------------|
| `gmt_Graph` | `gmt_Graph(Name, EdgeMatrix, Edges, Vertices, Parameters, Inputs, Ports, ...)` | Superclass for all graph-based models. Stores topology, equations, parameters, and simulation code. |
| `gmt_Edge` | `gmt_Edge(EdgeName, EdgeEq)` | Defines a directed edge (power flow). Use `xt`/`xh` for tail/head vertex states. Optional: `"External", true`. |
| `gmt_Vertex` | `gmt_Vertex(VertexName, CapacitanceEq)` | Defines a vertex (energy storage node or boundary condition). Optional: `"External", true`, `"Units", "..."`. |
| `gmt_Parameter` | `gmt_Parameter(Description, Variable, Data)` | Defines a model parameter — scalar, expression, lookup table, or neural network. Optional: `"Units", "..."`, `"Common", true`, `"Optimization", true`. |
| `gmt_Input` | `gmt_Input(VariableName, Description)` | Defines a control input variable. Optional: `"Units", "..."`, `"DependencyFormula", "..."`. |
| `gmt_Port` | `gmt_Port(PortType, ElementNumber, EnergyDomain)` | Defines a component connection port. `PortType`: `"EdgeConnection"` or `"VertexConnection"`. |

## Component Library

The toolbox includes pre-built component models, each implemented as a subclass of `gmt_Graph`:

| Component | Energy Domain | Description |
|-----------|----------------------|-------------|
| `gmt_Tank` | Thermal - Single Phase |Fluid Storage Tank|
| `gmt_HeatLoad` | Thermal - Single Phase | Fluid Heat Load Junction |
| `gmt_HeatExchanger` | Thermal - Single Phase | Single Wall Heat Exchanger|
| `gmt_SplitJunction(Name, nIn, nOut)` | Thermal - Single Phase | Configurable Fluid Junction |
| `gmt_DCMotor` | Electrical | DC Motor Thermal & Electrical |
| `gmt_Inverter` | Electrical | Inverter Thermal & Electrical |
| `gmt_Battery` | Electrical | Battery Thermal & Electrical W/ Built-In Configurations |

> **Note:** The component library is under active development. Additional components will be added over time.

Instantiate a component directly using its name. As a best practice, the workspace object name should match the component description name.

```matlab
MainTank = gmt_Tank('MainTank');
MainTank.gmt_ReportFull
MainTank.gmt_PlotGraph
```

## Quick Start

### Model Reports 

GMT provides built-in reports for analyzing model data. These reports can be accessed by calling the following report methods on any component or system model object:

```matlab
model.gmt_ReportFull        % all tables: graph, parameters, inputs, ports
model.gmt_ReportGraph       % vertices and edges only
model.gmt_ReportParameter   % parameters
model.gmt_ReportInitCon     % state variables and initial conditions
model.gmt_PlotGraph         % interactive directed graph plot
```

### Setting Initial Conditions

Initial conditions may be added after the model has been instantiated using the following syntax:

```matlab
% One value per internal state, in the order shown by gmt_ReportInitCon
model = model.gmt_InitCon([300, 6000]);
```

Alternatively, initial conditions may be specified during model instantiation using the following syntax:

```matlab
% One value per internal state, in the order shown by gmt_ReportInitCon
model = gmt_model('model','InitCon',[300, 6000]);
```

### Generating Simulation Code

Commandline simulation files may be generated after the model has been instantiated using the following syntax:

```matlab
model = model.gmt_BuildSim('path/to/output/folder');
% Creates:
%   sysFun_<ModelName>.m            — ODE function: xdot = f(t, x, u)
%   sysFun_<ModelName>SimScript.m   — ready-to-run simulation script
%   sysObj_<ModelName>.mat          — saved model object
```

Alternatively, commandline simulation files may be generated during model instantiation using the following syntax:

```matlab
model = gmt_model('model',"BuildSim",'path/to/output/folder');
% Creates:
%   sysFun_<ModelName>.m            — ODE function: xdot = f(t, x, u)
%   sysFun_<ModelName>SimScript.m   — ready-to-run simulation script
%   sysObj_<ModelName>.mat          — saved model object
```

### Building a System Model

```matlab
% Define connection structure — each row is one port connection.
% Primary object's equation takes precedence at each merge point.
PrimaryObj   = {CompA; CompB};
SecondaryObj = {CompB; CompC};
ObjectArray  = {PrimaryObj, SecondaryObj};
PortArray    = [2, 1;   % CompA port 2 ↔ CompB port 1
                1, 2];  % CompB port 1 ↔ CompC port 2

sys = gmt_Graph.gmt_Combine('SystemName', ObjectArray, PortArray);

% Input dependencies are not resolved automatically — define them after combining
sys.gmt_ReportInput
sys = sys.gmt_InputCommon(["u2", "(u7+u9)"; "u1", "u8"]);
```

### Updating Parameters

The following methods are provided to update model parameters for model instances that have already been instantiated in the workspace:

```matlab
model = model.gmt_ParamVals(["C", "2e-10"; "Cd", "0.62"]);  % update values
model = model.gmt_ParamOpt(["Kv", "true"]);                  % set optimization flags
model = model.gmt_ParamCommon(["R1", "R_shared"]);           % share across components
```

### Linearization

The following method applies a first-order Taylor series linearization to a model that has already been instantiated in the workspace:

```matlab
[A, B, Z] = model.gmt_ControlModel();                        % symbolic
[A, B, Z] = model.gmt_ControlModel('Simplify', true);        % simplified
[A, B, Z] = model.gmt_ControlModel('NumSub', true);          % numerical
[A, B, Z] = model.gmt_ControlModel('Discrete', 0.01);        % discrete-time (ZOH)
```

`Z` is an affine offset that linearizes the full nonlinear dynamics without requiring state derivative variables.

## Tutorial

See `gmtTutorial.mlx` for a live-script walkthrough covering:

- Creating and inspecting a single-tank component model
- Setting initial conditions and generating simulation code
- Running commandline simulations
- Linearizing nonlinear model
- Building a dual fuel tank FTMS model (based on Doman 2016)
- Matching inputs across components

## Documentation

Full documentation is available in the repository Wiki:

- [Quick Start](wiki/Quick-Start)
- [Core Concepts](wiki/Core-Concepts)
- [Toolbox Classes](wiki/Toolbox-Classes)
- [Model Interaction](wiki/Model-Interaction)
- [Component Library](wiki/Component-Models)
- [Creating Systems](wiki/Creating-Systems)
- [Simulating Systems](wiki/Simulating-Systems)
- [Creating Components](wiki/Creating-Components)

## References

[1] D. B. Doman, "Fuel flow control for extending aircraft thermal endurance part I: underlying principles," in *AIAA SciTech 2016 Forum*, San Diego, CA, USA, Jan. 2016.

## Code Base Contributors

| Name | Affiliation |
|------|-------------|
| Joseph Pisani | Penn State University |
| Hershcel Pangborn  | Penn State University |
| Jacoab Siefert  | Penn State University | 
| Christopher Askland | University of Illinois Urbana-Champaign |
| Philip Renkert | University of Illinois Urbana-Champaign |

## Citation

Use of this toolbox in published research should be cited as follows:

```
[Your citation here]
```

## License

This project is licensed under the [MIT License](LICENSE).

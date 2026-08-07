This tutorial follows the `gmtTutorial.mlx` MATLAB Live Script included with the toolbox. It covers two workflows:

1. [Single-component model](#part-1-single-component-model) — using a pre-built `gmt_Tank` component
2. [Multi-component system model](#part-2-multi-component-system-model) — combining tanks, heat loads, and junctions into a fuel system

---

## Part 1: Single-Component Model

### Creating a Component

```matlab
close all; clear all; clc

MainTank = gmt_Tank("MainTank")
```

This creates a `gmt_Tank` object with default parameters. It is a subclass of `gmt_Graph` and inherits all graph-model methods.

### Inspecting the Model

```matlab
MainTank.gmt_ReportInitCon   % state variables and current initial conditions
MainTank.gmt_ReportFull      % all tables: vertices, edges, parameters, inputs, ports
MainTank.gmt_PlotGraph       % interactive directed graph plot
```

### Setting Initial Conditions

```matlab
% After creation
MainTank = MainTank.gmt_InitCon([300, 6000])

% At creation time
MainTank = gmt_Tank("MainTank", "InitCon", [300, 6000])
```

The vector length must match the number of internal states shown by `gmt_ReportInitCon`.

### Generating Simulation Files

```matlab
pathName = "C:\path\to\output\folder";
MainTank = gmt_Tank("MainTank", "InitCon", [300, 6000], "BuildSim", pathName)
```

This writes three files to `pathName`:

| File | Description |
|------|-------------|
| `sysFun_MainTank.m` | ODE function: `xdot = f(t, x, u)` |
| `sysFun_MainTankSimScript.m` | Ready-to-run simulation script |
| `sysObj_MainTank.mat` | Saved model object |

The ODE function can be passed directly to `ode45`, `ode23s`, or `ode15s`.

### Model Linearization

`gmt_ControlModel` returns state matrix `A`, input matrix `B`, and affine offset `Z` via first-order Taylor expansion:

$$\dot{x} \approx Ax + Bu + Z$$

`Z` provides a linear approximation of the full nonlinear dynamics without requiring deviation variables from a trim point.

```matlab
[A, B, Z] = MainTank.gmt_ControlModel                      % symbolic
[A, B, Z] = MainTank.gmt_ControlModel("Simplify", true)    % simplified
[A, B, Z] = MainTank.gmt_ControlModel("NumSub", true)      % numerical
```

### Inspecting System Equations

```matlab
MainTank.SystemEquations.Expression       % symbolic (before parameter substitution)
MainTank.SystemEquationsSubs.Expression   % after parameter substitution
```

---

## Part 2: Multi-Component System Model

This section builds a fuel system based on the dual-tank architecture from:

> D. B. Doman, "Fuel flow control for extending aircraft thermal endurance part I: underlying principles," *AIAA SciTech 2016 Forum*, San Diego, CA, Jan. 2016.

### Defining Components

```matlab
clearvars -except pathName
close all; clc; tic

HeatLoad    = gmt_HeatLoad("HeatLoad");
CoolerLoad  = gmt_HeatLoad("CoolerLoad");
MainTank    = gmt_Tank("MainTank");
RecirTank   = gmt_Tank("RecirTank");
EngineSplit = gmt_SplitJunction("EngineSplit", 1, 2);
TankSplit   = gmt_SplitJunction("TankSplit", 2, 1);
```

### Defining the Connection Structure

Each row of `PrimaryObj`/`SecondaryObj` defines one port connection. The primary object's equation takes precedence at each merge point.

```matlab
PrimaryObj = ...
    {MainTank; RecirTank; RecirTank; CoolerLoad; EngineSplit; HeatLoad};

SecondaryObj = ...
    {TankSplit; TankSplit; CoolerLoad; EngineSplit; HeatLoad; TankSplit};

ObjectArray = {PrimaryObj, SecondaryObj};

% [primary_port, secondary_port]
PortArray = ...
    [2, 1;
     2, 2;
     1, 2;
     1, 2;
     1, 2;
     1, 3];
```

### Combining into a System Model

```matlab
FuelSystem = gmt_Graph.gmt_Combine("FuelSystem", ObjectArray, PortArray);
toc
```

The toolbox merges all component graphs, renumbers edges and vertices globally, and removes shared boundary nodes.

### Matching Dependent Inputs

Input dependencies are **not** resolved automatically. After combining, inspect the renamed inputs then define algebraic relationships:

```matlab
FuelSystem.gmt_ReportInput

InputMatching = ...
    ["u2", "(u7+u9)";
     "u5", "(u7+u9)";
     "u1", "u8";
     "u4", "(u7+u9-u8)"];

FuelSystem = FuelSystem.gmt_InputCommon(InputMatching)
```

### Reports and Initial Conditions

```matlab
FuelSystem.gmt_ReportFull
FuelSystem.gmt_ReportInitCon

FuelSystem = FuelSystem.gmt_InitCon([300, 300, 300, 300, 6000, 300, 1500, 300])
```

### Simulation and Linearization

```matlab
FuelSystem = FuelSystem.gmt_BuildSim(pathName)

FuelSystem.SystemEquations.Expression
[As, Bs, Zs] = FuelSystem.gmt_ControlModel("NumSub", true)
```

---

## Summary

| Task | Code |
|------|------|
| Create component | `Obj = gmt_Tank("Name")` |
| Set initial conditions | `Obj = Obj.gmt_InitCon(x0)` |
| Initial conditions at creation | `gmt_Tank("Name", "InitCon", x0)` |
| Full report | `Obj.gmt_ReportFull` |
| Plot graph | `Obj.gmt_PlotGraph` |
| Generate simulation files | `Obj = Obj.gmt_BuildSim(pathName)` |
| Linearize (symbolic) | `[A,B,Z] = Obj.gmt_ControlModel` |
| Linearize (numerical) | `[A,B,Z] = Obj.gmt_ControlModel("NumSub", true)` |
| View equations | `Obj.SystemEquations.Expression` |
| View substituted equations | `Obj.SystemEquationsSubs.Expression` |
| Combine components | `gmt_Graph.gmt_Combine("Name", ObjectArray, PortArray)` |
| Match dependent inputs | `Obj = Obj.gmt_InputCommon(InputMatching)` |

---

## See Also

[Core Concepts](Core-Concepts) | [Component Library](Component-Models) | [Creating Systems](Creating-Systems) | [Simulating Systems](Simulating-Systems)

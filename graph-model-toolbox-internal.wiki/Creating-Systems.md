A system model is created by combining two or more component `gmt_Graph` models using `gmt_Graph.gmt_Combine`. Components connect at shared ports, and input dependencies between them are defined afterwards with `gmt_InputCommon`.

## Step 1 — Define Components

Each component must have ports defined at construction.

```matlab
MainTank    = gmt_Tank("MainTank");
RecirTank   = gmt_Tank("RecirTank");
HeatLoad    = gmt_HeatLoad("HeatLoad");
CoolerLoad  = gmt_HeatLoad("CoolerLoad");
EngineSplit = gmt_SplitJunction("EngineSplit", 1, 2);
TankSplit   = gmt_SplitJunction("TankSplit",   2, 1);
```

## Step 2 — Define Connections

`gmt_Combine` takes two parallel lists — primary and secondary objects — where each row is one connection. The **primary** object's equation takes precedence at the merge point.

```matlab
PrimaryObj = {MainTank; RecirTank; RecirTank; CoolerLoad; EngineSplit; HeatLoad};
SecondaryObj = {TankSplit; TankSplit; CoolerLoad; EngineSplit; HeatLoad; TankSplit};

ObjectArray = {PrimaryObj, SecondaryObj};

% [primary_port, secondary_port] for each connection
PortArray = [2, 1;
             2, 2;
             1, 2;
             1, 2;
             1, 2;
             1, 3];
```

## Step 3 — Combine

```matlab
FuelSystem = gmt_Graph.gmt_Combine("FuelSystem", ObjectArray, PortArray);
```

The toolbox merges all component graphs, renumbers edges and vertices globally, and removes shared boundary nodes. Component input variables and parameters are renamed with component-specific prefixes to avoid collisions.

## Step 4 — Match Dependent Inputs

Input dependencies are **not** resolved automatically. After combining, inspect the renamed inputs:

```matlab
FuelSystem.gmt_ReportInput
```

Then define algebraic relationships between them using `gmt_InputCommon`. Pass an `N × 2` string array where column 1 is the variable to replace and column 2 is its replacement expression:

```matlab
InputMatching = ["u2", "(u7+u9)";
                 "u5", "(u7+u9)";
                 "u1", "u8";
                 "u4", "(u7+u9-u8)"];

FuelSystem = FuelSystem.gmt_InputCommon(InputMatching);
```

## Step 5 — Inspect and Set Initial Conditions

```matlab
FuelSystem.gmt_ReportFull
FuelSystem.gmt_ReportInitCon

FuelSystem = FuelSystem.gmt_InitCon([300, 300, 300, 300, 6000, 300, 1500, 300]);
```

## Port Connection Rules

- Ports are defined on each component with `gmt_Port(PortType, ElementNumber, EnergyDomain)`.
- Paired ports must share the same `EnergyDomain`.
- `EdgeConnection` ports merge at a shared edge; `VertexConnection` ports merge at a shared vertex node.

See [gmt_Port](gmt_Port) for the full port reference and [Tutorial](Tutorial#part-2-multi-component-system-model) for the complete fuel system walkthrough.

## See Also
[gmt_Graph](gmt_Graph) | [gmt_Port](gmt_Port) | [Component Library](Component-Library) | [Simulating Systems](Simulating-Systems)

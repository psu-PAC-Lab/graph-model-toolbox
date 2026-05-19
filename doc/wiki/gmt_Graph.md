# gmt_Graph

Core superclass that assembles a directed graph model and provides methods for analysis, simulation, and visualization. See [Core Concepts](Core-Concepts) for the underlying theory and [Tutorial](Tutorial) for worked examples.

## Constructor

```matlab
obj = gmt_Graph(Name, EdgeMatrix, Edges, Vertices, Parameters, Inputs, Ports)
obj = gmt_Graph(..., "InitCon", x0, "BuildSim", filepath, "SystemModel", true)
```

`EdgeMatrix` is `Ne × 2` where each row is `[tailVertex, headVertex]`. Vertex index `0` is the conventional ground/reservoir node.

## Key Properties

| Property | Description |
|----------|-------------|
| `Name` | Model name |
| `EdgeMatrix` | Edge connectivity matrix |
| `Edges` / `Vertices` | Arrays of `gmt_Edge` / `gmt_Vertex` objects |
| `States` | State variable names (`x1`, `x2`, ...) |
| `Inputs` | Input variable names (`u1`, `u2`, ...) |
| `Disturbances` | External algebraic variable names |
| `ModelParameters` | Active `gmt_Parameter` objects |
| `SystemEquations` | Symbolic equations; access via `.Expression` |
| `SystemEquationsSubs` | Equations after parameter substitution; access via `.Expression` |
| `InitialConditions` | Initial state values |
| `Ports` | `gmt_Port` objects for component connections |

## Methods

### Reporting
| Method | Description |
|--------|-------------|
| `gmt_ReportGraph()` | Print vertex and edge tables |
| `gmt_ReportParameter()` | Print parameter table |
| `gmt_ReportInput()` | Print input table |
| `gmt_ReportInitCon()` | Print initial conditions |
| `gmt_ReportConnection()` | Print port connection table |
| `gmt_ReportFull()` | Print all of the above |

### Analysis & Simulation
| Method | Description |
|--------|-------------|
| `gmt_ControlModel()` | Linearize model; returns `[A, B, Z]`. Options: `"Simplify"`, `"NumSub"`, `"Discrete"` (sample time) |
| `gmt_InitCon(x0)` | Set initial conditions |
| `gmt_BuildSim(filepath)` | Write ODE function, run script, and `.mat` file to disk |

### Model Modification
| Method | Description |
|--------|-------------|
| `gmt_ParamVals(N×2 string)` | Update scalar parameter values |
| `gmt_ParamCommon(N×2 string)` | Replace parameters with shared expressions |
| `gmt_ParamOpt(N×2 string)` | Set parameter optimization flags |
| `gmt_InputCommon(N×2 string)` | Replace inputs with common expressions (required after `gmt_Combine` to define flow dependencies) |
| `gmt_ModelUpdate()` | Rebuild all derived model data |

### Visualization
| Method | Description |
|--------|-------------|
| `gmt_PlotGraph()` | Interactive plot. Pass `'SimplifyLabels', true` for dense graphs. |

## Static Method — `gmt_Combine`

Combines component models into a system model.

```matlab
sys = gmt_Graph.gmt_Combine(Name, {PrimaryList, SecondaryList}, PortArray)
```

Each row of `PrimaryList`/`SecondaryList` defines one port connection. `PortArray` is `N × 2` with port indices `[primary_port, secondary_port]`. The primary object's equation takes precedence at each merge point.

> Input dependencies between components are **not** resolved automatically — use `gmt_InputCommon` after combining.

See [Tutorial](Tutorial#part-2-multi-component-system-model) for a full example.

## See Also
[gmt_Vertex](gmt_Vertex) | [gmt_Edge](gmt_Edge) | [gmt_Parameter](gmt_Parameter) | [gmt_Input](gmt_Input) | [gmt_Port](gmt_Port)

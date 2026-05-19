# gmt_Vertex

Defines the state dynamics of a graph vertex via a capacitance equation. The toolbox parses this equation automatically to classify the vertex and extract state metadata.

## Constructor

```matlab
obj = gmt_Vertex(VertexName, CapacitanceEquation)
obj = gmt_Vertex(..., "External", true, "Units", "Pa")
```

## Equation Syntax

| Symbol | Meaning |
|--------|---------|
| `x_dot` | Derivative of a single dynamic state |
| `x1_dot`, `x2_dot` | Derivatives for multi-state vertices (sequential from 1) |
| `x`, `x1`, `x2` | State variables |
| `u`, `u1`, `u2` | Input variables |

Single and indexed notation cannot be mixed in the same equation.

**Dynamic vertex** (contains `_dot`):
```matlab
V = gmt_Vertex("Pressure Node", "C*x_dot", "Units", "Pa");
V = gmt_Vertex("Thermal Mass",  "m*Cp*x_dot", "Units", "K");
```

**Algebraic vertex** (boundary condition, no `_dot`):
```matlab
V = gmt_Vertex("Supply Pressure", "u", "External", true, "Units", "Pa");
```

## Key Auto-Generated Properties

| Property | Description |
|----------|-------------|
| `StateType` | `Dynamic` or `Algebraic` |
| `StateVariables` | Independent state variable names |
| `StateDerVariables` | Derivative variable names |
| `Capacitance` | Extracted capacitance term |
| `VertexType` | `Internal` (default) or `External` |
| `NvS` / `NvU` | Number of states / inputs |

## gmt_VertexType Enumeration

```matlab
gmt_VertexType.Internal   % contributes to system states (default)
gmt_VertexType.External   % boundary condition or source
```

## gmt_StateType Enumeration

```matlab
gmt_StateType.Dynamic     % capacitance equation contains _dot
gmt_StateType.Algebraic   % no derivative term
```

## See Also
[gmt_Graph](gmt_Graph) | [gmt_Edge](gmt_Edge) | [Core Concepts](Core-Concepts)
[gmt_Graph](gmt_Graph) | [gmt_Edge](gmt_Edge)

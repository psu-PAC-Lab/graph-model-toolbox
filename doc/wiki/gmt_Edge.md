# gmt_Edge

Defines the flow equation for a directed graph edge. The toolbox parses the equation automatically to identify head/tail state and input variable dependencies.

## Constructor

```matlab
obj = gmt_Edge(EdgeName, EdgeEq)
obj = gmt_Edge(EdgeName, EdgeEq, "External", true)
```

## Equation Syntax

| Symbol | Meaning |
|--------|---------|
| `xh`, `xh1`, `xh2` | Head vertex state(s) |
| `xt`, `xt1`, `xt2` | Tail vertex state(s) |
| `u`, `u1`, `u2` | Input variables |

Indices must start at 1 and be sequential. Single and indexed notation cannot be mixed.

```matlab
E1 = gmt_Edge("Orifice",       "Cd*A*sqrt(xh - xt)");
E2 = gmt_Edge("Pipe",          "(xh - xt)/R");
E3 = gmt_Edge("Control Valve", "Kv*u*(xh - xt)", "External", true);
E4 = gmt_Edge("Flow Source",   "u",               "External", true);
```

## Key Auto-Generated Properties

| Property | Description |
|----------|-------------|
| `EdgeType` | `Internal` (default) or `External` |
| `HeadStateVariables` / `TailStateVariables` | Detected state variables |
| `InputVariables` | Detected input variables |
| `NeHS` / `NeTS` / `NeU` | Number of head states / tail states / inputs |

## gmt_EdgeType Enumeration

```matlab
gmt_EdgeType.Internal   % flow computed from vertex states (default)
gmt_EdgeType.External   % flow driven by a user-supplied input u
```

## See Also
[gmt_Graph](gmt_Graph) | [gmt_Vertex](gmt_Vertex) | [Core Concepts](Core-Concepts)

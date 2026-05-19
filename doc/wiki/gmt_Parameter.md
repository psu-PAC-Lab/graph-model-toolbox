# gmt_Parameter

Defines a named model parameter — scalar constant, expression, lookup table, or neural network.

## Constructor

```matlab
obj = gmt_Parameter(Description, Variable, Data)
obj = gmt_Parameter(..., "Units", "Pa", "Optimization", true, "Common", true)
```

## Parameter Types

Type is detected automatically from the `Variable` string.

| `Variable` contains | Type | Notes |
|--------------------|------|-------|
| `"interp"` | `Lookup` | Model becomes `Numerical` |
| `"net"` | `Neural_Network` | Model becomes `Numerical` |
| `"="` | `Scalar` (Expression) | Derived quantity, e.g. `"A = pi*r^2"` |
| anything else | `Scalar` | Simple numeric constant |

```matlab
% Scalar
P1 = gmt_Parameter("Capacitance",  "C",   1e-6, "Units", "m^3/Pa");

% Optimization variable
P2 = gmt_Parameter("Valve gain",   "Kv",  0.25, "Optimization", true);

% Shared system-level constant
P3 = gmt_Parameter("Gas constant", "R",   287,  "Common", true);

% Expression
P4 = gmt_Parameter("Area",         "A = pi*r^2", []);

% 1-D lookup table
data.x = [0,1,2]; data.y = [0,0.5,1.0];
P5 = gmt_Parameter("Flow map", "interp1(x,y,u)", data);
```

## Key Properties

| Property | Description |
|----------|-------------|
| `ParameterType` | `Scalar`, `Lookup`, or `Neural_Network` |
| `Expression` | `true` if `Variable` contains `"="` |
| `Optimization` | Preserved as free variable during parameter substitution |
| `Common` | Assigned to system-level parent when combining components |

## gmt_ParameterType & gmt_ModelType Enumerations

```matlab
gmt_ParameterType.Scalar          % simple constant or expression
gmt_ParameterType.Lookup          % interp1/2/3 table
gmt_ParameterType.Neural_Network  % net(u)

gmt_ModelType.Analytical   % all parameters are Scalar — symbolic ops available
gmt_ModelType.Numerical    % contains Lookup or Neural_Network
```

## See Also
[gmt_Graph](gmt_Graph) | [gmt_Vertex](gmt_Vertex) | [gmt_Edge](gmt_Edge)

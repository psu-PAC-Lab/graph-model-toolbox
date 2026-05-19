# Model Interaction

How to inspect, visualize, and analyze a `gmt_Graph` model after it has been built.

## Reporting

All report methods print formatted tables to the MATLAB Command Window.

```matlab
model.gmt_ReportGraph()       % vertex and edge tables
model.gmt_ReportParameter()   % parameters: variable, value, units, type
model.gmt_ReportInput()       % inputs: variable, parent, description, units
model.gmt_ReportInitCon()     % state variables and assigned initial conditions
model.gmt_ReportConnection()  % port connections
model.gmt_ReportFull()        % all of the above in sequence
```

## Visualization

```matlab
% Interactive plot — nodes can be dragged to reposition
model.gmt_PlotGraph()

% Simplified labels (V1, V2, E1, E2, ...) useful for dense graphs
model.gmt_PlotGraph('SimplifyLabels', true)
```

## Inspecting System Equations

```matlab
% Symbolic equations (before parameter substitution)
model.SystemEquations.Expression

% After substituting non-optimization parameter values
model.SystemEquationsSubs.Expression
```

## Linearization

`gmt_ControlModel` linearizes the model via first-order Taylor expansion, returning state matrix `A`, input matrix `B`, and affine offset `Z`:

```matlab
% Symbolic (default)
[A, B, Z] = model.gmt_ControlModel()

% With symbolic simplification
[A, B, Z] = model.gmt_ControlModel("Simplify", true)

% Numerical — substitute parameter values first
[A, B, Z] = model.gmt_ControlModel("NumSub", true)

% Discrete-time (ZOH at sample time dt)
[A, B, Z] = model.gmt_ControlModel("NumSub", true, "Discrete", dt)
```

The affine term `Z` gives a linear approximation of the full nonlinear dynamics without requiring deviation variables from a trim point:

$$\dot{x} \approx Ax + Bu + Z$$

> Linearization requires an `Analytical` model. Models containing lookup tables or neural networks are `Numerical` and do not support `gmt_ControlModel`.

## Updating a Model

After changing parameters or inputs, the model rebuilds automatically. Convenience methods:

```matlab
% Update a parameter value
model = model.gmt_ParamVals(["C", "2e-10"]);

% Set optimization flags
model = model.gmt_ParamOpt(["Kv", "true"]);

% Replace parameters with shared expressions
model = model.gmt_ParamCommon(["R1", "R_shared"; "R2", "R_shared"]);
```

## See Also
[gmt_Graph](gmt_Graph) | [Simulating Systems](Simulating-Systems)

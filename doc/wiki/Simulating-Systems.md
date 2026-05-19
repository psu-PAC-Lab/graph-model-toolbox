# Simulating Systems

## Step 1 — Set Initial Conditions

Use `gmt_ReportInitCon` to see the state variables in order, then assign a value for each:

```matlab
model.gmt_ReportInitCon

model = model.gmt_InitCon([101325, 293.15]);  % one value per state, in listed order
```

Initial conditions can also be set at construction time:

```matlab
model = gmt_Tank("MainTank", "InitCon", [300, 6000]);
```

## Step 2 — Generate Simulation Files

`gmt_BuildSim` writes three files to the specified folder:

```matlab
model = model.gmt_BuildSim("./generated/my_model");
```

| File | Description |
|------|-------------|
| `my_model_fun.m` | ODE function: `xdot = f(t, x, u)` |
| `my_model_run.m` | Simulation script (calls the solver) |
| `my_model.mat` | Saved graph object |

## Step 3 — Run the Simulation

Open and run `my_model_run.m`, or call the ODE function directly with any MATLAB solver:

```matlab
u = @(t) [0.5];                          % input function (mass flow, kg/s)
f = @(t, x) my_model_fun(t, x, u(t));   % wrap ODE function

[t, x] = ode45(f, [0, 100], model.InitialConditions);

plot(t, x)
```

For stiff systems (common in thermal and hydraulic models), use `ode15s` or `ode23s` instead of `ode45`.

## Building Simulation Files at Construction

Pass `"BuildSim"` directly to the constructor to generate files immediately:

```matlab
model = gmt_Tank("MainTank", "InitCon", [300, 6000], "BuildSim", "./generated/tank");
```

## See Also
[gmt_Graph](gmt_Graph) | [Model Interaction](Model-Interaction) | [Creating Systems](Creating-Systems)

# Component Library

The gmt Toolbox ships with pre-built component models for common physical elements. Each component is a subclass of `gmt_Graph` and inherits all graph-model methods including `gmt_ReportFull`, `gmt_ControlModel`, `gmt_BuildSim`, and `gmt_PlotGraph`.

Components can be used standalone or combined into system models via `gmt_Graph.gmt_Combine`.

---

## Available Components

| Class | Description | States | Ports |
|-------|-------------|--------|-------|
| [`gmt_Tank`](#gmt_tank) | Fluid storage tank with thermal and mass dynamics | Temperature, Mass | 2 (inlet, outlet) |
| [`gmt_HeatLoad`](#gmt_heatload) | Thermal load element with advective heat exchange | Temperature | — |
| [`gmt_SplitJunction`](#gmt_splitjunction) | Flow split/junction node with configurable inlet and outlet counts | Temperature | 3+ |

> **Note:** The component library is under active development. Additional components will be added over time.

---

## gmt_Tank

Models a fluid storage tank with coupled thermal energy and mass conservation dynamics.

### Constructor

```matlab
obj = gmt_Tank(Name)
obj = gmt_Tank(Name, "InitCon", x0, "BuildSim", filepath)
```

### States

| Variable | Description | Units |
|----------|-------------|-------|
| `x1` | Fluid temperature | K |
| `x2` | Fluid mass | kg |

### Edges

| Edge Name | Inputs | Equation |
|-----------|--------|----------|
| Advection In | `u1` | `cp_f * u1 * x_source` |
| Advection Out | `u2` | `cp_f * u2 * x1` |
| Tank Fill Rate | `u1, u2` | `u1 - u2` |
| Advection Tank Fluid | `u1, u2` | `cp_f * x1 * (u1 - u2)` |

### Parameters

| Parameter | Description | Units | Scope |
|-----------|-------------|-------|-------|
| `cp_f` | Fluid specific heat | kJ/(kg·K) | System (common) |
| `Rho` | Fluid density | kg/m³ | System (common) |
| `V` | Tank volume | m³ | Component |

### Inputs

| Variable | Description | Units |
|----------|-------------|-------|
| `u1` | Inlet mass flow rate | kg/s |
| `u2` | Outlet mass flow rate | kg/s |

### Ports

| Port | Description | Type |
|------|-------------|------|
| 1 | Advection In (inlet edge) | `EdgeConnection` |
| 2 | Advection Out (outlet edge) | `EdgeConnection` |

### State Equations

$$\dot{T} = \frac{1}{c_{p,f} \cdot m} \left[ c_{p,f} u_1 T_{in} - c_{p,f} u_2 T - c_{p,f} T (u_1 - u_2) \right]$$

$$\dot{m} = u_1 - u_2$$

### Example

```matlab
MainTank = gmt_Tank("MainTank")
MainTank = gmt_Tank("MainTank", "InitCon", [300, 6000])
```

---

## gmt_HeatLoad

Models a thermal load element — a volume of fluid that exchanges heat with an external power source and adjacent fluid streams via advection.

### Constructor

```matlab
obj = gmt_HeatLoad(Name)
obj = gmt_HeatLoad(Name, "InitCon", x0, "BuildSim", filepath)
```

### States

| Variable | Description | Units |
|----------|-------------|-------|
| `x1` | Fluid temperature in the load volume | K |

### Parameters

| Parameter | Description | Units | Scope |
|-----------|-------------|-------|-------|
| `cp_f` | Fluid specific heat | kJ/(kg·K) | System (common) |
| `Rho` | Fluid density | kg/m³ | System (common) |
| `V` | Load volume | m³ | Component |

### Inputs

| Variable | Description | Units |
|----------|-------------|-------|
| `u1` | Inlet mass flow rate | kg/s |

### Example

```matlab
HeatLoad   = gmt_HeatLoad("HeatLoad")
CoolerLoad = gmt_HeatLoad("CoolerLoad")
```

---

## gmt_SplitJunction

Models a flow split or junction node — a mixing volume where multiple inlet and outlet fluid streams merge. The constructor arguments define the number of inlet and outlet connections.

### Constructor

```matlab
obj = gmt_SplitJunction(Name, NumInlets, NumOutlets)
obj = gmt_SplitJunction(Name, NumInlets, NumOutlets, "InitCon", x0)
```

### States

| Variable | Description | Units |
|----------|-------------|-------|
| `x1` | Mixed fluid temperature at the junction | K |

### Parameters

| Parameter | Description | Units | Scope |
|-----------|-------------|-------|-------|
| `cp_f` | Fluid specific heat | kJ/(kg·K) | System (common) |
| `Rho` | Fluid density | kg/m³ | System (common) |
| `V` | Junction volume | m³ | Component |

### Example

```matlab
EngineSplit = gmt_SplitJunction("EngineSplit", 1, 2)  % 1 inlet, 2 outlets
TankSplit   = gmt_SplitJunction("TankSplit",   2, 1)  % 2 inlets, 1 outlet
```

The number of ports equals `NumInlets + NumOutlets`.

---

## Common System Parameters

When assembled into a system model, `cp_f` and `Rho` are marked `Common = true` and appear once in the system parameter table under the `"System"` parent. Each component contributes its own volume parameter, renamed with a numeric suffix (e.g., `V_1`, `V_2`, ...) to avoid collisions.

---

## See Also

[gmt_Graph](gmt_Graph) | [Creating Systems](Creating-Systems) | [Tutorial](Tutorial) | [gmt_Port](gmt_Port)

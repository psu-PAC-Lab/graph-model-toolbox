GMT contains several pre-built component models for single phase thermal and electrical domains. Each component is a subclass of `gmt_Graph` and inherits all graph-model methods including `gmt_ReportFull`, `gmt_ControlModel`, `gmt_BuildSim`, and `gmt_PlotGraph`.

Components can be used standalone or combined into system models via `gmt_Graph.gmt_Combine`. Reference [Creating Systems](Creating-Systems) for more information. 

---

## Available Components

| Component | Energy Domain | Description |
|-----------|----------------------|-------------|
| `gmt_Tank` | Thermal - Single Phase |Fluid Storage Tank|
| `gmt_HeatLoad` | Thermal - Single Phase | Fluid Heat Load Junction |
| `gmt_HeatExchanger` | Thermal - Single Phase | Single Wall Heat Exchanger|
| `gmt_SplitJunction` | Thermal - Single Phase | Configurable Fluid Junction |
| `gmt_DCMotor` | Electrical | DC Motor Thermal & Electrical |
| `gmt_Inverter` | Electrical | Inverter Thermal & Electrical |
| `gmt_Battery` | Electrical | Battery Thermal & Electrical W/ Built-In Configurations |

> **Note:** The component library is under active development. Additional components will be added over time.



## See Also

[gmt_Graph](gmt_Graph) | [Creating Systems](Creating-Systems) | [Tutorial](Tutorial) | [gmt_Port](gmt_Port)

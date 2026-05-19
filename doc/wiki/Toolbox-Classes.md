# Toolbox Classes

Reference index for all classes in the gmt Toolbox.

## Core Classes

| Class | Role |
|-------|------|
| [gmt_Graph](gmt_Graph) | Assembles and manages the graph model. Superclass for all component models. |
| [gmt_Vertex](gmt_Vertex) | Defines vertex state dynamics via a capacitance equation. |
| [gmt_Edge](gmt_Edge) | Defines the flow equation for a directed edge. |
| [gmt_Parameter](gmt_Parameter) | Defines a named model parameter — scalar, expression, lookup table, or neural network. |
| [gmt_Input](gmt_Input) | Defines an external input variable and its metadata. |
| [gmt_Port](gmt_Port) | Defines a connection point used when combining component models. |

## Enumerations

Each enumeration is documented on the page of the class that uses it.

| Enumeration | Values | Documented on |
|-------------|--------|---------------|
| `gmt_EdgeType` | `Internal`, `External`, `Unassigned` | [gmt_Edge](gmt_Edge) |
| `gmt_VertexType` | `Internal`, `External`, `Unassigned` | [gmt_Vertex](gmt_Vertex) |
| `gmt_StateType` | `Dynamic`, `Algebraic` | [gmt_Vertex](gmt_Vertex) |
| `gmt_ParameterType` | `Scalar`, `Lookup`, `Neural_Network` | [gmt_Parameter](gmt_Parameter) |
| `gmt_ModelType` | `Analytical`, `Numerical` | [gmt_Parameter](gmt_Parameter) |
| `gmt_PortType` | `EdgeConnection`, `VertexConnection` | [gmt_Port](gmt_Port) |
| `gmt_EnergyDomain` | `Hydraulic`, `Electrical`, `Thermal`, `Mechanical`, `Chemical`, `Voltage`, `Current`, `Unassigned` | [gmt_Port](gmt_Port) |

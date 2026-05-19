# gmt_Port

Defines a connection point on a component graph model, used by `gmt_Graph.gmt_Combine` to specify how components are linked.

## Constructor

```matlab
obj = gmt_Port(PortType, ElementNumber, EnergyDomain)
```

```matlab
P1 = gmt_Port("EdgeConnection",   2, "Hydraulic");  % connect via edge 2
P2 = gmt_Port("VertexConnection", 1, "Thermal");    % connect via vertex 1
```

`ElementNumber` is the 1-based edge or vertex index in the parent graph. Ports are passed into `gmt_Graph` at construction; the toolbox validates the indices and populates `Description` automatically.

## Key Properties

| Property | Description |
|----------|-------------|
| `PortType` | `EdgeConnection` or `VertexConnection` |
| `ElementNumber` | Edge or vertex index |
| `EnergyDomain` | Physical domain of the connection |
| `Description` | Auto-filled with the edge/vertex name after parent assignment |
| `ParentName` | Parent graph name |

## gmt_PortType Enumeration

```matlab
gmt_PortType.EdgeConnection     % port references a graph edge
gmt_PortType.VertexConnection   % port references a graph vertex
```

## gmt_EnergyDomain Enumeration

```matlab
gmt_EnergyDomain.Hydraulic
gmt_EnergyDomain.Electrical
gmt_EnergyDomain.Thermal
gmt_EnergyDomain.Mechanical
gmt_EnergyDomain.Chemical
gmt_EnergyDomain.Voltage
gmt_EnergyDomain.Current
gmt_EnergyDomain.Unassigned   % default
```

Ports paired in `gmt_Combine` must share the same `EnergyDomain`.

## See Also
[gmt_Graph](gmt_Graph) | [gmt_Edge](gmt_Edge) | [gmt_Vertex](gmt_Vertex)

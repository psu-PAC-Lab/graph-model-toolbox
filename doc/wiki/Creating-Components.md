# Creating Components

A component is a reusable `gmt_Graph` subclass that encapsulates a fixed physical model — its own vertices, edges, parameters, ports, and inputs — under a clean constructor interface. The built-in `gmt_Tank`, `gmt_HeatLoad`, and `gmt_SplitJunction` classes follow this pattern.

## Class Structure

```matlab
classdef MyComponent < gmt_Graph

    methods
        function obj = MyComponent(Name, varargin)

            %% 1. Define vertices
            V1 = gmt_Vertex("Pressure Node", "C*x_dot", "Units", "Pa");
            V2 = gmt_Vertex("Boundary",      "u",       "External", true, "Units", "Pa");

            %% 2. Define edges
            E1 = gmt_Edge("Supply Flow",   "u",                "External", true);
            E2 = gmt_Edge("Drain Orifice", "Cd*A*sqrt(xh - xt)");

            %% 3. Edge matrix: [tail, head]
            EM = [0, 1;
                  1, 2];

            %% 4. Define parameters
            P = [gmt_Parameter("Capacitance", "C",  1e-10, "Units", "m^3/Pa"), ...
                 gmt_Parameter("Cd",          "Cd", 0.62), ...
                 gmt_Parameter("Area",        "A",  1e-4,  "Units", "m^2")];

            %% 5. Define inputs
            U = gmt_Input("u", "Supply mass flow rate", "Units", "kg/s");

            %% 6. Define ports (connection points for gmt_Combine)
            Ports = [gmt_Port("EdgeConnection", 1, "Hydraulic"), ...
                     gmt_Port("EdgeConnection", 2, "Hydraulic")];

            %% 7. Call superclass constructor
            obj = obj@gmt_Graph(Name, EM, [E1, E2], [V1, V2], P, [U], Ports, varargin{:});

        end
    end

end
```

Passing `varargin{:}` to the superclass constructor forwards optional arguments like `"InitCon"` and `"BuildSim"` so users can set them at construction time.

## Key Design Decisions

**Vertices** define what states the component has. Internal vertices contribute to the system state vector; external vertices are boundary conditions driven by inputs or adjacent components.

**Edges** define the physics — the flow equations connecting vertices. Mark an edge `"External", true` when its flow is driven by a user input `u` rather than vertex states.

**Parameters** should be marked `"Common", true` for any physical constant shared across components (e.g., fluid density, specific heat). These appear once in the system parameter table rather than once per component.

**Ports** define where this component can connect to others. Choose `EdgeConnection` to merge at a shared flow edge, or `VertexConnection` to merge at a shared state node. The `ElementNumber` is the 1-based index into the `Edges` or `Vertices` arrays passed to the constructor.

## Tips

- Keep the component self-contained. All physics, parameters, and ports should be defined inside the constructor — the user should not need to modify the underlying graph directly.
- Use descriptive vertex and edge names prefixed consistently (e.g., `"MyComp: Pressure Node"`). The toolbox prefixes them with the component `Name` automatically during system assembly.
- Test the component standalone before combining it into a system:

```matlab
comp = MyComponent("Test", "InitCon", [101325]);
comp.gmt_ReportFull
comp.gmt_PlotGraph()
[A, B, Z] = comp.gmt_ControlModel("NumSub", true);
```

## See Also
[gmt_Vertex](gmt_Vertex) | [gmt_Edge](gmt_Edge) | [gmt_Parameter](gmt_Parameter) | [gmt_Port](gmt_Port) | [Component Library](Component-Models) | [Creating Systems](Creating-Systems)

# Core Concepts

## The Graph Model Formulation

The gmt Toolbox represents physical systems using **directed graphs**. A directed graph $G = (V, E)$ consists of:

- A set of **vertices** $V$ — representing energy-storing elements
- A set of **directed edges** $E$ — representing power flows between them

---

## Vertices

A vertex represents a lumped energy storage element. Its behavior is described by a **capacitance equation** defining how the stored state changes over time.

### Dynamic Vertices

A vertex is **dynamic** when its capacitance equation contains a time derivative (identified by the `_dot` suffix). The toolbox extracts the capacitance term from the left-hand side and assembles the right-hand side by summing signed contributions from connected edges.

```matlab
V = gmt_Vertex("Thermal Mass",        "m*Cp*x_dot", "Units", "K");
V = gmt_Vertex("Accumulator Pressure","V0/(gamma*x)*x_dot", "Units", "Pa");
```

### Algebraic Vertices

A vertex is **algebraic** when no `_dot` term is present — typically used for boundary conditions or external sources.

```matlab
V = gmt_Vertex("Supply Pressure", "u", "External", true, "Units", "Pa");
```

### Internal vs External

| Type | Meaning |
|------|---------|
| `Internal` | Contributes a state variable to the system equations (default) |
| `External` | Acts as a boundary condition or source node |

---

## Edges

An edge represents a power flow between two vertices, described by a **power flow equation** that may depend on head/tail vertex states, inputs, and parameters.

### Edge Directionality

```
EdgeMatrix(i, :) = [tail_vertex_index, head_vertex_index]
```

Power flow is **positive** when entering the head vertex. Vertex index `0` is the conventional ground/reservoir node.

### Head and Tail Notation

| Symbol | Meaning |
|--------|---------|
| `xh`, `xh1`, `xh2` | Head vertex state(s) |
| `xt`, `xt1`, `xt2` | Tail vertex state(s) |

```matlab
E = gmt_Edge("Orifice",       "Cd*A*sqrt(xh - xt)");
E = gmt_Edge("Control Valve", "Kv*u*(xh - xt)", "External", true);
```

### Internal vs External

| Type | Meaning |
|------|---------|
| `Internal` | Power flow computed from vertex states (default) |
| `External` | Power flow computed from user-supplied boundary condition |

---

## System Equation Assembly

During `gmt_Graph` construction, the toolbox:

1. Parses all vertex and edge equations to identify states, capacitances, and dependencies.
2. Substitutes graph-specific variable names (`x1`, `x2`, ...) for generic symbols (`x`, `xh`, `xt`).
3. Assembles the power balance for each internal vertex by summing signed edge contributions.
4. Divides by the capacitance to produce the final state equation:

$$\dot{x}_i = \frac{1}{C_i} \sum_{j \in E_i} \sigma_{ij} \cdot f_{ij}$$

where $\sigma_{ij} = +1$ if edge $j$ enters vertex $i$, and $\sigma_{ij} = -1$ if it leaves.

---

## Parameters

| Type | Detected when `Variable` contains | Model classification |
|------|----------------------------------|---------------------|
| Scalar | anything else | Analytical |
| Expression | `"="` | Analytical |
| Lookup | `"interp"` | Numerical |
| Neural Network | `"net"` | Numerical |

**Analytical** models support symbolic linearization and parameter substitution. **Numerical** models support simulation only.

---

## Combining Component Models

Individual component models can be combined into a system model using `gmt_Graph.gmt_Combine`. Components connect at shared ports referencing specific edges or vertices.

See [Creating Systems](Creating-Systems) for the full workflow.

---

## Linearization

Analytical models can be linearized via `gmt_ControlModel`, returning `A`, `B`, and affine offset `Z`:

$$\dot{x} \approx Ax + Bu + Z$$

`Z` provides a linear approximation of the nonlinear dynamics without requiring deviation variables from a trim point. Results can optionally be discretized using a zero-order hold.

---

## See Also

[Toolbox Classes](Toolbox-Classes) | [Quick Start](Quick-Start) | [gmt_Graph](gmt_Graph) | [gmt_Vertex](gmt_Vertex) | [gmt_Edge](gmt_Edge)

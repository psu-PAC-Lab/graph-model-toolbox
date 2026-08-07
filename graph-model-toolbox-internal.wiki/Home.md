# gmt Toolbox

A MATLAB framework for building, analyzing, and simulating physics-based dynamic system models using directed graphs. Vertices represent energy-storing elements; edges represent flows between them.

---

## Contents

| | |
|--|--|
| [Quick Start](Quick-Start) | Install, build your first model, run a simulation |
| [Core Concepts](Core-Concepts) | Graph model theory background |
| [Tutorial](Tutorial) | Walkthrough from the gmtTutorial live script |
| [Toolbox Classes](Toolbox-Classes) | Reference documentation on main toolbox classes |
| [Model Interaction](Model-Interaction) | Analyzing and interacting with graph models |
| [Component Library](Component-Library) | Prebuilt component models |
| [Creating Systems](Creating-Systems) | Combine components into a system model |
| [Simulating Systems](Simulating-Systems) | Set initial conditions, generating simulation files and running simulations |
| [Creating Components](Creating-Components) | Build a reusable component class |


---

## Workflow at a Glance

```
Define vertices & edges
        ↓
Build a gmt_Graph model
        ↓
    ┌───┴───────────────┐
Standalone model    Combine components
        ↓               ↓
  Interact &      Match inputs &
  inspect         rebuild model
        └───┬───────────┘
            ↓
   Set initial conditions
            ↓
     Build & run simulation
```

## Class Hierarchy

```
gmt_Graph                    ← core model class
├── gmt_Vertex               ← state dynamics
├── gmt_Edge                 ← flow equations
├── gmt_Parameter            ← model parameters
├── gmt_Input                ← external inputs
└── gmt_Port                 ← connection points

Component Models (subclasses of gmt_Graph)
├── gmt_Tank
├── gmt_HeatLoad
└── gmt_SplitJunction
```
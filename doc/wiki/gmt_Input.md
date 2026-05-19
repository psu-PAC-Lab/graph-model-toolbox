# gmt_Input

Defines an external input variable and its metadata. The `VariableName` must match the symbol used in edge and vertex equations exactly.

## Constructor

```matlab
obj = gmt_Input(VariableName, Description)
obj = gmt_Input(VariableName, Description, "Units", "kg/s", "DependencyFormula", "u2 = 2*u1")
```

```matlab
U1 = gmt_Input("u",  "Supply pressure",      "Units", "Pa");
U2 = gmt_Input("u1", "Inlet mass flow rate", "Units", "kg/s");
U3 = gmt_Input("u2", "Outlet mass flow rate","Units", "kg/s");
```

## Key Properties

| Property | Description |
|----------|-------------|
| `VariableName` | Variable name as used in equations (`"u"`, `"u1"`, ...) |
| `Description` | Physical description |
| `Units` | Engineering units (default: `"unassigned"`) |
| `DependencyFormula` | Optional algebraic relationship, e.g. `"u2 = 0.5*u1"` |
| `GraphVariableName` | Renamed variable after system assembly |
| `Parent` | Parent graph object name |

## Notes

- When components are combined via `gmt_Graph.gmt_Combine`, input variables are renamed with component prefixes (e.g. `u1` → `CompA_u1`). Use `gmt_ReportInput` to see the renamed variables, then `gmt_InputCommon` to define any algebraic dependencies.
- `DependencyFormula` is informational metadata only — the toolbox does not enforce it automatically.

## See Also
[gmt_Graph](gmt_Graph) | [gmt_Edge](gmt_Edge)

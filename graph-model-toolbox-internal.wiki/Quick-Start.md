## Installation

1. Download the `gmt.mltbx` toolbox file.
2. Double-click the file in MATLAB or run:

```matlab
matlab.addons.install('gmt.mltbx')
```

The toolbox will be added to your MATLAB Add-Ons automatically. To verify installation, check **Home → Add-Ons → Manage Add-Ons**.

## Instantiating Component from Library 

Instantiating a single phase thermal fluid tank object MainTank to the workspace

```matlab
MainTank = gmt_Tank("MainTank");
```

## Inspect

```matlab
MainTank.gmt_ReportFull        % print all reporting tables
MainTank.gmt_PlotGraph         % interactive graph plot
```

## Simulate

```matlab
MainTank = MainTank.gmt_InitCon([300,6000]);            % initial temperature (K), and tank mass (kg)
MainTank = MainTank.gmt_BuildSim("./generated/tank");   % generate and save ODE files to file path specified 
```

See [Simulating Systems](Simulating-Systems) for how to run the generated files, and [Core Concepts](Core-Concepts) for the theory behind the model structure.

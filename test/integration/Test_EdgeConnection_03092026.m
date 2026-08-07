%% Dual Tank Doman Model 
clear all; close all; clc

tic
% Define Each Componnet
HeatLoad = gmt_HeatLoad("HeatLoad");
CoolerLoad = gmt_HeatLoad("CoolerLoad");
MainTank = gmt_Tank("MainTank");
RecirTank = gmt_Tank("RecirTank");
EngineSplit = gmt_SplitJunction("EngineSplit",1,2);
TankSplit = gmt_SplitJunction("TankSplit",2,1);

% Combine Each Component 
PrimaryObj = ...
    {MainTank; 
     RecirTank; 
     RecirTank; 
     CoolerLoad; 
     EngineSplit; 
     HeatLoad};

SecondaryObj = ...
    {TankSplit; 
     TankSplit; 
     CoolerLoad; 
     EngineSplit; 
     HeatLoad; 
     TankSplit};

ObjectArray = {PrimaryObj,SecondaryObj};

PortArray = ...
    [2, 1; 
     2, 2; 
     1, 2; 
     1, 2; 
     1, 2; 
     1, 3];

FilePath = string(pwd);
FTMS = gmt_Graph.gmt_Combine("FTMS",ObjectArray,PortArray);

% Match Inputs 
InputMatching = ...
[ "u2", "u5"; ...
  "u1", "u8"; ...
  "u4", "(u5-u8)"; ...
  "u5", "(u7+u9)"
  ];

% Update Model W/ Matched Inputs
FTMS = FTMS.gmt_InputCommon(InputMatching);

% Algebraic State Conversion
FTMS = gmt_Algebraic(FTMS,[1,5,16],"BuildSim",FilePath);

% Plot Graph
FTMS.gmt_PlotGraph

% Generate Graph Report
FTMS.gmt_ReportFull
toc

%[A, B, Z] = FuelSystem.gmt_ControlModel("Simplify",true,"NumSub",true);
% 
% Afun = 
% Bfun = 
% Zfun = 


%% Status Note Log 
% Doman Dual Tank Requires Vertex Connection 

%% Improvement Log
% Feedback 
% Ensure source edges and vertices are treated as inputs 
% Ensure sink edges and vertices are treated as outputs
% Ability to specify where system model output combination
% Parameterization and input check during model build 
% Being able to specify output equations

% Lookup Table Parameterization Changes
    % Allow users to specify variable = lookup
% Neural Network Syntax 
% Component Model Options Architecture 
    % Placeholder for required inputs like tank configuration
    % Option for user to replace specific parameters
    % Option for variables to be optimized 


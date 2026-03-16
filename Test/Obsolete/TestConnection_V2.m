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

% % Combine Each Component 
% PrimaryObj = {MainTank; TankSplit; RecirTank; CoolerLoad; EngineSplit; HeatLoad;};
% SecondaryObj = {TankSplit; RecirTank; CoolerLoad; EngineSplit; HeatLoad; TankSplit;};
% PortArray = [2, 1; 2, 2; 1, 2; 1, 2; 1, 2; 3, 1];
% 
% FilePath = "C:\Users\jmp8430\Documents\Research\Practice System Modeling";
% FuelSystem = gmt_Graph.gmt_Combine("FuelSystem",PrimaryObj,SecondaryObj,PortArray,"BuildSim",FilePath);
% % SubSysB = gmt_Graph.gmt_CombineSimple(SubSysA,RecirTank,[4, 2]);
% % SubSysC = gmt_Graph.gmt_CombineSimple(SubSysB,CoolerLoad,[5, 2]);
% % SubSysD = gmt_Graph.gmt_CombineSimple(SubSysC,EngineSplit,[6, 2]);
% % SubSysE = gmt_Graph.gmt_CombineSimple(SubSysD,HeatLoad,[7, 2]);
% % SysFin = gmt_Graph.gmt_CombineSys(SubSysE,[4, 8]);

SubSysA = gmt_Graph.gmt_CombineSimple(MainTank,TankSplit,[2, 1]);
SubSysB = gmt_Graph.gmt_CombineSimple(SubSysA,RecirTank,[4, 2]);
SubSysC = gmt_Graph.gmt_CombineSimple(SubSysB,CoolerLoad,[5, 2]);
SubSysD = gmt_Graph.gmt_CombineSimple(SubSysC,EngineSplit,[6, 2]);
SubSysE = gmt_Graph.gmt_CombineSimple(SubSysD,HeatLoad,[7, 2]);
SysFin = gmt_Graph.gmt_CombineSys(SubSysE,[4, 8]);

% SubSysA = gmt_Graph.gmt_CombineSimple(MainTank,TankSplit,[2, 1]);
% SubSysB = gmt_Graph.gmt_CombineSimple(TankSplit,RecirTank,[4, 2]);
% SubSysC = gmt_Graph.gmt_CombineSimple(RecirTank,CoolerLoad,[5, 2]);
% SubSysD = gmt_Graph.gmt_CombineSimple(CoolerLoad,EngineSplit,[6, 2]);
% SubSysE = gmt_Graph.gmt_CombineSimple(EngineSplit,HeatLoad,[7, 2]);
% SysFin = gmt_Graph.gmt_CombineSys(SubSysE,[4, 8]);


% % Match Inputs 
InputMatching = ...
[ "u4", "(u2+u6)"; ...
  "u3", "u6"; ...
  "u7", "u5"; ...
  "u9", "(u2+u6)"; ...
  "u10", "(u2+u6-u5)"];   

% Update Model W/ Matched Inputs
pathname = "C:\Users\jmp8430\Documents\Research\GraphModel_ToolboxV2\doc";
Combine = SysFin.gmt_InputCommon(InputMatching,"BuildSim",pathname);

% Plot Graph
Combine.gmt_PlotGraph

% Generate Graph Report
Combine.gmt_ReportFull
toc

% SubSysB = gmt_Graph.gmt_CombineSimple(CoolerLoad,RecirTank,[2, 1],"SystemModel",true);
% SubSysC = gmt_Graph.gmt_CombineSimple(SubSysA,EngineSplit,[4, 1],"SystemModel",true);
% Sys = gmt_Graph.gmt_CombineSimple(SubSysC,SubSysB,[4, 1],"SystemModel",true);

%SysFin = gmt_Graph.gmt_CombineSys(Sys,[8, 3],"BuildModel",true,"SystemModel",true);


%% Status Note Log 
% Doman Dual Tank Requires Vertex Connection 
% Capacitance equation does not handle states numbering during connection
% Parameters with same variable name are treated as common, no updating on combination  
% Incidence matrix is correct, question is how to integrate the model inputs. 


%% Improvement Log
% Feedback 
% Ensure source edges and vertices are treated as inputs 
% Ensure sink edges and vertices are treated as outputs
% Ability to specify where system model output combination
% Automated combination
% Parameterization and input check during model build 
% Being able to specify output equations

% Lookup Table Parameterization Changes
    % Allow users to specify variable = lookup
% Neural Network Syntax 
% Component Model Options Architecture 
    % Placeholder for required inputs like tank configuration
    % Option for user to replace specific parameters
    % Option for variables to be optimized 

% y0 = ones(1,size(sys.MassMatrix,1));
% tspan = [0 10];
% options = odeset('Mass', sys.MassMatrix, 'MassSingular', 'yes');
% u1 = 1;
% u2 = 2;
% u3 = -25000;
% 
% n = 1;
% 
% for i = 1:n
%     tic; 
%     [t, y] = ode15s(@(t,y) sysFun_Combine(t,y,u1,u2,u3), tspan, y0, options);
%     elapsedTime3(i) = toc;
% end
% 
% plot(t,y)
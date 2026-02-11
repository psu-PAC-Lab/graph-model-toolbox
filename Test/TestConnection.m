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
SubSysA = gmt_Graph.gmt_CombineSimple(MainTank,TankSplit,[2, 1]);
SubSysB = gmt_Graph.gmt_CombineSimple(SubSysA,RecirTank,[4, 2]);
SubSysC = gmt_Graph.gmt_CombineSimple(SubSysB,CoolerLoad,[5, 2]);
SubSysD = gmt_Graph.gmt_CombineSimple(SubSysC,EngineSplit,[6, 2]);
SubSysE = gmt_Graph.gmt_CombineSimple(SubSysD,HeatLoad,[7, 2]);
SysFin = gmt_Graph.gmt_CombineSys(SubSysE,[4, 8]);

% Match Inputs 
% Ask Chris and Phil about automatic to join inputs
InputMatching = ...
[ "u4", "(u2+u6)"; ...
  "u3", "u6"; ...
  "u7", "u5"; ...
  "u9", "(u2+u6)"; ...
  "u10", "(u2+u6-u5)"];   

% Update Model W/ Matched Inputs
Combine = SysFin.gmt_InputCommon(InputMatching,"BuildSim","C:\Users\jmp8430\Documents\Research\Practice System Modeling");

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
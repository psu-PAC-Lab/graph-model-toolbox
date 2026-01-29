%% Dual Tank Doman Model 
clear all; close all; clc

tic
% Define Each Componnet
HeatLoad = gmt_HeatLoad("HeatLoad");
CoolerLoad = gmt_HeatLoad("CoolerLoad");
MainTank = gmt_Tank2("MainTank");
RecirTank = gmt_Tank("RecirTank");
EngineSplit = gmt_SplitJunction2("EngineSplit");
TankSplit = gmt_SplitJunction3("TankSplit");

% Combine Each Component 
SubSysA = gmt_Graph.gmt_CombineSimple(MainTank,TankSplit,[2, 1],"SystemModel",true);
SubSysB = gmt_Graph.gmt_CombineSimple(SubSysA,RecirTank,[4, 2],"SystemModel",true);
SubSysC = gmt_Graph.gmt_CombineSimple(SubSysB,CoolerLoad,[5, 2],"SystemModel",true);
SubSysD = gmt_Graph.gmt_CombineSimple(SubSysC,EngineSplit,[6, 2],"SystemModel",true);
SubSysE = gmt_Graph.gmt_CombineSimple(SubSysD,HeatLoad,[6, 2],"SystemModel",true);
SysFin = gmt_Graph.gmt_CombineSys(SubSysE,[4, 7],"SystemModel",true);

% Match Inputs 
% Ask Chris and Phil about automatic to join inputs
InputMatching = ...
["u2","u1"; ...
"u5","u3"; ...
"u6","u4"; ...
"u8", "(u1+u3)"; ...
"u9","u4"];

% Update Model W/ Matched Inputs
SysFin = SysFin.gmt_InputCommon("CombineInputs",InputMatching,"BuildModel",true,"SystemModel",true);

% Plot Graph
SysFin.gmt_PlotGraph

% Generate Graph Report
SysFin.gmt_FullReport
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
% Problem with parameter commonization Sys
% Improve Options Architecture Using Varagin
    % Graph Based Modeling Simple or System Connection Option 
    %   Opts("BuildModel",'True',"PlotModel","True","CommonInputs",["u1", "u2"],)
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
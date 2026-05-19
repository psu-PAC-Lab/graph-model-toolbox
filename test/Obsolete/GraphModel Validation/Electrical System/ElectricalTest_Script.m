%% Simple Electrical System 
clear all; close all; clc

tic
% Define Each Component
Inverter = gmt_Inverter("Inverter");
Motor = gmt_DCMotor("Motor");
Battery = gmt_Battery("Battery");

% Combine Each Component 
PrimaryObj = ...
    {}

SecondaryObj = ...
    {};

ObjectArray = {PrimaryObj,SecondaryObj};

PortArray = ...
    [];

FilePath = string(pwd);
ElectricSys = gmt_Graph.gmt_Combine("ElectricSys",ObjectArray,PortArray,"BuildSim",FilePath);

% Match Inputs 
InputMatching = ...
[];   

% Update Model W/ Matched Inputs
ElectricSys = ElectricSys.gmt_InputCommon(InputMatching,"BuildSim",FilePath);

% Plot Graph
ElectricSys.gmt_PlotGraph

% Generate Graph Report
ElectricSys.gmt_ReportFull
toc

%% Issuse List 
% How to have algebraic outputs using ODE 
% Functionality to update parameters from component models
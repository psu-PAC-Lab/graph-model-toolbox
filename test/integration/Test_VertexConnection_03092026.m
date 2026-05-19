%% Simple BEV Example
clear all; close all; clc

tic
% Define Each Componnet
DCMotor = gmt_DCMotor("DCMotor");
Battery = gmt_Battery("Battery");
Inverter = gmt_Inverter("Inverter");

% Generate Connection Reports
DCMotor.gmt_ReportConnection
Battery.gmt_ReportConnection
Inverter.gmt_ReportConnection

% Generate Input Reports
% DCMotor.gmt_ReportInput
% Battery.gmt_ReportInput
% Inverter.gmt_ReportInput

% Plot Figures
DCMotor.gmt_PlotGraph
Battery.gmt_PlotGraph
Inverter.gmt_PlotGraph

% Combine Each Component 
PrimaryObj = ...
    {Inverter;
     Battery;
     DCMotor};

SecondaryObj = ...
    {DCMotor;
     Inverter;
     Battery};

ObjectArray = {PrimaryObj,SecondaryObj};

PortArray = ...
    [2, 1;
     4, 6;
     3, 3];


FilePath = string(pwd);
BatteryElectric = gmt_Graph.gmt_Combine("BatteryElectric",ObjectArray,PortArray,"BuildSim",FilePath);

% Plot Graph
BatteryElectric.gmt_PlotGraph

% Generate Graph Report
BatteryElectric.gmt_ReportFull
toc
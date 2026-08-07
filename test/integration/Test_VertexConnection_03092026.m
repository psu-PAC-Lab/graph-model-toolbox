%% Simple BEV Example
clear all; close all; clc

% Define DC Motor Parameters
dcMotors_Param(1) = gmt_Parameter("Rotational Inertia","J",1.09*10^-4);
dcMotors_Param(2) = gmt_Parameter("DC Motor Specific Heat","Cp",60);
dcMotors_Param(3) = gmt_Parameter("Motor Inductance","L",1.252192537082724e-05);
dcMotors_Param(4) = gmt_Parameter("Friction Coefficient b","b",1.89435163576232e-05);
dcMotors_Param(5) = gmt_Parameter("Friction Coefficient b","c",0.000234355495215172);
dcMotors_Param(6) = gmt_Parameter("Motor Armature Resistance","Ra",0.005);
dcMotors_Param(7) = gmt_Parameter("Motor Torque Constant","Kt",0.40);
dcMotors_Param(8) = gmt_Parameter("Thermal Convection Resistance","Ru",0.009688163543703);

% Define Each Componnet
DCMotor = gmt_DCMotor("DCMotor","ModelParameters",dcMotors_Param);
Battery = gmt_Battery("Battery","Ns",125,"Np",25);
Inverter = gmt_Inverter("Inverter");
ElBus = gmt_ElectricalBus("ElBus",1,3);
WyeToDelta = gmt_WyeToDelta("WyeToDelta");
Car = gmt_GroundVehicle("Car");

%Combine Each Component 
PrimaryObj = ...
    {
    Battery;
    Inverter
    Inverter
    WyeToDelta
    DCMotor
    };

SecondaryObj = ...
    {
     ElBus
     ElBus
     WyeToDelta
     DCMotor
     Car
     };

ObjectArray = {PrimaryObj,SecondaryObj};

PortArray = ...
    [
     1, 2;
     1, 3;
     2, 1;
     2, 1;
     3, 1; 
     ];

% file path 
FilePath = string(pwd);

% create system model 
BEV = gmt_Graph.gmt_Combine("BEV",ObjectArray,PortArray);

% convert dynamic to algebraic vertices 
BEV = gmt_Algebraic(BEV,[12,14,21,22],"BuildSim",FilePath);

% Plot Graph
%BEV.gmt_PlotGraph

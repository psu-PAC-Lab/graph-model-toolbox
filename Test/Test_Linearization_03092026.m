close all
clear all
clc
% Create Object
Motor = gmt_DCMotor("Motor");

% Linearize 
[A, B, Z] = Motor.gmt_ControlModel('NumSub',true,"Simplify",true);

dt = 0.10;

%
Ad = exp(A*dt);
syms tau
Bd = int(exp(A*tau)*B,tau,0,dt);
% need to discretize linearization 

At = matlabFunction(A);
Bt = matlabFunction(B);
Zt = matlabFunction(Z);

%Boundary Conditions 
x4 = 12; % Motor: Source Voltage(External)
x5 = 273; % Motor: Sink Temperature(External)

% Initial Conditions
x1_0 = 1;  %Motor: Current(Internal)
x2_0 = 1;  %Motor: Angular Velocity(Internal)
x3_0 = 1;  %Motor: Temperature(Internal)
y0 = [x1_0,x2_0,x3_0];

% Linearized Matrix 
Av = At(x1_0,x2_0,x3_0);
Bv = Bt(x1_0,x2_0,x3_0);
Zv = Zt(x1_0,x2_0,x3_0,x4,x5);

% Simulation Time
SimTEnd = 0.1;

% Nonlinear Simulation 
[t, y] = ode23s(@(t,y) sysFun_Motor(t,y,x4,x5), [0 SimTEnd], y0);

% Linear Simulation 
[t_lin, y_lin] = ode23s(@(t,y) sysFun_MotorLin(t,y,x4,x5,Av,Bv,Zv), [0 SimTEnd], y0);

% Plot Only Internal State Types
InternalIdx = ([Motor.Vertices.VertexType] == gmt_VertexType.Internal);
yint = y(:,InternalIdx);
NumInternal = sum(InternalIdx);
DimSubPlot = max(ceil(sqrt(NumInternal)),2);
ylabels_tmp = [Motor.Vertices(InternalIdx).VertexName];
ylabelsnew_tmp = replace(ylabels_tmp, ":", newline);
figure
for i = 1:NumInternal
    subplot(DimSubPlot,DimSubPlot,i)
    plot(t,yint(:,i),'g')
    hold on
    plot(t_lin,y_lin(:,i),'r*')
    xlabel('Time')
    ylabel(ylabelsnew_tmp(i))
end


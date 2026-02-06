u1 = 0;% MainTank: Inlet Mass Flow 1
u2 = 0;% MainTank: Outlet Mass Flow 1
u5 = 0;% RecirTank: Inlet Mass Flow 1
u6 = 0;% RecirTank: Outlet Mass Flow 1
u8 = 0;% CoolerLoad: Energy Applied
u12 = 0;% HeatLoad: Energy Applied
SimTEnd = 2000;
x1_0 = 300;  %MainTank: Tank Fluid Temperature
x2_0 = 6000;  %MainTank: Tank Mass
x3_0 = 1;  %MainTank: Delta Tank Mass
x4_0 = 1;  %MainTank: Inlet Temperature
x5_0 = 1;  %MainTank: Tank Energy Temperature
x6_0 = 1;  %TankSplit: Junction Fluid Temperature
x7_0 = 1;  %RecirTank: Tank Fluid Temperature
x8_0 = 1;  %RecirTank: Tank Mass
x9_0 = 1;  %RecirTank: Delta Tank Mass
x10_0 = 1;  %RecirTank: Tank Energy Temperature
x11_0 = 1;  %CoolerLoad: Load Temperature
x12_0 = 1;  %CoolerLoad: Energy Applied
x13_0 = 1;  %EngineSplit: Junction Fluid Temperature
x14_0 = 1;  %EngineSplit: Outlet_3
x15_0 = 1;  %HeatLoad: Load Temperature
x16_0 = 1;  %HeatLoad: Energy Applied
y0 = [x1_0,x2_0,x3_0,x4_0,x5_0,x6_0,x7_0,x8_0,x9_0,x10_0,x11_0,x12_0,x13_0,x14_0,x15_0,x16_0];
[t, y] = ode23s(@(t,y) sysFun_Combine(t,y,u1,u2,u5,u6,u8,u12), [0 SimTEnd], y0);
% Plot Only Internal State Types
InternalIdx = ([Combine.Vertices.VertexType] == gmt_VertexType.Internal);
yint = y(:,InternalIdx);
NumInternal = sum(InternalIdx);
DimSubPlot = double(int32(sqrt(NumInternal)));
ylabels_tmp = [Combine.Vertices(InternalIdx).VertexName];
ylabelsnew_tmp = replace(ylabels_tmp, ":", newline);
figure
for i = 1:NumInternal
    subplot(DimSubPlot,DimSubPlot,i)
    plot(t,yint(:,i))
    xlabel('Time')
    ylabel(ylabelsnew_tmp(i))
end

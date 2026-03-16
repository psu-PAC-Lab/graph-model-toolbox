u1 = 0;% Inlet Mass Flow 1
u2 = 0;% Energy Applied
u5 = 0;% Outlet Mass Flow 2
u6 = 0;% Inlet Mass Flow 1
u7 = 0;% Energy Applied
u8 = 0;% Inlet Mass Flow 1
u9 = 0;% Outlet Mass Flow 1
u10 = 0;% Inlet Mass Flow 1
u11 = 0;% Outlet Mass Flow 1
SimTEnd = 2000;
x1_0 = 1;  %CoolerLoad: Load Temperature(Internal-unassigned)
x2_0 = 1;  %CoolerLoad: Energy Applied(External-Source)
x3_0 = 1;  %EngineSplit: Junction Fluid Temperature(Internal-unassigned)
x4_0 = 1;  %EngineSplit: Outlet_3(External-Sink)
x5_0 = 1;  %HeatLoad: Load Temperature(Internal-unassigned)
x6_0 = 1;  %HeatLoad: Energy Applied(External-Source)
x7_0 = 1;  %MainTank: Tank Fluid Temperature(Internal-unassigned)
x8_0 = 1;  %MainTank: Tank Mass(Internal-unassigned)
x9_0 = 1;  %MainTank: Delta Tank Mass(External-Source)
x10_0 = 1;  %MainTank: Inlet Temperature(External-Source)
x11_0 = 1;  %MainTank: Tank Energy Temperature(External-Sink)
x12_0 = 1;  %RecirTank: Tank Fluid Temperature(Internal-unassigned)
x13_0 = 1;  %RecirTank: Tank Mass(Internal-unassigned)
x14_0 = 1;  %RecirTank: Delta Tank Mass(External-Source)
x15_0 = 1;  %RecirTank: Tank Energy Temperature(External-Sink)
x16_0 = 1;  %TankSplit: Junction Fluid Temperature(Internal-unassigned)
y0 = [x1_0,x2_0,x3_0,x4_0,x5_0,x6_0,x7_0,x8_0,x9_0,x10_0,x11_0,x12_0,x13_0,x14_0,x15_0,x16_0];
[t, y] = ode23s(@(t,y) sysFun_FuelSystem(t,y,u1,u2,u5,u6,u7,u8,u9,u10,u11), [0 SimTEnd], y0);
% Plot Only Internal State Types
InternalIdx = ([FuelSystem.Vertices.VertexType] == gmt_VertexType.Internal);
yint = y(:,InternalIdx);
NumInternal = sum(InternalIdx);
DimSubPlot = max(double(int32(sqrt(NumInternal))),2);
ylabels_tmp = [FuelSystem.Vertices(InternalIdx).VertexName];
ylabelsnew_tmp = replace(ylabels_tmp, ":", newline);
figure
for i = 1:NumInternal
    subplot(DimSubPlot,DimSubPlot,i)
    plot(t,yint(:,i))
    xlabel('Time')
    ylabel(ylabelsnew_tmp(i))
end

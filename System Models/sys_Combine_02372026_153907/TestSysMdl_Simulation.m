Trans = SysFin2;

u1 = 0; % "MainTank: Inlet Mass Flow 1" 
u2 = 1.5; % "MainTank: Outlet Mass Flow 2"
u5 = 0; % "RecirTank: Inlet Mass Flow 1"  
u6 = 0; % "RecirTank: Outlet Mass Flow 1"
u8 = -100000; % "CoolerLoad: Energy Applied"
u12 = 60000; % "HeatLoad: Energy Applied"   

SimTEnd = 2000;

y0 = [300, 5000, 300, 300, 300, 300, 300, 1500, 300, 300, 300, 300, 300, 300, 300, 300]; 
tic
[t, y] = ode23s(@(t,y) sysFun_Combine(t,y,u1,u2,u5,u6,u8,u12), [0 SimTEnd], y0);
tend = toc;

Sim2Real = SimTEnd/toc

% Plot Only Internal State Types
InternalIdx = ([SysFin2.Vertices.VertexType] == gmt_VertexType.Internal);
yint = y(:,InternalIdx);
NumInternal = sum(InternalIdx);
DimSubPlot = double(int32(sqrt(NumInternal)));

ylabels_tmp = [Trans.Vertices(InternalIdx).VertexName];
ylabelsnew_tmp = replace(ylabels_tmp, ":", newline);

figure
for i = 1:NumInternal
    subplot(DimSubPlot,DimSubPlot,i)
    plot(t,yint(:,i))
    xlabel('Time')
    ylabel(ylabelsnew_tmp(i))
end
u1 = 0;% MainTank: Inlet Mass Flow 1
u2 = 0;% MainTank: Outlet Mass Flow 1
u5 = 0;% RecirTank: Inlet Mass Flow 1
u6 = 0;% RecirTank: Outlet Mass Flow 1
u8 = 0;% CoolerLoad: Energy Applied
u12 = 0;% HeatLoad: Energy Applied
SimTEnd = 2000;
y0 = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1];
[t, y] = ode23s(@(t,y) sysFun_Combine(t,y,u1,u2,u5,u6,u8,u12), [0 SimTEnd], y0);
% Plot Only Internal State Types
InternalIdx = ([Combine.Vertices.VertexType] == gmt_VertexType.Internal);
yint = y(:,InternalIdx);
NumInternal = sum(InternalIdx);
DimSubPlot = double(int32(sqrt(NumInternal)));
ylabels_tmp = [Combine.Vertices(InternalIdx).VertexName];
ylabelsnew_tmp = replace(ylabels_tmp, :, newline);
figure
for i = 1:NumInternal
    subplot(DimSubPlot,DimSubPlot,i)
    plot(t,yint(:,i))
    xlabel('Time')
    ylabel(ylabelsnew_tmp(i))
end

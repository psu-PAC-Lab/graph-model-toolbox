u1 = 0;% Inlet Mass Flow 1
u2 = 1.5;% Outlet Mass Flow 1
SimTEnd = 2000;
x1_0 = 300;  %MainTank: Tank Fluid Temperature(Internal-unassigned)
x2_0 = 5000;  %MainTank: Tank Mass(Internal-unassigned)
x3_0 = 300;  %MainTank: Delta Tank Mass(External-Source)
x4_0 = 300;  %MainTank: Inlet Temperature(External-Source)
x5_0 = 300;  %MainTank: Outlet Temperature(External-Sink)
x6_0 = 300;  %MainTank: Tank Energy Temperature(External-Sink)
y0 = [x1_0,x2_0,x3_0,x4_0,x5_0,x6_0];
[t, y] = ode23s(@(t,y) sysFun_MainTank(t,y,u1,u2), [0 SimTEnd], y0);
% Plot Only Internal State Types
InternalIdx = ([MainTank.Vertices.VertexType] == gmt_VertexType.Internal);
yint = y(:,InternalIdx);
NumInternal = sum(InternalIdx);
DimSubPlot = max(double(int32(sqrt(NumInternal))),2);
ylabels_tmp = [MainTank.Vertices(InternalIdx).VertexName];
ylabelsnew_tmp = replace(ylabels_tmp, ":", newline);
figure
for i = 1:NumInternal
    subplot(DimSubPlot,DimSubPlot,i)
    plot(t,yint(:,i))
    xlabel('Time')
    ylabel(ylabelsnew_tmp(i))
end

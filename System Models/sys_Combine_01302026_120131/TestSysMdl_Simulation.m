figure
SysFin.gmt_PlotGraph 

u1 = 1.5; % MainTank: Outlet Mass Flow 1
u3 = 1.5; % RecirTank: Oulet Mass Flow 
u4 = 1.5; % RecirTank: Inlet Mass Flow
u7 = 0; %CoolerLoad: Energy Applied
u11 = 60000; % "HeatLoad: Energy Applied" 

SimTEnd = 1000;

OdeOpts = odeset('Mass', SysFin.ModelMetadata.MassMatrix, 'MassSingular', 'yes');
y0 = [300, 6000, 300, 300, 300, 300, 1500, 300, 300, 300, 300, 1 ,1, 1, 1, 1]; 
tic
[t, y] = ode23t(@(t,y) sysFun_Combine(t,y,u1,u3,u4,u7,u11), [0 SimTEnd], y0 ,OdeOpts);
tend = toc;
format long g
Sim2Real = SimTEnd/toc

Dyn_Idx = [SysFin.Vertices.StateType] == gmt_StateType.Dynamic;
Alg_Idx = [SysFin.Vertices.StateType] == gmt_StateType.Algebraic;

ylabels_tmp = [[SysFin.Vertices(Dyn_Idx).VertexName],[SysFin.Vertices(Alg_Idx).VertexName]];
ylabelsnew_tmp = replace(ylabels_tmp, ":", newline);
figure
for i = 1:sum(Dyn_Idx)
    subplot(4,4,i)
    plot(t,y(:,i))
    xlabel('Time')
    ylabel(ylabelsnew_tmp(i))
end
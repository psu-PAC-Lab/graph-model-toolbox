figure
SysFin.gmt_PlotGraph 

u1 = 3; % Main Tank: Mdot In 
u2 = u1; 
u3 = 3; % Recir Tank: Mdot Int
u4 = u3; % Recir Tank: Mdot In
u5 = 0; % Recir Tank: Mdot Out 
u6 = u3;
u7 = 0; % Cooler Load Applied
u8 = u2 + u3; % Tank Split: Mdot Out 
u9 = u3;
u11 = 60000; % Heat Load Applied

SimTEnd = 10000;

OdeOpts = odeset('Mass', SysFin.ModelMetadata.MassMatrix, 'MassSingular', 'yes');
y0 = [300, 6000, 300, 300, 300, 1500, 300, 300, 300, 300, 300, 1 ,1, 1]; 
tic
[t, y] = ode23t(@(t,y) sysFun_Combine(t,y,u1,u2,u3,u4,u5,u6,u7,u8,u9,u11), [0 SimTEnd], y0 ,OdeOpts);
tend = toc;
Sim2Real = SimTEnd/toc

Dyn_Idx = [SysFin.Vertices.StateType] == gmt_StateType.Dynamic;
Alg_Idx = [SysFin.Vertices.StateType] == gmt_StateType.Algebraic;

ylabels_tmp = [[SysFin.Vertices(Dyn_Idx).VertexName],[SysFin.Vertices(Alg_Idx).VertexName]];
figure
for i = 1:length(Dyn_Idx)
    subplot(4,4,i)
    plot(t,y(:,i))
    xlabel('Time')
    ylabel(ylabels_tmp(i))
end
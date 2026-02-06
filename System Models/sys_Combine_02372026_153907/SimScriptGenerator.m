%% Simulation Script Generator 
inputstr_tmp = [obj.InputData.VariableName]'+ " =   ;% " + [obj.InputData.Description]';
simtimstr_tmp = "SimTEnd = 2000;";
icstr_tmp = "y0 = [" + strjoin(string(ones(1,length(obj.States))),",") + "];";
sysFuncName_tmp = obj.ModelMetadata.FunctionName; 
simbody_tmp = "[t, y] = ode23s(@(t,y) " + sysFuncName_tmp + ", [0 SimTEnd], y0);";

plotstr_tmp =[... 
"% Plot Only Internal State Types";
"InternalIdx = (["+obj.Name+".Vertices.VertexType] == gmt_VertexType.Internal);";
"yint = y(:,InternalIdx);";
"NumInternal = sum(InternalIdx);";
"DimSubPlot = double(int32(sqrt(NumInternal)));";

"ylabels_tmp = [Trans.Vertices(InternalIdx).VertexName];";
"ylabelsnew_tmp = replace(ylabels_tmp, " + ":"+ ", newline);";

"figure";
"for i = 1:NumInternal";
"    subplot(DimSubPlot,DimSubPlot,i)";
"    plot(t,yint(:,i))";
"    xlabel('Time')";
"    ylabel(ylabelsnew_tmp(i))";
"end"];

SimScriptGen_mfilecode = ...
    [inputstr_tmp; ...
    simtimstr_tmp; ...
    icstr_tmp; ...
    simbody_tmp; ...
    plotstr_tmp];
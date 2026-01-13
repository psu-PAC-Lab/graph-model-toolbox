%% Automated Graph-Based Modeling Component Build Tester
% Written By Joseph Pisani Penn State University 
% Purpose: Builds each component with default settings to test graph-based model updates

tic

workspace_prev = who;

% Grab Current Directory
[currentDir, ~, ~] = fileparts(mfilename('fullpath'));

% Find Componnent Model Directory For Testing 
testDir = strcat(extractBefore(currentDir,"Toolbox Automation"),"Component Models");

all_mfiles = dir(fullfile(testDir, '**', '*.m*'));

for i = 1:length(all_mfiles)
    compMdl = extractBefore(all_mfiles(i).name,".m");
    testName = extractAfter(compMdl,"gmt_");
    myObj = feval(compMdl,testName);
end

workspace_final = who;

vars_to_remove = setdiff(workspace_final,workspace_prev);

clearvars(vars_to_remove{:})

clearvars vars_to_remove workspace_final ans

sprintf("All Components Successfully Generated. No Error Identified.")

toc
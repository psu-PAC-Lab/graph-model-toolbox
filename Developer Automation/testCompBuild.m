%% Automated Graph-Based Modeling Component Build Tester
% Written By Joseph Pisani Penn State University 
% Purpose: Builds each component with default settings to test graph-based model updates

tic

workspace_prev = who;

% Grab Current Directory
[currentDir, ~, ~] = fileparts(mfilename('fullpath'));
[~, currentFolderName, ~] = fileparts(pwd);

% Find Componnent Model Directory For Testing 
testDir = strcat(extractBefore(currentDir,currentFolderName),"Component Models");

all_mfiles = dir(fullfile(testDir, '**', '*.m*'));

for i = 1:length(all_mfiles)
    if isa(all_mfiles(i).name,"gmt_Graph")
        compMdl = extractBefore(all_mfiles(i).name,".m")
        testName = extractAfter(compMdl,"gmt_");
        na = nargin(compMdl);
        if na == -2 && ~strcmp(compMdl,"gmt_Component") 
            myObj = feval(compMdl,testName);
        end
    end
end

workspace_final = who;

vars_to_remove = setdiff(workspace_final,workspace_prev);

clearvars(vars_to_remove{:})

clearvars vars_to_remove workspace_final ans

sprintf("All Components Successfully Generated. No Error Identified.")

toc
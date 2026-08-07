clc
clearvars ME

% add test scripts file path
currentFolder = which('gmt_TestScript.m');
parentFolder = fileparts(currentFolder);
toolboxFolder = fileparts(parentFolder);
targetFolder = fullfile(parentFolder, 'test scripts');
addpath(targetFolder)

% % Run all the test scripts 
resultsUnit = run_gmtUnitTests;
disp(resultsUnit)
assert(sum([resultsUnit.Failed])==0,"Test script aborted: Unit test has more than one failure")
resultsComp = run_gmtCompTests;
disp(resultsComp)
assert(sum([resultsComp.Failed])==0,"Test script aborted: Component test has more than one failure")

% Run Tutorial Live Script 
tutorialFolder = fullfile(toolboxFolder,'doc');
tutorialFiles = dir(fullfile(tutorialFolder, '*.mlx'));

for i = 1:length(tutorialFiles)
    
    tutorialName = tutorialFiles(i).name;

    try 
        set(0, 'DefaultFigureVisible', 'off');
        evalc("run(tutorialName)");
        set(0, 'DefaultFigureVisible', 'on');
        fprintf("Sucessfully completed tutorial script file tests \n")
    catch ME
        set(0, 'DefaultFigureVisible', 'on');
        fprintf(2, 'ERROR: %s\n', ME.message);
        [~, name, ext] = fileparts(ME.stack(1).file);
        fileName_tmp = string(name) + string(ext);
        fprintf(2, 'ERROR in file: %s\n', fileName_tmp);
        fprintf(2,"Unsuccessful tutorial script file tests \n")
    end

end







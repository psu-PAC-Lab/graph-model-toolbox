%% Automated Graph-Based Modeling Toolbox Document Generator
% Written By Joseph Pisani Penn State University 
% Purpose: Autogenerate help documentations for toolbox based on toolbox mfiles
% Creates table of contents file (TOC) and html for each mfile within toolbox

%% Setup

    % Grab Previous Workspace Variables
    workspace_prev = who;
    
    % Grab Current Directory
    [currentDir, ~, ~] = fileparts(mfilename('fullpath'));
    
    % Determine Project Root
    projectRoot = extractBefore(currentDir,"\Toolbox Automation");
    genRoot = strcat(projectRoot,"\General Toolbox");
    cmpRoot = strcat(projectRoot,"\Component Models");
    outputDir_tmp = strcat(projectRoot,"\html");

%% Publish Each Mfile Code

    % Setup Publish Options 
    options.format = 'html';
    options.showCode = true;
    options.evalCode = false;
    options.catchError = false;
    %options.outputDir = outputDir_tmp;
    
    % Determine Files Within General Toolbox Root
    all_mfiles = dir(fullfile(genRoot, '**', '*.m*'));
    
    % Search Through Each File
    for i = 1:length(all_mfiles)
        publish(all_mfiles(i).name,options);
    end
    
    % Determine Files Within Component Root
    all_mfiles = dir(fullfile(cmpRoot, '**', '*.m*'));
    
    % Search Through Each File
    for i = 1:length(all_mfiles)
       publish(all_mfiles(i).name,options);
    end


%% Create Table of Contents XML File

    % Initalization 
    docNode = com.mathworks.xml.XMLUtils.createDocument('toc');
    toc = docNode.getDocumentElement;
    toc.setAttribute('version','2.0');
    
    % Identify Subfolders
    items = dir(genRoot);
    subFolders = items([items.isdir] & ~startsWith({items.name}, '.'));

    % Create TocItems

        lvl1 = docNode.createElement('tocitem');
        help_filename_tmp = 
        lvl1.setAttribute('target',help_filename_tmp);
        help_name_tmp = extractBefore(help_filename_tmp,".m");
        lvl1.appendChild(docNode.createTextNode(help_name_tmp));
        toc.appendChild(lvl1);
    
    xmlString = xmlwrite(docNode);


%% Clean Up 

    % Grab Current Variables
    workspace_final = who;
    
    % Determine Workspace Variables to Remove
    vars_to_remove = setdiff(workspace_final,workspace_prev);
    
    % Remove Workspace Variables
    clearvars(vars_to_remove{:})
    clearvars vars_to_remove workspace_final ans


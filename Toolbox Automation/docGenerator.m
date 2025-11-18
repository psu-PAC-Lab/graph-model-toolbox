workspace_prev = who;

options.format = 'html';
options.showCode = true;
options.evalCode = false;
options.catchError = false;
options.outputDir = 'C:\Users\jmp8430\Documents\Research\GraphModel_ToolboxV2\html';

projectRoot = 'C:\Users\jmp8430\Documents\Research\GraphModel_ToolboxV2';

all_mfiles = dir(fullfile(projectRoot, '**', '*.m*'));
notinclude_mfiles = dir(fullfile(projectRoot, '*.m*'));

for i = 1:length(all_mfiles)
    notinclude_logical = 0;
    
    for j = 1:length(notinclude_mfiles)
        notinclude_logical = notinclude_logical + double(strcmp(all_mfiles(i).name,notinclude_mfiles(j).name));
    end

    if notinclude_logical == 0
        publish(all_mfiles(i).name,options);
    end

end

workspace_final = who;

vars_to_remove = setdiff(workspace_final,workspace_prev);

clearvars(vars_to_remove{:})

clearvars vars_to_remove workspace_final ans


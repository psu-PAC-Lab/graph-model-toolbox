% Export a Simulink model to an older Simulink version

% baseline model
modelName = "gmt_Simulink";          % model without .slx
modelName_slx = modelName + ".slx"; 

% check original model .slx simulink version 
info = Simulink.MDLInfo(modelName_slx);
modelName_slx_ver = info.SimulinkVersion;
modelName_mtlb_ver = simulinkVersionToRelease(modelName_slx_ver);

% find support matlab versions 
supported_versions = supportedExportVersions();

% find current matlab version 
current_slx_ver = ver("simulink").Version;
current_mtlb_ver = simulinkVersionToRelease(current_slx_ver);

% create backwards compatiable version 
targetVersion = "R2023a";        % older MATLAB/Simulink version
backwardVersion = "R2025a";      % original development version 
outputFile = modelName + "_" + targetVersion + ".slx";

% if original file and current simulink version match create R2023 file 
if any(ismember(supported_versions,current_mtlb_ver))
    
    % Load the model without opening the GUI
    load_system(modelName);
    
    % Save/export to older version
    save_system(modelName, outputFile, "ExportToVersion", targetVersion);
    
    fprintf("Saved %s as %s compatible version.\n", modelName, targetVersion);

% else save original file as R2025a then create R2023a file. 
else  
    
    % Load the model without opening the GUI
    load_system(outputFile);

    % Save/export to older version
    if strcmp(backwardVersion,current_mtlb_ver)
        save_system(outputFile, modelName);
    else
        save_system(outputFile, modelName, "ExportToVersion", backwardVersion);
    end

    % Close model without saving changes to the original
    close_system(outputFile, 0);

    % Load the model without opening the GUI
    load_system(modelName);
    
    % Save/export to older version
    save_system(modelName, outputFile, ...
        "ExportToVersion", targetVersion);
    
    fprintf("Saved %s as %s compatible version.\n", modelName, targetVersion);


end

function supported_ver = supportedExportVersions()

    % Current MATLAB release (e.g. "R2024a")
    rel_str  = string(version('-release'));
    rel_char = char(rel_str);

    % Extract Current Year and Version
    year_char = rel_char(1:4);
    year = double(string(year_char));
    sub_char  = rel_char(end);

    % Simulink supports exporting up to 7 years back
    for i = 1:7
        year_tmp = year - i;
        supported_ver(2*i-1,1) = "R" + string(year_tmp) + 'a';
        supported_ver(2*i,1)   = "R" + string(year_tmp) + 'b';
    end

    % Add current version 
    current_ver = "R" + year + sub_char;

    if sub_char == 'b'
        current_ver = ["R" + year + "a"; current_ver];
    end

    % concatenate 
    supported_ver = [current_ver; supported_ver];
    
end

function release = simulinkVersionToRelease(slVersion)

    % Accept numeric or string input
    slVersion = string(slVersion);

    parts = split(slVersion, ".");
    year = str2double(parts(1));
    half = parts(2);

    matlabYear = 2000 + year;

    if half == "1"
        matlabHalf = "a";
    elseif half == "2"
        matlabHalf = "b";
    else
        error("Unsupported Simulink version: %s", slVersion);
    end

    release = "R" + matlabYear + matlabHalf;
end
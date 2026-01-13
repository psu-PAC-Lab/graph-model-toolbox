classdef mdlUpdate

    methods(Static)

        % Following properties of 'maskInitContext' are available to use:
        %  - BlockHandle 
        %  - MaskObject 
        %  - MaskWorkspace: Use get/set APIs to work with mask workspace.

        % Use the code browser on the left to add the callbacks.
      
        function GraphModelObj(callbackContext)

             % Grab User Input Variable Name
            varName = get_param(gcb, 'GraphModelObj');

            % Validate varName is in workspace
            if existsInGlobalScope(bdroot, varName)

                % Grab Workspace Data using Variable Name
                dataValue = slResolve(varName, gcb);
    
                % Validate variable is gmt_Graph object 
                if ~isa(dataValue,"gmt_Graph")
                    error("Error data type for workspace variable is not of gmt_Graph type")
                end
    
                % Grab the element of variable with mfile code
                mcode_tmp = char(join(dataValue.MfileCode, newline));

                % Grab MATLAB Simulink Function Block configuration
                MATLAB_blk_name = [gcb '/System Model Function'];
                
                rt = sfroot;

                % 3. Find the 'EMChart' (Embedded MATLAB Chart) object
                chart = rt.find('-isa', 'Stateflow.EMChart', 'Path', MATLAB_blk_name);

                % Assign mfile code data to block function script 
                chart.Script = mcode_tmp;

                % Update Port Size
                data = chart.find('-isa', 'Stateflow.Data', 'Name', 'res');
                rows = length(dataValue.MassMatrix);
                cols = 1;
                data.Props.Array.Size = ['[' num2str(rows) ' ' num2str(cols) ']'];
                
                % Constant Block
                Constant_blk_name = [gcb '/Mass Matrix'];
                matrixString = mat2str(dataValue.MassMatrix);
                set_param(Constant_blk_name,"Value",matrixString)

            else
                error("Variable name not in active workspace")
            end
                
        end
    end
end
classdef mdlUpdate

    methods(Static)

        % Following properties of 'maskInitContext' are available to use:
        %  - BlockHandle 
        %  - MaskObject 
        %  - MaskWorkspace: Use get/set APIs to work with mask workspace.
       

        % Use the code browser on the left to add the callbacks.
      
        function GraphModelObj(~)

            % Grab User Input Variable Name
            varName = get_param(gcb, 'GraphModelObj');

            % varName Workspace Validation
            if ~existsInGlobalScope(bdroot, varName)
                error('Variable name is not in active workspace. Please check.')
            else
                % Grab Workspace Data using Variable Name
                dataValue = slResolve(varName, gcb);

                % Validate variable is gmt_Graph object 
                if ~isa(dataValue,"gmt_Graph")
                    error("Error data type for workspace variable is not of gmt_Graph type")
                end

                %% Update Simulink MATLAB Function Mfile Code

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

                %% Update Mass Matrix 

                % Constant Block
                Constant_blk_name = [gcb '/Mass Matrix'];
                matrixString = mat2str(dataValue.MassMatrix);
                set_param(Constant_blk_name,"Value",matrixString)

                %% Update Demux Block

                % Demux Block 
                demux_blk_name = [gcb '/Demux'];
                num_inputs_tmp = length(dataValue.Inputs);

                %% Update Port Connections 

                % Get Handles of Blocks
                hSource = get_param(demux_blk_name, 'Handle');
                hDest   = get_param(MATLAB_blk_name, 'Handle');

                % Get Port Handles 
                phSource = get_param(hSource, 'PortHandles');
                phDest   = get_param(hDest, 'PortHandles');

                % Terminator Block
                term_blk_name = [gcb '/Terminator'];

                % Remove Terminator Block 
                if ~isempty(find_system(gcb, 'SearchDepth', 1, 'LookUnderMasks', 'all', 'FollowLinks', 'on', 'Name', 'Terminator'))
                    delete_block(term_blk_name);
                end

                % Remove All Output Port Lines of Demux 
                lines = find_system(demux_blk_name, 'LookUnderMasks', 'all', 'FindAll', 'on', 'Type', 'line');
                delete_line(lines);

                % Update Demux Ports 
                if num_inputs_tmp > 1 
                    num_inputs = char(string(num_inputs_tmp));
                    set_param(demux_blk_name,'Outputs',num_inputs)
                else
                    set_param(demux_blk_name,'Outputs','1')
                    add_block('simulink/Sinks/Terminator',term_blk_name)
                end

                if num_inputs_tmp >= 1
                    for i = 1:num_inputs_tmp
                        lineHandle = get_param(phDest.Inport(2+i), 'Line');
                        % 4. If a line exists (handle is not -1), delete it
                        if lineHandle ~= -1
                            delete_line(lineHandle);
                        end
                    end
                    % Auto Route Lines
                    for i = 1:num_inputs_tmp
                        add_line(gcb, phSource.Outport(i), phDest.Inport(2+i), 'autorouting', 'smart');
                    end

                else 
                    hDest2   = get_param(term_blk_name, 'Handle');
                    phDest2   = get_param(hDest2, 'PortHandles');
                    add_line(gcb, phSource.Outport(1), phDest2.Inport(1), 'autorouting', 'smart');

                end

                Simulink.BlockDiagram.arrangeSystem(gcb) 
                delete_line(find_system(gcb, 'FindAll', 'on', 'Type', 'line', 'Connected', 'off'))

            end
        end
    end
end
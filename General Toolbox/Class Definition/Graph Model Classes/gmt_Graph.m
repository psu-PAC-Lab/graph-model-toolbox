%% gmt_Graph
% Superclass used to create any type of graph model (Component or System)

classdef gmt_Graph
    properties (SetAccess = public)
        % User Define Meta Data
        Name string % Name of the graph model
        EdgeMatrix double % An edge matrix defining connections between edges and vertices
        Edges gmt_Edge % A vector of edge objects
        Vertices gmt_Vertex % A vector of vertex objects
        Properties gmt_GraphProperties % Object containing overall graph properties
        DiGraph % MATLAB native directed graph object
        Inputs string = [] % String array of system input variable names
        InputData gmt_Input % Input objects to replace inputs in future
        States string % String array of system state variable names
        Outputs string = [] % String array of system output variable names
        %Disturbances string = [] % String array of system disturbance variable names
        ModelParameters gmt_ModelParameter % Model parameters object to manage model parameterization  
        SystemEquations string % Symbolic system of equations for system
        InitialConditions 
        ModelMetadata = struct("ModelType",[],"MfileCode",[],"MassMatrix",[]) 
        Ports gmt_ConnectionPort % Object containing graph model connection points
    end

    %% Public Methods 
    methods (Access = public)
        %% Constructor Graph 
        function obj = gmt_Graph(Name,EdgeMatrix,Edges,Vertices,Parameters,Inputs,varargin)
            % Generates instance of gmt_Graph object
            % Assign Data
            obj.Name = Name;
            obj.EdgeMatrix = EdgeMatrix;
            obj.Edges = Edges;
            obj.Vertices = Vertices;

            % Possibly set this up for varargin 
            if ~isempty(Parameters) 
                obj.ModelParameters = Parameters;
            end

            % Possibly set this up for varargin 
            if ~isempty(Inputs)
                obj.InputData = Inputs;
                for i = 1:length(obj.InputData)
                    obj.InputData(i) = obj.InputData(i).gmt_GraphInput(obj,[obj.InputData(i).VariableName],varargin{:});
                end
            end

            % Compute Basic Graph Properties (Nv, Ne, and M) 
            obj.Properties = gmt_GraphProperties(obj);

            % DiGraph Update
            obj = gmt_DiGraphUpdate(obj);

            % Build Model
            obj = gmt_ModelUpdate(obj,varargin{:});
        end

        %% Graph Report
        % Generates then displays vertex and edge report of entire model
        function gmt_GraphReport(obj)
            % Vertex Table
            varNames_tmp = ["Vertex Name","Vertex Type","Vertex State Variable","Inputs","Capacitance","Capacitance Equation","Power Equation"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [obj.Properties.Nv length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            % Assembly Table Data 
            for i = 1:obj.Properties.Nv
                table_tmp(i,1) = {obj.Vertices(i).VertexName};
                table_tmp(i,2) = {obj.Vertices(i).VertexType};
                if isempty(obj.Vertices(i).GraphStateVariables)
                    table_tmp(i,3) = {""};
                else
                    table_tmp(i,3) = {obj.Vertices(i).GraphStateVariables};
                end
                if isempty(obj.Vertices(i).InputVariables)
                    table_tmp(i,4) = {""};
                else
                    table_tmp(i,4) = {join([obj.Vertices(i).InputVariables],", ")};
                end
                table_tmp(i,5) = {obj.Vertices(i).GraphCapacitance};
                table_tmp(i,6) = {str2sym(obj.Vertices(i).GraphCapacitanceEq)};
                table_tmp(i,7) = {str2sym(obj.Vertices(i).GraphPowerEq)};
            end

            fprintf('\n'); disp(table_tmp) 

            % Edge Table
            varNames2_tmp = ["Edge Name","Edge Type","Inputs","Edge Equation"];
            for idx2_tmp = 1:length(varNames2_tmp)
                varTypes2_tmp(1,idx2_tmp) = {'string'};
            end
            sz2 = [obj.Properties.Ne length(varNames2_tmp)];
            table2_tmp = table('Size',sz2,'VariableTypes',varTypes2_tmp,'VariableNames',varNames2_tmp);
            % Assembly Table Data 
            for i = 1:obj.Properties.Ne
                table2_tmp(i,1) = {obj.Edges(i).EdgeName};
                table2_tmp(i,2) = {obj.Edges(i).EdgeType};
                if isempty(obj.Edges(i).InputVariables)
                    table2_tmp(i,3) = {""};
                else
                    table2_tmp(i,3) = {join([obj.Edges(i).InputVariables],", ")};
                end

                table2_tmp(i,4) = {str2sym(obj.Edges(i).GraphEdgeEq)};   
            end

            fprintf('\n'); disp(table2_tmp) 

        end

        %% Parameter Report
        % Generates then displays parameter report of all model parameterization 
        function gmt_ParameterReport(obj)
            num_params = length(obj.ModelParameters);
            varNames_tmp = ["Description","Parameter", "Parameter Type"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [num_params length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            for i = 1:num_params
                table_tmp(i,1) = {obj.ModelParameters(i).Description};
                table_tmp(i,2) = {obj.ModelParameters(i).Variable};
                table_tmp(i,3) = {obj.ModelParameters(i).ParameterType};
            end

            fprintf('\n'); disp(table_tmp) 

        end

        %% Connection Report  
        % Returns the port connection data in easy to read format
        function gmt_ConnectionReport(obj)
            num_params = length(obj.Ports);
            varNames_tmp = ["Description","PortType", "Element Number"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [num_params length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            for i = 1:num_params
                table_tmp(i,1) = {obj.Ports(i).Description};
                table_tmp(i,2) = {obj.Ports(i).PortType};
                table_tmp(i,3) = {obj.Ports(i).ElementNumber};
            end

            fprintf('\n'); disp(table_tmp) 

        end

        %% Input Report  
        % Returns the port connection data in easy to read format
        function gmt_InputReport(obj)
            num_params = length(obj.InputData);
            varNames_tmp = ["Variable","Description"];
            for idx_tmp = 1:length(varNames_tmp)
                varTypes_tmp(1,idx_tmp) = {'string'};
            end
            sz = [num_params length(varNames_tmp)];
            table_tmp = table('Size',sz,'VariableTypes',varTypes_tmp,'VariableNames',varNames_tmp);
            for i = 1:num_params
                table_tmp(i,1) = {obj.InputData(i).GraphVariableName};
                table_tmp(i,2) = {obj.InputData(i).GraphDescription};
            end

            fprintf('\n'); disp(table_tmp) 

        end

        %% Full Report 
        % Generates all reports 
        function gmt_FullReport(obj)

            fprintf('\n<strong>Graph Report</strong>\n');
            gmt_GraphReport(obj)
            fprintf('<strong>Parameter Report</strong>\n');
            gmt_ParameterReport(obj)
            fprintf('<strong>Input Report</strong>\n');
            gmt_InputReport(obj)
            fprintf('<strong>Connection Port Report</strong>\n');
            gmt_ConnectionReport(obj)

        end

        %% DiGraphUpdate
        function obj = gmt_DiGraphUpdate(obj)

            % Vertex Color Coding
            for i = 1:obj.Properties.Nv
                Vertices_Names_tmp(i,1) = obj.Vertices(i).VertexName;
                if obj.Vertices(i).VertexType == gmt_VertexType.External
                    color_tmp(i,:) = [1 0 0];
                else
                    color_tmp(i,:) = [0 0 1];
                end
            end

            % Edge Color Coding 
            for i =1:obj.Properties.Ne
                Edges_Names_tmp(i,1) = obj.Edges(i).EdgeName;
                Edges_Names_celltmp{i,1} = obj.Edges(i).EdgeName;
                if obj.Edges(i).EdgeType  == gmt_EdgeType.External 
                    color_tmp2(i,:) = [1 0 0];
                else
                    color_tmp2(i,:) = [0 0 1];
                end
            end

            % Updates direct graph object propeties 
            obj.DiGraph = digraph(obj.EdgeMatrix(:,1),obj.EdgeMatrix(:,2));

            % Reorganize Edge Labels and Color Codes 
            Edges_Names_rotmp = Edges_Names_tmp;
            color_rotmp2 = color_tmp2;

            for i = 1:obj.Properties.Ne
                if ~isequal(table2array(obj.DiGraph.Edges(i,:)),obj.EdgeMatrix(i,:))
                    for j = 1:obj.Properties.Ne
                        if isequal(table2array(obj.DiGraph.Edges(i,:)),obj.EdgeMatrix(j,:))
                        Edges_Names_rotmp(i) = Edges_Names_tmp(j);
                        color_rotmp2(i) = color_tmp2(j);
                        break
                        end
                    end
                else 
                end
            end

            % Update Labels
            obj.DiGraph.Nodes.NodeLabel = Vertices_Names_tmp;
            obj.DiGraph.Edges.EdgeLabel = Edges_Names_rotmp;
            
            % Update Color
            obj.DiGraph.Nodes.NodeColor = color_tmp;
            obj.DiGraph.Edges.EdgeColor = color_rotmp2;     

        end

        %% Plot DiGraph
        % Function creates MATLAB native graph object and updates properties for plotting  
        function gmt_PlotGraph(obj)
            figure
            p = plot(obj.DiGraph,'LineWidth',1,'Layout','subspace');
            % Set Edge Labels
            p.EdgeLabel = obj.DiGraph.Edges.EdgeLabel;
            % Set Node Labels
            p.NodeLabel = obj.DiGraph.Nodes.NodeLabel;
            % Set Edge Colors
            p.EdgeColor = obj.DiGraph.Edges.EdgeColor;
            % Set Node Colors
            p.NodeColor = obj.DiGraph.Nodes.NodeColor;
            % Arrow Size
            p.ArrowSize=15;
            % Position Arrow
            p.ArrowPosition = 0.80;
            % Font Size
            p.NodeFontSize = 7;
            p.EdgeFontSize = 7;
            text(p.XData+.01, p.YData+.01 ,p.NodeLabel, ...
            'VerticalAlignment','Bottom',...
            'HorizontalAlignment', 'left',...
            'FontSize', 7)
            p.NodeLabel = {}; 

        end
       
        %% Model Update 
        % Once all vertices, edges, and edge matrix has been defined a model can be generated 
        function obj = gmt_ModelUpdate(obj,varargin)

            % Varagin Input Argument Parsing 
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'BuildModel', false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'SystemModel',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'CombineInputs', [], @(s) isstring(s) && size(s,2) == 2);
            parse(p, varargin{:});
            CombineInputs = p.Results.CombineInputs;
            makeFunc_mfile  = p.Results.BuildModel;
            componentMdl = ~p.Results.SystemModel;

            % Updates graph properties object and performs validation checks
            if obj.Properties.GraphValidity.GraphValid && obj.Properties.GraphValidity.VerticesValid && obj.Properties.GraphValidity.EdgesValid
                % Compute Boundary Vertices
                obj.Properties.Ns = 0;
                for j = 1:obj.Properties.Nv
                    % Grab non-zero elements on each vertices 
                    tmp = obj.Properties.M(j,obj.Properties.M(j,:)~=0);
                    % Determine total number of edges
                    tmp_lgth = length(tmp);
                    % Take the max of all positive or all negative
                    tmp_sum = max(sum(abs(tmp(tmp==-1))),sum(tmp(tmp==1)));
                    % If all the elements match one direction, it is a boundary vertex
                    V_bv(j) = logical(tmp_sum == tmp_lgth);
                    % Update exogeny of each vertex 
                    % obj.Vertices(j) = obj.Vertices(j).gmt_VertexTypeUpdate(V_bv(j)); 
                    % if obj.Vertices(j).VertexType == gmt_VertexType.Internal
                    %     obj.Properties.Ns = obj.Properties.Ns + 1;
                    %     obj.Vertices(j) = obj.Vertices(j).gmt_VertexStateVariableUpdate(obj.Properties.Ns);
                    % end
                end
            elseif not(obj.Properties.GraphValidity.GraphValid)
                error('Error: Edge Matrix is not properly defined. Number of vertices must be greater than or equal to the number of edges')
            elseif not(obj.Properties.GraphValidity.VerticesValid)
                error('Error: Number of Vertices specified does not match dimensions of Edge Matrix')
            elseif not(obj.Properties.GraphValidity.EdgesValid)
                error('Error: Number of Edges specified does not match dimensions of Edge Matrix')
            end

            Tot_Ds_num = 0;
            Tot_As_num  = 0;
            Tot_y_num = 0;

            % Update Graph Specific State and State Derivative Variables 
            for i = 1:obj.Properties.Nv
                
                Ds_var_tmp = [];
                As_var_tmp = [];
                y_var_tmp = [];

                Ds_var = obj.Vertices(i).StateDerVariables; % Grab vertex specific dynamic state variables name
                Num_Ds = obj.Vertices(i).NvSd; % Grab total number of dynamic state varables 
                As_var = obj.Vertices(i).StateVariables; % Grab vertex specific dynamic state variables name
                Num_As = max(obj.Vertices(i).NvSa,obj.Vertices(i).NvS); % Grab total number of algebraic state varables
                V_var = obj.Vertices(i).OutputVariables; % Grab vertex specific output variables 
                Num_y = obj.Vertices(i).NvY; % Grab total number of output variables 

                if isa(Num_Ds,'double') && Num_Ds ~= 0
                    Tot_Ds_num = (1:Num_Ds) + Tot_Ds_num(end); % Compute graph specific dynamic state variable numbering 
                    if Num_Ds == 1 && strlength(extractAfter(extractBefore(Ds_var,"_dot"),"x")) == 0
                        Ds_var_tmp = strcat("x",num2str(Tot_Ds_num),"_dot");
                    else
                        Ds_var_tmp = regexprep(Ds_var, '\d+', '${num2str(Tot_Ds_num(str2double($0)))}');
                    end
                end

                if isa(Num_As,'double') && Num_As ~= 0
                    Tot_As_num = (1:Num_As) + Tot_As_num(end); % Compute graph specific algebraic state variable numbering
                    if Num_As == 1 && strlength(extractAfter(As_var,"x")) == 0
                        As_var_tmp = strcat("x",num2str(Tot_As_num));
                    else
                        As_var_tmp = regexprep(As_var, '\d+', '${num2str(Tot_As_num(str2double($0)))}');
                    end
                end

                if isa(Num_y,"double") && Num_y ~= 0
                    Tot_y_num = (1:Num_y) + Tot_y_num(end);
                    if Num_y == 1 && strlength(extractAfter(V_var,"y")) == 0
                        y_var_tmp = strcat("y",num2str(Tot_y_num));
                    else
                        y_var_tmp = regexprep(As_var, '\d+', '${num2str(Tot_As_num(str2double($0)))}');
                    end
                end

                obj.Vertices(i) = obj.Vertices(i).gmt_GraphVertexUpdate(Ds_var_tmp,As_var_tmp,y_var_tmp);

                % Update Head and State Vertices Numbers
                for j = 1:obj.Properties.Ne 
                    % Prepare to update graph model 
                    obj.Edges(j) = obj.Edges(j).gmt_EdgeGraphModelUpdate();
                    
                    %if obj.Edges(j).NeHS > 0 && obj.Properties.M(i,j) == 1
                    if obj.Properties.M(i,j) == 1
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateHeadVertexNum(i);
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateGraphHeadStateVar(obj.Vertices(i).GraphStateVariables);
                     
                    %elseif obj.Edges(j).NeTS > 0 && obj.Properties.M(i,j) == -1
                    elseif obj.Properties.M(i,j) == -1
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateTailVertexNum(i);
                       obj.Edges(j) = obj.Edges(j).gmt_UpdateGraphTailStateVar(obj.Vertices(i).GraphStateVariables);
                    end
                end


            end

            % Update System Variables

            % Update System State Variables
            state_vars_tmp = unique([obj.Vertices.GraphStateVariables]);
            state_nums_tmp = str2double(extractAfter(state_vars_tmp, "x"));
            [~, idx] = sort(state_nums_tmp);
            state_vars_sorted_tmp = state_vars_tmp(idx);
            obj.States = state_vars_sorted_tmp;

            % Update System Input Variables
            if ~isempty([obj.Vertices.InputVariables]) || ~isempty([obj.Edges.InputVariables])
                input_vars_tmp = unique([[obj.Vertices.InputVariables],[obj.Edges.InputVariables]]);
                input_nums_tmp = str2double(extractAfter(input_vars_tmp, "u"));
                [~, idx] = sort(input_nums_tmp);
                input_vars_sorted_tmp = input_vars_tmp(idx);
                obj.Inputs = input_vars_sorted_tmp;
            end

            % Update System Output Variables 
            output_vars_tmp = unique([obj.Vertices.GraphOutputVariables]);
            output_nums_tmp = str2double(extractAfter(output_vars_tmp, "y"));
            [~, idx] = sort(output_nums_tmp);
            output_vars_sorted_tmp = output_vars_tmp(idx);
            obj.Outputs = output_vars_sorted_tmp;

            % Update System Disturbance Variables 

            % Update Power Equation for Each Edge
            for i = 1:obj.Properties.Nv 
                NvE_tmp = sum(abs(obj.Properties.M(i,:))==1);
                EdgeNum_tmp = find(abs(obj.Properties.M(i,:))==1);
                EdgeNumStr_tmp = string(obj.Properties.M(i,EdgeNum_tmp));
                
                % Define search terms (Longest/most specific first)
                oldVals = {'-1', '1'};

                % Define corresponding replacements
                newVals = {'-', '+'};
                
                % Perform the replacement across the whole cell array
                [oldVals_common, ia, ib] = intersect(EdgeNumStr_tmp, oldVals);
                newVals_common =  string(newVals(ib));
                Operator_tmp = replace(EdgeNumStr_tmp, oldVals_common, newVals_common);
                EdgeEq_tmp = "(" + [obj.Edges(EdgeNum_tmp).GraphEdgeEq] + ")";
                PowerEq_tmp = strjoin(Operator_tmp + EdgeEq_tmp,'');
                obj.Vertices(i) = obj.Vertices(i).gmt_GraphVertexEqUpdate(PowerEq_tmp,NvE_tmp);
            end

            % Determine Equations for Stacking 
            IntVertices_idx = find([obj.Vertices.StateType] == gmt_StateType.Dynamic);
            ScalarParams_idx = find([obj.ModelParameters.ParameterType] == gmt_ParameterType.Scalar);
            LookupParams_idx = find([obj.ModelParameters.ParameterType] == gmt_ParameterType.Lookup);
            NNParams_idx = find([obj.ModelParameters.ParameterType] == gmt_ParameterType.Neural_Network);
            OutVertices_idx = find([obj.Vertices.StateType] == gmt_StateType.Algebraic);

            % Create string expression for each type
            sys_dyneq_str_tmp = [obj.Vertices(IntVertices_idx).GraphStateDerVariables]' + " = " + [obj.Vertices(IntVertices_idx).GraphVertexEq]' + ";";
            sys_algeq_str_tmp = [obj.Vertices(OutVertices_idx).GraphOutputVariables]' + " = " + [obj.Vertices(OutVertices_idx).GraphVertexEq]' + ";";

            % Stack string expression on top of each other
            sys_eq_str_tmp = [sys_dyneq_str_tmp;sys_algeq_str_tmp];

            % Create a MATLAB symbolic equation 
            obj.SystemEquations = sys_eq_str_tmp; %str2sym(sys_eq_str_tmp);

            % Determine Model Type 
            if any([obj.ModelParameters.ParameterType] == gmt_ParameterType.Lookup) || any([obj.ModelParameters.ParameterType] == gmt_ParameterType.Neural_Network)
                obj.ModelMetadata.ModelType = gmt_ModelType.Numerical;
            else
                obj.ModelMetadata.ModelType = gmt_ModelType.Analytical;
            end

            if componentMdl
                % Append Edge and Vertex Names By Component Name
                for i = 1:length(obj.Edges)
                    obj.Edges(i).EdgeName = obj.Name + ": " + obj.Edges(i).EdgeName; 
                end
    
                for j = 1:length([obj.Vertices])
                    obj.Vertices(j).VertexName = obj.Name + ": " + obj.Vertices(j).VertexName; 
                end
            end

            [Akeep, ia, ib] = intersect([obj.Inputs],[obj.InputData.GraphVariableName], 'stable');
            InputData_Match_tmp = ismember([obj.InputData.GraphVariableName],Akeep);
            obj.InputData = obj.InputData(InputData_Match_tmp);

            %% Create System Model in M File          
            if makeFunc_mfile 

                % System Function Header
                if ispc
                    user = getenv('USERNAME');
                else
                    user = getenv('USER');
                end

                sysfun_mfile_preheader = "% Code-Auto Generated By " + user + " using gmt Toolbox on " + string(datetime);

                if ~isempty(obj.Inputs)
                    sysfun_mfile_header = "function res = sysFun_" + obj.Name + "(t,y," + strjoin([obj.Inputs],",") + ")";
                else
                    sysfun_mfile_header = "function res = sysFun_" + obj.Name + "(t,y)";
                end
                sysfun_mfile_footer = "end";
    
                % System Function Input Parser 
                inputvar_list = [[obj.Vertices(IntVertices_idx).GraphStateVariables]';[obj.Vertices(OutVertices_idx).GraphOutputVariables]'];
                unpackingCode = "";
                for i = 1:length(inputvar_list)
                    unpackingCode(i) = inputvar_list(i) + " = y(" + i + ");";
                end
                
                sysfun_mfile_prefix = unpackingCode';

                % System Model Parameters Parser 

                % Scalars 
                sysfun_mfile_scalars = [obj.ModelParameters(ScalarParams_idx).Variable]' + " = " + [obj.ModelParameters(ScalarParams_idx).Data]' + ";";

                % Lookup
                if ~isempty(LookupParams_idx)

                    fields = fieldnames(obj.ModelParameters(LookupParams_idx).Data);
                    mFileLines = cell(length(fields), 1);
                    
                    % Loop through fields to create "LHS = RHS;" strings
                    for i = 1:numel(fields)
                        fieldName = fields{i};
                        val = obj.ModelParameters(LookupParams_idx).Data.(fieldName); % Dynamic access
                    
                        if ischar(val) || isstring(val)
                            % Format: FieldName = 'StringData';
                            rhs = sprintf("'%s'", val);
                    
                        elseif isnumeric(val) || islogical(val)
                            % Format: FieldName = [1 0; 0 1]; or FieldName = 5;
                            % mat2str handles the brackets and semicolon for matrices
                            rhs = mat2str(val);
                    
                        else
                            % Fallback for empty or unsupported types
                            rhs = '[]';
                        end
                    
                        % Combine into the final assignment string
                        mFileLines{i} = sprintf('%s = %s;', fieldName, rhs);
                    end
    
                    sysfun_mfile_lookup_tmp = string(mFileLines);

                    % Find if user specified function lookup outside of edge equation 
                    sysfun_lookup_func_idx_tmp = find(contains([obj.ModelParameters(LookupParams_idx).Variable],"="));
                    sysfun_lookup_func_idx = LookupParams_idx(sysfun_lookup_func_idx_tmp);

                    if ~isempty(sysfun_lookup_func_idx)
                        sys_mfile_lookup2_tmp = [obj.ModelParameters(sysfun_lookup_func_idx).Variable] + ";";
                    else
                        sys_mfile_lookup2_tmp = [];
                    end

                    sysfun_mfile_lookup = [sysfun_mfile_lookup_tmp;sys_mfile_lookup2_tmp];

                else 

                    sysfun_mfile_lookup = [];

                end

                % Neural Networks 

                % System Output Packager 
                outputvar_list = [[obj.Vertices(IntVertices_idx).GraphStateDerVariables]';[obj.Vertices(OutVertices_idx).GraphOutputVariables]' + "_"];
                packingCode = "res = [" + strjoin(outputvar_list',";") + "];";
                sysfun_mfile_suffix = packingCode';
    
                % System Function Body 
                % Create string expression for each type
                sys_dyneq_str_tmp = [obj.Vertices(IntVertices_idx).GraphStateDerVariables]' + " = " + [obj.Vertices(IntVertices_idx).GraphVertexEq]' + ";";
                sys_algeq_str_tmp = [obj.Vertices(OutVertices_idx).GraphOutputVariables]'+ "_ = " + [obj.Vertices(OutVertices_idx).GraphVertexEq]' + "-" + [obj.Vertices(OutVertices_idx).GraphOutputVariables]' + ";";
    
                % Stack string expression on top of each other
                sys_eq_str_tmp = [sys_dyneq_str_tmp;sys_algeq_str_tmp];
    
                sysfun_mfile_body = sys_eq_str_tmp;
    
                sysfun_mfile_combined = ...
                    [
                    sysfun_mfile_preheader; ...
                    sysfun_mfile_header;...
                    sysfun_mfile_scalars;...
                    sysfun_mfile_lookup;...
                    sysfun_mfile_prefix;...
                    sysfun_mfile_body;...
                    sysfun_mfile_suffix;...
                    sysfun_mfile_footer];

                obj.ModelMetadata.MfileCode = sysfun_mfile_combined;

                gmt_root = string(extractBefore(which('gmt_Graph.m'),'\General Toolbox'));
                sys_mdl_flder_tmp = "\System Models\";
                sysfun_filename_tmp = "sysFun_" + obj.Name + ".m";
                sysobj_filename_tmp = "sysObj_" + obj.Name + ".mat";
                sysname_tmp = "sys_" + obj.Name;

                date_tmp = string(datetime('now','Format','MMDDyyy'));
                time_tmp = string(datetime('now','Format','HHmmss'));

                sys_bld_flder_tmp = sysname_tmp + "_" + date_tmp +  "_" + time_tmp;
                sys_bld_path_tmp = gmt_root + sys_mdl_flder_tmp + sys_bld_flder_tmp;

                mkdir(sys_bld_path_tmp)

                sysfun_file_save_path = sys_bld_path_tmp + "\" + sysfun_filename_tmp;
                sysobj_file_save_path = sys_bld_path_tmp + "\" + sysobj_filename_tmp;
    
                writelines(sysfun_mfile_combined, sysfun_file_save_path);

                save(sysobj_file_save_path, "obj")
    
                % Create DAE Mass Matrix 
                NsD_tmp = sum(([obj.Vertices.StateType]==gmt_StateType.Dynamic));
                NsA_tmp = sum(([obj.Vertices.StateType]==gmt_StateType.Algebraic));

                obj.ModelMetadata.MassMatrix = blkdiag(eye(NsD_tmp),zeros(NsA_tmp));

            end

        end
        
        %% Input Commonization 
        function obj = gmt_InputCommon(obj,varargin)

            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'BuildModel', false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'SystemModel',false, @(x) islogical(x) && isscalar(x));
            addParameter(p, 'CombineInputs', [], @(s) isstring(s) && size(s,2) == 2);
            parse(p, varargin{:});
            CombineInputs = p.Results.CombineInputs;
            makeFunc_mfile  = p.Results.BuildModel;
            componentMdl = ~p.Results.SystemModel;
    
            for i = 1:length(obj.Edges)  
                EdgeEq_tmp(i) = replace(obj.Edges(i).EdgeEq,CombineInputs(:,1),CombineInputs(:,2));
                
                if obj.Edges(i).EdgeType == gmt_EdgeType.External
                    Edge_Updated(i) = gmt_Edge(obj.Edges(i).EdgeName,EdgeEq_tmp(i),string(obj.Edges(i).EdgeType));
                else
                    Edge_Updated(i) = gmt_Edge(obj.Edges(i).EdgeName,EdgeEq_tmp(i));
                end
    
            end
    
            for j = 1:length(obj.Vertices)  
                VerticesCapacitanceEq_tmp(j) = replace(obj.Vertices(j).CapacitanceEq,CombineInputs(:,2),CombineInputs(:,1));
    
                if obj.Vertices(j).VertexType == gmt_VertexType.External
                    Vertex_Updated(j) = gmt_Vertex(obj.Vertices(j).VertexName,VerticesCapacitanceEq_tmp(j),string(obj.Vertices(j).VertexType));
                else
                    Vertex_Updated(j) = gmt_Vertex(obj.Vertices(j).VertexName,VerticesCapacitanceEq_tmp(j));
                end
    
            end
    
            obj.Edges = Edge_Updated;
            obj.Vertices = Vertex_Updated;

            obj = gmt_Graph(obj.Name,obj.EdgeMatrix,obj.Edges,obj.Vertices,obj.ModelParameters,obj.InputData,varargin{:});

        end

    end
    %% Static Public Methods
    methods (Static)
        %% Graph Simple Combination Function NOTE: Need to work on algorithm   
        % Algorithm for connection two components together
        function objC = gmt_CombineSimple(objA, objB, Connection, varargin)

            %% Setup and Data Validation 
            % Data Validation 
            PortA_tmp = objA.Ports(Connection(1)).PortType;
            PortB_tmp = objB.Ports(Connection(2)).PortType;
            assert(PortA_tmp == PortB_tmp,"Connection Type Does Not Match") 

            % Component Incidence Matrices 
            M_a = objA.Properties.M;
            M_b = objB.Properties.M;

            % Create Object Placeholders for Equation Editing. 
            objA_tmp = objA;
            objB_tmp = objB;

            %% Varagin Proccessing     
            % Input Parsing and Data Validation 
            p = inputParser;
            p.KeepUnmatched = true;
            addParameter(p, 'CombineInputs', [], @(s) isstring(s) && size(s,2) == 2);
            parse(p, varargin{:});
            CommonInputs = p.Results.CombineInputs;
            TotNumCommonInputPairs = size(CommonInputs,1);
            %% Vertex Connection Case
            if objA.Ports(Connection(1,1)).PortType == gmt_PortType.VertexConnection

                %% Setup and Data Validation 
                Vertex_A = objA.Ports(Connection(1)).ElementNumber;
                Vertex_B = objB.Ports(Connection(2)).ElementNumber;

                VertexA_CapEq = objA.Vertices(Vertex_A).CapacitanceEq;
                VertexB_CapEq = objB.Vertices(Vertex_B).CapacitanceEq;
 
                assert(~strcmp(VertexA_CapEq,VertexB_CapEq),"Vertices do not share common capacitance equation")

                %% Incidence Matrix Creation 
                % Append Edges to Common Vertex
                M_c = zeros((size(M_a,1)+size(M_b,1)-1),(size(M_a,2)+size(M_b,2)));
                M_c(1:size(M_a,1),1:size(M_a,2)) = M_a;
                M_c(Vertex_A,size(M_a,2)+1:end) = M_b(Vertex_B,:);
                M_b_idx = 1:size(M_b,1);
                M_b_idx(Vertex_B) = [];
                M_c(size(M_a,1)+1:end,size(M_a,2)+1:end) = M_b(M_b_idx,:);

                %% Create New Edge and Vertex Vectors
                Vertices_New = [objA.Vertices,objB.Vertices(M_b_idx)];
                Edges_New = [objA.Edges,objB.Edges];

                %% Construct New Edge Matrix from Incidence
                for i = 1:size(M_c,2)
                    for j = 1:size(M_c,1)
                        idx_tmp = M_c(j,i);
                        if idx_tmp == 1
                            EdgeMatrix_New(i,2) = j;             
                        elseif idx_tmp == -1
                            EdgeMatrix_New(i,1) = j;
                        end
                    end
                end       

            %% Edge Connection Case
            elseif objA.Ports(Connection(1)).PortType == gmt_PortType.EdgeConnection

                %% Setup and Data Validation  
                Edge_A = objA.Ports(Connection(1)).ElementNumber;
                Edge_B = objB.Ports(Connection(2)).ElementNumber;

                % Vertex Removal Analysis 
                % Edge A
                EA_hvn = objA.Edges(Edge_A).HeadVertexNum;
                EA_tvn = objA.Edges(Edge_A).TailVertexNum;
                % Edge B
                EB_hvn = objB.Edges(Edge_B).HeadVertexNum;
                EB_tvn = objB.Edges(Edge_B).TailVertexNum;

                % EdgeA HeadTail Vertex Assignment
                if objA.Vertices(EA_hvn).GraphNvE == 1
                    EA_v2r = EA_hvn;
                elseif objA.Vertices(EA_tvn).GraphNvE == 1
                    EA_v2r = EA_tvn;
                else
                    error("New case identified, notify developer")
                end

                % EdgeB HeadTail Vertex Assignment
                if objB.Vertices(EB_hvn).GraphNvE == 1
                    EB_v2r = EB_hvn;
                elseif objB.Vertices(EB_tvn).GraphNvE == 1
                    EB_v2r = EB_tvn;
                else
                    error("New case identified, notify developer")
                end
                
                %% Incidence Matrix Creation 
                M_a_vidx = 1:size(M_a,1);
                M_a_vidx(EA_v2r) = [];
                M_b_vidx = 1:size(M_b,1);
                M_b_vidx(EB_v2r) = [];

                % Update Component and System Incidene Matrix 
                M_a = M_a(M_a_vidx,:);
                M_b = M_b(M_b_vidx,:);
                M_c = zeros((size(M_a,1)+size(M_b,1)),(size(M_a,2)+size(M_b,2)-1));

                % Construct Incidence Matrix
                M_c(1:size(M_a,1),1:size(M_a,2)) = M_a;
                if sum(M_a(:,Edge_A)) == -1
                    M_c(size(M_a,1)+1:end,Edge_A) = abs(M_b(:,Edge_B));
                else 
                    M_c(size(M_a,1)+1:end,Edge_A) = -1*abs(M_b(:,Edge_B));
                end
                M_b_eidx = 1:size(M_b,2);
                M_b_eidx(Edge_B) = [];
                M_c(size(M_a,1)+1:end,size(M_a,2)+1:end) = M_b(:,M_b_eidx);

                %% Input Variable Assignment 
                EdgeA_inputs = objA.Edges(Edge_A).InputVariables;
                EdgeB_inputs = objB.Edges(Edge_B).InputVariables;
                assert(length(EdgeA_inputs)==length(EdgeB_inputs),"Each edge equation has a unique number of control inputs")

                % Inputs Variable Update
                % Assumption all inputs are unique unless otherwise specified or identified 
                AllInputsA = unique([[objA.Vertices.InputVariables],[objA.Edges.InputVariables]]);
                TotNumInputsA = length(AllInputsA);
                AllInputsB = unique([[objB.Vertices.InputVariables],[objB.Edges.InputVariables]]);
                TotNumInputsB = length(AllInputsB);

                InputNewNumsB = TotNumInputsA+1:(TotNumInputsA+TotNumInputsB);
                NewInputsB = "u" + string(InputNewNumsB);

                % Renumber objB based on number of inputs in object A and object B 
                for i = 1:length(objB_tmp.Edges)  
                    objB_tmp.Edges(i).EdgeEq = replace(objB_tmp.Edges(i).EdgeEq,AllInputsB,NewInputsB);
                end

                for j = 1:length(objB_tmp.Vertices)
                    objB_tmp.Vertices(j).CapacitanceEq = replace(objB_tmp.Vertices(j).CapacitanceEq,AllInputsB,NewInputsB);
                end

                for k = 1:length(objB_tmp.InputData)
                    objB_tmp.InputData(k).VariableName = replace(objB_tmp.InputData(k).VariableName,AllInputsB,NewInputsB);
                end

                % Edge Input Commonization 
                NewInputsEdgeBNum = double(extractAfter(EdgeB_inputs, "u")) + TotNumInputsA;
                NewInputsEdgeB_rep = "u" + string(NewInputsEdgeBNum);

                % User Defined INput Commonization 
                if ~isempty(CommonInputs)
                    EdgeA_ComInputs_user = CommonInputs(:,1); 
                    UserInputsEdgeBNm = double(extractAfter(CommonInputs(:,2), "u")) + TotNumInputsA;
                    UserInputsEdgeB_rep = "u" + string(UserInputsEdgeBNm);
                else
                    EdgeA_ComInputs_user = [];
                    UserInputsEdgeBNm = [];
                    UserInputsEdgeB_rep = [];
                end

                % % Setup Replacement Vectors
                % EdgeA_Input_vector = unique([EdgeA_inputs; EdgeA_ComInputs_user]);
                % EdgeBNew_Input_vector = unique([NewInputsEdgeB_rep; UserInputsEdgeB_rep]);
                % assert(length(EdgeA_Input_vector)==length(EdgeBNew_Input_vector),"The number of inputs being replaced does not match, check user defined common input.")
                % 
                % if length(EdgeA_Input_vector) ~= length([EdgeA_inputs; EdgeA_ComInputs_user]) || length(EdgeBNew_Input_vector) ~= length([NewInputsEdgeB_rep; UserInputsEdgeB_rep])
                %     warning("Note: User defined common control inputs matches automated edge commonization pair. User defined commonization likely not required.")
                % end
                % 
                % for i = 1:length(objB_tmp.Edges)
                %     objB_tmp.Edges(i).EdgeEq = replace(objB_tmp.Edges(i).EdgeEq,EdgeBNew_Input_vector,EdgeA_Input_vector);
                % end
                % 
                % for j = 1:length(objB_tmp.Vertices)
                %     objB_tmp.Vertices(j).CapacitanceEq = replace(objB_tmp.Vertices(j).CapacitanceEq,EdgeBNew_Input_vector,EdgeA_Input_vector);
                % end
           
                %% Create New Edge and Vertex Vectors 
                % Join the edges and vertex arrays together less the remove or common elements 
                VerticesNew = [objA_tmp.Vertices(M_a_vidx),objB_tmp.Vertices(M_b_vidx)];
                EdgeNew = [objA_tmp.Edges,objB_tmp.Edges(M_b_eidx)];
                InputsNew = [objA_tmp.InputData,objB_tmp.InputData];

                % Update Vertex Objects
                for i = 1:length(VerticesNew)
                    if VerticesNew(i).VertexType == gmt_VertexType.External
                        VertexUpdated(i) = gmt_Vertex(VerticesNew(i).VertexName,VerticesNew(i).CapacitanceEq,string(VerticesNew(i).VertexType));
                    else
                        VertexUpdated(i) = gmt_Vertex(VerticesNew(i).VertexName,VerticesNew(i).CapacitanceEq);
                    end
                end

                % Update Edge Objects
                for j = 1:length(EdgeNew)
                    if string(EdgeNew(j).EdgeType) == gmt_EdgeType.External
                        EdgeUpdated(j) = gmt_Edge(EdgeNew(j).EdgeName,EdgeNew(j).EdgeEq,string(EdgeNew(j).EdgeType));
                    else
                        EdgeUpdated(j) = gmt_Edge(EdgeNew(j).EdgeName,EdgeNew(j).EdgeEq);
                    end
                end

                for k = 1:length(InputsNew)
                        InputsUpdated(k) = gmt_Input(InputsNew(k).VariableName,InputsNew(k).GraphDescription);
                end

                %% Construct New Edge Matrix from Incidence
                for i = 1:size(M_c,2)
                    for j = 1:size(M_c,1)
                        idx_tmp = M_c(j,i);
                        if idx_tmp == 1
                            EdgeMatrix_New(i,2) = j;             
                        elseif idx_tmp == -1
                            EdgeMatrix_New(i,1) = j;
                        end
                    end
                end   

            end

            %% Update Model Parameterization 
            % Need to be able to handle cases where variable is same between multiple models but needs to be unique and vice versa
            Params_New = [objA_tmp.ModelParameters, objB_tmp.ModelParameters];
            [C, ia, ic] = unique([Params_New.Variable]);
            Params_New = Params_New(ia);

            %% Update System Port Connections 
            PortsA_idx = 1:length(objA_tmp.Ports);
            PortsA_idx_keep = setdiff(PortsA_idx,Connection(1));
            PortsA = objA_tmp.Ports(PortsA_idx_keep);

            PortsB_idx = 1:length(objB_tmp.Ports);
            PortsB_idx_keep = setdiff(PortsB_idx,Connection(2));
            PortsB = objB_tmp.Ports(PortsB_idx_keep);

            % Update EdgeType Port Element Numbering
            EdgeB_NumOld = 1:length(objB.Edges);
            EdgeB_NumOld(Edge_B) = [];
            EdgeB_NumNew = (length(objA.Edges)+1):size(M_c,2);
            PortB_Edge_idx = find([PortsB.PortType] == gmt_PortType.EdgeConnection);
            [tf, loc] = ismember([PortsB(PortB_Edge_idx).ElementNumber], EdgeB_NumOld);
            PortB_ElNumNew = EdgeB_NumNew(loc(tf));  
            PortB_EdgeLookup_idx = PortB_Edge_idx(tf);

            for i = 1:length(PortB_ElNumNew)
                PortsB(PortB_EdgeLookup_idx(i)).ElementNumber = PortB_ElNumNew(i);
            end

            % Update VertexType Port Element Numbering
            VerticesB_NumOld = 1:length(objB.Vertices);
            VerticesB_NumOld(EB_v2r) =[];
            VerticesB_NumNew = length(objA.Vertices):size(M_c,1);
            % Determine indices with vertex connection 
            PortB_Vertex_idx = find([PortsB.PortType] == gmt_PortType.VertexConnection);
            % Determine required mapping 
            [tf2, loc2] = ismember([PortsB(PortB_Vertex_idx).ElementNumber], VerticesB_NumOld);
            PortB_ElNumNew2 = VerticesB_NumNew(loc2(tf2));  
            PortB_VertexLookup_idx = PortB_Vertex_idx(tf2);

            % Need to index properly here
            for i = 1:length(PortB_ElNumNew2)
                PortsB(PortB_VertexLookup_idx(i)).ElementNumber = PortB_ElNumNew2(i);
            end
                
            % Find Unique Edge Port Connections and Vertex Port Connections
            PortA_Edge_idx = [PortsA.PortType]==gmt_PortType.EdgeConnection;
            PortA_Vertex_idx = [PortsA.PortType]==gmt_PortType.VertexConnection;

            PortB_Edge_idx = [PortsB.PortType]==gmt_PortType.EdgeConnection;
            PortB_Vertex_idx = [PortsB.PortType]==gmt_PortType.VertexConnection;

            Common_Edge_PortsElNum = intersect([PortsA(PortA_Edge_idx).ElementNumber],[PortsB(PortB_Edge_idx).ElementNumber]);
            Common_Vertex_PortsElNum = intersect([PortsA(PortA_Vertex_idx).ElementNumber],[PortsB(PortB_Vertex_idx).ElementNumber]);

            PortB_tmp = [];
            if ~isempty(Common_Edge_PortsElNum)
                PortB_tmp = PortsB([PortsB.ElementNumber] ~= Common_Edge_PortsElNum);
            end

            if ~isempty(Common_Vertex_PortsElNum)
                PortB_tmp = [PortB_tmp; PortsB([PortsB.ElementNumber] ~= Common_Vertex_PortsElNum)];
            end

            if isempty(Common_Edge_PortsElNum) && isempty(Common_Vertex_PortsElNum)
                PortB_tmp = PortsB;
            end

            Ports_tmp = [PortsA(:); PortB_tmp(:)]';


            %% BuildGraphModel 
            objC = gmt_Graph("Combine",EdgeMatrix_New,EdgeUpdated,VertexUpdated,Params_New,InputsUpdated,varargin{:});
            %% Create New Port Objects
            for i = 1:length(Ports_tmp)
                objC.Ports(i) = gmt_ConnectionPort(objC,string(Ports_tmp(i).PortType),Ports_tmp(i).ElementNumber,string(Ports_tmp(i).EnergyDomain));
            end

        end

        %% System Connection Graph
        % Algorithm for closing system
        function obj = gmt_CombineSys(obj,Connection,varargin)

            assert(obj.Ports(Connection(1)).PortType == obj.Ports(Connection(2)).PortType,"Connection Type Does Not Match") 

            if obj.Ports(Connection(1)).PortType == gmt_PortType.EdgeConnection

                obj_tmp = obj;

                % Grab Edge Element Numbers  
                Edge_A = obj.Ports(Connection(1)).ElementNumber;
                Edge_B = obj.Ports(Connection(2)).ElementNumber;

                % Determine Vertex to remove from each 
                EA_hvn = obj.Edges(Edge_A).HeadVertexNum;
                EA_tvn = obj.Edges(Edge_A).TailVertexNum;

                if obj.Vertices(EA_hvn).GraphNvE == 1
                    EA_v2r = EA_hvn;
                elseif obj.Vertices(EA_tvn).GraphNvE == 1
                    EA_v2r = EA_tvn;
                else
                    error("New case identified, notify developer")
                end

                EB_hvn = obj.Edges(Edge_B).HeadVertexNum;
                EB_tvn = obj.Edges(Edge_B).TailVertexNum;

                if obj.Vertices(EB_hvn).GraphNvE == 1
                    EB_v2r = EB_hvn;
                elseif obj.Vertices(EB_tvn).GraphNvE == 1
                    EB_v2r = EB_tvn;
                else
                    error("New case identified, notify developer")
                end
                
                % Create Vertex Indexing Vectors 
                M_c = obj.Properties.M;
                M_c_vidx = 1:size(M_c,1);
                M_c_vidx([EA_v2r,EB_v2r]) = [];
                M_c_eidx = 1:size(M_c,2);
                M_c_eidx(Edge_B) = [];
                M_c([EA_v2r,EB_v2r],:) = [];
                M_c(:,Edge_A) = M_c(:,Edge_B) + M_c(:,Edge_A);
                M_c(:,Edge_B) = [];

                %% Input Commonization 

                EdgeA_inputs = obj.Edges(Edge_A).InputVariables;
                EdgeB_inputs = obj.Edges(Edge_B).InputVariables;
                %assert(length(EdgeA_inputs)==length(EdgeB_inputs),"Each edge equation has a unique number of control inputs")     

                % 
                % Input Commonization
                % for i = 1:length(obj.Edges)
                %     obj_tmp.Edges(i).EdgeEq = replace(obj_tmp.Edges(i).EdgeEq,EdgeB_inputs,EdgeA_inputs);
                % end
                % 
                % for j = 1:length(obj.Vertices)
                %     obj_tmp.Vertices(j).CapacitanceEq = replace(obj_tmp.Vertices(j).CapacitanceEq,EdgeB_inputs,EdgeA_inputs);
                % end
                % 
                VerticesNew = obj_tmp.Vertices(M_c_vidx);
                EdgeNew = obj_tmp.Edges(M_c_eidx);

                % Update Vertex Objects
                for i = 1:length(VerticesNew)
                    if VerticesNew(i).VertexType == gmt_VertexType.External
                        VertexUpdated(i) = gmt_Vertex(VerticesNew(i).VertexName,VerticesNew(i).CapacitanceEq,string(VerticesNew(i).VertexType));
                    else
                        VertexUpdated(i) = gmt_Vertex(VerticesNew(i).VertexName,VerticesNew(i).CapacitanceEq);
                    end
                end

                % Update Edge Objects
                for j = 1:length(EdgeNew)
                    if string(EdgeNew(j).EdgeType) == gmt_EdgeType.External
                        EdgeUpdated(j) = gmt_Edge(EdgeNew(j).EdgeName,EdgeNew(j).EdgeEq,string(EdgeNew(j).EdgeType));
                    else
                        EdgeUpdated(j) = gmt_Edge(EdgeNew(j).EdgeName,EdgeNew(j).EdgeEq);
                    end
                end

                % Construct New Edge Matrix
                for i = 1:size(M_c,2)
                    for j = 1:size(M_c,1)
                        idx_tmp = M_c(j,i);
                        if idx_tmp == 1
                            EdgeMatrix_New(i,2) = j;             
                        elseif idx_tmp == -1
                            EdgeMatrix_New(i,1) = j;
                        end
                    end
                end   


            elseif obj.Ports(Connection(1)).PortType == gmt_PortType.VertexConnection

                %% Setup and Data Validation 
                Vertex_A = obj.Ports(Connection(1)).ElementNumber;
                Vertex_B = obj.Ports(Connection(2)).ElementNumber;

                VertexA_CapEq = obj.Vertices(Vertex_A).CapacitanceEq;
                VertexB_CapEq = obj.Vertices(Vertex_B).CapacitanceEq;
 
                assert(strcmp(VertexA_CapEq,VertexB_CapEq),"Vertices do not share common capacitance equation")

                %% Incidence Matrix Creation 
                % Append Edges to Common Vertex
                M_c = obj.Properties.M;
                M_c(Vertex_A,:) = M_c(Vertex_A,:)+M_c(Vertex_B,:);
                M_c(Vertex_B,:) = [];

                %% Create New Edge and Vertex Vectors
                Vertices_Keep_idx = 1:length(obj.Vertices);
                Vertices_Keep_idx(Vertex_B) = [];
                VerticesNew = [obj.Vertices(Vertices_Keep_idx)];
                EdgeNew = [obj.Edges];

                %% Construct New Edge Matrix from Incidence
                for i = 1:size(M_c,2)
                    for j = 1:size(M_c,1)
                        idx_tmp = M_c(j,i);
                        if idx_tmp == 1
                            EdgeMatrix_New(i,2) = j;             
                        elseif idx_tmp == -1
                            EdgeMatrix_New(i,1) = j;
                        end
                    end
                end       

                % Update Vertex Objects
                for i = 1:length(VerticesNew)
                    if VerticesNew(i).VertexType == gmt_VertexType.External
                        VertexUpdated(i) = gmt_Vertex(VerticesNew(i).VertexName,VerticesNew(i).CapacitanceEq,string(VerticesNew(i).VertexType));
                    else
                        VertexUpdated(i) = gmt_Vertex(VerticesNew(i).VertexName,VerticesNew(i).CapacitanceEq);
                    end
                end

                % Update Edge Objects
                for j = 1:length(EdgeNew)
                    if string(EdgeNew(j).EdgeType) == gmt_EdgeType.External
                        EdgeUpdated(j) = gmt_Edge(EdgeNew(j).EdgeName,EdgeNew(j).EdgeEq,string(EdgeNew(j).EdgeType));
                    else
                        EdgeUpdated(j) = gmt_Edge(EdgeNew(j).EdgeName,EdgeNew(j).EdgeEq);
                    end
                end

            end

            Params_New = obj.ModelParameters;

            %% Update System Port Connections 
            Ports_idx = 1:length(obj.Ports);
            PortsA_idx_keep = setdiff(Ports_idx,[Connection(1);Connection(2)]);
            PortsA = obj.Ports(PortsA_idx_keep);

            obj_tmp = gmt_Graph("Combine",EdgeMatrix_New,EdgeUpdated,VertexUpdated,Params_New,obj.InputData,varargin{:});  
            obj_tmp.Ports = [PortsA(:)]';
            obj = obj_tmp;

        end
    end
end
